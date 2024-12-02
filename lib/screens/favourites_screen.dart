import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavouritesScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void showRecipeDetails(BuildContext context, Map recipe) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    recipe['title'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(recipe['image'], fit: BoxFit.cover),
                ),
                SizedBox(height: 20),
                Text('Ingredients:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...List.generate(
                  (recipe['ingredients'] as List).length,
                      (index) => ListTile(
                    title: Text(recipe['ingredients'][index]['name']),
                  ),
                ),
                SizedBox(height: 20),
                Text('Instructions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(recipe['instructions']),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteRecipe(String id) async {
    await _firestore.collection('favourites').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourites'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('favourites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No favourites yet!'));
          } else {
            final docs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data();
                final id = docs[index].id;
                return ListTile(
                  leading: Image.network(data['image'], fit: BoxFit.cover, width: 50, height: 50),
                  title: Text(data['title']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteRecipe(id),
                  ),
                  onTap: () => showRecipeDetails(context, data),
                );
              },
            );
          }
        },
      ),
    );
  }
}
