import 'dart:async';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/isolates/channels/extern_isolate_channel.dart';
import 'package:maxi_library/src/threads/isolates/channels/local_isolate_channel.dart';

mixin IIsolateThreadChannelManager {
  Future<int> createLocalChannel<R, S>({required InvocationContext parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function});
  Future<IChannel<S, R>> createExternalChannel<R, S>({required InvocationParameters parameters, required FutureOr<void> Function(InvocationContext context, IChannel<R, S> channel) function});

  Future<void> closeLocalChannel({required int identifier});
  Future<void> closeExternalChannel({required int identifier});

  Future<void> reactCloseLocalChannel({required int identifier});
  Future<void> reactcloseExternalChannel({required int identifier});

  Future<void> sendLocalValue({required int identifier, dynamic value});
  Future<void> sendExternalValue({required int identifier, dynamic value});

  Future<void> sendLocalError({required int identifier, required Object error, required StackTrace? stackTrace});
  Future<void> sendExternalError({required int identifier, required Object error, required StackTrace? stackTrace});

  void receiveLocalValue({required int identifier, dynamic value});
  void receiveExternalValue({required int identifier, dynamic value});

  void receiveLocalError({required int identifier, required Object error, required StackTrace? stackTrace});
  void receiveExternalError({required int identifier, required Object error, required StackTrace? stackTrace});

  Future<void> searchLocalChannel({required int identifier, required FutureOr<void> Function(LocalIsolateChannel) function});
  Future<void> searchExternalChannel({required int identifier, required FutureOr<void> Function(ExternIsolateChannel) function});

  void closeAll();
}
