import 'package:ebookchallenge/book_screen.dart';
import 'package:ebookchallenge/favorite_storage.dart';
import 'package:ebookchallenge/list_book.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<dynamic> books = [];
  bool showFavorites = false;
  final FavoritesStorage favoritesStorage = FavoritesStorage();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadBooks();
    await _loadFavorites();
  }

  Future<void> _loadBooks() async {
    try {
      List<dynamic> fetchedBooks = await ListBook.livrosDisponiveis();
      setState(() {
        books = fetchedBooks;
      });
    } catch (e) {
      print('Erro ao carregar os livros: $e');
     
    }
  }

  Future<void> _loadFavorites() async {
    List<String> favoriteBookIds = await favoritesStorage.getFavorites();
    setState(() {
      for (var book in books) {
        book['isFavorite'] = favoriteBookIds.contains(book['id'].toString());
      }
    });
  }

  List<dynamic> getFilteredBooks() {
    if (showFavorites) {
      return books.where((book) => book['isFavorite'] == true).toList();
    } else {
      return books;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Biblioteca virtual',
            style: TextStyle(color: Colors.white),
          ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showFavorites = false;
                      });
                    },
                    child: const Text('Todos os Livros'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showFavorites = true;
                      });
                    },
                    child: const Text('Favoritos'),
                  ),
                ],
              ),
              Expanded(
                child: books.isNotEmpty
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: getFilteredBooks().length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookScreen(
                                    bookPath: getFilteredBooks()[index]['download_url'],
                                    bookId: getFilteredBooks()[index]['id'].toString(),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              margin: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Image.network(
                                    getFilteredBooks()[index]['cover_url'],
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: -2.0,
                                    right: -2.0,
                                    child: GestureDetector(
                                    onTap: () async {
                                    bool isFavorite = getFilteredBooks()[index]['isFavorite'] ?? false;

                                    setState(() {
                                      getFilteredBooks()[index]['isFavorite'] = !isFavorite;
                                    });

                                    List<String> favorites = await favoritesStorage.getFavorites();
                                    
                                    setState(() {
                                      if (isFavorite) {
                                        favorites.remove(getFilteredBooks()[index]['id'].toString());
                                      } else {
                                        favorites.add(getFilteredBooks()[index]['id'].toString());
                                      }
                                      favoritesStorage.saveFavorites(favorites);
                                    });
                                  },
                                      child: Icon(
                                        getFilteredBooks()[index]['isFavorite'] == true
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: getFilteredBooks()[index]['isFavorite'] == true
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
