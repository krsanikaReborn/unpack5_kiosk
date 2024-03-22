part of 'services_bloc.dart';

enum ServiceStatus {
  pure,
  guide,
  ready,
  loading,
  settings,
  waitLowHigh,
  quickLowHighShot,
  photoNotication,
  photoDone,
  onPictures,
  shotComplate,
  selectMagazine,
  finalResult,
  fileNotFound,
}

@freezed
class ServicesState with _$ServicesState {
  factory ServicesState({
    @Default(ServiceStatus.pure) ServiceStatus status,
    @Default('') String uid,
    @Default(KindZoneType.pure) KindZoneType zone,
    @Default(<ShootingImage>[]) List<ShootingImage> shotedImages,
    @Default(<KindZoneType, ShootingImage>{})
    Map<KindZoneType, ShootingImage> selectedimages,
    @Default(<KindZoneType, String>{})
    Map<KindZoneType, String> selectedMagazineImages,
    DateTime? dateTime,
    OMPInfo? omp,
  }) = _ServiceState;
}
