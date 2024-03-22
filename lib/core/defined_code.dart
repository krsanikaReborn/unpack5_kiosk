import 'dart:io';
import 'dart:ui';

enum KindZoneType {
  pure(0, 0, 0, 0, ''),
  quick(1, 2, 4, 60, 'Quick'),
  low(1, 3, 3, 3, 'Low'),
  high(1, 3, 3, 3, 'High');

  const KindZoneType(this.selectCnt, this.rowCnt, this.totalShootCnt,
      this.shotTime, this.desc);

  final int selectCnt;
  final int rowCnt;
  final int totalShootCnt;
  final int shotTime;
  final String desc;
}

final gPhotoPath = 'C:${Platform.pathSeparator}photo_images';

const gFontSamsungonekorean = 'samsungonekorean';
const gFontSamsungsharpsans = 'samsungsharpsans';

const gDeviceType = 'kiosk';

const gDeviceId = 0;

const gWebsocketUrl = 'http://125.132.88.192:4000';

const gImageUrl = 'http://125.132.88.192:8080';

const gUploadUrl = 'http://125.132.88.192:3000';

const gGoSettingBarcode = '999999999999';

const gLastPrintBarcode = '999999999990';

const gOmpUid = '121212121212';

///퀵 사진 사이즈 (width, height)
const gQuickSize = Size(400, 358);

///하이로우 사진 사이즈 (width, height)
const gHighLowSize = Size(280, 373);

//첫화면 화살표 표시방향 스위치. QR리더가 오른쪽에 있으면 true. 왼쪽 false.
const gQrReaderOnRight = true;

///사진 촬영 끝나고 다음 화면 넘어갈때의 대기 시간
const gFinishedTimer = 6;

///퀵에서 사진 찍은 후 화면 이후의 전체 대기시간
const gQuickWaitTimer = 60;

///하이로에서 사진 찍은 후 화면 이후의 전체 대기시간
const gHighLowWaitTimer = 90;

///ARE YOU READY에서 Tap on the button to begin 깜빡이는 타임
const gTapOnTheButtonTimer = 30;

///ARE YOU READY에서 총 대기시간
const gAreYouReadyTimer = 70;

///화살표 방향
const double gQrReaderDegree = 0;

///Time is ticking 얼럿창 뛰우는 초기시간
const gTimeisTickingTimer = 20;

///프린트 출력 화면 파일 업로드 후 대기시간
const gWaitSaveAndPrintingTime = 15;


