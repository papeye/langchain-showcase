import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/langchain_service.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ApiKeyDialog(),
    );
    return result ?? false;
  }

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final _controller = TextEditingController();
  bool _obscureText = true;
  String? _error;
  late LLMProvider _selectedProvider;

  @override
  void initState() {
    super.initState();
    _selectedProvider = LangChainService.instance.currentProvider;
    if (LangChainService.instance.apiKey != null) {
      _controller.text = LangChainService.instance.apiKey!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    final apiKey = _controller.text.trim();
    if (apiKey.isEmpty) {
      setState(() => _error = 'Please enter your API key');
      return;
    }

    // Validate key format based on provider
    if (_selectedProvider == LLMProvider.openai && !apiKey.startsWith('sk-')) {
      setState(() => _error = 'OpenAI API keys should start with "sk-"');
      return;
    }

    LangChainService.instance.setProvider(_selectedProvider);
    LangChainService.instance.setApiKey(apiKey);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.surfaceColor),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.key,
                    color: AppTheme.secondaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configure LLM Provider',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Switch providers with just one line of code!',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Provider selection
            Text(
              'Select Provider',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: LLMProvider.values.map((provider) {
                final isSelected = _selectedProvider == provider;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: provider != LLMProvider.values.last ? 12 : 0,
                    ),
                    child: _buildProviderOption(provider, isSelected),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Code preview showing how easy the switch is
            _buildCodePreview(),

            const SizedBox(height: 24),

            // API Key input
            Text(
              '${_selectedProvider.displayName} API Key',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              obscureText: _obscureText,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: _selectedProvider == LLMProvider.openai
                    ? 'sk-...'
                    : 'AIza...',
                prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                errorText: _error,
              ),
              onSubmitted: (_) => _saveApiKey(),
            ),

            const SizedBox(height: 8),
            Text(
              _selectedProvider == LLMProvider.openai
                  ? 'Get your key at platform.openai.com'
                  : 'Get your key at aistudio.google.com',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.jetBrainsMono(color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _saveApiKey,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save & Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderOption(LLMProvider provider, bool isSelected) {
    final color = provider == LLMProvider.openai
        ? AppTheme.tertiaryAccent
        : AppTheme.secondaryAccent;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProvider = provider;
          _error = null;
          _controller.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppTheme.surfaceColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : AppTheme.surfaceColor.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              provider == LLMProvider.openai
                  ? Icons.auto_awesome
                  : Icons.diamond_outlined,
              color: isSelected ? color : AppTheme.textMuted,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              provider.displayName,
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? color : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.defaultModel,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodePreview() {
    final code = _selectedProvider == LLMProvider.openai
        ? '''final model = ChatOpenAI(
  apiKey: apiKey,
  defaultOptions: ChatOpenAIOptions(
    model: 'gpt-4o-mini',
  ),
);'''
        : '''final model = ChatGoogleGenerativeAI(
  apiKey: apiKey,
  defaultOptions: ChatGoogleGenerativeAIOptions(
    model: 'gemini-flash-latest',
  ),
);''';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, size: 14, color: AppTheme.warningAccent),
              const SizedBox(width: 8),
              Text(
                'That\'s all the code that changes!',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppTheme.warningAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            code,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
