import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'attendance_detail_for_class.dart';
import 'attendance_detail_for_students.dart';


class SQLiteDataBase {
  Future<Database> initializedDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'SqlDatabase1.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE studentTable(id Integer PRIMARY KEY AUTOINCREMENT, studentCode TEXT NOT NULL, studentName TEXT NOT NULL,classCode TEXT NOT NULL,formattedDate Text NOT NULL)",
        );

        await db.execute(
          "CREATE TABLE classTable(id INTEGER PRIMARY KEY AUTOINCREMENT, classCode TEXT NOT NULL, formattedDate TEXT NOT NULL, finalPresentStudentMapLength TEXT NOT NULL, totalStudents TEXT NOT NULL)",
        );
      },
    );
  }

  // insert data
  Future<int> insertInClassTable(List<AttendanceDetailForClass> ListOfAttendanceDetailForClass) async {
    int result = 0;
    final Database db = await initializedDB();
    for (var classAttendanceDetail in ListOfAttendanceDetailForClass) {
      result = await db.insert('classTable', classAttendanceDetail.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return result;
  }

  // retrieve data
  Future<List<AttendanceDetailForClass>> retrieveClassTable() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult = await db.query('classTable');
    return queryResult.map((e) => AttendanceDetailForClass.fromMap(e)).toList();
  }

  // delete class row
  Future<void> deleteClassRow(int id) async {
    final db = await initializedDB();
    await db.delete(
      'classTable',
      where: "id = ?",
      whereArgs: [id],
    );
  }



  // insert data
  Future<int> insertInStudentTable(List<AttendanceDetailForStudents> ListOfAttendanceDetailForStudents) async {
    int result = 0;
    final Database db = await initializedDB();
    for (var StudentAttendanceDetail in ListOfAttendanceDetailForStudents) {
      result = await db.insert('studentTable', StudentAttendanceDetail.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return result;
  }

  // retrieve data
  Future<List<AttendanceDetailForStudents>> retrieveStudentTable() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult = await db.query('studentTable');
    return queryResult.map((e) => AttendanceDetailForStudents.fromMap(e)).toList();
  }

  // delete class row
  Future<void> deleteStudentRow(int id) async {
    final db = await initializedDB();
    await db.delete(
      'studentTable',
      where: "id = ?",
      whereArgs: [id],
    );
  }


}
