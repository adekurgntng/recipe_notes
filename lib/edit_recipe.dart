import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Commented out to disable image picker
import 'package:http/http.dart' as http;
import 'models/recipe.dart';

class EditRecipe extends StatefulWidget {
  final Recipe recipe;

  EditRecipe({required this.recipe});

  @override
  _EditRecipeState createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _instructionsController;
  late List<Map<String, String>> _selectedIngredients;
  // XFile? _image; // Commented out to disable image picker
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _instructionsController = TextEditingController(text: widget.recipe.instructions);
    _selectedIngredients = widget.recipe.ingredients
        .split('\n')
        .map((ingredient) {
          final parts = ingredient.split(' - ');
          return {'name': parts[0], 'quantity': parts[1]};
        })
        .toList();
    _isFavorite = widget.recipe.isFavorite;
    // Decode image if it exists
    // if (widget.recipe.image != null) {
    //   final bytes = base64Decode(widget.recipe.image!);
    //   _image = XFile.fromData(bytes, name: 'recipe_image');
    // }
  }

  // Future<void> _pickImage() async {
  //   final ImagePicker _picker = ImagePicker();
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       _image = image;
  //     });
  //   }
  // }

  void _updateRecipe() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final instructions = _instructionsController.text;
      final ingredients = _selectedIngredients
          .map((ingredient) =>
              '${ingredient['name']} - ${ingredient['quantity']}')
          .join('\n');

      // String? imageUrl;
      // if (_image != null) {
      //   final bytes = await _image!.readAsBytes();
      //   imageUrl = base64Encode(bytes);
      // }

      final recipeData = {
        'id': widget.recipe.id,
        'title': title,
        'ingredients': ingredients,
        'instructions': instructions,
        // 'image': imageUrl, // Commented out to disable image picker
        'isFavorite': _isFavorite,
      };

      try {
        final response = await http.post(
          Uri.parse('http://192.168.43.130/recipe_api/update_recipe.php'),
          body: jsonEncode(recipeData),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final updatedRecipe = Recipe(
            id: widget.recipe.id,
            title: title,
            ingredients: ingredients,
            instructions: instructions,
            // image: imageUrl, // Commented out to disable image picker
            isFavorite: _isFavorite,
          );
          Navigator.pop(context, updatedRecipe);
        } else {
          // Handle error
        }
      } catch (e) {
        print(e);
        // Handle error
      }
    }
  }

  void _addIngredient(String name, String quantity) {
    setState(() {
      _selectedIngredients.add({'name': name, 'quantity': quantity});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Resep'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateRecipe,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan judul';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Bahan-bahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._selectedIngredients.map((ingredient) {
                return ListTile(
                  title: Text('${ingredient['name']} - ${ingredient['quantity']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _selectedIngredients.remove(ingredient);
                      });
                    },
                  ),
                );
              }).toList(),
              ListTile(
                title: Text('Tambah Bahan'),
                trailing: Icon(Icons.add),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final _nameController = TextEditingController();
                      final _quantityController = TextEditingController();
                      return AlertDialog(
                        title: Text('Tambah Bahan'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(labelText: 'Nama Bahan'),
                            ),
                            TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(labelText: 'Jumlah'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              _addIngredient(
                                _nameController.text,
                                _quantityController.text,
                              );
                              Navigator.pop(context);
                            },
                            child: Text('Tambah'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(labelText: 'Instruksi'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan instruksi';
                  }
                  return null;
                },
              ),
              // SizedBox(height: 16),
              // Text('Gambar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // SizedBox(height: 8),
              // GestureDetector(
              //   onTap: _pickImage,
              //   child: Container(
              //     height: 200,
              //     color: Colors.grey[800],
              //     child: _image == null
              //         ? Center(child: Text('Tap untuk memilih gambar', style: TextStyle(color: Colors.white)))
              //         : Image.file(File(_image!.path), fit: BoxFit.cover),
              //   ),
              // ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Favorite'),
                value: _isFavorite,
                onChanged: (bool? value) {
                  setState(() {
                    _isFavorite = value ?? false;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _updateRecipe,
                child: Text('Update Resep'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
