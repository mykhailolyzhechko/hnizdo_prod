import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hnizdo/models/child.dart';
import 'package:hnizdo/providers/child_provider.dart';
import 'package:hnizdo/providers/contact_info_provider.dart';
import 'package:hnizdo/screens/add_child_screen.dart';
import 'package:hnizdo/screens/child_details_screen.dart';
import 'package:hnizdo/screens/edit_child_screen.dart';
import 'package:intl/intl.dart';
import 'package:hnizdo/utils/image_utils.dart';
import 'dart:typed_data';

// Current status filter provider
final currentStatusFilterProvider = StateProvider<String>((ref) => 'All');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current filter status
    final currentFilter = ref.watch(currentStatusFilterProvider);

    // Get the raw children data directly
    final childrenMap = ref.watch(childrenProvider);

    // Create filtered list
    List<Child> filteredChildren = [];
    try {
      if (currentFilter == 'All') {
        filteredChildren = childrenMap.values.toList();
      } else {
        filteredChildren = childrenMap.values
            .where((child) => child.status == currentFilter)
            .toList();
      }

      // Sort by name
      filteredChildren.sort((a, b) => a.fullName.compareTo(b.fullName));
    } catch (e) {
      // Error handling without print
    }

    final statistics = ref.watch(childStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindergarten Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsCards(statistics),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Children',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                // Show current filter
                if (currentFilter != 'All')
                  Chip(
                    label: Text('Filtered: $currentFilter'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () =>
                        ref.read(currentStatusFilterProvider.notifier).state = 'All',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: childrenMap.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.child_care, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No children added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddChildForm(context, ref),
                            child: const Text('Add Child'),
                          ),
                        ],
                      ),
                    )
                  : filteredChildren.isEmpty && currentFilter != 'All'
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.filter_alt, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No children match the "$currentFilter" filter',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredChildren.length,
                          itemBuilder: (context, index) {
                            final child = filteredChildren[index];
                            return _buildChildItem(context, ref, child);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChildForm(context, ref),
        tooltip: 'Add Child',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, int> statistics) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard('Total', statistics['total'] ?? 0, Colors.blue),
          const SizedBox(width: 16),
          _buildStatCard('Active', statistics['active'] ?? 0, Colors.green),
          const SizedBox(width: 16),
          _buildStatCard('Inactive', statistics['inactive'] ?? 0, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildItem(BuildContext context, WidgetRef ref, Child child) {
    // Handle the date formatting safely to prevent errors
    String formattedDate = 'Unknown';
    try {
      formattedDate = DateFormat('dd/MM/yyyy').format(child.dateOfBirth);
    } catch (e) {
      print('Error formatting date for child ${child.id}: $e');
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: child.photoUrl != null && child.photoUrl!.isNotEmpty
            ? ClipOval(
                child: Image.memory(
                  ImageUtils.decodeBase64Image(child.photoUrl!) ?? Uint8List(0),
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) {
                    return CircleAvatar(
                      child: Text(child.fullName.isNotEmpty ? child.fullName[0] : '?'),
                    );
                  },
                ),
              )
            : CircleAvatar(
                child: Text(child.fullName.isNotEmpty ? child.fullName[0] : '?'),
              ),
        title: Text(
          child.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Date of Birth: $formattedDate'),
            // Contact info is loaded in a separate provider safely
            Builder(builder: (context) {
              try {
                final primaryContact = ref.watch(primaryContactProvider(child.id));
                return primaryContact != null
                    ? Text(
                        'Contact: ${primaryContact.name} (${primaryContact.relationship})')
                    : const Text('No primary contact');
              } catch (e) {
                print('Error loading primary contact: $e');
                return const Text('Contact info unavailable');
              }
            }),
            Text('Status: ${child.status}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'edit') {
              _showEditChildForm(context, ref, child);
            } else if (value == 'delete') {
              _confirmDeleteChild(context, ref, child);
            } else if (value == 'view') {
              _showChildDetails(context, ref, child);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'view',
              child: Text('View Details'),
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _showChildDetails(context, ref, child),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(currentStatusFilterProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Filter by Status'),
              enabled: false,
            ),
            const Divider(),
            ListTile(
              title: const Text('All'),
              trailing: currentFilter == 'All' ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(currentStatusFilterProvider.notifier).state = 'All';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Active'),
              trailing: currentFilter == 'Active' ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(currentStatusFilterProvider.notifier).state = 'Active';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Inactive'),
              trailing: currentFilter == 'Inactive' ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(currentStatusFilterProvider.notifier).state = 'Inactive';
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddChildForm(BuildContext context, WidgetRef ref) {
    // Navigate to a form to add a new child
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddChildScreen(),
      ),
    );
  }

  void _showEditChildForm(BuildContext context, WidgetRef ref, Child child) {
    // Navigate to a form to edit the child
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditChildScreen(childId: child.id),
      ),
    );
  }

  void _showChildDetails(BuildContext context, WidgetRef ref, Child child) {
    // Navigate to a detail view for the child
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChildDetailsScreen(childId: child.id),
      ),
    );
  }

  void _confirmDeleteChild(BuildContext context, WidgetRef ref, Child child) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Child'),
          content: Text('Are you sure you want to delete ${child.fullName}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(childrenProvider.notifier).deleteChild(child.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
