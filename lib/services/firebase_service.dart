import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';
import '../models/attendance_model.dart';
import '../models/participation_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _students => _firestore.collection('students');
  CollectionReference get _teachers => _firestore.collection('teachers');
  CollectionReference get _attendance => _firestore.collection('attendance');
  CollectionReference get _participation => _firestore.collection('participation');

  // ================== STUDENTS ==================

  /// Add a new student
  Future<String> addStudent(StudentModel student) async {
    final doc = await _students.add(student.toMap());
    return doc.id;
  }

  /// Get all students
  Stream<List<StudentModel>> getStudents() {
    return _students
        .orderBy('full_name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudentModel.fromFirestore(doc))
            .toList());
  }

  /// Get student by UID
  Future<StudentModel?> getStudentByUid(String uid) async {
    final querySnapshot = await _students
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return StudentModel.fromFirestore(querySnapshot.docs.first);
  }

  /// Update student
  Future<void> updateStudent(String id, StudentModel student) async {
    await _students.doc(id).update(student.toMap());
  }

  /// Delete student
  Future<void> deleteStudent(String id) async {
    await _students.doc(id).delete();
  }

  // ================== TEACHERS ==================

  /// Add a new teacher
  Future<String> addTeacher(TeacherModel teacher) async {
    final doc = await _teachers.add(teacher.toMap());
    return doc.id;
  }

  /// Get all teachers
  Stream<List<TeacherModel>> getTeachers() {
    return _teachers
        .orderBy('full_name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TeacherModel.fromFirestore(doc))
            .toList());
  }

  /// Update teacher
  Future<void> updateTeacher(String id, TeacherModel teacher) async {
    await _teachers.doc(id).update(teacher.toMap());
  }

  /// Delete teacher
  Future<void> deleteTeacher(String id) async {
    await _teachers.doc(id).delete();
  }

  // ================== ATTENDANCE ==================

  /// Record attendance (from IoT device)
  Future<String> recordAttendance(AttendanceModel attendance) async {
    final doc = await _attendance.add(attendance.toMap());
    return doc.id;
  }

  /// Get attendance for a specific date
  Stream<List<AttendanceModel>> getAttendanceByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _attendance
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  /// Get all attendance records
  Stream<List<AttendanceModel>> getAllAttendance() {
    return _attendance
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  /// Get attendance for a specific student
  Stream<List<AttendanceModel>> getStudentAttendance(String studentId) {
    return _attendance
        .where('student_id', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  // ================== PARTICIPATION ==================

  /// Create participation request (from IoT button)
  Future<String> createParticipationRequest(ParticipationModel participation) async {
    final doc = await _participation.add(participation.toMap());
    return doc.id;
  }

  /// Get pending participation requests
  Stream<List<ParticipationModel>> getPendingParticipations() {
    return _participation
        .where('status', isEqualTo: 'pending')
        .orderBy('request_time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParticipationModel.fromFirestore(doc))
            .toList());
  }

  /// Get all participations
  Stream<List<ParticipationModel>> getAllParticipations() {
    return _participation
        .orderBy('request_time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParticipationModel.fromFirestore(doc))
            .toList());
  }

  /// Get accepted participations only
  Stream<List<ParticipationModel>> getAcceptedParticipations() {
    return _participation
        .where('status', isEqualTo: 'accepted')
        .orderBy('request_time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParticipationModel.fromFirestore(doc))
            .toList());
  }

  /// Accept participation request
  Future<void> acceptParticipation(String id, String teacherId) async {
    await _participation.doc(id).update({
      'status': 'accepted',
      'teacher_id': teacherId,
      'approval_time': Timestamp.now(),
    });
  }

  /// Decline participation request
  Future<void> declineParticipation(String id, String teacherId) async {
    await _participation.doc(id).update({
      'status': 'declined',
      'teacher_id': teacherId,
      'approval_time': Timestamp.now(),
    });
  }

  /// Get all participation requests (for teachers)
  Stream<List<ParticipationModel>> getParticipationRequests() {
    return _participation
        .orderBy('request_time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParticipationModel.fromFirestore(doc))
            .toList());
  }

  // ================== UTILITY ==================

  /// Check if UID exists
  Future<bool> uidExists(String uid) async {
    final querySnapshot = await _students
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  /// Get student by ID
  Future<StudentModel?> getStudentById(String id) async {
    try {
      final doc = await _students.doc(id).get();
      if (doc.exists) {
        return StudentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
