import 'dart:io';

import 'package:dio/dio.dart';

void printImage(String imagePath) {
  Process.start('rundll32', [
    'shimgvw.dll',
    'ImageView_PrintTo',
    '/pt',
    imagePath,
    'DS-RX1'
  ]).then((process) {
    // Get the exit code from the new process.
    process.exitCode.then((exitCode) {
      print('exit code: $exitCode');
    });
  });
}

Future<bool> uploadFileWithDio(
    String url, String uid, String zone, List<File> files) async {
  final dio = Dio();

  final multiPartFiles = <MultipartFile>[];

  for (int i = 0; i < files.length; i++) {
    final fileName = files[i].path.split(Platform.pathSeparator).last;
    multiPartFiles.add(
      await MultipartFile.fromFile(files[i].path, filename: fileName),
    );
  }

  final formData =
      FormData.fromMap({'uid': uid, 'zone': zone, 'files': multiPartFiles});

  var response = await dio.post(url,
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType));

  if (response.statusCode != 200) {
    return false;
  }

  return true;
}

void removeDirectory(String path, DateTime now) {
  final directory = Directory(path);

  if (directory.existsSync()) {
    for (final entity in directory.listSync()) {
      if (entity is Directory) {
        final formattedString = entity.path.split(Platform.pathSeparator).last;
        final directoryDate = DateTime.tryParse(formattedString);
        if (directoryDate != null && !isSameDate(directoryDate, now)) {
          entity.deleteSync(recursive: true);
        }
      }
    }
  }
}

void removeFiles(String path) {
  final dir = Directory(path);

  // 디렉토리가 실제로 존재하는지 확인합니다.
  if (dir.existsSync()) {
    // 디렉토리 내의 모든 엔티티(파일, 하위 디렉토리 등)를 가져옵니다.
    final files = dir.listSync();

    for (var entity in files) {
      // 엔티티가 파일인지 확인하고, 파일이면 삭제합니다.
      if (entity is File) {
        entity.deleteSync();
      }
    }
  }
}

// 두 개의 DateTime이 동일한 날짜인지 확인하는 함수
bool isSameDate(DateTime date1, DateTime date2) {
  return (date1.year == date2.year) &&
      (date1.month == date2.month) &&
      (date1.day == date2.day);
}
