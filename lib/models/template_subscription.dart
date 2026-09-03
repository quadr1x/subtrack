import 'package:equatable/equatable.dart';

class TemplateSubscription extends Equatable {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String category;
  final String? description;
  final String? logoUrl;
  final String? color;
  final String? paymentMethod;
  final String? period;

  const TemplateSubscription({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.category,
    this.description,
    this.logoUrl,
    this.color,
    this.paymentMethod,
    this.period,
  });

  factory TemplateSubscription.fromJson(Map<String, dynamic> json) {
    return TemplateSubscription(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as double,
      currency: json['currency'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      color: json['color'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      period: json['period'] as String?,
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
      'paymentMethod': paymentMethod,
      'period': period,
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
        paymentMethod,
        period,
      ];
}