import 'dartd:math';
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

  // PEŁNY PROGRAM DLA KLASY 6 (WSZYSTKIE ROZDZIAŁY I DZIAŁY)
  final Map<String, SubjectData> _program = {
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
    'biologia': SubjectData('Biologia (Puls Życia 6)', '🌿', [
      'Dział I: Świat zwierząt',
      'Dział II: Od parzydełkowców do pierścienic',
      'Dział III: Stawonogi i mięczaki',
      'Dział IV: Kręgowce zmiennocieplne',
      'Dział V: Kręgowce stałocieplne',
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
    final rand = Random();

    if (_selectedSubject == 'matematyka') {
      for (int i = 1; i <= 10; i++) {
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
            hint: 'Wykonaj mnożenie pisemne lub w pamięci.',
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
        Question(
          text: 'Zgromadzenie szlachty z danego województwa, na którym wybierano posłów na Sejm Walny to:',
          options: ['Sejmik ziemski', 'Trybunał Główny', 'Senat'],
          correctAnswer: 'Sejmik ziemski',
          hint: 'Sejmiki ziemskie odbywały się lokalnie.',
        ),
        Question(
          text: 'Ustrój Rzeczypospolitej od XVI wieku, w którym szlachta współrządziła państwem z królem, nazywamy:',
          options: ['Demokracją szlachecką', 'Monarchią absolutną', 'Republiką miejską'],
          correctAnswer: 'Demokracją szlachecką',
          hint: 'Demokracja szlachecka.',
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
        Question(
          text: 'Wszystkie południki na globusie mają:',
          options: ['Tę samą długość', 'Różną długość', 'Zmienną długość'],
          correctAnswer: 'Tę samą długość',
          hint: 'Południki łączą oba bieguny, więc są równe.',
        ),
        Question(
          text: 'Wpisz symbol literowy kierunku geograficznego dla szerokości północnej (np. N):',
          isOpen: true,
          correctAnswer: 'N',
          hint: 'N - North.',
        ),
      ];
    } else {
      for (int i = 1; i <= 5; i++) {
        q.add(Question(
          text: 'Zadanie $i/5 z działu "$chapter": Które stwierdzenie najlepiej opisuje analizowane pojęcie?',
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
                        Text(e.value.icon, style: const TextStyle(fontSize: 44)),
                        const SizedBox(height: 10),
                        Text(
                          e.value.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
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
          Text('${subj.title} - Wybierz dział:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: subj.chapters.length,
              itemBuilder: (context, index) {
                final chap = subj.chapters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(chap, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
              ElevatedButton(onPressed: widget.onCancel, child: const Text('Anuluj')),
              Expanded(
                child: Text(
                  widget.chapterTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                        Text('Zadanie ${qIdx + 1}:${q.text}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (q.mapType != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            height: 200,
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
                        if (q.isOpen) ...[
                          TextField(
                            controller: _controllers.putIfAbsent(qIdx, () => TextEditingController()),
                            onChanged: (val) {
                              _userAnswers[qIdx] = val.trim();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Wpisz odpowiedź...',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF0F172A),
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
                final ans = _userAnswers[i] ?? '';
                if (ans.toLowerCase() == widget.questions[i].correctAnswer.toLowerCase()) {
                  score++;
                }
              }
              widget.onComplete(score);
            },
            child: const Text('Sprawdź odpowiedzi i odbierz XP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        ..lineTo(size.width * 0.42
