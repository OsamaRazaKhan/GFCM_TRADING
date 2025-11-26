import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/main.dart';

class SearchAbleCustomDropDownButton<T extends GetxController>
    extends StatefulWidget {
  final double? dropDownListTextSize;
  final double? height;
  final double? width;
  final Color? textColor;
  final double? textSize;
  final FontWeight? textFw;
  final List<String>? dropDownButtonList;
  final String? text;
  final bool? isShowingCustomNames;
  final T controller;
  final String? selectedValue;
  final String valueType;
  final Color? buttonColor;

  const SearchAbleCustomDropDownButton({
    super.key,
    this.dropDownButtonList,
    this.text,
    this.height,
    this.width,
    this.textColor,
    this.textSize,
    this.textFw,
    this.isShowingCustomNames = false,
    this.dropDownListTextSize,
    required this.controller,
    required this.selectedValue,
    required this.valueType,
    this.buttonColor,
  });
  @override
  State<SearchAbleCustomDropDownButton> createState() =>
      _SearchAbleCustomDropDownButtonState<T>();
}

class _SearchAbleCustomDropDownButtonState<T extends GetxController>
    extends State<SearchAbleCustomDropDownButton<T>> {
  late MediaQueryData mediaQuery;
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);
    return GetBuilder<T>(
      init: widget.controller,
      builder: (dropDownController) {
        final customController = dropDownController as dynamic;

        return Container(
          decoration: BoxDecoration(
            color: widget.buttonColor ?? colorConstants.fieldColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: DropdownSearch<String>(
            selectedItem: widget.selectedValue,
            onChanged: (value) {
              if (value != null) {
                customController.selectValueFromSearchAbleDropDown(
                  widget.valueType,
                  value,
                );
              }
            },
            items: (filter, _) {
              // Smooth loading: return filtered items
              final filteredList = widget.dropDownButtonList!
                  .where(
                    (item) =>
                        item.toLowerCase().contains(filter.toLowerCase()),
                  )
                  .toList();
              return filteredList;
            },

            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: widget.text,
                hintStyle: TextStyle(
                  fontSize: widget.textSize,
                  color: widget.textColor,
                  fontWeight: widget.textFw,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(
                    color: colorConstants.fieldBorderColor,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(
                    color: colorConstants.fieldBorderColor,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(
                    color: colorConstants.fieldBorderColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              itemBuilder: (context, item, isDisabled, isSelected) {
                return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorConstants.blackColor,
                    ),
                  ),
                );
              },
              // Smooth menu appearance
              menuProps: MenuProps(
                elevation: 4,
                borderRadius: BorderRadius.circular(10.r),
              ),
              fit: FlexFit.loose,
              constraints: BoxConstraints(),
              containerBuilder: (ctx, popupWidget) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Material(
                    color:
                        colorConstants
                            .primaryColor, //set dropdown background color here
                    child: popupWidget,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
