import 'dart:convert';
    import 'package:flutter/material.dart';
    import 'package:supabase_flutter/supabase_flutter.dart';
    import 'package:farmmatrix/models/field_info_model.dart';
    import 'package:farmmatrix/screens/field_add_selection/add_field_screen.dart';
    import 'package:shared_preferences/shared_preferences.dart';
    import 'package:farmmatrix/services/field_services.dart';
    import 'package:farmmatrix/config/app_config.dart';

    class SelectFieldDropdown extends StatefulWidget {
      final Function(FieldInfoModel?) onFieldSelected;

      const SelectFieldDropdown({
        super.key,
        required this.onFieldSelected,
      });

      @override
      _SelectFieldDropdownState createState() => _SelectFieldDropdownState();
    }

    class _SelectFieldDropdownState extends State<SelectFieldDropdown> {
      final SupabaseClient _supabase = Supabase.instance.client;
      final FieldService _fieldService = FieldService();
      List<FieldInfoModel> _userFields = [];
      bool _isLoading = true;
      bool _hasError = false;
      String _errorMessage = '';
      bool _isDeleteMode = false;
      Set<String> _selectedFieldIds = {};

      @override
      void initState() {
        super.initState();
        _fetchUserFields();
      }

      Future<void> _fetchUserFields() async {
        try {
          setState(() {
            _isLoading = true;
            _hasError = false;
          });

          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString('userId');
          if (userId == null) {
            throw Exception('User ID not found');
          }

          final response = await _supabase
              .from('user_fields')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);

          if (response.isEmpty) {
            setState(() {
              _userFields = [];
              _isLoading = false;
            });
            return;
          }

          setState(() {
            _userFields = response
                .map<FieldInfoModel>((field) => FieldInfoModel.fromMap(field))
                .toList();
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching fields: $e')),
          );
        }
      }

      Future<void> _handleAddField() async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => const AddFieldScreen()),
        );

        if (result == true) {
          await _fetchUserFields();
        }
      }

      Future<void> _saveSelectedField(FieldInfoModel field) async {
        final prefs = await SharedPreferences.getInstance();
        final fieldJson = jsonEncode(field.toMap());
        await prefs.setString('selectedField', fieldJson);
      }

      Future<void> _deleteSelectedFields() async {
        if (_selectedFieldIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No fields selected for deletion')),
          );
          return;
        }

        try {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString('userId');
          if (userId == null) {
            throw Exception('User ID not found');
          }

          await _fieldService.deleteFields(_selectedFieldIds.toList(), userId);
          setState(() {
            _userFields.removeWhere((field) => _selectedFieldIds.contains(field.id));
            _selectedFieldIds.clear();
            _isDeleteMode = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fields deleted successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting fields: $e')),
          );
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Select Field'),
            backgroundColor: AppConfig.primaryColor,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _isDeleteMode = !_isDeleteMode;
                    if (!_isDeleteMode) {
                      _selectedFieldIds.clear();
                    }
                  });
                },
              ),
            ],
          ),
          body: _buildBody(),
          floatingActionButton: _isDeleteMode && _userFields.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _deleteSelectedFields,
                  label: Text('Delete Selected'),
                  icon: Icon(Icons.delete),
                  backgroundColor: Colors.red,
                )
              : null,
        );
      }

      Widget _buildBody() {
        if (_isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (_hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading fields',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchUserFields,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_userFields.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.agriculture, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Fields Added',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add a new field to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleAddField,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Add New Field'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchUserFields,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _userFields.length,
            itemBuilder: (context, index) {
              final field = _userFields[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  title: Text(
                    field.fieldName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: _isDeleteMode
                      ? Checkbox(
                          value: _selectedFieldIds.contains(field.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedFieldIds.add(field.id);
                              } else {
                                _selectedFieldIds.remove(field.id);
                              }
                            });
                          },
                        )
                      : Icon(
                          Icons.arrow_forward,
                          color: AppConfig.primaryColor,
                        ),
                  onTap: _isDeleteMode
                      ? () {
                          setState(() {
                            if (_selectedFieldIds.contains(field.id)) {
                              _selectedFieldIds.remove(field.id);
                            } else {
                              _selectedFieldIds.add(field.id);
                            }
                          });
                        }
                      : () {
                          widget.onFieldSelected(field);
                          _saveSelectedField(field);
                          Navigator.pop(context);
                        },
                ),
              );
            },
          ),
        );
      }
    }