import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:subtrack/models/subscription.dart';
import 'package:subtrack/services/notification_service.dart';

class SubscriptionDialog extends StatefulWidget {
  final Subscription? subscription;
  final VoidCallback? onSaved;

  const SubscriptionDialog({
    super.key,
    this.subscription,
    this.onSaved,
  });

  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _currencyController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _colorController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _periodController = TextEditingController();
  final _nextPaymentDateController = TextEditingController();

  static const List<String> _periods = ['monthly', 'yearly', 'weekly'];

  String _makeId() {
    final t = DateTime.now().microsecondsSinceEpoch;
    final rand = (t ^ (t >> 16)) & 0xFFFF;
    final h = t.toRadixString(16).padLeft(12, '0');
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-4'
        '${(rand & 0xFFF).toRadixString(16).padLeft(3, '0')}-'
        '${(0x8 | (t & 3)).toRadixString(16)}-'
        '${(rand * 31).toRadixString(16).padLeft(12, '0')}';
  }

  @override
  void initState() {
    super.initState();
    final s = widget.subscription;
    if (s != null) {
      _nameController.text = s.name;
      _priceController.text = s.price.toString();
      _currencyController.text = s.currency;
      _categoryController.text = s.category;
      _descriptionController.text = s.description ?? '';
      _logoUrlController.text = s.logoUrl ?? '';
      _colorController.text = s.color ?? '';
      _paymentMethodController.text = s.paymentMethod;
      _periodController.text = s.billingCycle;
      _nextPaymentDateController.text =
          '${s.nextPaymentDate.year}-${s.nextPaymentDate.month.toString().padLeft(2, '0')}-${s.nextPaymentDate.day.toString().padLeft(2, '0')}';
    } else {
      _currencyController.text = 'RUB';
      _periodController.text = 'monthly';
      _nextPaymentDateController.text = DateTime.now().toIso8601String().substring(0, 10);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    _colorController.dispose();
    _paymentMethodController.dispose();
    _periodController.dispose();
    _nextPaymentDateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<Subscription>('subscriptions');
    final now = DateTime.now();
    final nextPaymentDate =
        DateTime.parse(_nextPaymentDateController.text);

    final isEditing = widget.subscription != null;
    final sub = Subscription(
      id: isEditing ? widget.subscription!.id : _makeId(),
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      currency: _currencyController.text.trim().isEmpty
          ? 'RUB'
          : _currencyController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      logoUrl: _logoUrlController.text.trim().isEmpty
          ? null
          : _logoUrlController.text.trim(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      nextPaymentDate: nextPaymentDate,
      paymentMethod: _paymentMethodController.text.trim(),
      billingCycle: _periodController.text,
      startDate: widget.subscription?.startDate,
      endDate: widget.subscription?.endDate,
      createdAt: isEditing ? widget.subscription!.createdAt : now,
      updatedAt: now,
    );

    if (isEditing) {
      await box.put(sub.id, sub);
    } else {
      await box.add(sub);
    }

    // Best-effort: schedule reminder notification (no-op if unsupported).
    try {
      await NotificationService.instance
          .scheduleSubscriptionNotification(sub);
    } catch (_) {}

    widget.onSaved?.call();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.subscription == null ? 'Add subscription' : 'Edit subscription'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid number' : null,
                ),
                TextFormField(
                  controller: _currencyController,
                  decoration: const InputDecoration(labelText: 'Currency'),
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _logoUrlController,
                  decoration: const InputDecoration(labelText: 'Logo URL'),
                ),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color (hex, e.g. #FF0000)'),
                ),
                TextFormField(
                  controller: _paymentMethodController,
                  decoration: const InputDecoration(labelText: 'Payment method'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _periodController.text.isEmpty
                      ? 'monthly'
                      : _periodController.text,
                  decoration: const InputDecoration(labelText: 'Billing cycle'),
                  items: _periods
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) _periodController.text = v;
                  },
                ),
                TextFormField(
                  controller: _nextPaymentDateController,
                  decoration: const InputDecoration(
                    labelText: 'Next payment (YYYY-MM-DD)',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    return DateTime.tryParse(v) == null ? 'Invalid date' : null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
