// lib/login/login.dart
import 'dart:convert';

import 'package:cuplix/login/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../apiInterface/ApiInterface.dart';
import '../apiInterface/ApIHelper.dart';
import '../dashboard/Dashboard.dart';
import '../services/GoogleSignInService.dart';
import '../utils/SharedPreferences.dart';
import 'OnboardingRoleSelection.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  bool isSignIn = true;

  // controllers for sign-up fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();

  // controllers for sign-in (separate so switching forms keeps values)
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // controller for otp
  final _otpController = TextEditingController();

  bool _loading = false; // used for both flows, you can split if needed

  // OTP / verification state
  bool _otpSent = false;
  bool _emailVerified = false;

  // secure storage (also used to write legacy keys if needed)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _openDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _dobController.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  // Helper: convert dd/mm/yyyy or dd-mm-yyyy to yyyy-MM-dd (returns null if empty/invalid)
  String? _formatDobForApi(String? dobText) {
    if (dobText == null || dobText.trim().isEmpty) return null;
    final cleaned = dobText.replaceAll('-', '/').trim();
    final parts = cleaned.split('/');
    if (parts.length != 3) return null;
    final dd = parts[0].padLeft(2, '0');
    final mm = parts[1].padLeft(2, '0');
    var yy = parts[2];
    if (yy.length == 2) {
      final yearInt = int.tryParse(yy) ?? 0;
      final century = yearInt > 30 ? '19' : '20';
      yy = '$century$yy';
    }
    return '${yy.padLeft(4, '0')}-$mm-$dd';
  }

  // Helper: normalize mobile to +<digits>
  String? _normalizeMobile(String? mobile) {
    if (mobile == null) return null;
    final s = mobile.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('+')) return s;
    if (s.startsWith('00')) return '+${s.substring(2)}';
    final digits = s.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return '+$digits';
  }

  void _showModalLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideModalLoader() {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  // ---------- Verify Email (send OTP) ----------
  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email first to verify')),
      );
      return;
    }

    _showModalLoader();
    try {
      final res = await ApiHelper.post(
        url: ApiInterface.sendOtp,
        body: {'email': email},
      );
      _hideModalLoader();
      if (res['success'] == true) {
        setState(() {
          _otpSent = true;
          _emailVerified = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent to email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['error']?.toString() ?? 'Failed to send verification',
            ),
          ),
        );
      }
    } catch (e) {
      _hideModalLoader();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  // ---------- Verify OTP ----------
  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email is required')));
      return;
    }
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the OTP you received')),
      );
      return;
    }

    _showModalLoader();
    try {
      final res = await ApiHelper.post(
        url: ApiInterface.verifyEmail,
        // ensure this exists in your ApiInterface
        body: {'email': email, 'otp': otp},
      );
      _hideModalLoader();
      if (res['success'] == true) {
        setState(() {
          _emailVerified = true;
          _otpSent = false; // hide the otp input after successful verification
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['error']?.toString() ?? 'OTP verification failed',
            ),
          ),
        );
      }
    } catch (e) {
      _hideModalLoader();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  // ---------- Create Account (Sign Up) ----------
  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final mobile = _mobileController.text.trim();
    final dobText = _dobController.text.trim();

    // Require OTP verification before allowing registration
    if (!_emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify your email with the OTP before creating an account',
          ),
        ),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // Build payload exactly as your backend expects: email, password, mobile, dateofbirth
    final payload = <String, dynamic>{'email': email, 'password': password};

    final formattedDob = _formatDobForApi(dobText);
    final normalizedMobile = _normalizeMobile(mobile);

    if (normalizedMobile != null) payload['mobile'] = normalizedMobile;
    if (formattedDob != null)
      payload['dateOfBirth'] =
          formattedDob; // use camelCase key expected by backend

    setState(() => _loading = true);

    final result = await ApiHelper.post(
      url: ApiInterface.register,
      body: payload,
    );

    setState(() => _loading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );
      // Optionally switch to sign-in or clear fields:
      setState(() => isSignIn = true);
      // navigate to onboarding role selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingRoleSelection(userEmail: email),
        ),
      );
    } else {
      final err = result['error'] ?? 'Registration failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  // ---------- Sign In ----------
  Future<void> _signIn() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {},
    ); // ensures we are in UI cycle

    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    final payload = {'email': email, 'password': password};

    setState(() => _loading = true);
    _showModalLoader();

    try {
      final result = await ApiHelper.post(
        url: ApiInterface.login,
        body: payload,
      );

      _hideModalLoader();
      setState(() => _loading = false);

      if (result['success'] == true) {
        final data = result['data'];

        // Typical shapes: { user: {...}, accessToken: "...", refreshToken: "..." }
        String? accessToken;
        String? refreshToken;
        Map<String, dynamic>? userMap;

        if (data != null && data is Map<String, dynamic>) {
          // token keys differ by backend - try common ones
          accessToken =
              (data['accessToken'] ?? data['token'] ?? data['access_token'])
                  ?.toString();
          refreshToken =
              (data['refreshToken'] ?? data['refresh_token'])?.toString();

          if (data['user'] is Map) {
            userMap = Map<String, dynamic>.from(data['user'] as Map);
          } else if (data['user'] is String) {
            try {
              userMap =
                  jsonDecode(data['user'] as String) as Map<String, dynamic>;
            } catch (_) {
              userMap = null;
            }
          } else if (data['user'] == null) {
            // sometimes some backends put user fields at top-level
            // try top-level name/email
            final nameTop = data['name']?.toString();
            final emailTop = data['email']?.toString();
            if (nameTop != null || emailTop != null) {
              userMap = <String, dynamic>{};
              if (nameTop != null) userMap['name'] = nameTop;
              if (emailTop != null) userMap['email'] = emailTop;
            }
          }
        }

        final userEmail = userMap != null ? userMap['email']?.toString() : null;
        final userName = userMap != null ? userMap['name']?.toString() : null;
        final userNumber =
            userMap != null ? userMap['number']?.toString() : null;

        // Save tokens + user info securely (best-effort)
        try {
          if (accessToken != null && accessToken.isNotEmpty) {
            await SharedPrefs.setAccessToken(accessToken);
            // also write legacy key for backward compat
            await _secureStorage.write(key: 'auth_token', value: accessToken);
          }
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await SharedPrefs.setRefreshToken(refreshToken);
            await _secureStorage.write(
              key: 'refresh_token',
              value: refreshToken,
            );
          }
          if (userEmail != null) await SharedPrefs.setEmail(userEmail);
          if (userName != null) await SharedPrefs.setName(userName);
          if (userNumber != null) await SharedPrefs.setNumber(userNumber);
        } catch (e) {
          // don't break login flow on storage failures
          // ignore: avoid_print
          print('Warning: failed to persist login data: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else {
        final err = result['error'] ?? 'Login failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err.toString())));
      }
    } catch (e) {
      _hideModalLoader();
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  Widget _buildLoader() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Center(
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFFaf57db), Color(0xFFe46791)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo (replace asset or fallback to icon)
                Image.asset(
                  'lib/assets/logo.jpg',
                  height: 60,
                  width: 60,
                  errorBuilder:
                      (c, e, s) => const Icon(
                        Icons.favorite,
                        size: 60,
                        color: Colors.purple,
                      ),
                ),

                const SizedBox(height: 12),

                // Gradient title
                ShaderMask(
                  shaderCallback:
                      (bounds) => gradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: const Text(
                    'Welcome to Cuplix.AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // required for shader
                    ),
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  'Your AI relationship companion',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),

                const SizedBox(height: 24),

                // Toggle (Sign In / Sign Up)
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F0F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Sign In
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!isSignIn) setState(() => isSignIn = true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color:
                                  isSignIn ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow:
                                  isSignIn
                                      ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    isSignIn ? Colors.black : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Sign Up
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isSignIn) setState(() => isSignIn = false);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color:
                                  !isSignIn ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow:
                                  !isSignIn
                                      ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    !isSignIn ? Colors.black : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Animated crossfade between SignInForm and SignUpForm
                AnimatedCrossFade(
                  firstChild: _buildSignInForm(gradient),
                  secondChild: _buildSignUpForm(gradient),
                  crossFadeState:
                      isSignIn
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 250),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Sign In Form ----------------
  Widget _buildSignInForm(Gradient gradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google continue (full width)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: () {
             // GoogleAuthClient.signInWithGoogleAndBackend(context);
            },
            icon: Image.asset(
              'lib/assets/chrome.png',
              height: 18,
              width: 18,
              errorBuilder: (c, e, s) => const Icon(Icons.language),
            ),
            label: const Text(
              "Continue with Google",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: const [
            Expanded(child: Divider(color: Colors.grey)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "OR CONTINUE WITH",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),

        const SizedBox(height: 16),

        // Email (sign in)
        TextField(
          controller: _signInEmailController,
          decoration: InputDecoration(
            hintText: 'you@example.com',
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        // Password (sign in)
        TextField(
          controller: _signInPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 24),

        // Sign In button (gradient)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFaf57db).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              _loading
                  ? _buildLoader()
                  : ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  // ---------------- Sign Up Form ----------------
  Widget _buildSignUpForm(Gradient gradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google sign up
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.28),
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Image.asset(
              'lib/assets/chrome.png',
              height: 18,
              width: 18,
              errorBuilder: (c, e, s) => const Icon(Icons.language),
            ),
            label: const Text(
              "Sign up with Google",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: const [
            Expanded(child: Divider(color: Colors.grey)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "OR SIGN UP WITH",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),

        const SizedBox(height: 16),

        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  filled: true,
                  fillColor: const Color(0xFFF8F6F8),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _verifyEmail,
              icon: const Icon(Icons.mail_outline),
              label: Text(_otpSent ? 'Resend OTP' : 'Send OTP'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        const Text(
          "Click 'Verify' to receive a verification code",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),

        const SizedBox(height: 8),

        // Show OTP input and Verify button when OTP was sent and email not yet verified
        if (_otpSent && !_emailVerified) ...[
          const SizedBox(height: 12),
          const Text(
            'Enter OTP',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    hintText: '123456',
                    filled: true,
                    fillColor: const Color(0xFFF8F6F8),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _verifyOtp,
                child: const Text('Verify'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],

        // Show small badge if email verified
        if (_emailVerified) ...[
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text('Email verified', style: TextStyle(color: Colors.green)),
            ],
          ),
        ],

        const SizedBox(height: 8),

        const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '••••••••',
            filled: true,
            fillColor: const Color(0xFFF8F6F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Must be at least 6 characters',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),

        const SizedBox(height: 18),

        const Text(
          'Mobile Number (Optional)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '123-456-7890',
            filled: true,
            fillColor: const Color(0xFFF8F6F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "We'll use this for account security and important notifications",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),

        const SizedBox(height: 18),

        const Text(
          'Date of Birth (Optional)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dobController,
          readOnly: true,
          onTap: _openDatePicker,
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            suffixIcon: const Icon(Icons.calendar_today),
            filled: true,
            fillColor: const Color(0xFFF8F6F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Helps us provide age-appropriate relationship guidance',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),

        const SizedBox(height: 20),

        // Create Account (gradient)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFaf57db).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
              _loading
                  ? _buildLoader()
                  : ElevatedButton(
                    onPressed: _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}
