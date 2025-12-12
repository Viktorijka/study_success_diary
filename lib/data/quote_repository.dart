import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/quote_model.dart';

class QuoteRepository {
  // Використовуємо безкоштовний API для отримання цитат
  static const String _baseUrl = 'https://dummyjson.com/quotes/random';

  Future<Quote> getRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quote.fromJson(data);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      // Повертаємо заглушку у разі помилки (наприклад, немає інтернету)
      return Quote(text: "Помилка завантаження цитати", author: "Система");
    }
  }
}