class Job {
  constructor(name, article, IN, AT, PA, LP) {
    this.name = name;
    this.nameWithArticle = article + name;
    this.IN = IN;
    this.AT = AT;
    this.PA = PA;
    this.LP = LP;
  }
}

class Weapon {
  constructor(name, article, IN, AT, PA, canCA) {
    this.name = name;
    this.nameWithArticle = article + name;
    this.IN = IN;
    this.AT = AT;
    this.PA = PA;
    this.canCA = canCA;
  }
}

class Fighter {
  constructor(name, jobId, weaponId) {
    this._name = name;
    this.job = arena.jobs[jobId];
    this.weapon = arena.weapons[weaponId];
    this.bonusAT = 0;
    this.LP = 3;
  }

  get name() {
    return `<strong>${this._name}</strong>`;
  }

  set name(val) {
    this._name = val;
  }

  get cleanName() {
    return this._name;
  }

  get IN() {
    return this.job.IN + this.weapon.IN;
  }

  get AT() {
    return this.job.AT + this.weapon.AT + this.bonusAT;
  }

  get PA() {
    return this.job.PA + this.weapon.PA;
  }

  get canCA() {
    return this.weapon.canCA;
  }

  get isDead() {
    return this.LP <= 0 ? true : false;
  }

  calcINBonus(oppIN) {
    if (this.IN > oppIN) {
      var diff = this.IN - oppIN;
      var bonusAT = Math.floor(diff / 3);
      if (this.AT + bonusAT > 17) {
          bonusAT = 17 - this.AT;
      }
      this.bonusAT = bonusAT;
      return bonusAT;
    }
    return 0;
  }
}

function getRandom(num) {
  return Math.floor((Math.random() * num) + 1);
}

class Arena
{
  constructor() {
    this.jobs = this.generateJobs();
    this.weapons = this.generateWeapons();
  }

  get inactiveFighter() {
    return (this.activeFighter % 2) + 1;
  }

  generateJobs() {
    var jobs = new Array();
    jobs[1] = new Job('Gladiator', 'a ', 9, 10, 8);
    jobs[2] = new Job('Warrior', 'a ', 9, 8, 10);
    jobs[3] = new Job('Knight', 'a ', 9, 7, 11);
    jobs[4] = new Job('Barbarian', 'a ', 7, 12, 7);
    jobs[5] = new Job('Dwarf', 'a ', 7, 8, 11);
    jobs[6] = new Job('Elf', 'an ', 11, 9, 8);
    jobs[7] = new Job('Orc', 'an ', 7, 10, 9);
    jobs[8] = new Job('Thief', 'a ', 11, 8, 9);
    jobs[9] = new Job('Pirate', 'a ', 9, 9, 9);
    jobs[10] = new Job('Mercenary', 'a ', 9, 11, 7);

    return jobs;
  }

  generateWeapons() {
      var weapons = new Array();
      weapons[1] = new Weapon('Spear', 'a ', 5, 0, 0, false);
      weapons[2] = new Weapon('Sword &amp; Shield', 'a ', -1, 0, 2, false);
      weapons[3] = new Weapon('Mace', 'a ', -1, 2, 0, false);
      weapons[4] = new Weapon('2-Handed Sword', 'a ', 2, 2, -1, false);
      weapons[5] = new Weapon('Axe', 'an ', -1, 1, 1, false);
      weapons[6] = new Weapon('Bow', 'a ', 5, 2, -2, false);
      weapons[7] = new Weapon('2-Handed Axe', 'a ', 2, 3, -2, false);
      weapons[8] = new Weapon('Saber', 'a ', 2, 0, 1, false);
      weapons[9] = new Weapon('Daggers', '', -3, -1, 2, true);
      weapons[10] = new Weapon('Orcblade', 'an ', -4, 3, 0, false);

      return weapons;
  }

  startFight(fighter1, fighter2) {
    this.fighters = new Array(3);
    this.fighters[1] = fighter1;
    this.fighters[2] = fighter2;

    fighter1.calcINBonus(fighter2.IN);
    fighter2.calcINBonus(fighter1.IN);

    if (fighter1.IN == fighter2.IN) {
      var rnd = getRandom(2);
      this.activeFighter = rnd;
    } else {
      var first = 1;
      if(fighter2.IN > fighter1.IN)
        first = 2;
      this.activeFighter = first;
    }

    this.activeFighter = this.inactiveFighter; // flip because it toggles in endRound
    this.endRound();
  }

  doAttack(attacker, defender) {
    var attackRoll = getRandom(20);
    if (attackRoll <= attacker.AT) {

      var parryRoll = getRandom(20);
      if (parryRoll <= defender.PA) {
        defender.hasParried = true;
      } else {
        defender.LP -= 1;
      }
    } else {
      if (defender.canCA)
        defender.willCA = true;
    }
  }

  doCounterAttack(attacker, defender) {
    var attackRoll = getRandom(20);
    if (attackRoll <= Math.ceil(attacker.AT / 2)) {
      if(defender.hasParried) {
        defender.LP -= 1;
      } else {
        var parryRoll = getRandom(20);
        if (parryRoll > defender.PA) {
          defender.LP -= 1;
        }
      }
    }
  }

  fight() {
    var attacker = this.fighters[this.activeFighter];
    var defender = this.fighters[this.inactiveFighter];
    defender.hasParried = false;

    this.doAttack(attacker, defender);
    var fightActive = this.updateLPDisplayAndCheckForDeath();

    if (attacker.canCA && attacker.willCA && fightActive) {
      attacker.willCA = false;
      this.doCounterAttack(attacker, defender);
    }

    this.endRound();
  }

  updateLPDisplayAndCheckForDeath() {
    for(var i = 1; i < 3; i++) {
        if (this.fighters[i].isDead) {
            return false;
        }
    }

    return true;
  }

    endRound() {
        var fightActive = this.updateLPDisplayAndCheckForDeath();

        this.activeFighter = this.inactiveFighter;
        if (fightActive)
            this.fight();
    }
}
