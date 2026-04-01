import 'package:flutter/material.dart';
import 'package:mcq_engine/mcq_engine.dart';

import '../enums/mcq_practice_dialog_phase.dart';
import '../models/mcq_practice_dialog_result.dart';
import 'mcq_question_view.dart';
import 'mcq_review_view.dart';

Future<McqPracticeDialogResult?> showMcqPracticeDialog({
  required BuildContext context,
  required Quiz quiz,
  QuizConfig randomizeConfig = const QuizConfig(),
  bool requireAnswerBeforeNext = false,
  bool requireAnswerBeforeSubmit = false,
  int? questionCount,
}) {
  return showDialog<McqPracticeDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: McqPracticeDialog(
          quiz: quiz,
          randomizeConfig: randomizeConfig,
          requireAnswerBeforeNext: requireAnswerBeforeNext,
          requireAnswerBeforeSubmit: requireAnswerBeforeSubmit,
          questionCount: questionCount,
        ),
      );
    },
  );
}

class McqPracticeDialog extends StatefulWidget {
  const McqPracticeDialog({
    super.key,
    required this.quiz,
    this.randomizeConfig = const QuizConfig(),
    this.requireAnswerBeforeNext = false,
    this.requireAnswerBeforeSubmit = false,
    this.questionCount,
  });

  final Quiz quiz;
  final QuizConfig randomizeConfig;
  final bool requireAnswerBeforeNext;
  final bool requireAnswerBeforeSubmit;
  final int? questionCount;

  @override
  State<McqPracticeDialog> createState() => _McqPracticeDialogState();
}

class _McqPracticeDialogState extends State<McqPracticeDialog> {
  late Quiz _quiz;
  final Map<String, UserAnswer> _answers = <String, UserAnswer>{};

  final Set<String> _usedQuestionIds = <String>{};

  int _currentIndex = 0;
  McqPracticeDialogPhase _phase = McqPracticeDialogPhase.answering;
  EvaluationResult? _evaluationResult;

  @override
  void initState() {
    super.initState();
    _quiz = _buildQuizForAttempt();
  }

  Question get _currentQuestion => _quiz.questions[_currentIndex];

  bool get _isLastQuestion => _currentIndex == _quiz.questions.length - 1;

  UserAnswer? get _currentAnswer => _answers[_currentQuestion.id];

  bool get _hasCurrentAnswer =>
      (_currentAnswer?.selectedOptionIds.isNotEmpty ?? false);

  void _handleAnswerChanged(UserAnswer answer) {
    setState(() {
      _answers[answer.questionId] = answer;
    });
  }

  void _goNext() {
    if (widget.requireAnswerBeforeNext && !_hasCurrentAnswer) {
      return;
    }

    if (_isLastQuestion) {
      _submit();
      return;
    }

    setState(() {
      _currentIndex++;
    });
  }

  void _goBack() {
    if (_currentIndex == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentIndex--;
    });
  }

  void _submit() {
    if (widget.requireAnswerBeforeSubmit && !_hasCurrentAnswer) {
      return;
    }

    final List<UserAnswer> answers = _answers.values.toList();

    final EvaluationResult result = const QuizEvaluator().evaluate(
      quiz: _quiz,
      answers: answers,
    );

    setState(() {
      _evaluationResult = result;
      _phase = McqPracticeDialogPhase.review;
    });
  }

  void _retryUntilPerfect() {
    setState(() {
      _quiz = _buildQuizForAttempt();
      _phase = McqPracticeDialogPhase.answering;
      _evaluationResult = null;
      _currentIndex = 0;
      _answers.clear();
    });
  }

  Quiz _buildQuizForAttempt() {
    final Quiz randomizedQuiz = const QuizRandomizer().randomize(
      quiz: widget.quiz,
      config: widget.randomizeConfig,
    );

    final List<Question> allQuestions = List<Question>.from(
      randomizedQuiz.questions,
    );

    if (allQuestions.isEmpty) {
      return randomizedQuiz;
    }

    final int desiredCount = widget.questionCount == null
        ? allQuestions.length
        : widget.questionCount!.clamp(1, allQuestions.length);

    List<Question> unseenQuestions = allQuestions
        .where((q) => !_usedQuestionIds.contains(q.id))
        .toList();

    if (unseenQuestions.isEmpty) {
      _usedQuestionIds.clear();
      unseenQuestions = List<Question>.from(allQuestions);
    }

    unseenQuestions.shuffle();

    final List<Question> selected = <Question>[];

    for (final q in unseenQuestions) {
      if (selected.length >= desiredCount) break;
      selected.add(q);
    }

    if (selected.length < desiredCount) {
      final Set<String> selectedIds = selected.map((e) => e.id).toSet();

      final List<Question> fallbackQuestions =
          allQuestions.where((q) => !selectedIds.contains(q.id)).toList()
            ..shuffle();

      for (final q in fallbackQuestions) {
        if (selected.length >= desiredCount) break;
        selected.add(q);
      }
    }

    _usedQuestionIds.addAll(selected.map((e) => e.id));

    return randomizedQuiz.copyWith(questions: selected);
  }

  void _closeWithResult() {
    final EvaluationResult result = _evaluationResult!;

    Navigator.of(context).pop(
      McqPracticeDialogResult(
        quiz: _quiz,
        answers: _answers.values.toList(),
        evaluationResult: result,
        completedPerfectly: result.correctCount == result.totalQuestions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 500),
      child: _phase == McqPracticeDialogPhase.answering
          ? _buildAnsweringView(context)
          : _buildReviewView(context),
    );
  }

  Widget _buildAnsweringView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildHeader(
          title: _quiz.title ?? 'Quiz',
          subtitle:
              'Question ${_currentIndex + 1} of ${_quiz.questions.length}',
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: McqQuestionView(
              index: _currentIndex,
              question: _currentQuestion,
              answer: _currentAnswer,
              onChanged: _handleAnswerChanged,
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              OutlinedButton(onPressed: _goBack, child: const Text('Back')),
              const Spacer(),
              FilledButton(
                onPressed:
                    (_isLastQuestion &&
                            widget.requireAnswerBeforeSubmit &&
                            !_hasCurrentAnswer) ||
                        (!_isLastQuestion &&
                            widget.requireAnswerBeforeNext &&
                            !_hasCurrentAnswer)
                    ? null
                    : _goNext,
                child: Text(_isLastQuestion ? 'Submit' : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewView(BuildContext context) {
    final EvaluationResult result = _evaluationResult!;
    final bool perfect = result.correctCount == result.totalQuestions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildHeader(
          title: perfect ? 'Bagus, semua benar!' : 'Review Jawaban',
          subtitle:
              'Benar ${result.correctCount}/${result.totalQuestions} • ${result.percentage.toStringAsFixed(0)}%',
        ),
        const Divider(height: 1),
        Expanded(
          child: McqReviewView(
            quiz: _quiz,
            answers: _answers.values.toList(),
            evaluationResult: result,
            padding: const EdgeInsets.all(16),
            showSummary: false,
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              if (!perfect)
                FilledButton(
                  onPressed: _retryUntilPerfect,
                  child: const Text('Ulangi'),
                ),
              const Spacer(),
              TextButton(
                onPressed: _closeWithResult,
                child: Text(perfect ? 'Selesai' : 'Tutup'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
