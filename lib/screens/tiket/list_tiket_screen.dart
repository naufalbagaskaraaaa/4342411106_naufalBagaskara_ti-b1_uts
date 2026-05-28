import 'package:flutter/material.dart';
import '../../core/dummy/dummy_data.dart';
import '../../models/tiket_model.dart';
import '../../widgets/tiket_card.dart';
import '../../widgets/empty_state_widget.dart';
import 'create_tiket_screen.dart';
import 'detail_tiket_screen.dart';

class ListTiketScreen extends StatefulWidget {
  final String role;
  const ListTiketScreen({super.key, required this.role});

  @override
  State<ListTiketScreen> createState() => _ListTiketScreenState();
}

class _ListTiketScreenState extends State<ListTiketScreen> {
  String selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    var tiketData = DummyData.tikets;
    if (widget.role == 'user') {
      tiketData = tiketData.where((t) => t.idUser == 'u2').toList();
    }

    if (selectedFilter != 'Semua') {
      tiketData = tiketData.where((t) => _statusToString(t.status) == selectedFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role == 'admin' ? 'Semua Tiket' : 'Tiket Saya'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['Semua', 'Open', 'In Progress', 'Resolved', 'Closed']
                  .map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selectedFilter == filter,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          
          Expanded(
            child: tiketData.isEmpty
                ? const EmptyStateWidget(message: 'Tidak ada tiket pada kategori ini')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tiketData.length,
                    itemBuilder: (context, index) {
                      return TiketCard(
                        tiket: tiketData[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailTiketScreen(
                                tiket: tiketData[index],
                                role: widget.role,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      
      floatingActionButton: widget.role == 'user'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateTiketScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _statusToString(StatusTiket status) {
    switch (status) {
      case StatusTiket.open: return 'Open';
      case StatusTiket.inProgress: return 'In Progress';
      case StatusTiket.resolved: return 'Resolved';
      case StatusTiket.closed: return 'Closed';
    }
  }
}
