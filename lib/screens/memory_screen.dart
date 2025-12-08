import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/langchain_service.dart';
import '../widgets/code_block.dart';
import '../widgets/api_key_dialog.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const String _codeExample = '''// Initialize memory
final memory = ConversationBufferMemory(returnMessages: true);

// Create a conversation chain
final chain = ConversationChain(
  llm: ChatOpenAI(apiKey: '...'),
  memory: memory,
);

// Turn 1
await chain.run('Hi, my name is Alex.');
// Output: "Hello Alex! Nice to meet you."

// Turn 2 (The AI remembers "Alex")
await chain.run('What is my name?');
// Output: "Your name is Alex."''';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    if (!LangChainService.instance.isConfigured) {
      final configured = await ApiKeyDialog.show(context);
      if (!configured) return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _messageController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await LangChainService.instance.chat(message);
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Error: ${e.toString()}',
          isUser: false,
          isError: true,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _resetConversation() {
    LangChainService.instance.resetConversation();
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - Code and explanation
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1),
                const SizedBox(height: 32),
                _buildConceptCard()
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(begin: -0.05),
                const SizedBox(height: 24),
                const CodeBlock(
                  code: _codeExample,
                  title: 'memory_chain.dart',
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                const SizedBox(height: 24),
                _buildTipsCard()
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.05),
              ],
            ),
          ),
        ),

        // Right panel - Chat interface
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.surfaceColor.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildChatHeader(),
                Expanded(child: _buildChatMessages()),
                _buildChatInput(),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppGradients.secondaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryAccent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'EXAMPLE 2',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppTheme.secondaryAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Memory',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'A chatbot that remembers your conversation',
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConceptCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.warningAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'The Problem: Stateless APIs',
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.warningAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Most LLM APIs are stateless — they forget you immediately after each request. '
            'If you tell the AI your name in one message, it won\'t remember it in the next.\n\n'
            'LangChain solves this with ConversationBufferMemory, which automatically tracks '
            'inputs and outputs so you can have a real, continuous conversation.',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.tertiaryAccent.withValues(alpha: 0.1),
            AppTheme.tertiaryAccent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.tertiaryAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: AppTheme.tertiaryAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Try these prompts',
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.tertiaryAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('1. "Hi, my name is [Your Name]"'),
          _buildTipItem('2. "I love programming in Dart"'),
          _buildTipItem('3. "What is my name?"'),
          _buildTipItem('4. "What do I love doing?"'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppTheme.tertiaryAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.tertiaryAccent.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Chat with Memory',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _resetConversation,
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Reset conversation',
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppTheme.textMuted,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The AI will remember what you tell it',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textMuted.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: AppTheme.secondaryAccent,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryAccent.withValues(alpha: 0.9)
                    : message.isError
                        ? AppTheme.primaryAccent.withValues(alpha: 0.15)
                        : AppTheme.surfaceColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight:
                      message.isUser ? const Radius.circular(4) : null,
                  bottomLeft:
                      !message.isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.jetBrainsMono(
                  color: message.isError
                      ? AppTheme.primaryAccent
                      : AppTheme.textPrimary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 16,
                color: AppTheme.primaryAccent,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 16,
              color: AppTheme.secondaryAccent,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryAccent,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .fadeIn(delay: Duration(milliseconds: i * 200))
                    .then()
                    .fadeOut(delay: const Duration(milliseconds: 400));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: AppTheme.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.secondaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: Icon(
                Icons.send,
                color: _isLoading
                    ? AppTheme.textMuted
                    : AppTheme.backgroundDark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}

