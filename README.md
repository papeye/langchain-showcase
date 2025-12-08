# LangChain Showcase

A beautiful macOS app demonstrating 4 key LangChain capabilities for Dart/Flutter developers.

![LangChain Showcase](https://img.shields.io/badge/Flutter-3.10+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![LangChain](https://img.shields.io/badge/LangChain-0.8.0-green)

## 🎯 Overview

This app is designed for tech talks and demonstrations, showing how LangChain solves common problems developers face when working with LLMs:

1. **Basic Chain** - The "Hello World" of LangChain
2. **Memory** - A chatbot that remembers your conversation
3. **Structured Output** - Get usable JSON data instead of free text
4. **RAG** - Talk to your documents (Retrieval-Augmented Generation)
5. **Tools & Agents** - AI that can call functions and get real-time data

## 🔄 Multi-Provider Support

One of LangChain's superpowers is **provider abstraction**. Switch between OpenAI and Google Gemini with just one line of code change!

```dart
// OpenAI
final model = ChatOpenAI(
  apiKey: apiKey,
  defaultOptions: ChatOpenAIOptions(model: 'gpt-4o-mini'),
);

// Google Gemini - same interface, different provider!
final model = ChatGoogleGenerativeAI(
  apiKey: apiKey,
  defaultOptions: ChatGoogleGenerativeAIOptions(model: 'gemini-1.5-flash'),
);
```

Both models implement `BaseChatModel`, so all your chains work with either!

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10+
- macOS (this demo is optimized for macOS)
- OpenAI API key

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd langchain_showcase

# Get dependencies
flutter pub get

# Run on macOS
flutter run -d macos
```

### Configuration

1. Launch the app
2. Click the "Set Key" button in the sidebar
3. Enter your OpenAI API key (starts with `sk-`)
4. Start exploring the examples!

## 📚 Examples

### Example 1: Basic Chain

**Concept:** PromptTemplate + LLM = Chain

Instead of manually string-mashing user input into a prompt, we use a template. We "pipe" the template into the model, making code clean, readable, and type-safe.

```dart
final prompt = PromptTemplate.fromTemplate(
  'Tell me a {adjective} joke about {topic}.'
);
final chain = prompt.pipe(model).pipe(StringOutputParser());
final result = await chain.invoke({
  'adjective': 'sarcastic',
  'topic': 'programmers',
});
```

### Example 2: Memory

**Concept:** Solving the "Stateless" problem

Most LLM APIs are stateless — they forget you immediately. LangChain adds `ConversationBufferMemory` that automatically tracks inputs and outputs.

```dart
final memory = ConversationBufferMemory(returnMessages: true);
final chain = ConversationChain(llm: model, memory: memory);

await chain.run('Hi, my name is Alex.');
await chain.run('What is my name?'); // "Your name is Alex."
```

### Example 3: Structured Output

**Concept:** Apps need Dart Objects (JSON), not free text

Developers hate parsing AI text with Regex. LangChain lets you define a schema and forces the AI to return clean JSON.

```dart
final result = await chain.invoke({
  'text': 'Meeting with Sarah at 2 PM on Friday...',
});
// Result: {"participants": ["Sarah"], "time": "14:00", ...}
```

### Example 4: RAG (Retrieval-Augmented Generation)

**Concept:** The "Killer Feature" — feeding documents to the AI

You can't fit a whole manual into a prompt. RAG splits documents into chunks, finds relevant pieces, and sends only those to the AI.

```dart
final vectorStore = MemoryVectorStore(embeddings: OpenAIEmbeddings());
await vectorStore.addDocuments(documents);

final chain = RetrievalQAChain.fromLlm(
  llm: model,
  retriever: vectorStore.asRetriever(),
);
final answer = await chain.invoke('What is the vacation policy?');
```

### Example 5: Tools & Agents

**Concept:** AI that can call functions to get real-time data

Standard LLMs don't know what time it is or current weather. Tools let the AI call your functions when it needs data it doesn't have.

```dart
// Define tools
final calculatorTool = CalculatorTool();
final weatherTool = WeatherTool();

// Create agent with tools
final agent = OpenAIToolsAgent.fromLLMAndTools(
  llm: model,
  tools: [calculatorTool, weatherTool],
);

final executor = AgentExecutor(agent: agent);
final result = await executor.invoke({
  'input': 'What is 253 * 12?'
});
// AI decides to call calculator → "253 times 12 equals 3036"
```

**How it works:**
1. 👤 User: "What's 253 × 12?"
2. 🤖 LLM: "I need to use calculator tool"
3. ⚙️ Tool: calculator("253 * 12") → 3036
4. 🤖 LLM: "253 times 12 equals 3036"

## 🎨 Features

- **Modern Dark Theme** - Monokai-inspired color scheme
- **Interactive Demos** - Try each example with your own inputs
- **Code Snippets** - Copy-paste ready code examples
- **Visual Diagrams** - Understand the flow of each concept
- **Real-time Output** - See AI responses as they come

## 📦 Dependencies

```yaml
dependencies:
  langchain: ^0.8.0
  langchain_openai: ^0.8.0
  langchain_google: ^0.7.0  # Gemini support!
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.2
  flutter_markdown: ^0.7.7
  file_picker: ^8.1.7
```

## 🤝 Contributing

Feel free to open issues or submit PRs to improve the showcase!

## 📄 License

MIT License - feel free to use this for your own tech talks and presentations.

---

Built with ❤️ using Flutter and LangChain
