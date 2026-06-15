import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Container(
      width: AppConstants.sidebarWidth,
      color: AppTheme.sidebarBg,
      child: Column(
        children: [
          // ── New Chat Button ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => provider.createNewChat(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, size: 20),
                    SizedBox(width: 12),
                    Text("New Chat", style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),

          // ── Chat List ──────────────────────────────────────────────────────
          Expanded(
            child: provider.isLoadingChats
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: provider.chats.length,
                    itemBuilder: (context, index) {
                      final chat = provider.chats[index];
                      final isSelected = provider.selectedChat?.id == chat.id;

                      return _ChatListTile(
                        title: chat.title,
                        isSelected: isSelected,
                        onTap: () => provider.selectChat(chat),
                        onDelete: () => provider.deleteChat(chat.id),
                      );
                    },
                  ),
          ),

          // ── Model Selector ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "AI Model",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    Tooltip(
                      message: "Refresh model list",
                      child: IconButton(
                        onPressed: () => provider.refreshModels(),
                        icon: const Icon(Icons.sync_rounded, size: 16, color: Colors.white38),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                provider.availableModels.isEmpty
                    ? const Text(
                        "No models found. Pull a model in terminal first.",
                        style: TextStyle(color: Colors.white24, fontSize: 10),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.availableModels.contains(provider.selectedModel) 
                                ? provider.selectedModel 
                                : provider.availableModels.first,
                            isExpanded: true,
                            dropdownColor: AppTheme.sidebarBg,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            items: provider.availableModels.map((String model) {
                              return DropdownMenuItem<String>(
                                value: model,
                                child: Text(model),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                provider.setSelectedModel(newValue);
                              }
                            },
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ChatListTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        dense: true,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isSelected ? Colors.white10 : Colors.transparent,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? Tooltip(
                message: "Delete chat",
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white38),
                  onPressed: onDelete,
                ),
              )
            : null,
      ),
    );
  }
}
