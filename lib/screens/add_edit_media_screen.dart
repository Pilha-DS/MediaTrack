import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/media_item.dart';
import '../services/media_service.dart';

class AddEditMediaScreen extends StatefulWidget {
  final MediaItem? item;

  const AddEditMediaScreen({super.key, this.item});

  @override
  State<AddEditMediaScreen> createState() => _AddEditMediaScreenState();
}

class _AddEditMediaScreenState extends State<AddEditMediaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late MediaType _selectedType;
  late int _currentSeason;
  late int _currentEpisode;
  late int _totalSeasons;
  late int _totalEpisodes;
  late int _currentChapter;
  late int _totalChapters;
  late int _currentPage;
  late int _totalPages;
  late double _rating;
  late TextEditingController _notesController;
  late bool _isCompleted;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final item = widget.item!;
      _titleController = TextEditingController(text: item.title);
      _selectedType = item.type;
      _currentSeason = item.currentSeason;
      _currentEpisode = item.currentEpisode;
      _totalSeasons = item.totalSeasons;
      _totalEpisodes = item.totalEpisodes;
      _currentChapter = item.currentChapter;
      _totalChapters = item.totalChapters;
      _currentPage = item.currentPage;
      _totalPages = item.totalPages;
      _rating = item.rating;
      _notesController = TextEditingController(text: item.notes);
      _isCompleted = item.isCompleted;
    } else {
      _titleController = TextEditingController();
      _selectedType = MediaType.serie;
      _currentSeason = 0;
      _currentEpisode = 0;
      _totalSeasons = 0;
      _totalEpisodes = 0;
      _currentChapter = 0;
      _totalChapters = 0;
      _currentPage = 0;
      _totalPages = 0;
      _rating = 0.0;
      _notesController = TextEditingController();
      _isCompleted = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = isEditing
        ? widget.item!
        : MediaItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text,
            type: _selectedType,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    item.title = _titleController.text;
    item.type = _selectedType;
    item.currentSeason = _currentSeason;
    item.currentEpisode = _currentEpisode;
    item.totalSeasons = _totalSeasons;
    item.totalEpisodes = _totalEpisodes;
    item.currentChapter = _currentChapter;
    item.totalChapters = _totalChapters;
    item.currentPage = _currentPage;
    item.totalPages = _totalPages;
    item.rating = _rating;
    item.notes = _notesController.text;
    item.isCompleted = _isCompleted;
    item.updatedAt = DateTime.now();

    if (isEditing) {
      await MediaService.updateItem(item);
    } else {
      await MediaService.addItem(item);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Item' : 'Adicionar Item'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: _save,
              icon: const Icon(Icons.save),
              tooltip: 'Salvar',
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MediaType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: MediaType.values.map((type) {
                final tempItem = MediaItem(
                  id: '',
                  title: '',
                  type: type,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                return DropdownMenuItem(
                  value: type,
                  child: Text(tempItem.typeName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            _buildTypeSpecificFields(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Avaliação: ${_rating.toStringAsFixed(1)}'),
                ),
                Expanded(
                  flex: 3,
                  child: Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 50,
                    label: _rating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Completo'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(
                  isEditing ? 'Salvar Alterações' : 'Salvar Item',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case MediaType.serie:
      case MediaType.anime:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _currentSeason.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Temporada Atual',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      _currentSeason = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _totalSeasons.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Total Temporadas',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      _totalSeasons = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _currentEpisode.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Episódio Atual',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      _currentEpisode = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _totalEpisodes.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Total Episódios',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      _totalEpisodes = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      case MediaType.livro:
      case MediaType.webtoon:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _currentPage.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Página Atual',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      _currentPage = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _totalPages.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Total Páginas',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      _totalPages = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      case MediaType.podcast:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _currentEpisode.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Episódio Atual',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      _currentEpisode = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _totalEpisodes.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Total Episódios',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      _totalEpisodes = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      case MediaType.filme:
      case MediaType.jogo:
        return const SizedBox.shrink();
    }
  }
}
