# Coach App - Profile Screen Implementation Specification

## Overview
The Profile Screen allows authenticated users to view and edit their Coach application preferences and personal information. All data is persisted to the Django backend at `https://www.pramari.de/api/v2/profile/`.

---

## API Specification

### Endpoint Details

**Base URL:** `https://www.pramari.de/api/v2/profile/`

**Authentication:** 
- All requests must include the Authentik JWT access token
- Header format: `Authorization: Bearer {access_token}`
- Token is available from `AuthProvider.accessToken`

### GET Request (Fetch Profile)

```
GET https://www.pramari.de/api/v2/profile/
Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json
```

**Response (200 OK):**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "language": "en",
  "confidence": 0.5,
  "default_workshop_length": 60,
  "default_workshop_setting": "on-site",
  "default_group_size": 10,
  "is_google_connected": false,
  "color": "#25AFF4",
  "icon": "person",
  "date_of_birth": "1990-01-15",
  "country": "Germany",
  "favorites": [1, 5, 23, 42]
}
```

**Field Descriptions:**
| Field | Type | Editable | Description |
|-------|------|----------|-------------|
| `name` | string | ❌ | User's full name from Authentik (read-only) |
| `email` | string | ❌ | User's email from Authentik (read-only) |
| `language` | string | ✅ | Language preference (e.g., "en", "de", "fr") |
| `confidence` | float | ✅ | Confidence level (0.0 - 1.0) |
| `default_workshop_length` | integer | ✅ | Default workshop duration in minutes |
| `default_workshop_setting` | string | ✅ | Workshop setting ("on-site" or "virtual") |
| `default_group_size` | integer | ✅ | Default group size (min 1) |
| `is_google_connected` | boolean | ✅ | Google Calendar integration status |
| `color` | string | ✅ | Hex color code (e.g., "#25AFF4") |
| `icon` | string | ✅ | Icon name/identifier (e.g., "person", "star") |
| `date_of_birth` | string (ISO 8601) | ✅ | Birth date in format "YYYY-MM-DD" or null |
| `country` | string | ✅ | Country name or country code |
| `favorites` | array[int] | ✅ | List of favorite method IDs |

**Error Responses:**
- `401 Unauthorized` - Invalid or expired token
- `500 Internal Server Error` - Server error

---

### PATCH Request (Update Profile)

```
PATCH https://www.pramari.de/api/v2/profile/
Headers:
  Authorization: Bearer {access_token}
  Content-Type: application/json

Body (only include fields to update):
{
  "language": "de",
  "confidence": 0.75,
  "default_workshop_length": 90,
  "default_workshop_setting": "virtual",
  "default_group_size": 15,
  "is_google_connected": true,
  "color": "#FF6B6B",
  "icon": "star",
  "date_of_birth": "1990-01-15",
  "country": "Germany",
  "favorites": [1, 5, 23, 42]
}
```

**Response (200 OK):**
Returns the complete updated profile object (same format as GET response).

**Error Responses:**
- `400 Bad Request` - Invalid field values
- `401 Unauthorized` - Invalid or expired token
- `500 Internal Server Error` - Server error

---

## UserProfile Model (Already Exists)

Update `lib/models/user_profile.dart` to ensure it has all fields:

```dart
class UserProfile {
  final String language;
  final double confidence;
  final int defaultWorkshopLength;
  final String defaultWorkshopSetting;
  final int defaultGroupSize;
  final bool isGoogleConnected;
  final String color;
  final String icon;
  final DateTime? dateOfBirth;
  final String country;
  final String name;
  final String email;
  final List<int> favorites;

  UserProfile({
    required this.language,
    required this.confidence,
    required this.defaultWorkshopLength,
    required this.defaultWorkshopSetting,
    required this.defaultGroupSize,
    required this.isGoogleConnected,
    required this.color,
    required this.icon,
    this.dateOfBirth,
    required this.country,
    required this.name,
    required this.email,
    this.favorites = const [],
  });

  // ... existing copyWith, toMap, fromMap, toJson, fromJson ...
}
```

---

## UserProvider Updates

Update `lib/providers/user_provider.dart` to use the new backend URL:

```dart
String get _baseUrl {
  // Update from: 'https://pramari.de/api/v2/profile'
  // To:
  return 'https://www.pramari.de/api/v2/profile';
}
```

The `fetchProfile()`, `updateProfile()`, and `toggleFavorite()` methods already work correctly with the backend.

---

## Profile Screen UI Requirements

### Screen Layout

**Header Section (Read-only):**
- User name (from profile.name)
- User email (from profile.email)
- Avatar or icon placeholder

**Editable Sections:**

#### 1. Language Preference
- **Type:** Dropdown
- **Options:** "English" (en), "German" (de), "French" (fr), etc.
- **Field:** `language`

#### 2. Confidence Level
- **Type:** Slider (0.0 - 1.0)
- **Display:** Show as percentage (0% - 100%)
- **Field:** `confidence`
- **Example:** 0.5 = 50%

#### 3. Workshop Settings
- **Type:** Multiple inputs
- **Fields:**
  - `default_workshop_length`: Input field (integer, minutes)
  - `default_workshop_setting`: Dropdown ("on-site" or "virtual")
  - `default_group_size`: Input field (integer)

#### 4. Visual Preferences
- **Type:** Selection inputs
- **Fields:**
  - `color`: Color picker (hex input or visual picker)
  - `icon`: Icon selector (list or grid)

#### 5. Personal Information
- **Type:** Input fields
- **Fields:**
  - `date_of_birth`: Date picker (ISO 8601 format)
  - `country`: Input field (text or country dropdown)

#### 6. Integrations
- **Type:** Toggle switch
- **Field:** `is_google_connected`
- **Note:** This is a read-only indicator; actual connection happens elsewhere

#### 7. Favorites Summary
- **Type:** Display (read-only)
- **Field:** `favorites`
- **Display:** Show count of liked methods
- **Link:** Navigate to FavoritesScreen when tapped

### Interaction Flow

#### On Screen Load:
1. Fetch profile data using `UserProvider.fetchProfile()`
2. Display loading indicator while fetching
3. Display error message if fetch fails
4. Populate all fields with fetched data

#### On Field Change:
1. Update local `UserProvider._profile` optimistically
2. Trigger `UserProvider.updateProfile(updatedProfile)`
3. Show loading state (disable buttons, show spinner)
4. On success: Show success toast/snackbar
5. On failure: Revert to previous values, show error message

#### Save Button:
- Only needed if using a form-based approach
- Alternative: Save on each field change (recommended)

#### Cancel/Discard:
- Load fresh data from `UserProvider.profile`
- Discard unsaved changes

---

## Error Handling

### Network Errors
```dart
try {
  await userProvider.updateProfile(updatedProfile);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Profile updated successfully')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to update profile: $e')),
  );
}
```

### Token Expiration
- If `updateProfile()` returns false or receives 401, trigger token refresh
- Use `AuthProvider.refresh()` to get new token
- Retry the request with new token
- If refresh fails, redirect to login

### Validation
- `confidence`: Must be 0.0 - 1.0
- `defaultWorkshopLength`: Must be > 0
- `defaultGroupSize`: Must be > 0
- `color`: Must be valid hex format (e.g., #RRGGBB)
- `dateOfBirth`: Must be valid ISO 8601 date or null
- `favorites`: Must be array of integers

---

## State Management

Use the existing `UserProvider`:

```dart
// In ProfileScreen
Consumer<UserProvider>(
  builder: (context, userProvider, child) {
    final profile = userProvider.profile;
    
    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (userProvider.hasError) {
      return Center(
        child: Text('Failed to load profile'),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile form fields here
          // Use userProvider.updateProfile() to save
        ],
      ),
    );
  },
)
```

---

## Dependencies

Ensure these packages are in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0  # State management (already in use)
  http: ^1.1.0      # API calls (already in use)
  intl: ^0.19.0     # Date formatting
  google_fonts: ^5.0.0  # Typography (already in use)
```

---

## Testing Checklist

- [ ] Fetch profile on screen load
- [ ] Display all fields correctly
- [ ] Edit language preference
- [ ] Adjust confidence slider
- [ ] Update workshop settings
- [ ] Change color preference
- [ ] Select different icon
- [ ] Update birth date
- [ ] Update country
- [ ] Toggle Google connection
- [ ] Save changes to backend
- [ ] Handle network errors gracefully
- [ ] Handle token expiration and refresh
- [ ] Validate field inputs
- [ ] Show loading states
- [ ] Show success/error messages
- [ ] Verify favorites count displays correctly

---

## Related Screens

- **HomeScreen**: Display user's name and selected preferences
- **FavoritesScreen**: Show methods in `profile.favorites` list
- **LoginScreen**: Authenticate user with Authentik (already implemented)

---

## Notes for Developer

1. **Token Handling**: All API requests automatically include the Bearer token from `AuthProvider.accessToken`. If you get a 401 error, the token has expired and needs to be refreshed.

2. **URL Change**: The backend was previously at `https://pramari.de/api/v2/profile` but is now at `https://www.pramari.de/api/v2/profile`. Make sure to update the `UserProvider._baseUrl` getter.

3. **Readonly Fields**: `name` and `email` come from Authentik and cannot be edited in this app. If users need to change these, they must do so in Authentik's own profile settings.

4. **Favorites**: The `favorites` array is managed by the favorites screen and library screens, but displayed here as a summary.

5. **Cross-domain CORS**: The Flutter app at `coach.pramari.de` can communicate with the backend at `www.pramari.de` because CORS is configured on the backend to allow this.

---

## Questions or Issues?

Contact the backend team if:
- API response differs from specification
- Getting unexpected error codes
- Token validation fails repeatedly
- Need to add new profile fields
