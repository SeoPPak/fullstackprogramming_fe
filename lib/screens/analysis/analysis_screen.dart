import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/record_provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        // 월별 지출 데이터 계산
        Map<int, int> monthlyExpenses = {};
        for (var record in provider.records) {
          final date = DateTime.parse(record.record.timeStamp);
          if (date.year == selectedYear) {
            monthlyExpenses[date.month] = (monthlyExpenses[date.month] ?? 0) + record.totalPrice;
          }
        }

        return Column(
          children: [
            // 연도 선택
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () => setState(() => selectedYear--),
                  ),
                  Text(
                    '$selectedYear년',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () => setState(() => selectedYear++),
                  ),
                ],
              ),
            ),

            // 월별 지출 그래프
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: monthlyExpenses.isEmpty ? 100000 :
                    monthlyExpenses.values.reduce((a, b) => a > b ? a : b) * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBorder: BorderSide.none,
                        tooltipRoundedRadius: 8,
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${group.x + 1}월\n${rod.toY.toInt().toString()}원',
                            const TextStyle(
                              color: Colors.white,
                            ),
                          );
                        },
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt() + 1}월');
                          },
                          reservedSize: 30,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: List.generate(12, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: monthlyExpenses[index + 1]?.toDouble() ?? 0,
                            color: Colors.blue,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),

            // 월별 지출 리스트
            Expanded(
              child: ListView.builder(
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final expense = monthlyExpenses[month] ?? 0;
                  return ListTile(
                    title: Text('$month월'),
                    trailing: Text(
                      '${expense.toString()}원',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}