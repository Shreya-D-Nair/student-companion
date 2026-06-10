import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_preferences_provider.dart';
import '../../providers/confession_provider.dart';

class ConfessionsScreen extends StatefulWidget {
  const ConfessionsScreen({super.key});

  @override
  State<ConfessionsScreen> createState() => _ConfessionsScreenState();
}

class _ConfessionsScreenState extends State<ConfessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final anonymousDeviceId =
          context.read<AppPreferencesProvider>().anonymousDeviceId;
      context.read<ConfessionProvider>().loadConfessions(
        anonymousDeviceId: anonymousDeviceId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfessionProvider>();
    final anonymousDeviceId =
        context.watch<AppPreferencesProvider>().anonymousDeviceId;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Share'),
      ),
      body: RefreshIndicator(
        onRefresh:
            () =>
                provider.loadConfessions(anonymousDeviceId: anonymousDeviceId),
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.padding),
          children: [
            Text(
              'Anonymous Confessions',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Share short thoughts anonymously with other students.'),
            const SizedBox(height: 20),
            if (provider.isLoading)
              const _CenteredState(
                icon: Icons.hourglass_empty_rounded,
                message: 'Loading confessions...',
              )
            else if (provider.errorMessage != null)
              _ErrorState(
                message: provider.errorMessage!,
                onRetry:
                    () => provider.loadConfessions(
                      anonymousDeviceId: anonymousDeviceId,
                    ),
              )
            else if (provider.confessions.isEmpty)
              const _CenteredState(
                icon: Icons.chat_bubble_outline_rounded,
                message:
                    'No confessions yet. Be the first to share something anonymously.',
              )
            else
              ...provider.confessions.map(
                (confession) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.person_rounded),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Anonymous Student',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      DateFormatter.relative(
                                        confession.createdAt,
                                      ),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (anonymousDeviceId == null) {
                                    _showSnackBar(
                                      'Anonymous device ID is not ready yet.',
                                    );
                                    return;
                                  }
                                  if (value == 'report') {
                                    _reportConfession(
                                      context,
                                      confession.id,
                                      anonymousDeviceId,
                                    );
                                  }
                                  if (value == 'delete') {
                                    _deleteConfession(
                                      context,
                                      confession.id,
                                      anonymousDeviceId,
                                    );
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'report',
                                        child: Text('Report'),
                                      ),
                                      if (confession.anonymousDeviceId ==
                                          anonymousDeviceId)
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                    ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(confession.content),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed:
                                    provider.isUpdatingAction ||
                                            anonymousDeviceId == null
                                        ? null
                                        : () async {
                                          final success = await provider
                                              .toggleReaction(
                                                confessionId: confession.id,
                                                anonymousDeviceId:
                                                    anonymousDeviceId,
                                              );
                                          if (!context.mounted) {
                                            return;
                                          }
                                          if (!success) {
                                            _showSnackBar(
                                              provider.errorMessage ??
                                                  'Unable to update reaction',
                                            );
                                          }
                                        },
                                icon: Icon(
                                  provider.reactedConfessionIds.contains(
                                        confession.id,
                                      )
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                ),
                                label: Text(
                                  '${confession.reactionCount} reactions',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateDialog() async {
    final provider = context.read<ConfessionProvider>();
    final anonymousDeviceId =
        context.read<AppPreferencesProvider>().anonymousDeviceId;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Share anonymously'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  maxLength: Validators.confessionMaxLength,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Write your confession...',
                  ),
                  validator: Validators.confession,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your confession will be posted anonymously.',
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || text == null || text.trim().isEmpty) {
      return;
    }

    if (anonymousDeviceId == null) {
      _showSnackBar('Anonymous device ID is not ready yet.');
      return;
    }

    final success = await provider.createConfession(
      anonymousDeviceId: anonymousDeviceId,
      content: text.trim(),
    );

    if (!mounted) {
      return;
    }

    _showSnackBar(
      success
          ? 'Confession shared successfully.'
          : provider.errorMessage ?? 'Failed to share confession.',
    );
  }

  Future<void> _reportConfession(
    BuildContext context,
    String confessionId,
    String anonymousDeviceId,
  ) async {
    final provider = context.read<ConfessionProvider>();
    final success = await provider.reportConfession(
      confessionId: confessionId,
      anonymousDeviceId: anonymousDeviceId,
      reason: 'Inappropriate or concerning content',
    );
    if (!context.mounted) {
      return;
    }
    _showSnackBar(
      success
          ? 'Confession reported successfully.'
          : provider.errorMessage ?? 'Unable to report confession',
    );
  }

  Future<void> _deleteConfession(
    BuildContext context,
    String confessionId,
    String anonymousDeviceId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete confession?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final provider = context.read<ConfessionProvider>();
    final success = await provider.deleteConfession(
      confessionId: confessionId,
      anonymousDeviceId: anonymousDeviceId,
    );
    if (!context.mounted) {
      return;
    }
    _showSnackBar(
      success
          ? 'Confession deleted successfully.'
          : provider.errorMessage ?? 'Unable to delete confession',
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
