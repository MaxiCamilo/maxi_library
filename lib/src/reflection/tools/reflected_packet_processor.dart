import 'dart:async';
import 'dart:developer';

import 'package:maxi_library/export_reflectors.dart';

mixin ReflectedPacketProcessor {
  static final _methodsMap = <Type, List<IMethodReflection>>{};

  final _methods = <IMethodReflection>[];

  bool get enableSerialization => true;

  bool isPackageProcessable(dynamic item) {
    if (item == null) {
      return false;
    }
    return isTypeProcessable(item.runtimeType);
  }

  bool isTypeProcessable(Type type) {
    if (_methods.isEmpty) {
      _getMethods();
    }

    return _searchMethod(type) != null;
  }

  bool isStringTypeProcessable(String type) {
    if (_methods.isEmpty) {
      _getMethods();
    }

    return _methods.any(
      (x) => (x.namedParametes.isNotEmpty && x.namedParametes.first.type.toString() == type) || (x.fixedParametes.isNotEmpty && x.fixedParametes.first.type.toString() == type),
    );
  }

  FutureOr<T> processPackage<T>(Object package) async {
    if (_methods.isEmpty) {
      _getMethods();
    }

    final method = _searchMethod(package.runtimeType);

    if (method == null) {
      if (enableSerialization) {
        if (package is String) {
          return await processPackage(ConverterUtilities.interpretToObjectJson(text: package));
        } else if (package is Map<String, dynamic>) {
          return await processPackage(ConverterUtilities.castDynamicMap(map: package));
        }
      }

      return await processUnknownPackage<T>(package);
    }

    dynamic result = method.callMethod(
      instance: this,
      fixedParametersValues: [package],
      namedParametesValues: method.namedParametes.isEmpty ? {} : {method.namedParametes.first.name: package},
    );

    if (result is Future) {
      result = await result;
    }

    if (result is T) {
      return result;
    } else {
      throw NegativeResult(
        identifier: NegativeResultCodes.wrongType,
        message: Oration(
          message: 'The method assigned to package %1 returned a result %2 (named %3), but a result of type %4 was expected',
          textParts: [package.runtimeType, result.runtimeType, method.name, T],
        ),
      );
    }
  }

  Future<T> processUnknownPackage<T>(Object package) {
    throw NegativeResult(
      identifier: NegativeResultCodes.wrongType,
      message: Oration(
        message: 'No defined method to process package of type %1',
        textParts: [package.runtimeType],
      ),
    );
  }

  IMethodReflection? _searchMethod(Type parameterType) {
    //final isDynamic = (returnType == dynamic || returnType.toString() == 'void' || returnType == Future || returnType.toString() == 'Future' || returnType.toString() == 'Future<void>');
    return _methods.selectItem(
      (x) => (x.namedParametes.isNotEmpty && x.namedParametes.first.type == parameterType) || (x.fixedParametes.isNotEmpty && x.fixedParametes.first.type == parameterType),
    );
  }

  void _getMethods() {
    final extisting = _methodsMap[runtimeType];

    if (extisting != null) {
      _methods.addAll(extisting);
      return;
    }

    final reflector = ReflectionManager.getReflectionEntity(runtimeType);

    final candidates = reflector.methods.where((x) => (x.namedParametes.length == 1 && x.fixedParametes.isEmpty) || (x.fixedParametes.length == 1 && x.namedParametes.isEmpty)).toList(growable: false);

    if (candidates.isEmpty) {
      throw NegativeResult(
        identifier: NegativeResultCodes.implementationFailure,
        message: Oration(
          message: 'Packet processor %1 lacks methods for processing various packet types',
          textParts: [runtimeType],
        ),
      );
    }

    _methodsMap[runtimeType] = candidates;
    _methods.addAll(candidates);
  }

  StreamSubscription connectToChannel({required IChannel channel, StreamSink? invokerPackageSink, void Function()? onDone}) {
    if (this is PaternalFunctionality) {
      return (this as PaternalFunctionality).joinEvent(
        event: channel.receiver,
        onData: (x) => _processEvent(event: x, invokerPackageSink: invokerPackageSink),
        onDone: onDone,
      );
    } else {
      return channel.receiver.listen(
        (x) => _processEvent(event: x, invokerPackageSink: invokerPackageSink),
        onDone: onDone,
      );
    }
  }

  void _processEvent({required dynamic event, StreamSink? invokerPackageSink}) {
    if (event is String) {
      _processEvent(event: ConverterUtilities.interpretToObjectJson(text: event), invokerPackageSink: invokerPackageSink);
      return;
    }

    if (event is! Map<String, dynamic>) {
      processPackage(event);

      return;
    }

    final type = event.getRequiredValueWithSpecificType<String>('\$type');

    if (invokerPackageSink != null && TaskInvokerInStream.isInvokerEvent(type)) {
      invokerPackageSink.add(event);
      return;
    }

    if (!isStringTypeProcessable(type)) {
      log('[$runtimeType] Unknown entity received (${event.runtimeType})');
      return;
    }

    _processEvent(event: ConverterUtilities.castDynamicMap(map: event), invokerPackageSink: invokerPackageSink);
  }
}
