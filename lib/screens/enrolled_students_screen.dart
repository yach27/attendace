import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/filter_button.dart';
import '../services/firebase_service.dart';
import '../models/student_model.dart';

class EnrolledStudentsScreen extends StatefulWidget {
  const EnrolledStudentsScreen({super.key});

  @override
  State<EnrolledStudentsScreen> createState() => _EnrolledStudentsScreenState();
}

class _EnrolledStudentsScreenState extends State<EnrolledStudentsScreen> {
  String? selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Students'),
        centerTitle: true,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SearchField(
                      hintText: 'Search students...',
                      controller: _searchController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterButton(
                    onPressed: () {
                      FilterSheet.show(
                        context,
                        filterOptions: const ['Name A-Z', 'Name Z-A', 'UID'],
                        selectedFilter: selectedFilter,
                        onFilterSelected: (filter) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<StudentModel>>(
                stream: _firebaseService.getStudents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
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
                          Text(
                            'Error loading students',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var students = snapshot.data!;

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    students = students.where((student) {
                      return student.fullName.toLowerCase().contains(_searchQuery) ||
                          student.uid.toLowerCase().contains(_searchQuery) ||
                          (student.gradeSection?.toLowerCase().contains(_searchQuery) ?? false);
                    }).toList();
                  }

                  // Apply sort filter
                  if (selectedFilter != null) {
                    switch (selectedFilter) {
                      case 'Name A-Z':
                        students.sort((a, b) => a.fullName.compareTo(b.fullName));
                        break;
                      case 'Name Z-A':
                        students.sort((a, b) => b.fullName.compareTo(a.fullName));
                        break;
                      case 'UID':
                        students.sort((a, b) => a.uid.compareTo(b.uid));
                        break;
                    }
                  }

                  if (students.isEmpty) {
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
                          Text(
                            _searchQuery.isEmpty
                                ? 'No students enrolled yet'
                                : 'No students found',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ModernCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _buildTableHeader(),
                              ...students.asMap().entries.map((entry) {
                                final index = entry.key;
                                final student = entry.value;
                                return _buildStudentRow(student, index + 1);
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              'NO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'UID',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'STUDENT NAME',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'GRADE/SEC',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(StudentModel student, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              student.uid,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              student.fullName.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              student.gradeSection ?? '-',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
