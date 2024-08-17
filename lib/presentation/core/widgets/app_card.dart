import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    required this.onTap,
  });
  final Widget child;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.w,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 249, 251, 255),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              offset: Offset(1, 1),
              blurRadius: 4,
              color: Color.fromARGB(255, 203, 218, 249),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
