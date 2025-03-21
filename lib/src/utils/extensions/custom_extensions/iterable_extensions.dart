part of '../custom_extensions.dart';

extension IterableExtensions<T> on Iterable<T>? {
  bool get isNull => this == null;

  bool get isBlank => isNull || this!.isEmpty;

  bool get isNotBlank => !isBlank;

  bool get isSingletonList => isNotBlank && this!.length == 1;

  T? get firstOrNull {
    if (isNull) return null;
    var iterator = this!.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }

  String get toPath => isNotBlank ? this!.join("/") : "/";

  T? lastWhereOrNull(bool Function(T element) test, {T Function()? orElse}) {
    if (isNull) return null;
    try {
      return this!.lastWhere(test, orElse: orElse);
    } catch (e) {
      return null;
    }
  }

  T? firstWhereOrNull(bool Function(T element) test, {T Function()? orElse}) {
    if (isNull) return null;
    try {
      return this!.firstWhere(test, orElse: orElse);
    } catch (e) {
      return null;
    }
  }

  T? get getRandom =>
      isNull ? null : this!.elementAt(Random().nextInt(this!.length));

  Iterable<T>? get filterOutNulls => this?.where((element) => element != null);
}
