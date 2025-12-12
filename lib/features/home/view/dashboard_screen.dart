import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../../app/theme/app_theme.dart';

const ShapeBorder greenLeftAccentShapeDashboard = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  side: BorderSide(color: AppTheme.accentGreen, width: 2), // ВИПРАВЛЕНО
);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Блок цитати
            if (viewModel.dailyQuote != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.format_quote, color: AppTheme.accentGreen),
                        SizedBox(width: 8),
                        Text("Цитата дня", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkGreen)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      viewModel.dailyQuote!.text,
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("- ${viewModel.dailyQuote!.author}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            Text('Успішність', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Динаміка успішності', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 30),
                          AspectRatio(
                            aspectRatio: 1.7,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1),
                                  getDrawingVerticalLine: (value) => const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1),
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(sideTitles: _bottomTitles),
                                  leftTitles: AxisTitles(sideTitles: _leftTitles),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineTouchData: LineTouchData(enabled: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: viewModel.performanceData,
                                    isCurved: true,
                                    color: AppTheme.darkGrey,
                                    barWidth: 5,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [AppTheme.accentGreen.withAlpha(76), AppTheme.accentGreen.withAlpha(0)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildStatCard(context, 'Середній бал', viewModel.averageGrade.toString(), viewModel.averageGrade / 100),
                      _buildStatCard(context, 'Прогрес', '${viewModel.progress.toInt()}%', viewModel.progress / 100),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, double progress) {
    return Card(
      shape: greenLeftAccentShapeDashboard,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(value: 1, strokeWidth: 12, color: Colors.grey[200]),
                  CircularProgressIndicator(value: progress, strokeWidth: 12, strokeCap: StrokeCap.round, color: AppTheme.darkGrey),
                  Center(child: Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkGrey))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  SideTitles get _bottomTitles => SideTitles(
    showTitles: true,
    interval: 1,
    getTitlesWidget: (value, meta) {
      String text = '';
      switch (value.toInt()) {
        case 0: text = 'Вер'; break;
        case 1: text = 'Жов'; break;
        case 2: text = 'Лис'; break;
        case 3: text = 'Гру'; break;
        case 4: text = 'Січ'; break;
      }
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      );
    },
  );

  SideTitles get _leftTitles => SideTitles(
    showTitles: true,
    interval: 2,
    getTitlesWidget: (value, meta) {
      return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 12));
    },
    reservedSize: 32,
  );
}