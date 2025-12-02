import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorConstants.blackColor),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: CustomText(
          "Terms and conditions",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Logo
                    Center(
                      child: Column(
                        children: [
                          CustomImage(
                            height: 110.h,
                            width: 110.w,
                            image: AssetConstants.gfcmLogo,
                          ),
                          CustomText(
                            "Global Forex Capital Markets",
                            color: colorConstants.blackColor,
                            fw: FontWeight.w600,
                            size: 18.sp,
                          ),
                          SizedBox(height: 10.h),
                          CustomText(
                            "Version 1.0.0",
                            color: colorConstants.dimGrayColor,
                            fw: FontWeight.w600,
                            size: 13.sp,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Description Section
                    CustomText(
                      "1. Introduction and Acceptance\n"
                      "Welcome to GFCM (\"the Company,\" \"we,\" \"us,\" or \"our\"). These Terms and Conditions govern your (\"the Client,\" \"you,\" or \"your\") use of our trading platform, website, and all related services. By registering an account, depositing funds, or placing a trade, you acknowledge that you have read, understood, and irrevocably agree to be bound by these Terms in their entirety. If you do not agree, you must not use our services.\n\n"
                      "2. High-Risk Investment Warning\n"
                      "2.1 Trading Contracts for Difference (CFDs), foreign exchange (Forex), and other leveraged financial instruments carries a high level of risk and may not be suitable for all investors.\n"
                      "2.2 The possibility exists that you could sustain a loss of some or all of your initial deposited funds. You should not invest money you cannot afford to lose.\n"
                      "2.3 GFCM does not guarantee, assure, or promise any future profit, loss, or specific outcome from trading. Past performance is not indicative of future results. All trading decisions are made solely by you, and you are solely responsible for such decisions.\n\n"
                      "3. Client Eligibility and Account Registration\n"
                      "3.1 Age Parameter: You hereby represent and warrant that you are of legal age in your jurisdiction to enter into a binding contract. You must be at least 18 years old to open an account with GFCM.\n"
                      "3.2 Identity Verification: You agree to provide accurate, current, and complete information during registration and to promptly update it. You authorize GFCM to verify your identity and protect against fraud (KYC & AML policies).\n"
                      "3.3 Prohibition of Third-Party Accounts & Payments:\n"
                      "    • Account Ownership: Your trading account must be in your own legal name. Third-party use is strictly prohibited and may lead to suspension.\n"
                      "    • Payment Method Ownership: All deposits/withdrawals must be from payment methods registered in the same name as your GFCM account.\n\n"
                      "4. Deposits and Withdrawals\n"
                      "4.1 Deposits are processed within 24 hours on business days, subject to verification.\n"
                      "4.2 Withdrawals are processed within 24 hours on business days after compliance checks.\n"
                      "4.3 Processing times depend on the payment provider.\n"
                      "4.4 Fees may apply as listed on the website.\n\n"
                      "5. Trading Rules and Execution\n"
                      "5.1 All trades executed on the platform are your sole responsibility.\n"
                      "5.2 GFCM provides execution services and may operate as Market Maker or Principal-to-Principal.\n"
                      "5.3 During extreme volatility or technical disruption, orders may face slippage, re-quotes, or rejection.\n\n"
                      "6. Margin and Leverage\n"
                      "6.1 Trading on margin involves high risk; maintain sufficient margin.\n"
                      "6.2 GFCM may change leverage levels at its discretion.\n"
                      "6.3 GFCM may close positions if margin levels fall below requirements.\n\n"
                      "7. Intellectual Property\n"
                      "All content on the GFCM website/platform is the exclusive property of GFCM and may only be used for personal trading activities.\n\n"
                      "8. Liability and Indemnification\n"
                      "8.1 GFCM is not liable for direct, indirect, or consequential losses arising from use of services.\n"
                      "8.2 You agree to indemnify GFCM for any damages from your breach of these Terms or legal violations.\n\n"
                      "9. Complaints and Dispute Resolution\n"
                      "Complaints must be submitted in writing. Disputes are governed by the laws of the specified jurisdiction.\n\n"
                      "10. Amendments and Termination\n"
                      "10.1 GFCM may amend Terms anytime; continued use means acceptance.\n"
                      "10.2 Either party may terminate the account. GFCM may suspend accounts for breaches or fraud.\n\n"
                      "11. Force Majeure\n"
                      "GFCM is not liable for failure to perform due to events beyond reasonable control.\n\n"
                      "12. General Provisions\n"
                      "If any part of these Terms is invalid, the remainder stays in effect.\n"
                      "By clicking \"I Agree\" during registration, you confirm acceptance of these Terms and Conditions.\n",
                      color: colorConstants.dimGrayColor,
                      textAlign: TextAlign.justify,
                      size: 14.sp,
                    ),

                    SizedBox(height: 30.h),

                    // Divider
                    Divider(color: colorConstants.grayColor, thickness: 1),

                    SizedBox(height: 10.h),
                    CustomText(
                      "Company Information",
                      color: colorConstants.blackColor,
                      size: 15.sp,
                      fw: FontWeight.w600,
                    ),

                    SizedBox(height: 8.h),
                    CustomText(
                      "Abc Tech.\n123 Business Street, Karachi, Pakistan",
                      color: colorConstants.dimGrayColor,
                      size: 13.sp,
                    ),

                    SizedBox(height: 25.h),
                    Divider(color: colorConstants.grayColor, thickness: 1),

                    // Contact info
                    SizedBox(height: 10.h),

                    CustomText(
                      "Contact Support",
                      color: colorConstants.blackColor,
                      size: 15.sp,
                      fw: FontWeight.w600,
                    ),

                    SizedBox(height: 8.h),

                    CustomText(
                      "Email: support@raccoontech.com\nPhone: +92 300 1234567",
                      color: colorConstants.dimGrayColor,
                      size: 13.sp,
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Center(
              child: CustomText(
                "© 2025 Abc Tech. All rights reserved.",
                color: colorConstants.dimGrayColor,
                size: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
