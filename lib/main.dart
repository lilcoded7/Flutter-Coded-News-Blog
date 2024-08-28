import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';  // Import url_launcher package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  Future<List<News>> fetchNews() async {
    final response = await http.get(Uri.parse('https://codednewsapi.onrender.com/blog/news/'));
    
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((newsJson) => News.fromJson(newsJson)).toList();
    } else {
      throw Exception('Failed to load news: ${response.statusCode}\n${response.body}');
    }
  }

  Future<void> _launchChatSupport() async {
    const chatUrl = 'https://tawk.to/chat/6405c8df4247f20fefe43d51/1gqr9hbfj';
    if (await canLaunch(chatUrl)) {
      await launch(chatUrl);
    } else {
      throw 'Could not launch $chatUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter News App'),
      ),
      body: FutureBuilder<List<News>>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load news:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No news available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                News news = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      news.newsImage != null
                          ? Image.network(news.newsImage!)
                          : SizedBox.shrink(),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.nameOrTitle,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(news.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchChatSupport,
        child: Icon(Icons.chat),
        tooltip: 'Chat Support',
      ),
    );
  }
}

class News {
  final int id;
  final String nameOrTitle;
  final String description;
  final String? newsImage;
  final int category;

  News({
    required this.id,
    required this.nameOrTitle,
    required this.description,
    this.newsImage,
    required this.category,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      nameOrTitle: json['name_or_title'],
      description: json['description'],
      newsImage: json['news_image'],
      category: json['category'],
    );
  }
}
