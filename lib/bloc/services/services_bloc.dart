import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:kiosk/bloc/setting_manage/setting_manage_cubit.dart';
import 'package:kiosk/bloc/websocket/web_socket_bloc.dart';
import 'package:path/path.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

import '../../core/defined_code.dart';
import '../../data/omp/ompinfo.dart';
import '../../data/shooting_image/shooting_image.dart';
import '../../injection_container.dart';
import '../../utils/images.dart';
import '../../utils/utils.dart';
import '../timer/timer_bloc.dart';

part 'services_bloc.freezed.dart';
part 'services_event.dart';
part 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc() : super(_ServiceState()) {
    ///바코드 오픈하여 초기화면으로 이동
    on<_OpenBarcodePort>(_openBarcodePort);

    ///촬영 준비
    on<_Ready>(_onReady);

    ///가이드 화면으로 전환
    on<_PureReady>(_onChangedReady);

    ///사진촬영 시작 이벤트 알림
    on<_StartShot>(_onStartShot);

    ///사진촬영 명령 이벤트 전송
    on<_ShotPhoto>(_onShotPhoto);

    ///사진촬용 종료 이벤트 알림
    on<_EndShot>(_onEndShot);

    ///서버로부터 사진 받은 이벤트
    on<_Received>(_onReceivedPhoto);

    ///매거진 선택한 최종 화면
    on<_FinalOnResult>(_onFinalResult);

    ///파일 저장/업로드 및 프린트 출력
    on<_SaveAndPrint>(_onSaveAndPrint);

    ///설정화면 바로 가기
    on<_GoSettings>(_onGoSettings);

    ///화면 분기
    on<_Divarication>(_onDivarication);

    ///사진 촬영완료로 사진 편집 이동
    on<_ShotComplated>(_onShotComplated);

    ///매거진 선택 화면
    on<_SelectMagazine>(_onSelectMagazine);

    ///바코드 스캐너 포트 종료
    on<_ScannerPortClose>(_onCloseScannerPort);

    ///초기화면으로 이동
    on<_GoInitScreen>(_onGoinitScrren);

    ///다시 촬영으로 이동
    on<_QuickReturn>(_onQuickReturn);

    ///마지막에 찍은 사진 출력
    on<_LastPrint>(_onLastPrint);

    ///OMP UID QR CODE
    on<_OmpData>(_onSetOmpData);
  }

  SerialPort? _port;

  void _onChangedReady(_PureReady event, Emitter<ServicesState> emit) {
    it<TimerBloc>().add(const TimerReset());
    final settingValues = it<SettingManageCubit>().state;
    final zone = settingValues.zone;
    it<WebSocketBloc>().add(const WebSocketEvent.offEvent());
    emit(
      ServicesState(
        status: ServiceStatus.guide,
        zone: zone,
        uid: event.barcode,
      ),
    );
  }

  void _openBarcodePort(event, Emitter<ServicesState> emit) async {
    final settingValues = it<SettingManageCubit>().state;
    final portInfo = settingValues.portInfo;
    final zone = settingValues.zone;

    if (portInfo.portName.isEmpty || state.status == ServiceStatus.pure) {
      if (kDebugMode &&
          state.zone == KindZoneType.pure &&
          state.status == ServiceStatus.settings) {
        return emit(ServicesState(zone: zone, status: ServiceStatus.ready));
      }

      return emit(state.copyWith(
          status: ServiceStatus.settings, zone: KindZoneType.pure));
    }

    _initPort(portInfo);

    var retry = 0;

    do {
      try {
        _port?.open();

        if (_port?.isOpened == true) {
          emit(ServicesState(status: ServiceStatus.ready, zone: zone));
          break;
        }
      } catch (e) {
        retry++;
        if (retry > 2) {
          emit(ServicesState(status: ServiceStatus.ready, zone: zone));
          break;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } while (_port?.isOpened == false);

    it<WebSocketBloc>().add(WebSocketEvent.socketChange(zone));

    _port?.readBytesOnListen(
      settingValues.readBarcodeLength,
      (value) {
        final goSettingBarcode =
            it<SettingManageCubit>().state.goSettingBarcode;
        final lastPrintBarcode =
            it<SettingManageCubit>().state.lastPrintBarcode;
        final data = String.fromCharCodes(value)
            .trim()
            .replaceAll('\r', '')
            .replaceAll('\n', '')
            .replaceAll('"', '');

        if (data.isEmpty) return;

        if (data == goSettingBarcode) {
          ///설정화면 바로 가기 이벤트
          add(const _GoSettings());
        } else if (data == lastPrintBarcode) {
          ///마지막에 찍은 사진 출력
          add(const _LastPrint());
        } else {
          ///초기화면으로 이동
          add(_PureReady(data));
        }
      },
    );
  }

  void _initPort(PortInfo portInfo) {
    _port?.close();
    _port = SerialPort(
      portInfo.portName,
      openNow: false,
      ByteSize: 8,
      ReadIntervalTimeout: 1,
      ReadTotalTimeoutConstant: 2,
    );
  }

  void _onStartShot(_StartShot event, Emitter<ServicesState> emit) {
    final isQuick = state.zone == KindZoneType.quick;

    it<WebSocketBloc>()
        .add(WebSocketEvent.startShooting(state.uid, state.zone));

    final status =
        isQuick ? ServiceStatus.photoNotication : ServiceStatus.waitLowHigh;

    emit(
      state.copyWith(
        status: status,
        selectedMagazineImages: {},
        selectedimages: {},
        shotedImages: [],
      ),
    );
  }

  void _onShotPhoto(_ShotPhoto event, Emitter<ServicesState> emit) {
    final zone = state.zone;
    final isEmptyPhoto =
        state.shotedImages.where((e) => e.type == zone.name).toList().isEmpty;

    if (isEmptyPhoto && state.status != ServiceStatus.photoNotication) {
      return emit(state.copyWith(status: ServiceStatus.photoNotication));
    }

    print('Shot Photo ${state.shotedImages.length}');

    it<WebSocketBloc>().add(WebSocketEvent.onShotPhoto(state.uid, zone));
  }

  void _onReceivedPhoto(_Received event, Emitter<ServicesState> emit) async {
    final zone = state.zone;
    final totalShotCnt = zone.totalShootCnt;
    final shotedImages = List.of(state.shotedImages);
    var currentImgCnt = shotedImages
        .where((e) => zone == KindZoneType.quick ? true : e.type == zone.name)
        .length;

    if (currentImgCnt >= totalShotCnt) return;

    shotedImages.add(event.image);
    currentImgCnt = shotedImages
        .where((e) => zone == KindZoneType.quick ? true : e.type == zone.name)
        .length;

    if (currentImgCnt >= totalShotCnt && zone != KindZoneType.high) {
      it<WebSocketBloc>().add(WebSocketEvent.endShot(state.uid));
      return emit(state.copyWith(
          shotedImages: shotedImages, status: ServiceStatus.photoDone));
    }

    emit(state.copyWith(
        shotedImages: shotedImages, status: ServiceStatus.onPictures));

    if (shotedImages.length == totalShotCnt && zone == KindZoneType.high) {
      // high 촬영후 3초 대기후 low 촬영 넘어감.
      await Future.delayed(const Duration(milliseconds: 3000));
      emit(state.copyWith(
          zone: KindZoneType.low,
          shotedImages: shotedImages,
          status: ServiceStatus.waitLowHigh));
    }
  }

  void _onDivarication(_Divarication event, Emitter<ServicesState> emit) {
    return emit(state.copyWith(status: ServiceStatus.quickLowHighShot));
  }

  void _onShotComplated(_ShotComplated event, Emitter<ServicesState> emit) {
    if (event.isEndShot) {
      it<WebSocketBloc>().add(WebSocketEvent.endShot(state.uid));
    }

    emit(state.copyWith(status: ServiceStatus.shotComplate));
  }

  void _onSelectMagazine(_SelectMagazine event, Emitter<ServicesState> emit) {
    final isQuick = state.zone == KindZoneType.quick;
    emit(state.copyWith(
      status: ServiceStatus.selectMagazine,
      zone: isQuick ? state.zone : KindZoneType.high,
      selectedimages: event.selectedImages,
      dateTime: DateTime.now(),
    ));
  }

  void _onFinalResult(_FinalOnResult event, Emitter<ServicesState> emit) {
    final isQuick = state.zone == KindZoneType.quick;
    final selectedMagazineImages = Map.of(state.selectedMagazineImages);
    final zone = event.zone;
    selectedMagazineImages[zone] = event.selectedMagazineImages;

    if (selectedMagazineImages.length == 2 && zone == KindZoneType.low ||
        isQuick) {
      return emit(state.copyWith(
        status: ServiceStatus.finalResult,
        selectedMagazineImages: selectedMagazineImages,
        dateTime: DateTime.now(),
      ));
    }

    return emit(state.copyWith(
      zone: KindZoneType.low,
      status: ServiceStatus.selectMagazine,
      selectedMagazineImages: selectedMagazineImages,
      dateTime: DateTime.now(),
    ));
  }

  void _onSaveAndPrint(_SaveAndPrint event, Emitter<ServicesState> emit) async {
    it<TimerBloc>().add(const TimerReset());
    emit(state.copyWith(status: ServiceStatus.loading));

    final selectedMagazineImages = state.selectedMagazineImages;
    final selectedimages = state.selectedimages;
    final uploadUrl = it<SettingManageCubit>().state.amzUploadUrl;
    final files = <File>[];
    final isQuick = state.zone == KindZoneType.quick;
    final zone = isQuick ? 'quick' : 'highlow';

    final now = DateTime.now();

    try {
      if (state.selectedimages.isEmpty) {
        throw '이미지를 찾을수가 없습니다.';
      }

      removeDirectory(gPhotoPath, now);

      final savePath =
          '$gPhotoPath${Platform.pathSeparator}${DateFormat('yyyyMMdd').format(now)}';

      await Directory(savePath).create(recursive: true);

      for (final key in selectedMagazineImages.keys) {
        final coverImgPath = selectedMagazineImages[key] ?? '';
        final selectImage = selectedimages[key];

        if (selectImage == null) {
          continue;
        }

        final coverImg = coverImgPath.isNotEmpty
            ? await loadImageAsset(
                coverImgPath,
              )
            : null;

        try {
          final mergedImage = img.Image(width: 1280, height: 1920);
          final orgImage = await getImageBytes(selectImage.image);

          if (coverImgPath.contains("01")) {
            if (zone == 'quick') {
              img.compositeImage(mergedImage, orgImage,
                  dstY: 400, dstW: 1280, dstH: 1280);
            } else {
              img.compositeImage(mergedImage, orgImage,
                  dstX: 105, dstY: 400, dstW: 1080, dstH: 1440);
            }
          } else {
            if (zone == 'quick') {
              img.compositeImage(mergedImage, orgImage,
                  dstX: -300, dstW: 1920, dstH: 1920);
            } else {
              img.compositeImage(mergedImage, orgImage,
                  dstX: -83, dstW: 1445, dstH: 1920);
            }
          }

          if (coverImg != null) {
            img.compositeImage(mergedImage, coverImg, dstH: 1920);
          }

          final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);

          final filePath =
              '$savePath${Platform.pathSeparator}${formattedDate}_${key.name}.png';
          await img.encodePngFile(filePath, mergedImage);

          files.add(File(filePath));

          printImage(filePath);
        } catch (e) {
          print(e);
        }
      }

      await uploadFileWithDio(uploadUrl, state.uid, zone, files);
    } catch (e) {
      return emit(ServicesState(
        zone: state.zone,
      ));
    }

    it<WebSocketBloc>().add(WebSocketEvent.saveShot(state.uid));

    await Future.delayed(const Duration(seconds: gWaitSaveAndPrintingTime));

    emit(ServicesState(zone: state.zone, status: ServiceStatus.ready));
  }

  void _onGoSettings(_GoSettings event, Emitter<ServicesState> emit) {
    emit(state.copyWith(status: ServiceStatus.settings));
  }

  void _onReady(_Ready event, Emitter<ServicesState> emit) {
    emit(state.copyWith(status: ServiceStatus.quickLowHighShot));
  }

  void _onEndShot(event, Emitter<ServicesState> emit) {
    it<WebSocketBloc>().add(WebSocketEvent.endShot(state.uid));

    final status = state.shotedImages.isNotEmpty
        ? ServiceStatus.photoDone
        : ServiceStatus.pure;

    return emit(state.copyWith(status: status));
  }

  void _onCloseScannerPort(
      _ScannerPortClose event, Emitter<ServicesState> emit) {
    _port?.close();
    emit(ServicesState(
        dateTime: DateTime.now(),
        status: ServiceStatus.settings,
        zone: KindZoneType.pure));
  }

  void _onGoinitScrren(event, Emitter<ServicesState> emit) {
    it<TimerBloc>().add(const TimerReset());
    emit(ServicesState(status: ServiceStatus.ready));
  }

  void _onQuickReturn(_QuickReturn event, Emitter<ServicesState> emit) {
    it<TimerBloc>().add(const TimerReset());
    emit(state.copyWith(
      status: ServiceStatus.quickLowHighShot,
      selectedMagazineImages: {},
      selectedimages: {},
      shotedImages: [],
      zone: state.zone != KindZoneType.quick ? KindZoneType.high : state.zone,
    ));
  }

  void _onLastPrint(_LastPrint event, Emitter<ServicesState> emit) async {
    emit(state.copyWith(status: ServiceStatus.loading));

    try {
      final isQuick = state.zone == KindZoneType.quick;

      final now = DateTime.now();
      final filePath =
          '$gPhotoPath${Platform.pathSeparator}${DateFormat('yyyyMMdd').format(now)}';

      final directory = Directory(filePath);

      final fileList = directory.listSync();

      fileList.sort((a, b) =>
          b.resolveSymbolicLinksSync().compareTo(a.resolveSymbolicLinksSync()));

      final findCnt = isQuick ? 1 : 2;

      final latestFiles = <FileSystemEntity>[];

      for (final file in fileList) {
        final fileName = basename(file.path);
        if (isQuick && fileName.contains(KindZoneType.quick.name)) {
          latestFiles.add(file);
        } else if (fileName.contains(KindZoneType.high.name) ||
            fileName.contains(KindZoneType.low.name)) {
          latestFiles.add(file);
        }
      }

      final printFiles = latestFiles
          .toList()
          .sublist(0, findCnt)
          .map((entity) => entity as File)
          .toList();

      if (printFiles.isEmpty) {
        throw '';
      }

      for (int i = 0; i < 2; i++) {
        for (final file in printFiles) {
          print(file.path);
          printImage(file.path);
        }
      }

      await Future.delayed(const Duration(seconds: 2));

      emit(ServicesState(status: ServiceStatus.ready, zone: state.zone));
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
      emit(ServicesState(status: ServiceStatus.ready, zone: state.zone));
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: ServiceStatus.fileNotFound));
    }
  }

  void _onSetOmpData(event, Emitter<ServicesState> emit) {
    emit(state.copyWith(omp: event.omp));
  }
}
