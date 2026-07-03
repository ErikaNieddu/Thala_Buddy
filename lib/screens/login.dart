import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thala_buddy/services/impact.dart'; 
import 'package:thala_buddy/screens/forgot_password.dart'; 

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final Impact impact = Impact();
  
  bool _obscurePassword = true;
  bool _rememberMe = false; 

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials(); 
  }

  Future<void> _loadRememberedCredentials() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = sp.getBool('remember_me') ?? false;
      if (_rememberMe) {
        userController.text = sp.getString('rememberED_username') ?? '';
        passwordController.text = sp.getString('rememberED_password') ?? '';
      }
    });
  }

  Future<void> _performLogin() async {
    String username = userController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid credentials')),
      );
      return;
    }

    int statusCode = await impact.getAndStoreTokens(username, password);

    if (!mounted) return;

    if (statusCode == 200) {
      final sp = await SharedPreferences.getInstance();
      
      await sp.setBool('isLoggedIn', true); 
      await sp.setBool('remember_me', _rememberMe);
      
      if (_rememberMe) {
        await sp.setString('rememberED_username', username);
        await sp.setString('rememberED_password', password);
      } else {
        await sp.remove('rememberED_username');
        await sp.remove('rememberED_password');
      }

      await sp.setString('username', username);
      await sp.setString('password', password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged in successfully!'),
            backgroundColor: Color.fromARGB(255, 99, 99, 99), // Messaggio grigio
          ),
        );
      }

      Navigator.pushReplacementNamed(context, '/guide/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect credentials or server unreachable ($statusCode)'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              const Spacer(flex: 2),
              Image.asset('assets/logo2.jpeg', height: 90, fit: BoxFit.contain),
              const SizedBox(height: 20), 
              const Text('Hey buddy!', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 42, color: Color(0xFFB72626)), textAlign: TextAlign.center),
              const Text('Login please', style: TextStyle(fontSize: 26, color: Colors.black, fontWeight: FontWeight.w300), textAlign: TextAlign.center),
              const Spacer(flex: 1), 
              
              TextField(
                controller: userController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(width: 1.5)),
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: passwordController,
                obscureText: _obscurePassword, 
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(width: 1.5)),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              
              CheckboxListTile(
                title: const Text("Remember me", style: TextStyle(color: Colors.black54, fontSize: 16)),
                value: _rememberMe,
                onChanged: (bool? val) => setState(() => _rememberMe = val ?? false),
                activeColor: const Color(0xFFB72626), 
                controlAffinity: ListTileControlAffinity.leading,
              ),

              ElevatedButton(
                onPressed: _performLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB72626), 
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 50), 
                  shape: const StadiumBorder(),
                ),
                child: const Text('Log in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
              ),
              const SizedBox(height: 25),
              
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPassword())),
                child: const Text('Forgot password?', style: TextStyle(color: Colors.black, fontSize: 16, decoration: TextDecoration.underline)),
              ),
              const Spacer(flex: 2), 
            ],
          ),
        ),
      ),
    );
  }
}