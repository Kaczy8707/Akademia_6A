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
          text: 'Przeanalizuj poniższą autentyczną mapę Rzeczypospolitej po Unii Lubelskiej (1569 r.). Który obszar stanowił Koronę Królestwa Polskiego?',
          imageAsset: 'assets/mapy/unia_lubelska.png',
          options: [
            'Obszar zachodni ze stolicą w Krakowie i Warszawą',
            'Wielkie Księstwo Litewskie na wschodzie',
            'Inflanty'
          ],
          correctAnswer: 'Obszar zachodni ze stolicą w Krakowie i Warszawą',
          hint: 'Korona Polska to zachodnia część państwa.',
        ),
      ];
    } else if (chapter.contains('Środowisko przyrodnicze')) {
      q = [
        Question(
          text: 'Przeanalizuj poniższą mapę fizyczną Europy. Który łańcuch górski stanowi wschodnią granicę Europy z Azją?',
          imageAsset: 'assets/mapy/europa_fizyczna.png',
          options: ['Góry Ural', 'Alpy', 'Karpaty'],
          correctAnswer: 'Góry Ural',
          hint: 'Góry Ural rozdzielają Europę i Azję.',
        ),
      ];
    } else if (chapter.contains('Świat zwierząt')) {
      q = [
        Question(
          text: 'Przeanalizuj poniższą ilustrację tkanki nerwowej. Które wypustki odbierają sygnały i przewodzą je do ciała komórki?',
          imageAsset: 'assets/mapy/neuron.png',
          options: ['Dendryty', 'Akson', 'Osłonka mielinowa'],
          correctAnswer: 'Dendryty',
          hint: 'Dendryty to krótkie, rozgałęzione wypustki.',
        ),
      ];
    } else {
      q = [
        Question(
          text: 'Przeanalizuj poniższą mapę z okresu wojen napoleońskich (1812 r.). Jak nazywało się państwo polskie utworzone przez Napoleona w 1807 r.?',
          imageAsset: 'assets/mapy/napoleon.png',
          options: ['Księstwo Warszawskie', 'Królestwo Polskie', 'Rzeczpospolita Obojga Narodów'],
          correctAnswer: 'Księstwo Warszawskie',
          hint: 'Napoleon utworzył Księstwo Warszawskie w 1807 r.',
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
        title: const Text('⚡ AKADEMIA SP7 - REALNE MAPY', style: TextStyle(fontWeight: FontWeight.bold)),
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
  final String? imageAsset;
  final List<String> options;
  final String correctAnswer;
  final String hint;

  Question({
    required this.text,
    this.imageAsset,
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
                        if (q.imageAsset != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              q.imageAsset!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                padding: const EdgeInsets.all(16),
                                color: Colors.black26,
                                child: const Text('Błąd ładowania mapy lokalnej', style: TextStyle(color: Colors.redAccent)),
                              ),
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
