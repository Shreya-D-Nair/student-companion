import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../models/student.dart';
import '../../providers/app_preferences_provider.dart';
import '../../providers/interest_provider.dart';
import '../../providers/student_provider.dart';
import 'student_profile_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<InterestProvider>().loadInterests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final interestProvider = context.watch<InterestProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final anonymousDeviceId =
        context.watch<AppPreferencesProvider>().anonymousDeviceId;

    return RefreshIndicator(
      onRefresh: () async {
        await interestProvider.loadInterests();
        if (anonymousDeviceId != null) {
          await studentProvider.loadRecommendedStudents(anonymousDeviceId);
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          Text(
            'Similar Student Connect',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('Select interests and discover students like you.'),
          const SizedBox(height: 20),
          if (interestProvider.isLoading)
            const _InterestState(
              icon: Icons.hourglass_empty_rounded,
              message: 'Loading interests...',
            )
          else if (interestProvider.errorMessage != null)
            _InterestErrorState(
              message: interestProvider.errorMessage!,
              onRetry: interestProvider.loadInterests,
            )
          else if (interestProvider.interests.isEmpty)
            const _InterestState(
              icon: Icons.interests_outlined,
              message:
                  'Select at least one interest to discover students with similar interests.',
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  interestProvider.interests.map((interest) {
                    final selected = interestProvider.selectedInterestNames
                        .contains(interest.name);

                    return FilterChip(
                      label: Text(interest.name),
                      selected: selected,
                      onSelected:
                          (_) => interestProvider.toggleInterest(interest.name),
                    );
                  }).toList(),
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed:
                interestProvider.isSaving || anonymousDeviceId == null
                    ? null
                    : () async {
                      final saved = await interestProvider
                          .saveSelectedInterests(anonymousDeviceId);
                      if (!context.mounted) {
                        return;
                      }
                      if (saved) {
                        await studentProvider.loadRecommendedStudents(
                          anonymousDeviceId,
                        );
                      }
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            saved
                                ? 'Interests saved successfully.'
                                : interestProvider.errorMessage ??
                                    'Unable to save interests',
                          ),
                        ),
                      );
                    },
            icon: const Icon(Icons.save_rounded),
            label: Text(
              interestProvider.isSaving ? 'Saving...' : 'Save interests',
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Text(
                interestProvider.selectedInterestNames.isEmpty
                    ? 'No interests selected yet.'
                    : 'Selected: ${interestProvider.selectedInterestNames.join(', ')}',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recommended Students',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (studentProvider.isLoading)
            const _InterestState(
              icon: Icons.people_outline_rounded,
              message: 'Loading recommended students...',
            )
          else if (studentProvider.errorMessage != null)
            _InterestErrorState(
              message: studentProvider.errorMessage!,
              onRetry: () {
                if (anonymousDeviceId != null) {
                  studentProvider.loadRecommendedStudents(anonymousDeviceId);
                }
              },
            )
          else if (studentProvider.recommendedStudents.isEmpty)
            const _InterestState(
              icon: Icons.person_search_rounded,
              message:
                  'No matching students found. Try selecting more interests.',
            )
          else
            ...studentProvider.recommendedStudents.map(
              (student) => _StudentRecommendationCard(
                student: student,
                anonymousDeviceId: anonymousDeviceId,
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentRecommendationCard extends StatelessWidget {
  const _StudentRecommendationCard({
    required this.student,
    required this.anonymousDeviceId,
  });

  final Student student;
  final String? anonymousDeviceId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                title: Text(student.name),
                subtitle: Text('${student.course} • ${student.academicYear}'),
              ),
              Text(student.bio),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    student.sharedInterests
                        .map((interest) => Chip(label: Text(interest)))
                        .toList(),
              ),
              const SizedBox(height: 12),
              Text('${student.commonInterestCount} common interests'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed:
                    anonymousDeviceId == null
                        ? null
                        : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => StudentProfileScreen(
                                    studentId: student.id,
                                    anonymousDeviceId: anonymousDeviceId!,
                                  ),
                            ),
                          );
                        },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('View Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestState extends StatelessWidget {
  const _InterestState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _InterestErrorState extends StatelessWidget {
  const _InterestErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
