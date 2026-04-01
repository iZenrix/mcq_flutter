import 'package:mcq_engine/mcq_engine.dart';

class McqPracticeDialogResult {
  final Quiz quiz;
  final List<UserAnswer> answers;
  final EvaluationResult evaluationResult;
  final bool completedPerfectly;

  const McqPracticeDialogResult({
    required this.quiz,
    required this.answers,
    required this.evaluationResult,
    required this.completedPerfectly,
  });
}
