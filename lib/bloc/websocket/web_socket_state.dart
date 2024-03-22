part of 'web_socket_bloc.dart';

@freezed
class WebSocketState with _$WebSocketState {
  const factory WebSocketState({WebsocketError? error, DateTime? dateTime}) =
      _WebSocketState;
}
