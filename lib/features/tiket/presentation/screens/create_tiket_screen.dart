import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/providers/auth_providers.dart';
import 'package:e_ticketing_helpdesk/features/tiket/presentation/providers/tiket_providers.dart';
import 'package:e_ticketing_helpdesk/widgets/app_button.dart';
import 'package:e_ticketing_helpdesk/widgets/app_text_field.dart';

/// Screen where a user creates a new ticket.
///
/// New tickets are always created with status `open` by the use case; there is
/// no manual status selection here.
class CreateTiketScreen extends ConsumerStatefulWidget {
  const CreateTiketScreen({super.key});

  @override
  ConsumerState<CreateTiketScreen> createState() => _CreateTiketScreenState();
}

class _CreateTiketScreenState extends ConsumerState<CreateTiketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi tidak ditemukan, silakan login ulang')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await ref.read(createTiketUseCaseProvider).call(
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          idUser: user.id,
        );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ref.invalidate(tiketListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket keluhan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Judul Keluhan',
                hint: 'Contoh: Internet Mati di Ruang Rapat',
                controller: _judulController,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Deskripsi Detail',
                hint: 'Jelaskan kronologi keluhan Anda...',
                controller: _deskripsiController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              AppButton(
                text: _isSubmitting ? 'Mengirim...' : 'Kirim Tiket',
                onPressed: _isSubmitting ? () {} : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
