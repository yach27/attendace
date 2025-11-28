import 'package:cloud_firestore/cloud_firestore.dart';

enum ParticipationStatus { pending, accepted, declined }

class ParticipationModel {
  final String? id;
  final int tableNumber;
  final String? studentId;
  final DateTime requestTime;
  final ParticipationStatus status;
  final String? teacherId;
  final DateTime? approvalTime;

  ParticipationModel({
    this.id,
    required this.tableNumber,
    this.studentId,
    DateTime? requestTime,
    this.status = ParticipationStatus.pending,
    this.teacherId,
    this.approvalTime,
  }) : requestTime = requestTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'table_number': tableNumber,
      'student_id': studentId,
      'request_time': Timestamp.fromDate(requestTime),
      'status': status.name,
      'teacher_id': teacherId,
      'approval_time': approvalTime != null ? Timestamp.fromDate(approvalTime!) : null,
    };
  }

  factory ParticipationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParticipationModel(
      id: doc.id,
      tableNumber: data['table_number'] ?? 0,
      studentId: data['student_id'],
      requestTime: (data['request_time'] as Timestamp).toDate(),
      status: ParticipationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ParticipationStatus.pending,
      ),
      teacherId: data['teacher_id'],
      approvalTime: (data['approval_time'] as Timestamp?)?.toDate(),
    );
  }

  factory ParticipationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ParticipationModel(
      id: id,
      tableNumber: map['table_number'] ?? 0,
      studentId: map['student_id'],
      requestTime: (map['request_time'] as Timestamp).toDate(),
      status: ParticipationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ParticipationStatus.pending,
      ),
      teacherId: map['teacher_id'],
      approvalTime: (map['approval_time'] as Timestamp?)?.toDate(),
    );
  }

  ParticipationModel copyWith({
    String? id,
    int? tableNumber,
    String? studentId,
    DateTime? requestTime,
    ParticipationStatus? status,
    String? teacherId,
    DateTime? approvalTime,
  }) {
    return ParticipationModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      studentId: studentId ?? this.studentId,
      requestTime: requestTime ?? this.requestTime,
      status: status ?? this.status,
      teacherId: teacherId ?? this.teacherId,
      approvalTime: approvalTime ?? this.approvalTime,
    );
  }
}
