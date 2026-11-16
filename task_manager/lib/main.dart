
import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

const Color primaryBlue = Color(0xFF2169D5);
const Color expenseRed = Color(0xFFFF626C);

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
      ),
      home: const WelcomeScreen(),
    );
  }
}

// MÀN HÌNH CHÀO MỪNG
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: primaryBlue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Expense Manager',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14243D),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 260,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionHomeScreen(),
                      ),
                    );
                  },
                  child: const Text('Bắt đầu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MÀN HÌNH CHỌN CHỨC NĂNG
class TransactionHomeScreen extends StatefulWidget {
  const TransactionHomeScreen({super.key});

  @override
  State<TransactionHomeScreen> createState() =>
      _TransactionHomeScreenState();
}

class _TransactionHomeScreenState extends State<TransactionHomeScreen> {
  String transactionName = 'Ăn trưa';
  String amount = '100000';
  String category = 'Ăn uống';
  String type = 'Chi tiêu';
  DateTime date = DateTime(2025, 4, 12);
  String note = 'Ăn trưa';

  Future<void> openAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionFormScreen(),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        transactionName = result['note'].toString().isEmpty
            ? result['category'].toString()
            : result['note'].toString();
        amount = result['amount'].toString();
        category = result['category'].toString();
        type = result['type'].toString();
        date = result['date'] as DateTime;
        note = result['note'].toString();
      });
    }
  }

  Future<void> openEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(
          isEdit: true,
          initialType: type,
          initialCategory: category,
          initialAmount: amount,
          initialDate: date,
          initialNote: note,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        transactionName = result['note'].toString().isEmpty
            ? result['category'].toString()
            : result['note'].toString();
        amount = result['amount'].toString();
        category = result['category'].toString();
        type = result['type'].toString();
        date = result['date'] as DateTime;
        note = result['note'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý giao dịch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giao dịch của tôi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: type == 'Chi tiêu'
                      ? const Color(0xFFFFE5E7)
                      : const Color(0xFFE2F5E8),
                  child: Icon(
                    type == 'Chi tiêu'
                        ? Icons.shopping_bag
                        : Icons.account_balance_wallet,
                    color: type == 'Chi tiêu'
                        ? expenseRed
                        : Colors.green,
                  ),
                ),
                title: Text(
                  transactionName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '$category • ${date.day}/${date.month}/${date.year}',
                ),
                trailing: Text(
                  '${type == 'Chi tiêu' ? '-' : '+'}${amount} đ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: type == 'Chi tiêu'
                        ? expenseRed
                        : Colors.green,
                  ),
                ),
                onTap: openEditScreen,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nhấn vào giao dịch để chỉnh sửa.',
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: openAddScreen,
                icon: const Icon(Icons.add),
                label: const Text('Thêm giao dịch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MÀN HÌNH THÊM VÀ SỬA GIAO DỊCH
class TransactionFormScreen extends StatefulWidget {
  final bool isEdit;
  final String initialType;
  final String initialCategory;
  final String initialAmount;
  final DateTime? initialDate;
  final String initialNote;

  const TransactionFormScreen({
    super.key,
    this.isEdit = false,
    this.initialType = 'Chi tiêu',
    this.initialCategory = 'Ăn uống',
    this.initialAmount = '',
    this.initialDate,
    this.initialNote = '',
  });

  @override
  State<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String selectedType = 'Chi tiêu';
  String selectedCategory = 'Ăn uống';
  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Hóa đơn',
    'Giải trí',
    'Lương',
    'Thưởng',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();

    selectedType = widget.initialType;
    selectedCategory = widget.initialCategory;
    amountController.text = widget.initialAmount;
    noteController.text = widget.initialNote;
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void saveTransaction() {
    final amount = double.tryParse(
      amountController.text.trim().replaceAll(',', ''),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ!'),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'type': selectedType,
      'category': selectedCategory,
      'amount': amountController.text.trim(),
      'date': selectedDate,
      'note': noteController.text.trim(),
    });
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF14243D),
        ),
      ),
    );
  }

  InputDecoration fieldDecoration({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chọn loại giao dịch
              Row(
                children: [
                  Expanded(
                    child: typeButton('Chi tiêu', expenseRed),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: typeButton('Thu nhập', Colors.green),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              buildLabel('Danh mục'),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: fieldDecoration(),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.restaurant,
                          color: expenseRed,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              buildLabel('Số tiền'),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: fieldDecoration(
                  hint: 'Nhập số tiền',
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text('đ'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              buildLabel('Ngày giao dịch'),

              InkWell(
                onTap: selectDate,
                child: InputDecorator(
                  decoration: fieldDecoration(
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                  child: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              buildLabel('Ghi chú'),

              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: fieldDecoration(
                  hint: 'Nhập ghi chú (tùy chọn)',
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget typeButton(String title, Color color) {
    final selected = selectedType == title;

    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedType = title;
          });
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: selected ? color : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black87,
          side: BorderSide(
            color: selected ? color : const Color(0xFFE0E5ED),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
