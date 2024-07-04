import 'package:flutter/material.dart';

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
                borderRadius: BorderRadius.circular(32),
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
