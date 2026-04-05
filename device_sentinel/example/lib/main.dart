import 'dart:async';

import 'package:device_sentinel/device_sentinel.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sentinel = const DeviceSentinel();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  StreamSubscription<DeviceEvent>? _eventSub;
  final List<_EventLogEntry> _eventLog = [];
  bool _monitoring = false;

  // SentinelConfig toggles — buttons
  bool _interceptVolumeUp = false;
  bool _interceptVolumeDown = false;
  bool _interceptPower = false;

  // SentinelConfig toggles — security categories
  bool _monitorShutdown = true;
  bool _monitorConnectivity = true;
  bool _monitorScreenLock = true;
  bool _monitorPowerUsb = true;
  bool _monitorSecurityPosture = true;

  int _tabIndex = 0;

  // ---------------------------------------------------------------------------
  // Start / Stop
  // ---------------------------------------------------------------------------

  Future<void> _toggle() async {
    if (_monitoring) {
      await _stop();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    _eventSub = _sentinel.events.listen(
      (event) {
        setState(() {
          _eventLog.insert(
            0,
            _EventLogEntry(time: TimeOfDay.now(), event: event),
          );
          if (_eventLog.length > 200) _eventLog.removeLast();
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        _showSnackBar('Stream error: $error');
      },
    );

    try {
      await _sentinel.start(
        config: SentinelConfig(
          interceptVolumeUp: _interceptVolumeUp,
          interceptVolumeDown: _interceptVolumeDown,
          interceptPower: _interceptPower,
          monitorShutdown: _monitorShutdown,
          monitorConnectivity: _monitorConnectivity,
          monitorScreenLock: _monitorScreenLock,
          monitorPowerUsb: _monitorPowerUsb,
          monitorSecurityPosture: _monitorSecurityPosture,
        ),
      );
      setState(() => _monitoring = true);
      // ignore: avoid_catching_errors, UnsupportedError is thrown by stubs.
    } on UnsupportedError {
      if (!mounted) return;
      _showSnackBar('Not supported on this platform.');
    } on Exception catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to start: $e');
    }
  }

  Future<void> _stop() async {
    await _eventSub?.cancel();
    _eventSub = null;
    try {
      await _sentinel.stop();
    } on Exception catch (_) {
      // ignore
    }
    setState(() => _monitoring = false);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    unawaited(_eventSub?.cancel());
    if (_monitoring) unawaited(_sentinel.stop());
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------------------------------------------------------------------------
  // Derived lists for each tab
  // ---------------------------------------------------------------------------

  List<_EventLogEntry> get _buttonEntries =>
      _eventLog.where((e) => e.event is ButtonEvent).toList();

  List<_EventLogEntry> get _securityEntries =>
      _eventLog.where((e) => e.event is DeviceSecurityEvent).toList();

  // ---------------------------------------------------------------------------
  // UI — Scaffold
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Sentinel'),
        actions: [
          _MonitoringChip(
            monitoring: _monitoring,
            onToggle: _toggle,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _ButtonTab(
            log: _buttonEntries,
            monitoring: _monitoring,
            interceptVolumeUp: _interceptVolumeUp,
            interceptVolumeDown: _interceptVolumeDown,
            interceptPower: _interceptPower,
            onInterceptVolumeUpChanged: _monitoring
                ? null
                : (v) => setState(() => _interceptVolumeUp = v),
            onInterceptVolumeDownChanged: _monitoring
                ? null
                : (v) => setState(() => _interceptVolumeDown = v),
            onInterceptPowerChanged: _monitoring
                ? null
                : (v) => setState(() => _interceptPower = v),
            onClear: () => setState(
              () => _eventLog.removeWhere((e) => e.event is ButtonEvent),
            ),
          ),
          _SecurityTab(
            log: _securityEntries,
            monitoring: _monitoring,
            monitorShutdown: _monitorShutdown,
            monitorConnectivity: _monitorConnectivity,
            monitorScreenLock: _monitorScreenLock,
            monitorPowerUsb: _monitorPowerUsb,
            monitorSecurityPosture: _monitorSecurityPosture,
            onShutdownChanged: _monitoring
                ? null
                : (v) => setState(() => _monitorShutdown = v),
            onConnectivityChanged: _monitoring
                ? null
                : (v) => setState(() => _monitorConnectivity = v),
            onScreenLockChanged: _monitoring
                ? null
                : (v) => setState(() => _monitorScreenLock = v),
            onPowerUsbChanged: _monitoring
                ? null
                : (v) => setState(() => _monitorPowerUsb = v),
            onSecurityPostureChanged: _monitoring
                ? null
                : (v) => setState(() => _monitorSecurityPosture = v),
            onClear: () => setState(
              () => _eventLog
                  .removeWhere((e) => e.event is DeviceSecurityEvent),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _buttonEntries.isNotEmpty,
              label: Text('${_buttonEntries.length}'),
              child: const Icon(Icons.touch_app),
            ),
            label: 'Buttons',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _securityEntries.isNotEmpty,
              label: Text('${_securityEntries.length}'),
              child: const Icon(Icons.security),
            ),
            label: 'Security',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Data model
// =============================================================================

class _EventLogEntry {
  const _EventLogEntry({required this.time, required this.event});
  final TimeOfDay time;
  final DeviceEvent event;
}

// =============================================================================
// Monitoring chip in AppBar
// =============================================================================

class _MonitoringChip extends StatelessWidget {
  const _MonitoringChip({
    required this.monitoring,
    required this.onToggle,
  });

  final bool monitoring;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        monitoring ? Icons.stop_circle : Icons.play_circle,
        size: 18,
        color: monitoring ? Colors.red : Colors.green,
      ),
      label: Text(monitoring ? 'Stop' : 'Start'),
      onPressed: onToggle,
    );
  }
}

// =============================================================================
// Button Tab
// =============================================================================

class _ButtonTab extends StatelessWidget {
  const _ButtonTab({
    required this.log,
    required this.monitoring,
    required this.interceptVolumeUp,
    required this.interceptVolumeDown,
    required this.interceptPower,
    required this.onInterceptVolumeUpChanged,
    required this.onInterceptVolumeDownChanged,
    required this.onInterceptPowerChanged,
    required this.onClear,
  });

  final List<_EventLogEntry> log;
  final bool monitoring;
  final bool interceptVolumeUp;
  final bool interceptVolumeDown;
  final bool interceptPower;
  final ValueChanged<bool>? onInterceptVolumeUpChanged;
  final ValueChanged<bool>? onInterceptVolumeDownChanged;
  final ValueChanged<bool>? onInterceptPowerChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Interception toggles
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  'Intercept (block default OS action)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  _ToggleChip(
                    label: 'Vol Up',
                    icon: Icons.volume_up,
                    enabled: interceptVolumeUp,
                    locked: monitoring,
                    color: const Color(0xFF1E88E5),
                    onChanged: onInterceptVolumeUpChanged,
                  ),
                  _ToggleChip(
                    label: 'Vol Down',
                    icon: Icons.volume_down,
                    enabled: interceptVolumeDown,
                    locked: monitoring,
                    color: const Color(0xFFFB8C00),
                    onChanged: onInterceptVolumeDownChanged,
                  ),
                  _ToggleChip(
                    label: 'Power',
                    icon: Icons.power_settings_new,
                    enabled: interceptPower,
                    locked: monitoring,
                    color: const Color(0xFFE53935),
                    onChanged: onInterceptPowerChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Event log header
        if (log.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Text(
                  '${log.length} event${log.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClear,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

        // Event list or empty state
        Expanded(
          child: log.isEmpty
              ? Center(
                  child: Text(
                    monitoring
                        ? 'Waiting for button events...\n\n'
                            'Press Volume Up, Volume Down, or Power.'
                        : 'Tap Start to begin.\n\n'
                            'Toggle intercept above to block\n'
                            'the default OS button action.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: log.length,
                  itemBuilder: (_, i) =>
                      _ButtonEventTile(entry: log[i]),
                ),
        ),
      ],
    );
  }
}

class _ButtonEventTile extends StatelessWidget {
  const _ButtonEventTile({required this.entry});

  final _EventLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = entry.event as ButtonEvent;
    final info = _buttonInfo(event);

    return Card(
      elevation: 0,
      color: info.color.withValues(alpha: 0.08),
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: info.color.withValues(alpha: 0.15),
          child: Icon(info.icon, color: info.color, size: 20),
        ),
        title: Text(
          info.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          info.action,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          entry.time.format(context),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Security Tab
// =============================================================================

class _SecurityTab extends StatelessWidget {
  const _SecurityTab({
    required this.log,
    required this.monitoring,
    required this.monitorShutdown,
    required this.monitorConnectivity,
    required this.monitorScreenLock,
    required this.monitorPowerUsb,
    required this.monitorSecurityPosture,
    required this.onShutdownChanged,
    required this.onConnectivityChanged,
    required this.onScreenLockChanged,
    required this.onPowerUsbChanged,
    required this.onSecurityPostureChanged,
    required this.onClear,
  });

  final List<_EventLogEntry> log;
  final bool monitoring;

  final bool monitorShutdown;
  final bool monitorConnectivity;
  final bool monitorScreenLock;
  final bool monitorPowerUsb;
  final bool monitorSecurityPosture;

  final ValueChanged<bool>? onShutdownChanged;
  final ValueChanged<bool>? onConnectivityChanged;
  final ValueChanged<bool>? onScreenLockChanged;
  final ValueChanged<bool>? onPowerUsbChanged;
  final ValueChanged<bool>? onSecurityPostureChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Category toggles
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  'Monitor categories',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                children: [
                  _ToggleChip(
                    label: 'Shutdown',
                    icon: Icons.power_settings_new,
                    enabled: monitorShutdown,
                    locked: monitoring,
                    color: _kShutdownColor,
                    onChanged: onShutdownChanged,
                  ),
                  _ToggleChip(
                    label: 'Connectivity',
                    icon: Icons.wifi,
                    enabled: monitorConnectivity,
                    locked: monitoring,
                    color: _kConnectivityColor,
                    onChanged: onConnectivityChanged,
                  ),
                  _ToggleChip(
                    label: 'Screen / Lock',
                    icon: Icons.screen_lock_portrait,
                    enabled: monitorScreenLock,
                    locked: monitoring,
                    color: _kScreenLockColor,
                    onChanged: onScreenLockChanged,
                  ),
                  _ToggleChip(
                    label: 'Power / USB',
                    icon: Icons.battery_charging_full,
                    enabled: monitorPowerUsb,
                    locked: monitoring,
                    color: _kPowerUsbColor,
                    onChanged: onPowerUsbChanged,
                  ),
                  _ToggleChip(
                    label: 'Security',
                    icon: Icons.shield,
                    enabled: monitorSecurityPosture,
                    locked: monitoring,
                    color: _kSecurityPostureColor,
                    onChanged: onSecurityPostureChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Event log header
        if (log.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Text(
                  '${log.length} event${log.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClear,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

        // Event list or empty state
        Expanded(
          child: log.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: log.length,
                  itemBuilder: (_, i) =>
                      _SecurityEventTile(entry: log[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              monitoring ? Icons.hearing : Icons.security,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              monitoring
                  ? 'Listening for events...'
                  : 'Tap Start to begin monitoring',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              monitoring
                  ? 'Try locking your screen, toggling airplane\n'
                      'mode, plugging in a charger, or starting\n'
                      'a screen recording.'
                  : 'Toggle the categories above to choose\n'
                      'which events to monitor.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Shared toggle chip
// =============================================================================

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.locked,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool locked;
  final Color color;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon, size: 16, color: enabled ? color : null),
      label: Text(label),
      selected: enabled,
      onSelected: locked ? null : onChanged,
      selectedColor: color.withValues(alpha: 0.15),
      checkmarkColor: color,
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

// =============================================================================
// Security event tile
// =============================================================================

class _SecurityEventTile extends StatelessWidget {
  const _SecurityEventTile({required this.entry});

  final _EventLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = entry.event as DeviceSecurityEvent;
    final info = _securityEventInfo(event);

    return Card(
      elevation: 0,
      color: info.categoryColor.withValues(alpha: 0.08),
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: info.categoryColor.withValues(alpha: 0.15),
          child: Icon(info.icon, color: info.categoryColor, size: 20),
        ),
        title: Text(
          info.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: info.subtitle != null
            ? Text(
                info.subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              entry.time.format(context),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: info.categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                info.category,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: info.categoryColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Category colours
// =============================================================================

const _kShutdownColor = Color(0xFFE53935);
const _kConnectivityColor = Color(0xFF1E88E5);
const _kScreenLockColor = Color(0xFF8E24AA);
const _kPowerUsbColor = Color(0xFFFB8C00);
const _kSecurityPostureColor = Color(0xFF43A047);

// =============================================================================
// Button event → UI info
// =============================================================================

class _ButtonInfo {
  const _ButtonInfo({
    required this.icon,
    required this.color,
    required this.label,
    required this.action,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String action;
}

_ButtonInfo _buttonInfo(ButtonEvent event) {
  final action = switch (event.action) {
    ButtonPressed() => 'Pressed',
    ButtonReleased() => 'Released',
  };

  return switch (event.button) {
    VolumeUpButton() => _ButtonInfo(
        icon: Icons.volume_up,
        color: const Color(0xFF1E88E5),
        label: 'Volume Up',
        action: action,
      ),
    VolumeDownButton() => _ButtonInfo(
        icon: Icons.volume_down,
        color: const Color(0xFFFB8C00),
        label: 'Volume Down',
        action: action,
      ),
    PowerButton() => _ButtonInfo(
        icon: Icons.power_settings_new,
        color: const Color(0xFFE53935),
        label: 'Power Button',
        action: action,
      ),
  };
}

// =============================================================================
// Security event → UI info
// =============================================================================

class _SecurityEventInfo {
  const _SecurityEventInfo({
    required this.icon,
    required this.title,
    required this.category,
    required this.categoryColor,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String category;
  final Color categoryColor;
}

_SecurityEventInfo _securityEventInfo(DeviceSecurityEvent event) {
  return switch (event) {
    ShutdownDetected() => const _SecurityEventInfo(
        icon: Icons.power_off,
        title: 'Shutdown Detected',
        subtitle: 'Device is shutting down',
        category: 'SHUTDOWN',
        categoryColor: _kShutdownColor,
      ),
    RebootDetected() => const _SecurityEventInfo(
        icon: Icons.restart_alt,
        title: 'Reboot Detected',
        subtitle: 'Device is rebooting',
        category: 'SHUTDOWN',
        categoryColor: _kShutdownColor,
      ),
    UncleanShutdownDetected(:final lastSeenTimestamp) =>
      _SecurityEventInfo(
        icon: Icons.warning_amber,
        title: 'Unclean Shutdown',
        subtitle: 'Crash or force-kill detected\n'
            'Last heartbeat: $lastSeenTimestamp',
        category: 'SHUTDOWN',
        categoryColor: _kShutdownColor,
      ),
    AirplaneModeOn() => const _SecurityEventInfo(
        icon: Icons.airplanemode_active,
        title: 'Airplane Mode ON',
        subtitle: 'All radios disabled',
        category: 'CONNECTIVITY',
        categoryColor: _kConnectivityColor,
      ),
    AirplaneModeOff() => const _SecurityEventInfo(
        icon: Icons.airplanemode_inactive,
        title: 'Airplane Mode OFF',
        subtitle: 'Radios re-enabled',
        category: 'CONNECTIVITY',
        categoryColor: _kConnectivityColor,
      ),
    NetworkConnected() => const _SecurityEventInfo(
        icon: Icons.signal_wifi_4_bar,
        title: 'Network Connected',
        subtitle: 'Internet connection established',
        category: 'CONNECTIVITY',
        categoryColor: _kConnectivityColor,
      ),
    NetworkDisconnected() => const _SecurityEventInfo(
        icon: Icons.signal_wifi_off,
        title: 'Network Disconnected',
        subtitle: 'Internet connection lost',
        category: 'CONNECTIVITY',
        categoryColor: _kConnectivityColor,
      ),
    NetworkCapsChanged(:final hasWifi, :final hasMobile) =>
      _SecurityEventInfo(
        icon: Icons.swap_vert,
        title: 'Network Caps Changed',
        subtitle:
            'WiFi: ${hasWifi ? "available" : "off"}, '
            'Mobile: ${hasMobile ? "available" : "off"}',
        category: 'CONNECTIVITY',
        categoryColor: _kConnectivityColor,
      ),
    VpnEstablished() => const _SecurityEventInfo(
        icon: Icons.vpn_lock,
        title: 'VPN Established',
        subtitle: 'VPN tunnel connected',
        category: 'CONNECTIVITY',
        categoryColor: _kConnectivityColor,
      ),
    VpnDisconnected() => const _SecurityEventInfo(
        icon: Icons.vpn_key_off,
        title: 'VPN Disconnected',
        subtitle: 'VPN tunnel dropped',
        category: 'CONNECTIVITY',
        categoryColor: _kConnectivityColor,
      ),
    ScreenOff() => const _SecurityEventInfo(
        icon: Icons.mobile_off,
        title: 'Screen Off',
        subtitle: 'Display turned off',
        category: 'SCREEN',
        categoryColor: _kScreenLockColor,
      ),
    ScreenOn() => const _SecurityEventInfo(
        icon: Icons.mobile_friendly,
        title: 'Screen On',
        subtitle: 'Display turned on',
        category: 'SCREEN',
        categoryColor: _kScreenLockColor,
      ),
    DeviceLocked() => const _SecurityEventInfo(
        icon: Icons.lock,
        title: 'Device Locked',
        subtitle: 'Lock screen activated',
        category: 'SCREEN',
        categoryColor: _kScreenLockColor,
      ),
    DeviceUnlocked() => const _SecurityEventInfo(
        icon: Icons.lock_open,
        title: 'Device Unlocked',
        subtitle: 'Lock screen dismissed',
        category: 'SCREEN',
        categoryColor: _kScreenLockColor,
      ),
    UserPresent() => const _SecurityEventInfo(
        icon: Icons.person,
        title: 'User Present',
        subtitle: 'User completed unlock (Android)',
        category: 'SCREEN',
        categoryColor: _kScreenLockColor,
      ),
    PowerConnected() => const _SecurityEventInfo(
        icon: Icons.power,
        title: 'Charger Connected',
        subtitle: 'Power source plugged in',
        category: 'POWER',
        categoryColor: _kPowerUsbColor,
      ),
    PowerDisconnected() => const _SecurityEventInfo(
        icon: Icons.power_off,
        title: 'Charger Disconnected',
        subtitle: 'Power source removed',
        category: 'POWER',
        categoryColor: _kPowerUsbColor,
      ),
    BatteryLow(:final level) => _SecurityEventInfo(
        icon: Icons.battery_2_bar,
        title: 'Battery Low',
        subtitle: 'Battery at $level% (≤ 20%)',
        category: 'POWER',
        categoryColor: _kPowerUsbColor,
      ),
    BatteryCritical(:final level) => _SecurityEventInfo(
        icon: Icons.battery_alert,
        title: 'Battery Critical',
        subtitle: 'Battery at $level% (≤ 5%)',
        category: 'POWER',
        categoryColor: _kPowerUsbColor,
      ),
    UsbDebuggingEnabled() => const _SecurityEventInfo(
        icon: Icons.usb,
        title: 'USB Debugging Enabled',
        subtitle: 'ADB access is now active (Android)',
        category: 'POWER',
        categoryColor: _kPowerUsbColor,
      ),
    UsbDebuggingDisabled() => const _SecurityEventInfo(
        icon: Icons.usb_off,
        title: 'USB Debugging Disabled',
        subtitle: 'ADB access revoked (Android)',
        category: 'POWER',
        categoryColor: _kPowerUsbColor,
      ),
    ScreenCaptureStarted() => const _SecurityEventInfo(
        icon: Icons.screenshot_monitor,
        title: 'Screen Capture Started',
        subtitle: 'Screen recording detected',
        category: 'SECURITY',
        categoryColor: _kSecurityPostureColor,
      ),
    ScreenCaptureStopped() => const _SecurityEventInfo(
        icon: Icons.stop_screen_share,
        title: 'Screen Capture Stopped',
        subtitle: 'Screen recording ended',
        category: 'SECURITY',
        categoryColor: _kSecurityPostureColor,
      ),
    DevModeEnabled() => const _SecurityEventInfo(
        icon: Icons.developer_mode,
        title: 'Dev Mode Enabled',
        subtitle: 'Developer options on (Android)',
        category: 'SECURITY',
        categoryColor: _kSecurityPostureColor,
      ),
    DevModeDisabled() => const _SecurityEventInfo(
        icon: Icons.developer_board_off,
        title: 'Dev Mode Disabled',
        subtitle: 'Developer options off (Android)',
        category: 'SECURITY',
        categoryColor: _kSecurityPostureColor,
      ),
  };
}
