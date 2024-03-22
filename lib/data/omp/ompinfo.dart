import 'package:freezed_annotation/freezed_annotation.dart';

part 'ompinfo.freezed.dart';
part 'ompinfo.g.dart';

@freezed
class OMPInfo with _$OMPInfo {
  factory OMPInfo({required String uid, required List<String> urls}) = _OMPInfo;

  factory OMPInfo.fromJson(Map<String, dynamic> json) =>
      _$OMPInfoFromJson(json);
}
