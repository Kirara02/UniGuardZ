enum AuthType { none, bearer, basic }

enum PendingFormCategory {
  forms(1),
  tasks(2),
  activity(3);

  final int value;

  const PendingFormCategory(this.value);

  // You might want to add a helper method to get the enum from the value:
  static PendingFormCategory fromValue(int value) {
    return PendingFormCategory.values.firstWhere((e) => e.value == value);
  }
}

enum FormType { FORMS, TASKS }

enum FieldTypes {
  text(1),
  input(2),
  checkbox(3),
  image(4),
  signature(5),
  select(6),
  number(7),
  email(8);

  final int value;

  const FieldTypes(this.value);

  static FieldTypes fromValue(int value) {
    return FieldTypes.values.firstWhere((e) => e.value == value);
  }
}

enum HistoryType {
  pending("pending"),
  uploaded("uploaded");

  final String value;

  const HistoryType(this.value);

  static HistoryType fromValue(String value) {
    return HistoryType.values.firstWhere((e) => e.value == value);
  }
}
