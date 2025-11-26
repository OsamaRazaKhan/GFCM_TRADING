import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/models/position_model.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/screens/market_sl_tp.dart';

class LimitSlTp extends StatefulWidget {
  const LimitSlTp({super.key});

  @override
  State<LimitSlTp> createState() => _SLTPOrderScreenState();
}

class _SLTPOrderScreenState extends State<LimitSlTp> {
  final TradeChartController controller = Get.find<TradeChartController>();
  final ColorConstants colorConstants = ColorConstants();

  final TextEditingController lotTextController = TextEditingController();
  final TextEditingController slTextController = TextEditingController();
  final TextEditingController tpTextController = TextEditingController();
  final TextEditingController entryPriceController = TextEditingController();

  TradeSide selectedTradeType = TradeSide.buy;
  double slValue = 0.0;
  double tpValue = 0.0;
  double lotSize = 0.01;
  double customEntryPrice = 0.0;
  bool skipSL = false;
  bool skipTP = false;

  String? validationError;
  bool isSubmitting = false;
  
  // New state variable for order type
  String selectedOrderType = "Limit"; // "Market" or "Limit"

  @override
  void initState() {
    super.initState();
    lotSize = controller.lotSize > 0 ? controller.lotSize : 0.01;
    lotTextController.text = lotSize.toStringAsFixed(2);
    slTextController.text = "";
    tpTextController.text = "";
    
    // Initialize entry price with live price
    final initialPrice = _getLivePrice();
    if (initialPrice > 0) {
      customEntryPrice = initialPrice;
      entryPriceController.text = initialPrice.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    lotTextController.dispose();
    slTextController.dispose();
    tpTextController.dispose();
    entryPriceController.dispose();
    super.dispose();
  }

  double _getLivePrice() {
    if (selectedTradeType == TradeSide.buy) {
      return controller.askPrice.value > 0
          ? controller.askPrice.value
          : (controller.lastPrice.value > 0 ? controller.lastPrice.value : 0.0);
    } else {
      return controller.bidPrice.value > 0
          ? controller.bidPrice.value
          : (controller.lastPrice.value > 0 ? controller.lastPrice.value : 0.0);
    }
  }

  double get entryPrice {
    return customEntryPrice > 0 ? customEntryPrice : _getLivePrice();
  }

  double getStepSize() {
    final ep = entryPrice;
    if (ep <= 0) return 0.01;
    if (ep < 100) return 0.01;
    if (ep < 1000) return 0.1;
    return 0.01;
  }

  double _normalize(double value) => double.parse(value.toStringAsFixed(2));

  void _syncSLController() {
    slTextController.text = slValue > 0 ? slValue.toStringAsFixed(2) : "";
    slTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: slTextController.text.length),
    );
  }

  void _syncTPController() {
    tpTextController.text = tpValue > 0 ? tpValue.toStringAsFixed(2) : "";
    tpTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: tpTextController.text.length),
    );
  }

  void _syncEntryPriceController() {
    entryPriceController.text = customEntryPrice > 0 ? customEntryPrice.toStringAsFixed(2) : "";
    entryPriceController.selection = TextSelection.fromPosition(
      TextPosition(offset: entryPriceController.text.length),
    );
  }

  void updateSL(double delta) {
    setState(() {
      final ep = entryPrice;
      if (ep <= 0) {
        validationError = "Waiting for live price data...";
        return;
      }

      final step = getStepSize();
      double candidate = slValue + (delta * step);

      if (selectedTradeType == TradeSide.sell && delta < 0) {
        final minAllowed = ep + step;
        if (candidate < minAllowed) {
          candidate = candidate <= 0 ? 0.0 : minAllowed;
        }
      }

      slValue = _clampSL(candidate);
      validationError = null;
    });
    _syncSLController();
  }

  double _clampSL(double candidate) {
    final ep = entryPrice;
    final step = getStepSize();
    if (candidate <= 0 || ep <= 0) return 0.0;

    if (selectedTradeType == TradeSide.buy) {
      final maxAllowed = ep - step;
      if (maxAllowed <= 0) return 0.0;
      if (candidate > maxAllowed) candidate = maxAllowed;
      if (candidate < 0) candidate = 0.0;
      return _normalize(candidate);
    } else {
      final minAllowed = ep + step;
      if (candidate < minAllowed) {
        candidate = minAllowed;
      }
      return _normalize(candidate);
    }
  }

  void updateTP(double delta) {
    setState(() {
      final ep = entryPrice;
      if (ep <= 0) {
        validationError = "Waiting for live price data...";
        return;
      }

      final step = getStepSize();
      double candidate = tpValue + (delta * step);

      if (selectedTradeType == TradeSide.buy && delta < 0) {
        final minAllowed = ep + step;
        if (candidate < minAllowed) {
          candidate = candidate <= 0 ? 0.0 : minAllowed;
        }
      }

      if (selectedTradeType == TradeSide.sell && delta > 0) {
        final maxAllowed = ep - step;
        if (candidate > maxAllowed) candidate = maxAllowed;
      }

      tpValue = _clampTP(candidate);
      validationError = null;
    });
    _syncTPController();
  }

  double _clampTP(double candidate) {
    final ep = entryPrice;
    final step = getStepSize();
    if (ep <= 0 || candidate <= 0) return 0.0;

    if (selectedTradeType == TradeSide.buy) {
      final minAllowed = ep + step;
      if (candidate < minAllowed) candidate = minAllowed;
      return _normalize(candidate);
    } else {
      final maxAllowed = ep - step;
      if (maxAllowed <= 0) return 0.0;
      if (candidate > maxAllowed) candidate = maxAllowed;
      return _normalize(candidate);
    }
  }

  void updateLotSize(double delta) {
    setState(() {
      final step = lotSize < 1 ? 0.01 : (lotSize < 10 ? 0.1 : 1.0);
      final newLot = lotSize + (delta * step);
      if (newLot >= 0.01 && newLot <= 100) {
        lotSize = double.parse(newLot.toStringAsFixed(2));
        controller.lotSize = lotSize;
        controller.loteSizeController.text = lotSize.toStringAsFixed(2);
        lotTextController.text = lotSize.toStringAsFixed(2);
        lotTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: lotTextController.text.length),
        );
      }
      validationError = null;
    });
  }

  void updateEntryPrice(double delta) {
    setState(() {
      final step = getStepSize();
      double candidate = customEntryPrice + (delta * step);
      if (candidate < 0) candidate = 0.0;
      customEntryPrice = _normalize(candidate);
      validationError = null;
    });
    _syncEntryPriceController();
  }

  bool get canIncreaseSL {
    final ep = entryPrice;
    if (ep <= 0) return false;
    final step = getStepSize();
    if (selectedTradeType == TradeSide.buy) {
      final maxAllowed = ep - step;
      return maxAllowed > 0 && slValue < maxAllowed;
    }
    return true;
  }

  bool get canDecreaseSL {
    if (skipSL) return false;
    final ep = entryPrice;
    if (ep <= 0 || slValue <= 0) return false;
    final step = getStepSize();
    if (selectedTradeType == TradeSide.buy) {
      return slValue - step >= 0;
    }
    final next = slValue - step;
    return next > ep || next <= 0;
  }

  bool get canIncreaseTP {
    if (skipTP) return false;
    final ep = entryPrice;
    if (ep <= 0) return false;
    if (selectedTradeType == TradeSide.buy) return true;
    final step = getStepSize();
    final maxAllowed = ep - step;
    if (maxAllowed <= 0) return false;
    if (tpValue == 0.0) return true;
    return tpValue + step < ep;
  }

  bool get canDecreaseTP {
    if (skipTP || tpValue <= 0) return false;
    final ep = entryPrice;
    if (ep <= 0) return false;
    final step = getStepSize();
    if (selectedTradeType == TradeSide.buy) {
      final next = tpValue - step;
      return next > ep || next <= 0;
    } else {
      final next = tpValue - step;
      return next >= 0;
    }
  }

  bool get canIncreaseLot =>
      lotSize + (lotSize < 1 ? 0.01 : (lotSize < 10 ? 0.1 : 1.0)) <= 100;

  bool get canDecreaseLot =>
      lotSize - (lotSize < 1 ? 0.01 : (lotSize < 10 ? 0.1 : 1.0)) >= 0.01;

  bool get canIncreaseEntryPrice => true;

  bool get canDecreaseEntryPrice => customEntryPrice > getStepSize();

  bool _validateInputs() {
    final ep = entryPrice;
    String? error;

    if (ep <= 0) {
      error = "Waiting for live price data...";
    } else if (lotSize <= 0) {
      error = "Lot Size must be greater than 0";
    } else if (lotSize > 100) {
      error = "Lot Size cannot exceed 100 lots";
    } else if (!skipSL && !skipTP && slValue <= 0 && tpValue <= 0) {
      error = "Please set at least Stop Loss or Take Profit";
    } else if (selectedTradeType == TradeSide.buy) {
      if (!skipSL && slValue > 0 && slValue >= ep) {
        error = "For BUY: Stop Loss must be less than Entry Price";
      } else if (!skipTP && tpValue > 0 && tpValue <= ep) {
        error = "For BUY: Take Profit must be greater than Entry Price";
      }
    } else {
      if (!skipSL && slValue > 0 && slValue <= ep) {
        error = "For SELL: Stop Loss must be greater than Entry Price";
      } else if (!skipTP && tpValue > 0 && tpValue >= ep) {
        error = "For SELL: Take Profit must be less than Entry Price";
      }
    }

    setState(() {
      validationError = error;
    });
    return error == null;
  }

  Future<void> applyOrder() async {
    if (isSubmitting) return;
    if (!_validateInputs()) return;

    final ep = entryPrice;
    
    setState(() {
      isSubmitting = true;
    });

    try {
      // ALWAYS create pending order for limit orders - never execute immediately
      // The order will wait until the chart price reaches the EP value
      await controller.createPendingOrder(
        side: selectedTradeType,
        lots: lotSize,
        entryPrice: ep,
        stopLoss: skipSL ? 0.0 : (slValue > 0 ? slValue : 0.0),
        takeProfit: skipTP ? 0.0 : (tpValue > 0 ? tpValue : 0.0),
      );
      Get.back();
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _handleLotChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        lotSize = 0.0;
      });
      return;
    }
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    setState(() {
      lotSize = parsed;
    });
  }

  void _commitLotInput() {
    double clamped = lotSize.clamp(0.0, 100.0);
    if (clamped > 0 && clamped < 0.01) clamped = 0.01;
    setState(() {
      lotSize = double.parse(clamped.toStringAsFixed(2));
      controller.lotSize = lotSize;
      controller.loteSizeController.text =
          lotSize > 0 ? lotSize.toStringAsFixed(2) : "";
    });
    lotTextController.text = lotSize > 0 ? lotSize.toStringAsFixed(2) : "";
    lotTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: lotTextController.text.length),
    );
  }

  void _handleSLChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        slValue = 0.0;
      });
      return;
    }
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    setState(() {
      slValue = parsed;
    });
  }

  void _commitSLInput() {
    final clamped = _clampSL(slValue);
    setState(() {
      slValue = clamped;
    });
    _syncSLController();
  }

  void _handleTPChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        tpValue = 0.0;
      });
      return;
    }
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    setState(() {
      tpValue = parsed;
    });
  }

  void _commitTPInput() {
    final clamped = _clampTP(tpValue);
    setState(() {
      tpValue = clamped;
    });
    _syncTPController();
  }

  void _handleEntryPriceChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        customEntryPrice = 0.0;
      });
      return;
    }
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    setState(() {
      customEntryPrice = parsed;
    });
  }

  void _commitEntryPriceInput() {
    if (customEntryPrice < 0) customEntryPrice = 0.0;
    setState(() {
      customEntryPrice = _normalize(customEntryPrice);
    });
    _syncEntryPriceController();
  }

  Widget _buildCounter({
    required String label,
    required double value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required bool canIncrement,
    required bool canDecrement,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    bool enabled = true,
    Color? valueColor,
    String? helperText,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: enabled
            ? colorConstants.fieldColor
            : colorConstants.fieldColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: enabled
              ? colorConstants.fieldBorderColor
              : colorConstants.fieldBorderColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(
                label,
                size: 14.sp,
                fw: FontWeight.w500,
                color: enabled
                    ? colorConstants.blackColor
                    : colorConstants.hintTextColor,
              ),
              if (helperText != null) ...[
                SizedBox(width: 8.w),
                CustomText(
                  helperText,
                  size: 12.sp,
                  color: colorConstants.hintTextColor,
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                enabled: enabled && canDecrement,
                onPressed: onDecrement,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: controller != null
                    ? TextField(
                        controller: controller,
                        enabled: enabled,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,5}'),
                          ),
                        ],
                        onChanged: onChanged,
                        onEditingComplete: onEditingComplete,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: valueColor ??
                              (enabled
                                  ? colorConstants.blackColor
                                  : colorConstants.hintTextColor),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Center(
                        child: CustomText(
                          value > 0 ? value.toStringAsFixed(2) : "0.00",
                          size: 18.sp,
                          fw: FontWeight.w700,
                          color: valueColor ??
                              (enabled
                                  ? colorConstants.blackColor
                                  : colorConstants.hintTextColor),
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              _buildStepButton(
                icon: Icons.add,
                enabled: enabled && canIncrement,
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: enabled
              ? colorConstants.secondaryColor.withOpacity(0.2)
              : colorConstants.fieldBorderColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color:
              enabled ? colorConstants.secondaryColor : colorConstants.hintTextColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPrice = entryPrice > 0;
    return Scaffold(
      backgroundColor: colorConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorConstants.blackColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: CustomText(
          "SL/TP Order",
          size: 20.sp,
          fw: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.h),
              
              // Market and Limit buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedOrderType != "Market") {
                          Get.off(() => const SLTPOrderScreen());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedOrderType == "Market"
                            ? colorConstants.secondaryColor
                            : colorConstants.fieldColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(
                            color: selectedOrderType == "Market"
                                ? colorConstants.secondaryColor
                                : colorConstants.fieldBorderColor,
                          ),
                        ),
                      ),
                      child: CustomText(
                        "Market",
                        size: 16.sp,
                        fw: FontWeight.w600,
                        color: selectedOrderType == "Market"
                            ? colorConstants.whiteColor
                            : colorConstants.blackColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedOrderType = "Limit";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedOrderType == "Limit"
                            ? colorConstants.secondaryColor
                            : colorConstants.fieldColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(
                            color: selectedOrderType == "Limit"
                                ? colorConstants.secondaryColor
                                : colorConstants.fieldBorderColor,
                          ),
                        ),
                      ),
                      child: CustomText(
                        "Limit",
                        size: 16.sp,
                        fw: FontWeight.w600,
                        color: selectedOrderType == "Limit"
                            ? colorConstants.whiteColor
                            : colorConstants.blackColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Only show the rest of the form if Limit is selected
              if (selectedOrderType == "Limit") ...[
                CustomText(
                  "Trade Type",
                  size: 16.sp,
                  fw: FontWeight.w500,
                  color: colorConstants.blackColor,
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: colorConstants.fieldColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: colorConstants.fieldBorderColor),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: DropdownButton<TradeSide>(
                    value: selectedTradeType,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: TradeSide.buy,
                        child: CustomText(
                          "BUY",
                          size: 16.sp,
                          color: colorConstants.greenColor,
                        ),
                      ),
                      DropdownMenuItem(
                        value: TradeSide.sell,
                        child: CustomText(
                          "SELL",
                          size: 16.sp,
                          color: colorConstants.redColor,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedTradeType = value;
                          slValue = 0.0;
                          tpValue = 0.0;
                          validationError = null;
                          
                          // Update entry price when trade type changes
                          final livePrice = _getLivePrice();
                          if (livePrice > 0) {
                            customEntryPrice = livePrice;
                            entryPriceController.text = livePrice.toStringAsFixed(2);
                          }
                        });
                        _syncSLController();
                        _syncTPController();
                      }
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                _buildCounter(
                  label: "Entry Price (EP)",
                  value: customEntryPrice,
                  onIncrement: () => updateEntryPrice(1),
                  onDecrement: () => updateEntryPrice(-1),
                  canIncrement: canIncreaseEntryPrice,
                  canDecrement: canDecreaseEntryPrice,
                  valueColor: colorConstants.secondaryColor,
                  controller: entryPriceController,
                  onChanged: _handleEntryPriceChanged,
                  onEditingComplete: _commitEntryPriceInput,
                ),
                SizedBox(height: 24.h),
                _buildCounter(
                  label: "Lot Size",
                  value: lotSize,
                  onIncrement: () => updateLotSize(1),
                  onDecrement: () => updateLotSize(-1),
                  canIncrement: canIncreaseLot,
                  canDecrement: canDecreaseLot,
                  controller: lotTextController,
                  onChanged: _handleLotChanged,
                  onEditingComplete: _commitLotInput,
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  final ep = entryPrice;
                  final helperText = selectedTradeType == TradeSide.buy
                      ? "(Must be < ${ep > 0 ? ep.toStringAsFixed(2) : 'EP'})"
                      : "(Must be > ${ep > 0 ? ep.toStringAsFixed(2) : 'EP'})";
                  return _buildCounter(
                    label: "Stop Loss (SL)",
                    value: slValue,
                    onIncrement: () => updateSL(1),
                    onDecrement: () => updateSL(-1),
                    canIncrement: !skipSL && canIncreaseSL,
                    canDecrement: !skipSL && canDecreaseSL,
                    enabled: hasPrice && !skipSL,
                    valueColor: colorConstants.redColor,
                    helperText: helperText,
                    controller: slTextController,
                    onChanged: _handleSLChanged,
                    onEditingComplete: _commitSLInput,
                  );
                }),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Checkbox(
                      value: skipSL,
                      activeColor: colorConstants.redColor,
                      onChanged: (val) {
                        setState(() {
                          skipSL = val ?? false;
                          if (skipSL) {
                            slValue = 0.0;
                            slTextController.text = "";
                          }
                        });
                      },
                    ),
                    CustomText(
                      "Skip SL",
                      size: 14.sp,
                      color: colorConstants.blackColor,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  final ep = entryPrice;
                  final helperText = selectedTradeType == TradeSide.buy
                      ? "(Must be > ${ep > 0 ? ep.toStringAsFixed(2) : 'EP'})"
                      : "(Must be < ${ep > 0 ? ep.toStringAsFixed(2) : 'EP'})";
                  return _buildCounter(
                    label: "Take Profit (TP)",
                    value: tpValue,
                    onIncrement: () => updateTP(1),
                    onDecrement: () => updateTP(-1),
                    canIncrement: !skipTP && canIncreaseTP,
                    canDecrement: !skipTP && canDecreaseTP,
                    enabled: hasPrice && !skipTP,
                    valueColor: colorConstants.greenColor,
                    helperText: helperText,
                    controller: tpTextController,
                    onChanged: _handleTPChanged,
                    onEditingComplete: _commitTPInput,
                  );
                }),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Checkbox(
                      value: skipTP,
                      activeColor: colorConstants.redColor,
                      onChanged: (val) {
                        setState(() {
                          skipTP = val ?? false;
                          if (skipTP) {
                            tpValue = 0.0;
                            tpTextController.text = "";
                          }
                        });
                      },
                    ),
                    CustomText(
                      "Skip TP",
                      size: 14.sp,
                      color: colorConstants.blackColor,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(height: 24.h),
                if (validationError != null)
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: colorConstants.pinkColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CustomText(
                      validationError!,
                      size: 14.sp,
                      color: colorConstants.redColor,
                    ),
                  ),
                if (validationError != null) SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: isSubmitting ? null : applyOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorConstants.secondaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: CustomText(
                    isSubmitting ? "Placing..." : "Place Order",
                    size: 16.sp,
                    fw: FontWeight.w600,
                    color: colorConstants.whiteColor,
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}