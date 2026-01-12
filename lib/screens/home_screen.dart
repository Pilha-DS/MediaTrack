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
  bool _showCompleted = false;

  Future<void> _addRapido() async {
    final tipos = MediaType.values;
    final tipoAleatorio = tipos[DateTime.now().millisecondsSinceEpoch % tipos.length];
    
    final exemplos = {
      MediaType.serie: ['Breaking Bad', 'Game of Thrones', 'Stranger Things', 'The Office'],
      MediaType.filme: ['Matrix', 'Inception', 'Interstellar', 'Pulp Fiction'],
      MediaType.livro: ['1984', 'O Senhor dos Anéis', 'Harry Potter', 'Dom Casmurro'],
      MediaType.jogo: ['The Witcher 3', 'Red Dead Redemption 2', 'God of War', 'Zelda'],
      MediaType.podcast: ['Podcast 1', 'Podcast 2', 'Podcast 3', 'Podcast 4'],
      MediaType.anime: ['Naruto', 'One Piece', 'Attack on Titan', 'Demon Slayer'],
      MediaType.webtoon: ['Solo Leveling', 'Tower of God', 'The Beginning After The End', 'Omniscient Reader'],
    };
    
    final titulos = exemplos[tipoAleatorio] ?? ['Item de Teste'];
    final tituloAleatorio = titulos[DateTime.now().millisecondsSinceEpoch % titulos.length];
    
    final now = DateTime.now();
    final item = MediaItem(
      id: 'test_${now.millisecondsSinceEpoch}',
      title: tituloAleatorio,
      type: tipoAleatorio,
      createdAt: now,
      updatedAt: now,
    );
    
    // Adiciona dados de exemplo baseado no tipo
    switch (tipoAleatorio) {
      case MediaType.serie:
      case MediaType.anime:
        item.totalSeasons = 3 + (now.millisecondsSinceEpoch % 5);
        item.totalEpisodes = 10 + (now.millisecondsSinceEpoch % 10);
        item.currentSeason = 1;
        item.currentEpisode = 1 + (now.millisecondsSinceEpoch % 5);
        break;
      case MediaType.livro:
      case MediaType.webtoon:
        item.totalPages = 200 + (now.millisecondsSinceEpoch % 300);
        item.currentPage = 1 + (now.millisecondsSinceEpoch % 50);
        break;
      case MediaType.podcast:
        item.totalEpisodes = 50 + (now.millisecondsSinceEpoch % 100);
        item.currentEpisode = 1 + (now.millisecondsSinceEpoch % 20);
        break;
      case MediaType.filme:
      case MediaType.jogo:
        item.isCompleted = (now.millisecondsSinceEpoch % 2) == 0;
        break;
    }
    
    await MediaService.addItem(item);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item de teste adicionado: $tituloAleatorio'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaTrack'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showCompleted ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
            tooltip: _showCompleted ? 'Ocultar completos' : 'Mostrar completos',
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _addRapido,
            tooltip: 'Adicionar Rápido (Teste)',
          ),
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
          final allItems = _selectedFilter == null
              ? MediaService.getAllItems()
              : MediaService.getItemsByType(_selectedFilter);

          // Filtrar itens completos se não devem ser mostrados
          var items = allItems;
          if (!_showCompleted) {
            items = items.where((item) => !item.isCompleted).toList();
          }

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.library_add_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Sua biblioteca está vazia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comece adicionando seus filmes, séries, livros e muito mais',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    FilledButton.icon(
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
                      label: const Text('Adicionar Primeiro Item'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Estatísticas (baseadas em todos os itens, não apenas os visíveis)
          final totalItems = allItems.length;
          final completedItems = allItems.where((item) => item.isCompleted).length;

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
    return Padding(
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
    );
  }
}

class _MediaItemCard extends StatefulWidget {
  final MediaItem item;

  const _MediaItemCard({required this.item});

  @override
  State<_MediaItemCard> createState() => _MediaItemCardState();
}

class _MediaItemCardState extends State<_MediaItemCard> {
  bool _isUpdating = false;
  double? _localSliderValue;

  @override
  void didUpdateWidget(_MediaItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resetar o valor local se o item mudou externamente
    if (oldWidget.item.id != widget.item.id) {
      _localSliderValue = null;
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

  Color _getBorderColor(MediaType type) {
    // Cores suaves, próximas ao cinza, mas com leve tom colorido
    switch (type) {
      case MediaType.serie:
        return Colors.blueGrey.shade300;
      case MediaType.filme:
        return Colors.grey.shade400;
      case MediaType.livro:
        return Colors.brown.shade300;
      case MediaType.jogo:
        return Colors.teal.shade300;
      case MediaType.podcast:
        return Colors.grey.shade400;
      case MediaType.anime:
        return Colors.pink.shade200;
      case MediaType.webtoon:
        return Colors.indigo.shade300;
    }
  }

  Future<void> _updateProgressFromSlider(double newProgress) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) {
      setState(() => _isUpdating = false);
      return;
    }

    // Converter o progresso (0.0 a 1.0) de volta para o valor atual
    switch (updatedItem.type) {
      case MediaType.serie:
      case MediaType.anime:
        if (updatedItem.totalSeasons > 0 && updatedItem.totalEpisodes > 0) {
          int totalAvailable = updatedItem.totalSeasons * updatedItem.totalEpisodes;
          int targetWatched = (newProgress * totalAvailable).round();
          
          if (targetWatched <= 0) {
            updatedItem.currentSeason = 1;
            updatedItem.currentEpisode = 1;
          } else if (targetWatched >= totalAvailable) {
            updatedItem.currentSeason = updatedItem.totalSeasons;
            updatedItem.currentEpisode = updatedItem.totalEpisodes;
            updatedItem.isCompleted = true;
          } else {
            updatedItem.currentSeason = ((targetWatched - 1) ~/ updatedItem.totalEpisodes) + 1;
            updatedItem.currentEpisode = ((targetWatched - 1) % updatedItem.totalEpisodes) + 1;
            updatedItem.isCompleted = false;
          }
          
          // Garantir que os valores estão dentro dos limites
          updatedItem.currentSeason = updatedItem.currentSeason.clamp(1, updatedItem.totalSeasons);
          updatedItem.currentEpisode = updatedItem.currentEpisode.clamp(1, updatedItem.totalEpisodes);
        }
        break;
      case MediaType.livro:
      case MediaType.webtoon:
        if (updatedItem.totalPages > 0) {
          updatedItem.currentPage = (newProgress * updatedItem.totalPages).round().clamp(1, updatedItem.totalPages);
          if (updatedItem.currentPage >= updatedItem.totalPages) {
            updatedItem.isCompleted = true;
          } else {
            updatedItem.isCompleted = false;
          }
        }
        break;
      case MediaType.podcast:
        if (updatedItem.totalEpisodes > 0) {
          updatedItem.currentEpisode = (newProgress * updatedItem.totalEpisodes).round().clamp(1, updatedItem.totalEpisodes);
          if (updatedItem.currentEpisode >= updatedItem.totalEpisodes) {
            updatedItem.isCompleted = true;
          } else {
            updatedItem.isCompleted = false;
          }
        }
        break;
      case MediaType.filme:
      case MediaType.jogo:
        updatedItem.isCompleted = newProgress >= 1.0;
        break;
    }

    await MediaService.updateItem(updatedItem);
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(widget.item.type),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaDetailScreen(item: widget.item),
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
                          widget.item.title,
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
                                color: _getTypeColor(widget.item.type).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.item.typeName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getTypeColor(widget.item.type),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (widget.item.rating > 0) ...[
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
                                    widget.item.rating.toStringAsFixed(1),
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
                  if (widget.item.type == MediaType.webtoon)
                    _WebtoonTotalControls(item: widget.item),
                  if (widget.item.isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.item.progressText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              _QuickProgressControls(item: widget.item),
              const SizedBox(height: 8),
              // Slider interativo para a barra de progresso
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getTypeColor(widget.item.type),
                  inactiveTrackColor: Colors.grey[200],
                  thumbColor: _getTypeColor(widget.item.type),
                  overlayColor: _getTypeColor(widget.item.type).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: (_localSliderValue ?? widget.item.progress).clamp(0.0, 1.0),
                  onChanged: _isUpdating
                      ? null
                      : (double value) {
                          setState(() {
                            _localSliderValue = value;
                          });
                          _updateProgressFromSlider(value);
                        },
                  onChangeEnd: (double value) {
                    // Limpar o valor local após o arrasto terminar
                    setState(() {
                      _localSliderValue = null;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickProgressControls extends StatefulWidget {
  final MediaItem item;

  const _QuickProgressControls({required this.item});

  @override
  State<_QuickProgressControls> createState() => _QuickProgressControlsState();
}

class _QuickProgressControlsState extends State<_QuickProgressControls> {
  bool _isUpdating = false;

  Future<void> _incrementProgress({int amount = 1}) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) return;

    switch (widget.item.type) {
      case MediaType.serie:
      case MediaType.anime:
        if (updatedItem.totalEpisodes > 0) {
          for (int i = 0; i < amount; i++) {
            updatedItem.currentEpisode++;
            if (updatedItem.currentEpisode > updatedItem.totalEpisodes) {
              if (updatedItem.currentSeason < updatedItem.totalSeasons) {
                updatedItem.currentSeason++;
                updatedItem.currentEpisode = 1;
              } else {
                updatedItem.currentEpisode = updatedItem.totalEpisodes;
                updatedItem.isCompleted = true;
                break;
              }
            }
          }
          if (updatedItem.currentSeason >= updatedItem.totalSeasons &&
              updatedItem.currentEpisode >= updatedItem.totalEpisodes) {
            updatedItem.isCompleted = true;
          }
        }
        break;
      case MediaType.livro:
      case MediaType.webtoon:
        if (updatedItem.totalPages > 0) {
          updatedItem.currentPage = (updatedItem.currentPage + amount).clamp(1, updatedItem.totalPages);
          if (updatedItem.currentPage >= updatedItem.totalPages) {
            updatedItem.isCompleted = true;
          }
        }
        break;
      case MediaType.podcast:
        if (updatedItem.totalEpisodes > 0) {
          updatedItem.currentEpisode = (updatedItem.currentEpisode + amount).clamp(1, updatedItem.totalEpisodes);
          if (updatedItem.currentEpisode >= updatedItem.totalEpisodes) {
            updatedItem.isCompleted = true;
          }
        }
        break;
      case MediaType.filme:
      case MediaType.jogo:
        updatedItem.isCompleted = true;
        break;
    }

    await MediaService.updateItem(updatedItem);
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _decrementProgress({int amount = 1}) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) return;

    updatedItem.isCompleted = false;

    switch (widget.item.type) {
      case MediaType.serie:
      case MediaType.anime:
        for (int i = 0; i < amount; i++) {
          updatedItem.currentEpisode--;
          if (updatedItem.currentEpisode < 1) {
            updatedItem.currentSeason--;
            if (updatedItem.currentSeason < 1) {
              updatedItem.currentSeason = 1;
              updatedItem.currentEpisode = 1;
              break;
            } else {
              updatedItem.currentEpisode = updatedItem.totalEpisodes;
            }
          }
        }
        break;
      case MediaType.livro:
      case MediaType.webtoon:
        updatedItem.currentPage = (updatedItem.currentPage - amount).clamp(1, updatedItem.totalPages);
        break;
      case MediaType.podcast:
        updatedItem.currentEpisode = (updatedItem.currentEpisode - amount).clamp(1, updatedItem.totalEpisodes);
        break;
      case MediaType.filme:
      case MediaType.jogo:
        updatedItem.isCompleted = false;
        break;
    }

    await MediaService.updateItem(updatedItem);
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Não mostrar controles para filmes/jogos completos ou itens sem progresso
    if ((widget.item.type == MediaType.filme || widget.item.type == MediaType.jogo) &&
        widget.item.isCompleted) {
      return const SizedBox.shrink();
    }

    if (_isUpdating) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (widget.item.type == MediaType.filme || widget.item.type == MediaType.jogo) {
      return IconButton(
        icon: const Icon(Icons.check_circle_outline),
        onPressed: _incrementProgress,
        tooltip: 'Marcar como completo',
        color: Colors.green,
      );
    }

    return Wrap(
      spacing: 4,
      alignment: WrapAlignment.end,
      children: [
        _buildQuickButton(
          label: '-10',
          onPressed: widget.item.progress > 0 && !_isUpdating 
              ? () => _decrementProgress(amount: 10) 
              : null,
          color: Colors.red[400]!,
        ),
        _buildQuickButton(
          label: '-5',
          onPressed: widget.item.progress > 0 && !_isUpdating 
              ? () => _decrementProgress(amount: 5) 
              : null,
          color: Colors.red[400]!,
        ),
        _buildQuickButton(
          label: '-1',
          onPressed: widget.item.progress > 0 && !_isUpdating 
              ? () => _decrementProgress(amount: 1) 
              : null,
          color: Colors.red[400]!,
        ),
        _buildQuickButton(
          label: '+1',
          onPressed: widget.item.progress < 1.0 && !_isUpdating 
              ? () => _incrementProgress(amount: 1) 
              : null,
          color: Colors.green[600]!,
        ),
        _buildQuickButton(
          label: '+5',
          onPressed: widget.item.progress < 1.0 && !_isUpdating 
              ? () => _incrementProgress(amount: 5) 
              : null,
          color: Colors.green[600]!,
        ),
        _buildQuickButton(
          label: '+10',
          onPressed: widget.item.progress < 1.0 && !_isUpdating 
              ? () => _incrementProgress(amount: 10) 
              : null,
          color: Colors.green[600]!,
        ),
      ],
    );
  }

  Widget _buildQuickButton({
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: onPressed != null ? color.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: onPressed != null ? color.withOpacity(0.3) : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onPressed != null ? color : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebtoonTotalControls extends StatefulWidget {
  final MediaItem item;

  const _WebtoonTotalControls({required this.item});

  @override
  State<_WebtoonTotalControls> createState() => _WebtoonTotalControlsState();
}

class _WebtoonTotalControlsState extends State<_WebtoonTotalControls> {
  bool _isUpdating = false;

  Future<void> _adjustTotalPages(int delta) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) return;

    updatedItem.totalPages = (updatedItem.totalPages + delta).clamp(1, 9999);
    // Ajusta currentPage se necessário
    if (updatedItem.currentPage > updatedItem.totalPages) {
      updatedItem.currentPage = updatedItem.totalPages;
    }
    if (updatedItem.currentPage >= updatedItem.totalPages) {
      updatedItem.isCompleted = true;
    } else {
      updatedItem.isCompleted = false;
    }

    await MediaService.updateItem(updatedItem);
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUpdating) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _adjustTotalPages(-1),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[300]!, width: 1),
              ),
              child: Text(
                'Total -1',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _adjustTotalPages(1),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[300]!, width: 1),
              ),
              child: Text(
                'Total +1',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
