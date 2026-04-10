import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  final Expense? expense;
  const AddExpenseSheet({super.key, this.expense});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  late bool _isRecurring;
  late String _recurrenceInterval;
  late bool _isSplit;
  late List<_SplitEntry> _splitEntries;
  bool _isLoading = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountController =
        TextEditingController(text: e != null ? e.amount.toStringAsFixed(2) : '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _selectedCategory = e?.category ?? kExpenseCategories.first;
    _selectedDate = e?.date ?? DateTime.now();
    _isRecurring = e?.isRecurring ?? false;
    _recurrenceInterval = e?.recurrenceInterval ?? 'monthly';
    _isSplit = e?.isSplit ?? false;
    _splitEntries = e?.splits
            .map((s) => _SplitEntry(
                  nameController: TextEditingController(text: s.name),
                  amountController:
                      TextEditingController(text: s.amount.toStringAsFixed(2)),
                  settled: s.settled,
                ))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    for (final e in _splitEntries) {
      e.nameController.dispose();
      e.amountController.dispose();
    }
    super.dispose();
  }

  void _addSplitEntry() {
    setState(() {
      _splitEntries.add(_SplitEntry(
        nameController: TextEditingController(),
        amountController: TextEditingController(),
        settled: false,
      ));
    });
  }

  void _removeSplitEntry(int index) {
    _splitEntries[index].nameController.dispose();
    _splitEntries[index].amountController.dispose();
    setState(() => _splitEntries.removeAt(index));
  }

  double get _totalSplitAmount => _splitEntries.fold(0.0, (sum, e) {
        return sum + (double.tryParse(e.amountController.text) ?? 0.0);
      });

  double get _yourShare {
    final total = double.tryParse(_amountController.text) ?? 0.0;
    return (total - _totalSplitAmount).clamp(0.0, double.infinity);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final total = double.tryParse(_amountController.text.trim()) ?? 0;
    if (_isSplit && _splitEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one person to split with')),
      );
      return;
    }
    if (_isSplit && _totalSplitAmount > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Split amounts exceed the total expense')),
      );
      return;
    }

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final splits = _isSplit
          ? _splitEntries
              .map((e) => SplitPerson(
                    name: e.nameController.text.trim(),
                    amount: double.tryParse(e.amountController.text.trim()) ?? 0,
                    settled: e.settled,
                  ))
              .toList()
          : <SplitPerson>[];

      if (_isEditing) {
        final updated = Expense(
          id: widget.expense!.id,
          amount: total,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          isRecurring: _isRecurring,
          recurrenceInterval: _isRecurring ? _recurrenceInterval : null,
          createdAt: widget.expense!.createdAt,
          isSplit: _isSplit,
          splits: splits,
        );
        await ref.read(expenseServiceProvider).updateExpense(user.uid, updated);
      } else {
        final expense = Expense(
          id: '',
          amount: total,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          isRecurring: _isRecurring,
          recurrenceInterval: _isRecurring ? _recurrenceInterval : null,
          createdAt: DateTime.now(),
          isSplit: _isSplit,
          splits: splits,
        );
        await ref.read(expenseServiceProvider).addExpense(user.uid, expense);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expense: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isEditing ? 'Edit Expense' : 'Add Expense',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter an amount';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  if (double.parse(v) <= 0)
                    return 'Amount must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: kExpenseCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a description'
                    : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recurring expense'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _recurrenceInterval,
                  decoration: const InputDecoration(
                    labelText: 'Repeats',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(
                        value: 'fortnightly', child: Text('Fortnightly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (v) => setState(() => _recurrenceInterval = v!),
                ),
              ],
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Split this bill'),
                value: _isSplit,
                onChanged: (v) => setState(() {
                  _isSplit = v;
                  if (v && _splitEntries.isEmpty) _addSplitEntry();
                }),
              ),
              if (_isSplit) ...[
                const SizedBox(height: 8),
                ..._splitEntries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: s.nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              suffixIcon: s.settled
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green, size: 18)
                                  : null,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: s.amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Owes',
                              border: OutlineInputBorder(),
                              prefixText: '\$',
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid';
                              if (double.parse(v) <= 0) return '> 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            s.settled
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: s.settled ? Colors.green : Colors.grey,
                            size: 22,
                          ),
                          tooltip: s.settled ? 'Mark unsettled' : 'Mark settled',
                          onPressed: () => setState(
                              () => _splitEntries[i] = s.copyWith(settled: !s.settled)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red, size: 22),
                          onPressed: () => _removeSplitEntry(i),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Add person'),
                  onPressed: _addSplitEntry,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your share',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        currency.format(_yourShare),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isEditing ? 'Update Expense' : 'Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitEntry {
  final TextEditingController nameController;
  final TextEditingController amountController;
  bool settled;

  _SplitEntry({
    required this.nameController,
    required this.amountController,
    required this.settled,
  });

  _SplitEntry copyWith({bool? settled}) => _SplitEntry(
        nameController: nameController,
        amountController: amountController,
        settled: settled ?? this.settled,
      );
}
