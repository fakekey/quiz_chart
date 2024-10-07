import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

@immutable
class QuizChartGroup {
  final double? fromY;
  final double? toY;
  final String? x;

  const QuizChartGroup({this.fromY, this.toY, this.x});

  @override
  String toString() => 'Group(fromY: $fromY, toY: $toY, x: $x)';

  factory QuizChartGroup.fromMap(Map<String, dynamic> data) => QuizChartGroup(
        fromY: (data['fromY'] as num?)?.toDouble(),
        toY: (data['toY'] as num?)?.toDouble(),
        x: data['x'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'fromY': fromY,
        'toY': toY,
        'x': x,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [QuizChartGroup].
  factory QuizChartGroup.fromJson(String data) {
    return QuizChartGroup.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [QuizChartGroup] to a JSON string.
  String toJson() => json.encode(toMap());

  QuizChartGroup copyWith({
    double? fromY,
    double? toY,
    String? x,
  }) {
    return QuizChartGroup(
      fromY: fromY ?? this.fromY,
      toY: toY ?? this.toY,
      x: x ?? this.x,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! QuizChartGroup) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => fromY.hashCode ^ toY.hashCode ^ x.hashCode;
}
