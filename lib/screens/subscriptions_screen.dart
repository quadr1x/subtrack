import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:subtrack/models/subscription.dart';
import 'package:subtrack/services/template_service.dart';
import 'package:subtrack/widgets/subscription_dialog.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late Box<Subscription> _subscriptionsBox;
  late List<Subscription> _subscriptions;
  late List<Subscription> _filteredSubscriptions;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscriptionsBox = Hive.box<Subscription>('subscriptions');
    _subscriptions = _subscriptionsBox.values.toList();
    _filteredSubscriptions = _subscriptions;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search subscriptions...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filterSubscriptions(value),
            ),
          ),
          Expanded(
            child: _filteredSubscriptions.isEmpty
                ? const Center(child: Text('No subscriptions found'))
                : ListView.builder(
                    itemCount: _filteredSubscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = _filteredSubscriptions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: sub.color != null
                                ? Color(int.parse(sub.color!.substring(1), radix: 16))
                                : Colors.grey,
                            child: Text(sub.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(sub.name),
                          subtitle: Text(
                              '${sub.category} - ${sub.nextPaymentDate.day}.${sub.nextPaymentDate.month}.${sub.nextPaymentDate.year}'),
                          trailing: Text(
                            '${sub.price} ${sub.currency}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          onTap: () => _showEditSubscriptionDialog(sub),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubscriptionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _filterSubscriptions(String query) {
    setState(() {
      _filteredSubscriptions = query.isEmpty
          ? _subscriptions
          : _subscriptions
              .where((sub) =>
                  sub.name.toLowerCase().contains(query.toLowerCase()) ||
                  sub.category.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _showAddSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const SubscriptionDialog(),
    ).then((value) {
      if (value == true) {
        setState(() {
          _subscriptions = _subscriptionsBox.values.toList();
          _filteredSubscriptions = _subscriptions;
        });
      }
    });
  }

  void _showEditSubscriptionDialog(Subscription subscription) {
    showDialog(
      context: context,
      builder: (ctx) => SubscriptionDialog(subscription: subscription),
    ).then((value) {
      if (value == true) {
        setState(() {
          _subscriptions = _subscriptionsBox.values.toList();
          _filteredSubscriptions = _subscriptions;
        });
      }
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Templates'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>(
            future: TemplateService.loadTemplates(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error loading templates');
              } else if (snapshot.hasData) {
                final templates = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var template in templates)
                      ListTile(
                        title: Text(template['name']),
                        subtitle: Text(template['category']),
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Template "${template['name']}" selected')),
                          );
                        },
                      ),
                  ],
                );
              } else {
                return const Text('No templates found');
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
