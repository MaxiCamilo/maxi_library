import 'dart:isolate';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process.dart';
import 'package:maxi_library/src/threads/isolates/channel_isolates.dart';
import 'package:maxi_library/src/threads/isolates/thread_communication_method_isolator.dart';

mixin AbylitysThreadLinkedSender on IThreadInvoker, IThreadProcess {
  final linkedConnectionList = <ThreadCommunicationMethodIsolator>[];

  SendPort linkedIsolator(SendPort port) {
    final channel = ChannelIsolates.createInitialChannelManually();
    final communicator = ThreadCommunicationMethodIsolator(channel: channel);
    linkedConnectionList.add(communicator);

    communicator.channel.finalizationNotifier.doOnDone(() => linkedConnectionList.remove(communicator));

    return channel.serder;
  }
}
