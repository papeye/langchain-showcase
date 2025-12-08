import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/langchain_service.dart';
import '../widgets/code_block.dart';
import '../widgets/api_key_dialog.dart';

class StructuredOutputScreen extends StatefulWidget {
  const StructuredOutputScreen({super.key});

  @override
  State<StructuredOutputScreen> createState() => _StructuredOutputScreenState();
}

class _StructuredOutputScreenState extends State<StructuredOutputScreen> {
  final _textController = TextEditingController(
    text: 'Meeting with Sarah and John at 2 PM on Friday to discuss the new UI design. '
        'We need to review the color palette and finalize the homepage layout.',
  );
  Map<String, dynamic>? _output;
  String? _error;
  bool _isLoading = false;

  static const String _codeExample = '''// Define the structure you want
final prompt = PromptTemplate.fromTemplate(
  'Extract information from this text.\\n'
  'Format: {format_instructions}\\n'
  'Text: {text}'
);

final chain = prompt.pipe(model).pipe(JsonOutputParser());

final result = await chain.invoke({
  'format_instructions': parser.getFormatInstructions(),
  'text': 'Meeting with Sarah at 2 PM on Friday...',
});

// Result is a genuine Dart Map!
// {
//   "summary": "UI Meeting",
//   "participants": ["Sarah"],
//   "time": "14:00",
//   "day": "Friday"
// }''';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _runExtraction() async {
    if (!LangChainService.instance.isConfigured) {
      final configured = await ApiKeyDialog.show(context);
      if (!configured) return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _output = null;
    });

    try {
      final result = await LangChainService.instance.extractStructuredData(
        _textController.text,
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
          _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
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
                      title: 'structured_output.dart',
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Right column
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputCard()
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: 0.05),
                    const SizedBox(height: 24),
                    _buildOutputCard()
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.05),
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
            gradient: AppGradients.successGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.tertiaryAccent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.data_object,
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
                  color: AppTheme.tertiaryAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'EXAMPLE 3',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppTheme.tertiaryAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Structured Output',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Get usable JSON data instead of free text',
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
                'Building App Features, Not Chat Bubbles',
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
            'Developers hate parsing AI text with Regex. When building real apps, '
            'you need structured data — not rambling paragraphs.\n\n'
            'LangChain lets you define a schema, and it forces the AI to return clean JSON '
            'that maps directly to your Dart classes.',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildComparisonRow(),
        ],
      ),
    );
  }

  Widget _buildComparisonRow() {
    return Row(
      children: [
        Expanded(
          child: _buildComparisonBox(
            'Without LangChain',
            '"The meeting is with Sarah at 2 PM on Friday to talk about UI stuff..."',
            AppTheme.primaryAccent,
            Icons.close,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildComparisonBox(
            'With LangChain',
            '{"participants": ["Sarah"],\n "time": "14:00"}',
            AppTheme.tertiaryAccent,
            Icons.check,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonBox(
      String title, String content, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
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
          color: AppTheme.tertiaryAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note,
                color: AppTheme.tertiaryAccent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Input Text',
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.tertiaryAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 5,
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter text to extract structured data from...',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _runExtraction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tertiaryAccent,
              ),
              icon: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.backgroundDark,
                      ),
                    )
                  : Icon(Icons.auto_awesome, size: 20, color: AppTheme.backgroundDark),
              label: Text(
                _isLoading ? 'Extracting...' : 'Extract Data',
                style: TextStyle(color: AppTheme.backgroundDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          color: _error != null
              ? AppTheme.primaryAccent.withValues(alpha: 0.5)
              : AppTheme.surfaceColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.data_object,
                      size: 14,
                      color: AppTheme.secondaryAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Structured Output',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.secondaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.secondaryAccent,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            _buildLoadingState()
          else if (_error != null)
            _buildErrorState()
          else if (_output != null)
            _buildJsonOutput()
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            width: 150.0 + (i * 30),
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: const Duration(milliseconds: 1500),
                color: AppTheme.secondaryAccent.withValues(alpha: 0.1),
              ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.primaryAccent,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              _error!,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.primaryAccent,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _output!.entries.map((entry) {
        return _buildJsonField(entry.key, entry.value);
      }).toList(),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildJsonField(String key, dynamic value) {
    Color keyColor = AppTheme.secondaryAccent;
    Widget valueWidget;

    if (value is List) {
      valueWidget = Wrap(
        spacing: 8,
        runSpacing: 8,
        children: value.map<Widget>((item) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.tertiaryAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '"$item"',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.tertiaryAccent,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      );
    } else if (value == null) {
      valueWidget = Text(
        'null',
        style: GoogleFonts.jetBrainsMono(
          color: AppTheme.textMuted,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      );
    } else {
      valueWidget = Text(
        value is String ? '"$value"' : value.toString(),
        style: GoogleFonts.jetBrainsMono(
          color: value is String
              ? AppTheme.warningAccent
              : AppTheme.primaryAccent,
          fontSize: 13,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: GoogleFonts.jetBrainsMono(
              color: keyColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Row(
      children: [
        Icon(
          Icons.lightbulb_outline,
          color: AppTheme.textMuted,
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Extract structured data from your text',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

