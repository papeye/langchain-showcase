import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/langchain_service.dart';
import 'api_key_dialog.dart';

class ProviderIndicator extends StatelessWidget {
  final VoidCallback onChanged;

  const ProviderIndicator({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final service = LangChainService.instance;
    final isConfigured = service.isConfigured;
    final provider = service.currentProvider;

    final color = provider == LLMProvider.openai
        ? AppTheme.tertiaryAccent
        : AppTheme.secondaryAccent;

    return GestureDetector(
      onTap: () async {
        final result = await ApiKeyDialog.show(context);
        if (result) onChanged();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isConfigured
                ? color.withValues(alpha: 0.15)
                : AppTheme.warningAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isConfigured
                  ? color.withValues(alpha: 0.3)
                  : AppTheme.warningAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                isConfigured
                    ? (provider == LLMProvider.openai
                        ? Icons.auto_awesome
                        : Icons.diamond_outlined)
                    : Icons.key_off,
                color: isConfigured ? color : AppTheme.warningAccent,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                isConfigured ? provider.displayName.split(' ').first : 'Set',
                style: GoogleFonts.jetBrainsMono(
                  color: isConfigured ? color : AppTheme.warningAccent,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (isConfigured) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '✓',
                    style: GoogleFonts.jetBrainsMono(
                      color: color,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

