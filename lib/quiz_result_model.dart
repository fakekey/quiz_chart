import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

@immutable
class QuizResultModel {
  final String? name;
  final int? total;
  final int? pass;

  const QuizResultModel({this.name, this.total, this.pass});

  @override
  String toString() {
    return 'QuizResultModel(name: $name, total: $total, pass: $pass)';
  }

  factory QuizResultModel.fromMap(Map<String, dynamic> data) {
    return QuizResultModel(
      name: data['name'] as String?,
      total: data['total'] as int?,
      pass: data['pass'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'total': total,
        'pass': pass,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [QuizResultModel].
  factory QuizResultModel.fromJson(String data) {
    return QuizResultModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [QuizResultModel] to a JSON string.
  String toJson() => json.encode(toMap());

  QuizResultModel copyWith({
    String? name,
    int? total,
    int? pass,
  }) {
    return QuizResultModel(
      name: name ?? this.name,
      total: total ?? this.total,
      pass: pass ?? this.pass,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! QuizResultModel) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode => name.hashCode ^ total.hashCode ^ pass.hashCode;
}
