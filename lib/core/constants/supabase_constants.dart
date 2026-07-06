/// Supabase database table names and configuration
class SupabaseConstants {
  // Table names
  static const String usersTable = 'users';
  static const String ticketsTable = 'tickets';
  static const String commentsTable = 'comments';

  // User roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleHelpdesk = 'helpdesk';

  // Ticket status values (must match database enum/check constraint)
  static const String statusOpen = 'open';
  static const String statusAssign = 'assign';
  static const String statusInProgress = 'in_progress';
  static const String statusClose = 'close';

  // Storage buckets (if using file storage)
  static const String attachmentsBucket = 'ticket-attachments';

  // Real-time subscriptions
  static const String subscriptionChannel = 'tickets:v1';

  // Query timeouts (in seconds)
  static const int queryTimeout = 30;
  static const int uploadTimeout = 300;
}

/// Supabase query helpers
class SupabaseQueryHelpers {
  // Common query patterns
  static const String createdAtDesc = 'created_at.desc';
  static const String updatedAtDesc = 'updated_at.desc';

  // Filter operators
  static const String operatorEq = 'eq';
  static const String operatorNeq = 'neq';
  static const String operatorGt = 'gt';
  static const String operatorLt = 'lt';
  static const String operatorGte = 'gte';
  static const String operatorLte = 'lte';
  static const String operatorLike = 'like';
  static const String operatorIn = 'in';
}
