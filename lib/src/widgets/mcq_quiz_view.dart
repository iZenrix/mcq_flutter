import 'package:flutter/material.dart';

import 'package:mcq_engine/mcq_engine.dart';
import 'mcq_question_view.dart';

class McqQuizView extends StatefulWidget {
  const McqQuizView({
    super.key,
    required this.quiz,
    required this.onSubmit,
    this.initialAnswers = const <UserAnswer>[],
    this.onAnswersChanged,
    this.submitButtonText = 'Submit',
    this.padding = const EdgeInsets.all(16),
  });

  final Quiz quiz;
  final List<UserAnswer> initialAnswers;
  final ValueChanged<List<UserAnswer>> onSubmit;
  final ValueChanged<List<UserAnswer>>? onAnswersChanged;
  final String submitButtonText;
  final EdgeInsetsGeometry padding;

  @override
  State<McqQuizView> createState() => _McqQuizViewState();
}

class _McqQuizViewState extends State<McqQuizView> {
  late final Map<String, UserAnswer> _answers;

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
    return ListView(
      padding: widget.padding,
      children: <Widget>[
        if ((widget.quiz.title ?? '').trim().isNotEmpty) ...<Widget>[
          Text(
            widget.quiz.title!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
        ],
        if ((widget.quiz.description ?? '').trim().isNotEmpty) ...<Widget>[
          Text(
            widget.quiz.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
        ],
        ...widget.quiz.questions.asMap().entries.map((
          MapEntry<int, Question> entry,
        ) {
          final int index = entry.key;
          final Question question = entry.value;
          return McqQuestionView(
            index: index,
            question: question,
            answer: _answers[question.id],
            onChanged: (UserAnswer updatedAnswer) {
              setState(() {
                _answers[updatedAnswer.questionId] = updatedAnswer;
              });
              widget.onAnswersChanged?.call(_answers.values.toList());
            },
          );
        }),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => widget.onSubmit(_answers.values.toList()),
          child: Text(widget.submitButtonText),
        ),
      ],
    );
  }
}
