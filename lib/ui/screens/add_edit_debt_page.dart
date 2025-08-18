import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_sizer/smart_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/debt_model.dart';
import '../../providers/debt_provider.dart';

class AddEditDebtPage extends StatefulWidget {
  final Debt? debt;

  const AddEditDebtPage({Key? key, this.debt}) : super(key: key);

  @override
  _AddEditDebtPageState createState() => _AddEditDebtPageState();
}

class _AddEditDebtPageState extends State<AddEditDebtPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phoneNumber;
  late double _amount;
  late String _note;
  late DateTime _date;

  bool get isEditing => widget.debt != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _name = widget.debt!.name;
      _phoneNumber = widget.debt!.phoneNumber;
      _amount = widget.debt!.amount;
      _note = widget.debt!.note;
      _date = widget.debt!.date;
    } else {
      _name = '';
      _phoneNumber = '';
      _amount = 0.0;
      _note = '';
      _date = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Debt' : 'Add Debt')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.getMinSize(12)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                label: 'Name',
                initialValue: _name,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: context.getHeight(12)),
              _buildTextFormField(
                label: 'Phone Number',
                initialValue: _phoneNumber,
                enabled: !isEditing, // Phone number is the ID, so not editable
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a phone number' : null,
                onSaved: (value) => _phoneNumber = value!,
              ),
              SizedBox(height: context.getHeight(12)),
              _buildTextFormField(
                label: 'Amount',
                initialValue: _amount.toString(),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null
                    ? 'Please enter a valid amount'
                    : null,
                onSaved: (value) => _amount = double.parse(value!),
              ),
              SizedBox(height: context.getHeight(12)),
              _buildTextFormField(
                label: 'Note',
                initialValue: _note,
                maxLines: 3,
                onSaved: (value) => _note = value!,
              ),
              SizedBox(height: context.getHeight(12)),
              _buildDatePicker(context),
              SizedBox(height: context.getHeight(18)),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save Debt'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: context.getHeight(10),
                  ),
                  textStyle: TextStyle(fontSize: context.getFontSize(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.getMinSize(8)),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Date: ${DateFormat.yMMMd().format(_date)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        TextButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null && pickedDate != _date) {
              setState(() {
                _date = pickedDate;
              });
            }
          },
          child: const Text('Change Date'),
        ),
      ],
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final debtProvider = Provider.of<DebtProvider>(context, listen: false);

      final newDebt = Debt(
        id: isEditing ? widget.debt!.id : null,
        phoneNumber: _phoneNumber,
        name: _name,
        amount: _amount,
        date: _date,
        note: _note,
        lastUpdated: Timestamp.now(), // Always update timestamp on save
      );

      if (isEditing) {
        debtProvider.updateDebt(newDebt);
      } else {
        debtProvider.addDebt(newDebt);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Debt updated' : 'Debt added')),
      );

      // Navigator.of(context).pop();
    }
  }
}
