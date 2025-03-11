# 🚀 CareMe App  

A Flutter-based application designed to assist elderly people in their daily lives by providing health monitoring, medication reminders, and legal/financial support.  

## 🔧 How to Run the Project  

To set up and run the **CareMe** app on your system, follow these steps:  

1. **Clone the Repository**  
   ```sh
   git clone https://github.com/your-username/careme.git
   cd careme
   ```

2. **Install Dependencies**  
   ```sh
   flutter pub get
   ```

3. **Run an Emulator or Connect a Device**  
   - Open **Android Studio** or **VS Code**  
   - Start an **Android Emulator** or connect a **real device** with USB debugging enabled  
   - Verify connected devices using:  
     ```sh
     flutter devices
     ```

4. **Run the App**  
   ```sh
   flutter run
   ```

5. **Check for Issues (Optional)**  
   ```sh
   flutter doctor
   ```

Now, the **CareMe** app should be running on your device or emulator! 🎉🚀  

---

## 🎯 Project Idea, Purpose, and Problem It Solves  

CareMe is a Flutter-based app designed to assist the elderly in managing their daily lives.  
It provides **health monitoring, medication reminders, and legal/financial support** in one platform.  
The app helps seniors **track their health, take medications on time, and access professional assistance** easily.  
It addresses the **challenges of missed medications, undiagnosed health issues, and difficulties in handling legal or financial matters**.  
CareMe aims to improve the **quality of life** for seniors by offering a simple and reliable digital solution.  

## 📌 Prerequisites  

Before running the CareMe app, make sure you have the following installed on your system:  

- **[Flutter](https://docs.flutter.dev/get-started/install)** – Flutter SDK for app development.  
- **Dart** – Included with Flutter, required for development.  
- **[Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)** – Preferred IDE for Flutter development.  
- **Emulator or Real Device** – To test the application.  

Ensure that Flutter and Dart are properly set up by running the following command in your terminal:  

```sh
flutter doctor
```

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

1. Create a Firebase project in the **[Firebase Console](https://console.firebase.google.com/)**.  
2. Add an Android/iOS app and download the required files:  
   - **Android:** `google-services.json`  
   - **iOS:** `GoogleService-Info.plist`  
3. Place the files in the respective platform directories:  
   - **Android:** `android/app/google-services.json`  
   - **iOS:** `ios/Runner/GoogleService-Info.plist`  
4. Enable **Firestore, Firebase Cloud Messaging, and Authentication**.  
5. Run the following command to ensure dependencies are configured correctly:  

   ```sh
   flutterfire configure
   ```

## 🔧 Running the App  

To run the app, use the following command:  

```sh
flutter run
```

For testing, use:  

```sh
flutter test
```

## 🌟 License  

This project is licensed under the **MIT License**.  
