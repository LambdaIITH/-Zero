// ignore_for_file: constant_identifier_names
import 'package:dashbaord/models/lecture_model.dart';

enum IITHSlot {
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  P,
  Q,
  R,
  S,
  W,
  X,
  Y,
  Z,
  AN1,
  AN2,
  AN4,
  FN1,
  FN2,
  FN3,
  FN4,
  FN5,
}

List<String> getAllSlots() {
  return IITHSlot.values
      .map((slot) => slot.toString().split('.').last)
      .toList();
}

IITHSlot? getSlotFromString(String slotString) {
  try {
    return IITHSlot.values
        .firstWhere((slot) => slot.toString().split('.').last == slotString);
  } catch (e) {
    return null;
  }
}

extension SlotExtension on IITHSlot {
  List<Lecture> getLectures({String courseCode = ""}) {
    switch (this) {
      case IITHSlot.A:
        return [
          Lecture(
              day: "Monday",
              startTime: "9:00 AM",
              endTime: "10:00 AM",
              courseCode: courseCode),
          Lecture(
              day: "Wednesday",
              startTime: "11:00 AM",
              endTime: "12:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "10:00 AM",
              endTime: "11:00 AM",
              courseCode: courseCode),
        ];
      case IITHSlot.B:
        return [
          Lecture(
              day: "Monday",
              startTime: "10:00 AM",
              endTime: "11:00 AM",
              courseCode: courseCode),
          Lecture(
              day: "Wednesday",
              startTime: "9:00 AM",
              endTime: "10:00 AM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "11:00 AM",
              endTime: "12:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.C:
        return [
          Lecture(
              day: "Monday",
              startTime: "11:00 AM",
              endTime: "12:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Wednesday",
              startTime: "10:00 AM",
              endTime: "11:00 AM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "9:00 AM",
              endTime: "10:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.D:
        return [
          Lecture(
              day: "Monday",
              startTime: "12:00 PM",
              endTime: "1:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Tuesday",
              startTime: "9:00 AM",
              endTime: "10:00 AM",
              courseCode: courseCode),
          Lecture(
              day: "Friday",
              startTime: "11:00 AM",
              endTime: "12:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.E:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "10:00 AM",
              endTime: "11:00 AM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "12:00 PM",
              endTime: "1:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Friday",
              startTime: "9:00 AM",
              endTime: "10:00 AM",
              courseCode: courseCode),
        ];
      case IITHSlot.F:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "11:00 AM",
              endTime: "12:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Wednesday",
              startTime: "2:30 PM",
              endTime: "4:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Friday",
              startTime: "10:00 AM",
              endTime: "11:00 AM",
              courseCode: courseCode),
        ];
      case IITHSlot.G:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "12:00 PM",
              endTime: "1:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Wednesday",
              startTime: "12:00 PM",
              endTime: "1:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Friday",
              startTime: "12:00 PM",
              endTime: "1:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.P:
        return [
          Lecture(
              day: "Monday",
              startTime: "2:30 PM",
              endTime: "4:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "4:00 PM",
              endTime: "5:30 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.Q:
        return [
          Lecture(
              day: "Monday",
              startTime: "4:00 PM",
              endTime: "5:30 PM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "2:30 PM",
              endTime: "4:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.R:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "2:30 PM",
              endTime: "4:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "4:00 PM",
              endTime: "5:30 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.S:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "4:00 PM",
              endTime: "5:30 PM",
              courseCode: courseCode),
          Lecture(
              day: "Friday",
              startTime: "2:30 PM",
              endTime: "4:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.W:
        return [
          Lecture(
              day: "Monday",
              startTime: "6:00 PM",
              endTime: "7:30 PM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "6:00 PM",
              endTime: "7:30 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.X:
        return [
          Lecture(
              day: "Monday",
              startTime: "7:30 PM",
              endTime: "9:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Thursday",
              startTime: "7:30 PM",
              endTime: "9:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.Y:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "6:00 PM",
              endTime: "7:30 PM",
              courseCode: courseCode),
          Lecture(
              day: "Friday",
              startTime: "6:00 PM",
              endTime: "7:30 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.Z:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "7:30 PM",
              endTime: "9:00 PM",
              courseCode: courseCode),
          Lecture(
              day: "Friday",
              startTime: "7:30 PM",
              endTime: "9:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.AN1:
        return [
          Lecture(
              day: "Monday",
              startTime: "2:30 PM",
              endTime: "5:30 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.AN2:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "2:30 PM",
              endTime: "5:30 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.AN4:
        return [
          Lecture(
              day: "Thursday",
              startTime: "2:30 PM",
              endTime: "5:30 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.FN1:
        return [
          Lecture(
              day: "Monday",
              startTime: "9:00 AM",
              endTime: "12:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.FN2:
        return [
          Lecture(
              day: "Tuesday",
              startTime: "9:00 AM",
              endTime: "12:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.FN3:
        return [
          Lecture(
              day: "Wednesday",
              startTime: "9:00 AM",
              endTime: "12:00 PM",
              courseCode: courseCode),
        ];
      case IITHSlot.FN4:
        return [
          Lecture(
              day: "Thursday",
              startTime: "9:00 AM",
              endTime: "12:00 AM",
              courseCode: courseCode),
        ];
      case IITHSlot.FN5:
        return [
          Lecture(
              day: "Friday",
              startTime: "9:00 AM",
              endTime: "12:00 AM",
              courseCode: courseCode),
        ];
      default:
        return [];
    }
  }
}
