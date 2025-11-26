import 'package:gfcm_trading/models/position_model.dart';

class CalculatePl {
  static double epsilon = 0.0001;

  static double calculatePL(Position p, double price, double contractSize) {
    double pl =
        (p.side == TradeSide.buy)
            ? (price - p.entryPrice) * p.lots * contractSize
            : (p.entryPrice - price) * p.lots * contractSize;

    // Round tiny numbers to 0
    if (pl.abs() < epsilon) pl = 0.0;

    return pl;
  }
}
