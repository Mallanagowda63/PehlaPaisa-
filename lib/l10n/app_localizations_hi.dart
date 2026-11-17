// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'PehlaPaisa';

  @override
  String get tagline => 'पहले बचाओ, फिर खर्चो';

  @override
  String get splashTipLabel => 'पैसों की बात';

  @override
  String get splashTip1 =>
      'पहले बचाओ, फिर खर्चो — महीने के ₹100 से भी आदत बनती है।';

  @override
  String get splashTip2 =>
      'हर महीने थोड़ी बचत, कभी न शुरू हुए बड़े प्लान से बेहतर है।';

  @override
  String get splashTip3 =>
      'रोज़ ₹50 मतलब महीने के ₹1,500। छोटे खर्च जुड़ जाते हैं!';

  @override
  String get splashTip4 =>
      'इमरजेंसी फ़ंड मुसीबत को बस एक छोटी परेशानी बना देता है।';

  @override
  String get splashTip5 =>
      'पहले ख़ुद को पैसे दो — आने वाला कल सबसे ज़रूरी बिल है।';

  @override
  String get splashTip6 => 'कमाई बढ़े तो पहले बचत बढ़ाओ।';

  @override
  String get splashTip7 =>
      'एक हफ़्ता हर खर्च लिखो — आसानी से बचत के रास्ते दिखेंगे।';

  @override
  String get splashTip8 => 'बचत की आदत, सबसे बड़ी दौलत।';

  @override
  String get commonContinue => 'आगे बढ़ें';

  @override
  String get commonBack => 'पीछे';

  @override
  String get commonCancel => 'रहने दें';

  @override
  String get commonSave => 'सेव करें';

  @override
  String get commonDone => 'हो गया';

  @override
  String get commonDelete => 'हटाएँ';

  @override
  String get commonEdit => 'बदलें';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonShare => 'शेयर करें';

  @override
  String get commonToday => 'आज';

  @override
  String get commonYesterday => 'कल';

  @override
  String get keypadDelete => 'आख़िरी अंक हटाएँ';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String dayOfMonth(int day) {
    return 'हर महीने की $day तारीख़';
  }

  @override
  String stepOf(int current, int total) {
    return 'कदम $current / $total';
  }

  @override
  String nextSalaryOn(String date) {
    return 'अगली सैलरी: $date';
  }

  @override
  String salaryForDate(String date) {
    return '$date की सैलरी';
  }

  @override
  String get navShelf => 'शेल्फ़';

  @override
  String get navGoals => 'लक्ष्य';

  @override
  String get navReport => 'रिपोर्ट';

  @override
  String get navBadges => 'बैज';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get jarSavings => 'बचत';

  @override
  String get jarRent => 'किराया और बिल';

  @override
  String get jarHome => 'घर में हिस्सा';

  @override
  String get jarFood => 'खाना';

  @override
  String get jarTravel => 'आना-जाना और फ़ोन';

  @override
  String get jarFun => 'मौज-मस्ती';

  @override
  String glassSemantics(String name, String left, String total) {
    return '$name का गिलास, $total में से $left बचे';
  }

  @override
  String glassSemanticsOverspent(String name, String amount) {
    return '$name का गिलास, $amount ज़्यादा खर्च';
  }

  @override
  String get glassHint =>
      'देखने के लिए टैप करें, खर्च जोड़ने के लिए दबाकर रखें';

  @override
  String jarLeft(String amount) {
    return '$amount बचे';
  }

  @override
  String jarOver(String amount) {
    return '$amount ज़्यादा';
  }

  @override
  String get jarEmpty => 'अभी भरा नहीं';

  @override
  String get onbIntroTitle => 'पहले ख़ुद को पैसे दो';

  @override
  String get onbIntroBody =>
      'हर सैलरी वाले दिन सबसे पहले बचत का गिलास भरो। फिर जो बचे उससे किराया, खाना, आना-जाना और मौज-मस्ती के गिलास भरो। खर्च गिलासों से करो — पर बचत से कभी नहीं।';

  @override
  String get onbIntroPoint1 => '🪙  हर महीने सबसे पहले बचत भरती है';

  @override
  String get onbIntroPoint2 => '🫙  हर गिलास दिखाता है कितना खर्च बाक़ी है';

  @override
  String get onbIntroPoint3 => '🔥  सिलसिला बनाए रखो और बैज जीतो';

  @override
  String get onbIntroSub =>
      'सैलरी वाले दिन पहले बचत का गिलास भरो। फिर बाक़ी बेफ़िक्र होकर खर्च करो।';

  @override
  String get onbFeat1Title => 'हमेशा पहले बचत';

  @override
  String get onbFeat1Body => 'हर महीने किसी भी चीज़ से पहले बचत भरती है';

  @override
  String get onbFeat2Title => 'देखो कितना बचा';

  @override
  String get onbFeat2Body => 'हर गिलास साफ़ दिखाता है कितना खर्च कर सकते हो';

  @override
  String get onbFeat3Title => 'आदत बनाओ';

  @override
  String get onbFeat3Body => 'सिलसिला बनाए रखो और बैज जीतो';

  @override
  String get onbStart => 'चलो शुरू करें';

  @override
  String get onbNameTitle => 'आपको क्या बुलाएँ?';

  @override
  String get onbNameHint => 'आपका नाम';

  @override
  String get onbNameError => 'कृपया अपना नाम लिखें';

  @override
  String onbIncomeTitle(String name) {
    return 'मिलकर अच्छा लगा, $name! अपने पैसों के बारे में बताओ';
  }

  @override
  String get onbIncomeLabel => 'महीने की कमाई';

  @override
  String get onbIncomeHint => 'जैसे 12,000';

  @override
  String get onbIncomeError => '₹500 से ₹10,00,000 के बीच रक़म लिखें';

  @override
  String get onbSalaryDayLabel => 'सैलरी की तारीख़';

  @override
  String get onbSalaryDayHelp =>
      'जिस दिन आम तौर पर पैसे आते हैं। आपका हर महीना इसी दिन से शुरू होगा।';

  @override
  String get onbIncomeTypeLabel => 'पैसे कैसे मिलते हैं?';

  @override
  String get incomeFixed => 'पक्की सैलरी';

  @override
  String get incomeFixedDesc => 'हर महीने लगभग एक जैसी रक़म';

  @override
  String get incomeIrregular => 'कभी कम, कभी ज़्यादा';

  @override
  String get incomeIrregularDesc =>
      'गिग, फ्रीलांस, ट्यूशन — रक़म बदलती रहती है';

  @override
  String get onbFamilyTitle => 'क्या आप परिवार के साथ रहते हैं?';

  @override
  String get onbFamilyBody =>
      'परिवार के साथ रहते हैं तो किराए की जगह छोटा \"घर में हिस्सा\" होगा, और बाक़ी पैसा बचत में जाएगा।';

  @override
  String get onbFamilyYes => 'हाँ, परिवार के साथ';

  @override
  String get onbFamilyNo => 'नहीं, अकेले';

  @override
  String get onbSplitTitle => 'आपके लिए सुझाया बँटवारा';

  @override
  String onbSplitBody(String income) {
    return 'महीने के $income के लिए। खिसकाकर बदलें — जो बचे वो मौज-मस्ती में।';
  }

  @override
  String get onbFinish => 'बचत शुरू करें';

  @override
  String get splitTotalLabel => 'कुल';

  @override
  String get splitFunLeft => 'जो बचेगा वो मौज-मस्ती में जाएगा';

  @override
  String get lowSavingsTitle => 'थोड़ा तो बचाओ?';

  @override
  String get lowSavingsBody =>
      'पहले बचत — चाहे ₹100 ही सही — आदत बनाती है। बचत आख़िर में रखो तो अक्सर कुछ नहीं बचता। क्या सच में 5% से कम बचाना है?';

  @override
  String get lowSavingsKeep => '5% रखें';

  @override
  String get lowSavingsConfirm => 'हाँ, पक्का';

  @override
  String get homeLeftToSpend => 'इस महीने खर्च के लिए बाक़ी';

  @override
  String homeDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन बाक़ी',
      one: '1 दिन बाक़ी',
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
      other: '$count महीने से पहले ख़ुद को पैसे',
      one: '1 महीने से पहले ख़ुद को पैसे',
      zero: 'इस महीने से सिलसिला शुरू करो',
    );
    return '🔥 $_temp0';
  }

  @override
  String get homeFillBanner => 'सैलरी का दिन! पहले बचत का गिलास भरो 🟡';

  @override
  String get homeFillButton => 'गिलास भरो';

  @override
  String get homeIncomeButton => 'पैसे आए';

  @override
  String get homeAddExpense => 'खर्च जोड़ें';

  @override
  String get homeShare => 'प्रगति शेयर करें';

  @override
  String homeTotalSaved(String amount) {
    return 'कुल बचत $amount';
  }

  @override
  String homeGreeting(String name) {
    return 'नमस्ते $name';
  }

  @override
  String alertLow(String jar, int percent, int days) {
    return 'आपका $jar गिलास $percent% ख़ाली है और $days दिन बाक़ी हैं';
  }

  @override
  String alertFoodWeekly(String spent, String limit) {
    return 'इस हफ़्ते खाने पर $spent — हफ़्ते के $limit से ज़्यादा';
  }

  @override
  String get alertDismiss => 'यह चेतावनी छिपाएँ';

  @override
  String get weeklyLimitsTitle => 'इस हफ़्ते की सीमा';

  @override
  String get weeklyLimitsHint =>
      'हर हफ़्ते इससे कम खर्च करो, तो गिलास पूरे महीने चलेंगे';

  @override
  String weeklyLimitPerWeek(String amount) {
    return '$amount/हफ़्ता';
  }

  @override
  String weeklyLimitLeft(String spent, String left) {
    return '$spent खर्च · इस हफ़्ते $left बाक़ी';
  }

  @override
  String weeklyLimitOver(String spent, String over) {
    return '$spent खर्च · इस हफ़्ते $over ज़्यादा';
  }

  @override
  String weeklyLimitTitleFor(String jar) {
    return 'हफ़्ते की सीमा – $jar';
  }

  @override
  String get weeklySummaryTitle => 'इस हफ़्ते';

  @override
  String weeklySummaryBody(String amount) {
    return 'सोमवार से अब तक $amount खर्च हुए';
  }

  @override
  String get addExpenseTitle => 'खर्च जोड़ें';

  @override
  String get addNoteHint => 'नोट (ज़रूरी नहीं)';

  @override
  String get addPickJar => 'किस गिलास से?';

  @override
  String get addSave => 'खर्च सेव करें';

  @override
  String get addEnterAmount => 'रक़म लिखें';

  @override
  String expenseSaved(String amount, String jar) {
    return '$jar से $amount खर्च हुए';
  }

  @override
  String get fillFirstTitle => 'पहले गिलास भरो';

  @override
  String get fillFirstBody =>
      'खर्च लिखने से पहले इस महीने के पैसे गिलासों में डालो — सबसे पहले बचत।';

  @override
  String overflowTitle(String jar) {
    return '$jar में पैसे कम हैं';
  }

  @override
  String overflowBody(String amount, String jar, String left, String short) {
    return 'यह $amount का है पर $jar में सिर्फ़ $left बचे हैं। बाक़ी $short कहाँ से लें:';
  }

  @override
  String overflowOption(String jar, String left) {
    return '$jar · $left बचे';
  }

  @override
  String get overflowNothing => 'बाक़ी गिलास ख़ाली हैं।';

  @override
  String get overflowBorrow => 'उधार लें';

  @override
  String get overflowOverspend => 'फिर भी लिखें — गिलास शून्य से नीचे जाएगा';

  @override
  String get overflowBreakSavings => 'मेरी बचत तोड़ो';

  @override
  String get breakTitle => 'बचत तोड़नी है?';

  @override
  String breakBody(String amount) {
    return 'बचत आपके आने वाले कल का पैसा है। इसमें से $amount लेने से इस महीने का सिलसिला टूट जाएगा। क्या सच में पक्का?';
  }

  @override
  String get breakConfirm => 'मेरी बचत तोड़ो';

  @override
  String get breakCancel => 'बचत बचाओ';

  @override
  String get payScan => 'UPI से पे करें';

  @override
  String get payTitle => 'UPI से पे करें';

  @override
  String payFrom(String jar, String left) {
    return '$jar से · $left बचे';
  }

  @override
  String payBorrowWarning(String amount) {
    return 'इस गिलास से $amount ज़्यादा। ये पहले मौज-मस्ती से उधार लिया जाएगा — बचत से कभी नहीं।';
  }

  @override
  String payOverspendWarning(String amount) {
    return 'आपके सारे गिलासों में बचे पैसों से $amount ज़्यादा। यह गिलास शून्य से नीचे जाएगा।';
  }

  @override
  String get payToLabel => 'किसे पे कर रहे हैं (ज़रूरी नहीं)';

  @override
  String get payToHint => 'जैसे चाय की दुकान, रमेश';

  @override
  String payButton(String amount) {
    return 'UPI ऐप खोलें · $amount';
  }

  @override
  String get payHowTitle => 'कैसे काम करता है';

  @override
  String get paySteps =>
      '1. अपना UPI ऐप चुनें (Google Pay, PhonePe, Paytm…)।\n2. उस ऐप में QR स्कैन करें या व्यक्ति चुनें, और पे करें।\n3. यहाँ वापस आएँ — \"हाँ, हो गया\" दबाएँ, और यह इस गिलास में जुड़ जाएगा।';

  @override
  String get payHandOff =>
      'आप अपने UPI ऐप में ही पे करते हैं, इसलिए यह आम पेमेंट की तरह हमेशा चलता है। PehlaPaisa आपका UPI PIN या बैंक की जानकारी कभी नहीं देखता।';

  @override
  String get payNoUpiApp => 'इस फ़ोन में कोई UPI ऐप नहीं मिला';

  @override
  String get payConfirmTitle => 'क्या पेमेंट हो गया?';

  @override
  String payConfirmBody(String amount) {
    return 'क्या आपने $amount पे किए?';
  }

  @override
  String payConfirmBodyTo(String amount, String name) {
    return 'क्या आपने $name को $amount पे किए?';
  }

  @override
  String get payConfirmYes => 'हाँ, हो गया';

  @override
  String get payConfirmNo => 'नहीं / फ़ेल हुआ';

  @override
  String payRecorded(String amount, String jar) {
    return '$amount $jar में जुड़ गया';
  }

  @override
  String get payNotRecorded => 'कुछ भी दर्ज नहीं हुआ';

  @override
  String payExpenseNote(String name) {
    return 'UPI · $name';
  }

  @override
  String get payExpenseNotePlain => 'UPI पेमेंट';

  @override
  String payWithTitle(String amount) {
    return '$amount किससे पे करें';
  }

  @override
  String payWithHint(String amount) {
    return 'ऐप खुलेगा। वहाँ QR स्कैन करके $amount पे करें, फिर वापस आएँ।';
  }

  @override
  String get payTryAnother => 'दूसरा ऐप खोलें';

  @override
  String get jarAllocated => 'डाले गए';

  @override
  String get jarSpent => 'खर्च';

  @override
  String get jarRemaining => 'बाक़ी';

  @override
  String get jarWeeklyLimit => 'खाने का हफ़्ते का बजट';

  @override
  String jarWeeklyProgress(String spent, String limit) {
    return 'इस हफ़्ते $limit में से $spent';
  }

  @override
  String get jarHistory => 'इस महीने';

  @override
  String get jarNoTransactions => 'इस महीने अभी कोई खर्च नहीं';

  @override
  String get jarMoveMoney => 'पैसे खिसकाएँ';

  @override
  String get jarSavingsInfo =>
      'बचत सुरक्षित है। जब तक आप ख़ुद इसे न तोड़ें, यह दूसरे गिलासों का खर्च नहीं उठाती।';

  @override
  String get jarGone => 'यह गिलास अब नहीं है।';

  @override
  String txnBorrowedFrom(String jar) {
    return '$jar से उधार';
  }

  @override
  String txnLentTo(String jar) {
    return '$jar में भेजे';
  }

  @override
  String txnToGoal(String goal) {
    return '$goal के लिए अलग रखे';
  }

  @override
  String get txnExpense => 'खर्च';

  @override
  String get deleteExpenseTitle => 'यह खर्च हटाएँ?';

  @override
  String deleteExpenseBody(String amount, String jar) {
    return '$amount वापस $jar गिलास में चले जाएँगे।';
  }

  @override
  String get moveTitle => 'पैसे खिसकाएँ';

  @override
  String get moveFrom => 'कहाँ से';

  @override
  String get moveTo => 'कहाँ';

  @override
  String moveAvailable(String amount) {
    return '$amount उपलब्ध';
  }

  @override
  String get moveButton => 'खिसकाएँ';

  @override
  String moveDone(String amount, String jar) {
    return '$amount $jar में डाले';
  }

  @override
  String get salaryTitle => 'सैलरी का दिन!';

  @override
  String get salaryIncomeTitle => 'पैसे आए';

  @override
  String get salaryAmountLabel => 'इस महीने की सैलरी';

  @override
  String get salaryChangeAmount => 'इस बार रक़म अलग है?';

  @override
  String get salaryFillSavings => 'पहले बचत भरो';

  @override
  String get salaryIntro =>
      'किसी और चीज़ से पहले, ख़ुद को पैसे दो। नीचे टैप करो और बचत का गिलास भरते देखो।';

  @override
  String get salaryPouring => 'बचत में पैसे डल रहे हैं…';

  @override
  String get salaryFillingOthers => 'अब बाक़ी गिलास भर रहे हैं…';

  @override
  String get salaryDone => 'सारे गिलास भर गए!';

  @override
  String salaryDoneBody(String amount) {
    return 'आपने पहले ख़ुद को पैसे दिए। $amount बचत में सुरक्षित हैं।';
  }

  @override
  String get salaryGoShelf => 'मेरी शेल्फ़ पर चलें';

  @override
  String get salaryIncomeHint =>
      'जितने पैसे मिले वो लिखें। ये आपके हमेशा वाले हिसाब से बँटेंगे — पहले बचत।';

  @override
  String salaryReceivedSoFar(String amount) {
    return 'इस महीने अब तक मिले: $amount';
  }

  @override
  String get goalsTitle => 'लक्ष्य';

  @override
  String get goalsFree => 'खुली बचत';

  @override
  String get goalsFreeHelp => 'बचत जो अभी किसी लक्ष्य में नहीं डाली';

  @override
  String get goalsEmpty => 'अभी कोई लक्ष्य नहीं। किसके लिए बचा रहे हो?';

  @override
  String get goalsSuggestTitle => 'इमरजेंसी फ़ंड से शुरू करो';

  @override
  String goalsSuggestBody(String amount) {
    return '3 महीने का खर्च = $amount। मुश्किल वक़्त में यही काम आता है।';
  }

  @override
  String get goalsSuggestButton => 'इमरजेंसी फ़ंड बनाएँ';

  @override
  String get goalEmergencyName => 'इमरजेंसी फ़ंड';

  @override
  String get goalAdd => 'नया लक्ष्य';

  @override
  String get goalEdit => 'लक्ष्य बदलें';

  @override
  String get goalName => 'लक्ष्य का नाम';

  @override
  String get goalNameHint => 'जैसे नया फ़ोन';

  @override
  String get goalNameError => 'लक्ष्य को एक नाम दें';

  @override
  String get goalTarget => 'कितने पैसे चाहिए';

  @override
  String get goalTargetError => 'रक़म लिखें';

  @override
  String get goalTargetDate => 'कब तक (ज़रूरी नहीं)';

  @override
  String get goalNoDate => 'कोई तारीख़ नहीं';

  @override
  String get goalPickIcon => 'एक चित्र चुनें';

  @override
  String goalProgress(String saved, String target) {
    return '$target में से $saved';
  }

  @override
  String goalEstimate(String rate, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months महीनों',
      one: '1 महीने',
    );
    return '$rate हर महीने बचाओगे तो $_temp0 में पहुँच जाओगे';
  }

  @override
  String get goalEstimateNone => 'हर महीने कुछ बचाओ, तब पता चलेगा कब पहुँचोगे';

  @override
  String goalNeedPerMonth(String amount, String date) {
    return '$date तक पहुँचने के लिए हर महीने $amount बचाओ';
  }

  @override
  String get goalReached => 'लक्ष्य पूरा! 🎉';

  @override
  String get goalAddMoney => 'बचत से डालें';

  @override
  String get goalTakeBack => 'वापस लें';

  @override
  String goalMoveTitle(String goal) {
    return 'बचत से $goal में डालें';
  }

  @override
  String goalTakeBackTitle(String goal) {
    return '$goal से पैसे वापस लें';
  }

  @override
  String get goalNoFreeSavings =>
      'अभी डालने को खुली बचत नहीं है। पहले बचत का गिलास भरो!';

  @override
  String goalMoved(String amount, String goal) {
    return '$goal में $amount डाले';
  }

  @override
  String get goalDeleteTitle => 'यह लक्ष्य हटाएँ?';

  @override
  String get goalDeleteBody => 'इसके पैसे वापस खुली बचत में चले जाएँगे।';

  @override
  String goalPercent(int percent) {
    return '$percent% भरा';
  }

  @override
  String get reportTitle => 'महीने की रिपोर्ट';

  @override
  String reportSavedPercent(int percent) {
    return 'आपने कमाई का $percent% बचाया';
  }

  @override
  String reportSavedAmount(String amount) {
    return '$amount बचत में सुरक्षित';
  }

  @override
  String reportTotalSpent(String amount) {
    return 'कुल खर्च $amount';
  }

  @override
  String get reportWhereMoneyWent => 'पैसा कहाँ गया';

  @override
  String get reportNoSpending => 'इस महीने कोई खर्च नहीं लिखा';

  @override
  String get reportLast6 => 'बचत — पिछले 6 महीने';

  @override
  String get reportBestJar => 'सबसे बढ़िया गिलास';

  @override
  String get reportWorstJar => 'ध्यान दें';

  @override
  String reportUsed(int percent) {
    return '$percent% खर्च';
  }

  @override
  String get reportVsLastMonth => 'पिछले महीने से तुलना';

  @override
  String reportSpentMore(int percent) {
    return 'आपने $percent% ज़्यादा खर्च किया';
  }

  @override
  String reportSpentLess(int percent) {
    return 'आपने $percent% कम खर्च किया';
  }

  @override
  String get reportSpentSame => 'खर्च लगभग उतना ही रहा';

  @override
  String reportSavedMore(String amount) {
    return '$amount ज़्यादा बचाए';
  }

  @override
  String reportSavedLess(String amount) {
    return '$amount कम बचाए';
  }

  @override
  String get reportSavedSame => 'पिछले महीने जितनी ही बचत';

  @override
  String get reportNoPrevious => 'तुलना के लिए अभी पिछला महीना नहीं है';

  @override
  String get reportNotFunded => 'इस महीने के गिलास अभी भरे नहीं हैं।';

  @override
  String get reportNoData => 'पहले सैलरी वाले दिन के बाद आपकी रिपोर्ट दिखेगी।';

  @override
  String get reportTipTitle => 'पैसों की टिप';

  @override
  String get reportTip1 =>
      'बड़ी ख़रीदारी से पहले 3 महीने के खर्च जितना इमरजेंसी फ़ंड रखो।';

  @override
  String get reportTip2 =>
      'छोटे-छोटे खर्च जुड़ जाते हैं — रोज़ ₹50 मतलब महीने के ₹1,500।';

  @override
  String get reportTip3 => 'कमाई बढ़े तो पहले बचत बढ़ाओ, फिर खर्च।';

  @override
  String get reportTip4 =>
      'एक हफ़्ता हर खर्च लिखो — आसानी से बचत के रास्ते दिखेंगे।';

  @override
  String get reportDisclaimer =>
      'ये बस सीखने के लिए आम सुझाव हैं — कोई वित्तीय सलाह नहीं।';

  @override
  String get badgesTitle => 'बैज';

  @override
  String get levelTitle => 'आपका लेवल';

  @override
  String levelToNext(String amount, String level) {
    return '$level बनने के लिए $amount और';
  }

  @override
  String get levelMax => 'आप सबसे ऊँचे लेवल पर हो!';

  @override
  String get levelBeginner => 'नए-नए';

  @override
  String get levelSaver => 'बचतकर्ता';

  @override
  String get levelSmartSaver => 'समझदार बचतकर्ता';

  @override
  String get levelGullakMaster => 'गुल्लक मास्टर';

  @override
  String get levelLegend => 'PehlaPaisa लीजेंड';

  @override
  String get badgeLocked => 'बंद';

  @override
  String badgeUnlockedOn(String date) {
    return '$date को मिला';
  }

  @override
  String badgesCount(int unlocked, int total) {
    return '$total में से $unlocked मिले';
  }

  @override
  String get badgePehlaKadam => 'पहला कदम';

  @override
  String get badgePehlaKadamDesc => 'अपनी शेल्फ़ तैयार की';

  @override
  String get badgePehlaPaisa => 'पहला पैसा';

  @override
  String get badgePehlaPaisaDesc => 'पहली बार सबसे पहले बचत भरी';

  @override
  String get badgeStreak3 => 'सिलसिला 3';

  @override
  String get badgeStreak3Desc => 'लगातार 3 महीने पहले ख़ुद को पैसे';

  @override
  String get badgeStreak6 => 'सिलसिला 6';

  @override
  String get badgeStreak6Desc => 'लगातार 6 महीने पहले ख़ुद को पैसे';

  @override
  String get badgeStreak12 => 'सिलसिला 12';

  @override
  String get badgeStreak12Desc => 'पूरा एक साल पहले ख़ुद को पैसे';

  @override
  String get badgeGullakMaster => 'गुल्लक मास्टर';

  @override
  String get badgeGullakMasterDesc => 'कुल ₹10,000 बचाए';

  @override
  String get badgeGoalGetter => 'लक्ष्य वीर';

  @override
  String get badgeGoalGetterDesc => 'पहला लक्ष्य पूरा किया';

  @override
  String get badgeFunUnderControl => 'मस्ती पर क़ाबू';

  @override
  String get badgeFunUnderControlDesc =>
      'एक महीना मौज-मस्ती को शून्य से नीचे या उधार के बिना पूरा किया';

  @override
  String get badgeLogger => 'हिसाब वाला';

  @override
  String get badgeLoggerDesc => 'लगातार 7 दिन खर्च लिखा';

  @override
  String get badgeBachatChampion => 'बचत चैंपियन';

  @override
  String get badgeBachatChampionDesc =>
      'एक महीने में कमाई का 25% या ज़्यादा बचाया';

  @override
  String get celebrateBadge => 'बैज मिला!';

  @override
  String get celebrateGoal => 'लक्ष्य पूरा!';

  @override
  String celebrateGoalBody(String goal) {
    return 'आपने $goal का गिलास पूरा भर दिया।';
  }

  @override
  String get celebrateStreak => 'सिलसिले का नया महीना!';

  @override
  String get celebrateSavings => 'सबसे पहले बचत भरी!';

  @override
  String get celebrateContinue => 'वाह! आगे चलें';

  @override
  String get shareTitle => 'अपनी प्रगति शेयर करें';

  @override
  String get shareStory => 'स्टोरी';

  @override
  String get sharePost => 'पोस्ट';

  @override
  String get shareCardStreak => 'सिलसिला';

  @override
  String get shareCardSaved => 'बचत';

  @override
  String get shareShowAmounts => 'रक़म दिखाएँ';

  @override
  String get shareShowAmountsHint =>
      'पहले से बंद — आपकी कमाई और बैलेंस निजी रहते हैं';

  @override
  String get shareButton => 'तस्वीर शेयर करें';

  @override
  String shareStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महीनों',
      one: '1 महीने',
    );
    return '🔥 $_temp0 से पहले ख़ुद को पैसे';
  }

  @override
  String shareSavedTitle(String amount) {
    return 'मैंने PehlaPaisa के साथ $amount बचाए';
  }

  @override
  String get shareSavedTitleHidden =>
      'मैं PehlaPaisa के साथ पहले ख़ुद को पैसे देता/देती हूँ';

  @override
  String shareSavedSub(int percent) {
    return 'मेरी कमाई का $percent% पहले बचत में जाता है';
  }

  @override
  String shareGoalTitle(String goal) {
    return 'लक्ष्य पूरा: $goal';
  }

  @override
  String shareGoalSub(String amount) {
    return '$amount बचाए';
  }

  @override
  String get shareGoalSubHidden => 'पूरा भर गया 🎉';

  @override
  String shareBadgeTitle(String badge) {
    return 'बैज मिला: $badge';
  }

  @override
  String get shareMessage =>
      'पहले बचाओ, फिर खर्चो — मैं PehlaPaisa के साथ बचत की आदत बना रहा/रही हूँ।';

  @override
  String get shareFailed => 'तस्वीर नहीं बन पाई। फिर से कोशिश करें।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsProfile => 'प्रोफ़ाइल';

  @override
  String get settingsEditProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get settingsName => 'नाम';

  @override
  String get settingsIncome => 'महीने की कमाई';

  @override
  String get settingsSalaryDay => 'सैलरी की तारीख़';

  @override
  String get settingsSalaryDayNote => 'नई तारीख़ अगले महीने से लागू होगी।';

  @override
  String get settingsIncomeType => 'कमाई का तरीका';

  @override
  String get settingsFamily => 'परिवार के साथ रहते हैं';

  @override
  String get settingsEditSplit => 'बँटवारा बदलें';

  @override
  String get settingsEditSplitDesc => 'कमाई कैसे बँटे, ये बदलें';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get themeSystem => 'फ़ोन के हिसाब से';

  @override
  String get themeDark => 'रात की शेल्फ़ (डार्क)';

  @override
  String get themeLight => 'सुबह की शेल्फ़ (लाइट)';

  @override
  String get settingsNotifications => 'याद दिलाना';

  @override
  String get notifMaster => 'नोटिफ़िकेशन चालू';

  @override
  String get notifSalary => 'सैलरी वाले दिन याद दिलाएँ';

  @override
  String get notifWeekly => 'हफ़्ते का हिसाब (रविवार शाम)';

  @override
  String get notifLowBalance => 'गिलास ख़ाली होने की चेतावनी';

  @override
  String get notifDaily => 'रोज़ खर्च लिखने की याद';

  @override
  String get notifDailyTime => 'याद दिलाने का समय';

  @override
  String get notifPermissionDenied =>
      'फ़ोन की सेटिंग्स में PehlaPaisa के नोटिफ़िकेशन बंद हैं।';

  @override
  String get settingsSharing => 'शेयरिंग';

  @override
  String get settingsData => 'आपका डेटा';

  @override
  String get settingsExport => 'डेटा निकालें (JSON)';

  @override
  String get settingsExportDesc => 'अपने सारे डेटा की कॉपी सेव करें या भेजें';

  @override
  String get settingsReset => 'सारा डेटा मिटाएँ';

  @override
  String get settingsResetDesc => 'सब कुछ मिटाकर नए सिरे से शुरू करें';

  @override
  String get resetTitle1 => 'सब कुछ मिटाना है?';

  @override
  String get resetBody1 =>
      'सारे गिलास, खर्च, लक्ष्य, सिलसिले और बैज इस फ़ोन से मिट जाएँगे।';

  @override
  String get resetTitle2 => 'क्या आप बिल्कुल पक्का हैं?';

  @override
  String get resetBody2 =>
      'यह वापस नहीं होगा। अगर डेटा निकाला नहीं है तो कोई बैकअप नहीं है।';

  @override
  String get resetConfirm => 'हाँ, सब मिटा दो';

  @override
  String get resetDone => 'सारा डेटा मिट गया';

  @override
  String get settingsAbout => 'PehlaPaisa के बारे में';

  @override
  String get profileSaved => 'प्रोफ़ाइल सेव हो गई';

  @override
  String get splitEditorTitle => 'बँटवारा बदलें';

  @override
  String get splitEditorHint =>
      'बदलाव अगली बार गिलास भरने से लागू होंगे। जो बचेगा वो मौज-मस्ती में।';

  @override
  String splitEditorIncome(String amount) {
    return 'महीने की कमाई $amount के हिसाब से';
  }

  @override
  String get splitUseSuggested => 'सुझाया बँटवारा लगाएँ';

  @override
  String get splitSaved => 'बँटवारा सेव हो गया';

  @override
  String get customJarAdd => 'अपना गिलास जोड़ें';

  @override
  String get customJarName => 'गिलास का नाम';

  @override
  String get customJarNameHint => 'जैसे दवाइयाँ';

  @override
  String get customJarRemove => 'गिलास हटाएँ';

  @override
  String get customJarRemoveBody =>
      'इसके पैसे और हिस्सा मौज-मस्ती में चले जाएँगे।';

  @override
  String get aboutTitle => 'जानकारी';

  @override
  String get aboutBody =>
      'PehlaPaisa एक आदत बनाने में मदद करता है: सैलरी वाले दिन सबसे पहले बचत का गिलास भरो। फिर बाक़ी गिलासों से बेफ़िक्र खर्च करो — वो साफ़ दिखाते हैं कितना बचा है।';

  @override
  String get aboutPrivacyTitle => 'आपकी प्राइवेसी';

  @override
  String get aboutPrivacy =>
      'आपका बजट इसी फ़ोन में रहता है: न लॉगिन, न क्लाउड, न बैंक या SMS की पहुँच। ऐप में Google AdMob के कुछ विज्ञापन दिखते हैं; इसके लिए Google को आपके फ़ोन की विज्ञापन ID और फ़ोन की सामान्य जानकारी मिलती है — आपका बजट कभी नहीं। पेमेंट आपके अपने UPI ऐप में होता है — PehlaPaisa आपका PIN या बैंक की जानकारी कभी नहीं देखता।';

  @override
  String get aboutDisclaimerTitle => 'वित्तीय सलाह नहीं';

  @override
  String get aboutDisclaimer =>
      'PehlaPaisa सिर्फ़ पैसों से जुड़े आम और सीखने वाले सुझाव देता है। यह निवेश या वित्तीय सलाह नहीं देता।';

  @override
  String aboutVersion(String version) {
    return 'वर्ज़न $version';
  }

  @override
  String get aboutMadeWith =>
      'पहली नौकरी वालों, स्टूडेंट्स, फ्रीलांसरों और गिग वर्करों के लिए प्यार से बनाया।';

  @override
  String get notifWelcomeTitle => 'याद दिलाना चालू है 🔔';

  @override
  String get notifWelcomeBody =>
      'हम सैलरी वाले दिन, हर रविवार शाम और गिलास ख़ाली होने पर याद दिलाएँगे।';

  @override
  String get notifTestButton => 'टेस्ट नोटिफ़िकेशन भेजें';

  @override
  String get notifTestDesc => 'देखें सैलरी वाले दिन की याद कैसी दिखती है';

  @override
  String get notifChannel => 'याद दिलाना';

  @override
  String get notifSalaryTitle => 'सैलरी का दिन!';

  @override
  String get notifSalaryBody => 'सैलरी का दिन! पहले बचत का गिलास भरो 🟡';

  @override
  String get notifWeeklyTitle => 'हफ़्ते का हिसाब';

  @override
  String notifWeeklyBody(String amount) {
    return 'इस हफ़्ते अब तक $amount खर्च हुए। अपने गिलास देखने के लिए PehlaPaisa खोलें।';
  }

  @override
  String get notifDailyTitle => 'छोटी-सी याद';

  @override
  String get notifDailyBody => 'आज का खर्च लिखें';

  @override
  String get notifLowTitle => 'गिलास ख़ाली हो रहा है';
}
