import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/user_repository.dart';
import '../../1_home/screens/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _saveNameAndProceed() {
    // ابتدا بررسی می‌کنیم که آیا فرم معتبر است (فیلد خالی نیست)
    if (_formKey.currentState!.validate()) {
      // <<<<< شروع تغییر: استفاده از مدیر پروفایل >>>>>
      // به مدیر پروفایل کاربر که در main.dart تعریف شده دسترسی پیدا می‌کنیم
      final userRepo = Provider.of<UserRepository>(context, listen: false);

      // یک پروفایل جدید برای کاربر می‌سازیم و آن را ذخیره می‌کنیم
      userRepo.createNewProfile(_nameController.text);
      // <<<<< پایان تغییر >>>>>

      // کاربر را به صفحه اصلی هدایت می‌کنیم
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(name: _nameController.text)),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت نام در شیشمینو'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'فقط یک قدم تا شروع ماجراجویی!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام و نام خانوادگی',
                    hintText: 'نام خود را اینجا وارد کنید',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  // اعتبارسنجی برای اطمینان از خالی نبودن فیلد
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'لطفاً نام خود را وارد کنید.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveNameAndProceed,
                  child: const Text('ورود به برنامه'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
