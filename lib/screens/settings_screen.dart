import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/quick_url.dart';
import '../models/app_settings.dart';
import 'webview_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box<QuickUrl> _quickUrlsBox;
  late Box<AppSettings> _settingsBox;

  @override
  void initState() {
    super.initState();
    _quickUrlsBox = Hive.box<QuickUrl>('quickUrls');
    _settingsBox = Hive.box<AppSettings>('appSettings');
  }

  Future<void> _addQuickUrl() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Adicionar URL Rápida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex: Webtoons',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://exemplo.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  urlController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty && 
        urlController.text.isNotEmpty) {
      final quickUrl = QuickUrl(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        url: urlController.text,
        createdAt: DateTime.now(),
      );
      await _quickUrlsBox.put(quickUrl.id, quickUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL rápida adicionada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _editQuickUrl(QuickUrl quickUrl) async {
    final nameController = TextEditingController(text: quickUrl.name);
    final urlController = TextEditingController(text: quickUrl.url);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Editar URL Rápida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  urlController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty && 
        urlController.text.isNotEmpty) {
      quickUrl.name = nameController.text;
      quickUrl.url = urlController.text;
      await quickUrl.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL rápida atualizada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteQuickUrl(QuickUrl quickUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${quickUrl.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await quickUrl.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL rápida excluída'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openQuickUrl(QuickUrl quickUrl, {bool external = false}) async {
    final uri = Uri.tryParse(quickUrl.url);
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

    if (external) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.settings),
                  text: 'Geral',
                ),
                Tab(
                  icon: Icon(Icons.star_border),
                  text: 'URLs Rápidas',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Aba de Configurações Gerais
                  ValueListenableBuilder<Box<AppSettings>>(
                    valueListenable: _settingsBox.listenable(),
                    builder: (context, box, _) {
                      final settings = box.get('settings') ?? AppSettings();
                      
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Seção de Aparência
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.palette,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Aparência',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                // Modo de Tema
                                ListTile(
                                  leading: const Icon(Icons.brightness_6),
                                  title: const Text('Modo de Tema'),
                                  subtitle: Text(
                                    settings.themeMode == 'system'
                                        ? 'Seguir sistema'
                                        : settings.themeMode == 'light'
                                            ? 'Claro'
                                            : 'Escuro',
                                  ),
                                  trailing: DropdownButton<String>(
                                    value: settings.themeMode,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'system',
                                        child: Text('Seguir sistema'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'light',
                                        child: Text('Claro'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'dark',
                                        child: Text('Escuro'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        settings.themeMode = value;
                                        settings.save();
                                        // Recarregar o app para aplicar o tema
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                ),
                                // Material 3
                                SwitchListTile(
                                  secondary: const Icon(Icons.auto_awesome),
                                  title: const Text('Material Design 3'),
                                  subtitle: const Text('Usar design Material 3'),
                                  value: settings.useMaterial3,
                                  onChanged: (value) {
                                    settings.useMaterial3 = value;
                                    settings.save();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Seção de Informações
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Informações',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.apps),
                                  title: const Text('Versão do App'),
                                  subtitle: const Text('1.0.0'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.storage),
                                  title: const Text('Armazenamento'),
                                  subtitle: Text(
                                    '${_quickUrlsBox.length} URLs rápidas',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // Aba de URLs Rápidas
                  ValueListenableBuilder<Box<QuickUrl>>(
                    valueListenable: _quickUrlsBox.listenable(),
                    builder: (context, box, _) {
                      final quickUrls = box.values.toList()
                        ..sort((a, b) => a.name.compareTo(b.name));

                      if (quickUrls.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.link_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma URL rápida',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Adicione URLs para acesso rápido',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: quickUrls.length,
                        itemBuilder: (context, index) {
                          final quickUrl = quickUrls[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.link,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                quickUrl.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                quickUrl.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.open_in_browser),
                                    onPressed: () => _openQuickUrl(quickUrl),
                                    tooltip: 'Abrir',
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editQuickUrl(quickUrl);
                                      } else if (value == 'external') {
                                        _openQuickUrl(quickUrl, external: true);
                                      } else if (value == 'delete') {
                                        _deleteQuickUrl(quickUrl);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'external',
                                        child: Row(
                                          children: [
                                            Icon(Icons.launch, size: 20),
                                            SizedBox(width: 8),
                                            Text('Abrir externo'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Excluir', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () => _openQuickUrl(quickUrl),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuickUrl,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar URL'),
      ),
    );
  }
}
