import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kiosk/data/kiosk_indicator/kiosk_indicator.dart';
import 'package:kiosk/data/websocket_error/websocket_error.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../core/defined_code.dart';
import '../../data/omp/ompinfo.dart';
import '../../data/shooting_image/shooting_image.dart';
import '../../data/uid/uid.dart';
import '../../injection_container.dart';
import '../services/services_bloc.dart';
import '../setting_manage/setting_manage_cubit.dart';

part 'web_socket_bloc.freezed.dart';
part 'web_socket_event.dart';
part 'web_socket_state.dart';

enum WebsocketEventKey {
  /// QR SKIP 테스트목적
  qrSkpEventKey('QR-SKIP'),

  /// 사용자 입장 - 준비완료
  kioskReadyEventKey('KIOSK-READY'),

  /// 촬영 시작
  kioskStartShootingEventKey('KIOSK-START-SHOOTING'),

  /// 촬영 완료
  kioskEndShootingEventKey('KIOSK-END-SHOOTING'),

  /// 전체 촬영 완료
  endShootingEventKey('KIOSK-END'),

  /// 촬영 결과 저장
  saveResultEventKey('KIOSK-SAVE-RESULT'),

  ///촬영 타임 알림 이벤트
  kioskStartIndicator('KIOSK-START-INDICATOR'),

  ///익명 사용자
  kioskOmpInfo('KIOSK-OMP-INFO'),

  ///에러 이벤트
  kioskError('KIOSK-ERROR'),

  /// 시스템 점검중 - 에러 발생
  errorEventKey('KIOSK-ERROR');

  const WebsocketEventKey(this.code);

  final String code;
}

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  WebSocketBloc() : super(const _WebSocketState()) {
    ///웹소켓 촬영 시작 발행
    on<_StartShooting>(_onShootingStart);

    ///High low 사진 찍기
    on<_ShotPhoto>(_onShotPhoto);

    ///전체 촬영 완료
    on<_EndShot>(_onEndShot);

    ///촬영 결과 저장
    on<_SaveShot>(_onSaveShot);

    ///웹소켓 변경
    on<_SocketChange>(_onSocketChange);

    ///리슨 이벤트 종료
    on<_OffEvent>(_onOffEvent);

    ///사진 촬영 인디케이트 시간 보내기
    on<_HighRowIndicator>(_onSendHighRowIndicator);

    ///웹소켓 상태 업데이트
    on<_UpdateState>(_onUpdateState);
  }

  Socket? socket;

  void _onShootingStart(
      _StartShooting event, Emitter<WebSocketState> emit) async {
    try {
      final uid = Uid(uid: event.barcode);

      socket?.off(WebsocketEventKey.kioskEndShootingEventKey.code);

      socket?.on(WebsocketEventKey.kioskEndShootingEventKey.code, (data) {
        print('webscoket on Received $data');
        final s3ImageUrl = it<SettingManageCubit>().state.s3ImageUrl;
        final image = ShootingImage.fromJson(data);

        it<ServicesBloc>().add(ServicesEvent.received(
            image: image.copyWith(image: '$s3ImageUrl${image.image}')));
      });

      ///웹소켓 사진 준비 발행
      socket?.emit(
          WebsocketEventKey.kioskReadyEventKey.code, jsonEncode(uid.toJson()));
      print('webscoket _onReadyShot');
    } catch (e) {}
  }

  @override
  Future<void> close() {
    socket?.close();
    return super.close();
  }

  void _onEndShot(_EndShot event, Emitter<WebSocketState> emit) async {
    socket?.off(WebsocketEventKey.kioskEndShootingEventKey.code);
    socket?.emit(WebsocketEventKey.endShootingEventKey.code,
        jsonEncode(Uid(uid: event.barcode)..toJson()));
    print('webscoket _onEndShot');
  }

  void _onSaveShot(_SaveShot event, Emitter<WebSocketState> emit) {
    socket?.emit(WebsocketEventKey.saveResultEventKey.code,
        jsonEncode(Uid(uid: event.barcode)..toJson()));
    print('webscoket onSaveShot');
  }

  void _onShotPhoto(_ShotPhoto event, Emitter<WebSocketState> emit) {
    socket?.emit(
        WebsocketEventKey.kioskStartShootingEventKey.code,
        jsonEncode(
            Uid(uid: event.barcode, type: event.kindZone.name)..toJson()));
    print('webscoket _onShotPhoto');
  }

  void _onSocketChange(_SocketChange event, Emitter<WebSocketState> emit) {
    print('webscoket _onSocketChange');
    socket?.disconnect();
    socket?.close();
    socket?.destroy();
    socket = null;

    final url = _makeWebsocketUrl(event.kindZone);
    socket = io(
        url,
        OptionBuilder()
            .enableForceNewConnection()
            .setTransports(['websocket']).build());

    socket?.connect();

    socket?.on(WebsocketEventKey.qrSkpEventKey.code, (data) {
      print('webscoket qrSkpEventKey $data');
      final uid = Uid.fromJson(data);
      it<ServicesBloc>().add(ServicesEvent.pureReady(uid.uid));
    });

    socket?.on(WebsocketEventKey.kioskError.code, (data) {
      print('webscoket kioskError $data');
      final error = WebsocketError.fromJson(data);
      add(_UpdateState(error: error));
    });

    socket?.on(WebsocketEventKey.kioskOmpInfo.code, (data) {
      print('websocket kioskOmpInfo $data');
      final omp = OMPInfo.fromJson(data);
      final ompUid = it<SettingManageCubit>().state.ompUid;
      if (omp.uid == ompUid) {
        it<ServicesBloc>().add(ServicesEvent.ompUid(omp));
      }
    });
  }

  void _onOffEvent(_OffEvent event, Emitter<WebSocketState> emit) {
    socket?.off(WebsocketEventKey.kioskEndShootingEventKey.code);
    print('webscoket onOffEvent');
  }

  void _onSendHighRowIndicator(
      _HighRowIndicator event, Emitter<WebSocketState> emit) {
    socket?.emit(
        WebsocketEventKey.kioskStartIndicator.code,
        jsonEncode(
            KioskIndicator(type: event.type, indicatorType: event.indicatorType)
              ..toJson()));
    print('webscoket onSendHighRowIndicator');
  }

  void _onUpdateState(_UpdateState event, Emitter<WebSocketState> emit) {
    emit(state.copyWith(error: event.error, dateTime: DateTime.now()));
    print('webscoket _onUpdateState');
  }
}

String _makeWebsocketUrl(KindZoneType type) {
  final zone = type == KindZoneType.quick ? 'quick' : 'highlow';
  final websocketUrl = it<SettingManageCubit>().state.websocketUrl;
  print('$websocketUrl?type=$gDeviceType&zone=$zone');
  return '$websocketUrl?type=$gDeviceType&zone=$zone';

  // return '$websocketUrl?type=$gDeviceType&zone=$zone';
}
