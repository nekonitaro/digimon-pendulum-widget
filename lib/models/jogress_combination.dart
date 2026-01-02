

/// ジョグレス進化の組み合わせ定義
class JogressCombination {
  final String name;              // 超究極体の名前
  final String description;       // 説明
  final List<String> requiredNames; // 必要なデジモン名（空なら任意の究極体2体）
  final int requiredCoins;        // 必要なコイン数

  const JogressCombination({
    required this.name,
    required this.description,
    this.requiredNames = const [],
    this.requiredCoins = 500,
  });

  /// 組み合わせが条件を満たすか確認
  bool canJogress(String name1, String name2) {
    if (requiredNames.isEmpty) {
      // 任意の究極体2体でOK
      return true;
    }
    
    // 特定の組み合わせが必要
    return (requiredNames.contains(name1) && requiredNames.contains(name2));
  }
}

/// 定義済みジョグレス組み合わせ
class JogressCombinations {
  // 汎用ジョグレス（任意の究極体2体）
  static const generic = JogressCombination(
    name: 'オメガモン',
    description: '究極体2体の融合',
    requiredCoins: 500,
  );

  // 特定組み合わせ（実装例）
  static const warGreymonMetalGarurumon = JogressCombination(
    name: 'オメガモン',
    description: 'ウォーグレイモンとメタルガルルモンの融合',
    requiredNames: ['ウォーグレイモン', 'メタルガルルモン'],
    requiredCoins: 300, // 特定組み合わせは安い
  );

  static const imperialdramon = JogressCombination(
    name: 'インペリアルドラモン',
    description: 'ドラゴン系究極体2体の融合',
    requiredNames: ['エグザモン', 'デュークモン'],
    requiredCoins: 400,
  );

  static const susanoomon = JogressCombination(
    name: 'スサノオモン',
    description: '神聖系究極体2体の融合',
    requiredNames: ['セラフィモン', 'オファニモン'],
    requiredCoins: 400,
  );

  /// 全ての組み合わせリスト
  static List<JogressCombination> get all => [
    warGreymonMetalGarurumon,
    imperialdramon,
    susanoomon,
    generic, // 最後に汎用パターン
  ];

  /// 2体のデジモン名から最適な組み合わせを取得
  static JogressCombination? findCombination(String name1, String name2) {
    // 特定組み合わせを優先的に検索
    for (var combo in all) {
      if (combo.canJogress(name1, name2)) {
        return combo;
      }
    }
    return null;
  }
}