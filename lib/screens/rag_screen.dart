import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../services/langchain_service.dart';
import '../widgets/code_block.dart';
import '../widgets/api_key_dialog.dart';

class RagScreen extends StatefulWidget {
  const RagScreen({super.key});

  @override
  State<RagScreen> createState() => _RagScreenState();
}

class _RagScreenState extends State<RagScreen> {
  final _questionController = TextEditingController(
    text: 'What is the vacation policy?',
  );
  String? _loadedFileName;
  String? _answer;
  String? _error;
  bool _isLoadingDoc = false;
  bool _isQuerying = false;

  static const String _codeExample = '''// 1. Load and split a document
final loader = TextLoader('assets/company_policy.txt');
final documents = await loader.load();

// 2. Create a vector store
final vectorStore = MemoryVectorStore(
  embeddings: OpenAIEmbeddings(apiKey: '...'),
);
await vectorStore.addDocuments(documents);

// 3. Create a retrieval chain
final chain = RetrievalQAChain.fromLlm(
  llm: ChatOpenAI(apiKey: '...'),
  retriever: vectorStore.asRetriever(),
);

// 4. Ask a question about the document
final answer = await chain.invoke('What is the vacation policy?');
print(answer['result']);''';

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadSampleDocument() async {
    if (!LangChainService.instance.isConfigured) {
      final configured = await ApiKeyDialog.show(context);
      if (!configured) return;
    }

    setState(() {
      _isLoadingDoc = true;
      _error = null;
    });

    try {
      final content = await rootBundle.loadString('assets/sample_document.txt');
      await LangChainService.instance.loadDocuments(content);
      setState(() {
        _loadedFileName = 'sample_document.txt (Employee Handbook)';
        _isLoadingDoc = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingDoc = false;
      });
    }
  }

  Future<void> _loadCustomDocument() async {
    if (!LangChainService.instance.isConfigured) {
      final configured = await ApiKeyDialog.show(context);
      if (!configured) return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isLoadingDoc = true;
      _error = null;
    });

    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      await LangChainService.instance.loadDocuments(content);
      setState(() {
        _loadedFileName = result.files.single.name;
        _isLoadingDoc = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingDoc = false;
      });
    }
  }

  Future<void> _askQuestion() async {
    if (!LangChainService.instance.isConfigured) {
      final configured = await ApiKeyDialog.show(context);
      if (!configured) return;
    }

    if (!LangChainService.instance.documentsLoaded) {
      setState(() => _error = 'Please load a document first');
      return;
    }

    setState(() {
      _isQuerying = true;
      _error = null;
      _answer = null;
    });

    try {
      final result = await LangChainService.instance.queryDocuments(
        _questionController.text,
      );
      setState(() {
        _answer = result;
        _isQuerying = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isQuerying = false;
      });
    }
  }

  void _clearDocuments() {
    LangChainService.instance.clearDocuments();
    setState(() {
      _loadedFileName = null;
      _answer = null;
      _error = null;
    });
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
                      title: 'rag_chain.dart',
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
                    _buildDocumentCard()
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: 0.05),
                    const SizedBox(height: 24),
                    _buildQueryCard()
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
            gradient: const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFf093fb).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.search,
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
                  color: const Color(0xFFf093fb).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'EXAMPLE 4',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFf093fb),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RAG',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Retrieval-Augmented Generation — Talk to your docs',
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
                'The "Killer Feature"',
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
            'You can\'t fit a whole manual into a prompt — there are token limits. '
            'RAG (Retrieval-Augmented Generation) solves this elegantly:\n\n'
            '1. Split your document into chunks\n'
            '2. Convert chunks to embeddings (vectors)\n'
            '3. When a question comes in, find relevant chunks\n'
            '4. Send only those chunks + the question to the AI',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildRagDiagram(),
        ],
      ),
    );
  }

  Widget _buildRagDiagram() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDiagramBox('📄 Document', AppTheme.textSecondary),
                const Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 16),
                _buildDiagramBox('✂️ Chunks', AppTheme.secondaryAccent),
                const Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 16),
                _buildDiagramBox('🔢 Vectors', AppTheme.tertiaryAccent),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(Icons.arrow_downward, color: AppTheme.textMuted, size: 20),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDiagramBox('❓ Question', AppTheme.warningAccent),
                const Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 16),
                _buildDiagramBox('🔍 Search', AppTheme.primaryAccent),
                const Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 16),
                _buildDiagramBox('💬 Answer', const Color(0xFFf093fb)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramBox(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDocumentCard() {
    final isLoaded = _loadedFileName != null;

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
          color: isLoaded
              ? AppTheme.tertiaryAccent.withValues(alpha: 0.5)
              : AppTheme.surfaceColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLoaded ? Icons.check_circle : Icons.upload_file,
                color: isLoaded ? AppTheme.tertiaryAccent : AppTheme.textMuted,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Step 1: Load Document',
                style: GoogleFonts.jetBrainsMono(
                  color: isLoaded ? AppTheme.tertiaryAccent : AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isLoaded)
                IconButton(
                  onPressed: _clearDocuments,
                  icon: const Icon(Icons.close, size: 18),
                  color: AppTheme.textMuted,
                  tooltip: 'Clear document',
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoaded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.tertiaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.tertiaryAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: AppTheme.tertiaryAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _loadedFileName!,
                      style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95))
          else ...[
            Text(
              'Load a document to start asking questions about it.',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingDoc ? null : _loadSampleDocument,
                    icon: _isLoadingDoc
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.secondaryAccent,
                            ),
                          )
                        : const Icon(Icons.article, size: 18),
                    label: const Text('Sample Doc'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingDoc ? null : _loadCustomDocument,
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: const Text('Choose File'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQueryCard() {
    final canQuery = _loadedFileName != null;

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
          color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.question_answer,
                color: canQuery ? AppTheme.secondaryAccent : AppTheme.textMuted,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Step 2: Ask Questions',
                style: GoogleFonts.jetBrainsMono(
                  color: canQuery ? AppTheme.secondaryAccent : AppTheme.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _questionController,
            enabled: canQuery,
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: canQuery
                  ? 'Ask a question about your document...'
                  : 'Load a document first',
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: canQuery ? AppTheme.textMuted : AppTheme.textMuted.withValues(alpha: 0.5),
              ),
            ),
            onSubmitted: (_) => _askQuestion(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canQuery && !_isQuerying ? _askQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf093fb),
              ),
              icon: _isQuerying
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textPrimary,
                      ),
                    )
                  : Icon(Icons.auto_awesome, size: 20, color: AppTheme.textPrimary),
              label: Text(
                _isQuerying ? 'Searching...' : 'Ask Question',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.primaryAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.primaryAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_answer != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFf093fb).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: const Color(0xFFf093fb),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Answer',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFf093fb),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _answer!,
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
          ],
        ],
      ),
    );
  }
}

