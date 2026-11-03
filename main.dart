
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'article_model.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const BeritaScreen(),
    );
  }
}

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  late Future<List<Article>> _articlesFuture;

  final ScrollController _scrollController = ScrollController();

  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    _articlesFuture = ApiService().fetchArticles();

    // Mendeteksi posisi scroll
    _scrollController.addListener(() {
      if (_scrollController.offset > 50) {
        if (!_showBackToTop) {
          setState(() {
            _showBackToTop = true;
          });
        }
      } else {
        if (_showBackToTop) {
          setState(() {
            _showBackToTop = false;
          });
        }
      }
    });
  }

  // Fitur pull to refresh
  Future<void> _refreshArticles() async {
    final newArticles = ApiService().fetchArticles();

    setState(() {
      _articlesFuture = newArticles;
    });

    await newArticles;
  }

  // Fitur kembali ke atas
  void _backToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Berita'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final articles = snapshot.data!;

            return ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: RefreshIndicator(
                onRefresh: _refreshArticles,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: article.urlimage != null
                            ? Image.network(
                                article.urlimage!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              )
                            : const Icon(Icons.image),

                        title: Text(article.title),

                        subtitle: Text(
                          article.description ?? 'Tidak ada deskripsi',
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),

      // Tombol kembali ke atas
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _backToTop,
              backgroundColor: Colors.blue,
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
