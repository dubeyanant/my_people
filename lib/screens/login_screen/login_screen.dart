import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:my_people/helpers/internet_connectivity_helper.dart';
import 'package:my_people/screens/login_screen/otp_input.dart';
import 'package:my_people/screens/home_screen/home_screen.dart';
import 'package:my_people/utility/debug_print.dart';
import 'package:my_people/utility/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final bool showGithubLogin;

  const LoginScreen({super.key, this.showGithubLogin = false});

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
  final ValueNotifier<bool> _isTyping = ValueNotifier(false);
  bool _isReadOnly = false;
  bool _showOtpField = false;
  String _currentOtp = '';
  bool _canResendOtp = false;
  int _resendTimer = 60;
  Timer? _resendOtpTimer;

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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   FocusScope.of(context).requestFocus(_emailFocusNode);
    // });

    // Add listener to the email controller to enable/disable the submit button
    _emailController.addListener(() {
      _isButtonEnabled.value = _isValidEmail(_emailController.text);
      _isTyping.value = _emailController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _resendOtpTimer?.cancel();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _isButtonEnabled.dispose();
    super.dispose();
  }

  void _updateImage() {
    int imageNumber = _random.nextInt(_totalDefaultImages) + 1;
    _defaultImage = 'assets/default$imageNumber.png';
  }

  void _skipLogin() async {
    if (await isConnected()) {
      await Supabase.instance.client.auth
          .signInAnonymously()
          .then((value) async {
        Get.off(() => const HomeScreen());
        await SharedPrefs.setLoggedIn(true);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please check your internet connection and try again!',
            ),
          ),
        );
      }
    }
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _submitEmail(String email) async {
    if (_formKey.currentState!.validate() && await isConnected()) {
      setState(() {
        _isButtonEnabled.value = false;
      });

      try {
        final supabase = Supabase.instance.client;
        await supabase.auth.signInWithOtp(email: email);

        setState(() {
          _isReadOnly = true;
          _showOtpField = true;
          _canResendOtp = false;
        });

        _startResendOtpTimer();

        // Focus on the OTP field
        if (mounted) FocusScope.of(context).unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).nextFocus();
        });
      } catch (error) {
        DebugPrint.log(
          'Error sending OTP: $error',
          color: DebugColor.red,
          tag: 'LoginScreen',
        );
        if (mounted) {
          if (error.toString().contains('statusCode: 429') ||
              error.toString().contains('rate limit')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to send OTP. Please try in an hour.',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to send OTP. Please try again later.',
                ),
              ),
            );
          }
        }
      } finally {
        setState(() {
          _isButtonEnabled.value = true;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please check your internet connection!',
            ),
          ),
        );
      }
    }
  }

  void _startResendOtpTimer() {
    _resendTimer = 60;
    _resendOtpTimer?.cancel();
    _resendOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResendOtp = true;
          timer.cancel();
        }
      });
    });
  }

  void _submitOtp(String email) async {
    try {
      var supabase = Supabase.instance.client;
      await supabase.auth.verifyOTP(
        email: email,
        token: _currentOtp,
        type: OtpType.email,
      );

      supabase.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;

        if (event == AuthChangeEvent.signedIn) {
          Get.off(() => const HomeScreen());
          await SharedPrefs.setLoggedIn(true);
        } else {}
      });
    } catch (err) {
      DebugPrint.log(
        'Error verifying OTP: $err',
        color: DebugColor.red,
        tag: 'LoginScreen',
      );
      if (mounted) {
        if (err.toString().contains('expired') ||
            err.toString().contains('Invalid')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Token has expired or is invalid. Please try again!',
              ),
            ),
          );
        } else if (err.toString().contains('SocketException')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please check your internet connection and try again!',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to verify OTP. Please try again later.',
              ),
            ),
          );
        }
      }
    }
  }

  void _onOtpChanged(String otp) {
    _isButtonEnabled.value = otp.length == 6;
    _currentOtp = otp;
    if (otp.length == 6) {
      _submitOtp(_emailController.text);
    }
  }

  Future<void> signInWithGithub() async {
    await Supabase.instance.client.auth
        .signInWithOAuth(OAuthProvider.github)
        .then((value) {
      Get.off(() => const HomeScreen());
      SharedPrefs.setLoggedIn(true);
    });
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        enabled: !_isReadOnly,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OTPInput(onOtpChanged: _onOtpChanged),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _canResendOtp
                            ? () {
                                _submitEmail(_emailController.text);
                                _startResendOtpTimer();
                              }
                            : null,
                        child: Text(
                          _canResendOtp
                              ? 'Resend OTP'
                              : 'Resend OTP in $_resendTimer seconds',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _isTyping,
                builder: (context, isTyping, child) {
                  return Visibility(
                    visible: !isTyping,
                    child: Column(
                      children: [
                        if (widget.showGithubLogin)
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(32),
                            child: GestureDetector(
                              onTap: () {
                                signInWithGithub();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset('assets/github.svg',
                                        width: 24),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Sign in with GitHub',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (widget.showGithubLogin) const SizedBox(height: 16),
                        // ElevatedButton(
                        //   onPressed: _skipLogin,
                        //   style: ElevatedButton.styleFrom(
                        //     minimumSize: const Size(double.infinity, 50),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(32),
                        //     ),
                        //   ),
                        //   child: const Text('Skip Login'),
                        // ),
                        GestureDetector(
                          onTap: _skipLogin,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(32),
                            color: Theme.of(context).colorScheme.primary,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 16),
                                  Text(
                                    'Skip Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.lock_open_rounded,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isTyping,
                builder: (context, isTyping, child) {
                  return Visibility(
                    visible: isTyping,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isButtonEnabled,
                      builder: (context, isEnabled, child) {
                        return GestureDetector(
                          onTap: isEnabled
                              ? _showOtpField
                                  ? () => _submitOtp(_emailController.text)
                                  : () => _submitEmail(_emailController.text)
                              : null,
                          child: Material(
                            elevation: _isButtonEnabled.value ? 4 : 0,
                            borderRadius: BorderRadius.circular(32),
                            color: _isButtonEnabled.value
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.background,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: _isButtonEnabled.value
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 16),
                                  Text(
                                    _showOtpField ? 'Login' : 'Next',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _isButtonEnabled.value
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _showOtpField
                                        ? Icons.lock_open_rounded
                                        : Icons.arrow_forward_ios,
                                    color: _isButtonEnabled.value
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Colors.grey[800],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
