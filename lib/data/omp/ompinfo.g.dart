// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ompinfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_OMPInfo _$$_OMPInfoFromJson(Map<String, dynamic> json) => _$_OMPInfo(
      uid: json['uid'] as String,
      urls: (json['urls'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_OMPInfoToJson(_$_OMPInfo instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'urls': instance.urls,
    };
