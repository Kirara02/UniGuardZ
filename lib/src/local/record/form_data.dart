class FormData {
  final List<FormStringEntry> comments;
  final List<FormStringEntry> switches;
  final List<FormFileEntry> photos;
  final List<FormFileEntry> signatures;
  final List<FormSelectEntry> selects;

  FormData({
    this.comments = const [],
    this.switches = const [],
    this.photos = const [],
    this.signatures = const [],
    this.selects = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'comments': comments.map((e) => e.toJson()).toList(),
      'switches': switches.map((e) => e.toJson()).toList(),
      'photos': photos.map((e) => e.toJson()).toList(),
      'signatures': signatures.map((e) => e.toJson()).toList(),
      'selects': selects.map((e) => e.toJson()).toList(),
    };
  }

  factory FormData.fromJson(Map<String, dynamic> json) {
    return FormData(
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => FormStringEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      switches:
          (json['switches'] as List<dynamic>?)
              ?.map((e) => FormStringEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => FormFileEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      signatures:
          (json['signatures'] as List<dynamic>?)
              ?.map((e) => FormFileEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      selects:
          (json['selects'] as List<dynamic>?)
              ?.map((e) => FormSelectEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FormStringEntry {
  final int id;
  final String? inputName;
  final String? value;

  FormStringEntry({required this.id, this.inputName, this.value});

  Map<String, dynamic> toJson() {
    return {'id': id, 'inputName': inputName, 'value': value};
  }

  factory FormStringEntry.fromJson(Map<String, dynamic> json) {
    return FormStringEntry(
      id: json['id'] as int,
      inputName: json['inputName'] as String?,
      value: json['value'] as String?,
    );
  }
}

class FormFileEntry {
  final int id;
  final String? inputName;
  final String? value;

  FormFileEntry({required this.id, this.inputName, this.value});

  Map<String, dynamic> toJson() {
    return {'id': id, 'inputName': inputName, 'value': value};
  }

  factory FormFileEntry.fromJson(Map<String, dynamic> json) {
    return FormFileEntry(
      id: json['id'] as int,
      inputName: json['inputName'] as String?,
      value: json['value'] as String?,
    );
  }
}

class FormSelectEntry {
  final int id;
  final String? inputName;
  final int pickListId;
  final String? pickListName;
  final String? value;
  final String? pickListOptionName;
  final int pos;

  FormSelectEntry({
    required this.id,
    this.inputName,
    required this.pickListId,
    this.pickListName,
    this.value,
    this.pickListOptionName,
    required this.pos,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inputName': inputName,
      'pickListId': pickListId,
      'pickListName': pickListName,
      'value': value,
      'pickListOptionName': pickListOptionName,
      'pos': pos,
    };
  }

  factory FormSelectEntry.fromJson(Map<String, dynamic> json) {
    return FormSelectEntry(
      id: json['id'] as int,
      inputName: json['inputName'] as String?,
      pickListId: json['pickListId'] as int,
      pickListName: json['pickListName'] as String?,
      value: json['value'] as String?,
      pickListOptionName: json['pickListOptionName'] as String?,
      pos: json['pos'] as int,
    );
  }
}
