class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Question.fromSupabaseData(Map<String, dynamic> quizData, List<Map<String, dynamic>> options) {
    // Sort options by option_index to ensure correct order
    options.sort((a, b) => a['option_index'].compareTo(b['option_index']));
    
    final optionTexts = options.map((o) => o['option_text'] as String).toList();
    final correctIndex = options.indexWhere((o) => o['is_correct'] == true);

    return Question(
      id: quizData['id'],
      question: quizData['question'],
      options: optionTexts,
      correctAnswerIndex: correctIndex,
    );
  }
}
