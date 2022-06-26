import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/widgets/drawer_nav.dart';

class AppBarWithBackButton extends StatelessWidget {
  final List<Widget>? actions;
  final Function()? onBackTap;
  final Widget? center;
  final bool showDrawerButton;

  const AppBarWithBackButton({
    Key? key,
    this.onBackTap,
    this.center,
    this.actions,
    this.showDrawerButton = true,
  }) : super(key: key);

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kColorBackgroundDark,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                splashRadius: 24.0,
                splashColor: kColorAccent,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  // color: kColorAccent,
                ),
                onPressed: () =>
                    onBackTap != null ? onBackTap!() : _goBack(context),
              ),
            ),
          ),
          // Expanded(
          //   flex: 3,
          //   child: Padding(
          //     padding: const EdgeInsets.all(5.0),
          //     child: Center(
          //       child: center != null
          //           ? center!
          //           : GestureDetector(
          //               onTap: () => context.vRouter.to("/"),
          //               child: Image.asset("assets/icons/sportee.png"),
          //             ),
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (actions != null) ...actions!,
                if (showDrawerButton) const NavDrawerButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
