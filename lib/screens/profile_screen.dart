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

  bool _isInitialized = false;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final userProvider = context.watch<UserProvider>();
      final profile = userProvider.profile;
      if (profile != null) {
        _initializeFromProfile(profile);
      } else if (!userProvider.isLoading) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final userProvider = context.watch<UserProvider>();
    final isEnabled = !userProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alex Rivers', style: TextStyle(fontWeight: FontWeight.bold)),
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
            children: [
              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBj2PeVZvItcOb1y1Vqs9ksQNbjUKfBePnfgdSyVGlPCWbD_RiIaCP8uiDPKT62JW23_1WILf4AxWsLCv7O_5dRA4p2Tx9y6t6bPvjiw1Yv7fjwynRfbs1Q2UKxGvzk3ex5CJR7JIhWBjHNPvb-LcUVv3QwIl3W8lOahvaEVDl4JaX-xt4myEHmrCzaE7gLdwdEpUjLgZZIkWwPThkhWjBlq6BYRFwcswxmBTjptfnvrWAMXH-lIzGa9x6_zWWrx6tHcaju51IDyiY'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Lead Facilitator',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'COACH LEVEL 42',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingSection(
                context,
                'IDENTITY',
                [
                  _buildTextInfo('Email', _email),
                  _buildTextInfo('Country', _country),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingSection(
                context,
                'WORKSHOP PREFERENCES',
                [
                  _buildDropdownSetting('Default Setting', _defaultWorkshopSetting, ['remote', 'on-site', 'hybrid'], (val) => setState(() => _defaultWorkshopSetting = val!)),
                  _buildTextSetting('Default Length (min)', _defaultWorkshopLength.toString(), (val) => _defaultWorkshopLength = int.tryParse(val) ?? 60),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection(BuildContext context, String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: colorScheme.outline),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextInfo(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildDropdownSetting(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: DropdownButton<String>(
        value: value,
        underline: Container(),
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextSetting(String label, String initialValue, ValueChanged<String> onChanged) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: SizedBox(
        width: 60,
        child: TextFormField(
          initialValue: initialValue,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final userProvider = context.read<UserProvider>();
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
      name: _name,
      email: _email,
    );
    await userProvider.updateProfile(updatedProfile);
  }
}
