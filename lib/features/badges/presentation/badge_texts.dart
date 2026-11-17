import '../../../app/l10n.dart';
import '../data/badge.dart';
import '../domain/levels.dart';

String badgeName(AppLocalizations l, BadgeKey k) {
  switch (k) {
    case BadgeKey.pehlaKadam:
      return l.badgePehlaKadam;
    case BadgeKey.pehlaPaisa:
      return l.badgePehlaPaisa;
    case BadgeKey.streak3:
      return l.badgeStreak3;
    case BadgeKey.streak6:
      return l.badgeStreak6;
    case BadgeKey.streak12:
      return l.badgeStreak12;
    case BadgeKey.gullakMaster:
      return l.badgeGullakMaster;
    case BadgeKey.goalGetter:
      return l.badgeGoalGetter;
    case BadgeKey.funUnderControl:
      return l.badgeFunUnderControl;
    case BadgeKey.logger:
      return l.badgeLogger;
    case BadgeKey.bachatChampion:
      return l.badgeBachatChampion;
  }
}

String badgeDescription(AppLocalizations l, BadgeKey k) {
  switch (k) {
    case BadgeKey.pehlaKadam:
      return l.badgePehlaKadamDesc;
    case BadgeKey.pehlaPaisa:
      return l.badgePehlaPaisaDesc;
    case BadgeKey.streak3:
      return l.badgeStreak3Desc;
    case BadgeKey.streak6:
      return l.badgeStreak6Desc;
    case BadgeKey.streak12:
      return l.badgeStreak12Desc;
    case BadgeKey.gullakMaster:
      return l.badgeGullakMasterDesc;
    case BadgeKey.goalGetter:
      return l.badgeGoalGetterDesc;
    case BadgeKey.funUnderControl:
      return l.badgeFunUnderControlDesc;
    case BadgeKey.logger:
      return l.badgeLoggerDesc;
    case BadgeKey.bachatChampion:
      return l.badgeBachatChampionDesc;
  }
}

String levelName(AppLocalizations l, UserLevel level) {
  switch (level) {
    case UserLevel.beginner:
      return l.levelBeginner;
    case UserLevel.saver:
      return l.levelSaver;
    case UserLevel.smartSaver:
      return l.levelSmartSaver;
    case UserLevel.gullakMaster:
      return l.levelGullakMaster;
    case UserLevel.legend:
      return l.levelLegend;
  }
}

const Map<UserLevel, String> levelEmoji = {
  UserLevel.beginner: '🌱',
  UserLevel.saver: '🪴',
  UserLevel.smartSaver: '🌳',
  UserLevel.gullakMaster: '🐷',
  UserLevel.legend: '👑',
};
