# mcq_flutter

Flutter UI widgets for `mcq_engine`.

## Features

- `McqQuestionView`
- `McqQuizView`
- `McqReviewView`


## Quiz dialog

You can open a one-question-at-a-time popup dialog with `showMcqQuizDialog`.
If the quiz has multiple questions, the dialog shows **Next** and **Back**.
If the quiz only has one question, it shows **Submit** directly.

```dart
final answers = await showMcqQuizDialog(
  context: context,
  quiz: quiz,
);
```
