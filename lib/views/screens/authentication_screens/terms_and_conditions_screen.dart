import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/auth_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  TermsAndConditionsDialog({super.key});
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colorConstants.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: GetBuilder<AuthController>(
        init: AuthController(),
        builder: (authController) {
          return Container(
            padding: EdgeInsets.all(20.r),
            constraints: BoxConstraints(maxHeight: 600.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      "Terms & Conditions",
                      color: colorConstants.blackColor,
                      fw: FontWeight.w600,
                      size: 18.sp,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20.sp,
                        color: colorConstants.blackColor,
                      ),
                      onPressed: () => Get.back(),
                    ),

                    // Title
                  ],
                ),

                SizedBox(height: 10.h),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: CustomText(
                      '''1. Acceptance of Terms
By using the GFCM(Global Forex Capital Markets) mobile application ("App"), you agree to these Terms & Conditions ("Terms"). If you disagree, do not access the App.

2. Eligibility
Users must be 18+ (or legal age in their jurisdiction). Prohibited in jurisdictions where trading is restricted.

3. Account Registration
Provide accurate, current information. You’re responsible for account security (passwords, 2FA). We may suspend accounts for suspicious activity.

4. Financial Risks
Trading involves high risk of financial loss. Past performance ≠ future results. You alone bear responsibility for trades.

5. Prohibited Activities
❌ Fraud, market manipulation, or illegal trades.
❌ Automated bots/scraping without permission.
❌ Sharing accounts or circumventing security.

6. Fees & Payments
Transaction fees, spreads, or commissions apply (see Fee Schedule). Fees are non-refundable unless required by law.

7. Intellectual Property
All App content (logos, algorithms) is owned by Global Forex Capital Markets. No copying, reverse engineering, or misuse allowed.

8. Termination
We may terminate access for violations, with or without notice.

9. Disclaimers
App is provided "as is"—no guarantees of profitability. We’re not liable for technical glitches, market delays, or losses.

10. Governing Law
Disputes will be resolved under [Country/State] law.

11. Changes to Terms
We may update these Terms; continued use = acceptance.

Contact Us:
For questions: [Support Email] | [Legal Address]
                      ''',
                      color: colorConstants.blackColor,
                      size: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
