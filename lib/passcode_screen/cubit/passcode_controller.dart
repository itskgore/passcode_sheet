import 'package:flutter/material.dart';

import 'passcode_state.dart';

class PasscodeController extends ChangeNotifier {
  PasscodeState passcodeState = PasscodeInitial();

// changing the states here to change the UI
  emit(PasscodeState state) {
    passcodeState = state;
    notifyListeners();
  }

// characters needed to enter a passcode
  List<Map<String, dynamic>> numbers = [
    {"no": 1, "actions": "no"},
    {"no": 2, "actions": "no"},
    {"no": 3, "actions": "no"},
    {"no": 4, "actions": "no"},
    {"no": 5, "actions": "no"},
    {"no": 6, "actions": "no"},
    {"no": 7, "actions": "no"},
    {"no": 8, "actions": "no"},
    {"no": 9, "actions": "no"},
    {"no": "Done", "actions": "Done"},
    {"no": 0, "actions": "no"},
    {"no": "<-", "actions": "yes"},
  ];

  // User entered string will be stored here
  List<String> passcode = [];

  // adding a passcode
  addPasscode({required dynamic number, required bool isRemove}) {
    if (isRemove) {
      // if user clicks on remove icon "<-"
      if (passcode.isNotEmpty) passcode.removeLast();
    } else {
      // if user clicks on any acceptable character
      passcode.add(number.toString());
    }
  }

  // manage size of small devices
  bool isSmallDevice(BuildContext context) {
    return MediaQuery.of(context).size.height <= 700;
  }

// When user clicks on "Done" Icons
  onDone(Map<String, dynamic> data, int passCodeLength,
      {List<String>? successPasscode}) {
    emit(PasscodeInitial());
    if (data['no'] == '<-') {
      addPasscode(number: data['no'], isRemove: true);
    } else if (data['no'] == "Done" || passcode.length == passCodeLength) {
      checkifSuccess(successPasscode, passcode);
    } else if (data['actions'] == "yes") {
      addPasscode(number: data['no'], isRemove: true);
    } else if (data['no'] == "Done" && passcode.length != passCodeLength) {
      emit(PasscodeError(errorMsg: "Please enter the passcode!"));
    } else {
      if (passcode.length == passCodeLength) {
        checkifSuccess(successPasscode, passcode);
      } else {
        addPasscode(number: data['no'], isRemove: !data.containsKey("no"));
        if (passcode.length == passCodeLength) {
          checkifSuccess(successPasscode, passcode);
        }
      }
    }
  }

// Checking if success passcode is passed or not then emitting the state
  checkifSuccess(List<String>? successPasscode, List<String> passcode) {
    if (successPasscode?.isNotEmpty ?? false) {
      if (haveSameValuesInSequence(successPasscode ?? [], passcode)) {
        emit(PasscodeLoaded(passcode: passcode));
      } else {
        emit(PasscodeError(errorMsg: "Incorrect passcode!"));
      }
    } else {
      emit(PasscodeLoaded(passcode: passcode));
    }
  }

// reset the passcode enteries
  reset() {
    passcode.clear();
    emit(PasscodeInitial());
  }

// start loading
  startLoading() {
    emit(PasscodeLoading());
  }

// throw a from UI
  throwError({required String errorMsg}) {
    emit(PasscodeError(
      errorMsg: errorMsg,
    ));
  }

// compare the values of success passcode and entered passcode
  bool haveSameValuesInSequence(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) {
      return false;
    }
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }
    return true;
  }
}
