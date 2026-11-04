import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../config/mqtt_config.dart';
import '../models/mqtt_message.dart' as app;

class MqttService {
  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;
  final StreamController<app.MqttMessage> _messagesController = StreamController<app.MqttMessage>.broadcast();
  bool _connecting = false;
  bool _disposed = false;
  Stream<app.MqttMessage> get messages => _messagesController.stream;
  bool get isConnected =>  _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    if (_disposed) {
      throw StateError('MqttService sudah di-dispose.');
    }

    if (isConnected) {
      debugPrint('MQTT: sudah terhubung.');
      return;
    }

    if (_connecting) {
      throw StateError('Koneksi MQTT sedang berlangsung.');
    }

    _connecting = true;
    final client = MqttServerClient.withPort(
      MqttConfig.host,
      MqttConfig.clientId,
      MqttConfig.port,
    );

    client
      ..setProtocolV311()
      ..logging(on: true) // Matikan dengan false setelah debugging.
      ..keepAlivePeriod = MqttConfig.keepAliveSeconds
      ..autoReconnect = false
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(MqttConfig.clientId)
          .startClean();

    _client = client;

    try {
      debugPrint(
        'MQTT: menghubungkan ke ${MqttConfig.host}:${MqttConfig.port}',
      );
      debugPrint('MQTT: clientId=${MqttConfig.clientId}');
      debugPrint('MQTT: topic=${MqttConfig.topic}');

      await client.connect();

      final state = client.connectionStatus?.state;
      debugPrint('MQTT: status koneksi setelah connect = $state');

      if (state != MqttConnectionState.connected) {
        throw Exception('Koneksi MQTT gagal. Status: $state');
      }

      // Pasang listener sebelum subscribe agar pesan yang masuk dapat diterima.
      await _subscription?.cancel();
      _subscription = client.updates?.listen(
            (receivedMessages) {
          for (final received in receivedMessages) {
            if (received.payload is! MqttPublishMessage) {
              debugPrint('MQTT: payload bukan MqttPublishMessage.');
              continue;
            }

            final publish = received.payload as MqttPublishMessage;
            final text = MqttPublishPayload.bytesToStringAsString(
              publish.payload.message,
            );

            debugPrint('MQTT: pesan diterima dari [${received.topic}]');
            debugPrint('MQTT: isi pesan = $text');

            if (!_messagesController.isClosed) {
              _messagesController.add(
                app.MqttMessage(
                  text: text,
                  receivedAt: DateTime.now(),
                ),
              );
            }
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('MQTT: updates error = $error');
          debugPrintStack(stackTrace: stackTrace);
        },
        onDone: () {
          debugPrint('MQTT: stream updates selesai.');
        },
      );

      debugPrint('MQTT: mulai subscribe ke ${MqttConfig.topic}');

      final subscription = client.subscribe(
        MqttConfig.topic,
        MqttQos.atLeastOnce,
      );

      if (subscription == null) {
        debugPrint('MQTT: subscribe gagal atau tidak berhasil dikirim.');
      } else {
        debugPrint('MQTT: permintaan subscribe terkirim.');
      }

      debugPrint('MQTT: berhasil terhubung dan menunggu pesan...');
    } catch (error, stackTrace) {
      debugPrint('MQTT: connect/subscribe error = $error');
      debugPrintStack(stackTrace: stackTrace);

      await _subscription?.cancel();
      _subscription = null;

      client.disconnect();

      if (identical(_client, client)) {
        _client = null;
      }

      rethrow;
    } finally {
      _connecting = false;
    }
  }

  void publish(String text) {
    final client = _client;

    if (client == null || !isConnected || text.trim().isEmpty) {
      debugPrint('Pesan tidak dikirim: MQTT belum terhubung atau pesan kosong.');
      return;
    }

    final builder = MqttClientPayloadBuilder()
      ..addString(text.trim());

    final payload = builder.payload;
    if (payload == null) return;

    client.publishMessage(
      MqttConfig.topic,
      MqttQos.atLeastOnce,
      payload,
    );
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;

    _client?.disconnect();
    _client = null;
  }

  Future<void> dispose() async {
    if (_disposed) return;

    await disconnect();
    _disposed = true;

    await _messagesController.close();
  }
}