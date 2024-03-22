import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket_error.freezed.dart';
part 'websocket_error.g.dart';

@freezed
class WebsocketError with _$WebsocketError {
  factory WebsocketError({required String code}) = _WebsocketError;

  factory WebsocketError.fromJson(Map<String, dynamic> json) =>
      _$WebsocketErrorFromJson(json);
}
