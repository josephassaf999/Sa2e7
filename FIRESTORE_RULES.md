# Firestore Security Rules Deployment Guide

This document explains the security rules for the Sa2e7 app and how to deploy them to production.

## Overview

The `firestore.rules` file contains security rules that enforce:
- **Public read access** to business listings (allows discovery)
- **Authenticated write access** to owner-specific resources
- **Fine-grained access control** for reviews, chats, and notifications
- **Default deny** for all other operations

## Security Rules Breakdown

### Users Collection

```
/Users/{userId}
- read: Only the user can read their own profile
- write: Only the user can write to their own profile
- create: Only authenticated users can create their own profile
```

**Use Cases:**
- User preferences
- Favorite businesses list
- Notification settings
- Personal data (name, email, profile picture)

### Businesses Collection

```
/businesses/{businessId}
- read: Anyone can read (public listings)
- create: Any authenticated user with a required fields (ownerId field must match their uid)
- update: Only the business owner can update
- delete: Only the business owner can delete
```

**Subcollections:**
- **reviews/** - Public read, authenticated users can add reviews
- **images/** - Public read, owner can add/delete
- **owners/** - Only owner can access

### Chats Collection

```
/chats/{chatId}
- read: Only participants can read conversations
- messages/{messageId}: Participants can read/create, users can delete own messages
```

**Security:** Participates are verified in the `participantIds` array

### Notifications Collection

```
/notifications/{notificationId}
- read: Only the recipient can read
- create: Users can create notifications for themselves
- update: Only recipient can mark as read
- delete: Only recipient can delete
```

## Deployment Steps

### Prerequisites

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Initialize Firebase project (if not already done):**
   ```bash
   firebase init
   ```
   Select "Firestore" when prompted

### Deploy Rules to Production

1. **Validate rules syntax** (before deploying):
   ```bash
   firebase deploy --only firestore:rules --dry-run
   ```
   This shows what will be deployed without actually deploying.

2. **Deploy to Firestore:**
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Verify deployment:**
   ```bash
   firebase firestore:describe-rules
   ```

### Rollback if Issues

If the new rules cause problems:

```bash
# View deployment history
firebase firestore:logs --limit=50

# Rollback to previous version (in Firebase Console)
# Firestore → Rules → Show Revision History → Restore
```

## Testing Rules

### Using Firebase Emulator (Local Testing)

1. **Install emulator:**
   ```bash
   firebase setup:emulators:firestore
   ```

2. **Start emulator:**
   ```bash
   firebase emulators:start
   ```

3. **Connect app in debug mode** - Update `firebase_config.dart` or use
   `useEmulator()` call

4. **Test read/write operations** before deploying to production

### Manual Testing in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database**
4. Click **Rules** tab
5. Test rules using the **Rules Playground** feature

## Common Issues & Solutions

### "Permission denied" when creating business

**Cause:** `ownerId` field doesn't match user's uid
```dart
// ✅ Correct - includes ownerId matching current user
await businessRef.set({
  'name': name,
  'ownerId': FirebaseAuth.instance.currentUser!.uid,
  'category': category,
  // ...
});

// ❌ Wrong - missing ownerId
await businessRef.set({
  'name': name,
  'category': category,
  // ...
});
```

### "Permission denied" updating business review

**Cause:** Review doesn't include `userId` field
```dart
// ✅ Correct
await reviewRef.set({
  'userId': uid,
  'rating': rating,
  'text': text,
  'timestamp': FieldValue.serverTimestamp(),
});

// ❌ Wrong
await reviewRef.set({
  'rating': rating,
  'text': text,  // Missing userId!
});
```

### "Permission denied" accessing other user's profile

**Cause:** Trying to read `/Users/{otherUserId}` when you're not that user

**Solution:** Only read your own user document or use Friends collection

## Updating Rules

To update rules:

1. **Edit `firestore.rules`** file
2. **Test with `--dry-run`:**
   ```bash
   firebase deploy --only firestore:rules --dry-run
   ```
3. **Deploy:**
   ```bash
   firebase deploy --only firestore:rules
   ```

## Advanced Security Patterns

### Restricting by User Roles

```javascript
// Check if user is a business owner
function isBusinessOwner() {
  return get(/databases/$(database)/documents/Users/$(userId())).data.isBusinessOwner == true;
}

// In rules:
allow create: if isAuth() && isBusinessOwner();
```

### Validating Data Structure

```javascript
// Ensure reviews have required fields
allow create: if request.resource.data.keys().hasAll(['userId', 'rating', 'text']) &&
               request.resource.data.rating >= 1 && request.resource.data.rating <= 5;
```

### Time-based restrictions

```javascript
// Prevent reviews older than 24 hours from being deleted
allow delete: if isOwner(resource.data.userId) &&
               (request.time - resource.data.createdAt) < duration.value(1, 'd');
```

## Best Practices

1. **Principle of Least Privilege** - Grant minimum necessary permissions
2. **Validate Data** - Check required fields and data types
3. **Test Thoroughly** - Use emulator and Rules Playground before production
4. **Monitor Logs** - Check Firestore logs for denied requests
5. **Update Regularly** - Review and improve rules as app evolves
6. **Document Changes** - Update this file when rules change

## Monitoring & Debugging

### View Denied Reads/Writes

In Firebase Console → Firestore → Logs:
```
resource.name: projects/YOUR_PROJECT/databases/(default)/documents/...
severity: ERROR
textPayload: "Permission denied"
```

### Debug Specific Request

Add logging to rules (Firebase Rules Playground):
```javascript
allow read: if {}.size() == 0; // Logs request
```

## References

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/start)
- [Rules Query Examples](https://firebase.google.com/docs/firestore/security/rules-query-examples)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
