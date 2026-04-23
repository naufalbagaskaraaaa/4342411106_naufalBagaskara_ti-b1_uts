import 'package:flutter/material.dart';
import 'package:e_ticketing_helpdesk/core/constants/app_colors.dart';
import 'package:e_ticketing_helpdesk/models/tiket_model.dart';

class StatusBadge extends StatelessWidget {
  final StatusTiket status;

  const StatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status) {
      case StatusTiket.open:
        return AppColors.statusOpen;
      case StatusTiket.inProgress:
        return AppColors.statusInProgress;
      case StatusTiket.resolved:
        return AppColors.statusResolved;
      case StatusTiket.closed:
        return AppColors.statusClosed;
    }
  }

  String _getStatusText() {
    switch (status) {
      case StatusTiket.open:
        return 'Open';
      case StatusTiket.inProgress:
        return 'In Progress';
      case StatusTiket.resolved:
        return 'Resolved';
      case StatusTiket.closed:
        return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}