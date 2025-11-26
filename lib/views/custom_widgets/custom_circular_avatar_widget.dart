import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gfcm_trading/constants/color_constants.dart';

class CustomCircularAvatarWidget extends StatelessWidget {
  final String? isNetworknull;
  final double? height;
  final double? width;
  final String? image;
  final Icon? icon;
  final String? text;
  final double? fw;
  final double? iconSize;
  final Color? textColor;
  final VoidCallback? onTab;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final bool isNetwork;
  Color? boxColor;
  Widget? svgIcon;
  bool isAsset = false;
  File? localImage;

  CustomCircularAvatarWidget({
    super.key,
    this.height,
    this.width,
    this.image,
    this.icon,
    this.text,
    this.fw,
    this.iconSize,
    this.textColor,
    this.onTab,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.isNetwork = false,
    this.isNetworknull = "",
    this.boxColor,
    this.svgIcon,
    required this.isAsset,
    this.localImage,
  });
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 50,
      height: height ?? 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: boxColor ?? Colors.grey,
      ),
      child:
          isAsset
              ? svgIcon
              : localImage != null
              ? ClipOval(
                child: Image.file(
                  localImage!,
                  width: width ?? 50,
                  height: height ?? 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: iconSize ?? 40,
                      color: colorConstants.primaryColor,
                    );
                  },
                ),
              )
              : image != null && image!.startsWith('http')
              ? ClipOval(
                child: Image.network(
                  image ?? "",
                  width: width ?? 50,
                  height: height ?? 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      color: colorConstants.primaryColor,
                      size: iconSize ?? 40,
                    );
                  },
                ),
              )
              : Icon(
                Icons.person,
                color: colorConstants.primaryColor,
                size: iconSize ?? 40,
              ),
    );
  }
}
