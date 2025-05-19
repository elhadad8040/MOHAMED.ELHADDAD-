import 'package:flutter/material.dart';

class ErrorHighlight extends StatelessWidget {
  final dynamic error;
  final VoidCallback onTap;
  
  const ErrorHighlight({
    Key? key,
    required this.error,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Color(int.parse(
        error.severityColor.substring(1),
        radix: 16,
      ) | 0xFF000000).withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    error.ruleName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildSeverityBadge(error.severity),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                error.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Color(int.parse(
                      error.severityColor.substring(1),
                      radix: 16,
                    ) | 0xFF000000),
                  ),
                ),
                child: Text(
                  error.text,
                  style: const TextStyle(
                    fontFamily: 'Uthmanic',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${error.startTime.toStringAsFixed(2)} - ${error.endTime.toStringAsFixed(2)} ثانية',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'اضغط للتفاصيل',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSeverityBadge(String severity) {
    Color color;
    
    switch (severity.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.amber;
        break;
      default:
        color = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        _getSeverityText(severity),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _getSeverityText(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'خطأ جسيم';
      case 'medium':
        return 'خطأ متوسط';
      case 'low':
        return 'خطأ بسيط';
      default:
        return severity;
    }
  }
}
