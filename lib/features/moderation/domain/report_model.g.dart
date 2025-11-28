// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  reporterId: json['reporter_id'] as String,
  reason: json['reason'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'reporter_id': instance.reporterId,
      'reason': instance.reason,
      'created_at': instance.createdAt.toIso8601String(),
    };
