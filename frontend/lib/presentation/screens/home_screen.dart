import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/message_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChats();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      drawer: isDesktop ? null : const Drawer(child: Sidebar()),
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(provider.selectedChat?.title ?? "New Chat"),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => provider.createNewChat(),
                ),
              ],
            ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(),
          Expanded(
            child: Column(
              children: [
                // ── Chat Area ────────────────────────────────────────────────
                Expanded(
                  child: SelectionArea(
                    child: provider.selectedChat == null
                        ? _buildEmptyState()
                        : _buildMessageList(provider),
                  ),
                ),

                // ── Input Area ────────────────────────────────────────────────
                if (provider.selectedChat != null)
                  MessageInput(
                    isDisabled: provider.isAIGenerating,
                    onSend: (text) {
                      provider.sendMessage(text);
                      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.forum_outlined, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text(
            "How can I help you today?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<ChatProvider>().createNewChat(),
            icon: const Icon(Icons.add_rounded),
            label: const Text("Start a new chat"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider provider) {
    // Scroll to bottom whenever messages change or typing occurs
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: provider.messages.length + (provider.isAIGenerating ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < provider.messages.length) {
          return MessageBubble(message: provider.messages[index]);
        } else {
          // Virtual bubble for live streaming content
          final isTypingAndEmpty = provider.isAIGenerating && provider.currentTypingContent.isEmpty;
          
          return MessageBubble(
            message: MessageModel.temp(
              chatId: provider.selectedChat!.id,
              role: MessageRole.assistant,
              content: isTypingAndEmpty ? "Thinking..." : provider.currentTypingContent,
            ),
            isStreaming: true,
          );
        }
      },
    );
  }
}
