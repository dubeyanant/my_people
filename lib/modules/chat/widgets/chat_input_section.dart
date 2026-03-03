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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
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
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.surfaceContainer,
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
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.4, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));

              final fadeAnimation = CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
              );

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: !isTextFieldEmpty
                ? Padding(
                    key: const ValueKey<bool>(true),
                    padding: const EdgeInsets.only(left: 8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.85, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.45),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded),
                          onPressed: onSendMessage,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey<bool>(false)),
          ),
        ],
      ),
    );
  }
}
