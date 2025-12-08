import 'dart:convert';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_google/langchain_google.dart';

enum LLMProvider {
  openai('OpenAI', 'gpt-4o-mini', 'sk-'),
  gemini('Google Gemini', 'gemini-1.5-flash', 'AI');

  final String displayName;
  final String defaultModel;
  final String keyPrefix;

  const LLMProvider(this.displayName, this.defaultModel, this.keyPrefix);
}

class LangChainService {
  static LangChainService? _instance;
  String? _apiKey;
  LLMProvider _provider = LLMProvider.openai;
  BaseChatModel? _model;

  LangChainService._();

  static LangChainService get instance {
    _instance ??= LangChainService._();
    return _instance!;
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;
  LLMProvider get currentProvider => _provider;
  String? get apiKey => _apiKey;

  void setProvider(LLMProvider provider) {
    if (_provider != provider) {
      _provider = provider;
      _apiKey = null;
      _model = null;
      _memory = null;
      _conversationChain = null;
      _vectorStore = null;
      _documentsLoaded = false;
    }
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
    _initializeModel();
  }

  void _initializeModel() {
    switch (_provider) {
      case LLMProvider.openai:
        _model = ChatOpenAI(
          apiKey: _apiKey!,
          defaultOptions: const ChatOpenAIOptions(
            model: 'gpt-4o-mini',
            temperature: 0.7,
          ),
        );
        break;
      case LLMProvider.gemini:
        _model = ChatGoogleGenerativeAI(
          apiKey: _apiKey!,
          defaultOptions: const ChatGoogleGenerativeAIOptions(
            model: 'gemini-flash-latest',
            temperature: 0.7,
          ),
        );
        break;
    }
  }

  BaseChatModel get model {
    if (_model == null) {
      throw Exception(
        'API key not configured. Please set your ${_provider.displayName} API key first.',
      );
    }
    return _model!;
  }

  // Example 1: Basic Chain
  Future<String> runBasicChain({
    required String adjective,
    required String topic,
  }) async {
    final prompt = PromptTemplate.fromTemplate(
      'Tell me a {adjective} joke about {topic}.',
    );

    final chain = prompt.pipe(model).pipe(const StringOutputParser());

    final result = await chain.invoke({'adjective': adjective, 'topic': topic});

    return result;
  }

  // Example 2: Conversation with Memory
  ConversationBufferMemory? _memory;
  ConversationChain? _conversationChain;

  void resetConversation() {
    _memory = ConversationBufferMemory(returnMessages: true);
    _conversationChain = ConversationChain(llm: model, memory: _memory!);
  }

  Future<String> chat(String message) async {
    if (_conversationChain == null) {
      resetConversation();
    }

    final response = await _conversationChain!.run(message);
    return response;
  }

  Future<List<ChatMessage>> getConversationHistory() async {
    if (_memory == null) return [];
    return await _memory!.chatHistory.getChatMessages();
  }

  // Example 3: Structured Output
  Future<Map<String, dynamic>> extractStructuredData(String text) async {
    final prompt = PromptTemplate.fromTemplate('''
Extract structured information from the following text and return it as valid JSON.
The JSON should have these fields:
- "summary": a brief summary of the main topic (string)
- "participants": list of people mentioned (array of strings)
- "datetime": any date/time mentioned (string or null)
- "action_items": any tasks or action items (array of strings)
- "location": any location mentioned (string or null)

Text: {text}

Return ONLY valid JSON, no other text.
''');

    final chain = prompt.pipe(model).pipe(const StringOutputParser());

    final result = await chain.invoke({'text': text});

    // Parse the JSON from the response
    try {
      // Clean up the response - remove markdown code blocks if present
      String cleanedResult = result.trim();
      if (cleanedResult.startsWith('```json')) {
        cleanedResult = cleanedResult.substring(7);
      } else if (cleanedResult.startsWith('```')) {
        cleanedResult = cleanedResult.substring(3);
      }
      if (cleanedResult.endsWith('```')) {
        cleanedResult = cleanedResult.substring(0, cleanedResult.length - 3);
      }
      cleanedResult = cleanedResult.trim();

      // Parse JSON
      final RegExp jsonRegex = RegExp(r'\{[\s\S]*\}');
      final match = jsonRegex.firstMatch(cleanedResult);
      if (match != null) {
        final jsonStr = match.group(0)!;
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
      return {'raw': result, 'error': 'Could not parse JSON'};
    } catch (e) {
      return {'raw': result, 'error': e.toString()};
    }
  }

  // Example 4: RAG (Retrieval-Augmented Generation)
  MemoryVectorStore? _vectorStore;
  bool _documentsLoaded = false;

  bool get documentsLoaded => _documentsLoaded;

  Future<void> loadDocuments(String content) async {
    // Split the document into chunks
    final splitter = RecursiveCharacterTextSplitter(
      chunkSize: 500,
      chunkOverlap: 50,
    );

    final docs = [Document(pageContent: content)];
    final chunks = splitter.splitDocuments(docs);

    // Create embeddings and vector store
    // Note: For Gemini, we still use OpenAI embeddings as they're more widely supported
    // In a production app, you might want to use Google's embedding API
    Embeddings embeddings;
    if (_provider == LLMProvider.openai) {
      embeddings = OpenAIEmbeddings(apiKey: _apiKey!);
    } else {
      // Gemini uses Google's embedding model
      embeddings = GoogleGenerativeAIEmbeddings(apiKey: _apiKey!);
    }

    _vectorStore = MemoryVectorStore(embeddings: embeddings);
    await _vectorStore!.addDocuments(documents: chunks);

    _documentsLoaded = true;
  }

  Future<String> queryDocuments(String question) async {
    if (_vectorStore == null || !_documentsLoaded) {
      throw Exception('No documents loaded. Please load a document first.');
    }

    // Retrieve relevant chunks
    final retriever = _vectorStore!.asRetriever(
      defaultOptions: VectorStoreRetrieverOptions(
        searchType: VectorStoreSearchType.similarity(k: 3),
      ),
    );

    final relevantDocs = await retriever.invoke(question);
    final context = relevantDocs.map((d) => d.pageContent).join('\n\n');

    // Create a QA prompt
    final prompt = PromptTemplate.fromTemplate('''
Use the following context to answer the question. If you cannot find the answer in the context, say "I couldn't find that information in the document."

Context:
{context}

Question: {question}

Answer:
''');

    final chain = prompt.pipe(model).pipe(const StringOutputParser());

    return await chain.invoke({'context': context, 'question': question});
  }

  void clearDocuments() {
    _vectorStore = null;
    _documentsLoaded = false;
  }
}
