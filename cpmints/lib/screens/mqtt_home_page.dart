import 'dart:async';

import 'package:flutter/material.dart';

import '../config/mqtt_config.dart';
import '../models/mqtt_message.dart';
import '../services/mqtt_service.dart';
import '../widgets/connection_card.dart';
import '../widgets/message_bubble.dart';
// import '../widgets/message_input.dart';
import '../widgets/mqtt_settings_page.dart';

class MqttHomePage extends StatefulWidget {
  const MqttHomePage({super.key});

  @override
  State<MqttHomePage> createState() => _MqttHomePageState();
}

class _MqttHomePageState extends State<MqttHomePage> {
  final MqttService _mqttService = MqttService();
  final TextEditingController _messageController = TextEditingController();
  final List<MqttMessage> _messages = [];

  StreamSubscription<MqttMessage>? _messageSubscription;

  bool _connected = false;
  bool _connecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _messageSubscription = _mqttService.messages.listen((message) {
      if (!mounted) return;

      setState(() {
        _messages.insert(0, message);
      });
    });
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });

    try {
      await _mqttService.connect();

      if (!mounted) return;
      setState(() {
        _connected = true;
        _connecting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _connected = false;
        _connecting = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _disconnect() async {
    await _mqttService.disconnect();

    if (!mounted) return;
    setState(() {
      _connected = false;
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (!_connected || text.isEmpty) return;

    _mqttService.publish(text);
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _mqttService.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monitoring System',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF4F7FB),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'monitoring':
                // Buka halaman monitoring
                  break;
                case 'settings':
                                Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MqttSettingsPage(),
                                  ),
                                ).then((saved) {
                                  if (saved == true && mounted) {
                                    setState(() {});
                                  }
                                });
                                break;
                case 'logout':
                // Proses logout
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'monitoring',
                child: Text('Monitoring RAM'),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text('Pengaturan'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kirim dan terima pesan melalui broker',
                style: TextStyle(color: Color(0xFF78869A)),
              ),
              const SizedBox(height: 18),
              ConnectionCard(
                connected: _connected,
                connecting: _connecting,
                host: MqttConfig.host,
                port: MqttConfig.port,
                onConnect: _connect,
                onDisconnect: _disconnect,
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pesan masuk',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${_messages.length} pesan',
                    style: const TextStyle(
                      color: Color(0xFF78869A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _messages.isEmpty ?
                      const Center(
                                    child: Text(
                                      'Belum ada pesan diterima',
                                      style: TextStyle(color: Color(0xFF8490A3)),
                                    ),
                                  )
                                  : ListView.builder(
                                                      itemCount: _messages.length,
                                                      itemBuilder: (context, index) {
                                                        return MessageBubble(message: _messages[index]);
                                                      },
                                                    ),
              ),
              // const SizedBox(height: 10),
              // MessageInput(
              //   controller: _messageController,
              //   enabled: _connected,
              //   onSend: _sendMessage,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}