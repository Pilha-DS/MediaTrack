// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaTypeAdapter extends TypeAdapter<MediaType> {
  @override
  final int typeId = 0;

  @override
  MediaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MediaType.serie;
      case 1:
        return MediaType.filme;
      case 2:
        return MediaType.livro;
      case 3:
        return MediaType.jogo;
      case 4:
        return MediaType.podcast;
      case 5:
        return MediaType.anime;
      case 6:
        return MediaType.webtoon;
      default:
        return MediaType.serie;
    }
  }

  @override
  void write(BinaryWriter writer, MediaType obj) {
    switch (obj) {
      case MediaType.serie:
        writer.writeByte(0);
        break;
      case MediaType.filme:
        writer.writeByte(1);
        break;
      case MediaType.livro:
        writer.writeByte(2);
        break;
      case MediaType.jogo:
        writer.writeByte(3);
        break;
      case MediaType.podcast:
        writer.writeByte(4);
        break;
      case MediaType.anime:
        writer.writeByte(5);
        break;
      case MediaType.webtoon:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaItemAdapter extends TypeAdapter<MediaItem> {
  @override
  final int typeId = 1;

  @override
  MediaItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaItem(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as MediaType,
      currentSeason: fields[3] as int,
      currentEpisode: fields[4] as int,
      totalSeasons: fields[5] as int,
      totalEpisodes: fields[6] as int,
      currentChapter: fields[7] as int,
      totalChapters: fields[8] as int,
      currentPage: fields[9] as int,
      totalPages: fields[10] as int,
      rating: fields[11] as double,
      notes: fields[12] as String,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      isCompleted: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MediaItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.currentSeason)
      ..writeByte(4)
      ..write(obj.currentEpisode)
      ..writeByte(5)
      ..write(obj.totalSeasons)
      ..writeByte(6)
      ..write(obj.totalEpisodes)
      ..writeByte(7)
      ..write(obj.currentChapter)
      ..writeByte(8)
      ..write(obj.totalChapters)
      ..writeByte(9)
      ..write(obj.currentPage)
      ..writeByte(10)
      ..write(obj.totalPages)
      ..writeByte(11)
      ..write(obj.rating)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
