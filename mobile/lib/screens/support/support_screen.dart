import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../models/support_resource.dart';
import '../../providers/support_resource_provider.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<SupportResourceProvider>().loadResources();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupportResourceProvider>();

    return RefreshIndicator(
      onRefresh: provider.loadResources,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          Text(
            'Feeling Homesick? You Are Not Alone.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjusting to a new environment takes time. Explore simple activities and resources that may help you feel more comfortable.',
          ),
          const SizedBox(height: 20),
          if (provider.isLoading)
            const _SupportState(
              icon: Icons.hourglass_empty_rounded,
              message: 'Loading support resources...',
            )
          else if (provider.errorMessage != null)
            _SupportErrorState(
              message: provider.errorMessage!,
              onRetry: provider.loadResources,
            )
          else if (provider.resources.isEmpty)
            const _SupportState(
              icon: Icons.spa_outlined,
              message: 'Support resources are not available yet.',
            )
          else
            ...provider.resources.map(
              (resource) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openResourceDetails(context, resource),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  resource.category,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(resource.description),
                          const SizedBox(height: 12),
                          ...resource.tips
                              .take(2)
                              .map(
                                (tip) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _TipRow(tip: tip),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Text(
                'This section provides general wellness suggestions and is not a substitute for professional counselling or medical advice. If you feel unsafe or overwhelmed, contact a trusted person, your college counsellor, or local emergency services immediately.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openResourceDetails(BuildContext context, SupportResource resource) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSizes.padding,
              right: AppSizes.padding,
              bottom:
                  MediaQuery.of(sheetContext).viewInsets.bottom +
                  AppSizes.padding,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  resource.category,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(resource.description),
                const SizedBox(height: 16),
                Text(
                  'Helpful steps',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...resource.tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TipRow(tip: tip),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    child: Text(
                      'This is general wellness guidance, not professional counselling or medical advice. If you feel unsafe or overwhelmed, contact your college counsellor, a trusted person, or local emergency services immediately.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(tip)),
      ],
    );
  }
}

class _SupportState extends StatelessWidget {
  const _SupportState({required this.icon, required this.message});

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

class _SupportErrorState extends StatelessWidget {
  const _SupportErrorState({required this.message, required this.onRetry});

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
