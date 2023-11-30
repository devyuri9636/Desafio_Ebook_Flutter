import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'list_book.dart';

class BookScreen extends StatefulWidget {
  final String bookId;
  final String bookPath;

  const BookScreen({
    Key? key,
    required this.bookId,
    required this.bookPath,
  }) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  bool loading = false;
  String? filePath;
  Map<String, dynamic> bookDetails = {}; // Adicionando para armazenar os detalhes do livro

  @override
  void initState() {
    super.initState();
    fetchBookDetails(); // Carrega os detalhes do livro ao iniciar a tela
  }

  Future<void> fetchBookDetails() async {
    try {
      List<Map<String, dynamic>> books = await ListBook.livrosDisponiveis();
      setState(() {
        bookDetails = books.firstWhere(
          (book) => book['id'].toString() == widget.bookId,
          orElse: () => {}, // Tratar se o livro não for encontrado
        );
      });
    } catch (e) {
      print('Erro ao carregar detalhes do livro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Livro selecionado', style: TextStyle(color: Colors.white),),
      ),
      body: Container(
         decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://i.imgur.com/9DlFuu8.jpeg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            color: const Color.fromARGB(255, 223, 222, 222),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bookDetails.isNotEmpty) // Verifica se há detalhes do livro
                  Column(
                    children: [
                      Image.network(
                        bookDetails['cover_url'],
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        bookDetails['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ElevatedButton(
                  
                  onPressed: () async {
                    await _downloadAndOpenEpub(bookDetails);
                  },
                  child: const Text('Abrir eBook'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchBooks() async {
    try {
      return await ListBook.livrosDisponiveis();
    } catch (e) {
      // Lida com erros ao carregar os livros
      print('Erro ao carregar os livros: $e');
      return [];
    }
  }

  Future<void> _downloadAndOpenEpub(Map<String, dynamic> bookDetails) async {
    setState(() {
      loading = true;
    });

    Directory? appDocDir = await getApplicationDocumentsDirectory();
    // ignore: prefer_interpolation_to_compose_strings
    String path = appDocDir.path + '/sample.epub';
    File file = File(path);

    if (!file.existsSync()) {
      await file.create();
      Dio dio = Dio();
      await dio.download(
        bookDetails['download_url'],
        path,
        deleteOnError: true,
      );

      setState(() {
        loading = false;
        filePath = path;
      });
    } else {
      setState(() {
        loading = false;
        filePath = path;
      });
    }

    if (filePath != null) {
      _openEpub(filePath!);
    }
  }

  void _openEpub(String filePath) {
    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: "iosBook",
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      allowSharing: true,
      enableTts: true,
      nightMode: true,
    );

    VocsyEpub.open(
      filePath,
      lastLocation: EpubLocator.fromJson({
        "bookId": widget.bookId,
        "href": "/OEBPS/ch06.xhtml",
        "created": 1539934158390,
        "locations": {
          "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
        }
      }),
    );

    VocsyEpub.locatorStream.listen((locator) {
      print('LOCATOR: $locator');
      // Salvar o localizador convertendo-o de string para JSON no banco de dados para recuperação posterior
    });
  }
}
