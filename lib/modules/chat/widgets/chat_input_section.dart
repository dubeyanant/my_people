import 'package:flutter/material.dart';

import 'package:my_people/utility/constants.dart';

class ChatInputSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final bool isTextFieldEmpty;
  final VoidCallback onSendMessage;

  const ChatInputSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.isTextFieldEmpty,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 3,
              minLines: 1,
              enabled: !loading,
              onTap: () => focusNode.requestFocus(),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 0.5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(36),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 0.5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(36),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 1.5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(36),
                  ),
                ),
                fillColor: loading
                    ? Colors.grey[200]
                    : Theme.of(context).colorScheme.primaryContainer,
                filled: true,
                contentPadding: const EdgeInsets.all(16),
                hintText: loading ? AppStrings.waiting : AppStrings.ask,
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: !isTextFieldEmpty
                ? Container(
                    key: const ValueKey<bool>(true),
                    padding: const EdgeInsets.only(left: 4),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: onSendMessage,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : const SizedBox(key: ValueKey<bool>(false)),
          ),
        ],
      ),
    );
  }
}
