import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OutputCard extends StatelessWidget {
  final String? output;
  final bool isLoading;
  final String? error;
  final String emptyMessage;

  const OutputCard({
    super.key,
    this.output,
    this.isLoading = false,
    this.error,
    this.emptyMessage = 'Run the example to see the output here',
  });

  @override
  Widget build(BuildContext context) {
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
          color: error != null
              ? AppTheme.primaryAccent.withValues(alpha: 0.5)
              : AppTheme.surfaceColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      'Output',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.tertiaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading) ...[
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
          if (isLoading)
            _buildLoadingState()
          else if (error != null)
            _buildErrorState()
          else if (output != null && output!.isNotEmpty)
            _buildOutputState()
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
        _buildShimmerLine(width: 200),
        const SizedBox(height: 8),
        _buildShimmerLine(width: 300),
        const SizedBox(height: 8),
        _buildShimmerLine(width: 150),
      ],
    );
  }

  Widget _buildShimmerLine({required double width}) {
    return Container(
      width: width,
      height: 16,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppTheme.secondaryAccent.withValues(alpha: 0.1),
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
              error!,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.primaryAccent,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake(hz: 2, duration: 300.ms);
  }

  Widget _buildOutputState() {
    return SelectableText(
      output!,
      style: GoogleFonts.jetBrainsMono(
        color: AppTheme.textPrimary,
        fontSize: 14,
        height: 1.6,
      ),
    ).animate().fadeIn(duration: 300.ms);
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
        Text(
          emptyMessage,
          style: GoogleFonts.jetBrainsMono(
            color: AppTheme.textMuted,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

