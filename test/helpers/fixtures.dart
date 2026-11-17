import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/jars/domain/jar_factory.dart';
import 'package:pehla_paisa/features/salary/data/month_cycle.dart';

/// Jars with the given remaining balances (allocated = remaining, spent = 0).
List<Jar> jarsWith({
  int savings = 2000,
  int rent = 3500,
  int food = 2500,
  int travel = 1000,
  int fun = 1000,
}) {
  final plan = {
    JarType.savings: savings,
    JarType.rent: rent,
    JarType.food: food,
    JarType.travel: travel,
    JarType.fun: fun,
  };
  return JarFactory.defaultJars(plan)
      .map((j) => j.copyWith(allocatedAmount: plan[j.type]))
      .toList();
}

Jar jarOf(List<Jar> jars, JarType t) => jars.firstWhere((j) => j.type == t);

MonthCycle cycle(
  int year,
  int month, {
  bool funded = true,
  bool filledFirst = true,
  bool broken = false,
  bool closed = true,
  int income = 10000,
  List<JarSnapshot> snapshot = const [],
}) {
  final id = '$year-${month.toString().padLeft(2, '0')}';
  return MonthCycle(
    id: id,
    month: month,
    year: year,
    startDate: DateTime(year, month, 1),
    endDate: DateTime(year, month + 1, 0),
    income: income,
    savingsFilledFirst: filledFirst,
    savingsFilledAt: filledFirst ? DateTime(year, month, 1) : null,
    savingsBroken: broken,
    funded: funded,
    jarsSnapshot: snapshot,
    closed: closed,
  );
}

int _counter = 0;
String testId() => 'id_${_counter++}';
