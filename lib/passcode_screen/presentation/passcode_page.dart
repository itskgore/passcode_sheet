import 'package:flutter/material.dart';
import 'package:passcode_sheet/passcode_screen/cubit/passcode_controller.dart';
import 'package:passcode_sheet/passcode_screen/cubit/passcode_state.dart';
import 'package:passcode_sheet/widgets/shake_widget.dart';

// ignore: must_be_immutable
class Passcode extends StatefulWidget {
  final Function(List<String>) onChange;
  final Function(List<String>) onSubmit;
  final Function() onCancel;
  final Function(List<String>, String) onError;
  List<String>? successPasscode;
  bool? shouldHaveScaffold;
  BorderRadiusGeometry? borderRadius;
  final PasscodeController controller;
  int? passCodeLength;
  bool? showError;
  TextStyle? textStyle;
  Color? sheetColor;
  Color? bgColor;
  Color? errorColor;
  Color? passcodeBorderSelected;
  Color? passcodeBorderUnselected;
  Color? passcodeErrorBorderUnselected;
  Passcode(
      {super.key,
      this.shouldHaveScaffold,
      this.successPasscode,
      this.showError,
      this.passCodeLength = 4,
      this.borderRadius,
      this.errorColor,
      this.textStyle,
      this.sheetColor,
      this.bgColor,
      this.passcodeBorderSelected,
      this.passcodeBorderUnselected,
      this.passcodeErrorBorderUnselected,
      required this.controller,
      required this.onChange,
      required this.onError,
      required this.onSubmit,
      required this.onCancel});

  @override
  State<Passcode> createState() => PasscodePageState();
}

class PasscodePageState extends State<Passcode> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return widget.shouldHaveScaffold ?? false
        ? Scaffold(
            backgroundColor: widget.bgColor,
            body: PasscodeContainer(
                sheetColor: widget.sheetColor, widget: widget, size: size),
          )
        : PasscodeContainer(
            sheetColor: widget.sheetColor, widget: widget, size: size);
  }
}

class PasscodeContainer extends StatelessWidget {
  const PasscodeContainer({
    super.key,
    required this.sheetColor,
    required this.widget,
    required this.size,
  });

  final Color? sheetColor;
  final Passcode widget;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
            color: sheetColor ?? Colors.white,
            borderRadius: widget.borderRadius ??
                const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                )),
        child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              if (widget.controller.passcodeState is PasscodeError) {
                widget.onError(
                    widget.controller.passcode,
                    (widget.controller.passcodeState as PasscodeError)
                        .errorMsg);
                Future.delayed(const Duration(seconds: 1), () {
                  widget.controller.reset();
                });
              } else if (widget.controller.passcodeState is PasscodeLoaded) {
                widget.onSubmit(
                  widget.controller.passcode,
                );
                if (widget.successPasscode?.isNotEmpty ?? false) {
                  Future.delayed(const Duration(seconds: 1), () {
                    widget.controller.reset();
                  });
                }
              }

              return Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ShakeWidget(
                      key: widget.controller.passcodeState is PasscodeError
                          ? UniqueKey()
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            List.generate(widget.passCodeLength!, (index) {
                          var passcodeBorderSelected = Border.all(
                              color: Theme.of(context).primaryColor, width: 3);
                          var passcodeBorderUnselected = Border.all(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withOpacity(0.15),
                              width: 0);
                          var passcodeErrorBorderUnselected = Border.all(
                              color: widget.errorColor ?? Colors.red, width: 2);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: size.height * 0.025,
                            height: size.height * 0.025,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: widget.controller.passcodeState
                                      is PasscodeError
                                  ? passcodeErrorBorderUnselected
                                  : widget.controller.passcode
                                          .asMap()
                                          .containsKey(index)
                                      ? passcodeBorderSelected
                                      : passcodeBorderUnselected,
                              color: widget.controller.passcodeState
                                      is PasscodeError
                                  ? widget.errorColor ?? Colors.red
                                  : widget.controller.passcode
                                          .asMap()
                                          .containsKey(index)
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.15),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  widget.controller.passcodeState is PasscodeError
                      ? widget.showError ?? false
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      (widget.controller.passcodeState
                                              as PasscodeError)
                                          .errorMsg,
                                      textAlign: TextAlign.center,
                                      style: widget.textStyle ??
                                          const TextStyle(fontSize: 15))
                                ],
                              ),
                            )
                          : const SizedBox.shrink()
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 20,
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: widget.controller.numbers.length,
                    padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical:
                            widget.controller.isSmallDevice(context) ? 10 : 15),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 12,
                        mainAxisSpacing:
                            widget.controller.isSmallDevice(context) ? 0 : 10,
                        childAspectRatio: 1.8,
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          if (widget.controller.passcodeState
                              is! PasscodeLoading) {
                            if (widget.controller.numbers[index]['no'] !=
                                "Done") {
                              widget.controller.onDone(
                                  widget.controller.numbers[index],
                                  successPasscode: widget.successPasscode,
                                  widget.passCodeLength!);
                            }
                          }
                        },
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6)),
                            child: InkWell(
                              child:
                                  widget.controller.numbers[index]['no'] == "<-"
                                      ? const Icon(
                                          Icons.arrow_back,
                                          color: Colors.black,
                                        )
                                      : Text(
                                          "${widget.controller.numbers[index]['no'] == "Done" ? "" : widget.controller.numbers[index]['no']}",
                                          style: widget.textStyle ??
                                              const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                        ),
                            )),
                      );
                    },
                  ),
                ],
              );
            }));
  }
}
