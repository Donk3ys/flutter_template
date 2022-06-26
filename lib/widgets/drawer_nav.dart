import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/view_providers/_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _drawerMenuTilePadding =
    EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0);
// const _drawerMenuTileHeight = 40.0;
const _drawerWidth = 230.0;
const _drawerDivider = Divider(
  height: 26.0,
  thickness: 2,
  indent: 18,
  endIndent: 18,
  color: kColorBackgroundDark,
);
const _textStyleSubHeading = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);
const _navHeight = 120.0;

class NavDrawerButton extends ConsumerWidget {
  const NavDrawerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(themeVMProvider);

    return IconButton(
      splashRadius: 24.0,
      splashColor: Colors.white,
      icon: const Icon(Icons.menu_outlined),
      onPressed: () => Scaffold.of(context).openEndDrawer(),
    );
  }
}

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // final email =
    //     ref.watch(currentUserProvider.select((user) => user?.email ?? ""));

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        return SizedBox(
          height: maxHeight,
          width: _drawerWidth,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                  },
                  child: Container(
                    height: _navHeight,
                    width: double.infinity,
                    // color: kColorAccent,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final profileImageUrl = ref.watch(
                              currentUserProvider.select(
                                (user) => user?.profileImageUrl ?? "",
                              ),
                            );
                            return CircleAvatar(
                              foregroundImage: profileImageUrl.isNotEmpty
                                  ? NetworkImage(
                                      profileImageUrl,
                                    )
                                  : null,
                              radius: 30,
                              child: const Icon(Icons.face),
                            );
                          },
                        ),
                        const SizedBox(height: 8.0),
                        Consumer(
                          builder: (context, ref, _) {
                            final username = ref.watch(
                              currentUserProvider
                                  .select((user) => user?.username ?? ""),
                            );
                            return InkWell(
                              onTap: () {
                                ref
                                    .read(currentUserProvider.notifier)
                                    .updateUsername();
                              },
                              child: Text(
                                // ref.read(currentUserProvider).username,
                                username,
                                style: _textStyleSubHeading,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                _DrawerMenu(maxHeight: maxHeight),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrawerMenu extends ConsumerWidget {
  final double maxHeight;
  const _DrawerMenu({
    Key? key,
    required this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: maxHeight - _navHeight - 40.0,
      width: _drawerWidth + 50,
      // color: kColorBackgroundDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
//           if (_authViewModel.isLoggedIn)
//             InkWell(
//               onTap: () async {
//                 context
//                     .findRootAncestorStateOfType<DrawerControllerState>()
//                     ?.close();
//                 // widget.scaffoldKey.currentState.close(direction: InnerDrawerDirection.end);
//                 // context.vRouter.push("/user");
//                 context.vRouter.to("/user-profile", isReplacement: true);
//                 // Routes.to(context, const UserPage());
//               },
//               child: Container(
//                 width: double.infinity,
//                 height: kDrawerMenuTileHeight,
//                 color: context.vRouter.url == "/user"
//                     ? kColorBackgroundDark
//                     : null,
//                 padding: kDrawerMenuTilePadding,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       width: 160.0,
//                       child: Text(
//                         _authViewModel.currentUser.firstName,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const Icon(Icons.account_circle, color: kColorAccent),
//                   ],
//                 ),
//               ),
//             ),
          if (ref.read(currentUserProvider.notifier).isLoggedIn)
            InkWell(
              onTap: () async {
                context
                    .findRootAncestorStateOfType<DrawerControllerState>()
                    ?.close();
                ref.read(currentUserProvider.notifier).logout(context);
                // clearData();
              },
              child: Padding(
                padding: _drawerMenuTilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Logout"),
                    Icon(Icons.logout),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                InkWell(
                  onTap: () async {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                    context.go("/login");
                  },
                  child: Padding(
                    padding: _drawerMenuTilePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Login"),
                        Icon(Icons.login),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                    context.push("/signup");
                  },
                  child: Padding(
                    padding: _drawerMenuTilePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Sign Up"),
                        Icon(Icons.app_registration_outlined),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          _drawerDivider,
          InkWell(
            onTap: () async {
              ref.read(themeProvider.notifier).toggleMode();
            },
            child: Padding(
              padding: _drawerMenuTilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.read(themeProvider.notifier).isDarkMode
                        ? "Light Mode"
                        : "Dark Mode",
                  ),
                  Icon(
                    ref.read(themeProvider.notifier).isDarkMode
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                    // context.vRouter.to("/contact");
                  },
                  child: Padding(
                    padding: _drawerMenuTilePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Contact Us"),
                        Icon(Icons.phone),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                    // context.vRouter.to("/terms-conditions");
                  },
                  child: Padding(
                    padding: _drawerMenuTilePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Terms & Conditions"),
                        Icon(Icons.file_copy),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: _DevWaterMark(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DevWaterMark extends StatefulWidget {
  const _DevWaterMark({
    Key? key,
  }) : super(key: key);

  @override
  State<_DevWaterMark> createState() => _DevWaterMarkState();
}

class _DevWaterMarkState extends State<_DevWaterMark> {
  int _devDisplayCounter = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _devDisplayCounter++;
        if (_devDisplayCounter >= 7) {
          _devDisplayCounter = 0;
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              // title: const Text("Alert"),
              content: const SizedBox(
                width: 200,
                child: Text("A Donk3y Development!"),
              ),
              actions: [
                TextButton(
                  onPressed: () async => Navigator.of(context).pop(),
                  child: const Text("Ok"),
                ),
              ],
            ),
          );
        }
      },
      child: const Padding(
        padding: EdgeInsets.only(bottom: 8.0, left: 8.0),
        child: Text(
          kVersion,
          style: TextStyle(color: Colors.grey, fontSize: 8.0),
        ),
      ),
    );
  }
}
