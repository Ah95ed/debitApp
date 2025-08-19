import 'package:flutter/material.dart';
import 'package:smart_sizer/smart_sizer.dart';
import '../theme/app_colors.dart';

class TotalDebtCard extends StatelessWidget {
  final double totalDebt;

  const TotalDebtCard({super.key, required this.totalDebt});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(context.getMinSize(12)),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.getMinSize(12)),
      ),
      child: Container(
        padding: EdgeInsets.all(context.getMinSize(12)),
        width: double.infinity,
        child: Column(
          children: [
            Text(
              'مجموع الديون',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor(Theme.of(context).brightness),
              ),
            ),
            SizedBox(height: context.getHeight(12)),
            Text(
              '\$ ${totalDebt.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
