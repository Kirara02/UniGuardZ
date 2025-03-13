import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ugz_app/src/local/interface/pending_forms_repository.dart';
import 'package:ugz_app/src/local/record/pending_forms_model.dart';
import 'package:ugz_app/src/local/repository/pending_forms_repository_impl.dart';
import 'package:ugz_app/src/local/usecases/stream_pending_forms/stream_pending_forms_params.dart';
import 'package:ugz_app/src/utils/misc/usecase.dart';

part 'stream_pending_forms.g.dart';

class StreamPendingForms
    implements
        UseCase<Stream<List<PendingFormsModel>>, StreamPendingFormsParams> {
  final PendingFormsRepository _repository;

  StreamPendingForms({required PendingFormsRepository repository})
    : _repository = repository;

  @override
  Future<Stream<List<PendingFormsModel>>> call(
    StreamPendingFormsParams params,
  ) async {
    final result = _repository.streamUsersHistories(
      partitionKey: "user:${params.userId}",
    );

    return result;
  }
}

@riverpod
StreamPendingForms dbStreamPendingForms(DbStreamPendingFormsRef ref) =>
    StreamPendingForms(repository: ref.watch(pendingFormsRepositoryProvider));
