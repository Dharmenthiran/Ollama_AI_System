import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isDisabled;

  const MessageInput({
    super.key,
    required this.onSend,
    this.isDisabled = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty && !widget.isDisabled) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: AppTheme.userBubble,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  style: const TextStyle(color: AppTheme.textMain),
                  decoration: const InputDecoration(
                    hintText: "Message ChatGPT...",
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              Tooltip(
                message: widget.isDisabled ? "Stop generating" : "Send message",
                child: IconButton(
                  onPressed: widget.isDisabled 
                      ? () => context.read<ChatProvider>().stopGenerating() 
                      : _handleSend,
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isDisabled ? Icons.stop_rounded : Icons.arrow_upward_rounded,
                      color: Colors.black,
                      size: 20,
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
}
