import 'package:flutter/material.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';

import '../../app/theme.dart';

/// Settings. Today only the anonymous statistics switch, so the screen is
/// reachable only in builds that can send them ([Telemetry.isConfigured]).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NASTAVENÍ')),
      body: ListView(
        children: [
          if (Telemetry.isConfigured)
            SwitchListTile(
              key: const Key('telemetry-switch'),
              activeThumbColor: kNeonCyan,
              title: const Text('Anonymní statistiky používání'),
              subtitle: const Text(
                'Pomáhají zjistit, které funkce se používají a kde appka '
                'zlobí. Bez skladeb, hledaných výrazů, jmen a identifikátorů. '
                'Vypnutím se smažou i dosud neodeslané záznamy. '
                'Podrobnosti: lioilsources.github.io/DJfy/privacy.html',
              ),
              value: Telemetry.isEnabled,
              onChanged: (on) async {
                await Telemetry.setEnabled(on);
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
    );
  }
}
