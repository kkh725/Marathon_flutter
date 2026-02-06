// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marathon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarathonAdapter extends TypeAdapter<Marathon> {
  @override
  final typeId = 0;

  @override
  Marathon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Marathon(
      id: fields[0] as String,
      name: fields[1] as String,
      location: fields[2] as String,
      date: fields[3] as DateTime,
      regDate: fields[4] as String,
      distance: (fields[5] as List).cast<String>(),
      entryMethod: fields[6] as EntryMethod,
      difficulty: fields[7] as Difficulty,
      suitability: (fields[8] as num).toInt(),
      accessibility: fields[9] as String,
      jetLag: fields[10] as String,
      accommodation: fields[11] as String,
      image: fields[12] as String,
      tags: (fields[13] as List).cast<String>(),
      recommendationReason: fields[14] as String?,
      visaInfo: fields[15] as String,
      officialUrl: fields[16] as String,
      price: fields[17] as String? ?? '',
      countryCode: fields[18] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Marathon obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.regDate)
      ..writeByte(5)
      ..write(obj.distance)
      ..writeByte(6)
      ..write(obj.entryMethod)
      ..writeByte(7)
      ..write(obj.difficulty)
      ..writeByte(8)
      ..write(obj.suitability)
      ..writeByte(9)
      ..write(obj.accessibility)
      ..writeByte(10)
      ..write(obj.jetLag)
      ..writeByte(11)
      ..write(obj.accommodation)
      ..writeByte(12)
      ..write(obj.image)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.recommendationReason)
      ..writeByte(15)
      ..write(obj.visaInfo)
      ..writeByte(16)
      ..write(obj.officialUrl)
      ..writeByte(17)
      ..write(obj.price)
      ..writeByte(18)
      ..write(obj.countryCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarathonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EntryMethodAdapter extends TypeAdapter<EntryMethod> {
  @override
  final typeId = 1;

  @override
  EntryMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EntryMethod.lottery;
      case 1:
        return EntryMethod.firstCome;
      case 2:
        return EntryMethod.qualifying;
      default:
        return EntryMethod.lottery;
    }
  }

  @override
  void write(BinaryWriter writer, EntryMethod obj) {
    switch (obj) {
      case EntryMethod.lottery:
        writer.writeByte(0);
      case EntryMethod.firstCome:
        writer.writeByte(1);
      case EntryMethod.qualifying:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyAdapter extends TypeAdapter<Difficulty> {
  @override
  final typeId = 2;

  @override
  Difficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Difficulty.beginner;
      case 1:
        return Difficulty.intermediate;
      case 2:
        return Difficulty.advanced;
      case 3:
        return Difficulty.extreme;
      default:
        return Difficulty.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, Difficulty obj) {
    switch (obj) {
      case Difficulty.beginner:
        writer.writeByte(0);
      case Difficulty.intermediate:
        writer.writeByte(1);
      case Difficulty.advanced:
        writer.writeByte(2);
      case Difficulty.extreme:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
