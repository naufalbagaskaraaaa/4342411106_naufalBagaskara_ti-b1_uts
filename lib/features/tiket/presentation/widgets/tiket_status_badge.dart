import 'package:flutter/material.dart';
import 'package:e_ticketing_helpdesk/core/constants/app_colors.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/entities/tiket_entity.dart';

/// Badge that visualizes a [TiketStatus] from the automated workflow.
class TiketStatusBadge extends StatelessWidget {
  const TiketStatusBadge({super.key, required this.status});

  final TiketStatus status;

  Color get _color {
    switch (status) {
      case TiketStatus.open:
        return AppColors.statusOpen;
      case TiketStatus.assign:
        return AppColors.secondary;
      case TiketStatus.inProgress:
        return AppColors.statusInProgress;
      case TiketStatus.close:
        return AppColors.statusResolved;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
