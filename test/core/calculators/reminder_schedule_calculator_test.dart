import 'package:flutter_test/flutter_test.dart';
import 'package:minum/src/core/calculators/reminder_schedule_calculator.dart';

void main() {
  late ReminderScheduleCalculator calculator;

  setUp(() {
    calculator = ReminderScheduleCalculator();
  });

  group('ReminderScheduleCalculator', () {
    test('schedules full day slots at 2h intervals', () {
      final now = DateTime(2026, 6, 15, 6, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 2.0,
        startTimeHour: 8,
        startTimeMinute: 0,
        endTimeHour: 22,
        endTimeMinute: 0,
        now: now,
      );
      expect(slots.length, 8);
      expect(slots[0].hour, 8);
      expect(slots[0].minute, 0);
      expect(slots[1].hour, 10);
      expect(slots[2].hour, 12);
      expect(slots[3].hour, 14);
      expect(slots[4].hour, 16);
      expect(slots[5].hour, 18);
      expect(slots[6].hour, 20);
      expect(slots[7].hour, 22);
    });

    test('skips slots before current time', () {
      final now = DateTime(2026, 6, 15, 15, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 2.0,
        startTimeHour: 8,
        startTimeMinute: 0,
        endTimeHour: 22,
        endTimeMinute: 0,
        now: now,
      );
      expect(slots.length, 4);
      expect(slots[0].hour, 16);
      expect(slots[1].hour, 18);
      expect(slots[2].hour, 20);
      expect(slots[3].hour, 22);
    });

    test('returns empty when schedule window has passed', () {
      final now = DateTime(2026, 6, 15, 23, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 2.0,
        startTimeHour: 8,
        startTimeMinute: 0,
        endTimeHour: 22,
        endTimeMinute: 0,
        now: now,
      );
      expect(slots, isEmpty);
    });

    test('handles overnight schedule (end < start)', () {
      final now = DateTime(2026, 6, 15, 14, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 4.0,
        startTimeHour: 22,
        startTimeMinute: 0,
        endTimeHour: 6,
        endTimeMinute: 0,
        now: now,
      );
      // Overnight: schedules from start to end-of-day today
      expect(slots.length, 1);
      expect(slots[0].hour, 22);
      expect(slots[0].minute, 0);
      expect(slots[0].day, 15);
    });

    test('returns empty for zero interval', () {
      final now = DateTime(2026, 6, 15, 8, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 0.0,
        startTimeHour: 8,
        startTimeMinute: 0,
        endTimeHour: 22,
        endTimeMinute: 0,
        now: now,
      );
      expect(slots, isEmpty);
    });

    test('returns empty for negative interval', () {
      final now = DateTime(2026, 6, 15, 8, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: -1.0,
        startTimeHour: 8,
        startTimeMinute: 0,
        endTimeHour: 22,
        endTimeMinute: 0,
        now: now,
      );
      expect(slots, isEmpty);
    });

    test('handles 30-minute intervals', () {
      final now = DateTime(2026, 6, 15, 9, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 0.5,
        startTimeHour: 9,
        startTimeMinute: 0,
        endTimeHour: 11,
        endTimeMinute: 0,
        now: now,
      );
      expect(slots.length, 4);
      expect(slots[0].hour, 9);
      expect(slots[0].minute, 30);
      expect(slots[1].hour, 10);
      expect(slots[1].minute, 0);
      expect(slots[2].hour, 10);
      expect(slots[2].minute, 30);
      expect(slots[3].hour, 11);
      expect(slots[3].minute, 0);
    });

    test('respects maxNotifications limit', () {
      final now = DateTime(2026, 6, 15, 0, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 0.1,
        startTimeHour: 0,
        startTimeMinute: 0,
        endTimeHour: 23,
        endTimeMinute: 59,
        now: now,
        maxNotifications: 5,
      );
      expect(slots.length, 5);
    });

    test('schedule starting at same time as now includes next interval', () {
      final now = DateTime(2026, 6, 15, 10, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 1.0,
        startTimeHour: 10,
        startTimeMinute: 0,
        endTimeHour: 12,
        endTimeMinute: 0,
        now: now,
      );
      // Current time is 10:00, start is 10:00.
      // nextReminderTime starts at 10:00, then advances while before now
      // 10:00 is not before 10:00, so it stays at 10:00
      // Then: if nextReminderTime.isAfter(now) => 10:00 is NOT after 10:00 => skipped
      // Advances to 11:00 -> isAfter(10:00) => added
      // Advances to 12:00 -> isAtSameMomentAs(12:00) => added
      // So: 11:00, 12:00
      expect(slots.length, 2);
      expect(slots[0].hour, 11);
      expect(slots[1].hour, 12);
    });

    test('includes end time slot', () {
      final now = DateTime(2026, 6, 15, 6, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 3.0,
        startTimeHour: 9,
        startTimeMinute: 0,
        endTimeHour: 15,
        endTimeMinute: 0,
        now: now,
      );
      // 9:00, 12:00, 15:00
      expect(slots.length, 3);
      expect(slots[2].hour, 15);
      expect(slots[2].minute, 0);
    });

    test('overnight schedule includes today slots only', () {
      final now = DateTime(2026, 6, 15, 22, 0, 0);
      final slots = calculator.calculateScheduleForToday(
        intervalHours: 3.0,
        startTimeHour: 23,
        startTimeMinute: 0,
        endTimeHour: 2,
        endTimeMinute: 0,
        now: now,
      );
      // Overnight: only today's slots (23:00), not tomorrow's (02:00)
      expect(slots.length, 1);
      expect(slots[0].hour, 23);
      expect(slots[0].day, 15);
    });
  });
}
