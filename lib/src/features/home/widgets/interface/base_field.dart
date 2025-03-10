import '../../domain/model/field_model.dart';

abstract class BaseField {
  String get IFieldTypeId;
  String get IFieldName;
  String get Iid;
  bool get IActive;
  bool get IRequired;
  PickList? get IPickList;
}
