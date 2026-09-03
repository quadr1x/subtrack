import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'subscription.g.dart';

@HiveType(typeId: 0)
class Subscription extends Equatable {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String category;
  final String? description;
  final String? logoUrl;
  final String? color;
  final DateTime nextPaymentDate;
  final String paymentMethod;
  final String billingCycle; // "monthly", "yearly", "weekly"
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.category,
    this.description,
    this.logoUrl,
    this.color,
    required this.nextPaymentDate,
    required this.paymentMethod,
    required this.billingCycle,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    String? currency,
    String? category,
    String? description,
    String? logoUrl,
    String? color,
    DateTime? nextPaymentDate,
    String? paymentMethod,
    String? billingCycle,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      color: color ?? this.color,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as double,
      currency: json['currency'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      color: json['color'] as String?,
      nextPaymentDate: DateTime.parse(json['nextPaymentDate'] as String),
      paymentMethod: json['paymentMethod'] as String,
      billingCycle: (json['billingCycle'] ?? json['period'] ?? 'monthly') as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'category': category,
      'description': description,
      'logoUrl': logoUrl,
      'color': color,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'billingCycle': billingCycle,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        currency,
        category,
        description,
        logoUrl,
        color,
        nextPaymentDate,
        paymentMethod,
        billingCycle,
        startDate,
        endDate,
        createdAt,
        updatedAt,
      ];
}