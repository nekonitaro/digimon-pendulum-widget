enum EvolutionStage {
  baby1,      // 幼年期Ⅰ
  baby2,      // 幼年期Ⅱ
  child,      // 成長期
  adult,      // 成熟期
  perfect,    // 完全体
  ultimate,   // 究極体
  superUltimate, // 超究極体（NEW!）
}

extension EvolutionStageExtension on EvolutionStage {
  String get displayName {
    switch (this) {
      case EvolutionStage.baby1:
        return '幼年期Ⅰ';
      case EvolutionStage.baby2:
        return '幼年期Ⅱ';
      case EvolutionStage.child:
        return '成長期';
      case EvolutionStage.adult:
        return '成熟期';
      case EvolutionStage.perfect:
        return '完全体';
      case EvolutionStage.ultimate:
        return '究極体';
      case EvolutionStage.superUltimate:
        return '超究極体'; // NEW!
    }
  }

  int get requiredLevel {
    switch (this) {
      case EvolutionStage.baby1:
        return 0;
      case EvolutionStage.baby2:
        return 3;
      case EvolutionStage.child:
        return 7;
      case EvolutionStage.adult:
        return 12;
      case EvolutionStage.perfect:
        return 18;
      case EvolutionStage.ultimate:
        return 25;
      case EvolutionStage.superUltimate:
        return 35; // NEW! 超究極体は通常進化不可
    }
  }

  // 見た目の色（デバッグ用）
  int get colorValue {
    switch (this) {
      case EvolutionStage.baby1:
        return 0xFFE0E0E0; // 薄いグレー
      case EvolutionStage.baby2:
        return 0xFFB0B0B0; // グレー
      case EvolutionStage.child:
        return 0xFF90EE90; // ライトグリーン
      case EvolutionStage.adult:
        return 0xFF4169E1; // ロイヤルブルー
      case EvolutionStage.perfect:
        return 0xFF9370DB; // ミディアムパープル
      case EvolutionStage.ultimate:
        return 0xFFFF4500; // オレンジレッド
      case EvolutionStage.superUltimate:
        return 0xFFFFD700; // ゴールド（NEW!）
    }
  }

  // 次の進化段階を取得（NEW!）
  EvolutionStage? get next {
    switch (this) {
      case EvolutionStage.baby1:
        return EvolutionStage.baby2;
      case EvolutionStage.baby2:
        return EvolutionStage.child;
      case EvolutionStage.child:
        return EvolutionStage.adult;
      case EvolutionStage.adult:
        return EvolutionStage.perfect;
      case EvolutionStage.perfect:
        return EvolutionStage.ultimate;
      case EvolutionStage.ultimate:
        return null; // 究極体は通常進化できない
      case EvolutionStage.superUltimate:
        return null; // 超究極体は最終形態
    }
  }
}