import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CustomRadioButton<T extends GetxController> extends StatelessWidget {
  final String? status;
  final T controller;

  const CustomRadioButton({super.key, this.status, required this.controller});

  @override
  Widget build(BuildContext context) {
    ColorConstants colorConstants = ColorConstants();
    return GetBuilder<T>(
      init: controller,
      builder: (radioButtonController) {
        final customController = radioButtonController as dynamic;
        return Row(
          children: [
            Radio(
              value: status,
              groupValue: customController.selectedStatus,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorConstants.secondaryColor; // When selected
                }
                return colorConstants.boxgryColor; // When unselected
              }),
              onChanged: (value) {
                customController.selectStatus(value!);
              },
            ),
            Expanded(
              child: CustomText(
                status.toString(),
                size: 14.sp,
                fw: FontWeight.w400,
                color: colorConstants.hintTextColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
