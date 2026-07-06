import 'komentar_entity.dart';

/// Ticket entity representing a support ticket in the E-Ticketing Helpdesk system.
///
/// This entity enforces the automated status workflow where status changes
/// are triggered by specific actions only, not manual user input.
class TiketEntity {
  /// Unique identifier for the ticket
  final String id;

  /// Title/subject of the ticket
  final String judul;

  /// Detailed description of the issue
  final String deskripsi;

  /// Current status following the automated workflow:
  /// - open: Initial status when user creates ticket
  /// - assign: Admin accepts the ticket
  /// - in_progress: Admin assigns ticket to helpdesk
  /// - close: Helpdesk marks ticket as finished
  final TiketStatus status;

  /// ID of the user who created the ticket
  final String idUser;

  /// ID of the admin who accepted/assigned the ticket (nullable until assigned)
  final String? idAdmin;

  /// ID of the helpdesk assigned to this ticket (nullable until assigned)
  final String? idHelpdesk;

  /// Timestamp when ticket was created
  final DateTime createdAt;

  /// Timestamp when ticket was last updated
  final DateTime? updatedAt;

  /// List of comments on this ticket
  final List<KomentarEntity> komentar;

  const TiketEntity({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.idUser,
    this.idAdmin,
    this.idHelpdesk,
    required this.createdAt,
    required this.updatedAt,
    this.komentar = const [],
  });

  /// Creates a copy of this ticket with updated fields
  TiketEntity copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    TiketStatus? status,
    String? idUser,
    String? idAdmin,
    String? idHelpdesk,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<KomentarEntity>? komentar,
  }) {
    return TiketEntity(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
      idUser: idUser ?? this.idUser,
      idAdmin: idAdmin ?? this.idAdmin,
      idHelpdesk: idHelpdesk ?? this.idHelpdesk,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      komentar: komentar ?? this.komentar,
    );
  }

  /// Check if ticket can be assigned to helpdesk
  bool get canBeAssigned => status == TiketStatus.assign;

  /// Check if ticket can be accepted by admin
  bool get canBeAccepted => status == TiketStatus.open;

  /// Check if ticket can be marked as finished
  bool get canBeFinished => status == TiketStatus.inProgress;

  /// Check if ticket is closed
  bool get isClosed => status == TiketStatus.close;

  /// Check if ticket is open
  bool get isOpen => status == TiketStatus.open;

  /// Check if ticket is in progress
  bool get isInProgress => status == TiketStatus.inProgress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TiketEntity &&
      other.id == id &&
      other.judul == judul &&
      other.deskripsi == deskripsi &&
      other.status == status &&
      other.idUser == idUser &&
      other.idAdmin == idAdmin &&
      other.idHelpdesk == idHelpdesk &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      judul.hashCode ^
      deskripsi.hashCode ^
      status.hashCode ^
      idUser.hashCode ^
      idAdmin.hashCode ^
      idHelpdesk.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}

/// Enum representing the automated status workflow for tickets.
///
/// CRITICAL: Status changes MUST follow this automated workflow:
/// 1. User creates ticket → status: open
/// 2. Admin accepts ticket → status: assign
/// 3. Admin assigns to helpdesk → status: in_progress
/// 4. Helpdesk clicks "Selesai/Finish" → status: close
///
/// IMPORTANT: Do NOT implement manual status change dropdowns/inputs.
/// Status changes must be triggered by specific actions only.
enum TiketStatus {
  /// Initial status when a user creates a new ticket
  open,

  /// Status when admin has accepted the ticket but hasn't assigned to helpdesk yet
  assign,

  /// Status when admin has assigned the ticket to a helpdesk staff
  inProgress,

  /// Final status when helpdesk has resolved the ticket
  close;

  /// Get the display name for the status
  String get displayName {
    switch (this) {
      case TiketStatus.open:
        return 'Open';
      case TiketStatus.assign:
        return 'Assigned';
      case TiketStatus.inProgress:
        return 'In Progress';
      case TiketStatus.close:
        return 'Closed';
    }
  }

  /// Get the description of what this status means
  String get description {
    switch (this) {
      case TiketStatus.open:
        return 'Ticket has been created and waiting for admin acceptance';
      case TiketStatus.assign:
        return 'Admin has accepted the ticket, ready to assign to helpdesk';
      case TiketStatus.inProgress:
        return 'Helpdesk is working on this ticket';
      case TiketStatus.close:
        return 'Ticket has been resolved by helpdesk';
    }
  }

  /// Check if this status can transition to the target status
  bool canTransitionTo(TiketStatus target) {
    switch (this) {
      case TiketStatus.open:
        return target == TiketStatus.assign;
      case TiketStatus.assign:
        return target == TiketStatus.inProgress;
      case TiketStatus.inProgress:
        return target == TiketStatus.close;
      case TiketStatus.close:
        return false; // Cannot transition from closed
    }
  }

  /// Get the next status in the workflow (if applicable)
  TiketStatus? get nextStatus {
    switch (this) {
      case TiketStatus.open:
        return TiketStatus.assign;
      case TiketStatus.assign:
        return TiketStatus.inProgress;
      case TiketStatus.inProgress:
        return TiketStatus.close;
      case TiketStatus.close:
        return null;
    }
  }
}