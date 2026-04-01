import 'package:flutter/material.dart';
import 'package:mcq_engine/mcq_engine.dart';

class McqQuestionView extends StatelessWidget {
  const McqQuestionView({
    super.key,
    required this.question,
    required this.onChanged,
    this.answer,
    this.result,
    this.reviewMode = false,
    this.index,
  });

  final Question question;
  final UserAnswer? answer;
  final QuestionResult? result;
  final bool reviewMode;
  final int? index;
  final ValueChanged<UserAnswer> onChanged;

  @override
  Widget build(BuildContext context) {
    final Set<String> selectedIds = answer?.selectedOptionIds ?? <String>{};

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              index == null ? question.text : '${index! + 1}. ${question.text}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...question.options.map(
              (OptionItem option) =>
                  _buildOptionTile(context, option, selectedIds),
            ),
            if (reviewMode &&
                question.explanation != null &&
                question.explanation!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Explanation: ${question.explanation!}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    OptionItem option,
    Set<String> selectedIds,
  ) {
    final String? groupValue = selectedIds.isEmpty ? null : selectedIds.first;
    final bool isSelected = selectedIds.contains(option.id);
    final bool isCorrect =
        result?.correctOptionIds.contains(option.id) ?? false;
    final bool isPickedWrong = reviewMode && isSelected && !isCorrect;

    Color? tileColor;
    if (reviewMode) {
      if (isCorrect) {
        tileColor = Colors.green.withValues(alpha: (0.12));
      } else if (isPickedWrong) {
        tileColor = Colors.red.withValues(alpha: (0.12));
      }
    }

    final Widget title = Container(
      color: tileColor,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Text(option.text),
    );

    if (question.type == QuestionType.singleChoice) {
      return RadioListTile<String>(
        value: option.id,
        groupValue: groupValue,
        onChanged: reviewMode
            ? null
            : (String? value) {
                if (value == null) return;
                onChanged(
                  UserAnswer(
                    questionId: question.id,
                    selectedOptionIds: <String>{value},
                  ),
                );
              },
        title: title,
      );
    }

    return CheckboxListTile(
      value: isSelected,
      onChanged: reviewMode
          ? null
          : (bool? value) {
              final Set<String> updated = <String>{...selectedIds};
              if (value == true) {
                updated.add(option.id);
              } else {
                updated.remove(option.id);
              }
              onChanged(
                UserAnswer(questionId: question.id, selectedOptionIds: updated),
              );
            },
      title: title,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
