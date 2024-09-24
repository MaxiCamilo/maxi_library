import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/threads/interfaces/ithread_process_entity.dart';

mixin TemplateThreadProcessClienteEntityStandar<E> on IThreadProcessEntity<E> {
  bool _isAssigned = false;
  late E _entity;

  @override
  E get entity {
    checkProgrammingFailure(
      thatChecks: tr('[ThreadProcessClienteEntityStandar] No entity of type "$E" has been assigned yet'),
      result: () => _isAssigned,
    );

    return _entity;
  }

  @override
  Type get typeManager => E;

  @override
  set entity(E newItem) {
    _entity = newItem;
    _isAssigned = true;
  }
}
