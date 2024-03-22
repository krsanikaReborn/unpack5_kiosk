part of 'setting_manage_cubit.dart';

@freezed
class SettingManageState with _$SettingManageState {
  const factory SettingManageState({
    @Default(
      PortInfo(
        friendlyName: '',
        portName: '',
        hardwareID: '',
        manufactureName: '',
      ),
    )
    PortInfo portInfo,
    @Default(KindZoneType.quick) KindZoneType zone,
    required Locale locale,
    @Default('') String s3ImageUrl,
    @Default('') String amzUploadUrl,
    @Default('') String websocketUrl,
    @Default('') String goSettingBarcode,
    @Default('') String lastPrintBarcode,
    @Default(32) int readBarcodeLength,
    @Default('') String ompUid,
  }) = _SettingManageState;
}
