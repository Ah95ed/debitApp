import 'package:debit_app/ui/widgets/total_debt_card.dart';
import 'package:debit_app/main.dart';
import 'package:debit_app/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_sizer/smart_sizer.dart';
import '../../providers/debt_provider.dart';
import '../../services/import_export_service.dart';
import 'add_edit_debt_page.dart';

enum _Menu { importJson, importCsv, exportJson, exportCsv }

class HomePage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const HomePage({super.key, required this.themeNotifier});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DebtProvider>(context, listen: false).loadDebtsFromLocalDB();
    });
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = Provider.of<DebtProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدير الديون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await debtProvider.syncWithAppwrite();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('اكتملت المزامنة')));
            },
          ),
          IconButton(
            icon: Icon(
              widget.themeNotifier.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () async {
              widget.themeNotifier.value =
                  widget.themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;

              await prefs.setBool(
                'isDarkMode',
                widget.themeNotifier.value == ThemeMode.dark,
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
                child: Text('استيراد من JSON'),
              ),
              const PopupMenuItem(
                value: _Menu.importCsv,
                child: Text('استيراد من CSV'),
              ),
              const PopupMenuItem(
                value: _Menu.exportJson,
                child: Text('تصدير إلى JSON'),
              ),
              const PopupMenuItem(
                value: _Menu.exportCsv,
                child: Text('تصدير إلى CSV'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TotalDebtCard(totalDebt: debtProvider.totalDebt),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                debtProvider.searchDebts(value);
              },
            ),
          ),
          Expanded(
            child: debtProvider.searchResults.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد ديون.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  )
                : BuildDesktopDebtList(debtProvider),
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

  

}
class BuildDesktopDebtList extends StatelessWidget {
  final DebtProvider debtProvider;

  const BuildDesktopDebtList(this.debtProvider, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(context.getMinSize(12)),
      itemCount: debtProvider.searchResults.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: DeviceUtils.valueDecider(
          context,
          onMobile: 1,
          onTablet: 1,
          onDesktop: 2,
        ),
        childAspectRatio:3.0,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      itemBuilder: (context, index) {
        final debt = debtProvider.searchResults[index];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.getMinSize(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم الشخص
                Text(
                  debt.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.getFontSize(18),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
               
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 1,
                ),
                // رقم الدين + أزرار التعديل والحذف
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$ ${debt.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: context.getFontSize(16),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,color: Colors.greenAccent,),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditDebtPage(debt: debt),
                              ),
                            );
                          },
                        ),
                 
                        IconButton(
                          icon: const Icon(Icons.delete,color:Colors.red,),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content: const Text(
                                    'سيتم حذف الدين من جميع الأجهزة والسحابة. لا يمكن التراجع عن هذا الإجراء.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('إلغاء'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: const Text('حذف'),
                                      onPressed: () {
                                        debtProvider.deleteDebt(debt.phoneNumber);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
