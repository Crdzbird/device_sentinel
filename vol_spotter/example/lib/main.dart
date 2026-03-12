import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vol_spotter/vol_spotter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final _volSpotter = const VolSpotter();

  StreamSubscription<ButtonEvent>? _subscription;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_startListening());
  }

  Future<void> _startListening() async {
    _subscription = _volSpotter.buttonEvents.listen(
      (event) {
        if (event.action is! ButtonPressed) return;
        setState(() {
          switch (event.button) {
            case VolumeUpButton():
              _counter++;
            case VolumeDownButton():
              _counter--;
            case PowerButton():
              _counter = 0;
          }
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stream error: $error')),
        );
      },
    );
    try {
      await _volSpotter.startListening(
        config: const VolSpotterConfig(interceptVolumeEvents: true),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start: $e')),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_volSpotter.stopListening());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Volume Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_counter',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Volume Up to increment\n'
              'Volume Down to decrement\n'
              'Power button to reset',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
