import 'package:usv_hub_management/core/consts.dart';
import 'package:usv_hub_management/features/add_teacher/domain/entities/user_entity.dart';
import 'package:usv_hub_management/features/add_teacher/domain/usecases/get_teacher_usecase.dart';
import 'package:usv_hub_management/features/view_departaments/domain/entities/course_entity.dart';
import 'package:usv_hub_management/features/view_departaments/domain/usecases/add_course_usecase.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddCourseProvider extends ChangeNotifier {
  final GetTeacherUsecase _getTeacherUsecase;
  final AddCourseUsecase _addCourseUsecase;

  AddCourseProvider(this._getTeacherUsecase, this._addCourseUsecase);
  bool? _isLoading = false;
  String? _title;
  int? _credits;
  String? _semesterid;
  int? _noOfCourses;
  String? _profesorId;
  String? _assistentId;
  String? _errorMessage;
  List<Map<String, dynamic>> _schedule = [];
  List<UserEntity> _profesors = [];
  bool _addButtonClicked = false;
  ClassType? _classType;
  CourseFrequency? _courseFrequency;
  DayOfWeek? _dayOfWeek;
  DateTime? _selectedStartHour;
  DateTime? _selectedEndHour;
  String? _classWhereHeld;

  bool? get isLoading => _isLoading;
  String? get getTitle => _title;
  int? get getCredits => _credits;
  String? get getSemesterId => _semesterid;
  int? get getNoOfCourses => _noOfCourses;
  String? get getProfesorId => _profesorId;
  String? get getAssistentId => _assistentId;
  List<Map<String, dynamic>> get getSchedule => _schedule;
  List<UserEntity> get getProfesors => _profesors;
  bool get getAddButtonClicked => _addButtonClicked;
  ClassType? get getClassType => _classType;
  CourseFrequency? get getCourseFrequency => _courseFrequency;
  DayOfWeek? get getDayOfWeek => _dayOfWeek;
  DateTime? get getSelectedStartHour => _selectedStartHour;
  DateTime? get getSelectedEndHour => _selectedEndHour;
  String? get getClassWhereHeld => _classWhereHeld;
  String? get getErrorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setCredits(int? value) {
    _credits = value;
    notifyListeners();
  }

  void setSemesterId(String? value) {
    _semesterid = value;
    notifyListeners();
  }

  void setNoOfCourses(int? value) {
    _noOfCourses = value;
    notifyListeners();
  }

  void setProfesorId(String? value) {
    _profesorId = value;
    notifyListeners();
  }

  void setAssistentId(String value) {
    _assistentId = value;
    notifyListeners();
  }

  void setSchedule(List<Map<String, dynamic>> value) {
    _schedule = value;
    notifyListeners();
  }

  void setProfesors(List<UserEntity> value) {
    _profesors = value;
    notifyListeners();
  }

  void setAddButtonClicked() {
    _addButtonClicked = !_addButtonClicked;
    notifyListeners();
  }

  void setClassType(ClassType value) {
    _classType = value;
    notifyListeners();
  }

  void setCourseFrequency(CourseFrequency value) {
    _courseFrequency = value;
    notifyListeners();
  }

  void setDayOfWeek(DayOfWeek value) {
    _dayOfWeek = value;
    notifyListeners();
  }

  void setSelectedStartHour(DateTime value) {
    _selectedStartHour = value;
    notifyListeners();
  }

  void setSelectedEndHour(DateTime value) {
    _selectedEndHour = value;
    notifyListeners();
  }

  void setClassWhereHeld(String value) {
    _classWhereHeld = value;
    notifyListeners();
  }

  void removeSchedule(int index) {
    _schedule.removeAt(index);
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> getTeachers(String departamentId) async {
    setLoading(true);
    final result = await _getTeacherUsecase.call(params: departamentId);
    result.fold(
      (l) {
        _errorMessage = l.message;
        setLoading(false);
        notifyListeners();
      },
      (r) {
        _profesors = r;
        setLoading(false);
        notifyListeners();
      },
    );
  }

  void addSchedule() {
    if (_classWhereHeld == null ||
        _classType == null ||
        _dayOfWeek == null ||
        _selectedStartHour == null ||
        _selectedEndHour == null ||
        _courseFrequency == null) {
      _errorMessage = "Please fill all the fields";
      notifyListeners();
      return;
    }
    Map<String, dynamic> schedule = {
      AppFields.classWhereHeld: _classWhereHeld,
      AppFields.classType: _classType!.stringValue,
      AppFields.dayOfWeek: _dayOfWeek!.index,
      AppFields.startingHour: _selectedStartHour!.hour,
      AppFields.endingHour: _selectedEndHour!.hour,
      AppFields.courseFrequency: _courseFrequency!.stringValue,
    };

    _schedule.add(schedule);
    _classWhereHeld = null;
    _classType = null;
    _dayOfWeek = null;
    _selectedStartHour = null;
    _selectedEndHour = null;
    _courseFrequency = null;

    setAddButtonClicked();
    notifyListeners();
  }

  Future<void> addCourse() async {
    if (_profesorId == null ||
        _assistentId == null ||
        _title == null ||
        _noOfCourses == null ||
        _credits == null ||
        _semesterid == null ||
        _schedule.isEmpty) {
      _errorMessage = "Please fill all the fields";
      notifyListeners();
      return;
    }
    setLoading(true);
    final CourseEntity courseEntity = CourseEntity(
      id: "",
      teacherId: _profesorId!,
      assistentId: _assistentId!,
      title: _title!,
      numberOfCourses: _noOfCourses!,
      courseCredits: _credits!,
      scheduleMap: _schedule,
      semesterId: _semesterid!,
    );
    final result = await _addCourseUsecase.call(
      params: courseEntity,
    );
    result.fold(
      (l) {
        _errorMessage = l.message;
        setLoading(false);
        notifyListeners();
      },
      (r) {
        setLoading(false);
        notifyListeners();
      },
    );
  }
}
