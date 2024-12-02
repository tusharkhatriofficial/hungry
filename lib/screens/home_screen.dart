import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_screen.dart';
import 'favourites_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _query = '';

  Future<List> fetchRecipes(String query) async {
    final apiKey = 'acbd85e921c54bb2a4fedaaec8ef8368'; // Replace with your API key
    final url = query.isEmpty
        ? 'https://api.spoonacular.com/recipes/random?apiKey=$apiKey&number=10'
        : 'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&query=$query&number=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return query.isEmpty ? data['recipes'] : data['results'];
    } else {
      throw Exception('Failed to load recipes: ${response.statusCode}');
    }
  }

  Future<void> addToFavorites(Map recipe) async {
    try {
      await _firestore.collection('favourites').add({
        'title': recipe['title'],
        'image': recipe['image'],
        'ingredients': recipe['extendedIngredients'] ?? [],
        'instructions': recipe['instructions'] ?? 'No instructions available',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe['title']} added to favorites!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Recipes'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavouritesScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _query = _searchController.text.trim();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchRecipes(_query),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final recipes = snapshot.data as List;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        child: Column(
                          children: [
                            Image.network(recipe['image'], fit: BoxFit.cover, height: 100),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(recipe['title'], maxLines: 2),
                            ),
                            IconButton(
                              icon: Icon(Icons.favorite_border),
                              onPressed: () => addToFavorites(recipe),
                            ),
                            TextButton(
                              child: Text('View Recipe'),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeScreen(recipe: recipe),
                                ),
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
          ),
        ],
      ),
    );
  }
}
