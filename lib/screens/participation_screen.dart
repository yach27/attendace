import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/filter_button.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../models/participation_model.dart';
import 'package:intl/intl.dart';

class ParticipationScreen extends StatefulWidget {
  const ParticipationScreen({super.key});

  @override
  State<ParticipationScreen> createState() => _ParticipationScreenState();
}

class _ParticipationScreenState extends State<ParticipationScreen> {
  String? selectedFilter;
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final String _currentTeacherId = 'TEACHER001'; // Mock teacher ID

  @override
  void initState() {
    super.initState();
    // Listen for participation notifications
    _notificationService.addListener(_onParticipationRequest);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onParticipationRequest);
    super.dispose();
  }

  void _onParticipationRequest(ParticipationModel request) {
    // Show snackbar when new participation request comes in
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New participation request from Table ${request.tableNumber}!'),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Participation'),
        centerTitle: true,
        actions: [
          FilterButton(
            onPressed: () {
              FilterSheet.show(
                context,
                filterOptions: const ['All', 'Pending', 'Accepted', 'Declined'],
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
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ParticipationModel>>(
          stream: _firebaseService.getParticipationRequests(),
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
                    const Text('Error loading participation requests'),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var requests = snapshot.data!;

            // Apply filter
            if (selectedFilter != null && selectedFilter != 'All') {
              requests = requests.where((r) {
                switch (selectedFilter) {
                  case 'Pending':
                    return r.status == ParticipationStatus.pending;
                  case 'Accepted':
                    return r.status == ParticipationStatus.accepted;
                  case 'Declined':
                    return r.status == ParticipationStatus.declined;
                  default:
                    return true;
                }
              }).toList();
            }

            // Sort by request time (newest first)
            requests.sort((a, b) => b.requestTime.compareTo(a.requestTime));

            final pendingCount = snapshot.data!
                .where((r) => r.status == ParticipationStatus.pending)
                .length;
            final acceptedCount = snapshot.data!
                .where((r) => r.status == ParticipationStatus.accepted)
                .length;

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      selectedFilter == null || selectedFilter == 'All'
                          ? 'No participation requests yet'
                          : 'No $selectedFilter requests',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildSummaryCards(acceptedCount, pendingCount),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildParticipationCard(requests[index]);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _simulateButtonPress(context),
        icon: const Icon(Icons.touch_app),
        label: const Text('Simulate Button'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Widget _buildSummaryCards(int acceptedCount, int pendingCount) {
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
                        'Accepted',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$acceptedCount',
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
              backgroundColor: AppColors.warning.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.pending,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$pendingCount',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
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

  Widget _buildParticipationCard(ParticipationModel request) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (request.status) {
      case ParticipationStatus.accepted:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Accepted';
        break;
      case ParticipationStatus.declined:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = 'Declined';
        break;
      case ParticipationStatus.pending:
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        statusText = 'Pending';
    }

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Table ${request.tableNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Requested: ${DateFormat('MMM d, h:mm a').format(request.requestTime)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (request.studentId != null) ...[
            const SizedBox(height: 8),
            FutureBuilder(
              future: _firebaseService.getStudentById(request.studentId!),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Text(
                    'Student: ${snapshot.data!.fullName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          if (request.status == ParticipationStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _declineRequest(request.id!),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptRequest(request.id!),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (request.status != ParticipationStatus.pending &&
              request.approvalTime != null) ...[
            const SizedBox(height: 8),
            Text(
              '$statusText at: ${DateFormat('MMM d, h:mm a').format(request.approvalTime!)}',
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await _firebaseService.acceptParticipation(
        requestId,
        _currentTeacherId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participation accepted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _declineRequest(String requestId) async {
    try {
      await _firebaseService.declineParticipation(
        requestId,
        _currentTeacherId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participation declined'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _simulateButtonPress(BuildContext context) async {
    // Show dialog to select table number
    final tableNumber = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulate IoT Button Press'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a table number:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(10, (index) {
                final table = index + 1;
                return ElevatedButton(
                  onPressed: () => Navigator.pop(context, table),
                  child: Text('Table $table'),
                );
              }),
            ),
          ],
        ),
      ),
    );

    if (tableNumber != null && context.mounted) {
      try {
        final participation = ParticipationModel(
          tableNumber: tableNumber,
          requestTime: DateTime.now(),
          status: ParticipationStatus.pending,
        );

        await _firebaseService.createParticipationRequest(participation);
        _notificationService.notifyParticipationRequest(participation);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Participation request created for Table $tableNumber'),
              backgroundColor: AppColors.warning,
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
