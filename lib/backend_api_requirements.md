# Backend API Requirements for Favorites Capability

To support the "liking" (favorites) capability in the Coach application, the following changes are required in the Django Rest Framework (DRF) backend.

## 1. User Profile Model Update
The user profile model (managed via `https://pramari.de/api/v2/profile/`) should include a `favorites` field.

- **Field Name**: `favorites`
- **Type**: List of Integers (Method IDs)
- **Behavior**:
    - **GET**: Return the current list of favorited method IDs.
    - **PATCH**: Accept a list of integers to update the favorites.

## 2. API Endpoints

### Fetch Profile
**GET** `https://pramari.de/api/v2/profile/`

**Response Example**:
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "favorites": [12, 45, 67],
  ...
}
```

### Update Favorites
**PATCH** `https://pramari.de/api/v2/profile/`

**Request Body**:
```json
{
  "favorites": [12, 45, 67, 89]
}
```

**Response**: `200 OK` with the updated profile.

## 3. Implementation Notes
- The `favorites` field should be handled as a standard field in the serializer.
- Validation should ensure that the provided IDs correspond to existing `MethodPage` objects.
