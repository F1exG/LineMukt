class Token {
  final int tokenNumber;
  final String patientName;
  final String department;
  final DateTime issuedAt;
  final String status; // waiting, serving, completed, cancelled
  final int positionInQueue;
  final int estimatedWaitMinutes;
  final String priority; // normal, urgent, vip
  final String? notes;

  Token({
    required this.tokenNumber,
    required this.patientName,
    required this.department,
    required this.issuedAt,
    required this.status,
    required this.positionInQueue,
    required this.estimatedWaitMinutes,
    required this.priority,
    this.notes,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      tokenNumber: json['token_number'],
      patientName: json['patient_name'],
      department: json['department'],
      issuedAt: DateTime.parse(json['issued_at']),
      status: json['status'],
      positionInQueue: json['position_in_queue'],
      estimatedWaitMinutes: json['estimated_wait_minutes'],
      priority: json['priority'] ?? 'normal',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'token_number': tokenNumber,
    'patient_name': patientName,
    'department': department,
    'issued_at': issuedAt.toIso8601String(),
    'status': status,
    'position_in_queue': positionInQueue,
    'estimated_wait_minutes': estimatedWaitMinutes,
    'priority': priority,
    'notes': notes,
  };

  Token copyWith({
    int? tokenNumber,
    String? patientName,
    String? department,
    DateTime? issuedAt,
    String? status,
    int? positionInQueue,
    int? estimatedWaitMinutes,
    String? priority,
    String? notes,
  }) {
    return Token(
      tokenNumber: tokenNumber ?? this.tokenNumber,
      patientName: patientName ?? this.patientName,
      department: department ?? this.department,
      issuedAt: issuedAt ?? this.issuedAt,
      status: status ?? this.status,
      positionInQueue: positionInQueue ?? this.positionInQueue,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
    );
  }

  bool get isUrgent => priority == 'urgent' || priority == 'vip';
  bool get isWaiting => status == 'waiting';
  bool get isServing => status == 'serving';
  bool get isCompleted => status == 'completed';
}