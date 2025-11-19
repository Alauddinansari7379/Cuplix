import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../apiInterface/APIHelper.dart';
import '../apiInterface/ApiInterface.dart';

/// ProfileCompletionPage
///
/// Accepts optional existingProfile map to prefill fields.
/// On successful update it pops with `true`.
class ProfileCompletionPage extends StatefulWidget {
  final Map<String, dynamic>? existingProfile;

  const ProfileCompletionPage({super.key, this.existingProfile});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for fields
  late final TextEditingController _nameCtr;
  late final TextEditingController _roleCtr;
  late final TextEditingController _avatarCtr;
  late final TextEditingController _mobileCtr;
  late final TextEditingController _dobCtr;
  late final TextEditingController _ageCtr;
  late final TextEditingController _religionCtr;
  late final TextEditingController _religiosityScoreCtr;
  late final TextEditingController _placeOfBirthCtr;
  late final TextEditingController _journeyStartDateCtr;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final p = widget.existingProfile ?? <String, dynamic>{};

    _nameCtr = TextEditingController(text: p['name']?.toString() ?? '');
    _roleCtr = TextEditingController(text: p['role']?.toString() ?? '');
    _avatarCtr =
        TextEditingController(text: p['avatarUrl']?.toString() ?? '');
    _mobileCtr = TextEditingController(text: p['mobile']?.toString() ?? '');
    // normalize date to yyyy-MM-dd if present (strip time)
    String dob = '';
    if (p['dateOfBirth'] != null) {
      final raw = p['dateOfBirth'].toString();
      dob = raw.split('T').first;
    }
    _dobCtr = TextEditingController(text: dob);
    _ageCtr =
        TextEditingController(text: p['age'] != null ? p['age'].toString() : '');
    _religionCtr =
        TextEditingController(text: p['religion']?.toString() ?? '');
    _religiosityScoreCtr = TextEditingController(
        text: p['religiosityScore'] != null
            ? p['religiosityScore'].toString()
            : '');
    _placeOfBirthCtr =
        TextEditingController(text: p['placeOfBirth']?.toString() ?? '');
    String journey = '';
    if (p['journeyStartDate'] != null) {
      final raw = p['journeyStartDate'].toString();
      journey = raw.split('T').first;
    }
    _journeyStartDateCtr = TextEditingController(text: journey);
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _roleCtr.dispose();
    _avatarCtr.dispose();
    _mobileCtr.dispose();
    _dobCtr.dispose();
    _ageCtr.dispose();
    _religionCtr.dispose();
    _religiosityScoreCtr.dispose();
    _placeOfBirthCtr.dispose();
    _journeyStartDateCtr.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initial = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initial = DateTime.parse(controller.text);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // Build request body matching API
    final body = <String, dynamic>{
      "name": _nameCtr.text.trim(),
      "role": _roleCtr.text.trim().isEmpty ? null : _roleCtr.text.trim(),
      "avatarUrl": _avatarCtr.text.trim().isEmpty ? null : _avatarCtr.text.trim(),
      "mobile": _mobileCtr.text.trim(),
      "dateOfBirth": _dobCtr.text.trim().isEmpty ? null : _dobCtr.text.trim(),
      "age": _ageCtr.text.trim().isEmpty ? null : int.tryParse(_ageCtr.text.trim()),
      "religion": _religionCtr.text.trim().isEmpty ? null : _religionCtr.text.trim(),
      "religiosityScore": _religiosityScoreCtr.text.trim().isEmpty
          ? null
          : int.tryParse(_religiosityScoreCtr.text.trim()),
      "placeOfBirth": _placeOfBirthCtr.text.trim().isEmpty ? null : _placeOfBirthCtr.text.trim(),
      "journeyStartDate": _journeyStartDateCtr.text.trim().isEmpty ? null : _journeyStartDateCtr.text.trim(),
    };

    try {
      // If your API needs token in header, ApiHelper.post with context should handle it,
      // otherwise ensure ApiHelper sends auth header or add a get token + header here.
      final res = await ApiHelper.post(
        url: '${ApiInterface.profiles}/me',
        body: body,
        context: context,
        showLoader: true,
      );

      if (res['success'] == true) {
        // success — pop true so caller can refresh
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      } else {
        final err = res['error'] ?? 'Update failed';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Name
                TextFormField(
                  controller: _nameCtr,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),

                // Role
                TextFormField(
                  controller: _roleCtr,
                  decoration: const InputDecoration(labelText: 'Role (e.g., partner)'),
                ),
                const SizedBox(height: 12),

                // Avatar URL (or add image picker here)
                TextFormField(
                  controller: _avatarCtr,
                  decoration: const InputDecoration(
                    labelText: 'Avatar URL',
                    helperText: 'Or leave blank and upload photo later',
                  ),
                ),
                const SizedBox(height: 8),
                // TODO: add image picker & upload. If you upload image, set avatarUrl to returned URL.

                // Mobile
                TextFormField(
                  controller: _mobileCtr,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Mobile is required' : null,
                ),
                const SizedBox(height: 12),

                // Date of birth + age (DOB picker will fill dob)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dobCtr,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Date of Birth'),
                        onTap: () => _pickDate(_dobCtr),
                        validator: (v) => v == null || v.trim().isEmpty ? 'DOB is required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _ageCtr,
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Religion
                TextFormField(
                  controller: _religionCtr,
                  decoration: const InputDecoration(labelText: 'Religion'),
                ),
                const SizedBox(height: 12),

                // Religiosity score
                TextFormField(
                  controller: _religiosityScoreCtr,
                  decoration: const InputDecoration(labelText: 'Religiosity Score (numeric)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Place of birth
                TextFormField(
                  controller: _placeOfBirthCtr,
                  decoration: const InputDecoration(labelText: 'Place of Birth'),
                ),
                const SizedBox(height: 12),

                // Journey start date
                TextFormField(
                  controller: _journeyStartDateCtr,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Journey Start Date'),
                  onTap: () => _pickDate(_journeyStartDateCtr),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Save Profile'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context, false),
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
