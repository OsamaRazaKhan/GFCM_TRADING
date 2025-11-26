import 'package:intl/intl.dart';

enum TradeSide { buy, sell }

class Position {
  final String tradeid;
  final int userid;
  final TradeSide side;
  final double lots;
  final double entryPrice;
  final double contractSize;
  final double marginUsed;
  final DateTime openedAt;
  final String? symbol;
  double? stopLoss;
  double? takeProfit;
  String? status; // "pending" for limit orders, "executed" or null for active trades
  double? priceAtCreation; // For pending orders: price when order was created
  // client-only flag, not sent to server
  @pragma('vm:entry-point')
  bool isSynced;

  Position({
    required this.tradeid,
    required this.userid,
    required this.side,
    required this.lots,
    required this.entryPrice,
    required this.contractSize,
    required this.marginUsed,
    required this.openedAt,
    this.symbol,
    this.stopLoss,
    this.takeProfit,
    this.status,
    this.priceAtCreation,
    this.isSynced = false,
  });

  /// Convert JSON -> Position
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      tradeid: json["tradeid"]?.toString() ?? json["orderId"]?.toString() ?? "",
      userid:
          json["userid"] is String
              ? int.tryParse(json["userid"]) ?? 0
              : json["userid"] ?? 0,
      side:
          (json["side"].toString().toLowerCase() == "buy")
              ? TradeSide.buy
              : TradeSide.sell,
      lots: (json["lots"] as num).toDouble(),
      entryPrice: (json["entryPrice"] as num).toDouble(),
      contractSize: (json["contractSize"] as num).toDouble(),
      marginUsed: (json["marginUsed"] as num).toDouble(),
      openedAt: json["openedAt"] != null
          ? (json["openedAt"] is String
              ? DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["openedAt"])
              : DateTime.parse(json["openedAt"].toString()))
          : (json["createdAt"] != null
              ? (json["createdAt"] is String
                  ? DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["createdAt"])
                  : DateTime.parse(json["createdAt"].toString()))
              : DateTime.now()),
      symbol: json["symbol"],
      stopLoss:
          json["stopLoss"] != null
              ? (json["stopLoss"] is num
                  ? (json["stopLoss"] as num).toDouble()
                  : double.tryParse(json["stopLoss"].toString()))
              : null,
      takeProfit:
          json["takeProfit"] != null
              ? (json["takeProfit"] is num
                  ? (json["takeProfit"] as num).toDouble()
                  : double.tryParse(json["takeProfit"].toString()))
              : null,
      status: json["status"]?.toString(),
      priceAtCreation: json["priceAtCreation"] != null
          ? (json["priceAtCreation"] is num
              ? (json["priceAtCreation"] as num).toDouble()
              : double.tryParse(json["priceAtCreation"].toString()))
          : null,
    );
  }

  /// Convert Position -> JSON
  Map<String, dynamic> toJson() {
    return {
      "tradeid": tradeid,
      "userid": userid,
      "side": side == TradeSide.buy ? "buy" : "sell",
      "lots": lots,
      "entryPrice": entryPrice,
      "contractSize": contractSize,
      "marginUsed": marginUsed,
      "openedAt": DateFormat("yyyy-MM-dd HH:mm:ss").format(openedAt),
      "symbol": symbol,
      "stopLoss": stopLoss,
      "takeProfit": takeProfit,
      if (status != null) "status": status,
      if (priceAtCreation != null) "priceAtCreation": priceAtCreation,
    };
  }
}
