import 'package:flutter/material.dart';

class SpinnerOverlay {
  static final SpinnerOverlay _instance = SpinnerOverlay._internal();
  factory SpinnerOverlay() => _instance;
  SpinnerOverlay._internal();

  OverlayEntry? _overlayEntry;

  void show(BuildContext context) {
    if (_overlayEntry != null) return; // Prevent showing multiple spinners

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(49, 0, 0, 0), // Semi-transparent background
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(30), // Padding around the spinner
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
