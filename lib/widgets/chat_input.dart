import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// =====================================================
// COMPONENT CONFIGURATION
// =====================================================

// Defines the chat input component and its external callback.
class ChatInput extends StatefulWidget {
  const ChatInput({required this.onSubmitted, super.key});

  // AUX: Sends the submitted message to the parent widget.
  final ValueChanged<String> onSubmitted;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

// =====================================================
// AUXILIARY — KEYBOARD INTENT DEFINITIONS
// =====================================================

// AUX: Represents the intention to submit a message.
class _SubmitMessageIntent extends Intent {
  const _SubmitMessageIntent();
}

// AUX: Represents the intention to insert a line break.
class _InsertNewlineIntent extends Intent {
  const _InsertNewlineIntent();
}

class _ChatInputState extends State<ChatInput> {
  // ===================================================
  // AUXILIARY — STATE AND BEHAVIOR
  // ===================================================

  // AUX: Stores and monitors the text entered in the input.
  final TextEditingController _controller = TextEditingController();

  // AUX: Inserts a line break at the current cursor position.
  // Used by the Shift+Enter shortcut.
  void _insertNewline() {
    final value = _controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;

    _controller.value = value.copyWith(
      text: value.text.replaceRange(start, end, '\n'),
      selection: TextSelection.collapsed(offset: start + 1),
      composing: TextRange.empty,
    );
  }

  // AUX: Validates and submits the message, then clears the input.
  // Used by the send button and Enter shortcut.
  void _submit() {
    final message = _controller.text;
    if (message.trim().isEmpty) return;

    widget.onSubmitted(message);
    _controller.clear();
  }

  // AUX: Releases the text controller when the widget is removed.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ===================================================
  // SCREEN — VISUAL STRUCTURE AND INTERACTIONS
  // ===================================================

  @override
  Widget build(BuildContext context) {
    // AUX: Provides the colors used by the visible elements.
    final colorScheme = Theme.of(context).colorScheme;

    // TELA: Main rounded container surrounding the chat input.
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(28),
      ),

      // TELA: Horizontal layout containing the input and send button.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // TELA: Text input area, expanded to fill available space.
          Expanded(
            child: Shortcuts(
              // BEHAVIOR: Maps keyboard keys to auxiliary intentions.
              shortcuts: const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.enter):
                    _SubmitMessageIntent(),
                SingleActivator(LogicalKeyboardKey.enter, shift: true):
                    _InsertNewlineIntent(),
              },

              // BEHAVIOR: Connects keyboard intentions to auxiliary methods.
              child: Actions(
                //- Action: define como o aplicativo executará essa intenção.
                actions: <Type, Action<Intent>>{
                  //Intent: representa o que o usuário deseja fazer.

                  // Enter calls AUX: _submit().
                  _SubmitMessageIntent: CallbackAction<_SubmitMessageIntent>(
                    // ACTION: Execute the auxiliary message submission method.
                    onInvoke: (_) {
                      _submit();
                      return null;
                    },
                  ),

                  // INTENT: The user requested a new line (Shift+Enter).
                  _InsertNewlineIntent: CallbackAction<_InsertNewlineIntent>(
                    // ACTION: Execute the auxiliary newline insertion method.
                    onInvoke: (_) {
                      _insertNewline();
                      return null;
                    },
                  ),
                },

                // TELA: Editable text field where the user types.
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),

                  // TELA: Placeholder, border removal, and inner spacing.
                  decoration: const InputDecoration(
                    hintText: 'Envie uma mensagem...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // TELA: Horizontal spacing before the send button.
          const SizedBox(width: 8),

          // BEHAVIOR: Rebuilds the button when AUX: _controller changes.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final canSubmit = value.text.trim().isNotEmpty;

              // TELA: Send button, disabled when the input is empty.
              return IconButton.filled(
                onPressed: canSubmit ? _submit : null,
                tooltip: 'Enviar mensagem',
                icon: const Icon(Icons.arrow_upward_rounded),
              );
            },
          ),
        ],
      ),
    );
  }
}
