import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/providers/auth_providers.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/entities/komentar_entity.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/entities/tiket_entity.dart';
import 'package:e_ticketing_helpdesk/features/tiket/presentation/providers/tiket_providers.dart';
import 'package:e_ticketing_helpdesk/features/tiket/presentation/widgets/tiket_status_badge.dart';
import 'package:e_ticketing_helpdesk/widgets/app_text_field.dart';
import 'package:e_ticketing_helpdesk/widgets/error_widget.dart';
import 'package:e_ticketing_helpdesk/widgets/loading_widget.dart';

/// Detail screen for a single ticket, including its comment thread.
///
/// Users can read the ticket and add comments. Ticket status is display-only
/// here because status transitions are automated by dedicated actions.
class DetailTiketScreen extends ConsumerStatefulWidget {
  const DetailTiketScreen({super.key, required this.tiketId});

  final String tiketId;

  @override
  ConsumerState<DetailTiketScreen> createState() => _DetailTiketScreenState();
}

class _DetailTiketScreenState extends ConsumerState<DetailTiketScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final isi = _commentController.text.trim();
    if (isi.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSending = true);
    final result = await ref.read(addKomentarUseCaseProvider).call(
          tiketId: widget.tiketId,
          userId: user.id,
          isi: isi,
        );

    if (!mounted) return;
    setState(() => _isSending = false);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        _commentController.clear();
        ref.invalidate(komentarListProvider(KomentarParams(tiketId: widget.tiketId)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tiketAsync =
        ref.watch(tiketDetailProvider(TiketDetailParams(tiketId: widget.tiketId)));
    final komentarAsync =
        ref.watch(komentarListProvider(KomentarParams(tiketId: widget.tiketId)));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: tiketAsync.when(
        loading: () => const LoadingWidget(message: 'Memuat tiket...'),
        error: (error, _) => CustomErrorWidget(errorMessage: error.toString()),
        data: (tiket) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TiketInfoCard(tiket: tiket),
                    const SizedBox(height: 24),
                    const Text(
                      'Riwayat Komentar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    komentarAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: LoadingWidget(),
                      ),
                      error: (error, _) =>
                          CustomErrorWidget(errorMessage: error.toString()),
                      data: (komentarList) {
                        if (komentarList.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Belum ada komentar',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return Column(
                          children: komentarList
                              .map((k) => _CommentBubble(
                                    komentar: k,
                                    isMe: k.idUser == user?.id,
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _CommentInput(
              controller: _commentController,
              isSending: _isSending,
              onSend: _sendComment,
            ),
          ],
        ),
      ),
    );
  }
}

class _TiketInfoCard extends StatelessWidget {
  const _TiketInfoCard({required this.tiket});

  final TiketEntity tiket;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Tiket #${tiket.id}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TiketStatusBadge(status: tiket.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tiket.judul,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat pada: ${tiket.createdAt.toString().substring(0, 16)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 32),
            const Text(
              'Deskripsi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(tiket.deskripsi),
          ],
        ),
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.komentar, required this.isMe});

  final KomentarEntity komentar;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMe ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMe ? 'Anda' : 'Pengguna lain',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isMe ? Colors.blue : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(komentar.isi),
            const SizedBox(height: 4),
            Text(
              komentar.createdAt.toString().substring(0, 16),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: controller,
              label: '',
              hint: 'Ketik balasan / komentar...',
            ),
          ),
          const SizedBox(width: 8),
          isSending
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: onSend,
                ),
        ],
      ),
    );
  }
}
