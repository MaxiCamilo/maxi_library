@Timeout(Duration(minutes: 30))
import 'package:deepseek/deepseek.dart';
import 'package:test/test.dart';

void main() {
  group('Deepseek Translate', () {
    setUp(() {});

    test('First function', () async {
      final deepSeek = DeepSeek("QUETEIMPORTA");

      try {
        // Create a chat completion -> https://api-docs.deepseek.com/api/create-chat-completion
        final response = await deepSeek.createChat(
          messages: [
            Message(
              role: 'system',
              content: '''
You are assuming the role of translator. You will receive a CSV file containing text enclosed in English quotation marks.
Your job is to translate the received text into Spanish and generate a JSON object. The property is the English text, and the value is the translated text.
If possible, make sure it is a natural and accurate translation.
You should keep in mind:
-You don't need to explain what you did; just return the JSON.
-It must return a JSON object; it must start with "{" and end with "}".
-Remove the quotation marks at the beginning and end of the text read.
-The received content must be convertible to a Map<String,dynamic> in Dart.
-If the original text does not end with ".", avoid adding the "." to its translation.
''',
            ),
            Message(
              role: 'user',
              content:
                  '"Line %1 of property %2 is %3 characters long, but a maximum of %4 characters is accepted","The thread took too long to confirm a feature","The file located at %1 cannot be read because its size exceeds the allowed limit (%2 kb > %3 kb)","The table has %1 rows, but an attempt was made to get the %2 position (starting from zero)"',
            ),
          ],
          model: 'deepseek-reasoner',
          /*
          options: {
            "temperature": 1.0,
            "max_tokens": 4096,
          },*/
        );
        print("Chat Response: ${response.textUtf8}");

        // List available models
        final models = await deepSeek.listModels();
        print("Available Models: $models");

        // Get user balance
        final balance = await deepSeek.getUserBalance();
        print("User Balance: ${balance.info}");
      } catch (e) {
        print("something unexpected happened: $e");
      }
    });
  });
}
