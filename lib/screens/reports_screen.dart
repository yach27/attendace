import 'package:attendance/models/student_model.dart';
import 'package:attendance/screens/reports/edit_score_screen.dart';
import 'package:attendance/screens/reports/view_report_screen.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:attendance/services/pdf_service.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/filter_button.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? selectedFilter;
  String selectedReportType = 'Attendance';
  final FirebaseService _firebaseService = FirebaseService();

  final List<String> reportTypes = [
    'Attendance',
    'Participation',
    'Scores',
    'Grades',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Scores'),
        centerTitle: true,
        actions: [
          FilterButton(
            onPressed: () {
              FilterSheet.show(
                context,
                filterOptions: const ['Name A-Z', 'Name Z-A', 'UID', 'Highest Score', 'Lowest Score'],
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
        child: Column(
          children: [
            _buildReportTypeSelector(),
            Expanded(
              child: StreamBuilder<List<StudentModel>>(
                stream: _firebaseService.getStudents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final students = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildReportCard(students[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: reportTypes.map((type) {
          final isSelected = type == selectedReportType;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedReportType = type;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportCard(StudentModel student) {
    return ModernCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UID: ${student.uid}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildReportDropdown(student),
        ],
      ),
    );
  }

  Widget _buildReportDropdown(StudentModel student) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        try {
          if (value == 'view') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewReportScreen(
                  student: student,
                  reportType: selectedReportType,
                ),
              ),
            );
          } else if (value == 'edit') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditScoreScreen(student: student),
              ),
            );
          } else if (value == 'export') {
            PdfService().generatePdf(student, selectedReportType);
          }
        } catch (e) {
          print('Error in _buildReportDropdown: $e');
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 18, color: AppColors.primary),
              SizedBox(width: 12),
              Text('View Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: AppColors.warning),
              SizedBox(width: 12),
              Text('Edit Score'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.download, size: 18, color: AppColors.success),
              SizedBox(width: 12),
              Text('Export'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedReportType,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
