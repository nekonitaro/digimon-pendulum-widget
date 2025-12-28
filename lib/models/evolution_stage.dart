enum EvolutionStage {
  baby1,      // 幼年期1
  baby2,      // 幼年期2
  child,      // 成長期
  adult,      // 成熟期
  perfect,    // 完全体
  ultimate;   // 究極体

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
    }
  }

  int get requiredLevel {
    switch (this) {
      case EvolutionStage.baby1:
        return 1;
      case EvolutionStage.baby2:
        return 3;
      case EvolutionStage.child:
        return 5;
      case EvolutionStage.adult:
        return 10;
      case EvolutionStage.perfect:
        return 15;
      case EvolutionStage.ultimate:
        return 20;
    }
  }

  EvolutionStage? get next {
    final index = EvolutionStage.values.indexOf(this);
    if (index < EvolutionStage.values.length - 1) {
      return EvolutionStage.values[index + 1];
    }
    return null;
  }
}