import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String? id;
  final String fullName;
  final String? subject;
  final DateTime createdAt;

  TeacherModel({
    this.id,
    required this.fullName,
    this.subject,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'subject': subject,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeacherModel(
      id: doc.id,
      fullName: data['full_name'] ?? '',
      subject: data['subject'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TeacherModel(
      id: id,
      fullName: map['full_name'] ?? '',
      subject: map['subject'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
