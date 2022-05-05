var messageLog = '';

function fightLog(text, roll) {
  if(roll)
    messageLog += `${text} <em class="text-muted">[${roll}]</em><br />`;
  else
    messageLog += text + '<br />';
}

function sendLog() {
  $('#fightlog').prepend(messageLog + '<br />');
  messageLog = '';
}

function clearLog() {
  $("#fightlog").empty();
}

var bubbleCounts = {
  hit: 4,
  damage: 5,
  parry: 4,
  miss: 4
};
function showBubble(fighter, type) {
    $avatar = $('#fighter' + fighter + '-avatar');

    if(type === 'dead') {
        window.setTimeout(function() {
            $('#fighter' + fighter + '-deadbubble').attr('src', '/images/bubbles/dead.png').fadeIn('slow');
            $avatar.toggle('pulsate', function() {
                $avatar.fadeTo(0.2);
            });
        }, 2000);
        return;
    }

    if(type == 'damage') {
        $avatar.effect('shake');
    } else if (type == 'hit' || type == 'miss') {
        if(fighter == 1)
            $avatar.animate({left: '+=50'}, 100).animate({left: '-=50'}, 100);
        else
            $avatar.animate({left: '-=50'}, 100).animate({left: '+=50'}, 100);
    } else if (type == 'parry') {
        if(fighter == 1)
            $avatar.animate({left: '-=50'}, 100).animate({left: '+=50'}, 100);
        else
            $avatar.animate({left: '+=50'}, 100).animate({left: '-=50'}, 100);
    }

    var rndBubble = Math.floor((bubbleRNG() * bubbleCounts[type]) + 1);
    $('#fighter' + fighter + '-bubble').attr('src', '/images/bubbles/' + type + '/' + rndBubble + '.png').fadeIn('fast', function() {
      var bubbleObj = $(this);
      window.setTimeout(function() { $(bubbleObj).fadeOut('fast'); }, 1000);
    });
}

function introduceFighter(fighter, oppIN, first) {
  fos = first ? 'first' : 'second';

  fightLog(`The ${fos} fighter is ${fighter.name} who is ${fighter.job.nameWithArticle} wielding ${fighter.weapon.nameWithArticle}.`);
  fightLog('Their stats are:');
  fightLog(`&nbsp;&nbsp;&nbsp;&nbsp;<h5>IN:</h5> ${fighter.IN}, <h5>AT:</h5> ${fighter.AT}, <h5>PA:</h5> ${fighter.PA}.`);
  sendLog();

  var bonus = fighter.calcINBonus(oppIN);
  if (bonus > 0) {
      fightLog(`${fighter.name}'s extra agility grants an extra bonus of <h5>${bonus}</h5> to their AT! [<h5>${fighter.AT}AT</h5>]`);
      sendLog();
  }
}


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
    return `<h5>${this._name}</h5>`;
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
  constructor(runSpeed) {
    runSpeed = runSpeed || 1000;
    this.runSpeed = runSpeed;
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

    introduceFighter(fighter1, fighter2.IN, true);
    introduceFighter(fighter2, fighter1.IN);

    if (fighter1.IN == fighter2.IN) {
      var rnd = getRandom(2);
      fightLog(`Even though the two fighters are equally quick ${this.fighters[rnd].name} finds a moment of opportunity and makes the first move.`, rnd);
      this.activeFighter = rnd;
    } else {
      var first = 1;
      if(fighter2.IN > fighter1.IN)
        first = 2;

      fightLog(`${this.fighters[first].name} is quicker and makes the first move.`);
      this.activeFighter = first;
    }

    $("#fighter1NameDisplay").text(fighter1.cleanName);
    $("#fighter2NameDisplay").text(fighter2.cleanName);
    $("#fighterDisplay").show();

    this.activeFighter = this.inactiveFighter; // flip because it toggles in endRound
    this.endRound();
  }

  doAttack(attacker, defender) {
    var attackRoll = getRandom(20);
    if (attackRoll <= attacker.AT) {
      showBubble(this.activeFighter, 'hit');
      fightLog(`${attacker.name} makes an attack and it succesfully connects.`, attackRoll);

      var parryRoll = getRandom(20);
      if (parryRoll <= defender.PA) {
        showBubble(this.inactiveFighter, 'parry');
        fightLog(`${defender.name} succesfully parries the attack.`, parryRoll);
        defender.hasParried = true;
      } else {
        showBubble(this.inactiveFighter, 'damage');
        fightLog(`${defender.name} fails to parry and takes a hit.`, parryRoll);
        defender.LP -= 1;

        if (defender.LP <= 0) {
          fightLog(`${defender.name} has died. ${attacker.name} is victorious!`);
        } else {
          fightLog(`${defender.name} has ${defender.LP} LP remaining.`);
        }
      }
    } else {
      showBubble(this.activeFighter, 'miss');
      fightLog(`${attacker.name} fumbles their attack and misses.`, attackRoll);
      if (defender.canCA)
        defender.willCA = true;
    }
  }

  doCounterAttack(attacker, defender) {
    var attackRoll = getRandom(20);
    if (attackRoll <= Math.ceil(attacker.AT / 2)) {
      showBubble(this.activeFighter, 'hit');
      if(defender.hasParried) {
        showBubble(this.inactiveFighter, 'damage');
        fightLog(`${attacker.name} succesfully counter-attacks. ${defender.name} is still recovering from their last parry and takes 1LP of damage!`, attackRoll);
        defender.LP -= 1;
      } else {
        fightLog(`${attacker.name} takes advantage of the failed attack and successfully counter-attacks.`, attackRoll);

        var parryRoll = getRandom(20);
        if (parryRoll <= defender.PA) {
          showBubble(this.inactiveFighter, 'parry');
          fightLog(`${defender.name} succesfully parries the counter-attack.`, parryRoll);
        } else {
          showBubble(this.inactiveFighter, 'damage');
          fightLog(`${defender.name} fails to parry and takes a hit.`, parryRoll);
          defender.LP -= 1;

          if (defender.LP <= 0) {
            fightLog(`${defender.name} has died. ${attacker.name} is victorious!`);
          } else {
            fightLog(`${defender.name} has ${defender.LP} LP remaining.`);
          }
        }
      }
    } else {
      showBubble(this.activeFighter, 'miss');
      fightLog(`${attacker.name} attempts to counter-attack but misses.`, attackRoll);
    }

    this.endRound();
  }

  fight() {
    var attacker = this.fighters[this.activeFighter];
    var defender = this.fighters[this.inactiveFighter];
    defender.hasParried = false;

    this.doAttack(attacker, defender);
    var fightActive = this.updateLPDisplayAndCheckForDeath();

    if (attacker.canCA && attacker.willCA && fightActive) {
      attacker.willCA = false;

      sendLog();

      var _this = this;
      setTimeout(function() { _this.doCounterAttack(attacker, defender); }, this.runSpeed);
      return;
    }

    this.endRound();
  }

    updateLPDisplayAndCheckForDeath() {
        var bothAlive = true;
        for(var i = 1; i < 3; i++) {
            $('#fighter' + i + '-life').css('width', (this.fighters[i].LP / .03) + '%');
            $('#fighter' + i + '-life').text(this.fighters[i].LP + ' LP');

            if (this.fighters[i].isDead) {
                bothAlive = false;
                showBubble(i, 'dead');

                $('#fighter' + i + '-life').text('DEAD');
                $('#fighter' + i + '-life').css('width', '100%');
                $('#fighter' + i + '-life').removeClass('progress-bar-striped progress-bar-animated bg-success').addClass('bg-danger');
            }
        }

        return bothAlive;
    }

  endRound() {
    var fightActive = this.updateLPDisplayAndCheckForDeath();
    sendLog();

    this.activeFighter = this.inactiveFighter;
    if (fightActive) {
      var _this = this;
      setTimeout(function() {_this.fight(); }, this.runSpeed);
    }
  }
}
