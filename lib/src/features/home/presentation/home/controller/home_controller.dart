import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/features/home/domain/model/activity_model.dart';
import 'package:ugz_app/src/features/home/domain/model/form_model.dart';
import 'package:ugz_app/src/features/home/domain/model/task_model.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_activities/get_activities.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_forms/get_forms_usecase.dart';
import 'package:ugz_app/src/features/home/domain/usecase/get_tasks/get_task_usecase.dart';
import 'package:ugz_app/src/utils/misc/result.dart';

final pageProvider = StateProvider<int>((ref) => 0);
