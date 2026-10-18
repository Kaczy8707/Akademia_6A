import 'dart:convert';
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
      title: 'Akademia SP7 - Klasa 1-6',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4F46E5),
          secondary: Color(0xFF0891B2),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1B4B),
          foregroundColor: Colors.white,
          elevation: 2,
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
  int _totalTests = 0;
  int _totalQuestionsAnswered = 0;
  List<Question> _reviewPool = [];

  String? _selectedSubject;
  String? _selectedChapter;
  List<Question> _currentQuiz = [];
  bool _isReviewMode = false;

  final Map<String, SubjectData> _program = {
    'angielski': SubjectData('Język Angielski', '🇬🇧', [
      'Klasy 1-3: Podstawowe Słownictwo (Kolory, Zwierzęta, Rodzina)',
      'Klasy 1-3: Liczby i Czasownik "to be"',
      'Klasa 4: Czas Present Simple & Present Continuous',
      'Klasa 5: Czas Past Simple & Czasowniki Nieregularne',
      'Klasa 6: Czas Present Perfect, Stopniowanie Przymiotników i Zwroty',
    ]),
    'biologia': SubjectData('Biologia (Puls Życia 6)', '🌿', [
      'Dział I: Świat zwierząt',
      'Dział II: Od parzydełkowców do pierścienic',
      'Dział III: Stawonogi i mięczaki',
      'Dział IV: Kręgowce zmiennocieplne',
      'Dział V: Kręgowce stałocieplne',
    ]),
    'historia': SubjectData('Historia (Wczoraj i dziś 6)', '⚔️', [
      'Rozdział I: Narodziny nowożytnego świata',
      'Rozdział II: W Rzeczypospolitej szlacheckiej',
      'Rozdział III: W obronie granic Rzeczypospolitej',
      'Rozdział IV: Od absolutyzmu do republiki',
      'Rozdział V: Upadek Rzeczypospolitej',
      'Rozdział VI: Rewolucja francuska i okres napoleoński',
    ]),
    'geografia': SubjectData('Geografia (Planeta Nowa 6)', '🌍', [
      'Rozdział 1: Współrzędne geograficzne',
      'Rozdział 2: Ruchy Ziemi',
      'Rozdział 3: Środowisko przyrodnicze i ludność Europy',
      'Rozdział 4: Gospodarka Europy',
      'Rozdział 5: Sąsiedzi Polski',
    ]),
    'matematyka': SubjectData('Matematyka (M+ 6)', '📐', [
      'Dział 1: Liczby naturalne i ułamki',
      'Dział 2: Figury na płaszczyźnie',
      'Dział 3: Liczby na co dzień',
      'Dział 4: Prędkość, droga, czas',
      'Dział 5: Pola wielokątów',
      'Dział 6: Procenty',
      'Dział 7: Liczby dodatnie i ujemne',
      'Dział 8: Wyrażenia algebraiczne i równania',
      'Dział 9: Figury przestrzenne',
    ]),
    'technika': SubjectData('Technika (Jak to działa? 6)', '🛠️', [
      'Dział I: Technika w najbliższym otoczeniu',
      'Dział II: Rysunek techniczny',
      'Dział III: ABC współczesnej techniki',
    ]),
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userXP = prefs.getInt('user_xp') ?? 0;
      _totalTests = prefs.getInt('total_tests') ?? 0;
      _totalQuestionsAnswered = prefs.getInt('total_questions') ?? 0;
      
      final String? reviewJson = prefs.getString('review_pool');
      if (reviewJson != null) {
        final List<dynamic> decoded = jsonDecode(reviewJson);
        _reviewPool = decoded.map((item) => Question.fromJson(item)).toList();
      }
    });
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_xp', _userXP);
    await prefs.setInt('total_tests', _totalTests);
    await prefs.setInt('total_questions', _totalQuestionsAnswered);
    
    final String encoded = jsonEncode(_reviewPool.map((q) => q.toJson()).toList());
    await prefs.setString('review_pool', encoded);
  }

  void _addWrongQuestionToReview(Question q) {
    if (!_reviewPool.any((item) => item.text == q.text)) {
      _reviewPool.add(q);
    }
  }

  void _removeCorrectQuestionFromReview(Question q) {
    _reviewPool.removeWhere((item) => item.text == q.text);
  }

  void _generateQuiz(String chapter) {
    _isReviewMode = false;
    List<Question> q = [];
    final rand = Random();

    if (_selectedSubject == 'angielski') {
      if (chapter.contains('Klasy 1-3')) {
        q = [
          Question(
            text: 'Wybierz poprawne tłumaczenie słowa "Pies":',
            options: ['Dog', 'Cat', 'Bird', 'Fish'],
            correctAnswer: 'Dog',
            hint: 'Dog to pies.',
          ),
          Question(
            text: 'Uzupełnij zdanie: I ___ a student.',
            options: ['am', 'is', 'are', 'be'],
            correctAnswer: 'am',
            hint: 'Dla "I" używamy formy "am".',
          ),
          Question(
            text: 'Wpisz po angielsku słowo "Jabłko":',
            isOpen: true,
            correctAnswer: 'apple',
            hint: 'An apple.',
          ),
        ];
      } else if (chapter.contains('Klasa 5') || chapter.contains('Past Simple')) {
        q = [
          Question(
            text: 'Jaka jest II forma (Past Simple) od czasownika "go"?',
            options: ['went', 'gone', 'goed', 'going'],
            correctAnswer: 'went',
            hint: 'Go - went - gone.',
          ),
          Question(
            text: 'Jaka jest II forma (Past Simple) od czasownika "see"?',
            options: ['saw', 'seen', 'seed', 'seeing'],
            correctAnswer: 'saw',
            hint: 'See - saw - seen.',
          ),
          Question(
            text: 'Przetłumacz na angielski czasownik "kupić" w Past Simple (II forma):',
            isOpen: true,
            correctAnswer: 'bought',
            hint: 'Buy -> bought.',
          ),
        ];
      } else {
        q = [
          Question(
            text: 'Uzupełnij zdanie w czasie Present Perfect: She has ___ (finish) her homework.',
            options: ['finished', 'finishing', 'finishes', 'finish'],
            correctAnswer: 'finished',
            hint: 'W Present Perfect po "have/has" dajemy III formę (-ed).',
          ),
          Question(
            text: 'Stopień wyższy od przymiotnika "good" to:',
            options: ['better', 'gooder', 'best', 'more good'],
            correctAnswer: 'better',
            hint: 'Good -> better -> the best.',
          ),
        ];
      }
    } else if (_selectedSubject == 'matematyka') {
      for (int i = 1; i <= 5; i++) {
        if (chapter.contains('Prędkość')) {
          int v = (rand.nextInt(6) + 4) * 10;
          int t = rand.nextInt(4) + 2;
          int s = v * t;
          q.add(Question(
            text: 'Pojazd jedzie ze stałą prędkością $v km/h przez $t godziny. Jaką drogę pokona?',
            options: ['$s km', '${s + 20} km', '${s - 15} km', '${v + t} km'],
            correctAnswer: '$s km',
            hint: 'Wzór na drogę: s = v * t.',
          ));
        } else if (chapter.contains('Pola wielokątów')) {
          int a = rand.nextInt(8) + 3;
          int h = rand.nextInt(6) + 2;
          int area = (a * h) ~/ 2;
          q.add(Question(
            text: 'Oblicz pole trójkąta o podstawie a = $a cm i wysokości h = $h cm:',
            options: ['$area cm²', '${a * h} cm²', '${area + 4} cm²', '${area * 2} cm²'],
            correctAnswer: '$area cm²',
            hint: 'Wzór na pole trójkąta: P = (a * h) / 2.',
          ));
        } else {
          int a = rand.nextInt(20) + 5;
          int b = rand.nextInt(15) + 3;
          int ans = a * b;
          q.add(Question(
            text: 'Oblicz wartość wyrażenia z działu "$chapter": $a * $b =',
            options: ['$ans', '${ans + 10}', '${ans - 5}', '${ans + 12}'],
            correctAnswer: '$ans',
            hint: 'Wykonaj mnożenie.',
          ));
        }
      }
    } else if (chapter.contains('Rzeczypospolitej szlacheckiej')) {
      q = [
        Question(
          text: 'Przeanalizuj poniższą mapę historyczną przedstawiającą Rzeczpospolitą Obojga Narodów po Unii Lubelskiej (1569 r.). Który obszar oznaczono literą A?',
          mapType: 'unia_lubelska',
          options: ['Korona Królestwa Polskiego', 'Wielkie Księstwo Litewskie', 'Prusy Książęce'],
          correctAnswer: 'Korona Królestwa Polskiego',
          hint: 'Korona Polska to zachodnia część państwa ze stolicą w Krakowie i Warszawą.',
        ),
        Question(
          text: 'Który stan w Rzeczypospolitej posiadał wyłączne prawo do posiadania ziemi i udziału w sejmach?',
          options: ['Szlachta', 'Mieszczaństwo', 'Chłopstwo'],
          correctAnswer: 'Szlachta',
          hint: 'Szlachta miała pełne prawa polityczne.',
        ),
        Question(
          text: 'Jak nazywała się wolna elekcja, na której cała szlachta mogła osobiście wybierać króla?',
          isOpen: true,
          correctAnswer: 'viritim',
          hint: 'Elekcja viritim.',
        ),
      ];
    } else if (chapter.contains('Współrzędne geograficzne')) {
      q = [
        Question(
          text: 'Przeanalizuj poniższy schemat siatki geograficznej. Od którego południka mierzymy długość geograficzną (0°)?',
          mapType: 'siatka_geo',
          options: ['Południka Greenwich (0°)', 'Równika (0°)', 'Zwrotnika Raka'],
          correctAnswer: 'Południka Greenwich (0°)',
          hint: 'Południk 0° przechodzi przez obserwatorium w Greenwich.',
        ),
        Question(
          text: 'Równik (0°) dzieli Ziemię na dwie półkule:',
          mapType: 'siatka_geo',
          options: ['Północną (N) i Południową (S)', 'Wschodnią (E) i Zachodnią (W)', 'Tylko wschodnią'],
          correctAnswer: 'Północną (N) i Południową (S)',
          hint: 'Równik wyznacza półkule północną i południową.',
        ),
      ];
    } else {
      for (int i = 1; i <= 5; i++) {
        q.add(Question(
          text: 'Zadanie $i/5 z działu "$chapter": Które stwierdzenie jest prawdziwe?',
          options: [
            'Prawidłowa definicja zgodna z programem szkolnym',
            'Błędna interpretacja zagadnienia',
            'Pojęcie niedotyczące tego działu'
          ],
          correctAnswer: 'Prawidłowa definicja zgodna z programem szkolnym',
          hint: 'Przeanalizuj podsumowanie działu w podręczniku.',
        ));
      }
    }

    setState(() {
      _selectedChapter = chapter;
      _currentQuiz = q;
    });
  }

  void _startReviewMode() {
    if (_reviewPool.isEmpty) return;
    setState(() {
      _isReviewMode = true;
      _selectedChapter = "Magazyn Powtórek";
      _currentQuiz = List.from(_reviewPool);
    });
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.insights, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('Twoje Statystyki', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Text('⭐', style: TextStyle(fontSize: 24)),
              title: const Text('Punkty XP', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text('$_userXP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFD97706))),
            ),
            ListTile(
              leading: const Text('📝', style: TextStyle(fontSize: 24)),
              title: const Text('Ukończone Testy', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text('$_totalTests', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4F46E5))),
            ),
            ListTile(
              leading: const Text('✅', style: TextStyle(fontSize: 24)),
              title: const Text('Przeanalizowane Zadania', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text('$_totalQuestionsAnswered', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF059669))),
            ),
            ListTile(
              leading: const Text('⚠️', style: TextStyle(fontSize: 24)),
              title: const Text('Do powtórki', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text('${_reviewPool.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 18)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ AKADEMIA SP7', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights, color: Colors.amberAccent),
            onPressed: _showStatsDialog,
            tooltip: 'Statystyki',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 1.5),
            ),
            child: Text('⭐ $_userXP XP', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent)),
          )
        ],
      ),
      body: _selectedChapter != null
          ? QuizScreen(
              chapterTitle: _selectedChapter!,
              questions: _currentQuiz,
              isReviewMode: _isReviewMode,
              onComplete: (correctQuestions, wrongQuestions) {
                setState(() {
                  _userXP += correctQuestions.length * 10;
                  _totalTests += 1;
                  _totalQuestionsAnswered += (correctQuestions.length + wrongQuestions.length);

                  for (var q in wrongQuestions) {
                    _addWrongQuestionToReview(q);
                  }
                  for (var q in correctQuestions) {
                    _removeCorrectQuestionFromReview(q);
                  }
                  _saveStats();
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
          if (_reviewPool.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: ListTile(
                leading: const Icon(Icons.bolt, color: Color(0xFFD97706), size: 36),
                title: Text('Powtórki: ${_reviewPool.length} zadań do opanowania', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF78350F))),
                subtitle: const Text('Przećwicz pytania, w których pojawił się błąd', style: TextStyle(color: Color(0xFF92400E))),
                trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD97706), size: 18),
                onTap: _startReviewMode,
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text('Wybierz przedmiot:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.extrabold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _program.entries.map((e) {
                return Card(
                  elevation: 2,
                  shadowColor: const Color(0xFF64748B).withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSubject = e.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(e.value.icon, style: const TextStyle(fontSize: 44)),
                          const SizedBox(height: 10),
                          Text(
                            e.value.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _selectedSubject = null;
              });
            },
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Powrót do przedmiotów', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 18),
          Text('${subj.title} - Wybierz dział:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.extrabold, color: Color(0xFF0F172A))),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              itemCount: subj.chapters.length,
              itemBuilder: (context, index) {
                final chap = subj.chapters[index];
                return Card(
                  elevation: 1.5,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    title: Text(chap, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                    trailing: const Icon(Icons.play_circle_fill, color: Color(0xFF4F46E5), size: 24),
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
  final bool isOpen;
  final List<String>? options;
  final String correctAnswer;
  final String hint;

  Question({
    required this.text,
    this.mapType,
    this.isOpen = false,
    this.options,
    required this.correctAnswer,
    required this.hint,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'mapType': mapType,
        'isOpen': isOpen,
        'options': options,
        'correctAnswer': correctAnswer,
        'hint': hint,
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        text: json['text'],
        mapType: json['mapType'],
        isOpen: json['isOpen'] ?? false,
        options: json['options'] != null ? List<String>.from(json['options']) : null,
        correctAnswer: json['correctAnswer'],
        hint: json['hint'],
      );
}

class QuizScreen extends StatefulWidget {
  final String chapterTitle;
  final List<Question> questions;
  final bool isReviewMode;
  final Function(List<Question> correct, List<Question> wrong) onComplete;
  final VoidCallback onCancel;

  const QuizScreen({
    super.key,
    required this.chapterTitle,
    required this.questions,
    this.isReviewMode = false,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, String> _userAnswers = {};
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Anuluj'),
              ),
              Expanded(
                child: Text(
                  widget.chapterTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zadanie ${qIdx + 1}: ${q.text}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                        if (q.mapType != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            height: 190,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: CustomPaint(
                              painter: MapPainter(mapType: q.mapType!),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (q.isOpen) ...[
                          TextField(
                            controller: _controllers.putIfAbsent(qIdx, () => TextEditingController()),
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                            onChanged: (val) {
                              _userAnswers[qIdx] = val.trim();
                            },
                            decoration: InputDecoration(
                              hintText: 'Wpisz odpowiedź...',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                          ),
                        ] else if (q.options != null) ...[
                          ...q.options!.map((opt) {
                            final isSelected = _userAnswers[qIdx] == opt;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _userAnswers[qIdx] = opt;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            onPressed: () {
              List<Question> correct = [];
              List<Question> wrong = [];

              for (int i = 0; i < widget.questions.length; i++) {
                final ans = _userAnswers[i] ?? '';
                if (ans.toLowerCase() == widget.questions[i].correctAnswer.toLowerCase()) {
                  correct.add(widget.questions[i]);
                } else {
                  wrong.add(widget.questions[i]);
                }
              }
              widget.onComplete(correct, wrong);
            },
            child: const Text('Sprawdź odpowiedzi i odbierz XP', style: TextStyle(fontWeight: FontWeight.extrabold, fontSize: 16, color: Colors.white)),
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

      const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13);
      final painterKorona = TextPainter(text: const TextSpan(text: 'KORONA (A)', style: textStyle), textDirection: TextDirection.ltr)..layout();
      painterKorona.paint(canvas, Offset(size.width * 0.18, size.height * 0.45));

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
