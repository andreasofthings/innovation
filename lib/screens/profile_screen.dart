import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _language;
  late double _confidence;
  late int _defaultWorkshopLength;
  late String _defaultWorkshopSetting;
  late int _defaultGroupSize;
  late bool _isGoogleConnected;
  late Color _color;
  late String _icon;
  DateTime? _dateOfBirth;
  late String _country;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final userProvider = context.watch<UserProvider>();
      final profile = userProvider.profile;
      if (profile != null) {
        _language = profile.language;
        _confidence = profile.confidence;
        _defaultWorkshopLength = profile.defaultWorkshopLength;
        _defaultWorkshopSetting = profile.defaultWorkshopSetting;
        _defaultGroupSize = profile.defaultGroupSize;
        _isGoogleConnected = profile.isGoogleConnected;
        _color = Color(int.parse(profile.color.replaceFirst('#', '0xFF')));
        _icon = profile.icon;
        _dateOfBirth = profile.dateOfBirth;
        _country = profile.country;
        _isInitialized = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    if (userProvider.isLoading && !_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userProvider.profile == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('General Settings'),
              DropdownButtonFormField<String>(
                value: _language,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'de', child: Text('German')),
                ],
                onChanged: (value) => setState(() => _language = value!),
              ),
              const SizedBox(height: 16),
              Text('Confidence: ${(_confidence * 100).toInt()}%'),
              Slider(
                value: _confidence,
                min: 0,
                max: 1,
                divisions: 10,
                label: '${(_confidence * 100).toInt()}%',
                onChanged: (value) => setState(() => _confidence = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _defaultWorkshopLength.toString(),
                decoration: const InputDecoration(labelText: 'Default Length for Workshops (min)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _defaultWorkshopLength = int.tryParse(value) ?? 60,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _defaultWorkshopSetting,
                decoration: const InputDecoration(labelText: 'Default Setting for Workshops'),
                items: const [
                  DropdownMenuItem(value: 'remote', child: Text('Remote')),
                  DropdownMenuItem(value: 'on-site', child: Text('On-site')),
                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                ],
                onChanged: (value) => setState(() => _defaultWorkshopSetting = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _defaultGroupSize.toString(),
                decoration: const InputDecoration(labelText: 'Default Group Size'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _defaultGroupSize = int.tryParse(value) ?? 10,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Personal Details'),
              TextFormField(
                initialValue: _country,
                decoration: const InputDecoration(labelText: 'Country'),
                onChanged: (value) => _country = value,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date of Birth'),
                subtitle: Text(_dateOfBirth == null ? 'Not set' : DateFormat('yyyy-MM-dd').format(_dateOfBirth!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateOfBirth,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Apperance'),
              ListTile(
                title: const Text('Theme Color'),
                trailing: CircleAvatar(backgroundColor: _color),
                onTap: _pickColor,
              ),
              TextFormField(
                initialValue: _icon,
                decoration: const InputDecoration(labelText: 'Icon Name'),
                onChanged: (value) => _icon = value,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Integrations'),
              SwitchListTile(
                title: const Text('Connection to Google'),
                subtitle: const Text('For calendar configuration'),
                value: _isGoogleConnected,
                onChanged: (value) {
                  setState(() => _isGoogleConnected = value);
                  if (value) {
                    _connectToGoogle();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _color,
              onColorChanged: (color) => setState(() => _color = color),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _connectToGoogle() {
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connecting to Google (token sharing through pramari.de)...')),
    );
  }

  Future<void> _saveProfile() async {
    final colorHex = '#${_color.value.toRadixString(16).substring(2).toUpperCase()}';
    final updatedProfile = UserProfile(
      language: _language,
      confidence: _confidence,
      defaultWorkshopLength: _defaultWorkshopLength,
      defaultWorkshopSetting: _defaultWorkshopSetting,
      defaultGroupSize: _defaultGroupSize,
      isGoogleConnected: _isGoogleConnected,
      color: colorHex,
      icon: _icon,
      dateOfBirth: _dateOfBirth,
      country: _country,
    );

    final success = await context.read<UserProvider>().updateProfile(updatedProfile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Profile updated successfully' : 'Failed to update profile')),
      );
    }
  }
}
