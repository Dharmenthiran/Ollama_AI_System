import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import '../../data/models/message_model.dart';
import '../../core/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildContent(context, isUser),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? AppTheme.accentColor : Colors.deepPurple,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? AppTheme.userBubble : AppTheme.aiBubble,
        borderRadius: BorderRadius.circular(16),
      ),
      child: MarkdownBody(
        data: message.content,
        selectable: false,
        extensionSet: md.ExtensionSet(
          [
            ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
            LatexBlockSyntax(),
          ],
          [
            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
            LatexInlineSyntax(),
          ],
        ),
        builders: {
          'code': CodeBlockBuilder(),
          'latex': LatexElementBuilder(),
        },
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.inter(
            color: AppTheme.textMain,
            fontSize: 16,
            height: 1.5,
          ),
          code: GoogleFonts.firaCode(
            backgroundColor: Colors.black26,
            fontSize: 14,
          ),
          codeblockDecoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class']!;
      language = lg.substring(9);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: HighlightView(
        element.textContent,
        language: language,
        theme: atomOneDarkTheme,
        padding: const EdgeInsets.all(12),
        textStyle: GoogleFonts.firaCode(fontSize: 14),
      ),
    );
  }
}
