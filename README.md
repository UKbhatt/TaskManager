# 🧠 Gig Task Manager  

<p align="">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Riverpod-40C4FF?style=for-the-badge&logo=riverpod&logoColor=white"/>
  <img src="https://img.shields.io/badge/Cloud%20Firestore-FFCA28?style=for-the-badge&logo=google-cloud&logoColor=white"/>
</p>


<p>
  
A modern Flutter-based task management app powered by **Firebase Authentication** and **Cloud Firestore**, with clean state management via **Riverpod**, and real-time UI updates.  
Each user can securely manage their personal tasks — add, edit, delete, and filter tasks by priority, completion, or date.
</p>


---

## 🚀 Features  

✅ **User Authentication**  
- Email/Password Sign Up & Login  
- Google Sign-In using Firebase  

✅ **Task Management**  
- Add, edit, and delete tasks  
- Set **priority** and **due date**  
- Auto-syncs with Firebase in real-time  
- User-specific task storage (each user sees only their own tasks)

✅ **Filters & Calendar View**  
- Filter tasks by **priority** or **status**  
- View all tasks in a **calendar view** using `table_calendar`  

✅ **UI & UX**  
- Gradient-themed responsive design  
- Material 3 widgets  
- Animations for smooth task updates  

✅ **State Management**  
- **Riverpod** for reactive UI  
- Streams for real-time updates  

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-------------|
| Frontend | Flutter (Material 3, Riverpod) |
| Backend | Firebase Firestore |
| Auth | Firebase Authentication |
| State Mgmt | Riverpod |
| Calendar | table_calendar |
| Animations | Flutter Animation APIs |

---

## 🧩 Project Architecture 
```
lib/
├── core/
│ ├── constants/
│ ├── utils/
│ └── widgets/
│
├── data/
│ ├── datasources/
│ │ └── firebase_service.dart
│ ├── models/
│ │ └── task_model.dart
│ └── repositories/
│ └── task_repository.dart
│
├── presentation/
│ ├── providers/
│ │ └── task_provider.dart
│ ├── screens/
│ │ ├── auth/
│ │ │ ├── login_screen.dart
│ │ │ └── register_screen.dart
│ │ ├── home/
│ │ │ ├── home_screen.dart
│ │ │ ├── add_edit_task_screen.dart
│ │ │ └── task_tile.dart
│ │ └── splash/
│ │ └── splash_screen.dart
│
└── main.dart
```
---

## ⚙️ Installation & Setup

### 1️⃣ Clone the Repository
```
git clone https://github.com/yourusername/gig_task_manager.git
cd gig_task_manager
```
### 2️⃣ Install Dependencies

```
flutter pub get
```
### 3️⃣ Set Up Firebase

- Create a new Firebase project in Firebase Console

- Enable Authentication (Email/Password + Google)

- Enable Cloud Firestore

- Download your google-services.json file and place it under:

```
android/app/google-services.json
```
- For iOS: add GoogleService-Info.plist under ios/Runner/
 
### 4️⃣ Configure Firebase in Flutter
Add these lines in android/app/build.gradle:

```
apply plugin: 'com.google.gms.google-services'
```

- In android/build.gradle:
```
classpath 'com.google.gms:google-services:4.4.0'
```

### 5️⃣ Run the App
```
flutter run
```
---
## 🧾 Firestore Data Structure
```
tasks (collection)
 ├── taskId (document)
 │    ├── title: "Buy Groceries"
 │    ├── description: "Milk, eggs, fruits"
 │    ├── dueDate: Timestamp
 │    ├── priority: "high"
 │    ├── isCompleted: false
 │    └── userId: "<FirebaseAuth_UID>"
```
---
## 🔐 Firebase Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📦 Dependencies
```
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.3.0
  firebase_auth: ^5.2.0
  cloud_firestore: ^5.2.0
  flutter_riverpod: ^2.5.1
  rxdart: ^0.27.7
  table_calendar: ^3.1.1
  intl: ^0.19.0
```

---

## 👨‍💻 Contributing
#### 💡 Want to improve this project? Feel free to contribute!<br>
1.Fork the repository<br>
2.Create a new branch (git checkout -b feature/your-feature)<br>
3.Make your changes and commit (git commit -am 'Added a new feature')<br>
4.Push the branch (git push origin feature/your-feature)<br>
5.Submit a Pull Request<br> 

---

## 🌍 Contact
**💻 Author: Utkarsh**<br>
**📧 Email: ubhatt2004@gmail.com**<br>
**🐙 GitHub: https://github.com/UKbhatt**<br>
