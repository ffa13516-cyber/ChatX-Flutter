# ChatX Flutter 🚀

Modern messenger app built with Flutter + Firebase.

## Features
- 💬 1-on-1 Chats (real-time)
- 👥 Groups (all members can send)
- 📢 Channels (admin only broadcasts)
- 💾 Saved Messages (at top of chat list)
- 👤 Profile with username
- ⚙️ Settings with logout
- 🎨 Modern dark UI with cyan gradient

## Setup

### 1. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Open your existing project **messengerapp-d6e7c**
3. Add a NEW Android app with package name: `com.chatx.app`
4. Download `google-services.json`

### 2. GitHub Setup
1. Create new repo: `ChatX-Flutter`
2. Upload all files
3. Go to **Settings → Secrets → Actions**
4. Add secret: `GOOGLE_SERVICES_JSON` → paste content of google-services.json

### 3. Build
1. Go to **Actions** tab
2. Run **Build ChatX Flutter APK**
3. Download APK from Artifacts

## Project Structure
```
lib/
├── main.dart
├── models/models.dart
├── repositories/firebase_repo.dart
├── utils/
│   ├── app_colors.dart
│   ├── session_manager.dart
│   └── extensions.dart
├── widgets/widgets.dart
└── screens/
    ├── auth/login_screen.dart
    ├── home/home_screen.dart
    ├── chat/
    │   ├── chats_tab.dart
    │   ├── chat_screen.dart
    │   ├── saved_messages_screen.dart
    │   └── new_chat_sheet.dart
    ├── group/groups_tab.dart
    ├── channel/channels_tab.dart
    ├── profile/profile_screen.dart
    └── settings/settings_screen.dart
```
