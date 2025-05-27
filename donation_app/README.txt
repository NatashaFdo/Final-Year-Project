# Donation App

This is a mobile application developed using **Flutter** and **Firebase**, aimed at reducing waste and promoting sustainability in Sri Lanka by enabling users to donate reusable items and leftover food.

## Key Features

- Post donation items (clothes, books, food, etc.)
- Share location using Google Maps
- View and request available donations
- Create and edit user profiles
- Get notified when someone requests your item

## Technologies Used

- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging (Notifications)
- Google Maps API
- Node.js (for FCM backend server)

## ⚠️ Important Notes

- To enable push notifications:
  - **Update the Wi-Fi IP address** in `lib/screens/singleitem_screen.dart` to match your local server IP.
  - Make sure to **run the Node.js FCM server (`fcm_server`)** that handles the backend push notification logic.

## 🗂️ Project Structure (lib/ folder)

```
lib/
├── main.dart
├── models/
├── screens/
├── widgets/
├── services/
├── utils/
├── theme/
```

## 🧪 Testing

- Manual testing performed on Android Emulator and real devices.
- Features tested: Sign up/login, posting items, editing profile, and notifications.


## 👩‍💻 Developer

Final year project by : 
NATASHA FERNANDO - 10899517
BSc (Hons) Software Engineering   
University of Plymouth
