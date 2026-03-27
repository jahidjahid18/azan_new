import 'dart:convert';
import 'dart:math';

import 'package:azan_app/ads/sticky_bottom_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const List<String> _categories = <String>[
    'Solat',
    'Quran',
    'Hadith',
    'General Islam',
  ];
  static const int _questionsPerRound = 10;

  final Random _random = Random();

  bool _isLoading = true;
  String? _errorText;
  String _selectedCategory = _categories.first;
  List<_QuizQuestion> _allQuestions = <_QuizQuestion>[];
  List<_QuizQuestion> _sessionQuestions = <_QuizQuestion>[];
  int _questionIndex = 0;
  int? _selectedIndex;
  int _correctCount = 0;

  _QuizQuestion get _current => _sessionQuestions[_questionIndex];

  bool get _hasData => _sessionQuestions.isNotEmpty;

  bool get _isCorrect =>
      _selectedIndex != null && _selectedIndex == _current.correctIndex;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final raw = await rootBundle.loadString(
        'assets/data/quiz_questions.json',
      );
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        throw Exception('Invalid quiz data format.');
      }

      final questions = decoded
          .map((item) => _QuizQuestion.fromMap(item as Map<String, dynamic>))
          .toList(growable: false);

      if (questions.isEmpty) {
        throw Exception('No quiz questions found.');
      }

      if (!mounted) return;
      setState(() {
        _allQuestions = questions;
      });
      _startCategoryQuiz();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Unable to load quiz questions.';
      });
    }
  }

  void _startCategoryQuiz() {
    final pool = _allQuestions
        .where((q) => q.category == _selectedCategory)
        .toList(growable: false);

    if (pool.length < _questionsPerRound) {
      setState(() {
        _isLoading = false;
        _sessionQuestions = <_QuizQuestion>[];
        _errorText =
            'Not enough questions in $_selectedCategory. Please add more in JSON.';
      });
      return;
    }

    final shuffled = List<_QuizQuestion>.from(pool)..shuffle(_random);
    setState(() {
      _isLoading = false;
      _errorText = null;
      _sessionQuestions = shuffled
          .take(_questionsPerRound)
          .toList(growable: false);
      _questionIndex = 0;
      _selectedIndex = null;
      _correctCount = 0;
    });
  }

  void _selectOption(int index) {
    if (_selectedIndex != null) return;
    setState(() {
      _selectedIndex = index;
      if (index == _current.correctIndex) {
        _correctCount += 1;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_selectedIndex == null) return;

    final isLast = _questionIndex >= _sessionQuestions.length - 1;
    if (isLast) {
      await _showCompletedDialog();
      return;
    }

    setState(() {
      _questionIndex += 1;
      _selectedIndex = null;
    });
  }

  Future<void> _showCompletedDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Completed'),
          content: Text(
            'You got $_correctCount / $_questionsPerRound correct.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startCategoryQuiz();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Quiz')),
      bottomNavigationBar: const StickyBottomBannerAd(topSpacing: 8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorText != null
          ? Center(child: Text(_errorText!))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories
                      .map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            if (!selected || _selectedCategory == category) {
                              return;
                            }
                            setState(() => _selectedCategory = category);
                            _startCategoryQuiz();
                          },
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: _allQuestions.isEmpty ? null : _startCategoryQuiz,
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('Start Random Quiz'),
                ),
                const SizedBox(height: 16),
                if (_hasData) ...<Widget>[
                  Text(
                    'Category: $_selectedCategory',
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Question ${_questionIndex + 1} / $_questionsPerRound',
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_current.question, style: textTheme.titleLarge),
                  const SizedBox(height: 16),
                  for (int i = 0; i < _current.options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed: () => _selectOption(i),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_current.options[i]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (_selectedIndex != null)
                    Text(
                      _isCorrect ? 'Correct' : 'Incorrect',
                      style: textTheme.titleMedium,
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _selectedIndex == null ? null : _nextQuestion,
                    child: Text(
                      _questionIndex >= _questionsPerRound - 1
                          ? 'Finish Quiz'
                          : 'Next Question',
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _QuizQuestion {
  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String category;

  factory _QuizQuestion.fromMap(Map<String, dynamic> map) {
    final optionsRaw = map['options'] as List<dynamic>;
    if (optionsRaw.length != 4) {
      throw const FormatException('Each quiz question must have 4 options.');
    }
    final correctIndex = map['correctIndex'] as int;
    if (correctIndex < 0 || correctIndex >= optionsRaw.length) {
      throw const FormatException('Invalid correctIndex in quiz question.');
    }
    return _QuizQuestion(
      question: map['question'] as String,
      options: optionsRaw.map((e) => e.toString()).toList(growable: false),
      correctIndex: correctIndex,
      category: map['category'] as String,
    );
  }
}
