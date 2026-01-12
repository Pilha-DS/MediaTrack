import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/media_service.dart';
import 'add_edit_media_screen.dart';

class MediaDetailScreen extends StatefulWidget {
  final MediaItem item;

  const MediaDetailScreen({super.key, required this.item});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  late MediaItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void _refreshItem() {
    final updated = MediaService.getItem(_item.id);
    if (updated != null) {
      setState(() {
        _item = updated;
      });
    }
  }

  Future<void> _showStatusDialog(BuildContext context) async {
    final updatedItem = MediaService.getItem(_item.id);
    if (updatedItem == null) return;

    final newStatus = await showDialog<MediaStatus>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: MediaStatus.values.map((status) {
              final tempItem = MediaItem(
                id: '',
                title: '',
                type: MediaType.serie,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                status: status,
              );
              return ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: tempItem.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(tempItem.statusName),
                selected: updatedItem.status == status,
                onTap: () => Navigator.pop(context, status),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (newStatus != null && newStatus != updatedItem.status) {
      // Salva status anterior antes de mudar (se não for um status especial)
      if (newStatus != MediaStatus.concluido && 
          newStatus != MediaStatus.dropado &&
          newStatus != MediaStatus.pausado &&
          newStatus != MediaStatus.naoIniciado &&
          updatedItem.status != MediaStatus.concluido &&
          updatedItem.status != MediaStatus.dropado) {
        updatedItem.previousStatus = updatedItem.status;
      }
      
      // Usa o método auxiliar para garantir exclusividade
      updatedItem.ensureStatusExclusivity(newStatus);
      await MediaService.updateItem(updatedItem);
      _refreshItem();
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${_item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await MediaService.deleteItem(_item.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item excluído com sucesso!')),
        );
      }
    }
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
      case MediaType.webtoon:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getTypeColor(_item.type),
                      _getTypeColor(_item.type).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getTypeIcon(_item.type),
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditMediaScreen(item: _item),
                    ),
                  );
                  if (result == true) {
                    _refreshItem();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item atualizado!')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _InfoItem(
                                icon: Icons.category,
                                label: 'Tipo',
                                value: _item.typeName,
                              ),
                              if (_item.rating > 0)
                                _InfoItem(
                                  icon: Icons.star,
                                  label: 'Avaliação',
                                  value: _item.rating.toStringAsFixed(1),
                                ),
                              GestureDetector(
                                onTap: () => _showStatusDialog(context),
                                child: _InfoItem(
                                  icon: Icons.flag,
                                  label: 'Status',
                                  value: _item.statusName,
                                  color: _item.statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Progresso',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _item.progressText,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _item.progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTypeColor(_item.type),
                              ),
                            ),
                          ),
                          Text(
                            '${(_item.progress * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_item.notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.note),
                                const SizedBox(width: 8),
                                Text(
                                  'Notas',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_item.notes),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info),
                              const SizedBox(width: 8),
                              Text(
                                'Informações',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Criado em', _formatDate(_item.createdAt)),
                          _buildInfoRow('Atualizado em', _formatDate(_item.updatedAt)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _deleteItem,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.delete),
        label: const Text('Excluir'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.serie:
        return Icons.tv;
      case MediaType.filme:
        return Icons.movie;
      case MediaType.livro:
        return Icons.menu_book;
      case MediaType.jogo:
        return Icons.sports_esports;
      case MediaType.podcast:
        return Icons.podcasts;
      case MediaType.anime:
        return Icons.animation;
      case MediaType.webtoon:
        return Icons.auto_stories;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
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
    );
  }
}
