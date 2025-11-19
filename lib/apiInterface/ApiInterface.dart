class ApiInterface {
  static const String baseUrl = "http://34.131.187.109:3001/api/";
  //auth
  static const String register = "${baseUrl}auth/register";
  static const String login = "${baseUrl}auth/login";
  static const String sendOtp = "${baseUrl}auth/send-otp";
  static const String verifyEmail = "${baseUrl}auth/verify-otp";
//Google auth
  static const String authGoogle = "${baseUrl}auth/google";
  static const String authVerify = "${baseUrl}auth/verify";
  static const String profiles = "${baseUrl}profiles/me";
  static const String deletePersonalityProfile = "${baseUrl}personality-profiles/me";
  static const String getCycleTracking = "${baseUrl}cycle-tracking";
  static const String partnerConnections = "${baseUrl}partner-connections";
}
