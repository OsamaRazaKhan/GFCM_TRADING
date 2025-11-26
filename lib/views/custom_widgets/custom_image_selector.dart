import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/main.dart';

class CustomImageSelector<T extends GetxController> extends StatefulWidget {
  final double? height;
  final double? width;
  final double? radius;
  final Color? color;
  final Icon? icon;
  final File? image;
  final T controller;

  VoidCallback? onTap;
  CustomImageSelector({
    super.key,
    this.height,
    this.width,
    this.radius,
    this.color,
    this.icon,
    this.image,
    required this.controller,
    this.onTap,
  });
  @override
  State<CustomImageSelector> createState() => _CustomImageSelectorState<T>();
}

ColorConstants colorConstants = ColorConstants();

class _CustomImageSelectorState<T extends GetxController>
    extends State<CustomImageSelector<T>> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);
    return GetBuilder<T>(
      init: widget.controller,
      builder: (imageController) {
        return InkWell(
          onTap: widget.onTap,
          child:
              widget.image != null
                  ? Image.file(
                    widget.image!,
                    height: widget.height,
                    width: widget.width,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    height: widget.height,
                    width: widget.width,
                    decoration: BoxDecoration(color: widget.color),
                    child: Icon(
                      Icons.camera_alt_sharp,
                      size: 100.sp,
                      color: colorConstants.iconGrayColor,
                    ),
                  ),
        );
      },
    );
  }
}
