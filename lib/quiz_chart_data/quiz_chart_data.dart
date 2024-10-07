import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'quiz_chart_group.dart';

@immutable
class QuizChartData {
  final String? x;
  final List<QuizChartGroup>? group;

  const QuizChartData({this.x, this.group});

  @override
  String toString() => 'QuizChartData(x: $x, group: $group)';

  factory QuizChartData.fromMap(Map<String, dynamic> data) => QuizChartData(
        x: data['x'] as String?,
        group: (data['group'] as List<dynamic>?)?.map((e) => QuizChartGroup.fromMap(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toMap() => {
        'x': x,
        'group': group?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [QuizChartData].
  factory QuizChartData.fromJson(String data) {
    return QuizChartData.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [QuizChartData] to a JSON string.
  String toJson() => json.encode(toMap());

  QuizChartData copyWith({
    String? x,
    List<QuizChartGroup>? group,
  }) {
    return QuizChartData(
      x: x ?? this.x,
      group: group ?? this.group,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! QuizChartData) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => x.hashCode ^ group.hashCode;
}
