import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/basic_chain_screen.dart';
import 'screens/memory_screen.dart';
import 'screens/structured_output_screen.dart';
import 'screens/rag_screen.dart';
import 'widgets/api_key_dialog.dart';
import 'services/langchain_service.dart';

void main() {
  runApp(const LangChainShowcaseApp());
}

class LangChainShowcaseApp extends StatelessWidget {
  const LangChainShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LangChain Showcase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.link,
      label: 'Basic Chain',
      color: AppTheme.primaryAccent,
    ),
    _NavItem(
      icon: Icons.psychology,
      label: 'Memory',
      color: AppTheme.secondaryAccent,
    ),
    _NavItem(
      icon: Icons.data_object,
      label: 'Structured',
      color: AppTheme.tertiaryAccent,
    ),
    _NavItem(
      icon: Icons.search,
      label: 'RAG',
      color: const Color(0xFFf093fb),
    ),
  ];

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return const BasicChainScreen();
      case 1:
        return const MemoryScreen();
      case 2:
        return const StructuredOutputScreen();
      case 3:
        return const RagScreen();
      default:
        return const BasicChainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: Row(
          children: [
            // Custom Navigation Rail
            _buildNavigationRail(),
            
            // Main content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _getScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        border: Border(
          right: BorderSide(
            color: AppTheme.surfaceColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo/Title
          _buildLogo(),
          const SizedBox(height: 32),
          // API Key indicator
          _buildApiKeyIndicator(),
          const SizedBox(height: 24),
          Divider(
            color: AppTheme.surfaceColor.withValues(alpha: 0.5),
            indent: 16,
            endIndent: 16,
          ),
          const SizedBox(height: 16),
          // Navigation items
          Expanded(
            child: Column(
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildNavItem(index, item);
              }).toList(),
            ),
          ),
          // Version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v0.8.0',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textMuted,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 24,
      ),
    ).animate().scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildApiKeyIndicator() {
    final isConfigured = LangChainService.instance.isConfigured;
    
    return GestureDetector(
      onTap: () async {
        final result = await ApiKeyDialog.show(context);
        if (result) setState(() {});
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isConfigured
                ? AppTheme.tertiaryAccent.withValues(alpha: 0.15)
                : AppTheme.warningAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isConfigured
                  ? AppTheme.tertiaryAccent.withValues(alpha: 0.3)
                  : AppTheme.warningAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                isConfigured ? Icons.key : Icons.key_off,
                color: isConfigured
                    ? AppTheme.tertiaryAccent
                    : AppTheme.warningAccent,
                size: 18,
              ),
              const SizedBox(height: 4),
              Text(
                isConfigured ? 'Ready' : 'Set Key',
                style: GoogleFonts.jetBrainsMono(
                  color: isConfigured
                      ? AppTheme.tertiaryAccent
                      : AppTheme.warningAccent,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItem item) {
    final isSelected = _selectedIndex == index;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? item.color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? item.color.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                item.icon,
                color: isSelected ? item.color : AppTheme.textMuted,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                style: GoogleFonts.jetBrainsMono(
                  color: isSelected ? item.color : AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: -0.2);
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;

  _NavItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
