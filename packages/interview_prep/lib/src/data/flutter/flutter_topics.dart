import 'package:flutter/material.dart';
import 'package:interview_prep/src/models/topic.dart';

List<InterviewTopic> flutterTopics() => const [
      InterviewTopic(
        id: 'dart_fundamentals',
        name: 'Dart Fundamentals',
        description: 'Core Dart language features, types, and syntax',
        icon: Icons.code,
        subtopics: ['Types', 'Null Safety', 'Async/Await', 'Collections', 'OOP', 'Generics'],
      ),
      InterviewTopic(
        id: 'widgets',
        name: 'Widgets & UI',
        description: 'Widget tree, StatelessWidget, StatefulWidget, lifecycle',
        icon: Icons.widgets,
        subtopics: ['StatelessWidget', 'StatefulWidget', 'Lifecycle', 'Keys', 'BuildContext'],
      ),
      InterviewTopic(
        id: 'layouts',
        name: 'Layouts & Styling',
        description: 'Row, Column, Stack, Container, constraints, responsive design',
        icon: Icons.dashboard,
        subtopics: ['Flex', 'Constraints', 'MediaQuery', 'Responsive', 'Themes'],
      ),
      InterviewTopic(
        id: 'state_management',
        name: 'State Management',
        description: 'setState, Provider, Riverpod, BLoC, and other approaches',
        icon: Icons.account_tree,
        subtopics: ['setState', 'InheritedWidget', 'Provider', 'Riverpod', 'BLoC'],
      ),
      InterviewTopic(
        id: 'navigation',
        name: 'Navigation & Routing',
        description: 'Navigator, GoRouter, deep linking, route guards',
        icon: Icons.route,
        subtopics: ['Navigator 1.0', 'Navigator 2.0', 'GoRouter', 'Deep Linking'],
      ),
      InterviewTopic(
        id: 'networking',
        name: 'Networking & Data',
        description: 'HTTP, REST APIs, JSON, local storage, Firebase',
        icon: Icons.cloud,
        subtopics: ['HTTP', 'JSON', 'REST', 'Firebase', 'Local Storage'],
      ),
      InterviewTopic(
        id: 'testing',
        name: 'Testing',
        description: 'Unit tests, widget tests, integration tests, mocking',
        icon: Icons.bug_report,
        subtopics: ['Unit Tests', 'Widget Tests', 'Integration Tests', 'Mocking', 'Golden Tests'],
      ),
      InterviewTopic(
        id: 'animations',
        name: 'Animations',
        description: 'Implicit, explicit, Hero, page transitions, Rive, Lottie',
        icon: Icons.animation,
        subtopics: ['Implicit', 'Explicit', 'AnimationController', 'Hero', 'Custom'],
      ),
      InterviewTopic(
        id: 'performance',
        name: 'Performance',
        description: 'Profiling, optimization, jank, memory, isolates',
        icon: Icons.speed,
        subtopics: ['Profiling', 'Optimization', 'Isolates', 'Memory', 'Rendering'],
      ),
      InterviewTopic(
        id: 'architecture',
        name: 'Architecture & Patterns',
        description: 'Clean architecture, MVVM, repository pattern, DI',
        icon: Icons.architecture,
        subtopics: ['Clean Architecture', 'MVVM', 'Repository', 'DI', 'SOLID'],
      ),
      InterviewTopic(
        id: 'platform_integration',
        name: 'Platform Integration',
        description: 'Platform channels, plugins, native code, FFI',
        icon: Icons.phone_android,
        subtopics: ['MethodChannel', 'EventChannel', 'Plugins', 'FFI', 'Pigeon'],
      ),
      InterviewTopic(
        id: 'internals',
        name: 'Flutter Internals',
        description: 'Rendering pipeline, Element tree, RenderObject, engine',
        icon: Icons.settings_suggest,
        subtopics: ['Widget-Element-RenderObject', 'Rendering Pipeline', 'Bindings', 'Engine', 'Compilation'],
      ),
    ];
