// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PehlaPaisa';

  @override
  String get tagline => 'Pehle bachao, phir kharcho';

  @override
  String get splashTipLabel => 'Money tip';

  @override
  String get splashTip1 =>
      'Save first, spend later — even ₹100 a month builds the habit.';

  @override
  String get splashTip2 =>
      'Small savings every month beat a big plan you never start.';

  @override
  String get splashTip3 => '₹50 a day is ₹1,500 a month. Small spends add up!';

  @override
  String get splashTip4 =>
      'An emergency fund turns a crisis into an inconvenience.';

  @override
  String get splashTip5 =>
      'Pay yourself first — your future self is your most important bill.';

  @override
  String get splashTip6 =>
      'When your income goes up, raise your savings first.';

  @override
  String get splashTip7 =>
      'Write down every spend for a week. You\'ll find easy savings.';

  @override
  String get splashTip8 => 'Bachat ki aadat, sabse badi daulat.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDone => 'Done';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonShare => 'Share';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get keypadDelete => 'Delete last digit';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String dayOfMonth(int day) {
    return 'Every month on day $day';
  }

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String nextSalaryOn(String date) {
    return 'Next salary: $date';
  }

  @override
  String salaryForDate(String date) {
    return 'Salary for $date';
  }

  @override
  String get navShelf => 'Shelf';

  @override
  String get navGoals => 'Goals';

  @override
  String get navReport => 'Report';

  @override
  String get navBadges => 'Badges';

  @override
  String get navSettings => 'Settings';

  @override
  String get jarSavings => 'Savings';

  @override
  String get jarRent => 'Rent & Bills';

  @override
  String get jarHome => 'Home contribution';

  @override
  String get jarFood => 'Food';

  @override
  String get jarTravel => 'Travel & Phone';

  @override
  String get jarFun => 'Fun';

  @override
  String glassSemantics(String name, String left, String total) {
    return '$name glass, $left left of $total';
  }

  @override
  String glassSemanticsOverspent(String name, String amount) {
    return '$name glass, overspent by $amount';
  }

  @override
  String get glassHint => 'Tap for details, long-press to add an expense';

  @override
  String jarLeft(String amount) {
    return '$amount left';
  }

  @override
  String jarOver(String amount) {
    return '$amount over';
  }

  @override
  String get jarEmpty => 'Not filled yet';

  @override
  String get onbIntroTitle => 'Pay yourself first';

  @override
  String get onbIntroBody =>
      'Every salary day, fill your Savings glass first. Then fill Rent, Food, Travel and Fun with what\'s left. Spend from the glasses — but never from Savings.';

  @override
  String get onbIntroPoint1 => '🪙  Savings is filled first, every month';

  @override
  String get onbIntroPoint2 => '🫙  Each glass shows what\'s left to spend';

  @override
  String get onbIntroPoint3 => '🔥  Keep your streak going and earn badges';

  @override
  String get onbIntroSub =>
      'On salary day, fill your Savings glass first. Then spend the rest without worry.';

  @override
  String get onbFeat1Title => 'Save first, always';

  @override
  String get onbFeat1Body =>
      'Savings is filled before anything else, every month';

  @override
  String get onbFeat2Title => 'See what\'s left';

  @override
  String get onbFeat2Body =>
      'Each glass shows exactly how much you can still spend';

  @override
  String get onbFeat3Title => 'Build the habit';

  @override
  String get onbFeat3Body => 'Keep your streak going and unlock badges';

  @override
  String get onbStart => 'Let\'s start';

  @override
  String get onbNameTitle => 'What should we call you?';

  @override
  String get onbNameHint => 'Your name';

  @override
  String get onbNameError => 'Please enter your name';

  @override
  String onbIncomeTitle(String name) {
    return 'Nice to meet you, $name! Tell us about your money';
  }

  @override
  String get onbIncomeLabel => 'Monthly income';

  @override
  String get onbIncomeHint => 'e.g. 12,000';

  @override
  String get onbIncomeError => 'Enter an amount between ₹500 and ₹10,00,000';

  @override
  String get onbSalaryDayLabel => 'Salary day';

  @override
  String get onbSalaryDayHelp =>
      'The day your money usually comes in. Each month on your shelf starts on this day.';

  @override
  String get onbIncomeTypeLabel => 'How do you get paid?';

  @override
  String get incomeFixed => 'Fixed salary';

  @override
  String get incomeFixedDesc => 'About the same amount every month';

  @override
  String get incomeIrregular => 'Irregular income';

  @override
  String get incomeIrregularDesc =>
      'Gigs, freelance, tuitions — the amount changes';

  @override
  String get onbFamilyTitle => 'Do you live with family?';

  @override
  String get onbFamilyBody =>
      'If you live with family, Rent becomes a smaller \"Home contribution\" and the extra goes to Savings.';

  @override
  String get onbFamilyYes => 'Yes, with family';

  @override
  String get onbFamilyNo => 'No, on my own';

  @override
  String get onbSplitTitle => 'Your suggested split';

  @override
  String onbSplitBody(String income) {
    return 'For $income a month. Drag to adjust — Fun gets whatever is left.';
  }

  @override
  String get onbFinish => 'Start saving';

  @override
  String get splitTotalLabel => 'Total';

  @override
  String get splitFunLeft => 'Fun gets whatever is left over';

  @override
  String get lowSavingsTitle => 'Save at least a little?';

  @override
  String get lowSavingsBody =>
      'Saving first — even ₹100 — builds the habit. When savings come last, there\'s usually nothing left. Do you really want to save less than 5%?';

  @override
  String get lowSavingsKeep => 'Keep 5%';

  @override
  String get lowSavingsConfirm => 'Yes, I\'m sure';

  @override
  String get homeLeftToSpend => 'left to spend this month';

  @override
  String homeDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String streakChip(int count) {
    return '🔥 $count';
  }

  @override
  String streakLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months of paying yourself first',
      one: '1 month of paying yourself first',
      zero: 'Start your streak this month',
    );
    return '🔥 $_temp0';
  }

  @override
  String get homeFillBanner => 'Salary day! Fill your Savings glass first 🟡';

  @override
  String get homeFillButton => 'Fill my glasses';

  @override
  String get homeIncomeButton => 'Income received';

  @override
  String get homeAddExpense => 'Add expense';

  @override
  String get homeShare => 'Share progress';

  @override
  String homeTotalSaved(String amount) {
    return 'Total saved $amount';
  }

  @override
  String homeGreeting(String name) {
    return 'Hi $name';
  }

  @override
  String alertLow(String jar, int percent, int days) {
    return 'Your $jar glass is $percent% empty with $days days left';
  }

  @override
  String alertFoodWeekly(String spent, String limit) {
    return 'Food this week: $spent — more than your weekly $limit';
  }

  @override
  String get alertDismiss => 'Hide this warning';

  @override
  String get weeklyLimitsTitle => 'This week\'s limits';

  @override
  String get weeklyLimitsHint =>
      'Stay under these each week and your glasses last the whole month';

  @override
  String weeklyLimitPerWeek(String amount) {
    return '$amount/week';
  }

  @override
  String weeklyLimitLeft(String spent, String left) {
    return '$spent spent · $left left this week';
  }

  @override
  String weeklyLimitOver(String spent, String over) {
    return '$spent spent · $over over this week';
  }

  @override
  String weeklyLimitTitleFor(String jar) {
    return 'Weekly limit – $jar';
  }

  @override
  String get weeklySummaryTitle => 'This week';

  @override
  String weeklySummaryBody(String amount) {
    return 'You\'ve spent $amount since Monday';
  }

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get addNoteHint => 'Note (optional)';

  @override
  String get addPickJar => 'From which glass?';

  @override
  String get addSave => 'Save expense';

  @override
  String get addEnterAmount => 'Enter an amount';

  @override
  String expenseSaved(String amount, String jar) {
    return '$amount spent from $jar';
  }

  @override
  String get fillFirstTitle => 'Fill your glasses first';

  @override
  String get fillFirstBody =>
      'Pour this month\'s money into your glasses — Savings first — before you log spending.';

  @override
  String overflowTitle(String jar) {
    return 'Not enough in $jar';
  }

  @override
  String overflowBody(String amount, String jar, String left, String short) {
    return 'This costs $amount but $jar has only $left. Borrow the extra $short from:';
  }

  @override
  String overflowOption(String jar, String left) {
    return '$jar · $left left';
  }

  @override
  String get overflowNothing => 'Your other glasses are empty.';

  @override
  String get overflowBorrow => 'Borrow';

  @override
  String get overflowOverspend => 'Log anyway — glass goes below zero';

  @override
  String get overflowBreakSavings => 'Break my savings';

  @override
  String get breakTitle => 'Break your savings?';

  @override
  String breakBody(String amount) {
    return 'Savings is your future self\'s money. Taking $amount from it ends your streak this month. Are you really sure?';
  }

  @override
  String get breakConfirm => 'Break my savings';

  @override
  String get breakCancel => 'Keep it safe';

  @override
  String get payScan => 'Pay with UPI';

  @override
  String get payTitle => 'Pay with UPI';

  @override
  String payFrom(String jar, String left) {
    return 'From $jar · $left left';
  }

  @override
  String payBorrowWarning(String amount) {
    return '$amount more than this glass has. It will be borrowed from Fun first — never from Savings.';
  }

  @override
  String payOverspendWarning(String amount) {
    return '$amount more than all your glasses have left. This glass will go below zero.';
  }

  @override
  String get payToLabel => 'Paying to (optional)';

  @override
  String get payToHint => 'e.g. Chai shop, Ramesh';

  @override
  String payButton(String amount) {
    return 'Open UPI app · $amount';
  }

  @override
  String get payHowTitle => 'How it works';

  @override
  String get paySteps =>
      '1. Pick your UPI app (Google Pay, PhonePe, Paytm…).\n2. In that app, scan the QR or choose the person, and pay.\n3. Come back here — tap \"Yes, paid\" and it\'s added to this glass.';

  @override
  String get payHandOff =>
      'You pay inside your own UPI app, so it always works like a normal payment. PehlaPaisa never sees your UPI PIN or bank details.';

  @override
  String get payNoUpiApp => 'No UPI app found on this phone';

  @override
  String get payConfirmTitle => 'Did the payment go through?';

  @override
  String payConfirmBody(String amount) {
    return 'Did you pay $amount?';
  }

  @override
  String payConfirmBodyTo(String amount, String name) {
    return 'Did you pay $amount to $name?';
  }

  @override
  String get payConfirmYes => 'Yes, paid';

  @override
  String get payConfirmNo => 'No / failed';

  @override
  String payRecorded(String amount, String jar) {
    return '$amount added to $jar';
  }

  @override
  String get payNotRecorded => 'Nothing was recorded';

  @override
  String payExpenseNote(String name) {
    return 'UPI · $name';
  }

  @override
  String get payExpenseNotePlain => 'UPI payment';

  @override
  String payWithTitle(String amount) {
    return 'Pay $amount with';
  }

  @override
  String payWithHint(String amount) {
    return 'The app opens. Scan the QR there and pay $amount, then come back.';
  }

  @override
  String get payTryAnother => 'Open another app';

  @override
  String get jarAllocated => 'Poured in';

  @override
  String get jarSpent => 'Spent';

  @override
  String get jarRemaining => 'Left';

  @override
  String get jarWeeklyLimit => 'Weekly food budget';

  @override
  String jarWeeklyProgress(String spent, String limit) {
    return '$spent of $limit this week';
  }

  @override
  String get jarHistory => 'This month';

  @override
  String get jarNoTransactions => 'No spending yet this month';

  @override
  String get jarMoveMoney => 'Move money';

  @override
  String get jarSavingsInfo =>
      'Savings is protected. It never pays for other glasses unless you choose to break it.';

  @override
  String get jarGone => 'This glass no longer exists.';

  @override
  String txnBorrowedFrom(String jar) {
    return 'Borrowed from $jar';
  }

  @override
  String txnLentTo(String jar) {
    return 'Moved to $jar';
  }

  @override
  String txnToGoal(String goal) {
    return 'Set aside for $goal';
  }

  @override
  String get txnExpense => 'Expense';

  @override
  String get deleteExpenseTitle => 'Delete this expense?';

  @override
  String deleteExpenseBody(String amount, String jar) {
    return '$amount will go back into the $jar glass.';
  }

  @override
  String get moveTitle => 'Move money';

  @override
  String get moveFrom => 'From';

  @override
  String get moveTo => 'To';

  @override
  String moveAvailable(String amount) {
    return '$amount available';
  }

  @override
  String get moveButton => 'Move';

  @override
  String moveDone(String amount, String jar) {
    return 'Moved $amount to $jar';
  }

  @override
  String get salaryTitle => 'Salary day!';

  @override
  String get salaryIncomeTitle => 'Income received';

  @override
  String get salaryAmountLabel => 'This month\'s salary';

  @override
  String get salaryChangeAmount => 'Different amount this month?';

  @override
  String get salaryFillSavings => 'Fill Savings First';

  @override
  String get salaryIntro =>
      'Before anything else, pay yourself. Tap below and watch your Savings glass fill.';

  @override
  String get salaryPouring => 'Pouring into Savings…';

  @override
  String get salaryFillingOthers => 'Now filling your other glasses…';

  @override
  String get salaryDone => 'All glasses filled!';

  @override
  String salaryDoneBody(String amount) {
    return 'You paid yourself first. $amount is safe in Savings.';
  }

  @override
  String get salaryGoShelf => 'Go to my shelf';

  @override
  String get salaryIncomeHint =>
      'Enter the amount you received. It\'s split with your usual percentages — Savings first.';

  @override
  String salaryReceivedSoFar(String amount) {
    return 'Received this month: $amount';
  }

  @override
  String get goalsTitle => 'Goals';

  @override
  String get goalsFree => 'Free savings';

  @override
  String get goalsFreeHelp => 'Savings not yet given to a goal';

  @override
  String get goalsEmpty => 'No goals yet. What are you saving for?';

  @override
  String get goalsSuggestTitle => 'Start with an Emergency Fund';

  @override
  String goalsSuggestBody(String amount) {
    return '3 months of expenses = $amount. It keeps you safe when life surprises you.';
  }

  @override
  String get goalsSuggestButton => 'Create Emergency Fund';

  @override
  String get goalEmergencyName => 'Emergency Fund';

  @override
  String get goalAdd => 'New goal';

  @override
  String get goalEdit => 'Edit goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get goalNameHint => 'e.g. New phone';

  @override
  String get goalNameError => 'Give your goal a name';

  @override
  String get goalTarget => 'Target amount';

  @override
  String get goalTargetError => 'Enter a target amount';

  @override
  String get goalTargetDate => 'Target date (optional)';

  @override
  String get goalNoDate => 'No date';

  @override
  String get goalPickIcon => 'Pick an icon';

  @override
  String goalProgress(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String goalEstimate(String rate, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return 'At $rate/month you\'ll reach this in $_temp0';
  }

  @override
  String get goalEstimateNone =>
      'Save something every month to see when you\'ll get there';

  @override
  String goalNeedPerMonth(String amount, String date) {
    return 'Save $amount/month to reach it by $date';
  }

  @override
  String get goalReached => 'Goal reached! 🎉';

  @override
  String get goalAddMoney => 'Add from savings';

  @override
  String get goalTakeBack => 'Take back';

  @override
  String goalMoveTitle(String goal) {
    return 'Move savings into $goal';
  }

  @override
  String goalTakeBackTitle(String goal) {
    return 'Take money back from $goal';
  }

  @override
  String get goalNoFreeSavings =>
      'No free savings to move yet. Fill your Savings glass first!';

  @override
  String goalMoved(String amount, String goal) {
    return '$amount added to $goal';
  }

  @override
  String get goalDeleteTitle => 'Delete this goal?';

  @override
  String get goalDeleteBody =>
      'Money in this goal goes back to your free savings.';

  @override
  String goalPercent(int percent) {
    return '$percent% filled';
  }

  @override
  String get reportTitle => 'Monthly report';

  @override
  String reportSavedPercent(int percent) {
    return 'You saved $percent% of your income';
  }

  @override
  String reportSavedAmount(String amount) {
    return '$amount kept safe in Savings';
  }

  @override
  String reportTotalSpent(String amount) {
    return 'Total spent $amount';
  }

  @override
  String get reportWhereMoneyWent => 'Where your money went';

  @override
  String get reportNoSpending => 'No spending recorded this month';

  @override
  String get reportLast6 => 'Savings — last 6 months';

  @override
  String get reportBestJar => 'Best glass';

  @override
  String get reportWorstJar => 'Needs attention';

  @override
  String reportUsed(int percent) {
    return '$percent% used';
  }

  @override
  String get reportVsLastMonth => 'Compared to last month';

  @override
  String reportSpentMore(int percent) {
    return 'You spent $percent% more';
  }

  @override
  String reportSpentLess(int percent) {
    return 'You spent $percent% less';
  }

  @override
  String get reportSpentSame => 'You spent about the same';

  @override
  String reportSavedMore(String amount) {
    return '$amount more saved';
  }

  @override
  String reportSavedLess(String amount) {
    return '$amount less saved';
  }

  @override
  String get reportSavedSame => 'Same savings as last month';

  @override
  String get reportNoPrevious => 'No previous month to compare yet';

  @override
  String get reportNotFunded => 'This month\'s glasses aren\'t filled yet.';

  @override
  String get reportNoData => 'Your report appears after your first salary day.';

  @override
  String get reportTipTitle => 'Money tip';

  @override
  String get reportTip1 =>
      'Keep 3 months of expenses as an emergency fund before big purchases.';

  @override
  String get reportTip2 =>
      'Small daily spends add up — ₹50 a day is ₹1,500 a month.';

  @override
  String get reportTip3 =>
      'When your income goes up, raise your savings first, then your spending.';

  @override
  String get reportTip4 =>
      'Write down every spend for a week — you\'ll spot easy savings.';

  @override
  String get reportDisclaimer =>
      'General tips for learning only — not financial advice.';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get levelTitle => 'Your level';

  @override
  String levelToNext(String amount, String level) {
    return '$amount more to become $level';
  }

  @override
  String get levelMax => 'You\'ve reached the top level!';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelSaver => 'Saver';

  @override
  String get levelSmartSaver => 'Smart Saver';

  @override
  String get levelGullakMaster => 'Gullak Master';

  @override
  String get levelLegend => 'PehlaPaisa Legend';

  @override
  String get badgeLocked => 'Locked';

  @override
  String badgeUnlockedOn(String date) {
    return 'Unlocked $date';
  }

  @override
  String badgesCount(int unlocked, int total) {
    return '$unlocked of $total unlocked';
  }

  @override
  String get badgePehlaKadam => 'Pehla Kadam';

  @override
  String get badgePehlaKadamDesc => 'Set up your shelf';

  @override
  String get badgePehlaPaisa => 'Pehla Paisa';

  @override
  String get badgePehlaPaisaDesc => 'Filled Savings first for the first time';

  @override
  String get badgeStreak3 => 'Streak 3';

  @override
  String get badgeStreak3Desc => '3 months in a row of paying yourself first';

  @override
  String get badgeStreak6 => 'Streak 6';

  @override
  String get badgeStreak6Desc => '6 months in a row of paying yourself first';

  @override
  String get badgeStreak12 => 'Streak 12';

  @override
  String get badgeStreak12Desc => 'A full year of paying yourself first';

  @override
  String get badgeGullakMaster => 'Gullak Master';

  @override
  String get badgeGullakMasterDesc => 'Saved ₹10,000 in total';

  @override
  String get badgeGoalGetter => 'Goal Getter';

  @override
  String get badgeGoalGetterDesc => 'Completed your first goal';

  @override
  String get badgeFunUnderControl => 'Fun Under Control';

  @override
  String get badgeFunUnderControlDesc =>
      'Finished a month without Fun going below zero or borrowing';

  @override
  String get badgeLogger => 'Logger';

  @override
  String get badgeLoggerDesc => 'Logged spending 7 days in a row';

  @override
  String get badgeBachatChampion => 'Bachat Champion';

  @override
  String get badgeBachatChampionDesc =>
      'Saved 25% or more of your income in a month';

  @override
  String get celebrateBadge => 'Badge unlocked!';

  @override
  String get celebrateGoal => 'Goal complete!';

  @override
  String celebrateGoalBody(String goal) {
    return 'You filled your $goal glass to the top.';
  }

  @override
  String get celebrateStreak => 'New streak month!';

  @override
  String get celebrateSavings => 'Savings filled first!';

  @override
  String get celebrateContinue => 'Yay! Continue';

  @override
  String get shareTitle => 'Share your progress';

  @override
  String get shareStory => 'Story';

  @override
  String get sharePost => 'Post';

  @override
  String get shareCardStreak => 'Streak';

  @override
  String get shareCardSaved => 'Saved';

  @override
  String get shareShowAmounts => 'Show amounts';

  @override
  String get shareShowAmountsHint =>
      'Off by default — your income and balances stay private';

  @override
  String get shareButton => 'Share image';

  @override
  String shareStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '🔥 $_temp0 of paying myself first';
  }

  @override
  String shareSavedTitle(String amount) {
    return 'I saved $amount with PehlaPaisa';
  }

  @override
  String get shareSavedTitleHidden =>
      'I\'m paying myself first with PehlaPaisa';

  @override
  String shareSavedSub(int percent) {
    return '$percent% of my income goes to savings first';
  }

  @override
  String shareGoalTitle(String goal) {
    return 'Goal complete: $goal';
  }

  @override
  String shareGoalSub(String amount) {
    return '$amount saved';
  }

  @override
  String get shareGoalSubHidden => 'Filled to the top 🎉';

  @override
  String shareBadgeTitle(String badge) {
    return 'Badge unlocked: $badge';
  }

  @override
  String shareMessage(String link) {
    return 'Pehle bachao, phir kharcho — I\'m building the savings habit with PehlaPaisa. Free app: $link';
  }

  @override
  String get shareCardOnPlay => 'Free on Google Play';

  @override
  String get shareCardFree => 'Free app · English & Hindi';

  @override
  String get settingsInvite => 'Invite a friend';

  @override
  String get settingsInviteDesc => 'Share PehlaPaisa on WhatsApp or anywhere';

  @override
  String inviteMessage(String link) {
    return 'Salary aate hi pehle bachao, phir kharcho 💰\nPehlaPaisa try karo — har mahine savings pakki. Free hai, Hindi mein bhi:\n$link';
  }

  @override
  String get shareFailed => 'Couldn\'t create the image. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsEditProfile => 'Edit profile';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsIncome => 'Monthly income';

  @override
  String get settingsSalaryDay => 'Salary day';

  @override
  String get settingsSalaryDayNote =>
      'A new salary day applies from your next month.';

  @override
  String get settingsIncomeType => 'Income type';

  @override
  String get settingsFamily => 'Living with family';

  @override
  String get settingsEditSplit => 'Edit split';

  @override
  String get settingsEditSplitDesc => 'Change how your income is divided';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Night shelf (dark)';

  @override
  String get themeLight => 'Morning shelf (light)';

  @override
  String get settingsNotifications => 'Reminders';

  @override
  String get notifMaster => 'Allow notifications';

  @override
  String get notifSalary => 'Salary day reminder';

  @override
  String get notifWeekly => 'Weekly check-in (Sunday evening)';

  @override
  String get notifLowBalance => 'Low glass alerts';

  @override
  String get notifDaily => 'Daily reminder to log spending';

  @override
  String get notifDailyTime => 'Reminder time';

  @override
  String get notifPermissionDenied =>
      'Notifications are turned off for PehlaPaisa in your phone settings.';

  @override
  String get settingsSharing => 'Sharing';

  @override
  String get settingsData => 'Your data';

  @override
  String get settingsExport => 'Export data (JSON)';

  @override
  String get settingsExportDesc => 'Save or send a copy of all your data';

  @override
  String get settingsReset => 'Reset all data';

  @override
  String get settingsResetDesc => 'Delete everything and start fresh';

  @override
  String get resetTitle1 => 'Reset everything?';

  @override
  String get resetBody1 =>
      'All glasses, spending, goals, streaks and badges will be deleted from this phone.';

  @override
  String get resetTitle2 => 'Are you absolutely sure?';

  @override
  String get resetBody2 =>
      'This cannot be undone. There is no backup unless you exported your data.';

  @override
  String get resetConfirm => 'Yes, delete everything';

  @override
  String get resetDone => 'All data deleted';

  @override
  String get settingsAbout => 'About PehlaPaisa';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get splitEditorTitle => 'Edit split';

  @override
  String get splitEditorHint =>
      'Changes apply from your next fill. Fun gets whatever is left.';

  @override
  String splitEditorIncome(String amount) {
    return 'Based on monthly income $amount';
  }

  @override
  String get splitUseSuggested => 'Use suggested split';

  @override
  String get splitSaved => 'Split saved';

  @override
  String get customJarAdd => 'Add a custom glass';

  @override
  String get customJarName => 'Glass name';

  @override
  String get customJarNameHint => 'e.g. Medicines';

  @override
  String get customJarRemove => 'Remove glass';

  @override
  String get customJarRemoveBody => 'Its money and plan go to Fun.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutBody =>
      'PehlaPaisa helps you build one habit: on salary day, fill your Savings glass first. Then spend from your other glasses without guilt — they show exactly what\'s left.';

  @override
  String get aboutPrivacyTitle => 'Your privacy';

  @override
  String get aboutPrivacy =>
      'Your budget stays on this phone: no login, no cloud, no bank or SMS access. The app shows a few ads from Google AdMob; to show them, Google receives your device\'s advertising ID and basic device info — never your budget. Payments happen in your own UPI app — PehlaPaisa never sees your PIN or bank details.';

  @override
  String get aboutDisclaimerTitle => 'Not financial advice';

  @override
  String get aboutDisclaimer =>
      'PehlaPaisa shares general, educational money tips only. It does not give investment or financial advice.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutMadeWith =>
      'Made with care for first-job workers, students, freelancers and gig workers.';

  @override
  String get notifWelcomeTitle => 'Reminders are on 🔔';

  @override
  String get notifWelcomeBody =>
      'We\'ll remind you on salary day, every Sunday evening, and when a glass is running low.';

  @override
  String get notifTestButton => 'Send a test notification';

  @override
  String get notifTestDesc => 'See how your salary-day reminder looks';

  @override
  String get notifChannel => 'Reminders';

  @override
  String get notifSalaryTitle => 'Salary day!';

  @override
  String get notifSalaryBody => 'Salary day! Fill your Savings glass first 🟡';

  @override
  String get notifWeeklyTitle => 'Weekly check-in';

  @override
  String notifWeeklyBody(String amount) {
    return 'This week you spent $amount so far. Open PehlaPaisa to see your glasses.';
  }

  @override
  String get notifDailyTitle => 'Quick check';

  @override
  String get notifDailyBody => 'Log today\'s spending';

  @override
  String get notifLowTitle => 'Glass running low';
}
