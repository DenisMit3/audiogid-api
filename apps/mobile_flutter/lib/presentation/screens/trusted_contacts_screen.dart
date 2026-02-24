import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/services/share_service.dart';

class TrustedContactsScreen extends ConsumerWidget {
  const TrustedContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(trustedContactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Доверенные контакты')),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return const Center(
                child: Text('Нет контактов. Добавьте номера телефонов.'));
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                title: Text(contact.name),
                subtitle: Text(contact.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(trustedContactsProvider.notifier)
                        .remove(contact.id);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить контакт'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Телефон'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                ref
                    .read(trustedContactsProvider.notifier)
                    .add(nameController.text, phoneController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
