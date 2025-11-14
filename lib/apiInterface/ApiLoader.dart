// lib/api/loader.dart
import 'package:flutter/material.dart';

class ApiLoader {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return; // Prevent multiple overlays
    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
