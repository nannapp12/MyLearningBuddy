import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'puppy.dart';
import 'rainbow_title.dart';

/// The puppy and "My Learning Buddy" at the top of the screen. Tapping it goes
/// to the main menu (where the puppy says "This is fun!"); on the main menu
/// itself it calls [onTapOnHome].
class AppTitle extends StatelessWidget {
  const AppTitle({super.key, this.onTapOnHome});

  final VoidCallback? onTapOnHome;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'My Learning Buddy',
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppStateScope.of(context).pop();
        final navigator = Navigator.of(context);
        if (ModalRoute.of(context)?.isFirst ?? true) {
          onTapOnHome?.call();
        } else {
          navigator.popUntil((route) => route.isFirst);
        }
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Puppy(size: 56),
          SizedBox(width: 4),
          Flexible(child: RainbowTitle('My Learning Buddy')),
        ],
      ),
    ),
  );
}
