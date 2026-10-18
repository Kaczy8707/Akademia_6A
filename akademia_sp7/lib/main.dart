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
  int _totalTests = 0;
  int _totalQuestionsAnswered = 0;
  List<Question> _reviewPool = [];

  String? _selectedSubject;
  String? _selectedChapter;
  List<Question> _currentQuiz = [];
  bool _isReviewMode = false;

  final Map<String, SubjectData> _program = {
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

    if (_selectedSubject == 'matematyka') {
      for (int i = 1; i <= 5; i++) {
        if (chapter.contains('Prędkość')) {
          int v = (rand.nextInt(6) + 4) * 10;
          int t = rand.nextInt(4) + 2;
          int s = v * t;
          q.add(Question(
            text: 'Pojazd jedzie ze stałą prędkością $v km/h przez$t godziny. Jaką drogę pokona?',
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
            'Prawidłowa definicja zgodna z programem Klasy 6',
            'Błędna interpretacja zagadnienia',
            'Pojęcie niedotyczące tego działu'
          ],
          correctAnswer: 'Prawidłowa definicja zgodna z programem Klasy 6',
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
      _selectedChapter = "Magazyn Powtórek (Zadania Problematyczne)";
      _currentQuiz = List.from(_reviewPool);
    });
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.cyan),
            SizedBox(width: 8),
            Text('Statystyki Nauki'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Text('⭐', style: TextStyle(fontSize: 24)),
              title: const Text('Punkty XP'),
              trailing: Text('$_userXP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(
              leading: const Text('📝', style: TextStyle(fontSize: 24)),
              title: const Text('Ukończone Testy'),
              trailing: Text('$_totalTests', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(
              leading: const Text('✅', style: TextStyle(fontSize: 24)),
              title: const Text('Przeanalizowane Zadania'),
              trailing: Text('$_totalQuestionsAnswered', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(
              leading: const Text('⚠️', style: TextStyle(fontSize: 24)),
              title: const Text('Do powtórki'),
              trailing: Text('${_reviewPool.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 18)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ AKADEMIA SP7 - KLASA 6', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.cyan),
            onPressed: _showStatsDialog,
            tooltip: 'Statystyki',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            Card(
              color: const Color(0xFF332A15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.amber),
              ),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
                title: Text('Powtórki do zrobienia: ${_reviewPool.length} zadań', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Kliknij, aby przećwiczyć trudniejsze pytania'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
                onTap: _startReviewMode,
              ),
            ),
            const SizedBox(height: 16),
          ],
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
                    borderRadius: BorderRadius
