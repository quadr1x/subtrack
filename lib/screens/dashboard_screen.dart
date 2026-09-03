import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/subscription.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Box<Subscription> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Subscription>('subscriptions');
  }

  // ---------- Расчёты ----------

  /// Помесячная стоимость одной подписки (годовые делим на 12).
  double _monthlyOf(Subscription sub) {
    if (sub.billingCycle.toLowerCase() == 'yearly' ||
 sub.billingCycle.toLowerCase() == 'annual') {
      return sub.price / 12.0;
    }
    return sub.price;
  }

  /// Общие расходы за месяц.
  double get _monthlyTotal {
    double total = 0;
    for (final sub in _box.values) {
      total += _monthlyOf(sub);
    }
    return total;
  }

  /// Прогноз расходов на год.
  double get _yearlyForecast => _monthlyTotal * 12.0;

  /// Суммы по категориям (в пересчёте на месяц).
  Map<String, double> get _categoryTotals {
    final Map<String, double> map = {};
    for (final sub in _box.values) {
      final key = sub.category.isEmpty ? 'Без категории' : sub.category;
      map[key] = (map[key] ?? 0) + _monthlyOf(sub);
    }
    // Сортируем по убыванию для наглядности
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Суммы по месяцам (1..12) — для столбчатого графика.
  Map<int, double> _monthlyBreakdown() {
    final Map<int, double> map = {for (int i = 1; i <= 12; i++) i: 0.0};
    final now = DateTime.now();

    for (final sub in _box.values) {
      final monthly = _monthlyOf(sub);
      final start = sub.startDate ?? now;

      for (int m = 1; m <= 12; m++) {
        // Учитываем подписку в месяце m, если она активна на этот месяц текущего года
        final ref = DateTime(now.year, m, 1);
        if (!ref.isBefore(DateTime(start.year, start.month, 1)) &&
            (sub.endDate == null ||
 !ref.isAfter(DateTime(sub.endDate!.year, sub.endDate!.month, 1)))) {
          map[m] = (map[m] ?? 0) + monthly;
        }
      }
    }
    return map;
  }

  // ---------- Графики ----------

  Widget _buildCategoryPieChart() {
    final data = _categoryTotals;
    final total = data.values.fold<double>(0, (s, e) => s + e);

    final palette = <Color>[
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
    ];

    final sections = <PieChartSectionData>[];
    int i = 0;
    data.forEach((category, value) {
      final percent = total > 0 ? (value / total * 100) : 0;
      sections.add(
        PieChartSectionData(
          value: value,
          color: palette[i % palette.length],
          title: percent >= 5 ? '${percent.toStringAsFixed(0)}%' : '',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Расходы по категориям',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: total > 0
                  ? PieChart(
 PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                      ),
                    )
                  : const Center(child: Text('Нет данных')),
 ),
            const SizedBox(height: 8),
            _buildLegend(data, palette),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, double> data, List<Color> palette) {
    final entries = data.entries.toList();
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: List.generate(entries.length, (idx) {
        final e = entries[idx];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: palette[idx % palette.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${e.key} — ${e.value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMonthlyBarChart() {
    final monthly = _monthlyBreakdown();
    final maxY = (monthly.values.fold<double>(0, (s, e) => e > s ? e : s)) * 1.2;
    final upper = maxY == 0 ? 100.0 : maxY;

    const monthLabels = [
      '',
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек',
    ];

    final barGroups = <BarChartGroupData>[];
    monthly.forEach((month, value) {
      barGroups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.blueAccent,
              width: 14,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Траты по месяцам',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: upper,
                  barGroups: barGroups,
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
 );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 1 || idx > 12) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              monthLabels[idx],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Шапка со сводкой ----------

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _summaryItem(
                'Месяц',
                _monthlyTotal,
                Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryItem(
                'Прогноз на год',
                _yearlyForecast,
                Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: color)),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Дашборд')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            if (isMobile)
              Column(
                children: [
                  _buildCategoryPieChart(),
                  const SizedBox(height: 16),
                  _buildMonthlyBarChart(),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCategoryPieChart()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMonthlyBarChart()),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
