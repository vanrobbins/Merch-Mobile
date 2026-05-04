import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();

/**
 * Validates an invite code server-side and creates (or finds) a pending
 * membership atomically. The invite code is never exposed to clients.
 *
 * Returns: { storeId: string, status: 'pending' | 'active' }
 * Throws:
 *   unauthenticated — caller is not signed in
 *   invalid-argument — code is not exactly 6 characters
 *   not-found — no store has the given invite code
 */
export const joinByInviteCode = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be signed in to join a store.');
  }

  const raw = typeof request.data?.inviteCode === 'string'
    ? (request.data.inviteCode as string)
    : '';
  const inviteCode = raw.trim().toUpperCase();

  if (inviteCode.length !== 6) {
    throw new HttpsError('invalid-argument', 'Enter a 6-character invite code.');
  }

  const uid = request.auth.uid;
  const token = request.auth.token;
  const displayName =
    (token.name as string | undefined) ??
    (token.email as string | undefined) ??
    'Staff';

  const storeSnap = await db
    .collection('stores')
    .where('inviteCode', '==', inviteCode)
    .limit(1)
    .get();

  if (storeSnap.empty) {
    throw new HttpsError('not-found', 'Invalid invite code.');
  }

  const storeId = storeSnap.docs[0].id;
  const membershipRef = db
    .collection('stores').doc(storeId)
    .collection('memberships').doc(uid);
  const userStoresRef = db.collection('userStores').doc(uid);

  const existing = await membershipRef.get();
  if (existing.exists) {
    const status = (existing.data()?.status as string) ?? 'pending';
    await userStoresRef.set(
      { activeStoreIds: admin.firestore.FieldValue.arrayUnion(storeId) },
      { merge: true },
    );
    return { storeId, status };
  }

  const batch = db.batch();
  batch.set(membershipRef, {
    uid,
    role: 'staff',
    status: 'pending',
    displayName,
    joinedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  batch.set(
    userStoresRef,
    { activeStoreIds: admin.firestore.FieldValue.arrayUnion(storeId) },
    { merge: true },
  );
  await batch.commit();

  return { storeId, status: 'pending' };
});
