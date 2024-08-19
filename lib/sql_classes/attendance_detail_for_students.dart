class AttendanceDetailForStudents{
  int? id;
  late final String studentCode;
  late final String studentName;
  late final String classCode;
  late final String formattedDate;

  AttendanceDetailForStudents(
      this.studentCode, this.studentName, this.classCode, this.formattedDate);


  AttendanceDetailForStudents.fromMap(Map<String, dynamic> result)
      : id = result["id"],
        studentCode = result["studentCode"],
        studentName = result["studentName"],
        classCode = result["classCode"],
        formattedDate = result["formattedDate"];


  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      "studentCode": studentCode,
      "studentName": studentName,
      "classCode": classCode,
      "formattedDate": formattedDate
    };
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }
}