part of '../custom_extensions.dart';

extension AsyncValueExtensions<T> on AsyncValue<T> {
  bool get isNotLoading => !isLoading;

  void _showToastOnError(Toast toast) {
    if (!isRefreshing) {
      whenOrNull(
        error: (error, stackTrace) {
          toast.close();
          toast.showError(error.toString());
        },
      );
    }
  }

  void showToastOnError(Toast toast, {bool withMicrotask = false}) {
    if (withMicrotask) {
      Future.microtask(() => (this._showToastOnError(toast)));
    } else {
      this._showToastOnError(toast);
    }
  }

  T? valueOrToast(Toast toast, {bool withMicrotask = false}) =>
      (this..showToastOnError(toast, withMicrotask: withMicrotask)).valueOrNull;

  Widget showUiWhenData(
    BuildContext context,
    Widget Function(T data) data, {
    VoidCallback? refresh,
    Widget Function(Widget)? wrapper,
    bool showGenericError = false,
    bool addScaffoldWrapper = false,
  }) {
    if (addScaffoldWrapper) {
      wrapper = (body) => Scaffold(appBar: AppBar(), body: body);
    }
    return when(
      data: data,
      skipError: true,
      error: (error, trace) => AppUtils.wrapIf(
          wrapper,
          Emoticons(
            text:  showGenericError ? "Something error" : error.toString(),
            button: refresh != null
                ? TextButton(
                    onPressed: refresh,
                    child: const Text("Refresh"),
                  )
                : null,
          )),
      loading: () =>
          AppUtils.wrapIf(wrapper, const CircularProgressIndicator()),
    );
  }

  AsyncValue<U> copyWithData<U>(U Function(T) data) => when(
        skipError: true,
        data: (prev) => AsyncData(data(prev)),
        error: (error, stackTrace) => AsyncError<U>(error, stackTrace),
        loading: () => AsyncLoading<U>(),
      );
}
