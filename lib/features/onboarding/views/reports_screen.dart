// features/monitor/views/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> dependents;
  final int monitorId;

  const ReportsScreen({
    super.key,
    required this.dependents,
    required this.monitorId,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final Color _primaryColor = const Color(0xFF4A90A4);
  final Color _accentColor = const Color(0xFF6AC2B0);

  String _selectedTimeRange = 'Last 7 Days';
  String _selectedDependent = 'All Dependents';
  int _currentReportType = 0; // 0: Adherence, 1: Performance, 2: Trends

  final List<String> _timeRanges = [
    'Today',
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
  ];
  final List<String> _reportTypes = ['Adherence', 'Performance', 'Trends'];

  // بيانات تقرير افتراضية
  final Map<String, dynamic> _reportData = {
    'overallAdherence': 87,
    'totalMedications': 15,
    'takenOnTime': 12,
    'missedDoses': 2,
    'takenLate': 1,
    'dailyAdherence': [85, 90, 88, 92, 87, 85, 89],
    'dependentPerformance': [
      {'name': 'Father', 'adherence': 92, 'medications': 5},
      {'name': 'Mother', 'adherence': 85, 'medications': 4},
      {'name': 'Son Ahmed', 'adherence': 84, 'medications': 6},
    ],
    'medicationTrends': [
      {'month': 'Jan', 'adherence': 82},
      {'month': 'Feb', 'adherence': 85},
      {'month': 'Mar', 'adherence': 87},
      {'month': 'Apr', 'adherence': 89},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, size: 22.sp),
            onPressed: _shareReport,
          ),
          IconButton(
            icon: Icon(Icons.download, size: 22.sp),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Filters
            _buildFiltersSection(),
            SizedBox(height: 20.h),

            // Report Type Tabs
            _buildReportTypeTabs(),
            SizedBox(height: 20.h),

            // Main Report Content
            _buildReportContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Time Range',
                  _selectedTimeRange,
                  _timeRanges,
                  (value) => setState(() => _selectedTimeRange = value!),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildFilterDropdown(
                  'Dependent',
                  _selectedDependent,
                  [
                    'All Dependents',
                    ...widget.dependents.map((d) => d['name']),
                  ],
                  (value) => setState(() => _selectedDependent = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  icon: Icon(Icons.refresh, size: 16.sp),
                  label: Text('Generate Report'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _compareReports,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: BorderSide(color: _primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  icon: Icon(Icons.compare, size: 16.sp),
                  label: Text('Compare'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, size: 20.sp),
            items: options.map((String option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: TextStyle(fontSize: 14.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeTabs() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _reportTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          final isSelected = _currentReportType == index;

          return Expanded(
            child: Material(
              color: isSelected
                  ? _primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _currentReportType = index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? _primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? _primaryColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_currentReportType) {
      case 0:
        return _buildAdherenceReport();
      case 1:
        return _buildPerformanceReport();
      case 2:
        return _buildTrendsReport();
      default:
        return _buildAdherenceReport();
    }
  }

  Widget _buildAdherenceReport() {
    return Column(
      children: [
        // Overall Adherence Card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Overall Medication Adherence',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: 120.w,
                height: 120.h,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: _reportData['overallAdherence'] / 100,
                      strokeWidth: 12.w,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_reportData['overallAdherence']}%',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          Text(
                            'Adherence',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              _buildAdherenceStats(),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Daily Adherence Chart
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Adherence Trend',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Container(height: 150.h, child: _buildDailyAdherenceChart()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCircle(
          'Taken on Time',
          _reportData['takenOnTime'],
          Colors.green,
        ),
        _buildStatCircle(
          'Missed Doses',
          _reportData['missedDoses'],
          Colors.red,
        ),
        _buildStatCircle('Taken Late', _reportData['takenLate'], Colors.orange),
      ],
    );
  }

  Widget _buildStatCircle(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.w),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDailyAdherenceChart() {
    // Simple bar chart simulation
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _reportData['dailyAdherence'].length,
      itemBuilder: (context, index) {
        final adherence = _reportData['dailyAdherence'][index];
        final day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$adherence%',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
              SizedBox(height: 4.h),
              Container(
                width: 20.w,
                height: (adherence / 100) * 100.h,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                day,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceReport() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dependent Performance',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          ..._reportData['dependentPerformance'].map((dependent) {
            return _buildDependentPerformanceCard(dependent);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDependentPerformanceCard(Map<String, dynamic> dependent) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, size: 20.sp, color: _primaryColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dependent['name'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${dependent['medications']} medications',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _getAdherenceColor(
                dependent['adherence'],
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${dependent['adherence']}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: _getAdherenceColor(dependent['adherence']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsReport() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Trends',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _reportData['medicationTrends'].length,
              itemBuilder: (context, index) {
                final trend = _reportData['medicationTrends'][index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${trend['adherence']}%',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 30.w,
                        height: (trend['adherence'] / 100) * 150.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryColor, _accentColor],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        trend['month'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
          _buildTrendInsights(),
        ],
      ),
    );
  }

  Widget _buildTrendInsights() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 Performance Insights',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Adherence has improved by 7% over the last 3 months. '
            'Best performance was in April with 89% adherence rate.',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Color _getAdherenceColor(int adherence) {
    if (adherence >= 90) return Colors.green;
    if (adherence >= 80) return Colors.orange;
    return Colors.red;
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating report for $_selectedTimeRange...'),
        backgroundColor: _primaryColor,
      ),
    );
  }

  void _compareReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comparison feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing report...'),
        backgroundColor: _primaryColor,
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting report as PDF...'),
        backgroundColor: _primaryColor,
      ),
    );
  }
}
