import 'package:maxi_library/maxi_library.dart';

class ConsoleCommandProcessor with IFunctionality<ConsoleCommandInterpretResult> {
  final List<String> arguments;
  final bool caseSensitive;
  final String classifyingCharacter;

  const ConsoleCommandProcessor({required this.arguments, this.caseSensitive = true, this.classifyingCharacter = '-'});

  @override
  ConsoleCommandInterpretResult runFunctionality() {
    final directCommands = <String>[];
    final classifiedCommands = <String, List<String>>{};

    bool onDirectCommand = true;
    bool onInsideCommand = false;
    String command = '';

    for (final item in arguments) {
      if (item.startsWith(classifyingCharacter)) {
        onDirectCommand = false;
        onInsideCommand = true;
        command = item.extractFrom(since: classifyingCharacter.length);
        if (!caseSensitive) {
          command = command.toLowerCase();
        }
        if (!classifiedCommands.containsKey(command)) {
          classifiedCommands[command] = <String>[];
        }
      } else if (onDirectCommand) {
        directCommands.add(item);
      } else if (onInsideCommand) {
        classifiedCommands[command]!.add(item);
      } else {
        if (!classifiedCommands.containsKey('')) {
          classifiedCommands[''] = <String>[];
        }

        classifiedCommands['']!.add(item);
      }
    }

    return ConsoleCommandInterpretResult(classifiedCommands: classifiedCommands, directCommands: directCommands);
  }
}
