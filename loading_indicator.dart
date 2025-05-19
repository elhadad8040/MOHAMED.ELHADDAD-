import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// ويدجت لعرض مؤشر التحميل مع رسالة اختيارية
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color color;
  final double size;
  
  const LoadingIndicator({
    Key? key,
    this.message,
    this.color = AppConstants.primaryColor,
    this.size = 40.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 4.0,
            ),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
              child: Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
