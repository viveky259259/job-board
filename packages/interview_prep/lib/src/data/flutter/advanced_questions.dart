import 'package:interview_prep/src/models/difficulty.dart';
import 'package:interview_prep/src/models/question.dart';

List<InterviewQuestion> advancedQuestions() => const [
  // --- Internals ---
  InterviewQuestion(
    id: 'a_internal_1',
    topic: 'internals',
    subtopic: 'Widget-Element-RenderObject',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'Explain the three trees in Flutter: Widget tree, Element tree, and RenderObject tree.',
    answer: 'Widgets are immutable configuration blueprints (recreated on each build). Elements are the instantiation of widgets that manage the tree lifecycle and hold references to both the widget and render object. RenderObjects handle layout, painting, and hit testing.',
    explanation: 'Widget: lightweight, immutable description of what to show\nElement: mutable, manages the lifecycle, bridges widget ↔ render object\nRenderObject: handles layout constraints, painting to canvas, and hit testing\n\nWhen setState is called, widgets are recreated but elements and render objects are reused when possible — this is why Flutter is fast.',
  ),
  InterviewQuestion(
    id: 'a_internal_2',
    topic: 'internals',
    subtopic: 'Rendering Pipeline',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'Describe Flutter\'s rendering pipeline from widget to pixels.',
    answer: 'Build phase (widgets create elements/render objects) → Layout phase (constraints down, sizes up) → Paint phase (render objects paint to layers) → Compositing phase (layers assembled into a scene) → Rasterization (scene sent to GPU via Skia/Impeller).',
    explanation: 'The SchedulerBinding schedules frames. Each frame:\n1. Build: dirty elements rebuild, updating render objects\n2. Layout: RenderObject.performLayout() with parent constraints\n3. Paint: RenderObject.paint() draws to Layer canvases\n4. Composite: Layers composed into a Scene\n5. Rasterize: Engine sends Scene to Skia/Impeller for GPU rendering',
  ),
  InterviewQuestion(
    id: 'a_internal_3',
    topic: 'internals',
    subtopic: 'Bindings',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'What are Bindings in Flutter? Name the main ones.',
    answer: 'Bindings are singletons that connect the Flutter framework to the engine. Main bindings: WidgetsBinding (widget tree), SchedulerBinding (frame scheduling), RendererBinding (render tree), GestureBinding (hit testing), ServicesBinding (platform channels), PaintingBinding (image cache).',
    explanation: 'WidgetsFlutterBinding.ensureInitialized() initializes all bindings. In tests, you use TestWidgetsFlutterBinding. Custom bindings can override behavior — useful for testing and performance monitoring.',
  ),

  // --- Performance ---
  InterviewQuestion(
    id: 'a_perf_1',
    topic: 'performance',
    subtopic: 'Optimization',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'What strategies do you use to prevent unnecessary widget rebuilds?',
    answer: 'Use const constructors, extract widgets into separate classes, use RepaintBoundary, select specific data with context.select(), avoid building expensive widgets in build(), use ValueListenableBuilder for targeted rebuilds, and mark widgets as const where possible.',
    explanation: 'const MyWidget() — never rebuilds if nothing changes\nExtracted widget class — only rebuilds if its own state/props change\nRepaintBoundary — isolates repainting to subtree\ncontext.select<T, R>() — only rebuild when selected value changes\nAvoid: anonymous widgets in build(), rebuilding lists without keys',
  ),
  InterviewQuestion(
    id: 'a_perf_2',
    topic: 'performance',
    subtopic: 'Isolates',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'What are Isolates in Dart? When and how should you use them?',
    answer: 'Isolates are independent execution contexts with their own memory heap — Dart\'s approach to parallelism. Use them for CPU-intensive work (image processing, JSON parsing of large data, crypto) to avoid blocking the main UI thread.',
    explanation: 'Isolates don\'t share memory — they communicate via message passing (SendPort/ReceivePort).\nSimple: await compute(expensiveFunction, data)\nAdvanced: Isolate.spawn() for long-lived workers\nUse when: >16ms of computation would cause jank (dropped frames)',
  ),
  InterviewQuestion(
    id: 'a_perf_3',
    topic: 'performance',
    subtopic: 'Profiling',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'How do you profile and debug performance issues in Flutter?',
    answer: 'Use Flutter DevTools: Performance view for frame rendering, CPU profiler for hot functions, Memory view for leaks, Widget Inspector for rebuild counts. Run in profile mode (flutter run --profile). Look for jank in the frame chart (>16ms frames).',
    explanation: 'Steps:\n1. flutter run --profile (not debug — debug has overhead)\n2. Open DevTools Performance tab\n3. Look for red frames (jank)\n4. Check if build, layout, or paint phase is slow\n5. Use Widget Inspector to find excessive rebuilds\n6. Memory tab to check for leaks (retained objects growing)',
  ),
  InterviewQuestion(
    id: 'a_perf_4',
    topic: 'performance',
    subtopic: 'Rendering',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'What is Impeller and how does it differ from Skia?',
    answer: 'Impeller is Flutter\'s new rendering engine replacing Skia. It pre-compiles shaders at build time (no runtime shader compilation), eliminating first-frame jank. It uses Metal on iOS and Vulkan on Android for better GPU utilization.',
    explanation: 'Skia compiled shaders on-demand, causing "shader jank" on first use of effects. Impeller pre-compiles all shaders during build, guaranteeing predictable frame times. It also has a simpler rendering model optimized specifically for Flutter\'s use case.',
  ),

  // --- Platform Integration ---
  InterviewQuestion(
    id: 'a_platform_1',
    topic: 'platform_integration',
    subtopic: 'MethodChannel',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'Explain MethodChannel, EventChannel, and BasicMessageChannel.',
    answer: 'MethodChannel: request-response for calling platform-specific methods (like getting battery level). EventChannel: stream of events from platform to Flutter (like sensor data). BasicMessageChannel: simple bidirectional message passing with custom codecs.',
    explanation: 'MethodChannel: Flutter calls native, gets single response\nconst channel = MethodChannel("com.app/battery");\nfinal level = await channel.invokeMethod("getBatteryLevel");\n\nEventChannel: native streams data to Flutter\nEventChannel("com.app/sensors").receiveBroadcastStream().listen(...)\n\nBasicMessageChannel: custom codecs for specialized data formats',
  ),
  InterviewQuestion(
    id: 'a_platform_2',
    topic: 'platform_integration',
    subtopic: 'Plugins',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'What is the federated plugin architecture in Flutter?',
    answer: 'Federated plugins split a plugin into three packages: app-facing (API), platform interface (abstract contract), and platform implementations (iOS, Android, web, etc.). This allows independent development and contribution per platform.',
    explanation: 'url_launcher (app-facing) → url_launcher_platform_interface (contract) → url_launcher_ios, url_launcher_android, url_launcher_web (implementations)\nThis lets someone add Linux support without touching iOS code.',
  ),

  // --- Architecture ---
  InterviewQuestion(
    id: 'a_arch_1',
    topic: 'architecture',
    subtopic: 'Clean Architecture',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'How would you implement Clean Architecture in a Flutter app?',
    answer: 'Three layers: Presentation (widgets, state management), Domain (entities, use cases, repository interfaces — no dependencies), Data (repository implementations, data sources, DTOs). Dependencies point inward — Domain depends on nothing, Data implements Domain interfaces.',
    explanation: 'Domain layer:\n  - entities/ (pure Dart models)\n  - usecases/ (single-responsibility business logic)\n  - repositories/ (abstract interfaces)\n\nData layer:\n  - repositories/ (implements domain interfaces)\n  - datasources/ (API, local DB)\n  - models/ (DTOs with fromJson/toJson)\n\nPresentation layer:\n  - screens/, widgets/, state management',
  ),
  InterviewQuestion(
    id: 'a_arch_2',
    topic: 'architecture',
    subtopic: 'DI',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'How do you implement Dependency Injection in Flutter?',
    answer: 'Options: 1) Constructor injection (simplest). 2) Riverpod providers (recommended — compile-safe, override in tests). 3) get_it (service locator pattern). 4) InheritedWidget. Each has trade-offs in testability, boilerplate, and discoverability.',
    explanation: 'Riverpod:\nfinal authRepoProvider = Provider<AuthRepo>((ref) => FirebaseAuthRepo());\n// In tests:\nProviderScope(overrides: [authRepoProvider.overrideWith((_) => MockAuthRepo())])\n\nConstructor injection:\nclass LoginScreen { final AuthRepo authRepo; }',
  ),

  // --- Animations ---
  InterviewQuestion(
    id: 'a_anim_1',
    topic: 'animations',
    subtopic: 'AnimationController',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'How do you create a staggered animation in Flutter?',
    answer: 'Use a single AnimationController with multiple Tween/CurvedAnimation instances, each using Interval to define when they play. The Interval defines a fraction (0.0 to 1.0) of the total animation duration.',
    explanation: 'final controller = AnimationController(duration: Duration(seconds: 2), vsync: this);\nfinal fadeIn = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Interval(0.0, 0.3)));\nfinal slideUp = Tween(begin: 50.0, end: 0.0).animate(CurvedAnimation(parent: controller, curve: Interval(0.2, 0.6)));\ncontroller.forward(); // both animate with staggered timing',
  ),

  // --- Testing ---
  InterviewQuestion(
    id: 'a_test_1',
    topic: 'testing',
    subtopic: 'Golden Tests',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'What are golden tests and when should you use them?',
    answer: 'Golden tests capture a screenshot of a widget and compare it pixel-by-pixel against a reference image. Use them for complex UI components where visual regression matters — design system components, custom painters, charts.',
    explanation: 'testWidgets("button golden", (tester) async {\n  await tester.pumpWidget(MyButton());\n  await expectLater(find.byType(MyButton), matchesGoldenFile("button.png"));\n});\nUpdate goldens: flutter test --update-goldens',
  ),

  // --- Dart ---
  InterviewQuestion(
    id: 'a_dart_1',
    topic: 'dart_fundamentals',
    subtopic: 'OOP',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'What are sealed classes in Dart and when should you use them?',
    answer: 'Sealed classes restrict which classes can extend/implement them — only classes in the same library. This enables exhaustive pattern matching in switch statements. The compiler warns if you miss a case.',
    explanation: 'sealed class Shape {}\nclass Circle extends Shape { final double radius; }\nclass Square extends Shape { final double side; }\n\nswitch (shape) {\n  case Circle(radius: var r): return pi * r * r;\n  case Square(side: var s): return s * s;\n  // compiler warns if you add Triangle but forget to handle it\n}',
  ),
  InterviewQuestion(
    id: 'a_dart_2',
    topic: 'dart_fundamentals',
    subtopic: 'Async/Await',
    difficulty: Difficulty.advanced,
    type: QuestionType.conceptual,
    question: 'What is the difference between Future.wait and Future.any? What about error handling?',
    answer: 'Future.wait waits for ALL futures to complete and returns a list of results. Future.any completes with the FIRST future to complete. Future.wait fails if any future fails (unless eagerError is false). Future.any completes with the first result, ignoring others.',
    explanation: 'await Future.wait([fetchUser(), fetchPosts()]); // both finish, returns [user, posts]\nawait Future.any([serverA(), serverB()]); // fastest one wins\n\nFuture.wait fails fast by default. Use .catchError or try/catch. For partial results, handle errors per-future before passing to wait.',
  ),
];
