import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';

final supabase = Supabase.instance.client;

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswerIndex;
  bool answered = false;
  bool isLoading = true;
  String? errorMessage;

  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      // Fetch quiz questions and options in one query using join
      final response = await supabase
          .from('quiz')
          .select('*, quiz_option(*)')
          .order('id');

      final List<Question> loadedQuestions = [];
      
      for (var quizData in response) {
        final options = List<Map<String, dynamic>>.from(quizData['quiz_option'] ?? []);
        final question = Question.fromSupabaseData(quizData, options);
        loadedQuestions.add(question);
      }

      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });
    } on PostgrestException catch (error) {
      setState(() {
        errorMessage = 'Error loading quiz: ${error.message}';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.message}')),
      );
    } catch (error) {
      setState(() {
        errorMessage = 'Unexpected error: $error';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void selectAnswer(int index) {
    if (!answered) {
      setState(() {
        selectedAnswerIndex = index;
        answered = true;
        if (index == questions[currentQuestionIndex].correctAnswerIndex) {
          score++;
        }
      });
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        answered = false;
      });
    } else {
      showResultsDialog();
    }
  }

  void showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Completed!'),
          content: Text(
            'Your Score: $score / ${questions.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: resetQuiz,
              child: const Text('Retake Quiz'),
            ),
          ],
        );
      },
    );
  }

  void resetQuiz() {
    Navigator.pop(context);
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswerIndex = null;
      answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz App'),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz App'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            errorMessage ?? 'No quiz questions found',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1}/${questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 32),

              // Question
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedAnswerIndex == index;
                    bool isCorrect =
                        index == question.correctAnswerIndex;
                    bool showCorrectAnswer = answered && isCorrect;
                    bool showIncorrectAnswer = answered && isSelected && !isCorrect;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => selectAnswer(index),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: showCorrectAnswer
                                  ? Colors.green
                                  : showIncorrectAnswer
                                      ? Colors.red
                                      : isSelected
                                          ? Colors.deepPurple
                                          : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: showCorrectAnswer
                                ? Colors.green.shade50
                                : showIncorrectAnswer
                                    ? Colors.red.shade50
                                    : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: showCorrectAnswer
                                      ? Colors.green
                                      : showIncorrectAnswer
                                          ? Colors.red
                                          : isSelected
                                              ? Colors.deepPurple
                                              : Colors.grey.shade300,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      color: isSelected || showCorrectAnswer || showIncorrectAnswer
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (showCorrectAnswer)
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                              if (showIncorrectAnswer)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Next button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: answered ? nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: Text(
                    currentQuestionIndex == questions.length - 1
                        ? 'Finish Quiz'
                        : 'Next Question',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
