import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PehlaPaisa'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Pehle bachao, phir kharcho'**
  String get tagline;

  /// No description provided for @splashTipLabel.
  ///
  /// In en, this message translates to:
  /// **'Money tip'**
  String get splashTipLabel;

  /// No description provided for @splashTip1.
  ///
  /// In en, this message translates to:
  /// **'Save first, spend later — even ₹100 a month builds the habit.'**
  String get splashTip1;

  /// No description provided for @splashTip2.
  ///
  /// In en, this message translates to:
  /// **'Small savings every month beat a big plan you never start.'**
  String get splashTip2;

  /// No description provided for @splashTip3.
  ///
  /// In en, this message translates to:
  /// **'₹50 a day is ₹1,500 a month. Small spends add up!'**
  String get splashTip3;

  /// No description provided for @splashTip4.
  ///
  /// In en, this message translates to:
  /// **'An emergency fund turns a crisis into an inconvenience.'**
  String get splashTip4;

  /// No description provided for @splashTip5.
  ///
  /// In en, this message translates to:
  /// **'Pay yourself first — your future self is your most important bill.'**
  String get splashTip5;

  /// No description provided for @splashTip6.
  ///
  /// In en, this message translates to:
  /// **'When your income goes up, raise your savings first.'**
  String get splashTip6;

  /// No description provided for @splashTip7.
  ///
  /// In en, this message translates to:
  /// **'Write down every spend for a week. You\'ll find easy savings.'**
  String get splashTip7;

  /// No description provided for @splashTip8.
  ///
  /// In en, this message translates to:
  /// **'Bachat ki aadat, sabse badi daulat.'**
  String get splashTip8;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @keypadDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete last digit'**
  String get keypadDelete;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Every month on day {day}'**
  String dayOfMonth(int day);

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @nextSalaryOn.
  ///
  /// In en, this message translates to:
  /// **'Next salary: {date}'**
  String nextSalaryOn(String date);

  /// No description provided for @salaryForDate.
  ///
  /// In en, this message translates to:
  /// **'Salary for {date}'**
  String salaryForDate(String date);

  /// No description provided for @navShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get navShelf;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get navReport;

  /// No description provided for @navBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get navBadges;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @jarSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get jarSavings;

  /// No description provided for @jarRent.
  ///
  /// In en, this message translates to:
  /// **'Rent & Bills'**
  String get jarRent;

  /// No description provided for @jarHome.
  ///
  /// In en, this message translates to:
  /// **'Home contribution'**
  String get jarHome;

  /// No description provided for @jarFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get jarFood;

  /// No description provided for @jarTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel & Phone'**
  String get jarTravel;

  /// No description provided for @jarFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get jarFun;

  /// No description provided for @glassSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name} glass, {left} left of {total}'**
  String glassSemantics(String name, String left, String total);

  /// No description provided for @glassSemanticsOverspent.
  ///
  /// In en, this message translates to:
  /// **'{name} glass, overspent by {amount}'**
  String glassSemanticsOverspent(String name, String amount);

  /// No description provided for @glassHint.
  ///
  /// In en, this message translates to:
  /// **'Tap for details, long-press to add an expense'**
  String get glassHint;

  /// No description provided for @jarLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String jarLeft(String amount);

  /// No description provided for @jarOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String jarOver(String amount);

  /// No description provided for @jarEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not filled yet'**
  String get jarEmpty;

  /// No description provided for @onbIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay yourself first'**
  String get onbIntroTitle;

  /// No description provided for @onbIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Every salary day, fill your Savings glass first. Then fill Rent, Food, Travel and Fun with what\'s left. Spend from the glasses — but never from Savings.'**
  String get onbIntroBody;

  /// No description provided for @onbIntroPoint1.
  ///
  /// In en, this message translates to:
  /// **'🪙  Savings is filled first, every month'**
  String get onbIntroPoint1;

  /// No description provided for @onbIntroPoint2.
  ///
  /// In en, this message translates to:
  /// **'🫙  Each glass shows what\'s left to spend'**
  String get onbIntroPoint2;

  /// No description provided for @onbIntroPoint3.
  ///
  /// In en, this message translates to:
  /// **'🔥  Keep your streak going and earn badges'**
  String get onbIntroPoint3;

  /// No description provided for @onbIntroSub.
  ///
  /// In en, this message translates to:
  /// **'On salary day, fill your Savings glass first. Then spend the rest without worry.'**
  String get onbIntroSub;

  /// No description provided for @onbFeat1Title.
  ///
  /// In en, this message translates to:
  /// **'Save first, always'**
  String get onbFeat1Title;

  /// No description provided for @onbFeat1Body.
  ///
  /// In en, this message translates to:
  /// **'Savings is filled before anything else, every month'**
  String get onbFeat1Body;

  /// No description provided for @onbFeat2Title.
  ///
  /// In en, this message translates to:
  /// **'See what\'s left'**
  String get onbFeat2Title;

  /// No description provided for @onbFeat2Body.
  ///
  /// In en, this message translates to:
  /// **'Each glass shows exactly how much you can still spend'**
  String get onbFeat2Body;

  /// No description provided for @onbFeat3Title.
  ///
  /// In en, this message translates to:
  /// **'Build the habit'**
  String get onbFeat3Title;

  /// No description provided for @onbFeat3Body.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak going and unlock badges'**
  String get onbFeat3Body;

  /// No description provided for @onbStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start'**
  String get onbStart;

  /// No description provided for @onbNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onbNameTitle;

  /// No description provided for @onbNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onbNameHint;

  /// No description provided for @onbNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get onbNameError;

  /// No description provided for @onbIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Nice to meet you, {name}! Tell us about your money'**
  String onbIncomeTitle(String name);

  /// No description provided for @onbIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get onbIncomeLabel;

  /// No description provided for @onbIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12,000'**
  String get onbIncomeHint;

  /// No description provided for @onbIncomeError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between ₹500 and ₹10,00,000'**
  String get onbIncomeError;

  /// No description provided for @onbSalaryDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary day'**
  String get onbSalaryDayLabel;

  /// No description provided for @onbSalaryDayHelp.
  ///
  /// In en, this message translates to:
  /// **'The day your money usually comes in. Each month on your shelf starts on this day.'**
  String get onbSalaryDayHelp;

  /// No description provided for @onbIncomeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'How do you get paid?'**
  String get onbIncomeTypeLabel;

  /// No description provided for @incomeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed salary'**
  String get incomeFixed;

  /// No description provided for @incomeFixedDesc.
  ///
  /// In en, this message translates to:
  /// **'About the same amount every month'**
  String get incomeFixedDesc;

  /// No description provided for @incomeIrregular.
  ///
  /// In en, this message translates to:
  /// **'Irregular income'**
  String get incomeIrregular;

  /// No description provided for @incomeIrregularDesc.
  ///
  /// In en, this message translates to:
  /// **'Gigs, freelance, tuitions — the amount changes'**
  String get incomeIrregularDesc;

  /// No description provided for @onbFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you live with family?'**
  String get onbFamilyTitle;

  /// No description provided for @onbFamilyBody.
  ///
  /// In en, this message translates to:
  /// **'If you live with family, Rent becomes a smaller \"Home contribution\" and the extra goes to Savings.'**
  String get onbFamilyBody;

  /// No description provided for @onbFamilyYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, with family'**
  String get onbFamilyYes;

  /// No description provided for @onbFamilyNo.
  ///
  /// In en, this message translates to:
  /// **'No, on my own'**
  String get onbFamilyNo;

  /// No description provided for @onbSplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Your suggested split'**
  String get onbSplitTitle;

  /// No description provided for @onbSplitBody.
  ///
  /// In en, this message translates to:
  /// **'For {income} a month. Drag to adjust — Fun gets whatever is left.'**
  String onbSplitBody(String income);

  /// No description provided for @onbFinish.
  ///
  /// In en, this message translates to:
  /// **'Start saving'**
  String get onbFinish;

  /// No description provided for @splitTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get splitTotalLabel;

  /// No description provided for @splitFunLeft.
  ///
  /// In en, this message translates to:
  /// **'Fun gets whatever is left over'**
  String get splitFunLeft;

  /// No description provided for @lowSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Save at least a little?'**
  String get lowSavingsTitle;

  /// No description provided for @lowSavingsBody.
  ///
  /// In en, this message translates to:
  /// **'Saving first — even ₹100 — builds the habit. When savings come last, there\'s usually nothing left. Do you really want to save less than 5%?'**
  String get lowSavingsBody;

  /// No description provided for @lowSavingsKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep 5%'**
  String get lowSavingsKeep;

  /// No description provided for @lowSavingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m sure'**
  String get lowSavingsConfirm;

  /// No description provided for @homeLeftToSpend.
  ///
  /// In en, this message translates to:
  /// **'left to spend this month'**
  String get homeLeftToSpend;

  /// No description provided for @homeDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String homeDaysLeft(int days);

  /// No description provided for @streakChip.
  ///
  /// In en, this message translates to:
  /// **'🔥 {count}'**
  String streakChip(int count);

  /// No description provided for @streakLong.
  ///
  /// In en, this message translates to:
  /// **'🔥 {count, plural, =0{Start your streak this month} =1{1 month of paying yourself first} other{{count} months of paying yourself first}}'**
  String streakLong(int count);

  /// No description provided for @homeFillBanner.
  ///
  /// In en, this message translates to:
  /// **'Salary day! Fill your Savings glass first 🟡'**
  String get homeFillBanner;

  /// No description provided for @homeFillButton.
  ///
  /// In en, this message translates to:
  /// **'Fill my glasses'**
  String get homeFillButton;

  /// No description provided for @homeIncomeButton.
  ///
  /// In en, this message translates to:
  /// **'Income received'**
  String get homeIncomeButton;

  /// No description provided for @homeAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get homeAddExpense;

  /// No description provided for @homeShare.
  ///
  /// In en, this message translates to:
  /// **'Share progress'**
  String get homeShare;

  /// No description provided for @homeTotalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total saved {amount}'**
  String homeTotalSaved(String amount);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}'**
  String homeGreeting(String name);

  /// No description provided for @alertLow.
  ///
  /// In en, this message translates to:
  /// **'Your {jar} glass is {percent}% empty with {days} days left'**
  String alertLow(String jar, int percent, int days);

  /// No description provided for @alertFoodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Food this week: {spent} — more than your weekly {limit}'**
  String alertFoodWeekly(String spent, String limit);

  /// No description provided for @alertDismiss.
  ///
  /// In en, this message translates to:
  /// **'Hide this warning'**
  String get alertDismiss;

  /// No description provided for @weeklyLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'This week\'s limits'**
  String get weeklyLimitsTitle;

  /// No description provided for @weeklyLimitsHint.
  ///
  /// In en, this message translates to:
  /// **'Stay under these each week and your glasses last the whole month'**
  String get weeklyLimitsHint;

  /// No description provided for @weeklyLimitPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{amount}/week'**
  String weeklyLimitPerWeek(String amount);

  /// No description provided for @weeklyLimitLeft.
  ///
  /// In en, this message translates to:
  /// **'{spent} spent · {left} left this week'**
  String weeklyLimitLeft(String spent, String left);

  /// No description provided for @weeklyLimitOver.
  ///
  /// In en, this message translates to:
  /// **'{spent} spent · {over} over this week'**
  String weeklyLimitOver(String spent, String over);

  /// No description provided for @weeklyLimitTitleFor.
  ///
  /// In en, this message translates to:
  /// **'Weekly limit – {jar}'**
  String weeklyLimitTitleFor(String jar);

  /// No description provided for @weeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weeklySummaryTitle;

  /// No description provided for @weeklySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {amount} since Monday'**
  String weeklySummaryBody(String amount);

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseTitle;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get addNoteHint;

  /// No description provided for @addPickJar.
  ///
  /// In en, this message translates to:
  /// **'From which glass?'**
  String get addPickJar;

  /// No description provided for @addSave.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get addSave;

  /// No description provided for @addEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get addEnterAmount;

  /// No description provided for @expenseSaved.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent from {jar}'**
  String expenseSaved(String amount, String jar);

  /// No description provided for @fillFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill your glasses first'**
  String get fillFirstTitle;

  /// No description provided for @fillFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Pour this month\'s money into your glasses — Savings first — before you log spending.'**
  String get fillFirstBody;

  /// No description provided for @overflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough in {jar}'**
  String overflowTitle(String jar);

  /// No description provided for @overflowBody.
  ///
  /// In en, this message translates to:
  /// **'This costs {amount} but {jar} has only {left}. Borrow the extra {short} from:'**
  String overflowBody(String amount, String jar, String left, String short);

  /// No description provided for @overflowOption.
  ///
  /// In en, this message translates to:
  /// **'{jar} · {left} left'**
  String overflowOption(String jar, String left);

  /// No description provided for @overflowNothing.
  ///
  /// In en, this message translates to:
  /// **'Your other glasses are empty.'**
  String get overflowNothing;

  /// No description provided for @overflowBorrow.
  ///
  /// In en, this message translates to:
  /// **'Borrow'**
  String get overflowBorrow;

  /// No description provided for @overflowOverspend.
  ///
  /// In en, this message translates to:
  /// **'Log anyway — glass goes below zero'**
  String get overflowOverspend;

  /// No description provided for @overflowBreakSavings.
  ///
  /// In en, this message translates to:
  /// **'Break my savings'**
  String get overflowBreakSavings;

  /// No description provided for @breakTitle.
  ///
  /// In en, this message translates to:
  /// **'Break your savings?'**
  String get breakTitle;

  /// No description provided for @breakBody.
  ///
  /// In en, this message translates to:
  /// **'Savings is your future self\'s money. Taking {amount} from it ends your streak this month. Are you really sure?'**
  String breakBody(String amount);

  /// No description provided for @breakConfirm.
  ///
  /// In en, this message translates to:
  /// **'Break my savings'**
  String get breakConfirm;

  /// No description provided for @breakCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep it safe'**
  String get breakCancel;

  /// No description provided for @payScan.
  ///
  /// In en, this message translates to:
  /// **'Pay with UPI'**
  String get payScan;

  /// No description provided for @payTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with UPI'**
  String get payTitle;

  /// No description provided for @payFrom.
  ///
  /// In en, this message translates to:
  /// **'From {jar} · {left} left'**
  String payFrom(String jar, String left);

  /// No description provided for @payBorrowWarning.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than this glass has. It will be borrowed from Fun first — never from Savings.'**
  String payBorrowWarning(String amount);

  /// No description provided for @payOverspendWarning.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than all your glasses have left. This glass will go below zero.'**
  String payOverspendWarning(String amount);

  /// No description provided for @payToLabel.
  ///
  /// In en, this message translates to:
  /// **'Paying to (optional)'**
  String get payToLabel;

  /// No description provided for @payToHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chai shop, Ramesh'**
  String get payToHint;

  /// No description provided for @payButton.
  ///
  /// In en, this message translates to:
  /// **'Open UPI app · {amount}'**
  String payButton(String amount);

  /// No description provided for @payHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get payHowTitle;

  /// No description provided for @paySteps.
  ///
  /// In en, this message translates to:
  /// **'1. Pick your UPI app (Google Pay, PhonePe, Paytm…).\n2. In that app, scan the QR or choose the person, and pay.\n3. Come back here — tap \"Yes, paid\" and it\'s added to this glass.'**
  String get paySteps;

  /// No description provided for @payHandOff.
  ///
  /// In en, this message translates to:
  /// **'You pay inside your own UPI app, so it always works like a normal payment. PehlaPaisa never sees your UPI PIN or bank details.'**
  String get payHandOff;

  /// No description provided for @payNoUpiApp.
  ///
  /// In en, this message translates to:
  /// **'No UPI app found on this phone'**
  String get payNoUpiApp;

  /// No description provided for @payConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Did the payment go through?'**
  String get payConfirmTitle;

  /// No description provided for @payConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Did you pay {amount}?'**
  String payConfirmBody(String amount);

  /// No description provided for @payConfirmBodyTo.
  ///
  /// In en, this message translates to:
  /// **'Did you pay {amount} to {name}?'**
  String payConfirmBodyTo(String amount, String name);

  /// No description provided for @payConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, paid'**
  String get payConfirmYes;

  /// No description provided for @payConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'No / failed'**
  String get payConfirmNo;

  /// No description provided for @payRecorded.
  ///
  /// In en, this message translates to:
  /// **'{amount} added to {jar}'**
  String payRecorded(String amount, String jar);

  /// No description provided for @payNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Nothing was recorded'**
  String get payNotRecorded;

  /// No description provided for @payExpenseNote.
  ///
  /// In en, this message translates to:
  /// **'UPI · {name}'**
  String payExpenseNote(String name);

  /// No description provided for @payExpenseNotePlain.
  ///
  /// In en, this message translates to:
  /// **'UPI payment'**
  String get payExpenseNotePlain;

  /// No description provided for @payWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} with'**
  String payWithTitle(String amount);

  /// No description provided for @payWithHint.
  ///
  /// In en, this message translates to:
  /// **'The app opens. Scan the QR there and pay {amount}, then come back.'**
  String payWithHint(String amount);

  /// No description provided for @payTryAnother.
  ///
  /// In en, this message translates to:
  /// **'Open another app'**
  String get payTryAnother;

  /// No description provided for @jarAllocated.
  ///
  /// In en, this message translates to:
  /// **'Poured in'**
  String get jarAllocated;

  /// No description provided for @jarSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get jarSpent;

  /// No description provided for @jarRemaining.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get jarRemaining;

  /// No description provided for @jarWeeklyLimit.
  ///
  /// In en, this message translates to:
  /// **'Weekly food budget'**
  String get jarWeeklyLimit;

  /// No description provided for @jarWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} this week'**
  String jarWeeklyProgress(String spent, String limit);

  /// No description provided for @jarHistory.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get jarHistory;

  /// No description provided for @jarNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No spending yet this month'**
  String get jarNoTransactions;

  /// No description provided for @jarMoveMoney.
  ///
  /// In en, this message translates to:
  /// **'Move money'**
  String get jarMoveMoney;

  /// No description provided for @jarSavingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Savings is protected. It never pays for other glasses unless you choose to break it.'**
  String get jarSavingsInfo;

  /// No description provided for @jarGone.
  ///
  /// In en, this message translates to:
  /// **'This glass no longer exists.'**
  String get jarGone;

  /// No description provided for @txnBorrowedFrom.
  ///
  /// In en, this message translates to:
  /// **'Borrowed from {jar}'**
  String txnBorrowedFrom(String jar);

  /// No description provided for @txnLentTo.
  ///
  /// In en, this message translates to:
  /// **'Moved to {jar}'**
  String txnLentTo(String jar);

  /// No description provided for @txnToGoal.
  ///
  /// In en, this message translates to:
  /// **'Set aside for {goal}'**
  String txnToGoal(String goal);

  /// No description provided for @txnExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get txnExpense;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense?'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} will go back into the {jar} glass.'**
  String deleteExpenseBody(String amount, String jar);

  /// No description provided for @moveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move money'**
  String get moveTitle;

  /// No description provided for @moveFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get moveFrom;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get moveTo;

  /// No description provided for @moveAvailable.
  ///
  /// In en, this message translates to:
  /// **'{amount} available'**
  String moveAvailable(String amount);

  /// No description provided for @moveButton.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveButton;

  /// No description provided for @moveDone.
  ///
  /// In en, this message translates to:
  /// **'Moved {amount} to {jar}'**
  String moveDone(String amount, String jar);

  /// No description provided for @salaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Salary day!'**
  String get salaryTitle;

  /// No description provided for @salaryIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Income received'**
  String get salaryIncomeTitle;

  /// No description provided for @salaryAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'This month\'s salary'**
  String get salaryAmountLabel;

  /// No description provided for @salaryChangeAmount.
  ///
  /// In en, this message translates to:
  /// **'Different amount this month?'**
  String get salaryChangeAmount;

  /// No description provided for @salaryFillSavings.
  ///
  /// In en, this message translates to:
  /// **'Fill Savings First'**
  String get salaryFillSavings;

  /// No description provided for @salaryIntro.
  ///
  /// In en, this message translates to:
  /// **'Before anything else, pay yourself. Tap below and watch your Savings glass fill.'**
  String get salaryIntro;

  /// No description provided for @salaryPouring.
  ///
  /// In en, this message translates to:
  /// **'Pouring into Savings…'**
  String get salaryPouring;

  /// No description provided for @salaryFillingOthers.
  ///
  /// In en, this message translates to:
  /// **'Now filling your other glasses…'**
  String get salaryFillingOthers;

  /// No description provided for @salaryDone.
  ///
  /// In en, this message translates to:
  /// **'All glasses filled!'**
  String get salaryDone;

  /// No description provided for @salaryDoneBody.
  ///
  /// In en, this message translates to:
  /// **'You paid yourself first. {amount} is safe in Savings.'**
  String salaryDoneBody(String amount);

  /// No description provided for @salaryGoShelf.
  ///
  /// In en, this message translates to:
  /// **'Go to my shelf'**
  String get salaryGoShelf;

  /// No description provided for @salaryIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount you received. It\'s split with your usual percentages — Savings first.'**
  String get salaryIncomeHint;

  /// No description provided for @salaryReceivedSoFar.
  ///
  /// In en, this message translates to:
  /// **'Received this month: {amount}'**
  String salaryReceivedSoFar(String amount);

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @goalsFree.
  ///
  /// In en, this message translates to:
  /// **'Free savings'**
  String get goalsFree;

  /// No description provided for @goalsFreeHelp.
  ///
  /// In en, this message translates to:
  /// **'Savings not yet given to a goal'**
  String get goalsFreeHelp;

  /// No description provided for @goalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No goals yet. What are you saving for?'**
  String get goalsEmpty;

  /// No description provided for @goalsSuggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with an Emergency Fund'**
  String get goalsSuggestTitle;

  /// No description provided for @goalsSuggestBody.
  ///
  /// In en, this message translates to:
  /// **'3 months of expenses = {amount}. It keeps you safe when life surprises you.'**
  String goalsSuggestBody(String amount);

  /// No description provided for @goalsSuggestButton.
  ///
  /// In en, this message translates to:
  /// **'Create Emergency Fund'**
  String get goalsSuggestButton;

  /// No description provided for @goalEmergencyName.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get goalEmergencyName;

  /// No description provided for @goalAdd.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalAdd;

  /// No description provided for @goalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalEdit;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New phone'**
  String get goalNameHint;

  /// No description provided for @goalNameError.
  ///
  /// In en, this message translates to:
  /// **'Give your goal a name'**
  String get goalNameError;

  /// No description provided for @goalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTarget;

  /// No description provided for @goalTargetError.
  ///
  /// In en, this message translates to:
  /// **'Enter a target amount'**
  String get goalTargetError;

  /// No description provided for @goalTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date (optional)'**
  String get goalTargetDate;

  /// No description provided for @goalNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get goalNoDate;

  /// No description provided for @goalPickIcon.
  ///
  /// In en, this message translates to:
  /// **'Pick an icon'**
  String get goalPickIcon;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String goalProgress(String saved, String target);

  /// No description provided for @goalEstimate.
  ///
  /// In en, this message translates to:
  /// **'At {rate}/month you\'ll reach this in {months, plural, =1{1 month} other{{months} months}}'**
  String goalEstimate(String rate, int months);

  /// No description provided for @goalEstimateNone.
  ///
  /// In en, this message translates to:
  /// **'Save something every month to see when you\'ll get there'**
  String get goalEstimateNone;

  /// No description provided for @goalNeedPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Save {amount}/month to reach it by {date}'**
  String goalNeedPerMonth(String amount, String date);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached! 🎉'**
  String get goalReached;

  /// No description provided for @goalAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add from savings'**
  String get goalAddMoney;

  /// No description provided for @goalTakeBack.
  ///
  /// In en, this message translates to:
  /// **'Take back'**
  String get goalTakeBack;

  /// No description provided for @goalMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move savings into {goal}'**
  String goalMoveTitle(String goal);

  /// No description provided for @goalTakeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Take money back from {goal}'**
  String goalTakeBackTitle(String goal);

  /// No description provided for @goalNoFreeSavings.
  ///
  /// In en, this message translates to:
  /// **'No free savings to move yet. Fill your Savings glass first!'**
  String get goalNoFreeSavings;

  /// No description provided for @goalMoved.
  ///
  /// In en, this message translates to:
  /// **'{amount} added to {goal}'**
  String goalMoved(String amount, String goal);

  /// No description provided for @goalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this goal?'**
  String get goalDeleteTitle;

  /// No description provided for @goalDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Money in this goal goes back to your free savings.'**
  String get goalDeleteBody;

  /// No description provided for @goalPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% filled'**
  String goalPercent(int percent);

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly report'**
  String get reportTitle;

  /// No description provided for @reportSavedPercent.
  ///
  /// In en, this message translates to:
  /// **'You saved {percent}% of your income'**
  String reportSavedPercent(int percent);

  /// No description provided for @reportSavedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} kept safe in Savings'**
  String reportSavedAmount(String amount);

  /// No description provided for @reportTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent {amount}'**
  String reportTotalSpent(String amount);

  /// No description provided for @reportWhereMoneyWent.
  ///
  /// In en, this message translates to:
  /// **'Where your money went'**
  String get reportWhereMoneyWent;

  /// No description provided for @reportNoSpending.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded this month'**
  String get reportNoSpending;

  /// No description provided for @reportLast6.
  ///
  /// In en, this message translates to:
  /// **'Savings — last 6 months'**
  String get reportLast6;

  /// No description provided for @reportBestJar.
  ///
  /// In en, this message translates to:
  /// **'Best glass'**
  String get reportBestJar;

  /// No description provided for @reportWorstJar.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get reportWorstJar;

  /// No description provided for @reportUsed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used'**
  String reportUsed(int percent);

  /// No description provided for @reportVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Compared to last month'**
  String get reportVsLastMonth;

  /// No description provided for @reportSpentMore.
  ///
  /// In en, this message translates to:
  /// **'You spent {percent}% more'**
  String reportSpentMore(int percent);

  /// No description provided for @reportSpentLess.
  ///
  /// In en, this message translates to:
  /// **'You spent {percent}% less'**
  String reportSpentLess(int percent);

  /// No description provided for @reportSpentSame.
  ///
  /// In en, this message translates to:
  /// **'You spent about the same'**
  String get reportSpentSame;

  /// No description provided for @reportSavedMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more saved'**
  String reportSavedMore(String amount);

  /// No description provided for @reportSavedLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less saved'**
  String reportSavedLess(String amount);

  /// No description provided for @reportSavedSame.
  ///
  /// In en, this message translates to:
  /// **'Same savings as last month'**
  String get reportSavedSame;

  /// No description provided for @reportNoPrevious.
  ///
  /// In en, this message translates to:
  /// **'No previous month to compare yet'**
  String get reportNoPrevious;

  /// No description provided for @reportNotFunded.
  ///
  /// In en, this message translates to:
  /// **'This month\'s glasses aren\'t filled yet.'**
  String get reportNotFunded;

  /// No description provided for @reportNoData.
  ///
  /// In en, this message translates to:
  /// **'Your report appears after your first salary day.'**
  String get reportNoData;

  /// No description provided for @reportTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Money tip'**
  String get reportTipTitle;

  /// No description provided for @reportTip1.
  ///
  /// In en, this message translates to:
  /// **'Keep 3 months of expenses as an emergency fund before big purchases.'**
  String get reportTip1;

  /// No description provided for @reportTip2.
  ///
  /// In en, this message translates to:
  /// **'Small daily spends add up — ₹50 a day is ₹1,500 a month.'**
  String get reportTip2;

  /// No description provided for @reportTip3.
  ///
  /// In en, this message translates to:
  /// **'When your income goes up, raise your savings first, then your spending.'**
  String get reportTip3;

  /// No description provided for @reportTip4.
  ///
  /// In en, this message translates to:
  /// **'Write down every spend for a week — you\'ll spot easy savings.'**
  String get reportTip4;

  /// No description provided for @reportDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'General tips for learning only — not financial advice.'**
  String get reportDisclaimer;

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesTitle;

  /// No description provided for @levelTitle.
  ///
  /// In en, this message translates to:
  /// **'Your level'**
  String get levelTitle;

  /// No description provided for @levelToNext.
  ///
  /// In en, this message translates to:
  /// **'{amount} more to become {level}'**
  String levelToNext(String amount, String level);

  /// No description provided for @levelMax.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the top level!'**
  String get levelMax;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelSaver.
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get levelSaver;

  /// No description provided for @levelSmartSaver.
  ///
  /// In en, this message translates to:
  /// **'Smart Saver'**
  String get levelSmartSaver;

  /// No description provided for @levelGullakMaster.
  ///
  /// In en, this message translates to:
  /// **'Gullak Master'**
  String get levelGullakMaster;

  /// No description provided for @levelLegend.
  ///
  /// In en, this message translates to:
  /// **'PehlaPaisa Legend'**
  String get levelLegend;

  /// No description provided for @badgeLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get badgeLocked;

  /// No description provided for @badgeUnlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {date}'**
  String badgeUnlockedOn(String date);

  /// No description provided for @badgesCount.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} unlocked'**
  String badgesCount(int unlocked, int total);

  /// No description provided for @badgePehlaKadam.
  ///
  /// In en, this message translates to:
  /// **'Pehla Kadam'**
  String get badgePehlaKadam;

  /// No description provided for @badgePehlaKadamDesc.
  ///
  /// In en, this message translates to:
  /// **'Set up your shelf'**
  String get badgePehlaKadamDesc;

  /// No description provided for @badgePehlaPaisa.
  ///
  /// In en, this message translates to:
  /// **'Pehla Paisa'**
  String get badgePehlaPaisa;

  /// No description provided for @badgePehlaPaisaDesc.
  ///
  /// In en, this message translates to:
  /// **'Filled Savings first for the first time'**
  String get badgePehlaPaisaDesc;

  /// No description provided for @badgeStreak3.
  ///
  /// In en, this message translates to:
  /// **'Streak 3'**
  String get badgeStreak3;

  /// No description provided for @badgeStreak3Desc.
  ///
  /// In en, this message translates to:
  /// **'3 months in a row of paying yourself first'**
  String get badgeStreak3Desc;

  /// No description provided for @badgeStreak6.
  ///
  /// In en, this message translates to:
  /// **'Streak 6'**
  String get badgeStreak6;

  /// No description provided for @badgeStreak6Desc.
  ///
  /// In en, this message translates to:
  /// **'6 months in a row of paying yourself first'**
  String get badgeStreak6Desc;

  /// No description provided for @badgeStreak12.
  ///
  /// In en, this message translates to:
  /// **'Streak 12'**
  String get badgeStreak12;

  /// No description provided for @badgeStreak12Desc.
  ///
  /// In en, this message translates to:
  /// **'A full year of paying yourself first'**
  String get badgeStreak12Desc;

  /// No description provided for @badgeGullakMaster.
  ///
  /// In en, this message translates to:
  /// **'Gullak Master'**
  String get badgeGullakMaster;

  /// No description provided for @badgeGullakMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Saved ₹10,000 in total'**
  String get badgeGullakMasterDesc;

  /// No description provided for @badgeGoalGetter.
  ///
  /// In en, this message translates to:
  /// **'Goal Getter'**
  String get badgeGoalGetter;

  /// No description provided for @badgeGoalGetterDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed your first goal'**
  String get badgeGoalGetterDesc;

  /// No description provided for @badgeFunUnderControl.
  ///
  /// In en, this message translates to:
  /// **'Fun Under Control'**
  String get badgeFunUnderControl;

  /// No description provided for @badgeFunUnderControlDesc.
  ///
  /// In en, this message translates to:
  /// **'Finished a month without Fun going below zero or borrowing'**
  String get badgeFunUnderControlDesc;

  /// No description provided for @badgeLogger.
  ///
  /// In en, this message translates to:
  /// **'Logger'**
  String get badgeLogger;

  /// No description provided for @badgeLoggerDesc.
  ///
  /// In en, this message translates to:
  /// **'Logged spending 7 days in a row'**
  String get badgeLoggerDesc;

  /// No description provided for @badgeBachatChampion.
  ///
  /// In en, this message translates to:
  /// **'Bachat Champion'**
  String get badgeBachatChampion;

  /// No description provided for @badgeBachatChampionDesc.
  ///
  /// In en, this message translates to:
  /// **'Saved 25% or more of your income in a month'**
  String get badgeBachatChampionDesc;

  /// No description provided for @celebrateBadge.
  ///
  /// In en, this message translates to:
  /// **'Badge unlocked!'**
  String get celebrateBadge;

  /// No description provided for @celebrateGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal complete!'**
  String get celebrateGoal;

  /// No description provided for @celebrateGoalBody.
  ///
  /// In en, this message translates to:
  /// **'You filled your {goal} glass to the top.'**
  String celebrateGoalBody(String goal);

  /// No description provided for @celebrateStreak.
  ///
  /// In en, this message translates to:
  /// **'New streak month!'**
  String get celebrateStreak;

  /// No description provided for @celebrateSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings filled first!'**
  String get celebrateSavings;

  /// No description provided for @celebrateContinue.
  ///
  /// In en, this message translates to:
  /// **'Yay! Continue'**
  String get celebrateContinue;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your progress'**
  String get shareTitle;

  /// No description provided for @shareStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get shareStory;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get sharePost;

  /// No description provided for @shareCardStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get shareCardStreak;

  /// No description provided for @shareCardSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get shareCardSaved;

  /// No description provided for @shareShowAmounts.
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get shareShowAmounts;

  /// No description provided for @shareShowAmountsHint.
  ///
  /// In en, this message translates to:
  /// **'Off by default — your income and balances stay private'**
  String get shareShowAmountsHint;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareButton;

  /// No description provided for @shareStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'🔥 {count, plural, =1{1 month} other{{count} months}} of paying myself first'**
  String shareStreakTitle(int count);

  /// No description provided for @shareSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'I saved {amount} with PehlaPaisa'**
  String shareSavedTitle(String amount);

  /// No description provided for @shareSavedTitleHidden.
  ///
  /// In en, this message translates to:
  /// **'I\'m paying myself first with PehlaPaisa'**
  String get shareSavedTitleHidden;

  /// No description provided for @shareSavedSub.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of my income goes to savings first'**
  String shareSavedSub(int percent);

  /// No description provided for @shareGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal complete: {goal}'**
  String shareGoalTitle(String goal);

  /// No description provided for @shareGoalSub.
  ///
  /// In en, this message translates to:
  /// **'{amount} saved'**
  String shareGoalSub(String amount);

  /// No description provided for @shareGoalSubHidden.
  ///
  /// In en, this message translates to:
  /// **'Filled to the top 🎉'**
  String get shareGoalSubHidden;

  /// No description provided for @shareBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Badge unlocked: {badge}'**
  String shareBadgeTitle(String badge);

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Pehle bachao, phir kharcho — I\'m building the savings habit with PehlaPaisa.'**
  String get shareMessage;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the image. Please try again.'**
  String get shareFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsName;

  /// No description provided for @settingsIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get settingsIncome;

  /// No description provided for @settingsSalaryDay.
  ///
  /// In en, this message translates to:
  /// **'Salary day'**
  String get settingsSalaryDay;

  /// No description provided for @settingsSalaryDayNote.
  ///
  /// In en, this message translates to:
  /// **'A new salary day applies from your next month.'**
  String get settingsSalaryDayNote;

  /// No description provided for @settingsIncomeType.
  ///
  /// In en, this message translates to:
  /// **'Income type'**
  String get settingsIncomeType;

  /// No description provided for @settingsFamily.
  ///
  /// In en, this message translates to:
  /// **'Living with family'**
  String get settingsFamily;

  /// No description provided for @settingsEditSplit.
  ///
  /// In en, this message translates to:
  /// **'Edit split'**
  String get settingsEditSplit;

  /// No description provided for @settingsEditSplitDesc.
  ///
  /// In en, this message translates to:
  /// **'Change how your income is divided'**
  String get settingsEditSplitDesc;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Night shelf (dark)'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Morning shelf (light)'**
  String get themeLight;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsNotifications;

  /// No description provided for @notifMaster.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notifMaster;

  /// No description provided for @notifSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary day reminder'**
  String get notifSalary;

  /// No description provided for @notifWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly check-in (Sunday evening)'**
  String get notifWeekly;

  /// No description provided for @notifLowBalance.
  ///
  /// In en, this message translates to:
  /// **'Low glass alerts'**
  String get notifLowBalance;

  /// No description provided for @notifDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to log spending'**
  String get notifDaily;

  /// No description provided for @notifDailyTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get notifDailyTime;

  /// No description provided for @notifPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for PehlaPaisa in your phone settings.'**
  String get notifPermissionDenied;

  /// No description provided for @settingsSharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get settingsSharing;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsData;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export data (JSON)'**
  String get settingsExport;

  /// No description provided for @settingsExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Save or send a copy of all your data'**
  String get settingsExportDesc;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get settingsReset;

  /// No description provided for @settingsResetDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete everything and start fresh'**
  String get settingsResetDesc;

  /// No description provided for @resetTitle1.
  ///
  /// In en, this message translates to:
  /// **'Reset everything?'**
  String get resetTitle1;

  /// No description provided for @resetBody1.
  ///
  /// In en, this message translates to:
  /// **'All glasses, spending, goals, streaks and badges will be deleted from this phone.'**
  String get resetBody1;

  /// No description provided for @resetTitle2.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure?'**
  String get resetTitle2;

  /// No description provided for @resetBody2.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. There is no backup unless you exported your data.'**
  String get resetBody2;

  /// No description provided for @resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete everything'**
  String get resetConfirm;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get resetDone;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About PehlaPaisa'**
  String get settingsAbout;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @splitEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit split'**
  String get splitEditorTitle;

  /// No description provided for @splitEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Changes apply from your next fill. Fun gets whatever is left.'**
  String get splitEditorHint;

  /// No description provided for @splitEditorIncome.
  ///
  /// In en, this message translates to:
  /// **'Based on monthly income {amount}'**
  String splitEditorIncome(String amount);

  /// No description provided for @splitUseSuggested.
  ///
  /// In en, this message translates to:
  /// **'Use suggested split'**
  String get splitUseSuggested;

  /// No description provided for @splitSaved.
  ///
  /// In en, this message translates to:
  /// **'Split saved'**
  String get splitSaved;

  /// No description provided for @customJarAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a custom glass'**
  String get customJarAdd;

  /// No description provided for @customJarName.
  ///
  /// In en, this message translates to:
  /// **'Glass name'**
  String get customJarName;

  /// No description provided for @customJarNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Medicines'**
  String get customJarNameHint;

  /// No description provided for @customJarRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove glass'**
  String get customJarRemove;

  /// No description provided for @customJarRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Its money and plan go to Fun.'**
  String get customJarRemoveBody;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'PehlaPaisa helps you build one habit: on salary day, fill your Savings glass first. Then spend from your other glasses without guilt — they show exactly what\'s left.'**
  String get aboutBody;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your budget stays on this phone: no login, no cloud, no bank or SMS access. The app shows a few ads from Google AdMob; to show them, Google receives your device\'s advertising ID and basic device info — never your budget. Payments happen in your own UPI app — PehlaPaisa never sees your PIN or bank details.'**
  String get aboutPrivacy;

  /// No description provided for @aboutDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not financial advice'**
  String get aboutDisclaimerTitle;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'PehlaPaisa shares general, educational money tips only. It does not give investment or financial advice.'**
  String get aboutDisclaimer;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with care for first-job workers, students, freelancers and gig workers.'**
  String get aboutMadeWith;

  /// No description provided for @notifWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on 🔔'**
  String get notifWelcomeTitle;

  /// No description provided for @notifWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you on salary day, every Sunday evening, and when a glass is running low.'**
  String get notifWelcomeBody;

  /// No description provided for @notifTestButton.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get notifTestButton;

  /// No description provided for @notifTestDesc.
  ///
  /// In en, this message translates to:
  /// **'See how your salary-day reminder looks'**
  String get notifTestDesc;

  /// No description provided for @notifChannel.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifChannel;

  /// No description provided for @notifSalaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Salary day!'**
  String get notifSalaryTitle;

  /// No description provided for @notifSalaryBody.
  ///
  /// In en, this message translates to:
  /// **'Salary day! Fill your Savings glass first 🟡'**
  String get notifSalaryBody;

  /// No description provided for @notifWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly check-in'**
  String get notifWeeklyTitle;

  /// No description provided for @notifWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'This week you spent {amount} so far. Open PehlaPaisa to see your glasses.'**
  String notifWeeklyBody(String amount);

  /// No description provided for @notifDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick check'**
  String get notifDailyTitle;

  /// No description provided for @notifDailyBody.
  ///
  /// In en, this message translates to:
  /// **'Log today\'s spending'**
  String get notifDailyBody;

  /// No description provided for @notifLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Glass running low'**
  String get notifLowTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
