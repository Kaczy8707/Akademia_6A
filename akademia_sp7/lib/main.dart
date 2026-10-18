import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AkademiaApp());
}

class AkademiaApp extends StatelessWidget {
  const AkademiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akademia SP7 - Klasa 6',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF06B6D4),
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _userXP = 0;
  String? _selectedSubject;
  String? _selectedChapter;
  List<Question> _currentQuiz = [];

  final Map<String, SubjectData> _program = {
    'historia': SubjectData('Historia (Wczoraj i dziś 6)', '⚔️', [
      'Rozdział I: Narodziny nowożytnego świata',
      'Rozdział II: W Rzeczypospolitej szlacheckiej',
      'Rozdział VI: Rewolucja francuska i okres napoleoński',
    ]),
    'geografia': SubjectData('Geografia (Planeta Nowa 6)', '🌍', [
      'Rozdział 1: Współrzędne geograficzne',
      'Rozdział 3: Środowisko przyrodnicze i ludność Europy',
    ]),
    'biologia': SubjectData('Biologia (Puls Życia 6)', '🌿', [
      'Dział I: Świat zwierząt',
    ]),
  };

  @override
  void initState() {
    super.initState();
    _loadXP();
  }

  Future<void> _loadXP() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userXP = prefs.getInt('user_xp') ?? 0;
    });
  }

  Future<void> _addXP(int points) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userXP += points;
    });
    await prefs.setInt('user_xp', _userXP);
  }

  void _generateQuiz(String chapter) {
    List<Question> q = [];

    if (chapter.contains('Rzeczypospolitej szlacheckiej')) {
      q = [
        Question(
          text: 'Przeanalizuj poniższą mapę historyczną przedstawiającą Rzeczpospolitą Obojga Narodów (1569 r.). Który obszar oznaczono literą A?',
          mapType: 'unia_lubelska',
          options: [
            'Korona Królestwa Polskiego (obszar A)',
            'Wielkie Księstwo Litewskie (obszar B)',
            'Prusy Książęce'
          ],
          correctAnswer: 'Korona Królestwa Polskiego (obszar A)',
          hint: 'Obszar A ze stolicą w Krakowie i Warszawą to Korona Polska.',
        ),
      ];
    } else if (chapter.contains('Współrzędne geograficzne')) {
      q = [
        Question(
          text: 'Przeanalizuj poniższy schemat siatki geograficznej. Od jakiej linii mierzymy długość geograficzną (0°)?',
          mapType: 'siatka_geo',
          options: ['Południk 0° (Greenwich)', 'Równik (0°)', 'Biegun Północny'],
          correctAnswer: 'Południk 0° (Greenwich)',
          hint: 'Południk Greenwich przechodzi pionowo przez siatkę.',
        ),
      ];
    } else {
      q = [
        Question(
          text: 'Przeanalizuj zagadnienie z działu "$chapter":',
          options: ['Wiedza opanowana poprawnie', 'Wymaga powtórzenia'],
          correctAnswer: 'Wiedza opanowana poprawnie',
          hint: 'Skorzystaj z podsumowania w podręczniku.',
        ),
      ];
    }

    setState(() {
      _selectedChapter = chapter;
      _currentQuiz = q;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ AKADEMIA SP7 - KLASA 6', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Text('⭐ $_userXP XP', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          )
        ],
      ),
      body: _selectedChapter != null
          ? QuizScreen(
              chapterTitle: _selectedChapter!,
              questions: _currentQuiz,
              onComplete: (score) {
                _addXP(score * 10);
                setState(() {
                  _selectedChapter = null;
                });
              },
              onCancel: () {
                setState(() {
                  _selectedChapter = null;
                });
              },
            )
          : _selectedSubject != null
              ? _buildChapterList()
              : _buildSubjectGrid(),
    );
  }

  Widget _buildSubjectGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wybierz przedmiot:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _program.entries.map((e) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSubject = e.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.value.icon, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(e.value.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    final subj = _program[_selectedSubject]!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedSubject = null;
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Powrót do przedmiotów'),
          ),
          const SizedBox(height: 16),
          Text('${subj.title} - Wybierz dział:', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: subj.chapters.length,
              itemBuilder: (context, index) {
                final chap = subj.chapters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(chap, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _generateQuiz(chap),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectData {
  final String title;
  final String icon;
  final List<String> chapters;
  SubjectData(this.title, this.icon, this.chapters);
}

class Question {
  final String text;
  final String? mapType;
  final List<String> options;
  final String correctAnswer;
  final String hint;

  Question({
    required this.text,
    this.mapType,
    required this.options,
    required this.correctAnswer,
    required this.hint,
  });
}

class QuizScreen extends StatefulWidget {
  final String chapterTitle;
  final List<Question> questions;
  final Function(int) onComplete;
  final VoidCallback onCancel;

  const QuizScreen({
    super.key,
    required this.chapterTitle,
    required this.questions,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, String> _userAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: widget.onCancel, child: const Text('Anuluj')),
              Expanded(
                child: Text(
                  widget.chapterTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.questions.length,
              itemBuilder: (context, qIdx) {
                final q = widget.questions[qIdx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zadanie ${qIdx + 1}: ${q.text}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (q.mapType != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: CustomPaint(
                              painter: MapPainter(mapType: q.mapType!),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        ...q.options.map((opt) {
                          final isSelected = _userAnswers[qIdx] == opt;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _userAnswers[qIdx] = opt;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF0891B2) : const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSelected ? Colors.cyan : Colors.white24),
                                ),
                                child: Text(opt, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFF6366F1),
            ),
            onPressed: () {
              int score = 0;
              for (int i = 0; i < widget.questions.length; i++) {
                if (_userAnswers[i] == widget.questions[i].correctAnswer) {
                  score++;
                }
              }
              widget.onComplete(score);
            },
            child: const Text('Sprawdź odpowiedzi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final String mapType;

  MapPainter({required this.mapType});

  @override
  void paint(Canvas canvas, Size size) {
    if (mapType == 'unia_lubelska') {
      final fillKorona = Paint()..color = const Color(0xFFE57373);
      final fillLitwa = Paint()..color = const Color(0xFF64B5F6);
      final strokeBorder = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2;

      final pathKorona = Path()
        ..moveTo(size.width * 0.1, size.height * 0.3)
        ..lineTo(size.width * 0.45, size.height * 0.2)
        ..lineTo(size.width * 0.42, size.height * 0.8)
        ..lineTo(size.width * 0.15, size.height * 0.75)
        ..close();

      final pathLitwa = Path()
        ..moveTo(size.width * 0.45, size.height * 0.2)
        ..lineTo(size.width * 0.85, size.height * 0.25)
        ..lineTo(size.width * 0.8, size.height * 0.75)
        ..lineTo(size.width * 0.42, size.height * 0.8)
        ..close();

      canvas.drawPath(pathKorona, fillKorona);
      canvas.drawPath(pathKorona, strokeBorder);
      canvas.drawPath(pathLitwa, fillLitwa);
      canvas.drawPath(pathLitwa, strokeBorder);

      const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
      final painterKorona = TextPainter(text: const TextSpan(text: 'KORONA (A)', style: textStyle), textDirection: TextDirection.ltr)..layout();
      painterKorona.paint(canvas, Offset(size.width * 0.2, size.height * 0.45));

      final painterLitwa = TextPainter(text: const TextSpan(text: 'LITWA (B)', style: textStyle), textDirection: TextDirection.ltr)..layout();
      painterLitwa.paint(canvas, Offset(size.width * 0.55, size.height * 0.45));
    } else {
      final globeBg = Paint()..color = const Color(0xFF0284C7);
      final linePaint = Paint()..color = Colors.amber..style = PaintingStyle.stroke..strokeWidth = 2;
      final greenwichPaint = Paint()..color = Colors.redAccent..style = PaintingStyle.stroke..strokeWidth = 2;

      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), globeBg);
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);
      canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), greenwichPaint);

      const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);
      final p1 = TextPainter(text: const TextSpan(text: 'Równik (0°)', style: style), textDirection: TextDirection.ltr)..layout();
      p1.paint(canvas, Offset(10, size.height / 2 - 18));

      final p2 = TextPainter(text: const TextSpan(text: 'Południk 0° (Greenwich)', style: style), textDirection: TextDirection.ltr)..layout();
      p2.paint(canvas, Offset(size.width / 2 + 8, 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
