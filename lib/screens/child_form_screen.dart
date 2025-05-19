import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hnizdo/models/child.dart';
import 'package:hnizdo/models/contact_info.dart';
import 'package:hnizdo/providers/child_provider.dart';
import 'package:hnizdo/providers/contact_info_provider.dart';
import 'package:hnizdo/utils/image_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChildFormScreen extends ConsumerStatefulWidget {
  final String? childId;
  final String title;

  // Constructor for add child (no childId)
  const ChildFormScreen.add({super.key})
      : childId = null,
        title = 'Add Child';

  // Constructor for edit child (requires childId)
  const ChildFormScreen.edit(String this.childId, {super.key})
      : title = 'Edit Child';

  @override
  ConsumerState<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends ConsumerState<ChildFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _dateOfBirth;
  String _selectedGroup = '';
  String _selectedStatus = 'Active';
  List<ContactInfo> _contacts = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Image related
  String? _base64Image;
  Uint8List? _imageBytes;

  final List<String> _groups = ['Group A', 'Group B', 'Group C']; // Replace with actual groups
  final List<String> _statusOptions = ['Active', 'Inactive'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    if (widget.childId != null && !_isInitialized) {
      setState(() => _isLoading = true);
      
      try {
        // Load child data for editing
        final child = ref.read(childByIdProvider(widget.childId!));
        
        if (child != null) {
          _fullNameController.text = child.fullName;

          // Handle photo URL as base64 string
          if (child.photoUrl != null && child.photoUrl!.isNotEmpty) {
            _base64Image = child.photoUrl;
            _imageBytes = ImageUtils.decodeBase64Image(_base64Image);
          }

          _notesController.text = child.notes;
          _dateOfBirth = child.dateOfBirth;
          _selectedGroup = child.groupId;
          _selectedStatus = child.status;
          _contacts = List.from(child.contactInfo);
          
          setState(() => _isInitialized = true);
        }
      } catch (e) {
        // Handle error loading child data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading child data: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (widget.childId == null) {
      // For new child, just mark as initialized
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _photoUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relationshipTypes = ref.watch(relationshipTypesProvider)
        .where((type) => type != 'All') // Remove "All" option for adding contacts
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChild,
            child: _isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Card
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Basic Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Photo section
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _showImagePickerOptions,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: _imageBytes != null
                                          ? ClipOval(
                                              child: Image.memory(
                                                _imageBytes!,
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                              ),
                                            )
                                          : Icon(
                                              Icons.add_a_photo,
                                              color: Theme.of(context).primaryColor,
                                              size: 40,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to add photo',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  if (_base64Image != null)
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _base64Image = null;
                                          _imageBytes = null;
                                        });
                                      },
                                      child: const Text('Remove photo'),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Full Name
                            TextFormField(
                              controller: _fullNameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter child\'s name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Date of Birth
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _dateOfBirth == null
                                          ? 'Select date'
                                          : DateFormat('dd/MM/yyyy').format(_dateOfBirth!),
                                    ),
                                    const Icon(Icons.calendar_today),
                                  ],
                                ),
                              ),
                            ),
                            if (_dateOfBirth == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0, left: 12.0),
                                child: Text(
                                  'Please select a date of birth',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(height: 16),
                            
                            // Group Dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Group *',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedGroup.isEmpty ? null : _selectedGroup,
                              hint: const Text('Select a group'),
                              items: _groups.map((group) {
                                return DropdownMenuItem(
                                  value: group,
                                  child: Text(group),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGroup = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a group';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Status Dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedStatus,
                              items: _statusOptions.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Notes
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes (optional)',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Contact Information
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Contact Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showAddContactDialog(context, relationshipTypes),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Contact'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            if (_contacts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'No contacts added yet.\nPlease add at least one contact.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _contacts.length,
                                itemBuilder: (context, index) {
                                  final contact = _contacts[index];
                                  return ListTile(
                                    title: Text(contact.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(contact.relationship),
                                        Text(contact.phoneNumber),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (contact.isPrimaryContact)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Chip(
                                              label: const Text('Primary'),
                                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                              labelStyle: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showEditContactDialog(context, relationshipTypes, index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteContact(index),
                                        ),
                                      ],
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Show image picker options dialog
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      final base64String = await ImageUtils.pickAndEncodeImage(source);

      if (base64String != null) {
        setState(() {
          _base64Image = base64String;
          _imageBytes = ImageUtils.decodeBase64Image(base64String);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _showAddContactDialog(BuildContext context, List<String> relationshipTypes) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final alternativePhoneController = TextEditingController();
    final emailController = TextEditingController();
    
    String? selectedRelationship;
    bool isPrimary = _contacts.isEmpty ? true : false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Relationship *',
                  border: OutlineInputBorder(),
                ),
                value: selectedRelationship,
                hint: const Text('Select relationship'),
                items: relationshipTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRelationship = value;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: alternativePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Alternative Phone (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                title: const Text('Primary Contact'),
                value: isPrimary,
                onChanged: (value) {
                  isPrimary = value!;
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Validate inputs
              if (nameController.text.isEmpty || 
                  selectedRelationship == null || 
                  phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }
              
              // If this is set as primary, remove primary from other contacts
              if (isPrimary) {
                for (var i = 0; i < _contacts.length; i++) {
                  if (_contacts[i].isPrimaryContact) {
                    setState(() {
                      _contacts[i] = ContactInfo(
                        name: _contacts[i].name,
                        relationship: _contacts[i].relationship,
                        phoneNumber: _contacts[i].phoneNumber,
                        alternativePhoneNumber: _contacts[i].alternativePhoneNumber,
                        email: _contacts[i].email,
                        isPrimaryContact: false,
                      );
                    });
                  }
                }
              }
              
              // Add the new contact
              setState(() {
                _contacts.add(
                  ContactInfo(
                    name: nameController.text,
                    relationship: selectedRelationship!,
                    phoneNumber: phoneController.text,
                    alternativePhoneNumber: alternativePhoneController.text.isEmpty 
                        ? null 
                        : alternativePhoneController.text,
                    email: emailController.text.isEmpty ? null : emailController.text,
                    isPrimaryContact: isPrimary,
                  ),
                );
              });
              
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(BuildContext context, List<String> relationshipTypes, int index) {
    final contact = _contacts[index];
    
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phoneNumber);
    final alternativePhoneController = TextEditingController(
      text: contact.alternativePhoneNumber ?? '',
    );
    final emailController = TextEditingController(text: contact.email ?? '');
    
    String selectedRelationship = contact.relationship;
    bool isPrimary = contact.isPrimaryContact;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Relationship *',
                  border: OutlineInputBorder(),
                ),
                value: selectedRelationship,
                items: relationshipTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRelationship = value!;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: alternativePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Alternative Phone (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                title: const Text('Primary Contact'),
                value: isPrimary,
                onChanged: (value) {
                  isPrimary = value!;
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Validate inputs
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }
              
              // If this is set as primary, remove primary from other contacts
              if (isPrimary && !contact.isPrimaryContact) {
                for (var i = 0; i < _contacts.length; i++) {
                  if (_contacts[i].isPrimaryContact) {
                    setState(() {
                      _contacts[i] = ContactInfo(
                        name: _contacts[i].name,
                        relationship: _contacts[i].relationship,
                        phoneNumber: _contacts[i].phoneNumber,
                        alternativePhoneNumber: _contacts[i].alternativePhoneNumber,
                        email: _contacts[i].email,
                        isPrimaryContact: false,
                      );
                    });
                  }
                }
              }
              
              // Update the contact
              setState(() {
                _contacts[index] = ContactInfo(
                  name: nameController.text,
                  relationship: selectedRelationship,
                  phoneNumber: phoneController.text,
                  alternativePhoneNumber: alternativePhoneController.text.isEmpty 
                      ? null 
                      : alternativePhoneController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  isPrimaryContact: isPrimary,
                );
              });
              
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteContact(int index) {
    final contact = _contacts[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _contacts.removeAt(index);
                
                // If the deleted contact was primary and we have other contacts,
                // set the first one as primary
                if (contact.isPrimaryContact && _contacts.isNotEmpty) {
                  _contacts[0] = ContactInfo(
                    name: _contacts[0].name,
                    relationship: _contacts[0].relationship,
                    phoneNumber: _contacts[0].phoneNumber,
                    alternativePhoneNumber: _contacts[0].alternativePhoneNumber,
                    email: _contacts[0].email,
                    isPrimaryContact: true,
                  );
                }
              });
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveChild() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    
    // Check if date of birth is selected
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date of birth')),
      );
      return;
    }
    
    // Check if at least one contact is added
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one contact')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (widget.childId == null) {
        // Adding a new child
        await ref.read(childrenProvider.notifier).addChild(
          fullName: _fullNameController.text.trim(),
          photoUrl: _base64Image, // Use the base64 image string
          contactInfo: _contacts,
          dateOfBirth: _dateOfBirth!,
          notes: _notesController.text.trim(),
          groupId: _selectedGroup,
          status: _selectedStatus,
        );
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child added successfully')),
        );
      } else {
        // Updating an existing child
        await ref.read(childrenProvider.notifier).updateChild(
          childId: widget.childId!,
          fullName: _fullNameController.text.trim(),
          photoUrl: _base64Image, // Use the base64 image string
          contactInfo: _contacts,
          dateOfBirth: _dateOfBirth,
          notes: _notesController.text.trim(),
          groupId: _selectedGroup,
          status: _selectedStatus,
        );
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child updated successfully')),
        );
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      
      final action = widget.childId == null ? 'adding' : 'updating';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error $action child: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
