import 'package:quran_halaqa_app/models/student.dart';

// نموذج لتمثيل بيانات الحلقة
class Halaqa {
  final String id;
  final String name;
  final List<Student> students;

  Halaqa({required this.id, required this.name, required this.students});
}
