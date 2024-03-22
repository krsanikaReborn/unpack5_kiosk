import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/defined_code.dart';
import '../../injection_container.dart';
import '../../l10n/l10n.dart';

part 'setting_manage_cubit.freezed.dart';
part 'setting_manage_state.dart';

const prefImageUrlKey = 's3ImageUrlKey';
const prefUploadUrlKey = 's3UploadUrlKey';
const prefWebsocketUrlKey = 'websocketUrlKey';
const prefBarcodeLengthKey = 'barcodeLengthKey';
const prefGoSettingBarcodeKey = 'goSettingBarcodeKey';
const prefLastPrintBarcodeKey = 'lastPrintBarcodeKey';
const prefZoneKey = 'zoneKey';
const prefSerialComKey = 'serialComKey';
const prefLanguageKey = 'languageKey';
const prefOmpUidKey = 'ompUidKey';

class SettingManageCubit extends Cubit<SettingManageState> {
  SettingManageCubit({required Locale locale})
      : super(SettingManageState(locale: locale));
  final prefs = it<SharedPreferences>();

  void initSetting() {
    final imageUrl = prefs.getString(prefImageUrlKey) ?? gImageUrl;
    final uploadUrl = prefs.getString(prefUploadUrlKey) ?? gUploadUrl;
    final websocketUrl = prefs.getString(prefWebsocketUrlKey) ?? gWebsocketUrl;
    final barcodeLen = prefs.getInt(prefBarcodeLengthKey) ?? 32;
    final goSettingBarcode =
        prefs.getString(prefGoSettingBarcodeKey) ?? gGoSettingBarcode;

    final prefZone = prefs.getString(prefZoneKey);

    final zone = prefZone != null && prefZone.isNotEmpty
        ? KindZoneType.values.byName(prefZone)
        : KindZoneType.quick;

    final lastPrintBarcode =
        prefs.getString(prefLastPrintBarcodeKey) ?? gLastPrintBarcode;

    final prefSerialCom = prefs.getString(prefSerialComKey) ?? '';
    // final prefSerialCom = '4';

    final language = L10n.all[prefs.getInt(prefLanguageKey) ?? 0];

    final ompUid = prefs.getString(prefOmpUidKey) ?? gOmpUid;

    emit(state.copyWith(
      s3ImageUrl: imageUrl,
      amzUploadUrl: uploadUrl,
      websocketUrl: websocketUrl,
      readBarcodeLength: barcodeLen,
      goSettingBarcode: goSettingBarcode,
      lastPrintBarcode: lastPrintBarcode,
      locale: language,
      ompUid: ompUid,
      portInfo: PortInfo(
          portName: prefSerialCom,
          friendlyName: '',
          hardwareID: '',
          manufactureName: ''),
      zone: zone,
    ));
  }

  void onChangedLocal(Locale locale) async {
    final index =
        L10n.all.indexWhere((e) => e.countryCode == locale.countryCode);
    await prefs.setInt(prefLanguageKey, index);
    emit(state.copyWith(locale: locale));
  }

  void onChangedBarcodePort(PortInfo portInfo) async {
    await prefs.setString(prefSerialComKey, portInfo.portName);
    emit(state.copyWith(portInfo: portInfo));
  }

  void onChnagedZone(KindZoneType zone) async {
    await prefs.setString(prefZoneKey, zone.name);
    emit(state.copyWith(zone: zone));
  }

  void onSaveImageUrl(String url) async {
    await prefs.setString(prefImageUrlKey, url);
    emit(state.copyWith(s3ImageUrl: url));
  }

  void onSaveUploadUrl(String url) async {
    await prefs.setString(prefUploadUrlKey, url);
    emit(state.copyWith(amzUploadUrl: url));
  }

  void onSaveWebsocketUrl(String url) async {
    await prefs.setString(prefWebsocketUrlKey, url);
    emit(state.copyWith(websocketUrl: url));
  }

  void onSettingBarcode(String barcode) async {
    await prefs.setString(prefGoSettingBarcodeKey, barcode);
    emit(state.copyWith(goSettingBarcode: barcode));
  }

  void onLastPrintBarcode(String barcode) async {
    await prefs.setString(prefLastPrintBarcodeKey, barcode);
    emit(state.copyWith(lastPrintBarcode: barcode));
  }

  void onSaveBarcodeLength(String len) async {
    final length = int.tryParse(len) ?? 32;
    await prefs.setInt(prefBarcodeLengthKey, length);
    emit(state.copyWith(readBarcodeLength: length));
  }

  void onSaveOmpUid(String uid) async {
    await prefs.setString(prefOmpUidKey, uid);
    emit(state.copyWith(ompUid: uid));
  }
}
