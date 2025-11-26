import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_dropdown_widget.dart';

class TickerSelector extends StatelessWidget {
  final void Function(String symbol) onSymbolSelected;
  TickerSelector({super.key, required this.onSymbolSelected});
  TradeChartController tradeChartController = Get.put(TradeChartController());
  @override
  Widget build(BuildContext context) {
    final symbols = ['XAUUSD', 'BTCUSDT', 'ETHUSDT', 'LTCUSDT', 'XRPUSDT'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: symbols.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              onSymbolSelected(symbols[index]);
            },
            child: Obx(() {
              return Card(
                color:
                    tradeChartController.currentSymbol.value == symbols[index]
                        ? colorConstants.blueColor
                        : colorConstants.bottomDarkGrayCol,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text(symbols[index])),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
