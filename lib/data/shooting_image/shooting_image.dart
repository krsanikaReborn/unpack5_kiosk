import 'package:freezed_annotation/freezed_annotation.dart';

part 'shooting_image.freezed.dart';
part 'shooting_image.g.dart';

@freezed
class ShootingImage with _$ShootingImage {
  factory ShootingImage(
      {required String uid,
      required String image,
      @Default('') String type}) = _ShootingImage;

  factory ShootingImage.fromJson(Map<String, dynamic> json) =>
      _$ShootingImageFromJson(json);
}
