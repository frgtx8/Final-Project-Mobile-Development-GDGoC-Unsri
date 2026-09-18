import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/env/env_config.dart';
import '../../players/domain/player.dart';
import '../domain/squad_synergy_report.dart';

class GeminiAIService {
  GenerativeModel? _jsonModel;
  GenerativeModel? _textModel;
  GenerativeModel? _fallbackTextModel;
  GenerativeModel? _fallbackJsonModel;

  GeminiAIService() {
    if (EnvConfig.isGeminiConfigured) {
      // Primary model: gemini-3.6-flash
      _jsonModel = GenerativeModel(
        model: 'gemini-3.6-flash',
        apiKey: EnvConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.1,
          maxOutputTokens: 2500,
        ),
      );

      _textModel = GenerativeModel(
        model: 'gemini-3.6-flash',
        apiKey: EnvConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 3000,
        ),
      );

      // Fallback model: gemini-3.5-flash for redundancy if 3.6 encounters temporary spikes (503)
      _fallbackTextModel = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: EnvConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 3000,
        ),
      );

      _fallbackJsonModel = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: EnvConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.1,
          maxOutputTokens: 2500,
        ),
      );
    }
  }

  /// FITUR KUNCI: AI Squad Doctor & Synergy Analyzer
  Future<SquadSynergyReport> analyzeSquadSynergy({
    required String formation,
    required String teamPlaystyle,
    required Map<String, Player> lineUpWithPositions,
  }) async {
    final prompt = _buildSquadAnalysisPrompt(
      formation: formation,
      teamPlaystyle: teamPlaystyle,
      lineUpWithPositions: lineUpWithPositions,
    );

    // If Gemini API is configured, call live Gemini with retry on transient spikes
    if (_jsonModel != null) {
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          final content = [Content.text(prompt)];
          final response = await _jsonModel!
              .generateContent(content)
              .timeout(const Duration(seconds: 25));

          final responseText = response.text;
          if (responseText != null && responseText.isNotEmpty) {
            final cleanJson = _extractJson(responseText);
            final Map<String, dynamic> data =
                jsonDecode(cleanJson) as Map<String, dynamic>;
            return SquadSynergyReport.fromJson(data);
          }
        } catch (e) {
          if (attempt == 0) {
            await Future.delayed(const Duration(milliseconds: 1000));
          }
        }
      }

      // Try fallback model
      if (_fallbackJsonModel != null) {
        try {
          final response = await _fallbackJsonModel!
              .generateContent([Content.text(prompt)])
              .timeout(const Duration(seconds: 25));

          final responseText = response.text;
          if (responseText != null && responseText.isNotEmpty) {
            final cleanJson = _extractJson(responseText);
            final Map<String, dynamic> data =
                jsonDecode(cleanJson) as Map<String, dynamic>;
            return SquadSynergyReport.fromJson(data);
          }
        } catch (_) {}
      }
    }

    // Heuristic Engine: analyzes real eFootball tactical synergy with out-of-position detection
    return _analyzeWithTacticalRules(
      formation: formation,
      teamPlaystyle: teamPlaystyle,
      lineUpWithPositions: lineUpWithPositions,
    );
  }

  /// FITUR AI KEDUA: AI Player Scout & Progression Recommender
  Future<String> askPlayerScoutAdvice({
    required String query,
    required String currentPlaystyle,
    List<Player> catalog = const [],
  }) async {
    if (_textModel != null) {
      final qLower = query.toLowerCase();

      // Find candidates from database catalog matching playstyle or query
      final relevantFromCatalog = catalog.where((p) {
        return qLower.contains(p.playerPlaystyle.toLowerCase()) ||
            qLower.contains(p.primaryPosition.toLowerCase()) ||
            p.secondaryPositions
                .any((s) => qLower.contains(s.toLowerCase()));
      }).take(8).map((p) =>
          '- ${p.name} (${p.club}) - ${p.primaryPosition} [Playstyle: ${p.playerPlaystyle}, OVR: ${p.overallRating}]').join('\n');

      final catalogContext = relevantFromCatalog.isNotEmpty
          ? '\n\nDaftar Pemain Tersedia di Database Aplikasi:\n$relevantFromCatalog\n'
          : '';

      final prompt = '''
Anda adalah Asisten Scout & Coach Profesional untuk game eFootball 2024/2025.
Gaya Main Tim Pengguna saat ini: $currentPlaystyle
Pertanyaan Pengguna: "$query"
$catalogContext
Kamus Istilah Gaya Main eFootball (PENTING):
- Pemburu Celah / Penyerang Lubang = Hole Player (AMF/SS/CMF yang aktif merangsek ke kotak penalti dari lini kedua, contoh: Jude Bellingham, Florian Wirtz, Bruno Fernandes, Antoine Griezmann, Cole Palmer, Dani Olmo)
- Pemburu Gol = Goal Poacher (CF/SS penyerang murni penuntas peluang di garis offside, contoh: Erling Haaland, Kylian Mbappé, Victor Osimhen, Lautaro Martínez, Viktor Gyökeres)
- Gelandang Jangkar = Anchor Man (DMF murni penyeimbang bertahan di depan bek, contoh: Rodri, Aurélien Tchouaméni, Declan Rice)
- Pembangun Serangan = Build Up (CB pengumpan dari lini belakang, contoh: Virgil van Dijk, William Saliba, Rúben Dias)
- Perusak = The Destroyer (CB/DMF agresif merebut bola, contoh: Antonio Rüdiger)
- Penyerang Sayap Produktif = Prolific Winger (LWF/RWF menusuk ke dalam kotak penalti, contoh: Bukayo Saka, Son Heung-min, Rodrygo)
- Sayap Menjelajah = Roaming Flank (LWF/RWF bergerak bebas mencari ruang, contoh: Vinícius Júnior, Mohamed Salah)
- Playmaker Kreatif = Creative Playmaker (AMF/Winger pengatur tempo, contoh: Kevin De Bruyne, Lionel Messi, Martin Ødegaard)
- Box-to-Box = Box-to-Box (CMF aktif menyerang dan bertahan, contoh: Federico Valverde, Nicolò Barella)
- Dirigen Permainan = Orchestrator (CMF/DMF pengatur ritme umpan, contoh: Frenkie de Jong, Alexis Mac Allister, Luka Modrić)

ATURAN KRUSIAL:
1. Rekomendasi HARUS 100% tepat menjawab apa yang dicari pengguna! Jika pengguna mencari pemain dengan gaya main tertentu (seperti "Pemburu Celah" / Hole Player), ketiga pemain yang Anda rekomendasikan HARUS memiliki gaya main Hole Player! DILARANG KERAS merekomendasikan Anchor Man (seperti Rodri) atau Build Up (seperti Saliba) jika yang ditanya adalah Pemburu Celah!
2. Berikan 3 rekomendasi pemain terbaik di eFootball beserta Nama, Klub, Posisi, dan Gaya Main mereka.
3. Jelaskan mengapa mereka cocok untuk gaya main $currentPlaystyle.
4. Berikan saran alokasi Poin Latihan (Progression Points: Dribbling, Passing, Dexterity, Shooting, Lower Body Strength).
5. Berikan tips instruksi individual (Individual Instructions) di taktik eFootball.
''';

      // Try primary model with retry on transient spikes
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          final response = await _textModel!
              .generateContent([Content.text(prompt)])
              .timeout(const Duration(seconds: 25));
          if (response.text != null && response.text!.isNotEmpty) {
            return response.text!;
          }
        } catch (e) {
          if (attempt == 0) {
            await Future.delayed(const Duration(milliseconds: 1000));
          }
        }
      }

      // Try fallback model (gemini-3.5-flash)
      if (_fallbackTextModel != null) {
        try {
          final response = await _fallbackTextModel!
              .generateContent([Content.text(prompt)])
              .timeout(const Duration(seconds: 25));
          if (response.text != null && response.text!.isNotEmpty) {
            return response.text!;
          }
        } catch (_) {}
      }
    }

    // Smart Local Heuristic Fallback Scout advice
    return _generateOfflineScoutAdvice(query, currentPlaystyle, catalog);
  }

  String _buildSquadAnalysisPrompt({
    required String formation,
    required String teamPlaystyle,
    required Map<String, Player> lineUpWithPositions,
  }) {
    final playerSummary = lineUpWithPositions.entries.map((entry) {
      final slotId = entry.key;
      final slotPos = slotId.replaceAll(RegExp(r'[0-9]'), '');
      final p = entry.value;
      final effectiveOvr = p.getEffectiveRating(slotPos);
      final isOutOfPosition = effectiveOvr < p.overallRating;

      final status = isOutOfPosition
          ? '⚠️ LUAR POSISI! Posisi Asli: ${p.primaryPosition}, dipasang di $slotPos (OVR anjlok dari ${p.overallRating} ke $effectiveOvr)'
          : 'Posisi Sesuai ($slotPos), OVR: $effectiveOvr';

      return '- Posisi Slot $slotId ($slotPos): ${p.name} | $status | Playstyle: ${p.playerPlaystyle} | Def: ${p.keyStats.defending}, Pace: ${p.keyStats.pace}';
    }).join('\n');

    return '''
Anda adalah AI Squad Doctor & Analis Taktik Profesional eFootball 2024/2025.
Analisis sinergi skuad berikut secara mendalam:

Formasi: $formation
Gaya Main Tim: $teamPlaystyle
Daftar 11 Pemain di Lapangan:
$playerSummary

PERHATIAN KHUSUS POSISI PEMAIN:
- Jika ada pemain yang bertanda "⚠️ LUAR POSISI" (misalnya Penyerang/CF dijadikan Bek/CB atau sebaliknya, atau pemain biasa dijadikan Kiper/GK):
  1. Anda HARUS memberikan peringatan keras di 'tactical_verdict' dan sebutkan nama pemain tersebut.
  2. Masukkan kelemahan fatal tersebut ke dalam daftar 'weaknesses' (seperti rapuhnya pertahanan, minimnya skill bertahan, dsb).
  3. Berikan 'synergy_score' yang rendah (di bawah 50 jika striker dipasang sebagai bek).
  4. Pada 'tactical_instructions' dan 'alternative_suggestions', rekomendasikan pemain pengganti yang berposisi murni di posisi tersebut.

KEMBALIKAN HANYA FORMAT JSON PERSIS SEPERTI INI TANPA TEKS LAIN:
{
  "synergy_score": 85,
  "grade": "A",
  "tactical_verdict": "Penjelasan ringkas 2-3 kalimat mengenai karakter tim ini di eFootball.",
  "strengths": [
    "Kelebihan taktik 1",
    "Kelebihan taktik 2"
  ],
  "weaknesses": [
    "Kelemahan atau celah spasial 1",
    "Kelemahan atau celah spasial 2"
  ],
  "tactical_instructions": [
    "Instruksi individual 1 (misal: Set Defensive pada DMF)",
    "Instruksi individual 2"
  ],
  "alternative_suggestions": [
    "Saran pemain pengganti untuk menambal kelemahan"
  ]
}
''';
  }

  String _extractJson(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return trimmed;
    }
    final firstBrace = trimmed.indexOf('{');
    final lastBrace = trimmed.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      return trimmed.substring(firstBrace, lastBrace + 1);
    }
    return trimmed;
  }

  /// Engine Heuristik Aturan eFootball (Mendeteksi blunder posisi dan taktik eFootball secara presisi)
  SquadSynergyReport _analyzeWithTacticalRules({
    required String formation,
    required String teamPlaystyle,
    required Map<String, Player> lineUpWithPositions,
  }) {
    int score = 84;
    final strengths = <String>[];
    final weaknesses = <String>[];
    final instructions = <String>[];
    final alternatives = <String>[];

    const forwards = ['CF', 'SS', 'LWF', 'RWF'];
    const defenders = ['CB', 'LB', 'RB', 'LWB', 'RWB'];

    // 1. DETEKSI KRUSIAL: Pemain Luar Posisi (Out of Position)
    final outOfPositionList = <String>[];
    for (final entry in lineUpWithPositions.entries) {
      final slotPos = entry.key.replaceAll(RegExp(r'[0-9]'), '');
      final p = entry.value;

      if (!p.canPlayPosition(slotPos)) {
        final effectiveOvr = p.getEffectiveRating(slotPos);
        final drop = p.overallRating - effectiveOvr;
        outOfPositionList.add('${p.name} ($slotPos, -$drop OVR)');

        // Blunder fatal: Striker dipasang di Bek
        if (forwards.contains(p.primaryPosition) && defenders.contains(slotPos)) {
          score -= 32;
          weaknesses.add(
            'BLUNDER TAKTIK FATAL: ${p.name} (Penyerang) dipasang sebagai bek ($slotPos). '
            'Atribut bertahannya sangat rendah (${p.keyStats.defending}), membuat lini belakang mudah diterobos lawan.',
          );
          instructions.add(
            'Segera ganti ${p.name} di posisi $slotPos dengan bek murni bertipe Build Up atau The Destroyer.',
          );
          alternatives.add(
            'Rekomendasi bek tangguh: William Saliba (CB 95), Virgil van Dijk (CB 96), atau Rúben Dias (CB 95).',
          );
        } else if (p.primaryPosition != 'GK' && slotPos == 'GK') {
          score -= 45;
          weaknesses.add(
            'BLUNDER FATAL: Pemain non-kiper ${p.name} dipasang sebagai Kiper (GK)! OVR anjlok drastis ke $effectiveOvr.',
          );
          instructions.add('Wajib pasang kiper murni (GK) di bawah mistar gawang.');
          alternatives.add('Gunakan Thibaut Courtois (GK 96) atau Alisson Becker (GK 95).');
        } else {
          score -= 12;
          weaknesses.add(
            '${p.name} bermain di luar posisi terbaiknya ($slotPos), mengalami penalti OVR sebesar -$drop.',
          );
        }
      }
    }

    // 2. Evaluasi Sinergi Lini Tengah & Gaya Main

    final hasAnchorMan = lineUpWithPositions.values.any((p) => p.playerPlaystyle == 'Anchor Man');
    final hasHolePlayer = lineUpWithPositions.values.any((p) => p.playerPlaystyle == 'Hole Player');
    final hasGoalPoacher = lineUpWithPositions.values.any((p) => p.playerPlaystyle == 'Goal Poacher');

    if (teamPlaystyle == 'Quick Counter') {
      if (hasHolePlayer && hasGoalPoacher) {
        score += 8;
        strengths.add(
          'Kombinasi Pemburu Celah (Hole Player) dan Pemburu Gol (Goal Poacher) sangat ideal untuk taktik Quick Counter, menusuk cepat ke ruang terbuka saat transisi.',
        );
      }
      if (!hasAnchorMan) {
        score -= 6;
        weaknesses.add(
          'Lini tengah rentan serangan balik kilat lawan karena tidak memiliki Gelandang Jangkar (Anchor Man) penyeimbang pertahanan.',
        );
        instructions.add('Pasang instruksi individual "Defensive" pada salah satu gelandang bertahan.');
        alternatives.add('Rekomendasi Anchor Man terbaik: Rodri (DMF 98) atau Aurélien Tchouaméni (DMF 94).');
      } else {
        strengths.add('Gelandang Jangkar (Anchor Man) aktif memutus alur bola serangan balik lawan.');
      }
    } else if (teamPlaystyle == 'Possession Game') {
      final orchestrators = lineUpWithPositions.values
          .where((p) => p.playerPlaystyle == 'Orchestrator' || p.playerPlaystyle == 'Creative Playmaker')
          .length;
      if (orchestrators >= 2) {
        score += 8;
        strengths.add(
          'Lini tengah kaya akan playmaker dan pengatur tempo (Orchestrator/Creative Playmaker), memudahkan sirkulasi umpan pendek penguasaan bola.',
        );
      } else {
        weaknesses.add('Minim pengatur tempo di lini tengah untuk memecah blok pertahanan rendah lawan.');
      }
    }

    // 3. Evaluasi Pertahanan
    final cbs = lineUpWithPositions.entries
        .where((e) => e.key.startsWith('CB'))
        .map((e) => e.value)
        .toList();

    if (cbs.isNotEmpty) {
      final avgPace =
          (cbs.map((p) => p.keyStats.pace).reduce((a, b) => a + b) / cbs.length).round();
      if (avgPace >= 82) {
        strengths.add(
            'Duo bek tengah memiliki kecepatan (Pace rata-rata $avgPace) yang solid untuk mengantisipasi umpan terobosan.');
      } else if (avgPace < 74 && teamPlaystyle == 'Quick Counter') {
        score -= 6;
        weaknesses.add(
            'Garis pertahanan tinggi Quick Counter rawan ditembus penyerang cepat karena kecepatan bek tengah relatif rendah.');
        instructions.add('Pasang instruksi "Deep Defensive Line" pada taktik bertahan.');
      }
    }

    score = score.clamp(20, 98);
    String grade = 'B';
    if (score >= 90) {
      grade = 'S';
    } else if (score >= 80) {
      grade = 'A';
    } else if (score >= 65) {
      grade = 'B';
    } else if (score >= 50) {
      grade = 'C';
    } else {
      grade = 'D';
    }

    String verdict;
    if (outOfPositionList.isNotEmpty) {
      verdict =
          'PERINGATAN TAKTIK: Terdapat ${outOfPositionList.length} pemain yang bermain di luar posisi alaminya (${outOfPositionList.join(", ")}). '
          'Sinergi tim turun drastis ke peringkat $grade ($score/100) karena terjadi penurunan atribut (OVR drop) dan kekosongan peran spesifik di lapangan.';
    } else {
      verdict =
          'Skuad $formation dengan gaya main $teamPlaystyle memiliki sinergi $grade ($score/100). '
          'Transisi taktik teratur dan setiap pemain mengisi posisi yang sesuai dengan atribut alaminya.';
    }

    return SquadSynergyReport(
      synergyScore: score,
      grade: grade,
      tacticalVerdict: verdict,
      strengths: strengths.isNotEmpty
          ? strengths
          : ['Lini serang memiliki daya jelajah yang cukup aktif.'],
      weaknesses: weaknesses.isNotEmpty
          ? weaknesses
          : ['Jarak antar lini tengah dan lini serang perlu dijaga saat transisi bertahan.'],
      tacticalInstructions: instructions.isNotEmpty
          ? instructions
          : ['Gunakan instruksi "Defensive" pada salah satu bek sayap saat menghadapi lawan ofensif.'],
      alternativeSuggestions: alternatives.isNotEmpty
          ? alternatives
          : ['Pertahankan susunan inti ini untuk memaksimalkan chemistry tim.'],
    );
  }

  /// Engine Heuristik Pencarian Cerdas Pemain (Sesuai 100% dengan istilah eFootball)
  String _generateOfflineScoutAdvice(
    String query,
    String playstyle, [
    List<Player> catalog = const [],
  ]) {
    final q = query.toLowerCase();

    // 1. Pemburu Celah / Hole Player
    if (q.contains('pemburu celah') ||
        q.contains('hole player') ||
        q.contains('penyerang lubang') ||
        q.contains('celah')) {
      final holePlayers = catalog
          .where((p) => p.playerPlaystyle == 'Hole Player')
          .toList()
        ..sort((a, b) => b.overallRating.compareTo(a.overallRating));

      final p1 = holePlayers.isNotEmpty ? holePlayers[0].name : 'Jude Bellingham';
      final c1 = holePlayers.isNotEmpty ? holePlayers[0].club : 'Real Chamartin (Real Madrid)';
      final r1 = holePlayers.isNotEmpty ? holePlayers[0].overallRating : 97;

      final p2 = holePlayers.length > 1 ? holePlayers[1].name : 'Florian Wirtz';
      final c2 = holePlayers.length > 1 ? holePlayers[1].club : 'Bayer Leverkusen';
      final r2 = holePlayers.length > 1 ? holePlayers[1].overallRating : 95;

      final p3 = holePlayers.length > 2 ? holePlayers[2].name : 'Antoine Griezmann';
      final c3 = holePlayers.length > 2 ? holePlayers[2].club : 'Atlético Madrid';
      final r3 = holePlayers.length > 2 ? holePlayers[2].overallRating : 94;

      return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai **Pemain Pemburu Celah (Hole Player)**:

1. **Rekomendasi Pemain Kunci (Hole Player Murni):**
   - **$p1 ($c1)** - AMF (OVR $r1): Gelandang serang paling komplit di eFootball. Memiliki akselerasi menusuk dari lini kedua, fisik kokoh (*Physical Contact* 88), dan kemampuan mencetak gol tinggi.
   - **$p2 ($c2)** - AMF/SS (OVR $r2): Playmaker lincah dengan *Tight Possession* dan *Through Passing* luar biasa. Sangat licin menyusup saat bek lawan terpancing maju.
   - **$p3 ($c3)** - SS/AMF (OVR $r3): Penyerang lubang dengan kecerdasan spasial tinggi. Efektif melepaskan *First-time Shot* dan *Long Range Curler* langsung saat menerima umpan di depan kotak penalti.

2. **Karakter Taktis Pemburu Celah di eFootball:**
   - Pemain dengan gaya ini akan **secara otomatis melakukan sprint tanpa bola** ke ruang kosong (celah) di kotak penalti lawan begitu tim Anda menguasai bola di sepertiga akhir lapangan.
   - Sangat cocok untuk gaya main **$playstyle** karena memberikan opsi umpan terobosan vertikal instan ketika striker utama Anda dijaga ketat.

3. **Saran Alokasi Poin Latihan (Progression Points):**
   - **Dexterity (8-10 poin):** Sangat krusial agar akselerasi (*Acceleration*) dan kelincahan mencari ruang semakin responsif.
   - **Dribbling (8 poin):** Mengoptimalkan kontrol bola instan saat menerima operan di ruang sempit.
   - **Passing (6 poin):** Menjamin umpan satu-dua (*one-two*) dan through pass akurat.
   - **Shooting (6-8 poin):** Memastikan eksekusi tembakan di kotak penalti membuahkan gol.

4. **Tips Instruksi Taktik eFootball:**
   - Pasangkan Pemburu Celah dengan striker bertipe **Goal Poacher** atau **Deep-Lying Forward** yang bisa memancing bek tengah lawan keluar dari posisinya.
   - Jika AMF terasa kurang agresif naik, tambahkan instruksi individual **"Attacking"** pada AMF tersebut di taktik pertandingan.
''';
    }

    // 2. Pemburu Gol / Goal Poacher / Striker
    if (q.contains('pemburu gol') ||
        q.contains('goal poacher') ||
        q.contains('striker') ||
        q.contains('cf') ||
        q.contains('penyerang')) {
      final poachers = catalog
          .where((p) => p.playerPlaystyle == 'Goal Poacher' || p.primaryPosition == 'CF')
          .toList()
        ..sort((a, b) => b.overallRating.compareTo(a.overallRating));

      final p1 = poachers.isNotEmpty ? poachers[0].name : 'Kylian Mbappé';
      final c1 = poachers.isNotEmpty ? poachers[0].club : 'Real Chamartin (Real Madrid)';
      final r1 = poachers.isNotEmpty ? poachers[0].overallRating : 98;

      final p2 = poachers.length > 1 ? poachers[1].name : 'Erling Haaland';
      final c2 = poachers.length > 1 ? poachers[1].club : 'Manchester B (Man City)';
      final r2 = poachers.length > 1 ? poachers[1].overallRating : 97;

      final p3 = poachers.length > 2 ? poachers[2].name : 'Victor Osimhen';
      final c3 = poachers.length > 2 ? poachers[2].club : 'Galatasaray';
      final r3 = poachers.length > 2 ? poachers[2].overallRating : 93;

      return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai **Penyerang / Pemburu Gol (Goal Poacher)**:

1. **Rekomendasi Pemain Kunci (Goal Poacher Murni):**
   - **$p1 ($c1)** - CF/LWF (OVR $r1): Kecepatan murni (*Speed* 98) dan akselerasi mematikan. Monster serangan balik yang siap menghancurkan garis pertahanan tinggi lawan.
   - **$p2 ($c2)** - CF (OVR $r2): Ujung tombak fisik predator (*Finishing* 95, *Physical Contact* 94). Sangat mematikan dalam duel bola atas dan *First-time Shot*.
   - **$p3 ($c3)** - CF (OVR $r3): Striker atletis dengan *Speed* 93 dan lompatan tinggi, sangat agresif memburu bola muntah di kotak penalti.

2. **Saran Alokasi Poin Latihan (Progression Points):**
   - **Dexterity (8-10 poin):** Memaksimalkan reaksi dan insting gol di kotak penalti.
   - **Shooting (8-10 poin):** Menjamin tingkat konversi tembakan tinggi.
   - **Lower Body Strength (6-8 poin):** Meningkatkan *Speed* dan *Kicking Power*.
   - **Dribbling (4 poin):** Cukup untuk kontrol bola dasar saat berhadapan 1v1 dengan kiper.

3. **Tips Instruksi Taktik:**
   - Tambahkan instruksi individual **"Counter Target"** pada penyerang utama agar tidak lelah membantu pertahanan dan selalu siap menerima umpan terobosan.
''';
    }

    // 3. Gelandang Jangkar / Anchor Man / DMF
    if (q.contains('jangkar') ||
        q.contains('anchor man') ||
        q.contains('dmf') ||
        q.contains('gelandang bertahan')) {
      final anchors = catalog
          .where((p) => p.playerPlaystyle == 'Anchor Man' || p.primaryPosition == 'DMF')
          .toList()
        ..sort((a, b) => b.overallRating.compareTo(a.overallRating));

      final p1 = anchors.isNotEmpty ? anchors[0].name : 'Rodri';
      final c1 = anchors.isNotEmpty ? anchors[0].club : 'Manchester B (Man City)';
      final r1 = anchors.isNotEmpty ? anchors[0].overallRating : 98;

      final p2 = anchors.length > 1 ? anchors[1].name : 'Aurélien Tchouaméni';
      final c2 = anchors.length > 1 ? anchors[1].club : 'Real Chamartin (Real Madrid)';
      final r2 = anchors.length > 1 ? anchors[1].overallRating : 94;

      final p3 = anchors.length > 2 ? anchors[2].name : 'Declan Rice';
      final c3 = anchors.length > 2 ? anchors[2].club : 'Arsenal';
      final r3 = anchors.length > 2 ? anchors[2].overallRating : 94;

      return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai **Gelandang Jangkar (Anchor Man)**:

1. **Rekomendasi Pemain Kunci (Anchor Man Murni):**
   - **$p1 ($c1)** - DMF (OVR $r1): Jangkar nomor satu di dunia. Dominan dalam tekel, intersepsi bola, dan umpan pendek transisi.
   - **$p2 ($c2)** - DMF (OVR $r2): Jangkar modern dengan fisik tinggi, mobilitas cepat, dan jangkauan sapuan bola luas.
   - **$p3 ($c3)** - DMF (OVR $r3): Gelandang bertubuh kekar dengan stamina baja yang mampu menutup celah di depan CB.

2. **Karakter Taktis Gelandang Jangkar:**
   - Gaya main **Anchor Man** menjamin pemain bertahan tetap berdiri di depan dua bek tengah dan **TIDAK PERNAH NAIK** ikut menyerang. Ini vital untuk menangkal serangan balik kilat musuh.

3. **Saran Alokasi Poin Latihan (Progression Points):**
   - **Defending (12 poin):** Memaksimalkan *Defensive Engagement*, *Tackling*, dan *Interception*.
   - **Physical / Aerial (6-8 poin):** Memenangkan duel udara dan adu bodi dengan penyerang lawan.
   - **Passing (4-6 poin):** Menjamin distribusi bola aman ke lini depan.

4. **Tips Instruksi Taktik:**
   - Pasang instruksi individual **"Defensive"** agar posisinya semakin terkunci di depan garis pertahanan.
''';
    }

    // 4. Bek Tengah / CB / Build Up / Destroyer
    if (q.contains('bek') ||
        q.contains('cb') ||
        q.contains('center back') ||
        q.contains('build up') ||
        q.contains('destroyer') ||
        q.contains('pertahanan')) {
      return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai **Bek Tengah (CB / Defender)**:

1. **Rekomendasi Pemain Kunci:**
   - **Virgil van Dijk (Liverpool)** - CB (OVR 96) - Build Up: Tembok raksasa dengan *Defensive Awareness* 96 dan dominasi duel udara mutlak.
   - **William Saliba (Arsenal)** - CB (OVR 95) - Build Up: Bek modern dengan *Pace* (84) dan *Defensive Awareness* (95) yang sangat ideal untuk formasi garis tinggi.
   - **Antonio Rüdiger (Real Chamartin)** - CB (OVR 95) - The Destroyer: Bek agresif bertipe penabrak dengan kecepatan tinggi dan tekel keras tanpa kompromi.

2. **Saran Alokasi Poin Latihan (Progression Points):**
   - **Defending (12-14 poin):** Prioritas mutlak untuk atribut bertahan.
   - **Aerial Strength (6-8 poin):** Mengamankan bola lambung dan duel sundulan.
   - **Dexterity (4-6 poin):** Meningkatkan *Speed* dan kelincahan agar tidak mudah dilewati *Through Pass*.

3. **Tips Instruksi Taktik:**
   - Hindari memasang dua bek bertipe *The Destroyer* bersamaan karena garis pertahanan rentan berlubang saat mereka terpancing menekan.
''';
    }

    // 5. Sayap / Winger / Roaming Flank / Prolific Winger
    if (q.contains('sayap') ||
        q.contains('winger') ||
        q.contains('lwf') ||
        q.contains('rwf') ||
        q.contains('roaming flank') ||
        q.contains('prolific winger')) {
      return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai **Pemain Sayap (Winger)**:

1. **Rekomendasi Pemain Kunci:**
   - **Vinícius Júnior (Real Chamartin)** - LWF (OVR 97) - Roaming Flank: Sayap paling lincah dengan *Speed* 99, *Dribbling* 97, dan skill *Double Touch*.
   - **Mohamed Salah (Liverpool)** - RWF (OVR 96) - Roaming Flank: Sayap pencetak gol dengan *Finishing* 92 dan lengkungan tembakan maut (*Long Range Curler*).
   - **Bukayo Saka (Arsenal)** - RWF (OVR 95) - Prolific Winger: Penyerang sayap berdaya jelajah tinggi dengan umpan silang akurat (*Pinpoint Crossing*).

2. **Saran Alokasi Poin Latihan (Progression Points):**
   - **Dexterity (8-10 poin):** Meningkatkan akselerasi dan respon pergerakan.
   - **Dribbling (8-10 poin):** Kontrol bola lengket untuk melewati bek sayap lawan.
   - **Passing (4-6 poin):** Akurasi umpan silang dan cutback.
   - **Shooting (6-8 poin):** Tembakan melengkung dari sudut sempit.
''';
    }

    // 6. Playmaker Kreatif
    if (q.contains('playmaker') ||
        q.contains('kreatif') ||
        q.contains('creative playmaker')) {
      return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai **Playmaker Kreatif (Creative Playmaker)**:

1. **Rekomendasi Pemain Kunci:**
   - **Kevin De Bruyne (Manchester B)** - AMF (OVR 97): Maestro umpan terbaik dengan *Low Pass* 98 dan *Weighted Pass*.
   - **Lionel Messi (Inter Miami)** - RWF/AMF (OVR 98): Visi bermain legendaris dengan *Tight Possession* dan *Through Passing* sempurna.
   - **Martin Ødegaard (Arsenal)** - AMF (OVR 95): Pengatur serangan cerdas dengan mobilitas dan umpan terobosan berbobot.

2. **Saran Alokasi Poin Latihan:**
   - **Passing (10-12 poin):** Memaksimalkan umpan terobosan dan umpan lambung.
   - **Dribbling (8 poin):** Mempertahankan bola di bawah pressing ketat.
   - **Shooting (6 poin):** Senjata tembakan jarak jauh (*Long Range Shooting*).
''';
    }

    // 7. Box-to-Box
    if (q.contains('box to box') || q.contains('b2b')) {
      return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai **Gelandang Box-to-Box**:

1. **Rekomendasi Pemain Kunci:**
   - **Federico Valverde (Real Chamartin)** - CMF (OVR 96): Dinamo tim dengan *Speed* 92, stamina tanpa henti, dan tembakan geledek.
   - **Nicolò Barella (Inter Milano)** - CMF (OVR 94): Gelandang petarung yang aktif merebut bola dan membantu transisi serangan.
   - **Eduardo Camavinga (Real Chamartin)** - CMF (OVR 93): Gelandang serba bisa dengan kemampuan tekel bersih dan dribel keluar dari tekanan.

2. **Saran Alokasi Poin Latihan:**
   - Seimbangkan poin antara **Dexterity (6)**, **Defending (8)**, **Passing (6)**, dan **Lower Body Strength (8)**.
''';
    }

    // 8. Kiper / GK
    if (q.contains('kiper') || q.contains('gk') || q.contains('penjaga gawang')) {
      return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai **Penjaga Gawang (Goalkeeper / GK)**:

1. **Rekomendasi Pemain Kunci:**
   - **Thibaut Courtois (Real Chamartin)** - GK (OVR 96) - Defensive Goalkeeper: Kiper tertinggi (200 cm) dengan jangkauan *GK Reach* luar biasa untuk menepis tembakan jarak dekat.
   - **Alisson Becker (Liverpool)** - GK (OVR 95) - Offensive Goalkeeper: Kiper agresif yang cepat keluar memotong umpan terobosan di taktik garis tinggi.
   - **Gianluigi Donnarumma (Paris Saint-Germain)** - GK (OVR 94) - Defensive Goalkeeper: Refleks monster untuk menghalau tembakan deras.

2. **Saran Alokasi Poin Latihan (Progression Points):**
   - **GK 1 (8-10 poin):** *GK Catching* dan *GK Jumping*.
   - **GK 2 (10-12 poin):** *GK Parrying* dan *GK Awareness*.
   - **GK 3 (8-10 poin):** *GK Reach* dan *Reflexes*.
''';
    }

    // 9. Generic / Fallback dinamis
    return '''
### 🔍 Rekomendasi Scout eFootball ($playstyle)

Berdasarkan pencarian Anda mengenai "$query":

1. **Rekomendasi Taktis Umum:**
   - Untuk gaya main **$playstyle**, prioritaskan pemain dengan atribut *Speed* dan *Dexterity* tinggi di lini depan, serta *Defensive Awareness* dan *Physical Contact* di lini belakang.
   - Pastikan setiap pemain ditempatkan pada posisi alami atau posisi sekunder agar tidak mengalami penalti penurunan OVR.

2. **Saran Poin Latihan Universal:**
   - **Penyerang (CF/Winger):** Fokuskan pada *Dexterity* dan *Shooting*.
   - **Gelandang (AMF/CMF):** Fokuskan pada *Passing* dan *Dribbling*.
   - **Bertahan (DMF/CB):** Fokuskan pada *Defending* dan *Lower Body Strength*.

3. **Tips Instruksi Taktik:**
   - Sesuaikan instruksi individual sesuai kelemahan lawan yang dihadapi.
''';
  }
}
