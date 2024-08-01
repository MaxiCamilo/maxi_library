import 'dart:async';

import 'package:maxi_library/src/threads/abilitys/iability_receive_trhead_messages.dart';
import 'package:maxi_library/src/threads/abilitys/iability_send_thread_messages.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_communication_method.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_message.dart';
import 'package:maxi_library/src/threads/isolates/channel_isolates.dart';

class ThreadCommunicationMethodIsolator with IThreadCommunicationMethod, IAbilityReceiveThreadMessages, IAbilitySendThreadMessages {
  final ChannelIsolates channel;

  final _threadMessageNotifier = StreamController<IThreadMessage>.broadcast();

  final _threadUnkownNotifier = StreamController.broadcast();

  @override
  IAbilitySendThreadMessages get sender => this;

  @override
  IAbilityReceiveThreadMessages get receiver => this;

  @override
  Stream<IThreadMessage> get receivedMessage => _threadMessageNotifier.stream;

  @override
  Stream get receivedUnknownMaterial => _threadUnkownNotifier.stream;

  @override
  bool get isActive => channel.isActive;

  ThreadCommunicationMethodIsolator({required this.channel}) {
    channel.dataReceivedNotifier.listen(_reactObjetReceivedIsolator, onDone: closeCommunication);
  }

  @override
  Future<void> closerConnection() async {
    channel.closeConnection();

    _threadMessageNotifier.close();
    _threadUnkownNotifier.close();
  }

  @override
  Future<void> sendMessage(IThreadMessage message) async {
    channel.sendObject(message);
  }

  @override
  Future<void> sendUnkownMaterial(any) async {
    channel.sendObject(any);
  }

  void _reactObjetReceivedIsolator(event) {
    if (event is IThreadMessage) {
      _threadMessageNotifier.add(event);
    } else {
      _threadUnkownNotifier.add(event);
    }
  }
  
  
}
