import 'package:freezed_annotation/freezed_annotation.dart';

part 'kiosk_indicator.freezed.dart';
part 'kiosk_indicator.g.dart';

@freezed
class KioskIndicator with _$KioskIndicator {
  factory KioskIndicator(
      {required String type, required String indicatorType}) = _KioskIndicator;

  factory KioskIndicator.fromJson(Map<String, dynamic> json) =>
      _$KioskIndicatorFromJson(json);
}
