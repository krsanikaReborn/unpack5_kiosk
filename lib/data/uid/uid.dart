import 'package:freezed_annotation/freezed_annotation.dart';

part 'uid.freezed.dart';
part 'uid.g.dart';

@freezed
class Uid with _$Uid {
  factory Uid({required String uid, @Default('') String type}) = _Uid;

  factory Uid.fromJson(Map<String, dynamic> json) => _$UidFromJson(json);
}
