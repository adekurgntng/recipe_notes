import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'detail_recipe.dart';

class FavoriteRecipes extends StatelessWidget {
  final List<Recipe> favoriteRecipes;

  const FavoriteRecipes({super.key, required this.favoriteRecipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorite Recipes"),
        backgroundColor: Colors.deepOrange,
      ),
      body: favoriteRecipes.isEmpty
          ? Center(child: Text('No favorite recipes'))
          : ListView.builder(
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    title: Text(
                      favoriteRecipes[index].title,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailRecipe(
                            recipe: favoriteRecipes[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
