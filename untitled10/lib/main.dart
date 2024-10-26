import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled10/CategorySelector.dart';
import 'dart:convert';
import 'package:untitled10/news_list.dart';
import 'package:untitled10/search_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crewin News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: NewsHomePage(),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  List<dynamic> articles = [];
  List<dynamic> filteredArticles = [];
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'general';

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  void loadNews() async {
    var newsService = NewsService();
    var newsArticles = await newsService.fetchNews(selectedCategory);
    setState(() {
      articles = newsArticles;
      filteredArticles = newsArticles;
    });
  }

  void onSearch(String query) {
    setState(() {
      filteredArticles = articles.where((article) {
        final title = article['title'].toLowerCase();
        final searchLower = query.toLowerCase();
        return title.contains(searchLower);
      }).toList();
    });
  }

  void onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
      loadNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fiber_new_sharp, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Flutter',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            Text(
              ' News',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBarr(
              controller: searchController,
              onSearch: onSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CategorySelector(onCategoryChanged: onCategoryChanged),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: NewsList(articles: filteredArticles),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsService {
  final String apiKey = 'API KEY';

  Future<List<dynamic>> fetchNews(String category) async {
    final url =
        'https://newsapi.org/v2/top-headlines?category=$category&apiKey=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}