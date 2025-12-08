import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CodeBlock extends StatefulWidget {
  final String code;
  final String language;
  final String? title;

  const CodeBlock({
    super.key,
    required this.code,
    this.language = 'dart',
    this.title,
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.surfaceColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                // Colored dots (macOS style)
                Row(
                  children: [
                    _buildDot(const Color(0xFFFF5F56)),
                    const SizedBox(width: 8),
                    _buildDot(const Color(0xFFFFBD2E)),
                    const SizedBox(width: 8),
                    _buildDot(const Color(0xFF27C93F)),
                  ],
                ),
                const SizedBox(width: 16),
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                ],
                if (widget.title == null) const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.language,
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.secondaryAccent,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _copyToClipboard,
                  icon: Icon(
                    _copied ? Icons.check : Icons.copy,
                    size: 16,
                    color: _copied ? AppTheme.tertiaryAccent : AppTheme.textMuted,
                  ),
                  tooltip: _copied ? 'Copied!' : 'Copy code',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              widget.code,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textPrimary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

