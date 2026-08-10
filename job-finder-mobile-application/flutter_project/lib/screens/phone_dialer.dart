import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mirrors the React `SIMULATED PHONE DIALER` full-screen overlay.
class PhoneDialerOverlay extends StatefulWidget {
  const PhoneDialerOverlay({
    super.key,
    required this.name,
    required this.phone,
    this.onHangUp,
  });

  final String name;
  final String phone;
  final VoidCallback? onHangUp;

  @override
  State<PhoneDialerOverlay> createState() => _PhoneDialerOverlayState();
}

class _PhoneDialerOverlayState extends State<PhoneDialerOverlay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020617).withValues(alpha: 0.95),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(),
            // Avatar + status
            Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: context.appColors.slate800,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: context.appColors.slate700, width: 4),
                  ),
                  child: Icon(
                    Icons.call_rounded,
                    size: 40,
                    color: context.appColors.emerald400,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.appColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'CALLING...',
                  style: TextStyle(
                    color: context.appColors.emerald400,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '+977 ${widget.phone}',
                  style: TextStyle(
                    color: context.appColors.slate600,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            Spacer(),
            // Hang up
            Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'This triggers a native telephone call widget (tel:) on physical iOS and Android smartphones.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.appColors.slate700,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      if (widget.onHangUp != null) widget.onHangUp!();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: context.appColors.red500,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.call_end_rounded,
                        color: context.appColors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience helper to push the dialer overlay as a full-screen route.
Future<void> showPhoneDialer(
  BuildContext context, {
  required String name,
  required String phone,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PhoneDialerOverlay(name: name, phone: phone),
    ),
  );
}
