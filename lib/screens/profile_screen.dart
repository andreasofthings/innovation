import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
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
  late String _name;
  late String _email;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final userProvider = Provider.of<UserProvider>(context);
      final profile = userProvider.profile;
      if (profile != null) {
        _initializeFromProfile(profile);
      } else if (!userProvider.isLoading) {
        // Initialize with defaults if profile is not available and not loading
        _initializeDefaults();
      }
    }
  }

  void _initializeFromProfile(UserProfile profile) {
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
    _name = profile.name;
    _email = profile.email;
    _isInitialized = true;
  }

  void _initializeDefaults() {
    _language = 'en';
    _confidence = 0.5;
    _defaultWorkshopLength = 60;
    _defaultWorkshopSetting = 'on-site';
    _defaultGroupSize = 10;
    _isGoogleConnected = false;
    _color = const Color(0xFF25AFF4);
    _icon = 'person';
    _dateOfBirth = null;
    _country = '';
    _name = 'User';
    _email = '';
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final hasError = userProvider.hasError;
    final isEnabled = !hasError && !userProvider.isLoading;

    if (userProvider.isLoading && !_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show snackbar on error
    if (hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile not available. Using offline settings.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isEnabled ? _saveProfile : null,
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
              _buildSectionTitle('Identity'),
              Text('Name: $_name'),
              const SizedBox(height: 8),
              Text('Email: $_email'),
              const SizedBox(height: 24),
              _buildSectionTitle('General Settings'),
              DropdownButtonFormField<String>(
                value: _language,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'de', child: Text('German')),
                ],
                onChanged: isEnabled ? (value) => setState(() => _language = value!) : null,
              ),
              const SizedBox(height: 16),
              Text('Confidence: ${(_confidence * 100).toInt()}%'),
              Slider(
                value: _confidence,
                min: 0,
                max: 1,
                divisions: 10,
                label: '${(_confidence * 100).toInt()}%',
                onChanged: isEnabled ? (value) => setState(() => _confidence = value) : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _defaultWorkshopLength.toString(),
                decoration: const InputDecoration(labelText: 'Default Length for Workshops (min)'),
                keyboardType: TextInputType.number,
                enabled: isEnabled,
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
                onChanged: isEnabled ? (value) => setState(() => _defaultWorkshopSetting = value!) : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _defaultGroupSize.toString(),
                decoration: const InputDecoration(labelText: 'Default Group Size'),
                keyboardType: TextInputType.number,
                enabled: isEnabled,
                onChanged: (value) => _defaultGroupSize = int.tryParse(value) ?? 10,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Personal Details'),
              TextFormField(
                initialValue: _country,
                decoration: const InputDecoration(labelText: 'Country'),
                enabled: isEnabled,
                onChanged: (value) => _country = value,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date of Birth'),
                subtitle: Text(_dateOfBirth == null ? 'Not set' : DateFormat('yyyy-MM-dd').format(_dateOfBirth!)),
                trailing: const Icon(Icons.calendar_today),
                enabled: isEnabled,
                onTap: isEnabled ? _pickDateOfBirth : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Appearance'),
              ListTile(
                title: const Text('Theme Color'),
                trailing: CircleAvatar(backgroundColor: _color),
                enabled: isEnabled,
                onTap: isEnabled ? _pickColor : null,
              ),
              TextFormField(
                initialValue: _icon,
                decoration: const InputDecoration(labelText: 'Icon Name'),
                enabled: isEnabled,
                onChanged: (value) => _icon = value,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Integrations'),
              SwitchListTile(
                title: const Text('Connection to Google'),
                subtitle: const Text('For calendar configuration'),
                value: _isGoogleConnected,
                onChanged: isEnabled ? (value) {
                  setState(() => _isGoogleConnected = value);
                  if (value) {
                    _connectToGoogle();
                  }
                } : null,
              ),
              const SizedBox(height: 32),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
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
    final userProvider = context.read<UserProvider>();
    final currentProfile = userProvider.profile;

    final colorHex = '#${_color.value.toRadixString(16).substring(2).toUpperCase()}';
    final updatedProfile = UserProfile(
      pk: currentProfile?.pk,
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
      name: _name,
      email: _email,
      rawAttributes: currentProfile?.rawAttributes ?? {},
    );

    final success = await userProvider.updateProfile(updatedProfile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Profile updated successfully' : 'Failed to update profile')),
      );
    }
  }
}
