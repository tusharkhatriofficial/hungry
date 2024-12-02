import 'package:flutter/material.dart';

class RecipeScreen extends StatelessWidget {
  final Map recipe;

  RecipeScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe['image']),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipe['title'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Ingredients:', style: TextStyle(fontSize: 18)),
            ),
            ...List.generate(
              recipe['extendedIngredients'].length,
                  (index) => ListTile(
                title: Text(recipe['extendedIngredients'][index]['name']),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Instructions:', style: TextStyle(fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(recipe['instructions'] ?? 'No instructions available'),
            ),
          ],
        ),
      ),
    );
  }
}
