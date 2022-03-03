// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beacon_login_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeaconData _$BeaconDataFromJson(Map<String, dynamic> json) {
  return BeaconData(
    bssid: json['bssid'] as String?,
    uuid: json['uuid'] as String?,
    major: json['major'] as String?,
    minor: json['minor'] as String?,
    rssi: json['rssi'] as int?,
  );
}

Map<String, dynamic> _$BeaconDataToJson(BeaconData instance) =>
    <String, dynamic>{
      'bssid': instance.bssid,
      'uuid': instance.uuid,
      'major': instance.major,
      'minor': instance.minor,
      'rssi': instance.rssi,
    };

SendBeaconLoginDto _$SendBeaconLoginDtoFromJson(Map<String, dynamic> json) {
  return SendBeaconLoginDto(
    token: json['token'] as String?,
    commute: json['commute'] as String?,
    data: (json['data'] as List<dynamic>?)
        ?.map((e) => BeaconData.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$SendBeaconLoginDtoToJson(SendBeaconLoginDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'commute': instance.commute,
      'data': instance.data,
    };

getBeaconLoginDto _$getBeaconLoginDtoFromJson(Map<String, dynamic> json) {
  return getBeaconLoginDto(
    result: json['result'] as String?,
    code: json['code'] as int?,
  );
}

Map<String, dynamic> _$getBeaconLoginDtoToJson(getBeaconLoginDto instance) =>
    <String, dynamic>{
      'result': instance.result,
      'code': instance.code,
    };
