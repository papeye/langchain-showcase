import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // Example 5: Tools & Agents
  Future<AgentResult> runAgentWithTools(String query) async {
    // Define tools using StringTool for simplicity
    final calculatorTool = CalculatorTool();
    final currentTimeTool = CurrentTimeTool();
    final weatherTool = WeatherTool();
    final webSearchTool = TavilySearchTool();

    final tools = <Tool>[
      calculatorTool,
      currentTimeTool,
      weatherTool,
      webSearchTool,
    ];

    // Create agent based on provider
    if (_provider == LLMProvider.openai) {
      final llm = ChatOpenAI(
        apiKey: _apiKey!,
        defaultOptions: const ChatOpenAIOptions(
          model: 'gpt-4o-mini',
          temperature: 0,
        ),
      );

      final agent = OpenAIToolsAgent.fromLLMAndTools(llm: llm, tools: tools);
      final executor = AgentExecutor(
        agent: agent,
        returnIntermediateSteps: true,
      );

      final result = await executor.invoke({'input': query});
      final steps = _extractIntermediateSteps(result);

      // Debug: show step type if extraction failed
      String? debugInfo;
      if (steps.isEmpty) {
        final intermediate = result['intermediate_steps'];
        if (intermediate is List && intermediate.isNotEmpty) {
          debugInfo = 'Step type: ${intermediate.first.runtimeType}';
        }
      }

      return AgentResult(
        output: result['output'] as String,
        intermediateSteps: steps,
        debugInfo: debugInfo,
      );
    } else {
      // For Gemini, use a simpler ReAct-style approach
      final llm = ChatGoogleGenerativeAI(
        apiKey: _apiKey!,
        defaultOptions: const ChatGoogleGenerativeAIOptions(
          model: 'gemini-flash-latest',
          temperature: 0,
        ),
      );

      // Use tool calling agent for Gemini
      final agent = ToolsAgent.fromLLMAndTools(llm: llm, tools: tools);
      final executor = AgentExecutor(
        agent: agent,
        returnIntermediateSteps: true,
      );

      final result = await executor.invoke({'input': query});
      final steps = _extractIntermediateSteps(result);

      // Debug: show step type if extraction failed
      String? debugInfo;
      if (steps.isEmpty) {
        final intermediate = result['intermediate_steps'];
        if (intermediate is List && intermediate.isNotEmpty) {
          debugInfo = 'Step type: ${intermediate.first.runtimeType}';
        }
      }

      return AgentResult(
        output: result['output'] as String,
        intermediateSteps: steps,
        debugInfo: debugInfo,
      );
    }
  }

  List<AgentStepInfo> _extractIntermediateSteps(Map<String, dynamic> result) {
    final steps = <AgentStepInfo>[];

    // The key is snake_case: intermediate_steps
    final intermediate = result['intermediate_steps'];

    if (intermediate is List) {
      for (final step in intermediate) {
        // The step is LangChain's AgentStep which has 'action' and 'observation'
        if (step is AgentStep) {
          final action = step.action;
          steps.add(
            AgentStepInfo(
              toolName: action.tool,
              toolInput: _formatToolInput(action.toolInput),
              toolOutput: step.observation,
            ),
          );
        }
      }
    }

    return steps;
  }

  String _formatToolInput(dynamic input) {
    if (input is Map) {
      // Extract the 'input' key if it exists, otherwise stringify
      if (input.containsKey('input')) {
        return input['input'].toString();
      }
      return input.values.first?.toString() ?? input.toString();
    }
    return input.toString();
  }
}

class AgentResult {
  final String output;
  final List<AgentStepInfo> intermediateSteps;
  final String? debugInfo;

  AgentResult({
    required this.output,
    required this.intermediateSteps,
    this.debugInfo,
  });
}

// Renamed to avoid conflict with LangChain's AgentStep
class AgentStepInfo {
  final String toolName;
  final String toolInput;
  final String toolOutput;

  AgentStepInfo({
    required this.toolName,
    required this.toolInput,
    required this.toolOutput,
  });
}

// Custom Tools
final class CalculatorTool extends StringTool {
  CalculatorTool()
    : super(
        name: 'calculator',
        description:
            'Useful for performing math calculations. Input should be a mathematical expression like "25 * 4" or "100 / 5".',
      );

  @override
  Future<String> invokeInternal(
    String toolInput, {
    ToolOptions? options,
  }) async {
    try {
      final sanitized = toolInput.replaceAll(' ', '');

      if (sanitized.contains('*')) {
        final parts = sanitized.split('*');
        final result = double.parse(parts[0]) * double.parse(parts[1]);
        return result.toStringAsFixed(
          result.truncateToDouble() == result ? 0 : 2,
        );
      } else if (sanitized.contains('/')) {
        final parts = sanitized.split('/');
        final result = double.parse(parts[0]) / double.parse(parts[1]);
        return result.toStringAsFixed(
          result.truncateToDouble() == result ? 0 : 2,
        );
      } else if (sanitized.contains('+')) {
        final parts = sanitized.split('+');
        final result = double.parse(parts[0]) + double.parse(parts[1]);
        return result.toStringAsFixed(
          result.truncateToDouble() == result ? 0 : 2,
        );
      } else if (sanitized.contains('-')) {
        final parts = sanitized.split('-');
        final result = double.parse(parts[0]) - double.parse(parts[1]);
        return result.toStringAsFixed(
          result.truncateToDouble() == result ? 0 : 2,
        );
      }

      return 'Could not parse expression: $toolInput';
    } catch (e) {
      return 'Error calculating: $e';
    }
  }
}

final class CurrentTimeTool extends StringTool {
  CurrentTimeTool()
    : super(
        name: 'current_time',
        description:
            'Returns the current date and time. Use this when the user asks what time it is or the current date.',
      );

  @override
  Future<String> invokeInternal(
    String toolInput, {
    ToolOptions? options,
  }) async {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }
}

final class WeatherTool extends StringTool {
  WeatherTool()
    : super(
        name: 'get_weather',
        description:
            'Gets the current weather for a city. Input should be a city name.',
      );

  @override
  Future<String> invokeInternal(
    String toolInput, {
    ToolOptions? options,
  }) async {
    final weathers = {
      'london': '☁️ Cloudy, 12°C',
      'paris': '🌤️ Partly sunny, 15°C',
      'tokyo': '☀️ Sunny, 22°C',
      'new york': '🌧️ Rainy, 8°C',
      'sydney': '☀️ Clear skies, 28°C',
      'san francisco': '🌫️ Foggy, 14°C',
      'warsaw': '❄️ Cold and cloudy, 2°C',
      'berlin': '🌥️ Overcast, 7°C',
    };

    final lowerCity = toolInput.toLowerCase().trim();
    return weathers[lowerCity] ?? '☀️ Pleasant weather, 20°C';
  }
}

final class TavilySearchTool extends StringTool {
  static const String _apiKey = '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';

  TavilySearchTool()
    : super(
        name: 'web_search',
        description:
            'Searches the web for current information. Use this when you need to find up-to-date information about any topic, news, facts, or when you don\'t know something. Input should be a search query.',
      );

  @override
  Future<String> invokeInternal(
    String toolInput, {
    ToolOptions? options,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.tavily.com/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_key': _apiKey,
          'query': toolInput,
          'search_depth': 'basic',
          'include_answer': true,
          'include_raw_content': false,
          'max_results': 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // If Tavily provides a direct answer, use it
        if (data['answer'] != null && (data['answer'] as String).isNotEmpty) {
          return data['answer'] as String;
        }

        // Otherwise, compile results from search
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final buffer = StringBuffer();
          buffer.writeln('Search results for "$toolInput":');
          buffer.writeln();

          for (int i = 0; i < results.length && i < 3; i++) {
            final result = results[i] as Map<String, dynamic>;
            final title = result['title'] ?? 'No title';
            final content = result['content'] ?? 'No content';
            buffer.writeln('${i + 1}. $title');
            buffer.writeln('   $content');
            buffer.writeln();
          }

          return buffer.toString();
        }

        return 'No results found for: $toolInput';
      } else {
        return 'Search failed with status ${response.statusCode}';
      }
    } catch (e) {
      return 'Error searching: $e';
    }
  }
}
