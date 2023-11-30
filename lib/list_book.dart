import 'dart:convert';
import 'package:http/http.dart' as http;

class ListBook {
  static Future<List<Map<String, dynamic>>> livrosDisponiveis() async {
    final response = await http.get(Uri.parse('https://escribo.com/books.json'));

    if (response.statusCode == 200) {
      List<dynamic> bookData = json.decode(response.body);

      if (bookData.isNotEmpty) {
        List<Map<String, dynamic>> booksWithDetails = bookData.map((book) {
          return {
            'id': book['id'],
            'title': book['title'],
            'author': book['author'],
            'cover_url': book['cover_url'],
            'download_url': book['download_url'],
          };
        }).toList();

        return booksWithDetails;
      } else {
        return []; // Retorna uma lista vazia se não houver livros disponíveis
      }
    } else {
      throw Exception('Falha ao carregar os livros');
    }
  }
}

