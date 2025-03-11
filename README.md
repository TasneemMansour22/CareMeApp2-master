# CareMe App 🚀

A **Flutter-based** application designed to assist elderly people in their daily lives by providing **health monitoring, medication reminders, and legal/financial support**.

## 🎯 Project Idea, Purpose, and Problem It Solves  

CareMe is a Flutter-based app designed to assist the elderly in managing their daily lives.  
It provides **health monitoring, medication reminders, and legal/financial support** in one platform.  
The app helps seniors **track their health, take medications on time, and access professional assistance** easily.  
It addresses the **challenges of missed medications, undiagnosed health issues, and difficulties in handling legal or financial matters**.  
CareMe aims to improve the **quality of life** for seniors by offering a simple and reliable digital solution.  


## ✨ Features

✅ Health status assessment  
✅ Medication reminders with Firebase Cloud Messaging  
✅ Legal and financial services  
✅ User-friendly and visually appealing UI  
✅ Notification system with badge count  
✅ Secure document upload and privacy settings  
✅ Admin role for managing legal and financial content

## 🗕️ Installation

Clone the repository and run the following commands:

```sh
git clone https://github.com/your-username/careme.git
cd careme
flutter pub get
flutter run
```

## ⚙️ Firebase Setup
To enable full functionality, configure Firebase:

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an Android/iOS app and download the `google-services.json` (Android) or `GoogleService-Info.plist` (iOS).
3. Place the files in the respective platform directories:
    - Android: `android/app/google-services.json`
    - iOS: `ios/Runner/GoogleService-Info.plist`
4. Enable Firestore, Firebase Cloud Messaging, and Authentication.
5. Run the following command to ensure dependencies are configured correctly:

```sh
flutterfire configure
```

## 🔧 Running the App
To run the app, use the following command:

```sh
flutter run
```

For testing:
```sh
flutter test
```

## 🌟 License
This project is licensed under the [MIT License](LICENSE).
