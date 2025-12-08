import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/langchain_service.dart';
import '../widgets/code_block.dart';
import '../widgets/output_card.dart';
import '../widgets/api_key_dialog.dart';

class BasicChainScreen extends StatefulWidget {
  const BasicChainScreen({super.key});

  @override
  State<BasicChainScreen> createState() => _BasicChainScreenState();
}

class _BasicChainScreenState extends State<BasicChainScreen> {
  final _adjectiveController = TextEditingController(text: 'sarcastic');
  final _topicController = TextEditingController(text: 'programmers');
  String? _output;
  String? _error;
  bool _isLoading = false;

  static const String _codeExample = '''// 1. Create a prompt template
final prompt = PromptTemplate.fromTemplate(
  'Tell me a {adjective} joke about {topic}.'
);

// 2. Initialize the model
final model = ChatOpenAI(apiKey: '...');

// 3. Create a chain by piping components
final chain = prompt.pipe(model).pipe(StringOutputParser());

// 4. Run it
final result = await chain.invoke({
  'adjective': 'sarcastic',
  'topic': 'programmers',
});''';

  @override
  void dispose() {
    _adjectiveController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _runExample() async {
    if (!LangChainService.instance.isConfigured) {
      final configured = await ApiKeyDialog.show(context);
      if (!configured) return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await LangChainService.instance.runBasicChain(
        adjective: _adjectiveController.text,
        topic: _topicController.text,
      );
      setState(() {
        _output = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          const SizedBox(height: 32),

          // Main content in two columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Code and explanation
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConceptCard()
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideX(begin: -0.05),
                    const SizedBox(height: 24),
                    const CodeBlock(
                      code: _codeExample,
                      title: 'basic_chain.dart',
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Right column - Interactive demo
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDemoCard()
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: 0.05),
                    const SizedBox(height: 24),
                    OutputCard(
                      output: _output,
                      isLoading: _isLoading,
                      error: _error,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.link, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'EXAMPLE 1',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.primaryAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Basic Chain',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'The "Hello World" of LangChain — PromptTemplate + LLM',
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
        border: Border.all(color: AppTheme.surfaceColor.withValues(alpha: 0.5)),
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
                'Why it matters',
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
            'Instead of manually concatenating user input into a prompt string, we use a template. '
            'We "pipe" the template into the model, making the code clean, readable, and type-safe.',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildConceptDiagram(),
        ],
      ),
    );
  }

  Widget _buildConceptDiagram() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDiagramBox('PromptTemplate', AppTheme.secondaryAccent),
            _buildDiagramArrow(),
            _buildDiagramBox('LLM', AppTheme.primaryAccent),
            _buildDiagramArrow(),
            _buildDiagramBox('OutputParser', AppTheme.tertiaryAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramBox(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDiagramArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 20),
    );
  }

  Widget _buildDemoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.backgroundCard,
            AppTheme.surfaceColor.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: AppTheme.secondaryAccent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Try it yourself',
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.secondaryAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Adjective',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _adjectiveController,
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText: 'e.g., sarcastic, funny, dark',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Topic',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _topicController,
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText: 'e.g., programmers, cats, coffee',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _runExample,
              icon: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textPrimary,
                      ),
                    )
                  : const Icon(Icons.play_arrow, size: 20),
              label: Text(_isLoading ? 'Generating...' : 'Run Chain'),
            ),
          ),
        ],
      ),
    );
  }
}
