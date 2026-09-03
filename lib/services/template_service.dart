import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:subtrack/models/template_subscription.dart';

class TemplateService {
  static const String _templateFilePath = 'assets/templates/subscriptions.json';

  static Future<List<TemplateSubscription>> loadTemplates() async {
    try {
      final String jsonString = await rootBundle.loadString(_templateFilePath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList
          .map((json) => TemplateSubscription.fromJson(json))
          .toList();
    } catch (e) {
      // В случае ошибки возвращаем пустой список
      return [];
    }
  }

  static List<TemplateSubscription> searchTemplates(
      List<TemplateSubscription> templates, String query) {
    if (query.isEmpty) {
      return templates;
    }

    return templates.where((template) {
      final name = template.name.toLowerCase();
      final q = query.toLowerCase();
      return name.contains(q);
    }).toList();
  }
}