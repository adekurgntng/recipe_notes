import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_notesapp/add_recipe.dart';
import 'package:recipe_notesapp/edit_recipe.dart';
import 'package:recipe_notesapp/detail_recipe.dart';
import 'package:recipe_notesapp/favorite_recipes.dart';
import 'models/recipe.dart';

class HomeRecipe extends StatefulWidget {
  const HomeRecipe({super.key});

  @override
  State<HomeRecipe> createState() => _HomeRecipeState();
}

class _HomeRecipeState extends State<HomeRecipe> {
  List<Recipe> _listdata = [];
  List<Recipe> _filteredData = [];
  bool _loading = true;
  TextEditingController _searchController = TextEditingController();

  Future<void> _getdata() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.130/recipe_api/read_recipes.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final loadedRecipes = data.map((recipeJson) => Recipe.fromJson(recipeJson)).toList();
        await _loadFavorites(loadedRecipes);
        setState(() {
          _listdata = loadedRecipes;
          _filteredData = _listdata;
          _loading = false;
        });
      } else {
        print('Failed to load recipes');
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteData(String id) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.130/recipe_api/delete_recipe.php'),
        body: jsonEncode({'id': id}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _listdata.removeWhere((recipe) => recipe.id == id);
          _filteredData = _listdata;
        });
      } else {
        print('Failed to delete recipe');
      }
    } catch (e) {
      print('Error deleting recipe: $e');
    }
  }

  void _searchRecipe(String query) {
    setState(() {
      _filteredData = _listdata
          .where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadFavorites(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoriteRecipeIds') ?? [];
    for (var recipe in recipes) {
      recipe.isFavorite = favoriteIds.contains(recipe.id);
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = _listdata.where((recipe) => recipe.isFavorite).map((recipe) => recipe.id).toList();
    await prefs.setStringList('favoriteRecipeIds', favoriteIds);
  }

  void _toggleFavorite(Recipe recipe) {
    setState(() {
      recipe.isFavorite = !recipe.isFavorite;
      _saveFavorites();
    });
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoriteRecipes(favoriteRecipes: _listdata.where((recipe) => recipe.isFavorite).toList()),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menghapus resep ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteData(id);
            },
            child: Text('Ya'),
          ),
        ],
      ),
    );
  }

  void _editRecipe(Recipe recipe) async {
    final editedRecipe = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipe(recipe: recipe),
      ),
    );
    if (editedRecipe != null) {
      setState(() {
        int index = _listdata.indexWhere((r) => r.id == editedRecipe.id);
        if (index != -1) {
          _listdata[index] = editedRecipe;
          _filteredData = List.from(_listdata);
          _saveFavorites();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resep Saya"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: _navigateToFavorites,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Recipes...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _searchRecipe,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredData.length,
                    itemBuilder: ((context, index) {
                      return Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          title: Text(
                            _filteredData[index].title,
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _filteredData[index].isFavorite
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.yellow,
                                ),
                                onPressed: () {
                                  _toggleFavorite(_filteredData[index]);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  _editRecipe(_filteredData[index]);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(_filteredData[index].id);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailRecipe(recipe: _filteredData[index]),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipe(),
            ),
          ).then((value) => _getdata());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
