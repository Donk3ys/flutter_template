import 'package:dart_mappable/dart_mappable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/main.mapper.g.dart';

@MappableEnum()
enum UserStatus {
  @MappableValue(0)
  removed,
  @MappableValue(1)
  activated,
  @MappableValue(2)
  deactivated,
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class User extends Equatable {
  @MappableField(key: "user_uuid")
  final String uuid;
  final String email;
  final String password;
  final String username;
  final String profileImageUrl;
  // final String firebaseToken;
  final DateTime createdAt;
  final UserStatus status;

  const User({
    required this.uuid,
    this.password = "",
    required this.email,
    required this.username,
    required this.profileImageUrl,
    required this.createdAt,
    required this.status,
  });

  factory User.init() => User(
        uuid: "-1",
        email: "err",
        username: "err",
        profileImageUrl: "",
        createdAt: DateTime(1970),
        status: UserStatus.removed,
      );

  factory User.fromJson(JsonMap json) {
    final User u = Mapper.fromMap(json);
    return u;
  }

  // bool get isCurrentUser => uuid == authVm.currentUser.uuid;
  DateTime get createdAtLocal => createdAt.toLocal();

  JsonMap toJson() => toMap();

  @override
  String toString() => toMap().toString();

  @override
  List<Object?> get props => [uuid];
}

// // NOTE: User Info
// @MappableClass(caseStyle: CaseStyle.snakeCase)
// class UserInfo {
//   @MappableField(key: "user_uuid")
//   final String uuid;
//   final String username;
//   final String profileImageUrl;
//   final int position;
//
//   UserInfo({
//     required this.uuid,
//     required this.username,
//     required this.profileImageUrl,
//     // TODO: set to null
//     this.position = 100,
//   });
//
//   factory UserInfo.fromJson(JsonMap json) {
//     final UserInfo u = Mapper.fromMap(json);
//     return u;
//   }
//
//   @override
//   String toString() => toJson();
//
//   @override
//   int get hashCode => uuid.hashCode;
//
//   /// COMPARE ///
//   @override
//   bool operator ==(dynamic other) => (other is UserInfo) && other.uuid == uuid;
// }
