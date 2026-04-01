import 'package:flutter/material.dart';

import 'package:mcq_engine/mcq_engine.dart';
import 'mcq_question_view.dart';

class McqReviewView extends StatelessWidget {
  const McqReviewView({
    super.key,
    required this.quiz,
    required this.answers,
    required this.evaluationResult,
    this.padding = const EdgeInsets.all(16),
    this.showSummary = true,
  });

  final Quiz quiz;
  final List<UserAnswer> answers;
  final EvaluationResult evaluationResult;
  final EdgeInsetsGeometry padding;
  final bool showSummary;

  @override
  Widget build(BuildContext context) {
    final Map<String, UserAnswer> answerMap = <String, UserAnswer>{
      for (final UserAnswer answer in answers) answer.questionId: answer,
    };
    final Map<String, QuestionResult> resultMap = <String, QuestionResult>{
      for (final QuestionResult result in evaluationResult.questionResults)
        result.questionId: result,
    };

    return ListView(
      padding: padding,
      children: <Widget>[
        if (showSummary) ...[
          _SummaryHeader(evaluationResult: evaluationResult),
          const SizedBox(height: 16),
        ],
        ...quiz.questions.asMap().entries.map((MapEntry<int, Question> entry) {
          final int index = entry.key;
          final Question question = entry.value;
          return McqQuestionView(
            index: index,
            question: question,
            answer: answerMap[question.id],
            result: resultMap[question.id],
            reviewMode: true,
            onChanged: (_) {},
          );
        }),
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.evaluationResult});

  final EvaluationResult evaluationResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Quiz Result', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Correct: ${evaluationResult.correctCount}'),
            Text('Wrong: ${evaluationResult.wrongCount}'),
            Text('Unanswered: ${evaluationResult.unansweredCount}'),
            Text(
              'Score: ${evaluationResult.totalScore}/${evaluationResult.maxScore}',
            ),
            Text(
              'Percentage: ${evaluationResult.percentage.toStringAsFixed(2)}%',
            ),
          ],
        ),
      ),
    );
  }
}
