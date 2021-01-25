// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProblemAdapter extends TypeAdapter<Problem> {
  @override
  final int typeId = 0;

  @override
  Problem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Problem(
      strId: fields[0] as String,
      name: fields[1] as String,
      holdsType: fields[2] as int,
      holdsSetup: fields[3] as int,
      author: fields[4] as String,
      grade: fields[5] as int,
      holds: fields[6] as String,
      dateTime: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Problem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.strId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.holdsType)
      ..writeByte(3)
      ..write(obj.holdsSetup)
      ..writeByte(4)
      ..write(obj.author)
      ..writeByte(5)
      ..write(obj.grade)
      ..writeByte(6)
      ..write(obj.holds)
      ..writeByte(7)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProblemAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
