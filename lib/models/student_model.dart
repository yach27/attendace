import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String? id;
  final String uid;
  final String fullName;
  final String? gradeSection;
  final DateTime createdAt;

  StudentModel({
    this.id,
    required this.uid,
    required this.fullName,
    this.gradeSection,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'full_name': fullName,
      'grade_section': gradeSection,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      fullName: data['full_name'] ?? '',
      gradeSection: data['grade_section'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Map
  factory StudentModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return StudentModel(
      id: id,
      uid: map['uid'] ?? '',
      fullName: map['full_name'] ?? '',
      gradeSection: map['grade_section'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  StudentModel copyWith({
    String? id,
    String? uid,
    String? fullName,
    String? gradeSection,
    DateTime? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      gradeSection: gradeSection ?? this.gradeSection,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
