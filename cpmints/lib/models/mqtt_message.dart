class MqttMessage {
  final String text;
  final DateTime receivedAt;

  const MqttMessage({
    required this.text,
    required this.receivedAt,
  });
}