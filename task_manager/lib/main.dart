import 'package:flutter/material.dart';
import 'database_helper.dart';

const primaryBlue = Color(0xFF2169D5);
const expenseRed = Color(0xFFE84D5B);
const incomeGreen = Color(0xFF25A653);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.init();
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Expense Manager',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8FC),
        centerTitle: true,
      ),
    ),
    home: const DashboardScreen(),
  );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool loading = true;
  String filter = 'Tất cả';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    setState(() => loading = true);
    final rows = await DatabaseHelper.instance.getTransactions();
    if (!mounted) return;
    setState(() {
      transactions = rows;
      loading = false;
    });
  }

  double get totalIncome => transactions
      .where((e) => e['type'] == 'Thu nhập')
      .fold(0.0, (s, e) => s + (e['amount'] as num).toDouble());

  double get totalExpense => transactions
      .where((e) => e['type'] == 'Chi tiêu')
      .fold(0.0, (s, e) => s + (e['amount'] as num).toDouble());

  double get balance => totalIncome - totalExpense;

  List<Map<String, dynamic>> get visibleTransactions {
    return transactions.where((e) {
      final matchesType = filter == 'Tất cả' || e['type'] == filter;
      final q = keyword.toLowerCase();
      final matchesText = e['note'].toString().toLowerCase().contains(q) ||
          e['category'].toString().toLowerCase().contains(q);
      return matchesType && matchesText;
    }).toList();
  }

  String money(num value) =>
      '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';

  Future<void> openForm({Map<String, dynamic>? item}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: item),
      ),
    );
    if (result == true) loadTransactions();
  }

  Future<void> deleteTransaction(Map<String, dynamic> item) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: Text('Bạn có chắc muốn xóa "${item['note']}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: expenseRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (yes == true) {
      await DatabaseHelper.instance.deleteTransaction(item['id'] as int);
      loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final recent = visibleTransactions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thu chi', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => showAboutDialog(
            context: context,
            applicationName: 'Expense Manager',
            applicationVersion: '1.0.0',
            children: const [Text('Ứng dụng quản lý thu nhập và chi tiêu cá nhân bằng SQLite.')],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: loadTransactions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 30),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadTransactions,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4C86F5), Color(0xFF1457D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Text('SỐ DƯ HIỆN TẠI', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          SizedBox(width: 8), Icon(Icons.account_balance_wallet, color: Colors.white70, size: 18),
                        ]),
                        const SizedBox(height: 12),
                        Text(money(balance), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('${transactions.length} giao dịch đã ghi nhận', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _summaryCard('TỔNG THU NHẬP', totalIncome, incomeGreen, Icons.south)),
                    const SizedBox(width: 12),
                    Expanded(child: _summaryCard('TỔNG CHI TIÊU', totalExpense, expenseRed, Icons.north)),
                  ]),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Giao dịch gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => setState(() => filter = 'Tất cả'),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm theo nội dung hoặc danh mục...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() => keyword = v),
                  ),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, children: ['Tất cả', 'Thu nhập', 'Chi tiêu'].map((v) =>
                    ChoiceChip(label: Text(v), selected: filter == v, onSelected: (_) => setState(() => filter = v))
                  ).toList()),
                  const SizedBox(height: 10),
                  if (recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(children: [
                        Icon(Icons.receipt_long, size: 54, color: Colors.blueGrey),
                        SizedBox(height: 10),
                        Text('Chưa có giao dịch. Nhấn nút + để thêm mới.'),
                      ]),
                    )
                  else
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (int i = 0; i < recent.length; i++) ...[
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              leading: CircleAvatar(
                                backgroundColor: recent[i]['type'] == 'Thu nhập'
                                    ? incomeGreen.withValues(alpha: .12)
                                    : expenseRed.withValues(alpha: .12),
                                child: Icon(_categoryIcon(recent[i]['category'].toString()),
                                  color: recent[i]['type'] == 'Thu nhập' ? incomeGreen : expenseRed),
                              ),
                              title: Text(recent[i]['note'].toString().isEmpty ? recent[i]['category'].toString() : recent[i]['note'].toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${recent[i]['category']} • ${_dateLabel(recent[i]['date'].toString())}'),
                              trailing: Text(
                                '${recent[i]['type'] == 'Thu nhập' ? '+' : '-'}${money(recent[i]['amount'] as num)}',
                                style: TextStyle(fontWeight: FontWeight.bold,
                                  color: recent[i]['type'] == 'Thu nhập' ? incomeGreen : expenseRed),
                              ),
                              onTap: () => openForm(item: recent[i]),
                              onLongPress: () => deleteTransaction(recent[i]),
                            ),
                            if (i != recent.length - 1) const Divider(height: 1, indent: 72),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text('Chạm giao dịch để chỉnh sửa • Nhấn giữ để xóa', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String title, double value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withValues(alpha: .09), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FittedBox(child: Text(money(value), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 17))),
        ]),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Ăn uống': return Icons.restaurant;
      case 'Di chuyển': return Icons.directions_car;
      case 'Mua sắm': return Icons.shopping_cart;
      case 'Học tập': return Icons.school;
      case 'Lương': return Icons.payments;
      case 'Hóa đơn': return Icons.receipt;
      case 'Giải trí': return Icons.movie;
      default: return Icons.category;
    }
  }

  String _dateLabel(String raw) {
    final d = DateTime.tryParse(raw) ?? DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class TransactionFormScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  const TransactionFormScreen({super.key, this.transaction});
  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'Chi tiêu';
  String _category = 'Ăn uống';
  DateTime _date = DateTime.now();
  bool _saving = false;

  final List<String> _categories = ['Ăn uống', 'Di chuyển', 'Mua sắm', 'Học tập', 'Hóa đơn', 'Giải trí', 'Lương', 'Thưởng', 'Khác'];

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _type = t['type'] as String;
      _category = t['category'] as String;
      _amountController.text = (t['amount'] as num).toStringAsFixed(0);
      _noteController.text = t['note']?.toString() ?? '';
      _date = DateTime.tryParse(t['date'].toString()) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _date,
      firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'type': _type,
      'category': _category,
      'amount': double.parse(_amountController.text.replaceAll(',', '').replaceAll('.', '')),
      'date': _date.toIso8601String(),
      'note': _noteController.text.trim(),
    };
    try {
      if (widget.transaction == null) {
        await DatabaseHelper.instance.insertTransaction(data);
      } else {
        await DatabaseHelper.instance.updateTransaction(widget.transaction!['id'] as int, data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể lưu giao dịch: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.transaction != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Sửa giao dịch' : 'Thêm giao dịch')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Chi tiêu', label: Text('Chi tiêu'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: 'Thu nhập', label: Text('Thu nhập'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 22),
            const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) { if (v != null) setState(() => _category = v); },
            ),
            const SizedBox(height: 18),
            const Text('Số tiền (VNĐ)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Ví dụ: 50000', border: OutlineInputBorder(), suffixText: 'đ'),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '').replaceAll('.', ''));
                if (n == null || n <= 0) return 'Nhập số tiền lớn hơn 0';
                return null;
              },
            ),
            const SizedBox(height: 18),
            const Text('Ngày giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text('${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}'),
            ),
            const SizedBox(height: 18),
            const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(controller: _noteController, maxLines: 3,
              decoration: const InputDecoration(hintText: 'Nhập nội dung giao dịch', border: OutlineInputBorder())),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
              label: Text(_saving ? 'Đang lưu...' : 'Lưu giao dịch'),
              style: FilledButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
