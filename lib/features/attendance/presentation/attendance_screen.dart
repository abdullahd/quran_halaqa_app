import 'package:flutter/material.dart';
import 'package:quran_halaqa_app/features/attendance/presentation/widgets/attendance_table.dart';
import 'package:quran_halaqa_app/models/halaqa.dart';
import 'package:intl/intl.dart' as intl;

class AttendanceScreen extends StatefulWidget {
  final Halaqa halaqa;
  const AttendanceScreen({super.key, required this.halaqa});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // متغير لتتبع الأسبوع المعروض حالياً
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    // لا نسمح بالذهاب للمستقبل
    if (_selectedDate
        .isBefore(DateTime.now().subtract(const Duration(days: 6)))) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // تنسيق التاريخ لعرضه في العنوان
    final formatter = intl.DateFormat('MMMM yyyy', 'ar');
    final displayMonth = formatter.format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('سجل حضور: ${widget.halaqa.name}'),
      ),
      body: Column(
        children: [
          // شريط التنقل بين الأسابيع
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _goToNextWeek),
                Text(displayMonth,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _goToPreviousWeek),
              ],
            ),
          ),
          // الجدول سيتم عرضه هنا
          Expanded(
            child: AttendanceTable(
              key: ValueKey(
                  _selectedDate), // مهم لتحديث الجدول عند تغيير التاريخ
              students: widget.halaqa.students,
              weekDate: _selectedDate,
            ),
          ),
        ],
      ),
    );
  }
}
