# Security Issues — Merch-Mobile

Reviewed: 2026-05-04 | Branch: `feature/v0.3`

---

## Must Fix

### 1. No Firebase Storage Security Rules

**Severity:** HIGH  
**File:** `firebase.json` (missing `"storage"` key) / `lib/features/photo_docs/photo_provider.dart:103`

There is no `storage.rules` file and no storage entry in `firebase.json`. Firebase Storage falls back to its default rules, which allow **any authenticated user to read, write, overwrite, or delete any file at any path**. A staff member from Store A can download, overwrite, or delete before/after photos belonging to Store B by constructing the path `photos/<storeBId>/<uid>/<id>.jpg` directly.

Firestore rules correctly protect photo *metadata* documents, but they have no effect on the actual files in Cloud Storage — that is a separate rules system.

**Fix — create `storage.rules` at the project root:**

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /photos/{storeId}/{userId}/{photoId} {
      allow read:  if request.auth != null
                   && exists(/databases/(default)/documents/stores/$(storeId)/memberships/$(request.auth.uid))
                   && get(/databases/(default)/documents/stores/$(storeId)/memberships/$(request.auth.uid)).data.status == 'active';
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && exists(/databases/(default)/documents/stores/$(storeId)/memberships/$(request.auth.uid))
                   && get(/databases/(default)/documents/stores/$(storeId)/memberships/$(request.auth.uid)).data.status == 'active';
    }
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**Add to `firebase.json`:**

```json
"storage": {
  "rules": "storage.rules"
}
```

**Deploy:**

```bash
firebase deploy --only storage
```

---

## Optional Improvements

### 2. Login Error Leaks Account Existence

**Severity:** LOW  
**File:** `lib/features/auth/login_screen.dart:55–57`

The raw Firebase error string is shown directly to the user:

```dart
final error = activeState.hasError ? activeState.error.toString() : _confirmError;
```

Firebase returns different error codes for `auth/user-not-found` vs `auth/wrong-password`, which tells an attacker whether a given email is registered. Low risk for an internal retail tool, but easy to close.

**Fix — show a generic message instead:**

```dart
final error = activeState.hasError
    ? 'Invalid email or password. Please try again.'
    : _confirmError;
```

---

### 3. Store Metadata Exposes Invite Codes to All Authenticated Users

**Severity:** LOW  
**File:** `firestore.rules:26–30`

The Firestore rule for the `stores` collection allows any authenticated user to read any store document:

```
allow read: if request.auth != null;
```

The store document contains the `inviteCode` field. A user who is a member of any store can read the invite code for a different store they don't belong to. The existing code has a comment acknowledging this trade-off (needed so the join-by-code query works before membership exists).

This is not directly exploitable into a full breach — even with a valid invite code, new memberships are forced to `role: 'staff'` and `status: 'pending'` by the create rule, and require coordinator approval before becoming active. Risk is low for this app's threat model.

**Option A (minimal change):** Move invite code validation to a Cloud Function so the code never needs to be readable by clients. The function validates the code server-side and creates the membership atomically.

**Option B (low effort):** Restrict the store read to members and add a dedicated public lookup document (no invite code) for the join flow.

---

## Not Vulnerable (Confirmed)

| Concern | Verdict |
|---|---|
| Brute force login | Firebase Auth enforces server-side rate limiting automatically (`auth/too-many-requests`) |
| Injection through login fields | Not possible — credentials go directly to Firebase Auth SDK, no query is constructed |
| Role self-escalation on join | Blocked — Firestore rule C3 enforces `role == 'staff'` and `status == 'pending'` on create |
| Pending member self-approval | Blocked — rule C4 uses `hasOnly(['uid'])` on self-updates, preventing status/role changes |
| Manager escalating to coordinator | Blocked — only `isCoordinator()` can write membership updates |
| IDOR on product reads | Not exploitable — Firestore enforces `isMember(storeId)` on all product reads |
| Cross-store photo metadata access | Not exploitable — Firestore rules scope photo documents to store members |
