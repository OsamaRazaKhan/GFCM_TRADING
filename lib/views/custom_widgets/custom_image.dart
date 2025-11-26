import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomImage extends StatelessWidget {
  final String? isNetworknull;
  final double? height;
  final double? width;
  final String? image;
  final Icon? icon;
  final String? text;
  final double? fw;
  final double? size;
  final Color? textColor;
  final VoidCallback? onTab;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final bool isNetwork;
  final double? iconSize;
  const CustomImage({
    super.key,
    this.height,
    this.width,
    this.image,
    this.icon,
    this.text,
    this.fw,
    this.size,
    this.textColor,
    this.onTab,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.isNetwork = false,
    this.isNetworknull = "",
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 0.r),
        border: Border.all(
          width: borderWidth ?? 0.0,
          color: borderColor ?? Colors.transparent,
        ),
        color: Colors.transparent,
      ),
      child:
          isNetwork
              ? image != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius ?? 0.r),
                    child: Image.network(
                      image ?? "",
                      width: width ?? 50,
                      height: height ?? 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: width ?? 50,
                          height: height ?? 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              borderRadius ?? 0.r,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: iconSize ?? 24,
                          ),
                        );
                      },
                    ),
                  )
                  : Icon(Icons.image, color: Colors.white, size: iconSize ?? 24)
              : ClipRRect(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? 0.r,
                ), // Clip the image with border radius
                child:
                    image != null
                        ? Image.asset(
                          image!,
                          height: height,
                          width: width,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              size: iconSize ?? 50,
                              color: Colors.grey,
                            );
                          },
                        )
                        : Icon(
                          Icons
                              .image_not_supported, // Icon when image is null or empty
                          size:
                              width ??
                              50.w, // Set the icon size to match image container
                          color: Colors.grey,
                        ),
              ),
    );
  }
}
