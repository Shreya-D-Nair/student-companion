import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../providers/student_provider.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({
    required this.studentId,
    required this.anonymousDeviceId,
    super.key,
  });

  final String studentId;
  final String anonymousDeviceId;

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<StudentProvider>().loadStudentDetails(
        studentId: widget.studentId,
        anonymousDeviceId: widget.anonymousDeviceId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final student = provider.selectedStudent;

    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          if (provider.isLoading && student == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 56),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.errorMessage != null && student == null)
            Column(
              children: [
                const Icon(Icons.error_outline_rounded, size: 40),
                const SizedBox(height: 12),
                Text(provider.errorMessage!, textAlign: TextAlign.center),
              ],
            )
          else if (student != null) ...[
            const CircleAvatar(radius: 40, child: Icon(Icons.person_rounded)),
            const SizedBox(height: 16),
            Text(
              student.name,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${student.course} • ${student.academicYear}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Text(student.bio),
              ),
            ),
            const SizedBox(height: 16),
            Text('Interests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  student.interests
                      .map((item) => Chip(label: Text(item)))
                      .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Common Interests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  student.sharedInterests
                      .map((item) => Chip(label: Text(item)))
                      .toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  provider.isSendingRequest
                      ? null
                      : () async {
                        final sent = await provider.sendConnectRequest(
                          anonymousDeviceId: widget.anonymousDeviceId,
                          studentId: widget.studentId,
                        );
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              sent
                                  ? provider.connectRequestMessage ??
                                      'Connect request sent successfully.'
                                  : provider.errorMessage ??
                                      'Unable to send connect request',
                            ),
                          ),
                        );
                      },
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(
                provider.isSendingRequest
                    ? 'Sending...'
                    : 'Send Connect Request',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
