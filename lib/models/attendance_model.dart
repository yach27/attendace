import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent }

class AttendanceModel {
  final String? id;
  final String studentId;
  final String uid;
  final DateTime date;
  final DateTime? timeScanned;
  final AttendanceStatus status;
  final DateTime createdAt;

  AttendanceModel({
    this.id,
    required this.studentId,
    required this.uid,
    required this.date,
    this.timeScanned,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'time_scanned': timeScanned != null ? Timestamp.fromDate(timeScanned!) : null,
      'status': status.name,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      studentId: data['student_id'] ?? '',
      uid: data['uid'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeScanned: (data['time_scanned'] as Timestamp?)?.toDate(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AttendanceModel(
      id: id,
      studentId: map['student_id'] ?? '',
      uid: map['uid'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      timeScanned: (map['time_scanned'] as Timestamp?)?.toDate(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
