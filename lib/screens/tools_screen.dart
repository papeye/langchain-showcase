import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/langchain_service.dart';
import '../widgets/code_block.dart';
import '../widgets/api_key_dialog.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final _queryController = TextEditingController(text: 'What is 253 times 12?');
  AgentResult? _result;
  String? _error;
  bool _isLoading = false;

  final List<String> _sampleQueries = [
    'What is 253 times 12?',
    'What time is it right now?',
    'What\'s the weather in Tokyo?',
    'Who won F1 race on 07.12.2025?',
    'Search for latest Flutter news',
    'What is LangChain?',
  ];

  static const String _codeExample =
      '''// 1. Define tools (functions the AI can call)
final calculatorTool = CalculatorTool();
final webSearchTool = TavilySearchTool();

// TavilySearchTool calls real web search API!
class TavilySearchTool extends StringTool {
  Future<String> invokeInternal(String query) async {
    final response = await http.post(
      Uri.parse('https://api.tavily.com/search'),
      body: {'query': query, 'api_key': apiKey},
    );
    return parseResults(response);
  }
}

// 2. Create Agent with tools
final agent = OpenAIToolsAgent.fromLLMAndTools(
  llm: model,
  tools: [calculatorTool, webSearchTool],
);

// 3. Run - AI decides which tool to use!
final result = await executor.invoke({
  'input': 'Search for latest AI news'
});''';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _runAgent() async {
    if (!LangChainService.instance.isConfigured) {
      final configured = await ApiKeyDialog.show(context);
      if (!configured) return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await LangChainService.instance.runAgentWithTools(
        _queryController.text,
      );
      setState(() {
        _result = result;
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
                    _buildFlowDiagram()
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.05),
                    const SizedBox(height: 24),
                    const CodeBlock(
                      code: _codeExample,
                      title: 'tools_agent.dart',
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
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
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: 0.05),
                    const SizedBox(height: 24),
                    _buildOutputCard()
                        .animate()
                        .fadeIn(delay: 500.ms)
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
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.build_circle, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'EXAMPLE 5',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF667eea),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tools & Agents',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'AI that can call functions and get real-time data',
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
                'Why Tools Matter',
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
            'Standard LLMs don\'t know what time it is, can\'t check your database, '
            'and can\'t fetch live data. They only know their training data.\n\n'
            'With Tools, you give the AI a list of functions it can call. '
            'The AI decides when to use them and interprets the results.',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildToolsList(),
        ],
      ),
    );
  }

  Widget _buildToolsList() {
    final tools = [
      ('🔢', 'calculator', 'Math calculations'),
      ('⏰', 'current_time', 'Current date/time'),
      ('🌤️', 'get_weather', 'Weather by city (mock)'),
      ('🔍', 'web_search', 'Real web search (Tavily)'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Tools',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...tools.map(
            (tool) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(tool.$1, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tool.$2,
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF667eea),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tool.$3,
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowDiagram() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea).withValues(alpha: 0.1),
            const Color(0xFF764ba2).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667eea).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree,
                color: const Color(0xFF667eea),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'How it works',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF667eea),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFlowStep(
            1,
            '👤 User',
            '"What\'s 253 × 12?"',
            AppTheme.textPrimary,
          ),
          _buildFlowArrow(),
          _buildFlowStep(
            2,
            '🤖 LLM',
            'I need to use calculator tool',
            AppTheme.secondaryAccent,
          ),
          _buildFlowArrow(),
          _buildFlowStep(
            3,
            '⚙️ Tool',
            'calculator("253 * 12") → 3036',
            AppTheme.tertiaryAccent,
          ),
          _buildFlowArrow(),
          _buildFlowStep(
            4,
            '🤖 LLM',
            '"253 times 12 equals 3036"',
            AppTheme.primaryAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep(int step, String actor, String action, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: GoogleFonts.jetBrainsMono(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          actor,
          style: GoogleFonts.jetBrainsMono(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              action,
              style: GoogleFonts.jetBrainsMono(color: color, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlowArrow() {
    return Padding(
      padding: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
      child: Icon(Icons.arrow_downward, color: AppTheme.textMuted, size: 16),
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
          color: const Color(0xFF667eea).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat, color: const Color(0xFF667eea), size: 22),
              const SizedBox(width: 10),
              Text(
                'Ask the Agent',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF667eea),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _queryController,
            maxLines: 2,
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: 'Ask something that requires a tool...',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Try these:',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sampleQueries.map((query) {
              return InkWell(
                onTap: () => setState(() => _queryController.text = query),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.surfaceColor),
                  ),
                  child: Text(
                    query,
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _runAgent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
              ),
              icon: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textPrimary,
                      ),
                    )
                  : Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: AppTheme.textPrimary,
                    ),
              label: Text(
                _isLoading ? 'Running Agent...' : 'Run Agent',
                style: TextStyle(color: AppTheme.textPrimary),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.tertiaryAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.terminal,
                      size: 14,
                      color: AppTheme.tertiaryAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Agent Execution',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.tertiaryAccent,
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
          else if (_result != null)
            _buildResultState()
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLoadingStep('Analyzing query...'),
        const SizedBox(height: 8),
        _buildLoadingStep('Selecting tools...'),
        const SizedBox(height: 8),
        _buildLoadingStep('Executing...'),
      ],
    );
  }

  Widget _buildLoadingStep(String text) {
    return Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: const Color(0xFF667eea),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: const Color(0xFF667eea).withValues(alpha: 0.1),
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
          Icon(Icons.error_outline, color: AppTheme.primaryAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              _error!,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.primaryAccent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tools section header
        Row(
          children: [
            Icon(Icons.build_circle, color: AppTheme.tertiaryAccent, size: 16),
            const SizedBox(width: 8),
            Text(
              'Tools Used',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.tertiaryAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _result!.intermediateSteps.isNotEmpty
                    ? AppTheme.tertiaryAccent.withValues(alpha: 0.2)
                    : AppTheme.textMuted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _result!.intermediateSteps.isNotEmpty
                    ? '${_result!.intermediateSteps.length}'
                    : '0',
                style: GoogleFonts.jetBrainsMono(
                  color: _result!.intermediateSteps.isNotEmpty
                      ? AppTheme.tertiaryAccent
                      : AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Show tool calls or "no tools" message
        if (_result!.intermediateSteps.isNotEmpty)
          ..._result!.intermediateSteps.map((step) => _buildToolCallCard(step))
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.surfaceColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.textMuted,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI answered directly without using any tools',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                // Debug info
                if (_result!.debugInfo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Debug: ${_result!.debugInfo}',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.warningAccent,
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Final answer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF667eea).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble,
                    color: const Color(0xFF667eea),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Final Answer',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF667eea),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                _result!.output,
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildToolCallCard(AgentStepInfo step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.tertiaryAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build, color: AppTheme.tertiaryAccent, size: 14),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.tertiaryAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  step.toolName,
                  style: GoogleFonts.jetBrainsMono(
                    color: AppTheme.tertiaryAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (step.toolInput.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Input: ${step.toolInput}',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Output: ${step.toolOutput}',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.warningAccent,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildEmptyState() {
    return Row(
      children: [
        Icon(Icons.lightbulb_outline, color: AppTheme.textMuted, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Ask a question and watch the agent decide which tools to use',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
