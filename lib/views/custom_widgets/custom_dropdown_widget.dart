
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CustomDropDown<T extends GetxController> extends StatefulWidget {
  final FontWeight? fw;
  final double textSize;
  final Color? iconColor;
  final Color? boxColor;
  final Color? boxBorderColor;
  final List<String> items;
  final String? Function() selectedValue;
  final String defaultText;
  final String fieldValue;
  final T controller;
  bool isSimpleDropDown;

  CustomDropDown({
    super.key,
    required this.items,
    required this.boxColor,
    this.boxBorderColor,
    this.iconColor,
    this.fw,
    required this.textSize,
    required this.selectedValue,
    required this.defaultText,
    required this.fieldValue,
    required this.controller,
    this.isSimpleDropDown = false, // ✅ Receive controller
  });

  @override
  State<CustomDropDown> createState() => _CustomDropDownState<T>();
}

ColorConstants colorConstants = ColorConstants();

class _CustomDropDownState<T extends GetxController>
    extends State<CustomDropDown<T>> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      init: widget.controller,
      builder: (dropDownController) {
        final customController = dropDownController as dynamic;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: widget.boxBorderColor ?? Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Title with background
              widget.isSimpleDropDown
                  ? SizedBox()
                  : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 15.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.fieldValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              const SizedBox(width: 10),
              // Dropdown
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.selectedValue(),
                    hint: CustomText(
                      widget.defaultText,
                      size: 10.sp,
                      fw: FontWeight.w700,
                      color: colorConstants.blackColor,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: widget.iconColor),
                    isExpanded: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: widget.textSize,
                    ),
                    dropdownColor: widget.boxColor,
                    borderRadius: BorderRadius.circular(10),
                    padding: EdgeInsets.only(right: 10.w),
                    onChanged: (String? newValue) {
                      customController.selectValue(
                        widget.fieldValue,
                        newValue!,
                      );
                    },
                    items:
                        widget.items.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
