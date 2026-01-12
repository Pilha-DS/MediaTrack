import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/search_history.dart';
import 'add_edit_media_screen.dart';

class WebViewScreen extends StatefulWidget {
  final String? url;
  final String title;

  const WebViewScreen({
    super.key,
    this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _showHomePage = true;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late Box<SearchHistory> _searchHistoryBox;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _searchHistoryBox = Hive.box<SearchHistory>('searchHistory');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) async {
            final currentUrl = await _controller.currentUrl();
            setState(() {
              _isLoading = false;
              _showHomePage = false;
              _currentUrl = currentUrl ?? url;
            });
          },
        ),
      );
    
    if (widget.url != null && widget.url!.isNotEmpty) {
      _loadUrl(widget.url!);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadUrl(String url, {bool isSearch = false}) {
    String finalUrl = url.trim();
    String originalQuery = url.trim();
    
    // Se não começar com http:// ou https://, trata como busca do Google
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      // Se contém espaços ou não parece uma URL, faz busca no Google
      if (finalUrl.contains(' ') || !finalUrl.contains('.')) {
        finalUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(finalUrl)}';
        
        // Salva no histórico de buscas
        _saveSearchHistory(originalQuery);
      } else {
        // Adiciona https:// se parecer uma URL
        finalUrl = 'https://$finalUrl';
      }
    }
    
    setState(() {
      _showHomePage = false;
      _isLoading = true;
    });
    
    _controller.loadRequest(Uri.parse(finalUrl));
  }

  void _saveSearchHistory(String query) {
    // Remove buscas duplicadas recentes
    final existing = _searchHistoryBox.values
        .where((h) => h.query.toLowerCase() == query.toLowerCase())
        .toList();
    for (var item in existing) {
      item.delete();
    }
    
    // Adiciona nova busca
    final history = SearchHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      query: query,
      searchedAt: DateTime.now(),
    );
    _searchHistoryBox.put(history.id, history);
    
    // Mantém apenas as últimas 10 buscas
    final allHistory = _searchHistoryBox.values.toList()
      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    if (allHistory.length > 10) {
      for (var item in allHistory.sublist(10)) {
        item.delete();
      }
    }
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _loadUrl(query, isSearch: true);
    }
  }

  void _handleUrl() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      _loadUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showHomePage && widget.url == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navegador'),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                setState(() {
                  _showHomePage = true;
                  _urlController.clear();
                  _searchController.clear();
                });
              },
              tooltip: 'Início',
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo estilo Google
                Text(
                  'MediaTrack',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 48),
                // Barra de busca
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      return TextField(
                        controller: _searchController,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Buscar na web ou digite uma URL',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: _handleSearch,
                                ),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _handleSearch(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Botões de ação rápida
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _handleSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar no Google'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Digite uma URL'),
                            content: TextField(
                              controller: _urlController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: 'URL',
                                hintText: 'https://exemplo.com',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.link),
                              ),
                              keyboardType: TextInputType.url,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleUrl();
                                },
                                child: const Text('Abrir'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Abrir URL'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                // Histórico de buscas
                ValueListenableBuilder<Box<SearchHistory>>(
                  valueListenable: _searchHistoryBox.listenable(),
                  builder: (context, box, _) {
                    final recentSearches = box.values.toList()
                      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
                    
                    if (recentSearches.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Buscas Recentes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Column(
                              children: recentSearches.take(5).map((history) {
                                return ListTile(
                                  key: ValueKey('search_history_${history.id}'),
                                  leading: Icon(
                                    Icons.history,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  title: Text(history.query),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      history.delete();
                                    },
                                  ),
                                  onTap: () {
                                    _searchController.text = history.query;
                                    _handleSearch();
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: TextEditingController(text: widget.url ?? ''),
          decoration: InputDecoration(
            hintText: 'Buscar ou digite URL',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            isDense: true,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onSubmitted: (value) {
            _loadUrl(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              setState(() {
                _showHomePage = true;
                _urlController.clear();
                _searchController.clear();
              });
            },
            tooltip: 'Início',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              }
            },
            tooltip: 'Voltar',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                await _controller.goForward();
              }
            },
            tooltip: 'Avançar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
            tooltip: 'Recarregar',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              final currentUrl = await _controller.currentUrl();
              final url = currentUrl ?? _currentUrl;
              
              if (value == 'copy') {
                if (url.isNotEmpty) {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL copiada para a área de transferência'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              } else if (value == 'create') {
                if (url.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditMediaScreen(
                        initialUrl: url,
                      ),
                    ),
                  );
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nenhuma URL disponível'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              } else if (value == 'external') {
                if (url.isNotEmpty) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 12),
                    Text('Copiar URL'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'create',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Criar conteúdo com URL'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'external',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser, size: 20),
                    SizedBox(width: 12),
                    Text('Abrir no navegador externo'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
