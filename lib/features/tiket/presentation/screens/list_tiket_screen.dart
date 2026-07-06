import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/providers/auth_providers.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/entities/tiket_entity.dart';
import 'package:e_ticketing_helpdesk/features/tiket/presentation/providers/tiket_providers.dart';
import 'package:e_ticketing_helpdesk/features/tiket/presentation/widgets/tiket_entity_card.dart';
import 'package:e_ticketing_helpdesk/widgets/empty_state_widget.dart';
import 'package:e_ticketing_helpdesk/widgets/error_widget.dart';
import 'package:e_ticketing_helpdesk/widgets/loading_widget.dart';
import 'create_tiket_screen.dart';
import 'detail_tiket_screen.dart';

/// Currently selected status filter on the user ticket list.
///
/// `null` means "Semua" (all statuses).
final userTiketFilterProvider =
    StateProvider.autoDispose<TiketStatus?>((ref) => null);

/// Screen that shows the signed-in user's own tickets with status filters.
///
/// Regular users can only see their own tickets (enforced by the use case) and
/// create new tickets. Status changes are automated and never edited here.
class ListTiketScreen extends ConsumerWidget {
  const ListTiketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final selectedFilter = ref.watch(userTiketFilterProvider);

    if (user == null) {
      return const Scaffold(
        body: EmptyStateWidget(message: 'Sesi tidak ditemukan, silakan login ulang'),
      );
    }

    final params = TiketListParams(
      userId: user.id,
      userRole: user.role,
      statusFilter: selectedFilter,
    );
    final tiketAsync = ref.watch(tiketListProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiket Saya'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _FilterBar(selected: selectedFilter),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(tiketListProvider),
              child: tiketAsync.when(
                loading: () => const LoadingWidget(message: 'Memuat tiket...'),
                error: (error, _) =>
                    CustomErrorWidget(errorMessage: error.toString()),
                data: (tiketList) {
                  if (tiketList.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyStateWidget(
                          message: 'Belum ada tiket pada kategori ini',
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: tiketList.length,
                    itemBuilder: (context, index) {
                      final tiket = tiketList[index];
                      return TiketEntityCard(
                        tiket: tiket,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailTiketScreen(tiketId: tiket.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTiketScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.selected});

  final TiketStatus? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // null entry represents "Semua".
    const filters = <TiketStatus?>[
      null,
      TiketStatus.open,
      TiketStatus.assign,
      TiketStatus.inProgress,
      TiketStatus.close,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: filters.map((filter) {
          final label = filter?.displayName ?? 'Semua';
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: selected == filter,
              onSelected: (isSelected) {
                if (isSelected) {
                  ref.read(userTiketFilterProvider.notifier).state = filter;
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
