import 'package:flutter/material.dart';

class TimeUtils {
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;

    if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds / 100).round()}';
    } else {
      return '${seconds.toString().padLeft(2, '0')}.${(milliseconds / 100).round()}';
    }
  }

  static String formatDurationShort(Duration duration) {
    final seconds = duration.inSeconds;
    final milliseconds = duration.inMilliseconds % 1000;
    return '$seconds.${(milliseconds / 100).round()}';
  }

  static String getTimeEmoji(Duration duration) {
    if (duration.inSeconds < 30) {
      return '⚡'; // Fast
    } else if (duration.inSeconds < 60) {
      return '🐰'; // Medium
    } else if (duration.inSeconds < 120) {
      return '🐌'; // Slow
    } else {
      return '🐌🐌'; // Very slow
    }
  }

  static Color getTimeColor(Duration duration) {
    if (duration.inSeconds < 30) {
      return const Color(0xFF4CAF50); // Green
    } else if (duration.inSeconds < 60) {
      return const Color(0xFFFF9800); // Orange
    } else if (duration.inSeconds < 120) {
      return const Color(0xFFFF5722); // Red
    } else {
      return const Color(0xFF9C27B0); // Purple
    }
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }
}
