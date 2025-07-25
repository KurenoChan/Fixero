# Firebase Initializer for Mock Data

This folder contains a Node.js script to **initialize mock users** and **upload mock data** into Firebase Realtime Database for development and testing purposes.

## 📁 Files

| File                     | Description                                                    |
|--------------------------|----------------------------------------------------------------|
| `initFirebase.js`        | Script to create users and push mock data to Realtime Database |
| `serviceAccountKey.json` | Firebase Admin SDK key file (DO NOT COMMIT TO GIT)             |


## ⚠️ Prerequisites

- [Node.js installed](https://nodejs.org/)
- Firebase project with:
    - Realtime Database enabled
    - Authentication (Email/Password) enabled
- Downloaded Firebase Admin SDK key (`serviceAccountKey.json`) from:
    - **Firebase Console → Project Settings → Service Accounts → Generate New Private Key**


## 🚀 How to Run

1. Open terminal in this folder:
   ```
   cd firebase_init
   ```
2. Install dependencies (only once):
   ```
   npm install firebase-admin
   ```
3. Run the script:
   ```
   node initFirebase.js
   ```

## 📦 What It Does
- Creates mock users in Firebase Authentication with specified UIDs, emails, and passwords. 
- Uploads initial mock data (e.g., users, jobs, etc.) to Realtime Database.

## 🧼 Optional: Reset/Delete Data
If you want to reset or clear all mock users and data, you can add functions in ```initFirebase.js``` like:

```
await db.ref().remove();              // Deletes all Realtime DB data
await auth.deleteUser('user001');     // Deletes specific user
```

## 🔐 Security Warning
❗**Do NOT commit** ```serviceAccountKey.json``` to Git repositories.
Add to ```.gitignore```:
```
firebase_init/serviceAccountKey.json
```
This file gives full admin access to your Firebase project.

## 📂 Recommended Folder Structure
```
my_flutter_project/
├── lib/
├── firebase_init/
│   ├── initFirebase.js
│   ├── serviceAccountKey.json
│   └── README.md
```

## 👤 Maintainers
This script is intended for developers/testers working on this Flutter app. Modify the mock data inside `initFirebase.js` to match your app's schema.