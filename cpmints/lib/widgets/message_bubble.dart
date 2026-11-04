import 'package:flutter/material.dart';

import '../models/mqtt_message.dart';

class MessageBubble extends StatelessWidget {
  final MqttMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.receivedAt.hour.toString().padLeft(2, '0')}:'
        '${message.receivedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFEAF1FF),
            child: Icon(
              Icons.message_rounded,
              size: 17,
              color: Color(0xFF1769FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF253247),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8490A3),
            ),
          ),
        ],
      ),
    );
  }
}