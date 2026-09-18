class Playstyles {
  // Team Playstyles
  static const String quickCounter = 'Quick Counter';
  static const String possessionGame = 'Possession Game';
  static const String longBallCounter = 'Long Ball Counter';
  static const String outWide = 'Out Wide';
  static const String longBall = 'Long Ball';

  static const List<String> allTeamPlaystyles = [
    quickCounter,
    possessionGame,
    longBallCounter,
    outWide,
    longBall,
  ];

  // Player Playstyles
  static const String goalPoacher = 'Goal Poacher';
  static const String foxInTheBox = 'Fox in the Box';
  static const String targetMan = 'Target Man';
  static const String deepLyingForward = 'Deep-Lying Forward';
  static const String creativePlaymaker = 'Creative Playmaker';
  static const String holePlayer = 'Hole Player';
  static const String classicNo10 = 'Classic No. 10';
  static const String prolificWinger = 'Prolific Winger';
  static const String roamingFlank = 'Roaming Flank';
  static const String crossSpecialist = 'Cross Specialist';
  static const String boxToBox = 'Box-to-Box';
  static const String anchorMan = 'Anchor Man';
  static const String destroyer = 'Destroyer';
  static const String orchestrator = 'Orchestrator';
  static const String buildUp = 'Build Up';
  static const String extraFrontman = 'Extra Frontman';
  static const String offensiveFullback = 'Attacking Full-back';
  static const String defensiveFullback = 'Defensive Full-back';
  static const String fullBackFinisher = 'Full-back Finisher';
  static const String offensiveGoalkeeper = 'Offensive Goalkeeper';
  static const String defensiveGoalkeeper = 'Defensive Goalkeeper';

  static const List<String> allPlayerPlaystyles = [
    goalPoacher,
    foxInTheBox,
    targetMan,
    deepLyingForward,
    creativePlaymaker,
    holePlayer,
    classicNo10,
    prolificWinger,
    roamingFlank,
    crossSpecialist,
    boxToBox,
    anchorMan,
    destroyer,
    orchestrator,
    buildUp,
    extraFrontman,
    offensiveFullback,
    defensiveFullback,
    fullBackFinisher,
    offensiveGoalkeeper,
    defensiveGoalkeeper,
  ];

  static const Map<String, String> playstyleTranslations = {
    goalPoacher: 'Pemburu Gol',
    foxInTheBox: 'Rubah di Kotak Penalti',
    targetMan: 'Target Man',
    deepLyingForward: 'Penyerang Bayangan',
    creativePlaymaker: 'Playmaker Kreatif',
    holePlayer: 'Pemburu Celah',
    classicNo10: 'Klasik No. 10',
    prolificWinger: 'Sayap Produktif',
    roamingFlank: 'Sayap Penjelajah',
    crossSpecialist: 'Spesialis Crossing',
    boxToBox: 'Box-to-Box',
    anchorMan: 'Gelandang Jangkar',
    destroyer: 'Perusak',
    orchestrator: 'Pengatur Serangan',
    buildUp: 'Pembangun Serangan',
    extraFrontman: 'Bek Penyerang Tambahan',
    offensiveFullback: 'Bek Sayap Menyerang',
    defensiveFullback: 'Bek Sayap Bertahan',
    fullBackFinisher: 'Bek Sayap Penyelesai',
    offensiveGoalkeeper: 'Kiper Menyerang',
    defensiveGoalkeeper: 'Kiper Bertahan',
  };

  static String getLabelWithIndonesian(String playstyle) {
    final indo = playstyleTranslations[playstyle];
    if (indo != null && indo.isNotEmpty) {
      return '$playstyle ($indo)';
    }
    return playstyle;
  }

  static String getIndonesian(String playstyle) {
    return playstyleTranslations[playstyle] ?? playstyle;
  }

  // Positions
  static const List<String> allPositions = [
    'CF',
    'SS',
    'LWF',
    'RWF',
    'AMF',
    'LMF',
    'RMF',
    'CMF',
    'DMF',
    'LB',
    'RB',
    'CB',
    'GK',
  ];
}
