import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'questions.dart';

void main() => runApp(const Z50000RevisionApp());

class ZColors {
  static const bg = Color(0xFF07121C);
  static const surface = Color(0xFF101E2A);
  static const surface2 = Color(0xFF142534);
  static const border = Color(0xFF263A4B);
  static const blue = Color(0xFF1685FF);
  static const blue2 = Color(0xFF4AA3FF);
  static const text = Color(0xFFF4F7FA);
  static const muted = Color(0xFFA8B5C2);
  static const green = Color(0xFF45D18A);
  static const red = Color(0xFFFF5B62);
  static const yellow = Color(0xFFF5C84B);
  static const cyan = Color(0xFF45CEDA);
  static const purple = Color(0xFF9B6CFF);
}

class Z50000RevisionApp extends StatelessWidget {
  const Z50000RevisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Z50000 Révision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ZColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ZColors.blue,
          brightness: Brightness.dark,
          surface: ZColors.surface,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: ZColors.bg,
          foregroundColor: ZColors.text,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomePage(),
    );
  }
}

const themeNames = {
  'general': 'Généralités & mécanique',
  'energy': 'Énergie électrique',
  'pneumatic': 'Pneumatique & traction',
  'braking': 'Freinage',
  'functions': 'Fonctions annexes',
};

const themeIcons = {
  'general': Icons.settings,
  'energy': Icons.bolt,
  'pneumatic': Icons.air,
  'braking': Icons.album,
  'functions': Icons.devices_other,
};

const themeColors = {
  'general': ZColors.blue2,
  'energy': ZColors.yellow,
  'pneumatic': ZColors.cyan,
  'braking': ZColors.red,
  'functions': ZColors.purple,
};

class AppStats {
  final int answered;
  final int correct;
  final int sessions;
  final int bestScore;

  const AppStats({this.answered = 0, this.correct = 0, this.sessions = 0, this.bestScore = 0});

  AppStats copyWith({int? answered, int? correct, int? sessions, int? bestScore}) => AppStats(
        answered: answered ?? this.answered,
        correct: correct ?? this.correct,
        sessions: sessions ?? this.sessions,
        bestScore: bestScore ?? this.bestScore,
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppStats stats = const AppStats();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      stats = AppStats(
        answered: p.getInt('answered') ?? 0,
        correct: p.getInt('correct') ?? 0,
        sessions: p.getInt('sessions') ?? 0,
        bestScore: p.getInt('bestScore') ?? 0,
      );
      loading = false;
    });
  }

  Future<void> _saveResult(int answered, int correct) async {
    final p = await SharedPreferences.getInstance();
    final next = stats.copyWith(
      answered: stats.answered + answered,
      correct: stats.correct + correct,
      sessions: stats.sessions + 1,
      bestScore: max(stats.bestScore, answered == 0 ? 0 : ((correct * 100) / answered).round()),
    );
    await p.setInt('answered', next.answered);
    await p.setInt('correct', next.correct);
    await p.setInt('sessions', next.sessions);
    await p.setInt('bestScore', next.bestScore);
    if (mounted) setState(() => stats = next);
  }

  Future<void> _start() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ModePage(stats: stats, onFinished: _saveResult)),
    );
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final percent = stats.answered == 0 ? 0 : ((stats.correct / stats.answered) * 100).round();
    return Scaffold(
      drawer: _AppDrawer(stats: stats),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    sliver: SliverToBoxAdapter(child: _homeHeader(context)),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                    sliver: SliverToBoxAdapter(child: _hero(context, percent)),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                    sliver: SliverToBoxAdapter(child: _sectionTitle('RÉVISER')),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    sliver: SliverToBoxAdapter(child: _quickModes(context)),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                    sliver: SliverToBoxAdapter(child: _sectionTitle('PROGRAMME')),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    sliver: SliverList.separated(
                      itemCount: themeNames.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final key = themeNames.keys.elementAt(i);
                        return _themeCard(context, key);
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                    sliver: SliverToBoxAdapter(child: _progressCard(context, percent)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _homeHeader(BuildContext context) => Row(
        children: [
          Builder(builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, size: 27),
                tooltip: 'Menu',
              )),
          const SizedBox(width: 2),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Z50000', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2.2)),
                Text('RÉVISION', style: TextStyle(fontSize: 11, letterSpacing: 4.4, color: ZColors.muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(border: Border.all(color: ZColors.border), borderRadius: BorderRadius.circular(6)),
            child: const Text('SNCF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ],
      );

  Widget _hero(BuildContext context, int percent) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZColors.border),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF102235), Color(0xFF0B1722)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: ZColors.blue.withOpacity(.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.train, color: ZColors.blue2, size: 29)),
              const SizedBox(width: 13),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CONNAÎTRE. COMPRENDRE. MAÎTRISER.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: .5)),
                SizedBox(height: 4),
                Text('200 questions issues du livret de formation Z50000.', style: TextStyle(color: ZColors.muted, fontSize: 12)),
              ])),
            ]),
            const SizedBox(height: 17),
            SizedBox(width: double.infinity, height: 48, child: FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.arrow_forward, size: 19),
              label: const Text('LANCER UNE SESSION', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .4)),
            )),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Text('${stats.answered} / 200 questions vues', style: const TextStyle(fontSize: 12, color: ZColors.muted))),
              Text('$percent %', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 7),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percent / 100, minHeight: 5)),
          ],
        ),
      );

  Widget _quickModes(BuildContext context) => Column(children: [
        _modeTile(context, QuizMode.rapid, Icons.bolt, 'Mode rapide', '10 questions', 'Révision express'),
        const SizedBox(height: 8),
        _modeTile(context, QuizMode.training, Icons.bar_chart, 'Mode entraînement', '20 questions', 'Correction et explications'),
        const SizedBox(height: 8),
        _modeTile(context, QuizMode.exam, Icons.description_outlined, 'Mode examen', '40 questions', 'Correction à la fin'),
        const SizedBox(height: 8),
        _modeTile(context, QuizMode.expert, Icons.emoji_events_outlined, 'Mode expert', '200 questions', 'Tout le programme, sans correction immédiate'),
      ]);

  Widget _modeTile(BuildContext context, QuizMode mode, IconData icon, String title, String count, String sub) => _TapCard(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SessionConfigPage(mode: mode, stats: stats, onFinished: _saveResult))),
        child: Row(children: [
          Container(width: 45, height: 45, decoration: BoxDecoration(color: ZColors.blue.withOpacity(.13), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: ZColors.blue2)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text('$count  •  $sub', style: const TextStyle(color: ZColors.muted, fontSize: 12))])),
          const Icon(Icons.chevron_right, color: ZColors.muted),
        ]),
      );

  Widget _themeCard(BuildContext context, String key) => _TapCard(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SessionConfigPage(mode: QuizMode.training, stats: stats, presetTheme: key, onFinished: _saveResult))),
        child: Row(children: [
          Container(width: 4, height: 47, decoration: BoxDecoration(color: themeColors[key], borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 13),
          Container(width: 43, height: 43, decoration: BoxDecoration(color: (themeColors[key] ?? ZColors.blue).withOpacity(.10), borderRadius: BorderRadius.circular(10)), child: Icon(themeIcons[key], color: themeColors[key])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(themeNames[key]!, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text('${questionBank.where((q) => q.theme == key).length} questions', style: const TextStyle(color: ZColors.muted, fontSize: 12))])),
          const Icon(Icons.chevron_right, color: ZColors.muted),
        ]),
      );

  Widget _progressCard(BuildContext context, int percent) => _TapCard(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProgressPage(stats: stats))),
        child: Row(children: [
          const Icon(Icons.bar_chart, color: ZColors.blue2),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Ma progression', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('${stats.sessions} sessions  •  meilleur score ${stats.bestScore} %', style: const TextStyle(color: ZColors.muted, fontSize: 12))])),
          Text('$percent %', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: ZColors.muted));
}

class _AppDrawer extends StatelessWidget {
  final AppStats stats;
  const _AppDrawer({required this.stats});
  @override Widget build(BuildContext context) => Drawer(
    backgroundColor: ZColors.surface,
    child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(20, 22, 20, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Z50000', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2)), Text('RÉVISION', style: TextStyle(fontSize: 10, letterSpacing: 4, color: ZColors.muted))])),
      const Divider(color: ZColors.border),
      ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Accueil'), onTap: () => Navigator.pop(context)),
      ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Ma progression'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ProgressPage(stats: stats))); }),
      const Spacer(),
      const Padding(padding: EdgeInsets.all(20), child: Text('Source : Livret d’études Z50000 Formation initiale\nETOF DP04001 — Version 02 — 17/09/2020', style: TextStyle(color: ZColors.muted, fontSize: 11, height: 1.4))),
    ])),
  );
}

class _TapCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TapCard({required this.child, required this.onTap});
  @override Widget build(BuildContext context) => Material(
    color: ZColors.surface,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: ZColors.border)), child: child)),
  );
}

class ModePage extends StatelessWidget {
  final AppStats stats;
  final Future<void> Function(int, int) onFinished;
  const ModePage({super.key, required this.stats, required this.onFinished});
  @override Widget build(BuildContext context) => SessionConfigPage(mode: QuizMode.training, stats: stats, onFinished: onFinished);
}

class SessionConfigPage extends StatefulWidget {
  final QuizMode mode;
  final AppStats stats;
  final String? presetTheme;
  final Future<void> Function(int, int) onFinished;
  const SessionConfigPage({super.key, required this.mode, required this.stats, this.presetTheme, required this.onFinished});
  @override State<SessionConfigPage> createState() => _SessionConfigPageState();
}

class _SessionConfigPageState extends State<SessionConfigPage> {
  String? selectedTheme;

  @override void initState() { super.initState(); selectedTheme = widget.presetTheme; }

  int get count => switch (widget.mode) { QuizMode.rapid => 10, QuizMode.training => 20, QuizMode.exam => 40, QuizMode.expert => questionBank.length };
  String get title => switch (widget.mode) { QuizMode.rapid => 'Mode rapide', QuizMode.training => 'Mode entraînement', QuizMode.exam => 'Mode examen', QuizMode.expert => 'Mode expert' };
  String get subtitle => switch (widget.mode) { QuizMode.rapid => '10 questions • révision express', QuizMode.training => '20 questions • correction immédiate', QuizMode.exam => '40 questions • correction à la fin', QuizMode.expert => 'Tout le programme • correction à la fin' };

  void _launch() {
    final pool = selectedTheme == null ? questionBank.toList() : questionBank.where((q) => q.theme == selectedTheme).toList();
    if (pool.isEmpty) return;
    final wanted = widget.mode == QuizMode.expert ? pool.length : min(count, pool.length);
    pool.shuffle(Random());
    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage(mode: widget.mode, questions: pool.take(wanted).toList(), onFinished: widget.onFinished)));
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 30), children: [
      Text('$count QUESTIONS', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: ZColors.muted, letterSpacing: 1.6)),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20),
      const Text('THÈME', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: ZColors.muted, letterSpacing: 1.6)),
      const SizedBox(height: 10),
      _themeChoice(null, 'Tout le programme', '${questionBank.length} questions', Icons.grid_view_rounded),
      ...themeNames.entries.map((e) => _themeChoice(e.key, e.value, '${questionBank.where((q) => q.theme == e.key).length} questions', themeIcons[e.key]!)),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: ZColors.surface, border: Border.all(color: ZColors.border), borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.info_outline, size: 19, color: ZColors.muted), const SizedBox(width: 10), Expanded(child: Text(widget.mode == QuizMode.training || widget.mode == QuizMode.rapid ? 'La correction et la référence du livret apparaissent après validation.' : 'Aucune correction ne sera affichée avant la fin de la session.', style: const TextStyle(color: ZColors.muted, fontSize: 12, height: 1.35)))])),
      const SizedBox(height: 18),
      SizedBox(height: 50, child: FilledButton.icon(onPressed: _launch, icon: const Icon(Icons.arrow_forward), label: Text('COMMENCER', style: const TextStyle(fontWeight: FontWeight.w800)))),
    ],
  );

  Widget _themeChoice(String? key, String title, String sub, IconData icon) {
    final selected = selectedTheme == key;
    final accent = key == null ? ZColors.blue2 : themeColors[key]!;
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: InkWell(onTap: () => setState(() => selectedTheme = key), borderRadius: BorderRadius.circular(10), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: selected ? ZColors.surface2 : ZColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? accent : ZColors.border, width: selected ? 1.3 : 1)), child: Row(children: [Icon(icon, color: accent), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), Text(sub, style: const TextStyle(color: ZColors.muted, fontSize: 12))])), Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? accent : ZColors.muted)]))));
  }
}

class QuizPage extends StatefulWidget {
  final QuizMode mode;
  final List<Question> questions;
  final Future<void> Function(int, int) onFinished;
  const QuizPage({super.key, required this.mode, required this.questions, required this.onFinished});
  @override State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int index = 0;
  int correctCount = 0;
  final Set<int> selected = {};
  final List<bool> results = [];
  bool locked = false;
  bool finished = false;

  Question get current => widget.questions[index];
  bool get immediate => widget.mode == QuizMode.rapid || widget.mode == QuizMode.training;
  bool get multi => current.multi || current.correct.length > 1;

  void _toggle(int i) {
    if (locked) return;
    setState(() {
      if (multi) {
        if (selected.contains(i)) selected.remove(i); else selected.add(i);
      } else {
        selected..clear()..add(i);
      }
    });
  }

  bool _isCorrect() => selected.length == current.correct.length && selected.containsAll(current.correct);

  Future<void> _validate() async {
    if (selected.isEmpty || locked) return;
    final ok = _isCorrect();
    if (ok) correctCount++;
    results.add(ok);
    if (immediate) {
      setState(() => locked = true);
    } else {
      _next();
    }
  }

  void _next() {
    if (index + 1 >= widget.questions.length) {
      setState(() => finished = true);
      widget.onFinished(widget.questions.length, correctCount);
      return;
    }
    setState(() { index++; selected.clear(); locked = false; });
  }

  @override Widget build(BuildContext context) {
    if (finished) return ResultPage(mode: widget.mode, total: widget.questions.length, correct: correctCount, questions: widget.questions, results: results, onHome: () => Navigator.of(context).popUntil((route) => route.isFirst));
    final pct = (index + 1) / widget.questions.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeLabel(widget.mode), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text('${index + 1} / ${widget.questions.length}', style: const TextStyle(fontFamily: 'monospace', color: ZColors.muted, fontSize: 12))))],
      ),
      body: Column(children: [
        LinearProgressIndicator(value: pct, minHeight: 4),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 20, 18, 20), children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: (themeColors[current.theme] ?? ZColors.blue).withOpacity(.12), borderRadius: BorderRadius.circular(6)), child: Text(themeNames[current.theme]!.toUpperCase(), style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: themeColors[current.theme], fontWeight: FontWeight.w800))),
            const Spacer(),
            Text(current.source, style: const TextStyle(fontFamily: 'monospace', color: ZColors.muted, fontSize: 11)),
          ]),
          const SizedBox(height: 22),
          Text(current.text, style: const TextStyle(fontSize: 23, height: 1.25, fontWeight: FontWeight.w800)),
          if (multi) ...[const SizedBox(height: 12), const Text('PLUSIEURS RÉPONSES POSSIBLES', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: ZColors.muted, letterSpacing: 1.1, fontWeight: FontWeight.w800))],
          const SizedBox(height: 20),
          ...List.generate(current.options.length, (i) => _option(i)),
          if (locked) ...[
            const SizedBox(height: 14),
            _feedback(_isCorrect()),
          ],
        ])),
        Container(padding: const EdgeInsets.fromLTRB(18, 10, 18, 18), decoration: const BoxDecoration(color: ZColors.bg, border: Border(top: BorderSide(color: ZColors.border))), child: SizedBox(height: 50, width: double.infinity, child: FilledButton.icon(
          onPressed: selected.isEmpty ? null : (locked ? _next : _validate),
          icon: Icon(locked ? Icons.arrow_forward : Icons.check),
          label: Text(locked ? 'QUESTION SUIVANTE' : 'VALIDER', style: const TextStyle(fontWeight: FontWeight.w800)),
        ))),
      ]),
    );
  }

  Widget _option(int i) {
    final isSelected = selected.contains(i);
    final isRight = current.correct.contains(i);
    Color border = ZColors.border;
    if (locked && isRight) border = ZColors.green;
    if (locked && isSelected && !isRight) border = ZColors.red;
    if (!locked && isSelected) border = ZColors.blue;
    return Padding(padding: const EdgeInsets.only(bottom: 9), child: InkWell(onTap: () => _toggle(i), borderRadius: BorderRadius.circular(9), child: AnimatedContainer(duration: const Duration(milliseconds: 130), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: isSelected ? ZColors.surface2 : ZColors.surface, border: Border.all(color: border, width: isSelected || locked ? 1.2 : 1), borderRadius: BorderRadius.circular(9)), child: Row(children: [
      Icon(multi ? (isSelected ? Icons.check_box : Icons.check_box_outline_blank) : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked), color: isSelected ? ZColors.blue2 : ZColors.muted, size: 22),
      const SizedBox(width: 11),
      Expanded(child: Text(current.options[i], style: const TextStyle(fontSize: 15, height: 1.25))),
      if (locked && isRight) const Icon(Icons.check, color: ZColors.green, size: 19),
    ]))));
  }

  Widget _feedback(bool ok) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: ok ? ZColors.green.withOpacity(.08) : ZColors.red.withOpacity(.08), border: Border.all(color: ok ? ZColors.green : ZColors.red), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? ZColors.green : ZColors.red), const SizedBox(width: 9), Text(ok ? 'Bonne réponse' : 'Réponse incorrecte', style: TextStyle(fontWeight: FontWeight.w800, color: ok ? ZColors.green : ZColors.red))]), const SizedBox(height: 10), Text(current.explanation, style: const TextStyle(height: 1.4, color: ZColors.text)), const SizedBox(height: 10), Text('Référence livret  •  ${current.source}', style: const TextStyle(fontFamily: 'monospace', color: ZColors.muted, fontSize: 11))]));

  String _modeLabel(QuizMode m) => switch (m) { QuizMode.rapid => 'Mode rapide', QuizMode.training => 'Entraînement', QuizMode.exam => 'Mode examen', QuizMode.expert => 'Mode expert' };
}

class ResultPage extends StatelessWidget {
  final QuizMode mode;
  final int total;
  final int correct;
  final List<Question> questions;
  final List<bool> results;
  final VoidCallback onHome;
  const ResultPage({super.key, required this.mode, required this.total, required this.correct, required this.questions, required this.results, required this.onHome});
  @override Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();
    final errors = <int>[];
    for (var i = 0; i < results.length; i++) { if (!results[i]) errors.add(i); }
    return Scaffold(appBar: AppBar(title: const Text('Session terminée', style: TextStyle(fontWeight: FontWeight.w800))), body: ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 30), children: [
      Center(child: SizedBox(width: 185, height: 185, child: Stack(alignment: Alignment.center, children: [SizedBox.expand(child: CircularProgressIndicator(value: percent / 100, strokeWidth: 10, backgroundColor: ZColors.surface2)), Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('$correct / $total', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text('$percent %', style: const TextStyle(fontFamily: 'monospace', color: ZColors.muted))])]))),
      const SizedBox(height: 20),
      Center(child: Text(_resultTitle(percent), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
      const SizedBox(height: 6),
      Center(child: Text(_resultSubtitle(percent), style: const TextStyle(color: ZColors.muted))),
      const SizedBox(height: 22),
      Row(children: [Expanded(child: _metric(Icons.check, '$correct', 'bonnes réponses', ZColors.green)), const SizedBox(width: 8), Expanded(child: _metric(Icons.close, '${total - correct}', 'erreurs', ZColors.red))]),
      const SizedBox(height: 16),
      if (errors.isNotEmpty) ...[
        const Text('À REVOIR', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: ZColors.muted, letterSpacing: 1.6, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...errors.map((i) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: ZColors.surface, border: Border.all(color: ZColors.border), borderRadius: BorderRadius.circular(9)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${i + 1}. ${questions[i].text}', style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25)), const SizedBox(height: 6), Text('Correct : ${questions[i].correct.map((n) => questions[i].options[n]).join(' • ')}', style: const TextStyle(color: ZColors.green, fontSize: 12)), Text('${questions[i].explanation}  (${questions[i].source})', style: const TextStyle(color: ZColors.muted, fontSize: 11, height: 1.35))]))),
      ],
      const SizedBox(height: 12),
      SizedBox(height: 50, child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.refresh), label: const Text('REFAIRE UNE SESSION', style: TextStyle(fontWeight: FontWeight.w800)))),
      const SizedBox(height: 8),
      TextButton.icon(onPressed: onHome, icon: const Icon(Icons.home_outlined), label: const Text('Retour à l’accueil')),
    ]));
  }
  Widget _metric(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZColors.surface,
        border: Border.all(color: ZColors.border),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: ZColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _resultTitle(int p) => p >= 90 ? 'Excellent résultat !' : p >= 75 ? 'Bon travail !' : p >= 60 ? 'Bonne progression' : 'À renforcer';
  String _resultSubtitle(int p) => p >= 75 ? 'Continuez à consolider les points techniques.' : 'Relisez les références indiquées et recommencez.';
}

class ProgressPage extends StatelessWidget {
  final AppStats stats;
  const ProgressPage({super.key, required this.stats});
  @override Widget build(BuildContext context) {
    final p = stats.answered == 0 ? 0 : ((stats.correct / stats.answered) * 100).round();
    return Scaffold(appBar: AppBar(title: const Text('Ma progression', style: TextStyle(fontWeight: FontWeight.w800))), body: ListView(padding: const EdgeInsets.all(18), children: [
      _TapCard(onTap: () {}, child: Row(children: [const Icon(Icons.bar_chart, color: ZColors.blue2, size: 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Maîtrise globale', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${stats.answered} / 200 questions vues', style: const TextStyle(color: ZColors.muted, fontSize: 12))])), Text('$p %', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900))]),
      ),
      const SizedBox(height: 12),
      ...themeNames.entries.map((e) {
        final total = questionBank.where((q) => q.theme == e.key).length;
        final viewed = stats.answered == 0 ? 0 : min(total, (stats.answered * total / 200).round());
        final pct = total == 0 ? 0 : ((viewed / total) * 100).round();
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: _TapCard(onTap: () {}, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(themeIcons[e.key], color: themeColors[e.key], size: 19), const SizedBox(width: 9), Expanded(child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w700))), Text('$pct %', style: const TextStyle(fontFamily: 'monospace', color: ZColors.muted, fontSize: 11))]), const SizedBox(height: 9), ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: pct / 100, minHeight: 5, color: themeColors[e.key])), const SizedBox(height: 6), Text('$viewed / $total questions', style: const TextStyle(color: ZColors.muted, fontSize: 11))])));
      }),
      const SizedBox(height: 8),
      _TapCard(onTap: () {}, child: Row(children: [const Icon(Icons.assessment_outlined, color: ZColors.blue2), const SizedBox(width: 10), Expanded(child: Text('${stats.sessions} sessions réalisées\nMeilleur score : ${stats.bestScore} %', style: const TextStyle(height: 1.5))), const Icon(Icons.chevron_right, color: ZColors.muted)])),
    ]));
  }
}
