import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/filter_button.dart';
import '../services/firebase_service.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? selectedFilter;
  final FirebaseService _firebaseService = FirebaseService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Attendance'),
            Text(
              DateFormat('MMMM d, yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
          FilterButton(
            onPressed: () {
              FilterSheet.show(
                context,
                filterOptions: const ['All Students', 'Present Only', 'Absent Only', 'Name A-Z'],
                selectedFilter: selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<StudentModel>>(
          stream: _firebaseService.getStudents(),
          builder: (context, studentsSnapshot) {
            if (studentsSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text('Error loading students'),
                  ],
                ),
              );
            }

            if (!studentsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allStudents = studentsSnapshot.data!;

            if (allStudents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text('No students enrolled yet'),
                  ],
                ),
              );
            }

            return StreamBuilder<List<AttendanceModel>>(
              stream: _firebaseService.getAttendanceByDate(_selectedDate),
              builder: (context, attendanceSnapshot) {
                if (attendanceSnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${attendanceSnapshot.error}'),
                  );
                }

                if (!attendanceSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final attendanceRecords = attendanceSnapshot.data!;

                // Create attendance data combining students and attendance records
                var attendanceList = allStudents.map((student) {
                  final attendance = attendanceRecords.firstWhere(
                    (a) => a.studentId == student.id,
                    orElse: () => AttendanceModel(
                      studentId: student.id!,
                      uid: student.uid,
                      date: _selectedDate,
                      status: AttendanceStatus.absent,
                    ),
                  );
                  return StudentAttendance(
                    student: student,
                    attendance: attendance,
                  );
                }).toList();

                // Apply filters
                if (selectedFilter != null) {
                  switch (selectedFilter) {
                    case 'Present Only':
                      attendanceList = attendanceList
                          .where((a) => a.attendance.status == AttendanceStatus.present)
                          .toList();
                      break;
                    case 'Absent Only':
                      attendanceList = attendanceList
                          .where((a) => a.attendance.status == AttendanceStatus.absent)
                          .toList();
                      break;
                    case 'Name A-Z':
                      attendanceList.sort((a, b) =>
                          a.student.fullName.compareTo(b.student.fullName));
                      break;
                  }
                }

                final presentCount = attendanceList
                    .where((a) => a.attendance.status == AttendanceStatus.present)
                    .length;
                final absentCount = attendanceList.length - presentCount;

                return Column(
                  children: [
                    _buildSummaryCards(presentCount, absentCount),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: attendanceList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildAttendanceCard(attendanceList[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _simulateUIDScan(context),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Simulate Scan'),
      ),
    );
  }

  Widget _buildSummaryCards(int presentCount, int absentCount) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ModernCard(
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Present',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$presentCount',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ModernCard(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Absent',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$absentCount',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(StudentAttendance data) {
    final isPresent = data.attendance.status == AttendanceStatus.present;
    final timeScanned = data.attendance.timeScanned;

    return ModernCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.student.fullName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UID: ${data.student.uid}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (timeScanned != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Scanned: ${DateFormat('h:mm a').format(timeScanned)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isPresent
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPresent ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: isPresent ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPresent ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateUIDScan(BuildContext context) async {
    // Get all students
    final students = await _firebaseService.getStudents().first;

    if (students.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No students to scan')),
        );
      }
      return;
    }

    // Show dialog to select a student
    if (context.mounted) {
      final selectedStudent = await showDialog<StudentModel>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Simulate UID Scan'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text(student.fullName),
                  subtitle: Text('UID: ${student.uid}'),
                  onTap: () => Navigator.pop(context, student),
                );
              },
            ),
          ),
        ),
      );

      if (selectedStudent != null && context.mounted) {
        try {
          final attendance = AttendanceModel(
            studentId: selectedStudent.id!,
            uid: selectedStudent.uid,
            date: _selectedDate,
            timeScanned: DateTime.now(),
            status: AttendanceStatus.present,
          );

          await _firebaseService.recordAttendance(attendance);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Attendance recorded for ${selectedStudent.fullName}'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    }
  }
}

class StudentAttendance {
  final StudentModel student;
  final AttendanceModel attendance;

  StudentAttendance({
    required this.student,
    required this.attendance,
  });
}
