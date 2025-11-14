import 'package:flutter/material.dart';

class ResultSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  const ResultSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.greenAccent.shade100.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.greenAccent.shade100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.green),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          children: [for (final item in items) ListTile(title: Text(item))],
        ),
      ),
    );
  }
}
