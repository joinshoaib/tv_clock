import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/settings_model.dart';
import '../services/overlay_service.dart';
import '../services/settings_service.dart';
import '../widgets/tv_button.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _hasPermission = false;
  bool _isOverlayRunning = false;
  ClockSettings _settings = ClockSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _init() async {
    _settings = await SettingsService.loadSettings();
    await _checkPermission();
    if (mounted) setState(() {});
  }

  Future<void> _checkPermission() async {
    final granted = await OverlayService.checkPermission();
    setState(() => _hasPermission = granted);
  }

  Future<void> _toggleOverlay() async {
    if (_isOverlayRunning) {
      await OverlayService.stopOverlay();
      setState(() => _isOverlayRunning = false);
    } else {
      if (!_hasPermission) {
        _showPermissionDialog();
        return;
      }
      _settings = await SettingsService.loadSettings();
      await OverlayService.startOverlay(_settings.toMap());
      setState(() => _isOverlayRunning = true);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Permission Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This app needs permission to draw over other apps. Please enable it in settings.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
        actions: [
          TvButton(
            label: 'Open Settings',
            onPressed: () {
              Navigator.of(ctx).pop();
              OverlayService.requestPermission();
            },
          ),
          const SizedBox(height: 12),
          TvButton(label: 'Cancel', onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
  }

  void _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    _settings = await SettingsService.loadSettings();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.goBack ||
                  event.logicalKey == LogicalKeyboardKey.escape) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          },
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'TV Clock Overlay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Status: ${_hasPermission ? "Permission granted" : "Permission required"}',
                  style: TextStyle(
                    color: _hasPermission ? Colors.greenAccent : Colors.orange,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 60),
                TvButton(
                  label: _isOverlayRunning ? 'Stop Overlay' : 'Start Overlay',
                  icon: _isOverlayRunning ? Icons.stop : Icons.play_arrow,
                  autofocus: true,
                  onPressed: _toggleOverlay,
                ),
                const SizedBox(height: 24),
                TvButton(
                  label: 'Settings',
                  icon: Icons.settings,
                  onPressed: _openSettings,
                ),
                const Spacer(),
                const Text(
                  'Use D-pad to navigate',
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
