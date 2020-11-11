class Talent {
  String name;
  String description;
}

class Icon {
  String name;
  String description;
  Talent iconsGift;
}

class Gear {
  String name;
  String description;
}

class Armor {
  String name;
  String description;
  int armorClass;
}

class Weapon {
  String name;
  String description;
  int bonus;
  int initiativeBonus;
  int damage;
  int diceToCritical;
  String range;
  String comments;
}


class Attribute {
  static const String STR = "Strength";
  static const String AGI = "Agility";
  static const String WIT = "Wits";
  static const String EMP = "Empathy";

  String name;
  int value;
}

class Skill {
  String name;
  bool special;
  String attributeName;
  int value;
}

class Character {
  String name;
  String problem;
  
  String concept;
  String groupConcept;

  String background;
  int reputation;
  
  Icon icon;

  Map<String, Attribute> attributes;
  int get maxHitPoints {
    if (attributes == null) return 0;
    return attributes[Attribute.AGI].value + attributes[Attribute.STR].value;
  }

  int get maxMindPoints {
    if (attributes == null) return 0;
    return attributes[Attribute.WIT].value + attributes[Attribute.EMP].value;
  }

  int hitPoints;
  int mindPoints;
  int radiation;
  int experience;

  List<Talent> talents;

  List<Skill> generalSkills;
  List<Skill> advancedSkils;

  // inventory
  List<Gear> gears;
  Armor armor;
  List<Weapon> weapons;

  
}