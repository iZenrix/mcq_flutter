import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mcq_engine/mcq_engine.dart';
import 'package:mcq_flutter/mcq_flutter.dart';

void main() {
  Quiz buildQuiz({int totalQuestions = 2}) {
    final List<Question> questions = <Question>[
      Question(
        id: 'q1',
        type: QuestionType.singleChoice,
        text: '2 + 2 = ?',
        options: <OptionItem>[
          const OptionItem(id: 'a', text: '3'),
          const OptionItem(id: 'b', text: '4'),
        ],
        correctOptionIds: <String>{'b'},
      ),
    ];

    if (totalQuestions > 1) {
      questions.add(
        Question(
          id: 'q2',
          type: QuestionType.multipleChoice,
          text: 'Select prime numbers',
          options: <OptionItem>[
            const OptionItem(id: 'a', text: '2'),
            const OptionItem(id: 'b', text: '3'),
            const OptionItem(id: 'c', text: '4'),
          ],
          correctOptionIds: <String>{'a', 'b'},
        ),
      );
    }

    return Quiz(title: 'Quiz Title', questions: questions);
  }

  testWidgets('McqQuizView renders title and submit button', (
    WidgetTester tester,
  ) async {
    final Quiz quiz = buildQuiz(totalQuestions: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: McqQuizView(quiz: quiz, onSubmit: (_) {}),
        ),
      ),
    );

    expect(find.text('Quiz Title'), findsOneWidget);
    expect(find.text('2 + 2 = ?'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('showMcqQuizDialog uses Next for multi-question quiz', (
    WidgetTester tester,
  ) async {
    final Quiz quiz = buildQuiz(totalQuestions: 2);
    List<UserAnswer>? submittedAnswers;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    submittedAnswers = await showMcqQuizDialog(
                      context: context,
                      quiz: quiz,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 2'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Submit'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Question 2 of 2'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(submittedAnswers, isNotNull);
  });

  testWidgets(
    'showMcqQuizDialog uses Submit directly for single question quiz',
    (WidgetTester tester) async {
      final Quiz quiz = buildQuiz(totalQuestions: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      showMcqQuizDialog(context: context, quiz: quiz);
                    },
                    child: const Text('Open Single'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Single'));
      await tester.pumpAndSettle();

      expect(find.text('Question 1 of 1'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    },
  );
}
