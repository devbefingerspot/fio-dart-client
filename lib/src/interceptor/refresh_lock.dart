import 'dart:async';

/// Single-flight lock for token refresh.
///
/// When a refresh is already in-flight, any concurrent caller receives the
/// **same** [Future] instead of triggering a second network request — exactly
/// like the JavaScript `refreshPromise` pattern in authAxios.ts.
class TokenRefreshLock {
  Completer<String>? _completer;

  /// `true` while a refresh call is in progress.
  bool get isRefreshing =>
      _completer != null && !_completer!.isCompleted;

  /// Runs [fn] as the single-flight refresh operation.
  ///
  /// - If no refresh is in-flight, [fn] is called immediately and its result
  ///   (or error) is broadcast to all concurrent waiters via a [Completer].
  /// - If a refresh is already in-flight, [fn] is **not** called; this
  ///   invocation simply awaits the existing [Future].
  ///
  /// Returns the new access token on success.
  /// Rethrows whatever [fn] throws so every waiter sees the same error.
  Future<String> run(Future<String> Function() fn) async {
    if (isRefreshing) {
      return _completer!.future;
    }

    final completer = Completer<String>();
    _completer = completer;

    try {
      final token = await fn();
      completer.complete(token);
      return token;
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      // Clear after completion so future 401s can start a fresh lock.
      _completer = null;
    }
  }
}
