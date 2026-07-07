import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../tiket/notification_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.role, super.key});

  final String role;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _liveTickets = [];
  List<Map<String, dynamic>> _helpdeskUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // 1. Ambil Data Tiket dari Supabase berdasarkan Role masing-masing
  Future<void> _fetchDashboardData() async {
    try {
      setState(() => _isLoading = true);
      
      var ticketQuery = _supabase.from('tickets').select('''
        *,
        user:id_user(nama),
        helpdesk:id_helpdesk(nama)
      ''');

      // Filter data tiket berdasarkan role yang masuk
      if (widget.role == 'helpdesk') {
        ticketQuery = ticketQuery.eq('id_helpdesk', _supabase.auth.currentUser!.id);
      } else if (widget.role == 'user') {
        ticketQuery = ticketQuery.eq('id_user', _supabase.auth.currentUser!.id);
      }

      final ticketData = await ticketQuery.order('created_at', ascending: false);

      // Jika admin, ambil juga data karyawan helpdesk untuk opsi dropdown penugasan tiket
      if (widget.role == 'admin') {
        final helpdeskData = await _supabase
            .from('users')
            .select('id, nama')
            .eq('role', 'helpdesk');
        _helpdeskUsers = List<Map<String, dynamic>>.from(helpdeskData);
      }

      if (!mounted) return;
      setState(() {
        _liveTickets = List<Map<String, dynamic>>.from(ticketData);
      });
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. Fungsi khusus Admin untuk Mendelegasikan (Assign) tiket ke tim Helpdesk
  Future<void> _assignTicketToHelpdesk(String ticketId, String helpdeskId) async {
    try {
      await _supabase.from('tickets').update({
        'id_helpdesk': helpdeskId,
        'id_admin': _supabase.auth.currentUser!.id,
        'status': 'assign',
      }).eq('id', ticketId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiket sukses didelegasikan ke Helpdesk!'), backgroundColor: Colors.green),
      );
      _fetchDashboardData(); // Refresh data dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendelegasikan tiket: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 3. Fungsi khusus Helpdesk untuk merubah status pengerjaan tiket (Workflow)
  Future<void> _updateWorkflowStatus(String ticketId, String nextStatus) async {
    try {
      await _supabase.from('tickets').update({
        'status': nextStatus,
      }).eq('id', ticketId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status tiket diperbarui menjadi $nextStatus!'), backgroundColor: Colors.green),
      );
      _fetchDashboardData(); // Refresh data dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung status kalkulasi secara dinamis dari database Supabase
    final finalTickets = _liveTickets;
    final int countTotal = finalTickets.length;
    final int countOpen = finalTickets.where((t) => t['status'] == 'open').length;
    final int countProgress = finalTickets.where((t) => t['status'] == 'in_progress' || t['status'] == 'assign').length;
    final int countResolved = finalTickets.where((t) => t['status'] == 'resolved').length;
    final int countClosed = finalTickets.where((t) => t['status'] == 'close' || t['status'] == 'closed').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role == 'admin' 
            ? 'Dashboard Admin' 
            : widget.role == 'helpdesk' 
                ? 'Dashboard Helpdesk' 
                : 'Dashboard Saya'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(role: widget.role),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard Tiket',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Tampilan Statistik Horizontal
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatCard(context, 'Total', countTotal.toString(), Colors.blue),
                          const SizedBox(width: 12),
                          _buildStatCard(context, 'Open', countOpen.toString(), Colors.redAccent),
                          const SizedBox(width: 12),
                          _buildStatCard(context, 'In Progress', countProgress.toString(), Colors.orange),
                          const SizedBox(width: 12),
                          _buildStatCard(context, 'Resolved', countResolved.toString(), Colors.purple),
                          const SizedBox(width: 12),
                          _buildStatCard(context, 'Closed', countClosed.toString(), Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Daftar Antrean Tiket',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    finalTickets.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: Text('Tidak ada antrean tiket saat ini.', style: TextStyle(color: Colors.grey))),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: finalTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = finalTickets[index];
                              return _buildInteractiveTicketCard(ticket);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  // Card Interaktif Khusus untuk Manajemen Alur Kerja (Workflow & Assignment)
  Widget _buildInteractiveTicketCard(Map<String, dynamic> ticket) {
    final String status = (ticket['status'] ?? 'open').toString().toLowerCase();
    Color badgeColor = Colors.orange;
    if (status == 'open') badgeColor = Colors.redAccent;
    if (status == 'assign') badgeColor = Colors.blue;
    if (status == 'in_progress') badgeColor = Colors.purple;
    if (status == 'close' || status == 'closed') badgeColor = Colors.green;

    final String clientName = ticket['user'] != null ? ticket['user']['nama'] ?? 'Anonim' : 'Anonim';
    final String helpdeskName = ticket['helpdesk'] != null ? ticket['helpdesk']['nama'] ?? '-' : '-';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(ticket['judul'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                  child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(ticket['deskripsi'] ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pelapor: $clientName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text('PIC: $helpdeskName', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),

            // --- DELEGASI & WORKFLOW ROLE-BASED UI RENDERING ---
            
            // A. JIKA ADMIN: Tampilkan dropdown list penugasan tim helpdesk
            if (widget.role == 'admin' && status == 'open') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tugaskan ke tim:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    hint: const Text('Pilih Helpdesk'),
                    items: _helpdeskUsers.map((hd) {
                      return DropdownMenuItem<String>(
                        value: hd['id'],
                        child: Text(hd['nama'] ?? 'No Name'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _assignTicketToHelpdesk(ticket['id'].toString(), val);
                    },
                  ),
                ],
              ),
            ],

            // B. JIKA HELPDESK: Akses tombol eksekusi status progress (Helpdesk Workflow Screen)
            if (widget.role == 'helpdesk') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == 'assign')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Proses Kerja'),
                      onPressed: () => _updateWorkflowStatus(ticket['id'].toString(), 'in_progress'),
                    ),
                  if (status == 'in_progress')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Selesaikan Tiket'),
                      onPressed: () => _updateWorkflowStatus(ticket['id'].toString(), 'close'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, Color color) {
    return Container(
      width: 110,
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}