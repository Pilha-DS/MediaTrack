import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/media_item.dart';
import '../models/quick_url.dart';
import '../services/media_service.dart';
import 'media_detail_screen.dart';
import 'add_edit_media_screen.dart';
import 'webview_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MediaType? _selectedFilter;
  bool _showCompleted = false;
  bool _showDropped = false;
  bool _showNotStarted = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showQuickUrlsMenu(BuildContext context, List<QuickUrl> quickUrls) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.link,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'URLs Rápidas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (quickUrls.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.link_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma URL rápida',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: const Text('Adicionar URLs'),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: quickUrls.length,
                  itemBuilder: (context, index) {
                    final quickUrl = quickUrls[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.link,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(quickUrl.name),
                      subtitle: Text(
                        quickUrl.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_browser),
                        onPressed: () {
                          Navigator.pop(context);
                          final uri = Uri.tryParse(quickUrl.url);
                          if (uri != null && uri.hasScheme) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  url: quickUrl.url,
                                  title: quickUrl.name,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        final uri = Uri.tryParse(quickUrl.url);
                        if (uri != null && uri.hasScheme) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewScreen(
                                url: quickUrl.url,
                                title: quickUrl.name,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Gerenciar URLs'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.white),
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                strutStyle: const StrutStyle(forceStrutHeight: true),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _showSearch = false;
                      });
                      _scrollToTop();
                    },
                  ),
                ),
                cursorColor: Colors.white,
                cursorWidth: 2.0,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {});
                  _scrollToTop();
                },
              )
            : ValueListenableBuilder<Box<QuickUrl>>(
                valueListenable: Hive.box<QuickUrl>('quickUrls').listenable(),
                builder: (context, box, _) {
                  final quickUrls = box.values.toList()
                    ..sort((a, b) => a.name.compareTo(b.name));
                  
                  return PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[800] 
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.menu,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[300] 
                            : Colors.grey[700],
                        size: 20,
                      ),
                    ),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) async {
                      if (value == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      } else if (value == 'browser') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WebViewScreen(
                              url: null,
                              title: 'Navegador',
                            ),
                          ),
                        );
                      } else if (value.startsWith('url_')) {
                        final urlId = value.substring(4);
                        final quickUrl = box.get(urlId);
                        if (quickUrl != null) {
                          final uri = Uri.tryParse(quickUrl.url);
                          if (uri != null && uri.hasScheme) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  url: quickUrl.url,
                                  title: quickUrl.name,
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (context) {
                      final items = <PopupMenuEntry<String>>[];
                      
                      // URLs rápidas
                      if (quickUrls.isNotEmpty) {
                        items.add(
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                'URLs Rápidas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                        
                        for (final quickUrl in quickUrls) {
                          items.add(
                            PopupMenuItem<String>(
                              value: 'url_${quickUrl.id}',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          quickUrl.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          quickUrl.url,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        items.add(const PopupMenuDivider());
                      }
                      
                      // Navegador Integrado
                      items.add(
                        PopupMenuItem<String>(
                          value: 'browser',
                          child: Row(
                            children: [
                              Icon(
                                Icons.web,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text('Navegador Integrado'),
                            ],
                          ),
                        ),
                      );
                      
                      // Configurações
                      items.add(
                        PopupMenuItem<String>(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text('Configurações'),
                            ],
                          ),
                        ),
                      );
                      
                      return items;
                    },
                  );
                },
              ),
        elevation: 0,
        actions: [
          if (!_showSearch) ...[
            IconButton(
              icon: Icon(
                _showCompleted ? Icons.check_circle : Icons.check_circle_outline,
              ),
              color: _showCompleted ? Colors.green : null,
              onPressed: () {
                setState(() {
                  if (_showCompleted) {
                    // Se já está mostrando concluídos, volta para padrões
                    _showCompleted = false;
                  } else {
                    // Mostra concluídos e esconde outros filtros
                    _showCompleted = true;
                    _showDropped = false;
                    _showNotStarted = false;
                  }
                });
                _scrollToTop();
              },
              tooltip: _showCompleted ? 'Ocultar concluídos' : 'Mostrar concluídos',
            ),
            IconButton(
              icon: Icon(
                _showDropped ? Icons.cancel : Icons.cancel_outlined,
              ),
              color: _showDropped ? Colors.red : null,
              onPressed: () {
                setState(() {
                  if (_showDropped) {
                    // Se já está mostrando dropados, volta para padrões
                    _showDropped = false;
                  } else {
                    // Mostra dropados e esconde outros filtros
                    _showDropped = true;
                    _showCompleted = false;
                    _showNotStarted = false;
                  }
                });
                _scrollToTop();
              },
              tooltip: _showDropped ? 'Ocultar dropados' : 'Mostrar dropados',
            ),
            IconButton(
              icon: Icon(
                _showNotStarted ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              ),
              color: _showNotStarted ? Colors.grey : null,
              onPressed: () {
                setState(() {
                  if (_showNotStarted) {
                    // Se já está mostrando não iniciados, volta para padrões
                    _showNotStarted = false;
                  } else {
                    // Mostra não iniciados e esconde outros filtros
                    _showNotStarted = true;
                    _showCompleted = false;
                    _showDropped = false;
                  }
                });
                _scrollToTop();
              },
              tooltip: _showNotStarted ? 'Ocultar não iniciados' : 'Mostrar não iniciados',
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
                _scrollToTop();
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
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                }
              });
              _scrollToTop();
            },
            tooltip: _showSearch ? 'Fechar busca' : 'Buscar',
          ),
          IconButton(
            icon: const Icon(Icons.web),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebViewScreen(
                    url: null,
                    title: 'Navegador',
                  ),
                ),
              );
            },
            tooltip: 'Navegador Integrado',
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<MediaItem>>(
        valueListenable: MediaService.box.listenable(),
        builder: (context, box, _) {
          var allItems = _selectedFilter == null
              ? MediaService.getAllItems()
              : MediaService.getItemsByType(_selectedFilter);

          // Filtrar por nome (case-insensitive)
          if (_searchController.text.isNotEmpty) {
            final searchQuery = _searchController.text.toLowerCase();
            allItems = allItems.where((item) {
              return item.title.toLowerCase().contains(searchQuery);
            }).toList();
          }

          // Ordenar itens baseado no estado de visualização (colocar os solicitados primeiro)
          var items = List<MediaItem>.from(allItems);
          
          if (_showNotStarted) {
            // Reorganizar: não iniciados primeiro, mas favoritos ainda primeiro
            items.sort((a, b) {
              // Favoritos sempre primeiro
              if (a.isFavorite && !b.isFavorite) return -1;
              if (!a.isFavorite && b.isFavorite) return 1;
              // Depois não iniciados
              final aIsNotStarted = a.status == MediaStatus.naoIniciado;
              final bIsNotStarted = b.status == MediaStatus.naoIniciado;
              if (aIsNotStarted && !bIsNotStarted) return -1;
              if (!aIsNotStarted && bIsNotStarted) return 1;
              return 0;
            });
          } else if (_showCompleted && !_showDropped) {
            // Reorganizar: concluídos primeiro, mas favoritos ainda primeiro
            items.sort((a, b) {
              // Favoritos sempre primeiro
              if (a.isFavorite && !b.isFavorite) return -1;
              if (!a.isFavorite && b.isFavorite) return 1;
              // Depois concluídos
              final aIsCompleted = a.isCompleted || a.status == MediaStatus.concluido;
              final bIsCompleted = b.isCompleted || b.status == MediaStatus.concluido;
              if (aIsCompleted && !bIsCompleted) return -1;
              if (!aIsCompleted && bIsCompleted) return 1;
              return 0;
            });
          } else if (!_showCompleted && _showDropped) {
            // Reorganizar: dropados primeiro, mas favoritos ainda primeiro
            items.sort((a, b) {
              // Favoritos sempre primeiro
              if (a.isFavorite && !b.isFavorite) return -1;
              if (!a.isFavorite && b.isFavorite) return 1;
              // Depois dropados
              final aIsDropped = a.status == MediaStatus.dropado;
              final bIsDropped = b.status == MediaStatus.dropado;
              if (aIsDropped && !bIsDropped) return -1;
              if (!aIsDropped && bIsDropped) return 1;
              return 0;
            });
          } else if (!_showCompleted && !_showDropped && !_showNotStarted) {
            // Ordenação padrão: Favoritos primeiro, depois Lendo/Assistindo, Em espera, Relendo/Reassistindo, Não iniciado, Dropado/Pausado, Concluído
            items.sort((a, b) {
              // Favoritos sempre primeiro
              if (a.isFavorite && !b.isFavorite) return -1;
              if (!a.isFavorite && b.isFavorite) return 1;
              
              int getPriority(MediaItem item) {
                // Verificar se é relendo (livro/webtoon com status lendo mas wasCompleted)
                final isRelendo = (item.type == MediaType.livro || item.type == MediaType.webtoon) &&
                    item.status == MediaStatus.lendo &&
                    item.wasCompleted;
                
                // Verificar se é reassistindo (série/anime/filme/podcast com status assistindo mas wasCompleted)
                final isReassistindo = (item.type == MediaType.serie || 
                    item.type == MediaType.anime || 
                    item.type == MediaType.filme || 
                    item.type == MediaType.podcast) &&
                    item.status == MediaStatus.assistindo &&
                    item.wasCompleted;
                
                // Verificar se é lendo/assistindo normal (primeira vez)
                final isLendoAssistindoNormal = (item.status == MediaStatus.lendo || 
                    item.status == MediaStatus.assistindo) &&
                    !item.wasCompleted;
                
                if (isLendoAssistindoNormal) {
                  return 1; // Lendo/Assistindo - Primeiro
                } else if (item.status == MediaStatus.emEspera) {
                  return 2; // Em espera
                } else if (isRelendo || item.status == MediaStatus.reassistindo || isReassistindo) {
                  return 3; // Relendo/Reassistindo
                } else if (item.status == MediaStatus.naoIniciado) {
                  return 4; // Não iniciado
                } else if (item.status == MediaStatus.dropado || item.status == MediaStatus.pausado) {
                  return 5; // Dropado/Pausado
                } else if (item.status == MediaStatus.concluido || item.isCompleted) {
                  return 6; // Concluído - Último
                } else {
                  return 7; // Outros status
                }
              }
              
              final aPriority = getPriority(a);
              final bPriority = getPriority(b);
              
              return aPriority.compareTo(bPriority);
            });
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
                  controller: _scrollController,
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
      floatingActionButton: ValueListenableBuilder<Box<MediaItem>>(
        valueListenable: MediaService.box.listenable(),
        builder: (context, box, _) {
          final allItems = _selectedFilter == null
              ? MediaService.getAllItems()
              : MediaService.getItemsByType(_selectedFilter);
          final isEmpty = allItems.isEmpty;
          
          return ValueListenableBuilder<Box<QuickUrl>>(
            valueListenable: Hive.box<QuickUrl>('quickUrls').listenable(),
            builder: (context, quickUrlsBox, _) {
              final quickUrls = quickUrlsBox.values.toList();
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (quickUrls.isNotEmpty)
                    FloatingActionButton(
                      heroTag: 'quick_urls',
                      onPressed: () {
                        _showQuickUrlsMenu(context, quickUrls);
                      },
                      child: const Icon(Icons.link),
                      tooltip: 'URLs Rápidas',
                    ),
                  if (quickUrls.isNotEmpty) const SizedBox(width: 16),
                  FloatingActionButton.extended(
                    heroTag: 'add_item',
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
                    label: Text(isEmpty ? 'Adicionar Item' : 'Adicionar'),
                  ),
                ],
              );
            },
          );
        },
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

  Color _getColor(BuildContext context) {
    // Usa uma cor neutra baseada no tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[400]! : Colors.grey[700]!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = _getColor(context);
    final backgroundColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              backgroundColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cardColor,
                    cardColor.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cardColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
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

  Future<void> _showStatusDialog(BuildContext context, MediaItem item) async {
    final updatedItem = MediaService.getItem(item.id);
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
    }
  }

  bool _shouldShowCompleteButton() {
    // Sempre mostrar o botão de concluído para todos os tipos de mídia
    return true;
  }

  Future<void> _toggleCompleted() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) {
      setState(() => _isUpdating = false);
      return;
    }
    updatedItem.toggleCompleted();
    await MediaService.updateItem(updatedItem);
    if (mounted) {
      setState(() => _isUpdating = false);
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
            updatedItem.isCompleted = false;
          } else if (targetWatched >= totalAvailable) {
            updatedItem.currentSeason = updatedItem.totalSeasons;
            updatedItem.currentEpisode = updatedItem.totalEpisodes;
            // Não marca como concluído automaticamente - só quando apertar o botão
            updatedItem.isCompleted = false;
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
          // Não marca como concluído automaticamente - só quando apertar o botão
          updatedItem.isCompleted = false;
        }
        break;
      case MediaType.podcast:
        if (updatedItem.totalEpisodes > 0) {
          updatedItem.currentEpisode = (newProgress * updatedItem.totalEpisodes).round().clamp(1, updatedItem.totalEpisodes);
          // Não marca como concluído automaticamente - só quando apertar o botão
          updatedItem.isCompleted = false;
        }
        break;
      case MediaType.filme:
      case MediaType.jogo:
        // Não marca como concluído automaticamente - só quando apertar o botão
        updatedItem.isCompleted = false;
        break;
    }

    updatedItem.updateStatusAutomatically();
    await MediaService.updateItem(updatedItem);
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _toggleDropped() async {
    if (_isUpdating) return;
    
    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) return;

    // Se está dropado, apenas desdropar (sem confirmação)
    if (updatedItem.status == MediaStatus.dropado) {
      setState(() => _isUpdating = true);
      // Restaura o status anterior
      updatedItem.undrop();
      updatedItem.updatedAt = DateTime.now();
      await MediaService.updateItem(updatedItem);
      if (mounted) {
        setState(() => _isUpdating = false);
      }
      return;
    }

    // Se não está dropado, pedir confirmação antes de dropar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Drop'),
        content: Text(
          'Tem certeza que deseja dropar "${updatedItem.title}"?\n\n'
          'O item ficará oculto da lista principal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Dropar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUpdating = true);
      updatedItem.drop();
      updatedItem.updatedAt = DateTime.now();
      await MediaService.updateItem(updatedItem);
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _togglePaused() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) {
      setState(() => _isUpdating = false);
      return;
    }
    if (updatedItem.status == MediaStatus.pausado) {
      // Se está pausado, restaura o status anterior
      updatedItem.unpause();
    } else {
      // Se não está pausado, marca como pausado (salvando o status anterior)
      updatedItem.pause();
    }
    updatedItem.updatedAt = DateTime.now();
    await MediaService.updateItem(updatedItem);
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) {
      setState(() => _isUpdating = false);
      return;
    }
    updatedItem.isFavorite = !updatedItem.isFavorite;
    updatedItem.updatedAt = DateTime.now();
    await MediaService.updateItem(updatedItem);
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL inválida'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.open_in_browser,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Abrir Link',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Como deseja abrir o link?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, 'integrated'),
              icon: const Icon(Icons.web, size: 20),
              label: const Text('Navegador Integrado'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, 'external'),
              icon: const Icon(Icons.launch, size: 20),
              label: const Text('Navegador Externo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );

    if (choice == 'integrated') {
      // Abrir no navegador integrado
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: url, title: widget.item.title),
          ),
        );
      }
    } else if (choice == 'external') {
      // Abrir no navegador externo
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o link'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: widget.item.isFavorite ? 4 : 2,
      shadowColor: widget.item.isFavorite 
          ? Colors.amber.withOpacity(0.3)
          : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.item.isFavorite 
              ? Colors.amber
              : _getBorderColor(widget.item.type),
          width: widget.item.isFavorite ? 2.0 : 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (widget.item.isFavorite)
                            Icon(
                              Icons.star,
                              color: Colors.amber[600],
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
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
                          GestureDetector(
                            onTap: () => _showStatusDialog(context, widget.item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.item.statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: widget.item.statusColor.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: widget.item.statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.item.statusName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.item.statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.item.rating > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.item.type != MediaType.filme && widget.item.type != MediaType.jogo)
                      _TotalControls(item: widget.item),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.item.isFavorite ? Icons.star : Icons.star_border,
                            color: widget.item.isFavorite ? Colors.amber[600] : Colors.grey[700],
                          ),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _isUpdating ? null : _toggleFavorite,
                          tooltip: widget.item.isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                        ),
                        if (widget.item.isCompleted)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 24,
                          ),
                        if (widget.item.url != null && widget.item.url!.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.open_in_browser),
                            iconSize: 24,
                            color: Colors.blue[700],
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: _isUpdating ? null : () => _openUrl(widget.item.url!),
                            tooltip: 'Abrir link',
                          ),
                        ],
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          iconSize: 20,
                          color: Colors.grey[700],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MediaDetailScreen(item: widget.item),
                              ),
                            );
                          },
                          tooltip: 'Abrir detalhes',
                        ),
                      ],
                    ),
                  ],
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
              // Botões de ação rápida (Pausar, Dropar, Concluído)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  children: [
                    // Botão Pausar/Despausar
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 3,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: OutlinedButton.icon(
                          onPressed: _isUpdating ? null : _togglePaused,
                          icon: Icon(
                            widget.item.status == MediaStatus.pausado 
                                ? Icons.play_arrow 
                                : Icons.pause,
                            size: 18,
                            color: widget.item.status == MediaStatus.pausado 
                                ? Colors.orange 
                                : Colors.grey[700],
                          ),
                          label: Text(
                            widget.item.status == MediaStatus.pausado ? 'Pausado' : 'Pausar',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.item.status == MediaStatus.pausado 
                                  ? Colors.orange 
                                  : Colors.grey[700],
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: widget.item.status == MediaStatus.pausado 
                                  ? Colors.orange 
                                  : Colors.grey[400]!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botão Dropar/Desdropar
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 3,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: OutlinedButton.icon(
                          onPressed: _isUpdating ? null : _toggleDropped,
                          icon: Icon(
                            widget.item.status == MediaStatus.dropado 
                                ? Icons.undo 
                                : Icons.cancel_outlined,
                            size: 18,
                            color: widget.item.status == MediaStatus.dropado 
                                ? Colors.red 
                                : Colors.grey[700],
                          ),
                          label: Text(
                            widget.item.status == MediaStatus.dropado ? 'Dropado' : 'Dropar',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.item.status == MediaStatus.dropado 
                                  ? Colors.red 
                                  : Colors.grey[700],
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: widget.item.status == MediaStatus.dropado 
                                  ? Colors.red 
                                  : Colors.grey[400]!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Botão Concluído (só aparece quando chegou ao final)
                    if (_shouldShowCompleteButton()) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 3,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: OutlinedButton.icon(
                            onPressed: _isUpdating ? null : _toggleCompleted,
                            icon: Icon(
                              widget.item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 18,
                              color: widget.item.isCompleted ? Colors.green : Colors.grey[700],
                            ),
                            label: Text(
                              widget.item.isCompleted ? 'Concluído' : 'Concluir',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.item.isCompleted ? Colors.green : Colors.grey[700],
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(
                                color: widget.item.isCompleted ? Colors.green : Colors.grey[400]!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
                // Não marca como concluído automaticamente - só quando apertar o botão
                updatedItem.isCompleted = false;
                break;
              }
            }
          }
          // Não marca como concluído automaticamente - só quando apertar o botão
          updatedItem.isCompleted = false;
        }
        break;
      case MediaType.livro:
      case MediaType.webtoon:
        if (updatedItem.totalPages > 0) {
          updatedItem.currentPage = (updatedItem.currentPage + amount).clamp(1, updatedItem.totalPages);
          // Não marca como concluído automaticamente - só quando apertar o botão
          updatedItem.isCompleted = false;
        }
        break;
      case MediaType.podcast:
        if (updatedItem.totalEpisodes > 0) {
          updatedItem.currentEpisode = (updatedItem.currentEpisode + amount).clamp(1, updatedItem.totalEpisodes);
          // Não marca como concluído automaticamente - só quando apertar o botão
          updatedItem.isCompleted = false;
        }
        break;
      case MediaType.filme:
      case MediaType.jogo:
        // Não marca como concluído automaticamente - só quando apertar o botão
        updatedItem.isCompleted = false;
        break;
    }

    updatedItem.updateStatusAutomatically();
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

    updatedItem.updateStatusAutomatically();
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

class _TotalControls extends StatefulWidget {
  final MediaItem item;

  const _TotalControls({required this.item});

  @override
  State<_TotalControls> createState() => _TotalControlsState();
}

class _TotalControlsState extends State<_TotalControls> {
  bool _isUpdating = false;

  Future<void> _adjustTotal(int delta, {bool adjustSeasons = false}) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    final updatedItem = MediaService.getItem(widget.item.id);
    if (updatedItem == null) return;

    switch (updatedItem.type) {
      case MediaType.livro:
      case MediaType.webtoon:
        updatedItem.totalPages = (updatedItem.totalPages + delta).clamp(1, 9999);
        // Ajusta currentPage se necessário
        if (updatedItem.currentPage > updatedItem.totalPages) {
          updatedItem.currentPage = updatedItem.totalPages;
        }
        break;
      case MediaType.serie:
      case MediaType.anime:
        if (adjustSeasons) {
          updatedItem.totalSeasons = (updatedItem.totalSeasons + delta).clamp(1, 9999);
          // Ajusta currentSeason se necessário
          if (updatedItem.currentSeason > updatedItem.totalSeasons) {
            updatedItem.currentSeason = updatedItem.totalSeasons;
          }
        } else {
          updatedItem.totalEpisodes = (updatedItem.totalEpisodes + delta).clamp(1, 9999);
          // Ajusta currentEpisode se necessário
          if (updatedItem.currentEpisode > updatedItem.totalEpisodes) {
            updatedItem.currentEpisode = updatedItem.totalEpisodes;
          }
        }
        break;
      case MediaType.podcast:
        updatedItem.totalEpisodes = (updatedItem.totalEpisodes + delta).clamp(1, 9999);
        // Ajusta currentEpisode se necessário
        if (updatedItem.currentEpisode > updatedItem.totalEpisodes) {
          updatedItem.currentEpisode = updatedItem.totalEpisodes;
        }
        break;
      case MediaType.filme:
      case MediaType.jogo:
        // Não deve aparecer para filme e jogo
        break;
    }
    
    // Não marca como concluído automaticamente - só quando apertar o botão
    updatedItem.isCompleted = false;

    updatedItem.updateStatusAutomatically();
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

    final isSerieOrAnime = widget.item.type == MediaType.serie || widget.item.type == MediaType.anime;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botões para episódios/páginas
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _adjustTotal(-1),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[300]!, width: 1),
              ),
              child: Text(
                '-1',
                style: TextStyle(
                  fontSize: 12,
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
            onTap: () => _adjustTotal(1),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[300]!, width: 1),
              ),
              child: Text(
                '+1',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
        ),
        // Botões para temporadas (apenas séries e animes)
        if (isSerieOrAnime) ...[
          const SizedBox(width: 4),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _adjustTotal(-1, adjustSeasons: true),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.purple[300]!, width: 1),
                ),
                child: Text(
                  '-1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple[700],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _adjustTotal(1, adjustSeasons: true),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.purple[300]!, width: 1),
                ),
                child: Text(
                  '+1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple[700],
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }
}
