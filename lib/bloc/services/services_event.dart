part of 'services_bloc.dart';

@freezed
class ServicesEvent with _$ServicesEvent {
  const factory ServicesEvent.ompUid(OMPInfo omp) = _OmpData;
  const factory ServicesEvent.openBarcodePort() = _OpenBarcodePort;
  const factory ServicesEvent.pureReady(String barcode) = _PureReady;
  const factory ServicesEvent.startShot() = _StartShot;
  const factory ServicesEvent.shotPhoto() = _ShotPhoto;
  const factory ServicesEvent.endShot() = _EndShot;
  const factory ServicesEvent.received({required ShootingImage image}) =
      _Received;

  const factory ServicesEvent.divarication({required int index}) =
      _Divarication;
  const factory ServicesEvent.shotComplated({@Default(false) bool isEndShot}) =
      _ShotComplated;

  const factory ServicesEvent.selectMagazine(
          {required Map<KindZoneType, ShootingImage> selectedImages}) =
      _SelectMagazine;

  const factory ServicesEvent.finalOnResult(
      {required String selectedMagazineImages,
      required KindZoneType zone}) = _FinalOnResult;

  const factory ServicesEvent.saveAndPrint() = _SaveAndPrint;

  const factory ServicesEvent.goSettings() = _GoSettings;

  const factory ServicesEvent.ready() = _Ready;

  const factory ServicesEvent.scannerPortClose() = _ScannerPortClose;

  const factory ServicesEvent.goinitScreen() = _GoInitScreen;

  const factory ServicesEvent.quickReturn() = _QuickReturn;

  const factory ServicesEvent.lastPrint() = _LastPrint;
}
