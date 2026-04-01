import 'package:flutter/material.dart';

import 'package:mcq_engine/mcq_engine.dart';
import 'mcq_question_view.dart';

/// Shows a modal quiz dialog and returns the submitted answers.
Future<List<UserAnswer>?> showMcqQuizDialog({
  required BuildContext context,
  required Quiz quiz,
  List<UserAnswer> initialAnswers = const <UserAnswer>[],
  bool barrierDismissible = true,
  String nextButtonText = 'Next',
  String backButtonText = 'Back',
  String submitButtonText = 'Submit',
  String closeTooltip = 'Close',
}) {
  return showDialog<List<UserAnswer>>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext dialogContext) {
      return McqQuizDialog(
        quiz: quiz,
        initialAnswers: initialAnswers,
        nextButtonText: nextButtonText,
        backButtonText: backButtonText,
        submitButtonText: submitButtonText,
        closeTooltip: closeTooltip,
      );
    },
  );
}

/// A modal dialog that displays one question at a time.
class McqQuizDialog extends StatefulWidget {
  const McqQuizDialog({
    super.key,
    required this.quiz,
    this.initialAnswers = const <UserAnswer>[],
    this.nextButtonText = 'Next',
    this.backButtonText = 'Back',
    this.submitButtonText = 'Submit',
    this.closeTooltip = 'Close',
  });

  final Quiz quiz;
  final List<UserAnswer> initialAnswers;
  final String nextButtonText;
  final String backButtonText;
  final String submitButtonText;
  final String closeTooltip;

  @override
  State<McqQuizDialog> createState() => _McqQuizDialogState();
}

class _McqQuizDialogState extends State<McqQuizDialog> {
  late final Map<String, UserAnswer> _answers;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _answers = <String, UserAnswer>{
      for (final UserAnswer answer in widget.initialAnswers)
        answer.questionId: answer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Question question = widget.quiz.questions[_currentIndex];
    final bool isFirst = _currentIndex == 0;
    final bool isLast = _currentIndex == widget.quiz.questions.length - 1;
    final bool isSingleQuestion = widget.quiz.questions.length == 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if ((widget.quiz.title ?? '').trim().isNotEmpty)
                          Text(
                            widget.quiz.title!,
                            style: theme.textTheme.titleLarge,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Question ${_currentIndex + 1} of ${widget.quiz.questions.length}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: widget.closeTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: widget.quiz.questions.isEmpty
                    ? 0
                    : (_currentIndex + 1) / widget.quiz.questions.length,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: McqQuestionView(
                  index: _currentIndex,
                  question: question,
                  answer: _answers[question.id],
                  onChanged: (UserAnswer updatedAnswer) {
                    setState(() {
                      _answers[updatedAnswer.questionId] = updatedAnswer;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: <Widget>[
                  if (!isFirst)
                    OutlinedButton(
                      onPressed: _goBack,
                      child: Text(widget.backButtonText),
                    )
                  else
                    const SizedBox.shrink(),
                  const Spacer(),
                  FilledButton(
                    onPressed: isLast || isSingleQuestion ? _submit : _goNext,
                    child: Text(
                      isLast || isSingleQuestion
                          ? widget.submitButtonText
                          : widget.nextButtonText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goBack() {
    if (_currentIndex == 0) {
      return;
    }

    setState(() {
      _currentIndex -= 1;
    });
  }

  void _goNext() {
    if (_currentIndex >= widget.quiz.questions.length - 1) {
      _submit();
      return;
    }

    setState(() {
      _currentIndex += 1;
    });
  }

  void _submit() {
    Navigator.of(context).pop(_answers.values.toList());
  }
}
