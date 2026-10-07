import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../widgets/tv_button.dart';
import '../widgets/tv_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ClockSettings _settings = ClockSettings();
  bool _loaded = false;

  final List<Map<String, dynamic>> _colorOptions = const [
    {'name': 'Default', 'value': 'default', 'color': Colors.grey},
    {'name': 'White', 'value': '#FFFFFF', 'color': Colors.white},
    {'name': 'Red', 'value': '#FF5252', 'color': Colors.redAccent},
    {'name': 'Green', 'value': '#69F0AE', 'color': Colors.greenAccent},
    {'name': 'Blue', 'value': '#448AFF', 'color': Colors.blueAccent},
    {'name': 'Yellow', 'value': '#FFD740', 'color': Colors.amberAccent},
    {'name': 'Cyan', 'value': '#18FFFF', 'color': Colors.cyanAccent},
    {'name': 'Orange', 'value': '#FFAB40', 'color': Colors.orangeAccent},
    {'name': 'Purple', 'value': '#E040FB', 'color': Colors.purpleAccent},
    {'name': 'Pink', 'value': '#FF4081', 'color': Colors.pinkAccent},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _settings = await SettingsService.loadSettings();
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    await SettingsService.saveSettings(_settings);
  }

  void _update(VoidCallback callback) {
    setState(callback);
    _save();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPositionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Position',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _posBtn('Top Left', 'topLeft'),
            _posBtn('Top Right', 'topRight'),
            _posBtn('Bottom Left', 'bottomLeft'),
            _posBtn('Bottom Right', 'bottomRight'),
          ],
        ),
      ],
    );
  }

  Widget _posBtn(String label, String pos) {
    final selected = _settings.position == pos;
    return TvButton(
      label: label,
      isSelected: selected,
      onPressed: () => _update(() => _settings.position = pos),
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theme',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _themeBtn('White', 'white'),
            _themeBtn('Black', 'black'),
            _themeBtn('Minimal', 'minimal'),
          ],
        ),
      ],
    );
  }

  Widget _themeBtn(String label, String themeValue) {
    final selected = _settings.theme == themeValue;
    return TvButton(
      label: label,
      isSelected: selected,
      onPressed: () => _update(() => _settings.theme = themeValue),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Text Color',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _colorOptions.map((opt) {
            final selected = _settings.color == opt['value'];
            final color = opt['color'] as Color;
            return _colorBtn(
              opt['name'] as String,
              opt['value'] as String,
              color,
              selected,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _colorBtn(String name, String value, Color color, bool selected) {
    return Focus(
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: () => _update(() => _settings.color = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: focused
                      ? Colors.white
                      : selected
                      ? Colors.greenAccent
                      : Colors.transparent,
                  width: focused ? 4 : (selected ? 3 : 0),
                ),
                boxShadow: focused
                    ? [const BoxShadow(color: Colors.white70, blurRadius: 10)]
                    : null,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.black, size: 28)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final divisionsCount = (max - min).toInt();
    return Focus(
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: focused ? Colors.white : Colors.transparent,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
              color: focused
                  ? Colors.deepPurple.withOpacity(0.2)
                  : Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label: ${value.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisionsCount > 0 ? divisionsCount : null,
                  onChanged: (v) => _update(() => onChanged(v)),
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.white24,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(48),
          children: [
            _buildSectionTitle('Clock'),
            TvSwitch(
              label: '24-Hour Format',
              value: _settings.is24HourFormat,
              onChanged: (v) => _update(() => _settings.is24HourFormat = v),
            ),
            TvSwitch(
              label: 'Show Seconds',
              value: _settings.showSeconds,
              onChanged: (v) => _update(() => _settings.showSeconds = v),
            ),
            TvSwitch(
              label: 'Show Date',
              value: _settings.showDate,
              onChanged: (v) => _update(() => _settings.showDate = v),
            ),
            _buildSectionTitle('Appearance'),
            _buildThemeSelector(),
            const SizedBox(height: 24),
            _buildColorSelector(),
            const SizedBox(height: 24),
            _buildSlider(
              'Size',
              _settings.size,
              10,
              96,
              (v) => _settings.size = v,
            ),
            _buildSlider(
              'Opacity',
              _settings.opacity,
              0.1,
              1.0,
              (v) => _settings.opacity = v,
            ),
            _buildSectionTitle('Layout'),
            _buildPositionSelector(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
