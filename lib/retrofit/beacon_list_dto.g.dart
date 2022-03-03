// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beacon_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeaconInfo _$BeaconInfoFromJson(Map<String, dynamic> json) {
  return BeaconInfo(
    uuid: (json['uuid'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$BeaconInfoToJson(BeaconInfo instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
    };

SendBeaconListDto _$SendBeaconListDtoFromJson(Map<String, dynamic> json) {
  return SendBeaconListDto(
    token: json['token'] as String?,
  );
}

Map<String, dynamic> _$SendBeaconListDtoToJson(SendBeaconListDto instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

GetBeaconListDto _$GetBeaconListDtoFromJson(Map<String, dynamic> json) {
  return GetBeaconListDto(
    result: json['result'] as String?,
    code: json['code'] as int?,
    data: json['data'] == null
        ? null
        : BeaconInfo.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GetBeaconListDtoToJson(GetBeaconListDto instance) =>
    <String, dynamic>{
      'result': instance.result,
      'code': instance.code,
      'data': instance.data,
    };
