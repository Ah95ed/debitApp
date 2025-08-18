import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_sizer/smart_sizer.dart';
import '../../providers/debt_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/import_export_service.dart';
import '../../models/debt_model.dart';
import 'add_edit_debt_page.dart';

enum _Menu { importJson, importCsv, exportJson, exportCsv }

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final debtProvider = Provider.of<DebtProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Manager'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme(
                themeProvider.themeMode == ThemeMode.light,
              );
            },
          ),
          PopupMenuButton<_Menu>(
            onSelected: (value) async {
              final importExportService = ImportExportService();
              switch (value) {
                case _Menu.importJson:
                case _Menu.importCsv:
                  final importedDebts = await importExportService.importDebts();
                  if (importedDebts != null) {
                    for (var debt in importedDebts) {
                      await debtProvider.addDebt(debt);
                    }
                  }
                  break;
                case _Menu.exportJson:
                  await importExportService.exportDebts(
                    debtProvider.debts,
                    'json',
                  );
                  break;
                case _Menu.exportCsv:
                  await importExportService.exportDebts(
                    debtProvider.debts,
                    'csv',
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _Menu.importJson,
                child: Text('Import from JSON'),
              ),
              const PopupMenuItem(
                value: _Menu.importCsv,
                child: Text('Import from CSV'),
              ),
              const PopupMenuItem(
                value: _Menu.exportJson,
                child: Text('Export to JSON'),
              ),
              const PopupMenuItem(
                value: _Menu.exportCsv,
                child: Text('Export to CSV'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTotalDebtCard(context, debtProvider.totalDebt),
          Expanded(
            child: debtProvider.debts.isEmpty
                ? Center(
                    child: Text(
                      'No debts yet. Add one!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  )
                : _buildDebtList(debtProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditDebtPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalDebtCard(BuildContext context, double totalDebt) {
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
              'Total Debt',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.getHeight(12)),
            Text(
              '\$ ${totalDebt.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtList(DebtProvider debtProvider) {
    return ListView.builder(
      itemCount: debtProvider.debts.length,
      itemBuilder: (context, index) {
        final debt = debtProvider.debts[index];
        return Card(
          margin: EdgeInsets.symmetric(
            horizontal: context.getWidth(12),
            vertical: context.getHeight(5),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(context.getMinSize(12)),
            title: Text(
              debt.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${debt.phoneNumber}\n Added: ${DateFormat.yMMMd().format(debt.date)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${debt.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: context.getFontSize(16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditDebtPage(debt: debt),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade300),
                  onPressed: () {
                    debtProvider.deleteDebt(debt.phoneNumber);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
