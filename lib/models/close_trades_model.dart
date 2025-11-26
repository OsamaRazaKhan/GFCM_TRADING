// To parse this JSON data, do
//
//     final closeTradesModel = closeTradesModelFromJson(jsonString);

class CloseTradesModel {
  final String tradeid;
  final int userid;
  final String symbol;
  final double lots;
  final String side;
  final double startPrice;
  final double currentPrice;
  final String dateTime;
  final double profitLose;
  double? stopLoss;
  double? takeProfit;

  CloseTradesModel({
    required this.tradeid,
    required this.userid,
    required this.symbol,
    required this.lots,
    required this.side,
    required this.startPrice,
    required this.currentPrice,
    required this.dateTime,
    required this.profitLose,
    this.stopLoss,
    this.takeProfit,
  });

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory CloseTradesModel.fromJson(Map<String, dynamic> json) {
    return CloseTradesModel(
      tradeid: json["tradeid"].toString(),
      userid: int.tryParse(json['userid']?.toString() ?? '') ?? 0,
      symbol: json['symbol']?.toString() ?? '',
      lots: _parseDouble(json['lots']),
      side: json['side']?.toString() ?? '',
      startPrice: _parseDouble(json['startPrice']),
      currentPrice: _parseDouble(json['currentPrice']),
      dateTime: json['dateTime']?.toString() ?? '',
      profitLose: _parseDouble(json['profitLose']),
      stopLoss:
          json["stopLoss"] != null
              ? (json["stopLoss"] is num
                  ? (json["stopLoss"] as num).toDouble()
                  : double.tryParse(json["stopLoss"].toString()))
              : 0.0,
      takeProfit:
          json["takeProfit"] != null
              ? (json["takeProfit"] is num
                  ? (json["takeProfit"] as num).toDouble()
                  : double.tryParse(json["takeProfit"].toString()))
              : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    "tradeid": tradeid,
    "userid": userid,
    "symbol": symbol,
    "lots": lots,
    "side": side,
    "startPrice": startPrice,
    "currentPrice": currentPrice,
    "dateTime": dateTime,
    "profitLose": profitLose,
    "stopLoss": stopLoss,
    "takeProfit": takeProfit,
  };
}
