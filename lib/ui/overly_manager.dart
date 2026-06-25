import 'package:flutter/material.dart';

class OverlayManager extends StatelessWidget {
  final Widget child;
  final Widget? overlayWidget;
  final VoidCallback onDismiss;

  const OverlayManager({
    super.key,
    required this.child,
    required this.onDismiss,
    this.overlayWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (overlayWidget != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // inner tap block করা
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 340,
                        constraints: const BoxConstraints(maxHeight: 500),
                        child: Stack(
                          children: [
                            overlayWidget!,
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: onDismiss,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}