import 'package:intl/intl.dart';
import 'package:gfcm_trading/models/position_model.dart';

class PendingOrder {
  final String orderId;
  final int userid;
  final TradeSide side;
  final double lots;
  final double entryPrice; // EP - Entry Price
  final double stopLoss; // SL
  final double takeProfit; // TP
  final DateTime createdAt;
  final String? symbol;
  final double contractSize;
  final double marginUsed;
  final double priceAtCreation; // Price when order was created (to determine direction)
  bool isExecuted;
  DateTime? executedAt;
  bool hasPriceCrossedEntry; // Track if price has crossed entry price (prevents immediate execution)

  PendingOrder({
    required this.orderId,
    required this.userid,
    required this.side,
    required this.lots,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.createdAt,
    this.symbol,
    required this.contractSize,
    required this.marginUsed,
    required this.priceAtCreation,
    this.isExecuted = false,
    this.executedAt,
    this.hasPriceCrossedEntry = false,
  });

  /// Convert PendingOrder -> JSON
  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "userid": userid,
      "side": side == TradeSide.buy ? "buy" : "sell",
      "lots": lots,
      "entryPrice": entryPrice,
      "stopLoss": stopLoss,
      "takeProfit": takeProfit,
      "createdAt": DateFormat("yyyy-MM-dd HH:mm:ss").format(createdAt),
      "symbol": symbol,
      "contractSize": contractSize,
      "marginUsed": marginUsed,
      "priceAtCreation": priceAtCreation,
      "isExecuted": isExecuted,
      "executedAt": executedAt != null
          ? DateFormat("yyyy-MM-dd HH:mm:ss").format(executedAt!)
          : null,
      "hasPriceCrossedEntry": hasPriceCrossedEntry,
    };
  }

  /// Convert JSON -> PendingOrder
  factory PendingOrder.fromJson(Map<String, dynamic> json) {
    // Handle both orderId (from PendingOrder) and tradeid (from Position/API)
    final orderId = json["orderId"]?.toString() ?? json["tradeid"]?.toString() ?? "";
    
    // Handle both createdAt (from PendingOrder) and openedAt (from Position/API)
    DateTime createdAt;
    if (json["createdAt"] != null) {
      createdAt = json["createdAt"] is String
          ? DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["createdAt"])
          : DateTime.parse(json["createdAt"].toString());
    } else if (json["openedAt"] != null) {
      createdAt = json["openedAt"] is String
          ? DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["openedAt"])
          : DateTime.parse(json["openedAt"].toString());
    } else {
      createdAt = DateTime.now();
    }
    
    return PendingOrder(
      orderId: orderId,
      userid: json["userid"] is String
          ? int.tryParse(json["userid"]) ?? 0
          : json["userid"] ?? 0,
      side: (json["side"].toString().toLowerCase() == "buy")
          ? TradeSide.buy
          : TradeSide.sell,
      lots: (json["lots"] as num).toDouble(),
      entryPrice: (json["entryPrice"] as num).toDouble(),
      stopLoss: json["stopLoss"] != null
          ? (json["stopLoss"] is num
              ? (json["stopLoss"] as num).toDouble()
              : double.tryParse(json["stopLoss"].toString()) ?? 0.0)
          : 0.0,
      takeProfit: json["takeProfit"] != null
          ? (json["takeProfit"] is num
              ? (json["takeProfit"] as num).toDouble()
              : double.tryParse(json["takeProfit"].toString()) ?? 0.0)
          : 0.0,
      createdAt: createdAt,
      symbol: json["symbol"],
      contractSize: (json["contractSize"] as num).toDouble(),
      marginUsed: (json["marginUsed"] as num).toDouble(),
      priceAtCreation: (json["priceAtCreation"] as num?)?.toDouble() ?? 0.0,
      isExecuted: json["isExecuted"] ?? (json["status"]?.toString().toLowerCase() == "executed") ?? false,
      executedAt: json["executedAt"] != null
          ? (json["executedAt"] is String
              ? DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["executedAt"])
              : DateTime.parse(json["executedAt"].toString()))
          : null,
      hasPriceCrossedEntry: json["hasPriceCrossedEntry"] is bool 
          ? json["hasPriceCrossedEntry"] as bool
          : (json["hasPriceCrossedEntry"] != null && json["hasPriceCrossedEntry"].toString().toLowerCase() == "true") ? true : false,
    );
  }
}

