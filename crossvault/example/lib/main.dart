import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:crossvault/crossvault.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Example: Initialize with global configuration (optional)
  // Uncomment to test with access groups (requires entitlements setup)
  /*
  if (Platform.isIOS || Platform.isMacOS) {
    await Crossvault.init(
      options: IOSOptions(
        accessGroup: 'io.alexmelnyk.crossvault.shared',
        synchronizable: true,
        accessibility: IOSAccessibility.afterFirstUnlock,
      ),
    );
  }
  */
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crossvault Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CrossvaultDemo(),
    );
  }
}

class CrossvaultDemo extends StatefulWidget {
  const CrossvaultDemo({super.key});

  @override
  State<CrossvaultDemo> createState() => _CrossvaultDemoState();
}

class _CrossvaultDemoState extends State<CrossvaultDemo> {
  final _crossvault = Crossvault();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  
  String _platformVersion = 'Unknown';
  String _result = '';
  bool _isLoading = false;
  StorageMode _storageMode = StorageMode.privateMode;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _initPlatformState() async {
    try {
      final version = await _crossvault.getPlatformVersion() ?? 'Unknown';
      setState(() => _platformVersion = version);
    } catch (e) {
      setState(() => _platformVersion = 'Error: $e');
    }
  }

  Future<void> _executeOperation(Future<void> Function() operation) async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      await operation();
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  CrossvaultOptions? _getOptions() {
    if (_storageMode == StorageMode.privateMode) {
      return null; // Use default (private)
    }
    
    // Shared mode with access group
    if (Platform.isIOS) {
      return IOSOptions(
        accessGroup: 'io.alexmelnyk.crossvault.shared',
        synchronizable: true,
        accessibility: IOSAccessibility.afterFirstUnlock,
      );
    } else if (Platform.isMacOS) {
      return MacOSOptions(
        accessGroup: 'io.alexmelnyk.crossvault.shared',
        synchronizable: true,
        accessibility: MacOSAccessibility.afterFirstUnlock,
      );
    }
    
    return null;
  }

  Future<void> _setValue() async {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();
    
    if (key.isEmpty || value.isEmpty) {
      setState(() => _result = 'Error: Key and value are required');
      return;
    }

    await _executeOperation(() async {
      await _crossvault.setValue(key, value, options: _getOptions());
      setState(() => _result = 'Success: Value saved for key "$key"');
    });
  }

  Future<void> _getValue() async {
    final key = _keyController.text.trim();
    
    if (key.isEmpty) {
      setState(() => _result = 'Error: Key is required');
      return;
    }

    await _executeOperation(() async {
      final value = await _crossvault.getValue(key, options: _getOptions());
      setState(() {
        if (value != null) {
          _result = 'Value: $value';
          _valueController.text = value;
        } else {
          _result = 'Key "$key" not found';
        }
      });
    });
  }

  Future<void> _existsKey() async {
    final key = _keyController.text.trim();
    
    if (key.isEmpty) {
      setState(() => _result = 'Error: Key is required');
      return;
    }

    await _executeOperation(() async {
      final exists = await _crossvault.existsKey(key, options: _getOptions());
      setState(() => _result = 'Key "$key" ${exists ? "exists" : "does not exist"}');
    });
  }

  Future<void> _deleteValue() async {
    final key = _keyController.text.trim();
    
    if (key.isEmpty) {
      setState(() => _result = 'Error: Key is required');
      return;
    }

    await _executeOperation(() async {
      await _crossvault.deleteValue(key, options: _getOptions());
      setState(() => _result = 'Success: Key "$key" deleted');
      _valueController.clear();
    });
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete All'),
        content: const Text('Are you sure you want to delete all stored values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _executeOperation(() async {
      await _crossvault.deleteAll(options: _getOptions());
      setState(() => _result = 'Success: All values deleted');
      _keyController.clear();
      _valueController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add top padding for macOS traffic light buttons
    final topPadding = Platform.isMacOS ? 40.0 : 0.0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crossvault Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16 + topPadding, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Platform Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Running on: $_platformVersion'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Storage Mode Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Storage Mode',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<StorageMode>(
                      segments: const [
                        ButtonSegment(
                          value: StorageMode.privateMode,
                          label: Text('Private'),
                          icon: Icon(Icons.lock),
                        ),
                        ButtonSegment(
                          value: StorageMode.sharedMode,
                          label: Text('Shared'),
                          icon: Icon(Icons.share),
                        ),
                      ],
                      selected: {_storageMode},
                      onSelectionChanged: (Set<StorageMode> newSelection) {
                        setState(() => _storageMode = newSelection.first);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _storageMode == StorageMode.privateMode
                          ? '🔒 Private: Data stored only for this app'
                          : '🌐 Shared: Data can be shared between apps (requires entitlements)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Input Fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Key-Value Storage',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _keyController,
                      decoration: const InputDecoration(
                        labelText: 'Key',
                        hintText: 'e.g., api_token',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: 'Value',
                        hintText: 'e.g., secret_value_123',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.text_fields),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Operations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _setValue,
                          icon: const Icon(Icons.save),
                          label: const Text('Set Value'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _getValue,
                          icon: const Icon(Icons.download),
                          label: const Text('Get Value'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _existsKey,
                          icon: const Icon(Icons.search),
                          label: const Text('Check Exists'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _deleteValue,
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete Key'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _deleteAll,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Delete All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Result Display
            if (_result.isNotEmpty || _isLoading)
              Card(
                color: _result.startsWith('Error')
                    ? Colors.red[50]
                    : _result.startsWith('Success')
                        ? Colors.green[50]
                        : Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _result.startsWith('Error')
                                ? Icons.error_outline
                                : _result.startsWith('Success')
                                    ? Icons.check_circle_outline
                                    : Icons.info_outline,
                            color: _result.startsWith('Error')
                                ? Colors.red
                                : _result.startsWith('Success')
                                    ? Colors.green
                                    : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Result',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Text(_result),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Quick Examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Examples',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildQuickExample('user_token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'),
                    _buildQuickExample('api_key', 'sk_test_1234567890'),
                    _buildQuickExample('user_email', 'user@example.com'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickExample(String key, String value) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.flash_on, size: 20),
      title: Text(key, style: const TextStyle(fontSize: 14)),
      subtitle: Text(value, style: const TextStyle(fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward, size: 20),
        onPressed: () {
          setState(() {
            _keyController.text = key;
            _valueController.text = value;
          });
        },
      ),
    );
  }
}

enum StorageMode {
  privateMode,
  sharedMode,
}
