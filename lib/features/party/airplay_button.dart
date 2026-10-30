import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Native AVRoutePickerView (iOS): lets the host send audio to AirPlay 2
/// speakers (Sonos One/Beam/Era…) while the queue stays on the phone.
/// On other platforms output goes through the system (Bluetooth), so nothing
/// is rendered.
class AirPlayButton extends StatelessWidget {
  final double size;
  const AirPlayButton({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS || kIsWeb) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: size,
      height: size,
      child: const UiKitView(viewType: 'djfy/airplay'),
    );
  }
}
