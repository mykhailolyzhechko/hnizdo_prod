import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hnizdo/models/child.dart';
import 'package:hnizdo/providers/child_provider.dart';
import 'package:hnizdo/providers/contact_info_provider.dart';
import 'package:hnizdo/screens/add_child_screen.dart';
import 'package:hnizdo/screens/edit_child_screen.dart';
import 'package:intl/intl.dart';
import 'package:hnizdo/utils/image_utils.dart';
import 'dart:typed_data';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final currentStatusFilterProvider = StateProvider<String>((ref) => 'All');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current filter status
    final currentFilter = ref.watch(currentStatusFilterProvider);

    // Get the raw children data directly
    final childrenMap = ref.watch(childrenProvider);

    final l10n = AppLocalizations.of(context)!;

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
        title: Text(l10n.children),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_1),
            onPressed: () => _showFilterOptions(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsCards(context, statistics),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.children,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                // Show current filter
                if (currentFilter != 'All')
                  Chip(
                    label: Text(l10n.filtered(currentFilter)),
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
                            l10n.noChildrenAdded,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddChildForm(context, ref),
                            child: Text(l10n.addChild),
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
                                l10n.noChildrenMatchFilter(currentFilter),
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
        tooltip: l10n.addChild,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, Map<String, int> statistics) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(l10n.total, statistics['total'] ?? 0, Colors.blue),
          const SizedBox(width: 16),
          _buildStatCard(l10n.active, statistics['active'] ?? 0, Colors.green),
          const SizedBox(width: 16),
          _buildStatCard(l10n.inactive, statistics['inactive'] ?? 0, Colors.orange),
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
    final l10n = AppLocalizations.of(context)!;
    // Handle the date formatting safely to prevent errors
    String formattedDate = l10n.unknown;
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
            Text(l10n.dateOfBirth(formattedDate)),
            // Contact info is loaded in a separate provider safely
            Builder(builder: (context) {
              try {
                final primaryContact = ref.watch(primaryContactProvider(child.id));
                return primaryContact != null
                    ? Text(l10n.contact(primaryContact.name, primaryContact.relationship))
                    : Text(l10n.noPrimaryContact);
              } catch (e) {
                print('Error loading primary contact: $e');
                return Text(l10n.contactUnavailable);
              }
            }),
            Text(l10n.status(child.status)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'edit') {
              _showEditChildForm(context, ref, child);
            } else if (value == 'delete') {
              _confirmDeleteChild(context, ref, child);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: Text(l10n.edit),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(l10n.delete),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _showEditChildForm(context, ref, child),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(currentStatusFilterProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.filterBy),
              enabled: false,
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.all),
              trailing: currentFilter == 'All' ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(currentStatusFilterProvider.notifier).state = 'All';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.active),
              trailing: currentFilter == 'Active' ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(currentStatusFilterProvider.notifier).state = 'Active';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.inactive),
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

  void _confirmDeleteChild(BuildContext context, WidgetRef ref, Child child) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.deleteChild),
          content: Text(l10n.deleteChildConfirmation(child.fullName)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                ref.read(childrenProvider.notifier).deleteChild(child.id);
                Navigator.of(context).pop();
              },
              child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}