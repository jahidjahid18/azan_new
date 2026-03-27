import 'package:azan_app/ads/sticky_bottom_banner_ad.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const List<_QuizQuestion> _questions = <_QuizQuestion>[
    _QuizQuestion(
      question: 'How many Rakats in Fajr?',
      options: <String>['2', '3', '4', '5'],
      correctIndex: 0,
    ),
    _QuizQuestion(
      question: 'First Surah in Quran?',
      options: <String>['Al-Baqarah', 'Al-Falaq', 'Al-Fatiha', 'An-Nas'],
      correctIndex: 2,
    ),
    _QuizQuestion(
      question: 'Qibla direction is towards?',
      options: <String>['Madinah', 'Kaaba', 'Jerusalem', 'Mount Sinai'],
      correctIndex: 1,
    ),
  ];

  int _questionIndex = 0;
  int? _selectedIndex;

  _QuizQuestion get _current => _questions[_questionIndex];

  bool get _isCorrect =>
      _selectedIndex != null && _selectedIndex == _current.correctIndex;

  void _selectOption(int index) {
    if (_selectedIndex != null) return;
    setState(() => _selectedIndex = index);
  }

  void _nextQuestion() {
    setState(() {
      _questionIndex = (_questionIndex + 1) % _questions.length;
      _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Quiz')),
      bottomNavigationBar: const StickyBottomBannerAd(topSpacing: 8),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Question ${_questionIndex + 1}',
            style: textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _current.question,
            style: textTheme.titleLarge,
          ),
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
            child: const Text('Next Question'),
          ),
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
  });

  final String question;
  final List<String> options;
  final int correctIndex;
}
