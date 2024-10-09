import 'package:flutter/material.dart';
import 'package:quiz_chart/quiz_chart.dart';
import 'package:quiz_chart/quiz_chart_data/quiz_chart_data.dart';
import 'package:quiz_chart/quiz_chart_data/quiz_chart_group.dart';
import 'package:quiz_chart/quiz_result_model.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      const QuizResultModel(name: "Product Planning", total: 13, pass: 13),
      const QuizResultModel(name: "Plant Administration", total: 27, pass: 12),
      const QuizResultModel(name: "Production Control", total: 26, pass: 0),
      const QuizResultModel(name: "Purchasing", total: 32, pass: 1),
      const QuizResultModel(name: "Supplier base development", total: 13, pass: 5),
      const QuizResultModel(name: "General Assembly", total: 20, pass: 16),
      const QuizResultModel(name: "Quality Control", total: 29, pass: 3),
      const QuizResultModel(name: "Corporate Governance", total: 13, pass: 9),
      const QuizResultModel(name: "President Office", total: 2, pass: 1),
      const QuizResultModel(name: "Demand Supply & Product Marketing", total: 15, pass: 12),
      const QuizResultModel(name: "Logistics", total: 40, pass: 34),
      const QuizResultModel(name: "Branding & Digitalization", total: 13, pass: 5),
      const QuizResultModel(name: "IT", total: 22, pass: 20),
      const QuizResultModel(name: "Service Planning & Operatation", total: 25, pass: 20),
      const QuizResultModel(name: "Field Operatation", total: 24, pass: 23),
      const QuizResultModel(name: "Business Planning", total: 9, pass: 7),
      const QuizResultModel(name: "Trade Union", total: 1, pass: 1),
      const QuizResultModel(name: "Business Support", total: 20, pass: 14),
      const QuizResultModel(name: "Administration & Corporate Social Responsibility", total: 22, pass: 21),
      const QuizResultModel(name: "Body", total: 27, pass: 14),
      const QuizResultModel(name: "S&S", total: 10, pass: 10),
      const QuizResultModel(name: "Human Resources", total: 16, pass: 12),
      const QuizResultModel(name: "CR & Service Techincal", total: 41, pass: 33),
      const QuizResultModel(name: "Finance", total: 30, pass: 15),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: QuizChart(
            gapBwLabelnAxes: 24,
            showSecondLabelReplace: true,
            data: List.generate(data.length, (i) {
              return QuizChartData(
                x: data[i].name,
                group: [
                  QuizChartGroup(
                    x: '${data[i].pass}',
                    fromY: 0,
                    toY: data[i].pass! / data[i].total!,
                  ),
                  QuizChartGroup(
                    x: '${data[i].total! - data[i].pass!}',
                    fromY: 1 - (1 - data[i].pass! / data[i].total!),
                    toY: 1,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
