import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String? _selectedGender;
  bool _isConsented = false; 
  bool _isExistingProfile = false; 
  
  static const Color primaryRed = Color.fromARGB(255, 183, 38, 38); 

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    
    setState(() {
      _isExistingProfile = sp.getBool('hasSeenOnboarding') ?? false;
      
      if (_isExistingProfile) {
        _isConsented = true;
      }

      _nameController.text = sp.getString('name') ?? '';
      _surnameController.text = sp.getString('surname') ?? '';
      _dateController.text = sp.getString('dob') ?? '';
      _selectedGender = sp.getString('gender');
      _heightController.text = sp.getString('height') ?? '';
      _weightController.text = sp.getString('weight') ?? '';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryRed,       
              onPrimary: Colors.white,    
              onSurface: Colors.black87,  
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isConsented) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must accept the privacy policy to continue.')),
        );
        return;
      }

      final sp = await SharedPreferences.getInstance();
      await sp.setString('name', _nameController.text.trim());
      await sp.setString('surname', _surnameController.text.trim());
      await sp.setString('gender', _selectedGender!);
      await sp.setString('dob', _dateController.text);
      await sp.setString('height', _heightController.text.trim());
      await sp.setString('weight', _weightController.text.trim());
      
      await sp.setBool('hasSeenOnboarding', true);

      if (context.mounted) {
        if (_isExistingProfile) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacementNamed(context, '/home/');
        }
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryRed, width: 1.5),
      ),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 15),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: primaryRed,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primaryRed, 
          selectionColor: Color.fromARGB(80, 183, 38, 38), 
          selectionHandleColor: primaryRed, 
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white, 
        appBar: _isExistingProfile ? AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: primaryRed),
        ) : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (!_isExistingProfile) const SizedBox(height: 30),
                  Image.asset('assets/logo2.jpeg', height: 80, fit: BoxFit.contain),
                  const SizedBox(height: 20),
                  Text(
                    _isExistingProfile ? 'Edit your profile' : 'Introduce yourself', 
                    style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 32, color: primaryRed)
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration('Name'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _surnameController,
                          decoration: _buildInputDecoration('Surname'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration('Sex'),
                          value: _selectedGender,
                          items: ['M', 'F', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _selectedGender = v),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: _buildInputDecoration('Date of birth'),
                          onTap: () => _selectDate(context),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Height (cm)'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Weight (kg)'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),
                        
                        if (!_isExistingProfile) ...[
                          CheckboxListTile(
                            value: _isConsented,
                            onChanged: (val) => setState(() => _isConsented = val ?? false),
                            title: const Text("I consent to the processing of personal data.", style: TextStyle(fontSize: 14)),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: primaryRed,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(140, 44), 
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: const Text('Save', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                        ),
                        const SizedBox(height: 40), 
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}