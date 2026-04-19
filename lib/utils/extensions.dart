import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

extension UserModelExt on UserModel {
  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? username,
    String? avatarUrl,
    bool? isOnline,
    int? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
