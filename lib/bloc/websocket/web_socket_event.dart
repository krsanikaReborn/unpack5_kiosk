part of 'web_socket_bloc.dart';

@freezed
class WebSocketEvent with _$WebSocketEvent {
  const factory WebSocketEvent.startShooting(
      String barcode, KindZoneType kindZone) = _StartShooting;

  const factory WebSocketEvent.onShotPhoto(
      String barcode, KindZoneType kindZone) = _ShotPhoto;

  const factory WebSocketEvent.endShot(String barcode) = _EndShot;
  const factory WebSocketEvent.saveShot(String barcode) = _SaveShot;

  const factory WebSocketEvent.socketChange(KindZoneType kindZone) =
      _SocketChange;

  const factory WebSocketEvent.offEvent() = _OffEvent;

  const factory WebSocketEvent.highRowIndicator(
      {required String type,
      required String indicatorType}) = _HighRowIndicator;

  const factory WebSocketEvent.updateState({required WebsocketError? error}) =
      _UpdateState;
}
