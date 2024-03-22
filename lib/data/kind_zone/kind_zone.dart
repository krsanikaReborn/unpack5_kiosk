import 'package:freezed_annotation/freezed_annotation.dart';

part 'kind_zone.freezed.dart';
part 'kind_zone.g.dart';

@freezed
class KindZone with _$KindZone {
  factory KindZone({required String zone}) = _KindZone;

  factory KindZone.fromJson(Map<String, dynamic> json) =>
      _$KindZoneFromJson(json);
}
