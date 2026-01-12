import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_item.dart';
import '../services/media_service.dart';
import 'media_detail_screen.dart';
import 'add_edit_media_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MediaType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaTrack'),
        elevation: 0,
        actions: [
          PopupMenuButton<MediaType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (MediaType? type) {
              setState(() {
                _selectedFilter = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos'),
              ),
              ...MediaType.values.map((type) {
                final item = MediaItem(
                  id: '',
                  title: '',
                  type: type,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                return PopupMenuItem(
                  value: type,
                  child: Text(item.typeName),
                );
              }),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<MediaItem>>(
        valueListenable: MediaService.box.listenable(),
        builder: (context, box, _) {
          final items = _selectedFilter == null
              ? MediaService.getAllItems()
              : MediaService.getItemsByType(_selectedFilter);

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum item encontrado',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no + para adicionar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Estatísticas
          final totalItems = items.length;
          final completedItems = items.where((item) => item.isCompleted).length;

          return Column(
            children: [
              if (totalItems > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCard(
                        icon: Icons.library_books,
                        label: 'Total',
                        value: totalItems.toString(),
                      ),
                      _StatCard(
                        icon: Icons.check_circle,
                        label: 'Completos',
                        value: completedItems.toString(),
                      ),
                      _StatCard(
                        icon: Icons.trending_up,
                        label: 'Progresso',
                        value: '${((completedItems / totalItems) * 100).toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _MediaItemCard(item: item);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditMediaScreen(),
            ),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item adicionado com sucesso!')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaItemCard extends StatelessWidget {
  final MediaItem item;

  const _MediaItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaDetailScreen(item: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(item.type).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.typeName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getTypeColor(item.type),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (item.rating > 0) ...[
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (item.isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.progressText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTypeColor(item.type),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(MediaType type) {
    switch (type) {
      case MediaType.serie:
        return Colors.blue;
      case MediaType.filme:
        return Colors.purple;
      case MediaType.livro:
        return Colors.orange;
      case MediaType.jogo:
        return Colors.green;
      case MediaType.podcast:
        return Colors.red;
      case MediaType.anime:
        return Colors.pink;
    }
  }
}
