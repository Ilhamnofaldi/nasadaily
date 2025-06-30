# Mengatasi Firebase Permission Error

## 1. **Deploy Firestore Rules**

Untuk mengatasi error permission-denied, deploy Firestore rules dengan command berikut:

```bash
# Install Firebase CLI jika belum ada
npm install -g firebase-tools

# Login ke Firebase
firebase login

# Inisialisasi project di folder ini
firebase init firestore

# Deploy rules ke Firebase
firebase deploy --only firestore:rules
```

**PENTING**: Setelah menjalankan `firebase init firestore`, pilih:
- Use existing project: **nasasnapshots**  
- Firestore rules file: **firestore.rules** (default)
- Firestore indexes file: **firestore.indexes.json** (default)

## 2. **Alternative: Manual Setup di Firebase Console**

Jika command di atas gagal, buat rules manual di Firebase Console:

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project "nasasnapshots"
3. Masuk ke **Firestore Database**
4. Klik tab **Rules**
5. Copy-paste rules berikut:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Rules for user data - favorites and catatan are subcollections
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcollection rules for favorites
      match /favorites/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Subcollection rules for catatan
      match /catatan/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

6. Klik **Publish**

## 3. **Verifikasi Authentication**

Pastikan user sudah login dengan benar:

1. Cek di **Authentication** tab di Firebase Console
2. Pastikan user terdaftar dan aktif
3. Test login/logout di aplikasi

## 4. **Test Aplikasi**

Setelah deploy rules:

1. Restart aplikasi
2. Login ulang jika perlu
3. Coba favoritkan foto terlebih dahulu
4. Tambahkan catatan pada foto yang sudah difavoritkan

## 5. **Troubleshooting**

Jika masih error:

- Pastikan internet connection stabil
- Clear app data dan login ulang
- Cek Firebase console untuk error logs
- Pastikan project ID sesuai di `firebase_options.dart` 