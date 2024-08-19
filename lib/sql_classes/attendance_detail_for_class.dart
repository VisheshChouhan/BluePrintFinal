class AttendanceDetailForClass{
  int? id;
  late final String classCode;
  late final String formattedDate;
  late final String finalPresentStudentMapLength;
  late final String totalStudents;

  AttendanceDetailForClass(this.classCode, this.formattedDate,
      this.finalPresentStudentMapLength, this.totalStudents);

  AttendanceDetailForClass.fromMap(Map<String, dynamic> result)
            : id = result["id"],
              classCode = result["classCode"],
              formattedDate = result["formattedDate"],
              finalPresentStudentMapLength = result["finalPresentStudentMapLength"],
              totalStudents = result["totalStudents"];


  Map<String, dynamic> toMap(){

    var map = <String, dynamic>{
      "classCode": classCode,
      "formattedDate": formattedDate,
      "finalPresentStudentMapLength": finalPresentStudentMapLength,
      "totalStudents": totalStudents
    };
    if (id != null) {
      map["id"] = id;
    }
    return map;

  }

}