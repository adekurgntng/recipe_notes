import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientDialog extends StatefulWidget {
  @override
  _IngredientDialogState createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<IngredientDialog> {
  String? _selectedIngredient;
  String? _selectedUnit;
  final _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Ingredient'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedIngredient,
            hint: Text('Select Ingredient'),
            onChanged: (value) {
              setState(() {
                _selectedIngredient = value;
                _selectedUnit = ingredients
                    .firstWhere((ingredient) => ingredient.name == value)
                    .units
                    .first;
              });
            },
            items: ingredients.map((ingredient) {
              return DropdownMenuItem(
                value: ingredient.name,
                child: Text(ingredient.name),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an ingredient';
              }
              return null;
            },
          ),
          if (_selectedIngredient != null)
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              hint: Text('Select Unit'),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value;
                });
              },
              items: ingredients
                  .firstWhere(
                      (ingredient) => ingredient.name == _selectedIngredient)
                  .units
                  .map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a unit';
                }
                return null;
              },
            ),
          TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(labelText: 'Quantity'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a quantity';
              }
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_selectedIngredient != null &&
                _selectedUnit != null &&
                _quantityController.text.isNotEmpty) {
              Navigator.pop(context, {
                'name': _selectedIngredient!,
                'quantity': '${_quantityController.text} $_selectedUnit'
              });
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
