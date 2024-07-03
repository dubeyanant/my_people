import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:my_people/screens/home_screen/home_screen.dart';
import 'package:my_people/utility/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _defaultImage;
  late Timer _timer;
  final Random _random = Random();
  static const int _totalDefaultImages = 8;
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);
  bool _isReadOnly = false;
  bool _showOtpField = false;

  @override
  void initState() {
    super.initState();
    _updateImage();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      setState(() {
        _updateImage();
      });
    });

    // Request focus to the email field when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });

    // Add listener to the email controller to enable/disable the submit button
    _emailController.addListener(() {
      _isButtonEnabled.value = _isValidEmail(_emailController.text);
    });
  }

  void _updateImage() {
    int imageNumber = _random.nextInt(_totalDefaultImages) + 1;
    _defaultImage = 'assets/default$imageNumber.png';
  }

  @override
  void dispose() {
    _timer.cancel();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _isButtonEnabled.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _submitEmail() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isReadOnly = true;
        _showOtpField = true;
        _isButtonEnabled.value = false;
      });
    }
  }

  void _submitOtp(String otp) async {
    Get.off(() => const HomeScreen());
    await SharedPrefs.setLoggedIn(true);
  }

  void _onOtpChanged(String otp) {
    _isButtonEnabled.value = otp.length == 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 80),
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(_defaultImage),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Welcome!\nReady to Make Every Interaction Count?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Please log in to access your profiles and details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      onTapOutside: (event) => _emailFocusNode.unfocus(),
                      keyboardType: TextInputType.emailAddress,
                      readOnly: _isReadOnly,
                      decoration: InputDecoration(
                        filled: _isReadOnly,
                        fillColor: Colors.grey[300],
                        prefixIcon: const Icon(Icons.email),
                        labelText: _isReadOnly ? '' : 'Email',
                        hintText: 'janedoe@yourmail.com',
                        enabled: !_isReadOnly,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!_isValidEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    if (_showOtpField) ...[
                      const SizedBox(height: 16),
                      OTPInput(onOtpChanged: _onOtpChanged),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _isButtonEnabled,
                builder: (context, isEnabled, child) {
                  return GestureDetector(
                    onTap: isEnabled
                        ? (_showOtpField
                            ? () => _submitOtp(_emailController.text)
                            : _submitEmail)
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _isButtonEnabled.value
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                      ),
                      child: Text(
                        _showOtpField ? 'Login' : 'Next',
                        style: TextStyle(
                          color: _isButtonEnabled.value
                              ? Theme.of(context).colorScheme.onPrimary
                              : Colors.grey[800],
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OTPInput extends StatefulWidget {
  final Function(String) onOtpChanged;

  const OTPInput({super.key, required this.onOtpChanged});

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(() {
        String otp = _controllers.map((c) => c.text).join();
        widget.onOtpChanged(otp);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 40,
          child: TextFormField(
            controller: _controllers[index],
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              if (value.length == 1) {
                if (index < 5) {
                  FocusScope.of(context).nextFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              }
            },
          ),
        );
      }),
    );
  }
}
