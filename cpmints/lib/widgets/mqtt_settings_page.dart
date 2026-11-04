import 'package:flutter/material.dart';
import '../config/mqtt_config.dart';

class MqttSettingsPage extends StatefulWidget {
  const MqttSettingsPage({super.key});

  @override
  State<MqttSettingsPage> createState() => _MqttSettingsPageState();
}

class _MqttSettingsPageState extends State<MqttSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _topicController;
  late final TextEditingController _keepAliveController;
  late final TextEditingController _clientIdController;

  @override
  void initState() {
    super.initState();

    _hostController = TextEditingController(text: MqttConfig.host);
    _portController = TextEditingController(text: MqttConfig.port.toString());
    _topicController = TextEditingController(text: MqttConfig.topic);
    _keepAliveController = TextEditingController(
      text: MqttConfig.keepAliveSeconds.toString(),
    );
    _clientIdController =
        TextEditingController(text: MqttConfig.clientId);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _topicController.dispose();
    _keepAliveController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }

  String? _portValidator(String? value) {
    final port = int.tryParse(value ?? '');
    if (port == null || port < 1 || port > 65535) {
      return 'Port harus antara 1–65535';
    }
    return null;
  }

  String? _keepAliveValidator(String? value) {
    final seconds = int.tryParse(value ?? '');
    if (seconds == null || seconds < 1) {
      return 'Masukkan angka lebih dari 0';
    }
    return null;
  }

  void _saveSettings() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      MqttConfig.host = _hostController.text.trim();
      MqttConfig.port = int.parse(_portController.text.trim());
      MqttConfig.topic = _topicController.text.trim();
      MqttConfig.keepAliveSeconds = int.parse(_keepAliveController.text.trim());
      MqttConfig.clientId = _clientIdController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan Divace disimpan')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan Divace',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF4F7FB),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildField(
                            controller: _hostController,
                            label: 'Host / IP Broker',
                            validator: _requiredValidator,
                          ),
                          _buildField(
                            controller: _portController,
                            label: 'Port',
                            keyboardType: TextInputType.number,
                            validator: _portValidator,
                          ),
                          _buildField(
                            controller: _topicController,
                            label: 'Topic',
                            validator: _requiredValidator,
                          ),
                          _buildField(
                            controller: _keepAliveController,
                            label: 'Keep-alive (detik)',
                            keyboardType: TextInputType.number,
                            validator: _keepAliveValidator,
                          ),
                          _buildField(
                            controller: _clientIdController,
                            label: 'Client ID',
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saveSettings,
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan Pengaturan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}