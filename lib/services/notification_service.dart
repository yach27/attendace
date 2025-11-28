import 'package:flutter/material.dart';
import '../models/participation_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<Function(ParticipationModel)> _listeners = [];

  /// Add a listener for new participation requests
  void addListener(Function(ParticipationModel) listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(Function(ParticipationModel) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of a new participation request
  void notifyParticipationRequest(ParticipationModel participation) {
    for (var listener in _listeners) {
      listener(participation);
    }
  }

  /// Show snackbar notification
  void showParticipationNotification(
    BuildContext context,
    ParticipationModel participation,
    Function(String, bool) onResponse,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Table ${participation.tableNumber} wants to answer'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            _showParticipationDialog(context, participation, onResponse);
          },
        ),
      ),
    );
  }

  /// Show dialog for participation request
  void _showParticipationDialog(
    BuildContext context,
    ParticipationModel participation,
    Function(String, bool) onResponse,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Participation Request'),
        content: Text(
          'Table ${participation.tableNumber} wants to answer.\n\n'
          'Do you want to accept this participation?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onResponse(participation.id!, false);
            },
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onResponse(participation.id!, true);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
