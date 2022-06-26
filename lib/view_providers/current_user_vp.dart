// import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/data_models/user.dart';
import 'package:flutter_frontend/main.mapper.g.dart';
import 'package:flutter_frontend/repositories/auth_repo.dart';
import 'package:flutter_frontend/service_locator.dart';
import 'package:flutter_frontend/view_providers/utils_vp.dart';
import 'package:flutter_frontend/widgets/snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loggy/loggy.dart';

// enum CurrentUserStatus { loggedIn, loggedOut }

// class CurrentUserState extends Equatable {
//   final User user;
//   final CurrentUserStatus status;
//
//   const CurrentUserState({required this.user, required this.status});
//
//   factory CurrentUserState.init() =>
//       CurrentUserState(user: User.init(), status: CurrentUserStatus.loggedOut);
//
// 	CurrentUserState copyWith({
//         User? user,
//         CurrentUserStatus? status,
//     }) =>
//         CurrentUserState(
//             user: user ?? this.user,
//             status: status ?? this.status,
//         );
//
//
//   @override
//   List<Object?> get props => [user, status];
// }

// Providers
late final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, User?>((ref) => sl());

class CurrentUserNotifier extends StateNotifier<User?> {
  final AuthRepository _authRepo;
  CurrentUserNotifier({required AuthRepository authRepo})
      : _authRepo = authRepo,
        super(null);

  bool get isLoggedIn => state != null;

  void updateUsername() {
    state = state?.copyWith(username: "New");
  }

  Future<void> signUpUser(
    BuildContext context,
    User newUser,
  ) async {
    // clearData();

    // TODO: put fb back for notifications
    // final token = await FirebaseMessaging.instance.getToken() ?? "";
    // const token = "";

    state = await NotifierUtil.makeCall(
      context: context,
      call: () async => _authRepo.signup(newUser),
    );

    if (state == null) return;

    // ignore: use_build_context_synchronously
    InfoSnackBar.showSuccess(context, "Sign Up Success");
    // ignore: use_build_context_synchronously
    context.go("/");
  }

  Future<void> loginUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    // _setLoadingState();
    // clearData();

    // TODO: put fb back for notifications
    // final token = await FirebaseMessaging.instance.getToken() ?? "";
    // const token = "";

    final newUser = User.init().copyWith(email: email, password: password);
    state = await NotifierUtil.makeCall(
      context: context,
      call: () async => _authRepo.login(newUser),
    );

    if (state == null) return;

    // ignore: use_build_context_synchronously
    InfoSnackBar.showSuccess(context, "Login Success");
    // ignore: use_build_context_synchronously
    context.go("/");
  }

  Future<void> getCurrentUser() async {
    try {
      state = await _authRepo.getCurrentUserLocal();
    } catch (e) {
      logDebug(e);
    }
  }

  Future<void> deleteCurrentUser(BuildContext context, String password) async {
    if (state != null) {
      final usr = state!.copyWith(password: password);
      final success = await NotifierUtil.makeCall(
        context: context,
        call: () async => _authRepo.deleteCurrentUser(usr),
      );
      if (success != null) {
        // ignore: use_build_context_synchronously
        InfoSnackBar.showSuccess(context, "Account Deleted Successfully");
      }
      // ignore: use_build_context_synchronously
      logout(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    await NotifierUtil.makeCall(
      context: context,
      call: () async => _authRepo.logout(state!.email),
    );
    state = null;
    // clearData();

    // ignore: use_build_context_synchronously
    context.go("/login");
    // notifyListeners();
  }

  Future<void> updatePassword(
    BuildContext context,
    String password,
    String newPassword,
  ) async {
    if (state != null) {
      final usr = state!.copyWith(password: password);
      final user = await NotifierUtil.makeCall(
        context: context,
        call: () async => _authRepo.updatePassword(usr, newPassword),
      );
      if (user != null) {
        // ignore: use_build_context_synchronously
        InfoSnackBar.showSuccess(context, kMessagePasswordUpdateSuccess);
      }
    }
  }

  Future<bool> passwordResetRequest(BuildContext context, String email) async {
    final success = await NotifierUtil.makeCall(
      context: context,
      call: () async => _authRepo.passwordResetRequest(email),
    );
    if (success == null) return false;

    state = User.init().copyWith(email: email);
    // ignore: use_build_context_synchronously
    InfoSnackBar.showSuccess(context, kMessagePasswordResetUpdateSuccess);
    return true;
  }

  Future<void> passwordReset(
    BuildContext context,
    String password,
    String passwordResetCode,
  ) async {
    if (passwordResetCode.length < 6) {
      InfoSnackBar.showError(
        context,
        "Unexpected error for password reset, please try send another email",
      );
      return;
    }

    final success = await NotifierUtil.makeCall(
      context: context,
      call: () async => _authRepo.passwordReset(password, passwordResetCode),
    );
    if (success == null) return;
    // ignore: use_build_context_synchronously
    InfoSnackBar.showSuccess(context, "Password reset success");

    if (state == null) {
      // ignore: use_build_context_synchronously
      context.go("/");
      return;
    }

    // Login user
    // ignore: use_build_context_synchronously
    await loginUser(context, state!.email, password);
  }
}

// class AuthController extends StateNotifier<CurrentUserState> {
//   final AuthRepository _authRepo;
//
//   // UserInfo get userInfoFromCurrentUser => UserInfo(
//   //       uuid: _authRepo.currentUser.uuid,
//   //       username: _authRepo.currentUser.username,
//   //       profileImageUrl: _authRepo.currentUser.profileImageUrl,
//   //       // position: 100,
//   //     );
//
//   //bool isCurrentUser(User usr) => usr.uuid == _authRepo.currentUser.uuid;
//
//   // NOTE: Update User Credentials
//   Future<void> updateEmail(
//     BuildContext context,
//     String newEmail,
//     String password,
//   ) async {
//     _setState(_State.busy);
//     final cu = _authRepo.currentUser;
//     if (cu == null) return;
//     final updatedUser = cu.copyWith(
//       email: newEmail,
//       password: password,
//     );
//
//     final success = await PgCtlUtil.makeCall<Success>(
//       context: context,
//       call: () async => _authRepo.updateEmail(updatedUser),
//       onComplete: () => _setState(),
//     );
//     if (success == null) return;
//     _authRepo.currentUser = cu.copyWith(email: newEmail);
//
//     // ignore: use_build_context_synchronously
//     InfoSnackBar.showSuccess(context, kMessageEmailUpdateSuccess);
//   }
//
  // Future<void> updateUsername({
  //   required BuildContext context,
  //   required String username,
  //   required String password,
  // }) async {
  //   setLoadingState();
  //   _setState(_State.busy);
  //   final cu = _authRepo.currentUser;
  //   if (cu == null) return;
  //   final updatedUser = cu.copyWith(
  //     username: username,
  //     password: password,
  //   );
  //
  //   final success = await PgCtlUtil.makeCall<Success>(
  //     context: context,
  //     call: () async => _authRepo.updateUsername(updatedUser),
  //     onComplete: () => _setState(),
  //   );
  //   if (success == null) return;
  //   _authRepo.currentUser = cu.copyWith(
  //     username: username,
  //   );
  //
  //   // ignore: use_build_context_synchronously
  //   InfoSnackBar.showSuccess(context, kMessageUsernameUpdateSuccess);
  // }
//
//   // Future<bool> updateProfileImage(
//   //   BuildContext _context,
//   //   Uint8List imageBytes,
//   //   String imageExtension,
//   // ) async {
//   //   _setState(_State.updatingProfile);
//   //   bool success = false;
//   //
//   //   final failureOrUrl = await authRepository.updateProfileImage(
//   //     imageBytes,
//   //     imageExtension,
//   //     _authRepo.currentUser,
//   //   );
//   //   failureOrUrl.fold((failure) {
//   //     ViewModelUtil.handleFailure(
//   //       context: _context,
//   //       failure: failure,
//   //     );
//   //   }, (profileImageUrl) {
//   //     _authRepo.currentUser = _authRepo.currentUser.copyWith(profileImageUrl: profileImageUrl);
//   //     success = true;
//   //     InfoSnackBar.showSuccess(_context, "Update profile image success");
//   //     // loggy.warning("remove $item $_inputList");
//   //   });
//   //   _setState(_State.idle);
//   //   return success;
//   // }
//
//   // Future<User?> fetchUserByUuid(String uuid) async {
//   //   User? user;
//   //
//   //   _setState(_State.busy);
//   //
//   //   if (uuid == _authRepo.currentUser.uuid) {
//   //     _setState(_State.idle);
//   //     return _authRepo.currentUser;
//   //   }
//   //
//   //   final failureOrUser = await authRepository.fetchUserByUuid(uuid);
//   //   failureOrUser.fold(
//   //     (failure) {
//   //       ViewModelUtil.handleFailure(
//   //         context: context,
//   //         failure: failure,
//   //       );
//   //     },
//   //     (usr) => user = usr,
//   //   );
//   //
//   //   _setState(_State.idle);
//   //   return user;
//   // }
//   //
//   // Future<List<JsonMap>> searchUser(String username) async {
//   //   if (username.length <= 1) return [];
//   //
//   //   // _setState(_State.busy);
//   //   List<FollowedUser> suggestedUserList = [];
//   //
//   //   final failureOrUsernames = await authRepository.searchUser(username);
//   //   failureOrUsernames.fold((failure) {
//   //     ViewModelUtil.handleFailure(
//   //       context: context,
//   //       failure: failure,
//   //     );
//   //   }, (usernames) {
//   //     suggestedUserList = usernames;
//   //   });
//   //   final dataMap = suggestedUserList
//   //       .map(
//   //         (user) => {
//   //           'id': user.userUuid,
//   //           'display': user.username,
//   //           'fullName': user.fullName,
//   //           'profileImageUrl': user.profileImageUrl,
//   //         },
//   //       )
//   //       .toList();
//   //
//   //   _setState(_State.idle);
//   //   return dataMap;
//   // }
//
//   Future<User?> fetchUserByUuid({
//     required BuildContext context,
//     required String uuid,
//   }) async {
//     // await Future.delayed(const Duration(seconds: 1));
//
//     return PgCtlUtil.makeCall<User>(
//       context: context,
//       call: () => _authRepo.fetchUserByUuid(uuid),
//     );
//   }
// }
