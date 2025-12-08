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
    if (!apiKey.startsWith('sk-')) {
      setState(() => _error = 'Invalid API key format');
      return;
    }

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
        width: 450,
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
                      'OpenAI API Key',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Required to run the examples',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter your OpenAI API key to enable the LangChain demos. Your key is stored locally and never shared.',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              obscureText: _obscureText,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'sk-...',
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _saveApiKey,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save Key'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

