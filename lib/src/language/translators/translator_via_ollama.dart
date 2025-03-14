import 'dart:convert';

import 'package:maxi_library/maxi_library.dart';
import 'package:maxi_library/src/language/interfaces/itext_traslator.dart';
import 'package:http/http.dart' as http;

class TranslatorViaOllama with ITextTraslator {
  final String url;
  final String prompt;
  final String model;

  const TranslatorViaOllama({required this.prompt, this.model = 'llama3.1', this.url = 'http://localhost:11434'});

  @override
  Future<String> traslateText(String text) async {
    final client = http.Client();
    final formattedUrl = url.startsWith('https') ? Uri.https(url.replaceAll('https://', ''), 'api/generate') : Uri.http(url.replaceAll('http://', ''), 'api/generate');
    try {
      final body = json.encode({
        'model': model,
        'stream': false,
        'prompt': prompt.replaceAll('%1', text),
      });
      final response = await client.post(formattedUrl, body: body);

      if (response.statusCode != 200) {
        throw NegativeResult(
          identifier: NegativeResultCodes.externalFault,
          message: Oration(message: 'The request to server %1 ended with an error, the error message is: %2', textParts: [url, response.body]),
        );
      }

      final responseJson = volatile(detail: Oration(message: 'Processing server response %1, expected a JSON object.', textParts: [url]), function: () => json.decode(response.body) as Map<String, dynamic>);
      final data = responseJson['response'];

      if (data == null) {
        throw NegativeResult(
          identifier: NegativeResultCodes.resultInvalid,
          message: Oration(message: 'The server %1 did not return data', textParts: [url]),
        );
      }

      return data.toString();
    } finally {
      client.close();
    }
  }
}
