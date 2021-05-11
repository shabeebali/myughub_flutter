import 'InstitutionModel.dart';
import 'UserModel.dart';

class ClassroomModel {
  final int id;
  final String name;
  final String subject;
  final String code;
  final int created_by_id;
  final InstitutionModel? institution;
  final UserModel created_by;
  ClassroomModel({required this.id, required this.name, required this.subject, required this.code, required this.created_by_id,  this.institution, required this.created_by});

}