import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/nav_controller.dart';
import 'package:gfcm_trading/controllers/settings_controller.dart';
import 'package:gfcm_trading/models/close_trades_model.dart';
import 'package:gfcm_trading/models/position_model.dart';
import 'package:gfcm_trading/models/pending_order_model.dart';
import 'package:gfcm_trading/services/authentication_service.dart';
import 'package:gfcm_trading/services/dashboard_services.dart';
import 'package:gfcm_trading/services/trading_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

class TradeChartController extends GetxController {
  static final DateFormat formatter = DateFormat('dd/MM/yyyy');
  // ===== Live market values =====
  final RxDouble lastPrice = 0.0.obs; // last traded (mid if missing)
  final RxDouble bidPrice = 0.0.obs; // best bid
  final RxDouble askPrice = 0.0.obs; // best ask
  final RxDouble spread = 0.0.obs; // ask - bid
  final RxString volume = '0'.obs;
  RxString selectedModeIsHedge = "hedgeMode".obs;
  RxString selectedMode = "Real".obs;
  RxDouble stopOutLevelPct = 50.0.obs;
  final RxBool isLiveUpdatesPaused = false.obs;
  final RxDouble credit = 0.0.obs;

  Timer? _syncTimer;
  Timer? _positionsPollTimer; // Timer for polling backend/admin-added trades
  Timer? _fetchDebounceTimer; // Debounce timer for API fetches
  bool _isFetchingPositions = false; // Flag to prevent concurrent fetches
  bool _isFetchingConfirmed =
      false; // Flag to prevent concurrent confirmed fetches

  // Track closed trade IDs to prevent them from being re-added by API refresh
  final Set<String> _closedTradeIds = <String>{};

  late AudioPlayer audioPlayer;

  RxBool isTradeLoader = false.obs;
  RxBool isbalanceLoader = false.obs;

  // ===== App colors / toasts =====
  final ColorConstants colorConstants = ColorConstants();
  Map<String, dynamic>? userData;

  // ===== Account settings =====
  RxDouble balance = 0.0.obs;

  final RxDouble leverage = 1000.0.obs; // e.g. 1000 => 1:1000

  // ===== Contract size (XAUUSD ~ 100 oz/lot) =====
  final double kGoldContractSizePerLot = 100.0;

  // ===== Live plumbing =====
  WebSocketChannel? chartChannel;
  WebSocketChannel? tickerChannel;
  late WebViewController webViewController;

  final RxString currentSymbol = 'XAUUSD'.obs;
  final RxString currentInterval = '1m'.obs;

  // ===== Lot input =====
  double lotSize = 0.00;
  final TextEditingController loteSizeController = TextEditingController();

  // ===== Account metrics =====
  final RxDouble equity = 0.0.obs;
  final RxDouble marginUsed = 0.0.obs; // sum of all positions' margin
  final RxDouble freeMargin = 0.0.obs;
  final RxDouble marginLevelPct = 0.0.obs;
  final RxBool isChartReady = false.obs;
  final RxBool isConnectedToInterNet = false.obs;
  RxDouble floatingMenuTop = 100.0.obs;
  RxDouble floatingMenuRight = 20.0.obs;
  RxBool marketOpen = false.obs;
  RxBool isWebViewInitialized = false.obs;
  bool isLiquidating = false;

  // ===== Positions =====
  final RxList<Position> positions = <Position>[].obs;
  final RxList<CloseTradesModel> closeTradeList = <CloseTradesModel>[].obs;

  // ===== Confirmed trades from API =====
  final RxList<CloseTradesModel> confirmedTrades = <CloseTradesModel>[].obs;
  final RxBool isLoadingConfirmedTrades = false.obs;

  // ===== Pending Orders (SL/TP orders waiting to be executed) =====
  final RxList<PendingOrder> pendingOrders = <PendingOrder>[].obs;

  /*-------------------------------------------------------------*/
  /*                    Check Market closed function             */
  /*-------------------------------------------------------------*/
  void setMarketStatus() {
    final now = DateTime.now().toLocal();
    final weekday = now.weekday;
    final hour = now.hour;

    //Weekend close: Saturday 2:00 AM → Monday 3:00 AM
    if ((weekday == DateTime.saturday && hour >= 2) || // Saturday after 2 AM
        weekday == DateTime.sunday || // Full Sunday
        (weekday == DateTime.monday && hour < 3)) {
      // Monday before 3 AM
      marketOpen.value = false;
    } else {
      //Daily maintenance: 2:00 AM → 2:59 AM (closed)
      if (hour == 2) {
        marketOpen.value = false;
      } else {
        marketOpen.value = true;
      }
    }
  }

  /*-------------------------------------------------------------*/
  /*                      Check internet connection              */
  /*-------------------------------------------------------------*/
  Future<void> checkInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      isConnectedToInterNet.value = true;
      loadChartDataFunction();
    } else {
      setMarketStatus();
      isConnectedToInterNet.value = false;
      loteSizeController.text = lotSize.toStringAsFixed(2);
      SharedPreferences sp = await SharedPreferences.getInstance();
      selectedMode.value = sp.getString("selectedMode") ?? "Real";
      selectedModeIsHedge.value = sp.getString("hedgeOrNetMode") ?? "hedgeMode";
    }
  }

  RxBool isShowSellBuy = true.obs;
  void showHideSellBuy() {
    isShowSellBuy.value = !isShowSellBuy.value;
  }

  Future<void> loadSelectedMode() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final newMode = sp.getString("selectedMode") ?? "Real";

    // If mode changed, clear all data first
    if (selectedMode.value != newMode) {
      // Clear all positions
      positions.clear();

      // Clear pending orders
      pendingOrders.clear();

      // Clear closed trade IDs tracking
      _closedTradeIds.clear();

      // CRITICAL: Clear executing orders set on account switch
      _executingOrderIds.clear();
      _pendingOrderReferencePrices.clear();

      // Clear confirmed trades
      confirmedTrades.clear();

      // Clear close trade list
      closeTradeList.clear();

      // Stop polling temporarily
      _stopPositionsPolling();

      // Reset account metrics
      balance.value = 0.0;
      equity.value = 0.0;
      marginUsed.value = 0.0;
      freeMargin.value = 0.0;
      credit.value = 0.0;
    }

    // Update mode
    selectedMode.value = newMode;

    // Reload data for the new mode
    getYourBalance(isFirstLoad: true);
    getYourTradePositions(); // Fetch only active trades from chart/API
    _recalcAccount(); // initialize UI totals
    // Start polling for backend/admin-added trades
    _startPositionsPolling();
    update();
  }

  void loadChartDataFunction() async {
    setMarketStatus();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            isWebViewInitialized.value = true;
            webViewController.runJavaScript(
              "changeTheme('${Get.find<SettingsController>().isDarkTheme.value ? 'dark' : 'light'}');",
            );
            initializeChart();
            webViewController.runJavaScript("fitChart();");
            // Add zoomToLast after chart is ready
            webViewController.runJavaScript("zoomToLast(50);");
          },
          onWebResourceError: (err) {},
        ),
      )
      ..loadFlutterAsset('assets/chart.html');

    // allow native zoom gestures where applicable (optional)
    webViewController.enableZoom(true);
    Get.find<SettingsController>().webViewController = webViewController;

    loteSizeController.text = lotSize.toStringAsFixed(2);
    SharedPreferences sp = await SharedPreferences.getInstance();
    selectedMode.value = sp.getString("selectedMode") ?? "Real";
    selectedModeIsHedge.value = sp.getString("hedgeOrNetMode") ?? "hedgeMode";
    await refreshChartTradeLines();
    // set balance based on saved mode

    getYourBalance(isFirstLoad: true);
    getYourTradePositions(); // Fetch only active trades from chart/API
    _recalcAccount(); // initialize UI totals
    // Start polling for backend/admin-added trades
    _startPositionsPolling();
  }

  StreamSubscription? _subscription;
  bool firstInit = true;
  @override
  void onInit() async {
    super.onInit();
    firstInit = false;
    update();
    checkInternet();
    _subscription = Connectivity().onConnectivityChanged.listen((resultList) {
      if (resultList.contains(ConnectivityResult.none)) {
        isConnectedToInterNet.value = false;
        update();
        _onDisconnected();
      } else {
        isConnectedToInterNet.value = true;

        if (!isWebViewInitialized.value) {
          loadChartDataFunction();
        }
        Get.put(NavController()).getUserData();
        _onReconnected();
      }
    });

    audioPlayer = AudioPlayer();
  }

  void _onDisconnected() {
    // Stop live WebSocket streams
    try {
      tickerChannel?.sink.close();
      chartChannel?.sink.close();
    } catch (_) {}
    // Stop polling when disconnected
    _stopPositionsPolling();
  }

  Future<void> _onReconnected() async {
    // Pause updates while reconnecting
    isLiveUpdatesPaused.value = true;

    try {
      await Future.delayed(
        const Duration(seconds: 2),
      ); // small delay for DNS to recover

      //  Try reconnect sockets safely
      connectTickerSocket();
      connectLiveChart(currentSymbol.value, currentInterval.value);

      // Refresh balance & positions
      if (firstInit) {
        await getYourBalance();
        await getYourTradePositions();
        await _recalcAccount();
        // Restart polling after reconnection
        _startPositionsPolling();
      }

      try {
        await webViewController.runJavaScript("showReconnectNotice();");
      } catch (_) {}

      // FlushMessages.commonToast(
      //   "Reconnected — Live data resumed",
      //   backGroundColor: Colors.green,
      // );
      firstInit = true;
      update();
    } catch (e) {
    } finally {
      // Resume updates
      isLiveUpdatesPaused.value = false;
    }
  }

  @override
  void onClose() {
    try {
      tickerChannel?.sink.close();
    } catch (_) {}
    try {
      chartChannel?.sink.close();
    } catch (_) {}
    loteSizeController.dispose();
    _syncTimer?.cancel();
    _positionsPollTimer?.cancel(); // Cancel positions polling timer
    _fetchDebounceTimer?.cancel(); // Cancel debounce timer
    _pendingOrdersMonitorTimer?.cancel(); // Cancel pending orders monitor
    _subscription?.cancel();
    super.onClose();
  }

  /*-----------------------------------------------*/
  /*                  Lot handling                 */
  /*-----------------------------------------------*/
  void increaseValue() {
    final step = getStepSize();
    final newLotSize = lotSize + step;
    if (newLotSize <= 100) {
      lotSize = double.parse(newLotSize.toStringAsFixed(2));
      syncTextField();
      update();
    }
  }

  void decreaseValue() {
    final step = getStepSize();
    if (lotSize - step >= 0.01) {
      lotSize = double.parse((lotSize - step).toStringAsFixed(2));
      syncTextField();
      update();
    }
  }

  double getStepSize() {
    if (lotSize < 1) return 0.01;
    if (lotSize < 10) return 0.1;
    return 1.0;
  }

  void setValueFromInput(String input, {bool format = false}) {
    final parsed = double.tryParse(input);
    if (parsed != null && parsed >= 0.01 && parsed <= 100) {
      lotSize = format ? double.parse(parsed.toStringAsFixed(2)) : parsed;
      if (format) {
        syncTextField();
        update();
      }
    } else if (parsed != null && (parsed < 0.01 || parsed > 100)) {
      // Clamp to valid range
      lotSize = parsed < 0.01 ? 0.01 : (parsed > 100 ? 100.0 : parsed);
      if (format) {
        syncTextField();
        update();
      }
    }
  }

  void syncTextField() {
    loteSizeController.text = lotSize.toStringAsFixed(2);
  }

  /*------------------------------------------------------------------*/
  /*                    stop loss and Take profit                     */
  /*------------------------------------------------------------------*/

  // --- Reactive SL/TP values ---
  final stopLossController = TextEditingController();
  final takeProfitController = TextEditingController();

  // --- Step size (change according to symbol) ---
  final double priceStep = 0.10; // e.g. 0.10 USD per tick

  void updateSLTPValue(double sL, double tP) {
    if (sL <= 0.0 && tP > 0.0) {
      stopLossController.clear();
      takeProfitController.text = tP.toStringAsFixed(2);
    } else if (tP <= 0.0 && sL > 0.0) {
      takeProfitController.clear();
      stopLossController.text = sL.toStringAsFixed(2);
    } else if (sL <= 0.0 && tP <= 0.0) {
      stopLossController.clear();
      takeProfitController.clear();
    } else {
      takeProfitController.text = tP.toStringAsFixed(2);
      stopLossController.text = sL.toStringAsFixed(2);
    }
  }

  // --- SL Methods ---
  void increaseSL(double entryPrice) {
    if (stopLossController.text.isEmpty ||
        stopLossController.text == "0" ||
        stopLossController.text == "0.0") {
      stopLossController.text = entryPrice.toStringAsFixed(2);
      final value = double.tryParse(stopLossController.text) ?? 0.0;
      stopLossController.text = (value + priceStep).toStringAsFixed(2);
    } else {
      final value = double.tryParse(stopLossController.text) ?? 0.0;
      stopLossController.text = (value + priceStep).toStringAsFixed(2);
    }
  }

  void decreaseSL(double entryPrice) {
    if (stopLossController.text.isEmpty ||
        stopLossController.text == "0" ||
        stopLossController.text == "0.0") {
      stopLossController.text = entryPrice.toStringAsFixed(2);
      final value = double.tryParse(stopLossController.text) ?? 0.0;
      stopLossController.text = ((value - priceStep).clamp(
        0.0,
        double.infinity,
      )).toStringAsFixed(2);
    } else {
      final value = double.tryParse(stopLossController.text) ?? 0.0;
      stopLossController.text = ((value - priceStep).clamp(
        0.0,
        double.infinity,
      )).toStringAsFixed(2);
    }
  }

  // --- TP Methods ---
  void increaseTP(double entryPrice) {
    if (takeProfitController.text.isEmpty ||
        takeProfitController.text == "0" ||
        takeProfitController.text == "0.0") {
      takeProfitController.text = entryPrice.toStringAsFixed(2);
      final value = double.tryParse(takeProfitController.text) ?? 0.0;
      takeProfitController.text = (value + priceStep).toStringAsFixed(2);
    } else {
      final value = double.tryParse(takeProfitController.text) ?? 0.0;
      takeProfitController.text = (value + priceStep).toStringAsFixed(2);
    }
  }

  void decreaseTP(double entryPrice) {
    if (takeProfitController.text.isEmpty ||
        takeProfitController.text == "0" ||
        takeProfitController.text == "0.0") {
      takeProfitController.text = entryPrice.toStringAsFixed(2);
      final value = double.tryParse(takeProfitController.text) ?? 0.0;
      takeProfitController.text = ((value - priceStep).clamp(
        0.0,
        double.infinity,
      )).toStringAsFixed(2);
    } else {
      final value = double.tryParse(takeProfitController.text) ?? 0.0;
      takeProfitController.text = ((value - priceStep).clamp(
        0.0,
        double.infinity,
      )).toStringAsFixed(2);
    }
  }

  /*-----------------------------------------------*/
  /*     Open Trade with SL/TP (Market Order)     */
  /*-----------------------------------------------*/
  Future<void> openTradeWithSLTP({
    required TradeSide side,
    required double lots,
    required double stopLoss,
    required double takeProfit,
  }) async {
    if (isLiquidating) return;

    if (!isConnectedToInterNet.value) {
      FlushMessages.commonToast(
        "Please check your internet connection",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    if (lots <= 0 || lots > 100) {
      FlushMessages.commonToast(
        "Lot size must be between 0.01 and 100",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    if (bidPrice.value <= 0 || askPrice.value <= 0) {
      FlushMessages.commonToast(
        "Waiting for live bid/ask...",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    final entry = (side == TradeSide.buy) ? askPrice.value : bidPrice.value;
    final priceForMargin = _midOrLast();
    final req = _marginRequired(lots: lots, price: priceForMargin);

    if (freeMargin.value < req || req <= 0) {
      FlushMessages.commonToast(
        "Not enough margin. Required ${req.toStringAsFixed(2)}, Free ${freeMargin.value.toStringAsFixed(2)}",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    _enqueueTrade(() async {
      final sp = await SharedPreferences.getInstance();
      final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

      final pos = Position(
        tradeid: Uuid().v4(),
        userid: userId,
        side: side,
        lots: lots,
        entryPrice: entry,
        contractSize: kGoldContractSizePerLot,
        marginUsed: req,
        openedAt: DateTime.now(),
        symbol: currentSymbol.value,
        stopLoss: stopLoss > 0 ? stopLoss : null,
        takeProfit: takeProfit > 0 ? takeProfit : null,
      );

      HapticFeedback.heavyImpact();
      positions.add(pos);
      await refreshChartTradeLines();
      await _recalcUsedMargin();
      _recalcAccount();

      FlushMessages.commonToast(
        "Opened ${side == TradeSide.buy ? 'BUY' : 'SELL'} ${lots.toStringAsFixed(2)} @ ${entry.toStringAsFixed(2)}",
        backGroundColor: colorConstants.secondaryColor,
      );

      _scheduleServerSync();
      _fetchDebounceTimer?.cancel();
      _fetchDebounceTimer = Timer(const Duration(milliseconds: 1000), () {
        getYourTradePositions(silent: true);
      });
    });
  }

  /*-----------------------------------------------*/
  /*     Create Pending Order (Limit Order)       */
  /*-----------------------------------------------*/
  Future<void> createPendingOrder({
    required TradeSide side,
    required double lots,
    required double entryPrice,
    required double stopLoss,
    required double takeProfit,
  }) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

      // Calculate margin required
      final priceForMargin = entryPrice;
      final req = _marginRequired(lots: lots, price: priceForMargin);

      if (freeMargin.value < req || req <= 0) {
        FlushMessages.commonToast(
          "Not enough margin. Required ${req.toStringAsFixed(2)}, Free ${freeMargin.value.toStringAsFixed(2)}",
          backGroundColor: colorConstants.dimGrayColor,
        );
        return;
      }

      // Get current market price at creation time
      double priceAtCreation =
          (side == TradeSide.buy) ? askPrice.value : bidPrice.value;
      if (priceAtCreation <= 0) {
        // Fallback to last price, then entry price
        final fallbackPrice = (side == TradeSide.buy)
            ? (lastPrice.value > 0 ? lastPrice.value : entryPrice)
            : (lastPrice.value > 0 ? lastPrice.value : entryPrice);
        priceAtCreation = fallbackPrice;
      }

      // Validate that EP is different from current price (limit orders must wait)
      if ((side == TradeSide.buy &&
              (entryPrice - priceAtCreation).abs() < 0.01) ||
          (side == TradeSide.sell &&
              (entryPrice - priceAtCreation).abs() < 0.01)) {
        FlushMessages.commonToast(
          "Entry price must be different from current market price for limit orders",
          backGroundColor: colorConstants.dimGrayColor,
        );
        return;
      }

      final order = PendingOrder(
        orderId: Uuid().v4(),
        userid: userId,
        side: side,
        lots: lots,
        entryPrice: entryPrice,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
        createdAt: DateTime.now(),
        symbol: currentSymbol.value,
        contractSize: kGoldContractSizePerLot,
        marginUsed: req,
        priceAtCreation: priceAtCreation,
        hasPriceCrossedEntry:
            false, // Always start as false - price must cross entry first
      );

      pendingOrders.add(order);
      // CRITICAL: Clear cache to force rebuild of allTradeItems
      _cachedAllTradeItems = null;
      _pendingOrderReferencePrices[order.orderId] = priceAtCreation;

      // Save pending order to backend immediately
      // await _savePendingOrderToBackend(order);

      // Show appropriate message based on order type
      String orderType = "";
      if (side == TradeSide.buy) {
        if (entryPrice < priceAtCreation) {
          orderType =
              "BUY limit (waiting for price to fall to ${entryPrice.toStringAsFixed(2)})";
        } else {
          orderType =
              "BUY stop-limit (waiting for price to rise to ${entryPrice.toStringAsFixed(2)})";
        }
      } else {
        if (entryPrice > priceAtCreation) {
          orderType =
              "SELL limit (waiting for price to rise to ${entryPrice.toStringAsFixed(2)})";
        } else {
          orderType =
              "SELL stop-limit (waiting for price to fall to ${entryPrice.toStringAsFixed(2)})";
        }
      }

      FlushMessages.commonToast(
        "Limit order placed: $orderType",
        backGroundColor: colorConstants.secondaryColor,
      );

      // Start monitoring prices for this order
      _monitorPendingOrders();

      // Save pending order to backend immediately (Real accounts only)
      if (selectedMode.value == "Real") {
        // await _savePendingOrderToBackend(order);
      }
    } catch (e) {
      debugPrint("Error creating pending order: $e");
      FlushMessages.commonToast(
        "Error creating order",
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*-----------------------------------------------*/
  /*     Monitor Pending Orders for Execution      */
  /*-----------------------------------------------*/
  Timer? _pendingOrdersMonitorTimer;

  double _deriveReferencePrice(PendingOrder order) {
    double reference = order.priceAtCreation;
    if (reference <= 0) {
      reference = _pendingOrderReferencePrices[order.orderId] ?? 0.0;
    }
    if (reference <= 0) {
      final livePrice =
          order.side == TradeSide.buy ? askPrice.value : bidPrice.value;
      if (livePrice > 0) {
        reference = livePrice;
      } else if (lastPrice.value > 0) {
        reference = lastPrice.value;
      } else {
        reference = order.entryPrice;
      }
    }
    _pendingOrderReferencePrices[order.orderId] = reference;
    return reference;
  }

  bool _checkPendingOrderExecution({
    required PendingOrder order,
    required double currentBid,
    required double currentAsk,
  }) {
    final minMovement = (order.entryPrice * 0.001).clamp(0.10, double.infinity);
    final referencePrice = _deriveReferencePrice(order);
    final targetPrice = order.entryPrice;
    final currentPrice = order.side == TradeSide.buy ? currentAsk : currentBid;

    bool expectPriceToFall;
    if (targetPrice == referencePrice) {
      expectPriceToFall = currentPrice > targetPrice;
    } else {
      expectPriceToFall = targetPrice < referencePrice;
    }

    bool movedEnough;
    bool reachedTarget;

    if (expectPriceToFall) {
      movedEnough = (referencePrice - currentPrice) >= minMovement;
      reachedTarget = currentPrice <= targetPrice;
    } else {
      movedEnough = (currentPrice - referencePrice) >= minMovement;
      reachedTarget = currentPrice >= targetPrice;
    }

    if (!order.hasPriceCrossedEntry) {
      if (movedEnough && reachedTarget) {
        order.hasPriceCrossedEntry = true;
        return false; // wait one more cycle
      }
      return false;
    }

    return reachedTarget;
  }

  void _removePendingOrderLocally(PendingOrder order) {
    pendingOrders.remove(order);
    _pendingOrderReferencePrices.remove(order.orderId);
    _cachedAllTradeItems = null;
  }

  Future<void> cancelPendingOrder(PendingOrder order) async {
    order.isExecuted = true;
    try {
      await updatePendingOrderStatus(order.orderId, "cancelled");
    } catch (e) {
      debugPrint("Error cancelling pending order: $e");
    }
    _removePendingOrderLocally(order);
    await updateYourTradePositions();
  }

  void _monitorPendingOrders() {
    // Cancel existing timer if any
    _pendingOrdersMonitorTimer?.cancel();

    // Monitor every 500ms for price hits
    _pendingOrdersMonitorTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!isConnectedToInterNet.value || pendingOrders.isEmpty) {
        return;
      }

      final currentBid = bidPrice.value;
      final currentAsk = askPrice.value;

      if (currentBid <= 0 || currentAsk <= 0) {
        return; // Wait for valid prices
      }

      // Check each pending order
      final ordersToExecute = <PendingOrder>[];

      for (final order in pendingOrders) {
        if (order.isExecuted) continue;

        final shouldExecute = _checkPendingOrderExecution(
          order: order,
          currentBid: currentBid,
          currentAsk: currentAsk,
        );

        if (shouldExecute) {
          ordersToExecute.add(order);
        }
      }

      // Execute orders that hit entry price
      for (final order in ordersToExecute) {
        _executePendingOrder(order);
      }
    });
  }

  /*-----------------------------------------------*/
  /*     Execute Pending Order (Apply Trade)       */
  /*-----------------------------------------------*/
  Future<void> _executePendingOrder(PendingOrder order) async {
    // CRITICAL: Prevent duplicate execution
    if (_executingOrderIds.contains(order.orderId)) {
      debugPrint("Order ${order.orderId} is already being executed, skipping");
      return;
    }

    try {
      // Mark as executing to prevent duplicates
      _executingOrderIds.add(order.orderId);

      // CRITICAL: Mark order as executed FIRST before any other operations
      order.isExecuted = true;
      order.executedAt = DateTime.now();

      // Get actual execution price (current market price when limit is hit)
      final executionPrice =
          (order.side == TradeSide.buy) ? askPrice.value : bidPrice.value;

      if (executionPrice <= 0) {
        debugPrint(
            "Error: Invalid execution price when executing pending order");
        // Revert execution flag
        order.isExecuted = false;
        return;
      }

      // CRITICAL: Remove from pending orders IMMEDIATELY to prevent showing as "Waiting"
      _removePendingOrderLocally(order);

      // Create position from order with actual execution price
      final sp = await SharedPreferences.getInstance();
      final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

      // CRITICAL: Use order.orderId as tradeid to prevent duplicates if API returns same ID
      final pos = Position(
        tradeid: order.orderId, // Use order ID to prevent duplicates
        userid: userId,
        side: order.side,
        lots: order.lots,
        entryPrice:
            executionPrice, // Use actual execution price, not limit price
        contractSize: order.contractSize,
        marginUsed: order.marginUsed,
        openedAt: DateTime.now(),
        symbol: order.symbol,
        stopLoss: order.stopLoss > 0 ? order.stopLoss : null,
        takeProfit: order.takeProfit > 0 ? order.takeProfit : null,
      );

      // CRITICAL: Check if position already exists (prevent duplicate)
      if (!positions.any((p) => p.tradeid == pos.tradeid)) {
        // Add to positions immediately
        positions.add(pos);
        await refreshChartTradeLines();
        await _recalcUsedMargin();
        _recalcAccount();
      } else {
        debugPrint(
            "Position ${pos.tradeid} already exists, skipping duplicate");
      }

      // Update backend: remove pending status and mark as executed (async, don't wait)
      updatePendingOrderStatus(order.orderId, "executed").catchError((e) {
        debugPrint("Error updating pending order status: $e");
      });

      FlushMessages.commonToast(
        "Order executed: ${order.side == TradeSide.buy ? 'BUY' : 'SELL'} ${order.lots.toStringAsFixed(2)} @ ${executionPrice.toStringAsFixed(2)}",
        backGroundColor: colorConstants.secondaryColor,
      );

      // Immediate API sync for consistency
      await updateYourTradePositions(); // Sync positions with server
      await updateYourBalance(); // Update balance/margin on server
      await getYourBalance(); // Fetch fresh balance

      // Schedule server sync for additional updates
      _scheduleServerSync();

      // Debounced refresh
      _fetchDebounceTimer?.cancel();
      _fetchDebounceTimer = Timer(const Duration(milliseconds: 1000), () {
        getYourTradePositions(silent: true);
      });
    } catch (e) {
      debugPrint("Error executing pending order: $e");
      // CRITICAL: Revert execution flag on error
      order.isExecuted = false;
      // Re-add to pending orders if execution failed
      if (!pendingOrders.any((o) => o.orderId == order.orderId)) {
        pendingOrders.add(order);
        if (!_pendingOrderReferencePrices.containsKey(order.orderId)) {
          final fallbackRef = order.priceAtCreation > 0
              ? order.priceAtCreation
              : order.entryPrice;
          _pendingOrderReferencePrices[order.orderId] = fallbackRef;
        }
        _cachedAllTradeItems = null;
      }
    } finally {
      // CRITICAL: Remove from executing set after completion
      _executingOrderIds.remove(order.orderId);
      _pendingOrderReferencePrices.remove(order.orderId);
    }
  }

  /*-----------------------------------------------*/
  /*          stop loss take profit logic          */
  /*-----------------------------------------------*/
  RxBool isSlSet = false.obs;
  RxBool isTPSet = false.obs;

  void setSLTP(String tradeId, {double? sl, double? tp}) async {
    isSlSet = false.obs;
    isTPSet = false.obs;

    final idx = positions.indexWhere((pos) => pos.tradeid == tradeId);
    if (idx == -1) return;

    final pos = positions[idx];
    final currentPrice =
        (pos.side == TradeSide.buy) ? askPrice.value : bidPrice.value;

    // -------------------- STOP LOSS VALIDATION --------------------
    if (sl != null && sl != 0.0) {
      if (pos.side == TradeSide.buy) {
        if (sl >= pos.entryPrice) {
          FlushMessages.commonToast(
            "SL must be lower than entry price for Buy trade",
            backGroundColor: colorConstants.dimGrayColor,
          );
          return;
        }
        if (sl >= currentPrice) {
          FlushMessages.commonToast(
            "SL must be lower than current price for Buy trade",
            backGroundColor: colorConstants.dimGrayColor,
          );
          return;
        }
      } else if (pos.side == TradeSide.sell) {
        if (sl <= pos.entryPrice) {
          FlushMessages.commonToast(
            "SL must be higher than entry price for Sell trade",
            backGroundColor: colorConstants.dimGrayColor,
          );
          return;
        }
        if (sl <= currentPrice) {
          FlushMessages.commonToast(
            "SL must be higher than current price for Sell trade",
            backGroundColor: colorConstants.dimGrayColor,
          );
          return;
        }
      }

      isSlSet.value = true;
      pos.stopLoss = sl;
    } else {
      pos.stopLoss = 0.0;
    }

    // -------------------- TAKE PROFIT VALIDATION --------------------
    if (tp != null && tp != 0.0) {
      if (pos.side == TradeSide.buy) {
        if (tp <= pos.entryPrice) {
          FlushMessages.commonToast(
            "TP must be higher than entry price for Buy trade",
            backGroundColor: colorConstants.dimGrayColor,
          );
          return;
        }
        if (tp <= currentPrice) {
          FlushMessages.commonToast(
            "TP must be higher than current price for Buy trade",
            backGroundColor: colorConstants.dimGrayColor,
          );
          return;
        }
      } else if (pos.side == TradeSide.sell) {
        if (tp >= pos.entryPrice) {
          FlushMessages.commonToast(
            "TP must be lower than entry price for Sell trade",
            backGroundColor: colorConstants.dimGrayColor,
          );
          return;
        }
        if (tp >= currentPrice) {
          FlushMessages.commonToast(
            "TP must be lower than current price for Sell trade",
            backGroundColor: colorConstants.dimGrayColor,
          );
          return;
        }
      }

      isTPSet.value = true;
      pos.takeProfit = tp;
    } else {
      pos.takeProfit = 0.0;
    }

    // -------------------- SUCCESS MESSAGES --------------------
    if (isSlSet.value && isTPSet.value) {
      FlushMessages.commonToast(
        "SL/TP updated successfully",
        backGroundColor: colorConstants.secondaryColor,
      );
      Get.back();
    } else if (isSlSet.value) {
      FlushMessages.commonToast(
        "SL updated successfully",
        backGroundColor: colorConstants.secondaryColor,
      );
      Get.back();
    } else if (isTPSet.value) {
      FlushMessages.commonToast(
        "TP updated successfully",
        backGroundColor: colorConstants.secondaryColor,
      );
      Get.back();
    } else {
      Get.back();
    }

    positions[idx] = pos; // Update in list

    try {
      await updateYourTradePositions();
    } catch (e) {}
  }

  void checkSLTP() {
    // CRITICAL: Only check if we have valid prices and positions
    if (bidPrice.value <= 0 || askPrice.value <= 0 || positions.isEmpty) {
      return;
    }

    // CRITICAL: Only check active positions, never pending orders
    for (var p in positions.toList()) {
      // Skip if this trade was already triggered (prevents double-closing)
      if (_triggeredTrades.contains(p.tradeid)) {
        continue;
      }

      final exitPrice =
          (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;

      // CRITICAL: Validate exit price is valid
      if (exitPrice <= 0) {
        continue;
      }

      // Check for auto-close on excessive loss (only if margin is valid)
      if (p.marginUsed > 0) {
        final pl = _positionPL(p);
        final marginLimit = -(p.marginUsed);
        // CRITICAL: Only auto-close if loss is significantly beyond margin (with small buffer to prevent false triggers)
        final shouldAutoClose =
            pl < marginLimit * 1.01; // 1% buffer to prevent false triggers

        if (shouldAutoClose) {
          _triggeredTrades.add(p.tradeid);
          _triggerClose(p);
          continue;
        }
      }

      // CRITICAL: TP/SL checks with proper price comparison
      // BUY: SL triggers when price FALLS to/below SL, TP triggers when price RISES to/above TP
      // SELL: SL triggers when price RISES to/above SL, TP triggers when price FALLS to/below TP
      bool hitSL = false;
      bool hitTP = false;

      if (p.stopLoss != null && p.stopLoss! > 0.0) {
        if (p.side == TradeSide.buy) {
          // BUY: SL triggers when price falls to or below stop loss
          hitSL = exitPrice <= p.stopLoss!;
        } else {
          // SELL: SL triggers when price rises to or above stop loss
          hitSL = exitPrice >= p.stopLoss!;
        }
      }

      if (p.takeProfit != null && p.takeProfit! > 0.0) {
        if (p.side == TradeSide.buy) {
          // BUY: TP triggers when price rises to or above take profit
          hitTP = exitPrice >= p.takeProfit!;
        } else {
          // SELL: TP triggers when price falls to or below take profit
          hitTP = exitPrice <= p.takeProfit!;
        }
      }

      // CRITICAL: Only trigger close if TP or SL is actually hit
      if (hitSL || hitTP) {
        // Mark as triggered to prevent re-triggering
        _triggeredTrades.add(p.tradeid);
        // Reset the opposite so it doesn't re-trigger
        if (hitSL) p.takeProfit = 0.0;
        if (hitTP) p.stopLoss = 0.0;
        _triggerClose(p);
      }
    }
  }

  void _triggerClose(Position p) {
    // CRITICAL: Only close if trade still exists (not already closed)
    if (positions.any((pos) => pos.tradeid == p.tradeid)) {
      closePosition(p.tradeid, isShowDilog: false);
    }
  }

  /*-----------------------------------------------*/
  /*               Symbol mapping                  */
  /*-----------------------------------------------*/
  String getBinanceSymbol(String uiSymbol) {
    if (uiSymbol.toUpperCase() == 'XAUUSD') return 'PAXGUSDT';
    return uiSymbol.toUpperCase();
  }

  /*-----------------------------------------------*/
  /*                Core math helpers              */
  /*-----------------------------------------------*/
  // Correct margin: price * contractSize * lots / leverage
  double _marginRequired({required double lots, required double price}) {
    if (price <= 0 || lots <= 0) return 0;
    final lev = leverage.value <= 0 ? 1 : leverage.value;
    return price * lots * kGoldContractSizePerLot / lev;
  }

  // Unrealized P&L uses *exit* prices:
  // - long closes at bid
  // - short closes at ask
  double _positionPL(Position p) {
    if (bidPrice.value <= 0 || askPrice.value <= 0) return 0;
    final exitPrice =
        (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;
    final diff = (p.side == TradeSide.buy)
        ? (exitPrice - p.entryPrice)
        : (p.entryPrice - exitPrice);
    return diff * p.lots * p.contractSize;
  }

  double get totalUnrealizedPL {
    // CRITICAL: Only calculate P/L for executed positions
    // Pending orders have NO P/L until they execute
    double sum = 0;
    for (final p in positions) {
      // Only calculate P/L for actual positions (not pending orders)
      sum += _positionPL(p);
    }
    // Pending orders have zero P/L - they're waiting, not executed
    return sum;
  }

  double _midOrLast() {
    if (bidPrice.value > 0 && askPrice.value > 0) {
      return (bidPrice.value + askPrice.value) / 2.0;
    }
    return lastPrice.value;
  }

  /*-----------------------------------------------*/
  /*           Eligibility & open trade            */
  /*-----------------------------------------------*/

  // ---------------- Queue System ----------------
  final List<Future Function()> _tradeQueue = [];
  bool _isProcessingTradeQueue = false;
  final Set<String> _closingTrades = {}; // prevent duplicate closes
  final Set<String> _triggeredTrades =
      {}; // track trades that have triggered TP/SL to prevent re-triggering
  final Set<String> _executingOrderIds =
      {}; // track orders currently being executed to prevent duplicates
  final Map<String, double> _pendingOrderReferencePrices =
      {}; // fallback reference price when backend data is missing
  //  Add trade operation to queue (for background sync, not blocking)

  void _enqueueTrade(Future Function() op, {bool isCloseTrade = false}) {
    _tradeQueue.add(op);
    _processTradeQueue(isCloseTrade: isCloseTrade);
  }

  Future<void> _processTradeQueue({bool isCloseTrade = false}) async {
    if (_isProcessingTradeQueue) return;
    _isProcessingTradeQueue = true;

    while (_tradeQueue.isNotEmpty) {
      final op = _tradeQueue.removeAt(0);
      try {
        await op();
        await _recalcUsedMargin(); // always recalc locally

        //No direct server calls here — handled by _scheduleServerSync()
        if (isCloseTrade) {
          if (positions.isEmpty && (equity.value < 0 || balance.value < 0)) {
            balance.value = 0.0;
          }
          // Save closed trade to history (not shown on trade page)
          await saveCompletedTradesForHistory();
          // Update server and refresh active/running trades
          await updateYourTradePositions();
          await updateYourBalance();
          await getYourBalance();
          // Refresh active/running trades - closed trades already removed from positions
          // Debounce to prevent rapid updates
          _fetchDebounceTimer?.cancel();
          _fetchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
            getYourTradePositions(
                silent: true); // Only refresh active trades API
          });
          _recalcAccount();
        }
      } catch (e) {}
    }
    _isProcessingTradeQueue = false;
  }

  // ---------------- Open Trade ----------------

  Future<void> openTrade(TradeSide side) async {
    if (isLiquidating) return;

    //  Validate *before* adding to queue
    if (!isConnectedToInterNet.value) {
      FlushMessages.commonToast(
        "Please check your internet connection",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    if (lotSize <= 0 || lotSize > 100) {
      FlushMessages.commonToast(
        "Lot size must be between 0.01 and 100",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    if (bidPrice.value <= 0 || askPrice.value <= 0) {
      FlushMessages.commonToast(
        "Waiting for live bid/ask...",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    final priceForMargin = _midOrLast();
    final req = _marginRequired(lots: lotSize, price: priceForMargin);

    if (freeMargin.value < req || req <= 0) {
      FlushMessages.commonToast(
        "Not enough margin. Required ${req.toStringAsFixed(2)}, Free ${freeMargin.value.toStringAsFixed(2)}",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    //  Passed all validation → now enqueue the trade
    _enqueueTrade(() async {
      final sp = await SharedPreferences.getInstance();
      final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

      final entry = (side == TradeSide.buy) ? askPrice.value : bidPrice.value;

      final pos = Position(
        tradeid: Uuid().v4(),
        userid: userId,
        side: side,
        lots: lotSize,
        entryPrice: entry,
        contractSize: kGoldContractSizePerLot,
        marginUsed: req,
        openedAt: DateTime.now(),
        symbol: currentSymbol.value,
      );

      HapticFeedback.heavyImpact();
      // Add to positions immediately for instant UI update
      positions.add(pos);
      await refreshChartTradeLines();
      // Immediately update account metrics
      await _recalcUsedMargin();
      _recalcAccount();

      FlushMessages.commonToast(
        "Opened ${side == TradeSide.buy ? 'BUY' : 'SELL'} ${lotSize.toStringAsFixed(2)} @ ${entry.toStringAsFixed(2)}",
        backGroundColor: colorConstants.secondaryColor,
      );
      // Schedule server sync after last click
      _scheduleServerSync();
      // Debounced refresh after opening to sync with backend (prevents flickering)
      _fetchDebounceTimer?.cancel();
      _fetchDebounceTimer = Timer(const Duration(milliseconds: 1000), () {
        getYourTradePositions(silent: true); // Only refresh active trades API
      });
    });
  }

  void _scheduleServerSync() {
    _syncTimer?.cancel(); // cancel previous timer if still counting
    _syncTimer = Timer(const Duration(seconds: 3), () async {
      try {
        await updateYourTradePositions(); // send all current positions
        await updateYourBalance();
        await getYourBalance();
      } catch (e) {}
    });
  }

  Future<void> refreshChartTradeLines() async {
    if (!isWebViewInitialized.value) return;

    final trades = positions
        .map((p) => {
              'tradeid': p.tradeid,
              'side': p.side == TradeSide.buy ? 'buy' : 'sell',
              'entryPrice': p.entryPrice,
              'lots': p.lots,
            })
        .toList();

    final jsonTrades = jsonEncode(trades);
    await webViewController.runJavaScript('updateTradeLines($jsonTrades)');
  }

  /*-------------------------------------------------------------*/
  /*                      credit calculations                    */
  /*-------------------------------------------------------------*/
  Future<void> creditCalculations(double pl) async {
    if (pl > 0) {
      // Profit directly adds to balance (reduces negative if any)
      balance.value += pl;
    } else {
      //  Loss handling
      final loss = pl.abs();

      if (balance.value >= loss) {
        //  Enough balance to cover loss fully
        balance.value -= loss;
      } else {
        //  Balance not enough
        double remainingLoss = loss - balance.value;

        // If balance is already negative or goes below zero
        balance.value -= loss; // allow temporary negative

        // Step 1: Try to cover remaining loss from credit
        if (credit.value > 0) {
          if (credit.value >= remainingLoss) {
            //  Credit fully covers the shortfall
            credit.value -= remainingLoss;
          } else {
            //  Credit not enough, use all credit and let balance go more negative
            credit.value = 0.0;
            // balance.value -= remainingLoss; // still negative, handled later
          }
        }
      }
    }
  }
  /*-------------------------------------------------------------*/
  /*                     close single trade                      */
  /*-------------------------------------------------------------*/

  // ---------------- Close Trade ----------------
  Future<void> closePosition(
    String id, {
    bool isShowDilog = true,
    isCloseTrade = true,
  }) async {
    _enqueueTrade(() async {
      if (_closingTrades.contains(id)) return; // skip if already closing
      _closingTrades.add(id);
      try {
        final idx = positions.indexWhere((p) => p.tradeid == id);
        if (idx == -1) return;

        final p = positions[idx];
        final pl = _positionPL(p); // uses current bid/ask

        // Calculate new balance safely

        await creditCalculations(pl);

        // close trade and save trades for history
        final sp = await SharedPreferences.getInstance();
        final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

        final exitPrice =
            (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;

        DateTime today = DateTime.now();
        String toDayDate = formatter.format(today).toString();

        final closeTrade = CloseTradesModel(
          tradeid: p.tradeid,
          userid: userId,
          symbol: p.symbol ?? "",
          side: p.side == TradeSide.buy ? 'BUY' : 'SELL',
          lots: p.lots,
          startPrice: p.entryPrice,
          currentPrice: exitPrice,
          dateTime: toDayDate,
          profitLose: pl,
          stopLoss: p.stopLoss ?? 0.0,
          takeProfit: p.takeProfit ?? 0.0,
        );

        closeTradeList.add(closeTrade);

        // Remove position immediately - prevent reappearing
        positions.removeAt(idx);
        // Also remove from confirmedTrades if present
        confirmedTrades.removeWhere((t) => t.tradeid == id);
        // CRITICAL: Remove from triggered trades set to allow re-triggering if trade is reopened
        _triggeredTrades.remove(id);
        // CRITICAL: Remove from executing orders set if it was there
        _executingOrderIds.remove(id);
        await refreshChartTradeLines();
        // Immediately update account metrics
        await _recalcUsedMargin();
        _recalcAccount();

        if (isShowDilog) {
          FlushMessages.commonToast(
            "Closed ${p.side == TradeSide.buy ? 'BUY' : 'SELL'} ${p.lots.toStringAsFixed(2)} | P/L ${pl.toStringAsFixed(2)}",
            backGroundColor: colorConstants.secondaryColor,
          );
        }
      } finally {
        _closingTrades.remove(id);
      }
    }, isCloseTrade: isCloseTrade);
  }

  /*-------------------------------------------------------------*/
  /*                      close all trades                       */
  /*-------------------------------------------------------------*/

  // Flag to prevent multiple simultaneous close-all operations
  bool _isClosingAll = false;

  Future<void> closeAllPositions() async {
    // Prevent multiple simultaneous calls
    if (_isClosingAll || positions.isEmpty) return;
    _isClosingAll = true;

    try {
      double realized = 0;

      // Clear any existing closed trades to prevent duplicates
      closeTradeList.clear();

      // Collect all positions to close (copy list to avoid modification during iteration)
      final positionsToClose = List<Position>.from(positions);
      final closedTradeIds = <String>{};

      for (final p in positionsToClose) {
        // close trades and save trades for history
        final sp = await SharedPreferences.getInstance();
        final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

        final exitPrice =
            (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;
        final pl = _positionPL(p);
        DateTime today = DateTime.now();
        String toDayDate = formatter.format(today).toString();
        final closeTrade = CloseTradesModel(
          tradeid: p.tradeid,
          userid: userId,
          symbol: p.symbol ?? "",
          side: p.side == TradeSide.buy ? 'BUY' : 'SELL',
          lots: p.lots,
          startPrice: p.entryPrice,
          currentPrice: exitPrice,
          dateTime: toDayDate,
          profitLose: pl,
          stopLoss: p.stopLoss ?? 0.0,
          takeProfit: p.takeProfit ?? 0.0,
        );

        closeTradeList.add(closeTrade);
        closedTradeIds.add(p.tradeid);
        realized += _positionPL(p);
      }

      // Track closed trade IDs to prevent re-adding
      _closedTradeIds.addAll(closedTradeIds);

      // Calculate and update balance
      await creditCalculations(realized);

      // Remove all positions immediately - prevent reappearing/blinking
      positions.clear();
      // Also remove from confirmedTrades if present
      confirmedTrades.removeWhere((t) => closedTradeIds.contains(t.tradeid));

      // Immediately update UI (removes trades from trade screen instantly)
      await refreshChartTradeLines();
      await _recalcUsedMargin();
      _recalcAccount();

      if (equity.value < 0 || balance.value < 0) {
        balance.value = 0.0;
      }

      FlushMessages.commonToast(
        "Closed ALL positions | P/L ${realized.toStringAsFixed(2)}",
        backGroundColor: colorConstants.secondaryColor,
      );

      // Temporarily stop polling to prevent re-adding closed trades
      _stopPositionsPolling();

      // Save completed trades to history ONCE (no duplicates)
      await saveCompletedTradesForHistory();

      // Refresh history screen after saving
      try {
        final navController = Get.find<NavController>();
        await navController.getYourTradsHistory();
      } catch (e) {
        debugPrint("Error refreshing history: $e");
      }

      // Update server with cleared positions
      await updateYourTradePositions();

      // Update balance/equity/margin on server
      await updateYourBalance();

      // Fetch fresh balance from server
      await getYourBalance();

      // Wait longer before refreshing positions to give server time to update
      // This prevents closed trades from reappearing
      _fetchDebounceTimer?.cancel();
      _fetchDebounceTimer = Timer(const Duration(seconds: 2), () {
        getYourTradePositions(
            silent: true, force: true); // Force refresh after delay
        // Restart polling after refresh
        _startPositionsPolling();
      });

      // Ensure UI updates (balance/equity/margin)
      _recalcAccount();
    } catch (e) {
      debugPrint("Error in closeAllPositions: $e");
    } finally {
      // Ensure list is cleared even on error
      if (positions.isNotEmpty) {
        final remainingIds = positions.map((p) => p.tradeid).toSet();
        _closedTradeIds.addAll(remainingIds);
        positions.clear();
        await refreshChartTradeLines();
        _recalcAccount();
      }
      _isClosingAll = false; // Reset flag
    }
  }

  /*-------------------------------------------------------------*/
  /*                    close profit trades                      */
  /*-------------------------------------------------------------*/
  // Flag to prevent multiple simultaneous close-profitable operations
  bool _isClosingProfitable = false;

  Future<void> closeProfitablePositions() async {
    // Prevent multiple simultaneous calls
    if (_isClosingProfitable || positions.isEmpty) return;
    _isClosingProfitable = true;

    try {
      final toClose = positions.where((p) => _positionPL(p) > 0.0).toList();
      if (toClose.isEmpty) {
        _isClosingProfitable = false;
        return;
      }

      // Clear any existing closed trades to prevent duplicates
      closeTradeList.clear();

      double realized = 0;
      final closedTradeIds = <String>{};

      for (final p in toClose) {
        // close trades and save trades for history
        final sp = await SharedPreferences.getInstance();
        final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

        final exitPrice =
            (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;
        final pl = _positionPL(p);
        DateTime today = DateTime.now();
        String toDayDate = formatter.format(today).toString();
        final closeTrade = CloseTradesModel(
          tradeid: p.tradeid,
          userid: userId,
          symbol: p.symbol ?? "",
          side: p.side == TradeSide.buy ? 'BUY' : 'SELL',
          lots: p.lots,
          startPrice: p.entryPrice,
          currentPrice: exitPrice,
          dateTime: toDayDate,
          profitLose: pl,
          stopLoss: p.stopLoss ?? 0.0,
          takeProfit: p.takeProfit ?? 0.0,
        );

        closeTradeList.add(closeTrade);
        closedTradeIds.add(p.tradeid);
        realized += _positionPL(p);
      }

      // Track closed trade IDs to prevent re-adding
      _closedTradeIds.addAll(closedTradeIds);

      // Remove all profitable positions immediately - prevent reappearing/blinking
      positions.removeWhere((p) => closedTradeIds.contains(p.tradeid));
      // Also remove from confirmedTrades if present
      confirmedTrades.removeWhere((t) => closedTradeIds.contains(t.tradeid));

      // Immediately update UI (removes trades from trade screen instantly)
      await refreshChartTradeLines();
      await creditCalculations(realized);
      await _recalcUsedMargin();
      _recalcAccount();

      if (positions.isEmpty && (equity.value < 0 || balance.value < 0)) {
        balance.value = 0.0;
      }

      FlushMessages.commonToast(
        "Closed PROFIT positions | P/L ${realized.toStringAsFixed(2)}",
        backGroundColor: colorConstants.secondaryColor,
      );

      // Temporarily stop polling to prevent re-adding closed trades
      _stopPositionsPolling();

      // Save completed trades to history ONCE (no duplicates)
      await saveCompletedTradesForHistory();

      // Refresh history screen after saving
      try {
        final navController = Get.find<NavController>();
        await navController.getYourTradsHistory();
      } catch (e) {
        debugPrint("Error refreshing history: $e");
      }

      // Update server with closed positions
      await updateYourTradePositions();

      // Update balance/equity/margin on server
      await updateYourBalance();

      // Fetch fresh balance from server
      await getYourBalance();

      // Wait longer before refreshing positions to give server time to update
      _fetchDebounceTimer?.cancel();
      _fetchDebounceTimer = Timer(const Duration(seconds: 2), () {
        getYourTradePositions(
            silent: true, force: true); // Force refresh after delay
        // Restart polling after refresh
        _startPositionsPolling();
      });

      // Ensure UI updates (balance/equity/margin)
      _recalcAccount();
    } catch (e) {
      debugPrint("Error in closeProfitablePositions: $e");
    } finally {
      _isClosingProfitable = false; // Reset flag
    }
  }

  /*-------------------------------------------------------------*/
  /*                     close lossing trade                     */
  /*-------------------------------------------------------------*/
  // Flag to prevent multiple simultaneous close-losing operations
  bool _isClosingLosing = false;

  Future<void> closeLosingPositions() async {
    // Prevent multiple simultaneous calls
    if (_isClosingLosing || positions.isEmpty) return;
    _isClosingLosing = true;

    try {
      final toClose = positions.where((p) => _positionPL(p) < 0.0).toList();
      if (toClose.isEmpty) {
        _isClosingLosing = false;
        return;
      }

      // Clear any existing closed trades to prevent duplicates
      closeTradeList.clear();

      double realized = 0;
      final closedTradeIds = <String>{};

      for (final p in toClose) {
        // close trades and save trades for history
        final sp = await SharedPreferences.getInstance();
        final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

        final exitPrice =
            (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;
        final pl = _positionPL(p);
        DateTime today = DateTime.now();
        String toDayDate = formatter.format(today).toString();
        final closeTrade = CloseTradesModel(
          tradeid: p.tradeid,
          userid: userId,
          symbol: p.symbol ?? "",
          side: p.side == TradeSide.buy ? 'BUY' : 'SELL',
          lots: p.lots,
          startPrice: p.entryPrice,
          currentPrice: exitPrice,
          dateTime: toDayDate,
          profitLose: pl,
          stopLoss: p.stopLoss ?? 0.0,
          takeProfit: p.takeProfit ?? 0.0,
        );

        closeTradeList.add(closeTrade);
        closedTradeIds.add(p.tradeid);
        realized += _positionPL(p);
      }

      // Track closed trade IDs to prevent re-adding
      _closedTradeIds.addAll(closedTradeIds);

      // Remove all losing positions immediately - prevent reappearing/blinking
      positions.removeWhere((p) => closedTradeIds.contains(p.tradeid));
      // Also remove from confirmedTrades if present
      confirmedTrades.removeWhere((t) => closedTradeIds.contains(t.tradeid));

      // Immediately update UI (removes trades from trade screen instantly)
      await refreshChartTradeLines();
      await creditCalculations(realized);
      await _recalcUsedMargin();
      _recalcAccount();

      if (positions.isEmpty && (equity.value < 0 || balance.value < 0)) {
        balance.value = 0.0;
      }

      FlushMessages.commonToast(
        "Closed NEGATIVE positions | P/L ${realized.toStringAsFixed(2)}",
        backGroundColor: colorConstants.secondaryColor,
      );

      // Temporarily stop polling to prevent re-adding closed trades
      _stopPositionsPolling();

      // Save completed trades to history ONCE (no duplicates)
      await saveCompletedTradesForHistory();

      // Refresh history screen after saving
      try {
        final navController = Get.find<NavController>();
        await navController.getYourTradsHistory();
      } catch (e) {
        debugPrint("Error refreshing history: $e");
      }

      // Update server with closed positions
      await updateYourTradePositions();

      // Update balance/equity/margin on server
      await updateYourBalance();

      // Fetch fresh balance from server
      await getYourBalance();

      // Wait longer before refreshing positions to give server time to update
      _fetchDebounceTimer?.cancel();
      _fetchDebounceTimer = Timer(const Duration(seconds: 2), () {
        getYourTradePositions(
            silent: true, force: true); // Force refresh after delay
        // Restart polling after refresh
        _startPositionsPolling();
      });

      // Ensure UI updates (balance/equity/margin)
      _recalcAccount();
    } catch (e) {
      debugPrint("Error in closeLosingPositions: $e");
    } finally {
      _isClosingLosing = false; // Reset flag
    }
  }

  /*-------------------------------------------------------------*/
  /*                     account recalculations                  */
  /*-------------------------------------------------------------*/
  bool _isRecalcInProgress = false;

  Future<void> _recalcUsedMargin() async {
    if (_isRecalcInProgress) return;
    _isRecalcInProgress = true;

    try {
      if (selectedModeIsHedge.value == "hedgeMode") {
        marginUsed.value = 0.0;
        final Map<String, double> buyLots = {};
        final Map<String, double> sellLots = {};

        for (final p in positions) {
          final symbol = p.symbol ?? "XAUUSD";
          if (p.side == TradeSide.buy) {
            buyLots[symbol] = (buyLots[symbol] ?? 0) + p.lots.abs();
          } else {
            sellLots[symbol] = (sellLots[symbol] ?? 0) + p.lots.abs();
          }
        }

        final priceForMargin = _midOrLast(); // compute once
        final allSymbols = {...buyLots.keys, ...sellLots.keys};

        for (final symbol in allSymbols) {
          final buy = buyLots[symbol] ?? 0.0;
          final sell = sellLots[symbol] ?? 0.0;
          final unhedgedLots = (buy - sell).abs();

          if (unhedgedLots > 0) {
            marginUsed.value += _marginRequired(
              lots: unhedgedLots,
              price: priceForMargin,
            );
          }
        }
      } else {
        double sum = 0.0;
        for (final p in positions) {
          sum += p.marginUsed;
        }
        marginUsed.value = sum;
      }

      await _recalcAccount();
    } finally {
      //  Always reset the flag, no matter what
      _isRecalcInProgress = false;
    }
  }

  Future<void> _recalcAccount() async {
    final pl = totalUnrealizedPL;
    equity.value = selectedMode.value == "Real"
        ? balance.value + credit.value + pl
        : balance.value + pl;
    freeMargin.value = equity.value - marginUsed.value;
    // marginLevelPct.value =
    //     marginUsed.value > 0 ? (equity.value / marginUsed.value) * 100.0 : 0.0;

    if (marginUsed.value > 0) {
      marginLevelPct.value = (equity.value / marginUsed.value) * 100.0;
    } else {
      marginLevelPct.value = double.infinity;
    }

    if (isLiquidating) return;

    final bool isFullyHedged = marginUsed.value.abs() <= 1e-9;

    bool shouldLiquidate = false;
    if (isFullyHedged) {
      shouldLiquidate = positions.isNotEmpty && (equity.value < 0);
    } else {
      shouldLiquidate = positions.isNotEmpty &&
          (marginUsed.value > 0) &&
          (equity.value < 0 || marginLevelPct.value <= stopOutLevelPct.value);
    }

    if (shouldLiquidate &&
        bidPrice.value > 0 &&
        askPrice.value > 0 &&
        isbalanceLoader.value == false) {
      isLiquidating = true;
      update();
      await saveLiquitedTradeHistory();
    }
  }

  bool _isTickerReconnecting = false;
  bool _isChartReconnecting = false;
  int _tickerRetryDelay = 5;
  int _chartRetryDelay = 5;

  /*-----------------------------------------------*/
  /*      Live ticker → update bid/ask/spread      */
  /*-----------------------------------------------*/
  void connectTickerSocket() async {
    if (_isTickerReconnecting) return;
    _isTickerReconnecting = true;
    // //  Don't attempt connection if no internet
    // final hasInternet = await _checkInternet();
    if (!isConnectedToInterNet.value) {
      _isTickerReconnecting = false;
      _handleTickerReconnect(); // schedule retry
      return;
    }

    try {
      tickerChannel?.sink.close();

      final apiSymbol = getBinanceSymbol(currentSymbol.value).toLowerCase();
      final url = 'wss://stream.binance.com:9443/ws/$apiSymbol@ticker';

      tickerChannel = IOWebSocketChannel.connect(Uri.parse(url));

      _tickerRetryDelay = 5; // reset delay on success

      tickerChannel!.stream.listen(
        (message) async {
          final data = jsonDecode(message);
          final c = double.tryParse('${data['c'] ?? '0'}') ?? 0.0;
          final b = double.tryParse('${data['b'] ?? '0'}') ?? 0.0;
          final a = double.tryParse('${data['a'] ?? '0'}') ?? 0.0;

          if (c > 0) lastPrice.value = c;
          if (b > 0) bidPrice.value = b;
          if (a > 0) askPrice.value = a;

          if (bidPrice.value > 0 && askPrice.value > 0) {
            spread.value = (askPrice.value - bidPrice.value).abs();
            if (lastPrice.value <= 0) {
              lastPrice.value = (bidPrice.value + askPrice.value) / 2.0;
            }
          }

          volume.value = '${data['v'] ?? '0'}';

          setMarketStatus();
          _recalcAccount();
          checkSLTP();

          try {
            webViewController.runJavaScript(
              'updateSpreadLines(${bidPrice.value}, ${askPrice.value});',
            );
          } catch (_) {}
        },
        onError: (error) {
          _handleTickerReconnect();
        },
        onDone: () {
          _handleTickerReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleTickerReconnect();
    } finally {
      _isTickerReconnecting = false;
    }
  }

  Future<void> _handleTickerReconnect() async {
    if (_isTickerReconnecting) return;
    _isTickerReconnecting = true;

    try {
      // Check internet before retry
      // final hasInternet = await _checkInternet();
      if (!isConnectedToInterNet.value) {
        await Future.delayed(Duration(seconds: _tickerRetryDelay));
        _tickerRetryDelay = (_tickerRetryDelay * 2).clamp(5, 60);
        _isTickerReconnecting = false;
        _handleTickerReconnect(); // try again later
        return;
      }

      await Future.delayed(Duration(seconds: _tickerRetryDelay));

      connectTickerSocket();
    } finally {
      _isTickerReconnecting = false;
    }
  }

  /*----------------------------------------------*/
  /*              Chart socket (logic)            */
  /*-----------------------------------------------*/
  void connectLiveChart(String symbol, String interval) async {
    if (_isChartReconnecting) return;
    _isChartReconnecting = true;
    // Don't attempt connection if no internet
    // final hasInternet = await _checkInternet();
    if (!isConnectedToInterNet.value) {
      _isChartReconnecting = false;
      _handleChartReconnect(symbol, interval); // schedule retry
      return;
    }

    try {
      chartChannel?.sink.close();

      final apiSymbol = getBinanceSymbol(symbol).toLowerCase();
      final wsUrl =
          'wss://stream.binance.com:9443/ws/$apiSymbol@kline_$interval';

      chartChannel = IOWebSocketChannel.connect(Uri.parse(wsUrl));

      _chartRetryDelay = 5; // reset delay on success

      chartChannel!.stream.listen(
        (event) {
          final decoded = jsonDecode(event);
          final k = decoded['k'];
          if (k == null) return;

          final bar = {
            'time': (k['t'] / 1000).floor(),
            'open': double.parse(k['o']),
            'high': double.parse(k['h']),
            'low': double.parse(k['l']),
            'close': double.parse(k['c']),
          };

          try {
            webViewController.runJavaScript(
              'updateCandle(${jsonEncode(bar)});',
            );
          } catch (_) {}
        },
        onError: (error) {
          _handleChartReconnect(symbol, interval);
        },
        onDone: () {
          _handleChartReconnect(symbol, interval);
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleChartReconnect(symbol, interval);
    } finally {
      _isChartReconnecting = false;
    }
  }

  Future<void> _handleChartReconnect(String symbol, String interval) async {
    if (_isChartReconnecting) return;
    _isChartReconnecting = true;

    try {
      // final hasInternet = await _checkInternet();
      if (!isConnectedToInterNet.value) {
        await Future.delayed(Duration(seconds: _chartRetryDelay));
        _chartRetryDelay = (_chartRetryDelay * 2).clamp(5, 60);
        _isChartReconnecting = false;
        _handleChartReconnect(symbol, interval);
        return;
      }

      await Future.delayed(Duration(seconds: _chartRetryDelay));

      connectLiveChart(symbol, interval);
    } finally {
      _isChartReconnecting = false;
    }
  }

  /*-----------------------------------------------*/
  /*           Init / symbol / interval            */
  /*-----------------------------------------------*/
  Future<void> initializeChart() async {
    try {
      final candles = await loadHistoricalData(
        symbol: currentSymbol.value,
        interval: currentInterval.value,
        limit: 500,
      );
      if (candles.isNotEmpty) {
        await webViewController.runJavaScript(
          'setInitialCandles(${jsonEncode(candles)});',
        );
      }

      // If bid/ask already known (e.g., from a previous socket), draw them.
      if (bidPrice.value > 0 && askPrice.value > 0) {
        await webViewController.runJavaScript(
          'updateSpreadLines(${bidPrice.value}, ${askPrice.value});',
        );
      }

      connectLiveChart(currentSymbol.value, currentInterval.value);
      connectTickerSocket();
    } catch (e) {}
  }

  // Future<void> changeSymbol(String newSymbol) async {
  //   currentSymbol.value = newSymbol.toUpperCase();

  //   // reset prices to avoid showing old spread on new symbol
  //   lastPrice.value = 0;
  //   bidPrice.value = 0;
  //   askPrice.value = 0;
  //   spread.value = 0;

  //   final candles = await loadHistoricalData(
  //     symbol: currentSymbol.value,
  //     interval: currentInterval.value,
  //     limit: 500,
  //   );
  //   if (candles.isNotEmpty) {
  //     await webViewController.runJavaScript(
  //       'setInitialCandles(${jsonEncode(candles)});',
  //     );
  //   }

  //   connectLiveChart(currentSymbol.value, currentInterval.value);
  //   connectTickerSocket();
  // }

  // Future<void> changeInterval(String newInterval) async {
  //   try {
  //     currentInterval.value = newInterval;
  //     final candles = await loadHistoricalData(
  //       symbol: currentSymbol.value,
  //       interval: currentInterval.value,
  //       limit: 500,
  //     );
  //     if (candles.isNotEmpty) {
  //       await webViewController.runJavaScript(
  //         'setInitialCandles(${jsonEncode(candles)});',
  //       );
  //     }
  //     connectLiveChart(currentSymbol.value, currentInterval.value);
  //   } catch (e) {}
  // }

  /*-----------------------------------------------*/
  /*  History data/candles loader from web socket  */
  /*-----------------------------------------------*/
  Future<List<Map<String, dynamic>>> loadHistoricalData({
    required String symbol,
    String interval = '1m',
    int limit = 500,
  }) async {
    try {
      final apiSymbol = getBinanceSymbol(symbol);
      final baseUrl = 'https://api.binance.com/api/v3/klines';
      final uri = Uri.parse(
        '$baseUrl?symbol=$apiSymbol&interval=$interval&limit=$limit',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return [];
      final List raw = jsonDecode(resp.body) as List;
      return raw.map((c) {
        return {
          'time': (c[0] / 1000).floor(),
          'open': double.parse(c[1].toString()),
          'high': double.parse(c[2].toString()),
          'low': double.parse(c[3].toString()),
          'close': double.parse(c[4].toString()),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /*-----------------------------------------------*/
  /*                 get your Balance              */
  /*-----------------------------------------------*/
  Future<void> getYourBalance({bool isFirstLoad = false}) async {
    try {
      if (isFirstLoad) {
        isbalanceLoader.value = true;
      }

      if (selectedMode.value == "Real") {
        final response = await TradingServices.getYourBalanceApi();
        if (response != null && response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          userData = responseData;
          balance.value = double.parse("${userData?['balance'] ?? 0.0}");
          leverage.value = double.parse("${userData?['leverage'] ?? 0.0}");
          marginUsed.value = double.parse("${userData?['margin used'] ?? 0.0}");
          credit.value = double.parse("${userData?['credit'] ?? 0.0}");
        } else {
          balance.value = 0.0;
          leverage.value = 0.0;
        }
      } else {
        //leverage.value = double.parse("${userData?['leverage'] ?? 0.0}");
        leverage.value = 1000.0;
        await getUserData();
        await getDemoBalance();
      }
    } catch (e) {
    } finally {
      isbalanceLoader.value = false;
    }
  }

  /*----------------------------------------------------------------------*/
  /*                              get demo balance                         */
  /*----------------------------------------------------------------------*/

  Future<void> getDemoBalance() async {
    try {
      update();
      var response = await HomeServices.getDemoBalance();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          balance.value = double.parse(responseData['demobalance']);
          credit.value = 0.0;
        }
      }
    } catch (e) {}
  }

  /*--------------------------------------------------*/
  /*              get demo margin in profile          */
  /*---------------------------------------------------*/
  Future<void> getUserData() async {
    try {
      var response = await AuthenticationService.getUserDataApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          userData = responseData['data'];
          marginUsed.value = double.parse(
            userData?['demousedmargin'].toString() ?? "0.0",
          );
        }
      }
    } catch (e) {}
  }

  /*-----------------------------------------------*/
  /*               update your balance             */
  /*-----------------------------------------------*/
  Future<void> updateYourTradePositions() async {
    try {
      // Convert pending orders to JSON format for API
      final pendingOrdersJson = selectedMode.value == "Real"
          ? pendingOrders
              .where((o) => !o.isExecuted)
              .map((o) => {
                    "tradeid": o.orderId,
                    "userid": o.userid,
                    "side": o.side == TradeSide.buy ? "buy" : "sell",
                    "lots": o.lots,
                    "entryPrice": o.entryPrice,
                    "contractSize": o.contractSize,
                    "marginUsed": o.marginUsed,
                    "openedAt":
                        DateFormat("yyyy-MM-dd HH:mm:ss").format(o.createdAt),
                    "symbol": o.symbol,
                    "stopLoss": o.stopLoss > 0 ? o.stopLoss : null,
                    "takeProfit": o.takeProfit > 0 ? o.takeProfit : null,
                    "status": "pending",
                    "priceAtCreation": o.priceAtCreation,
                    "hasPriceCrossedEntry":
                        o.hasPriceCrossedEntry, // Save the flag
                  })
              .toList()
          : <Map<String, dynamic>>[];

      final response = await TradingServices.updatePositionsOfTrade(
        positions,
        selectedMode.value,
        pendingOrders: pendingOrdersJson,
      );
      if (response != null && response.statusCode == 200) {}
    } catch (_) {
    } finally {
      // Refresh active/running trades after updating positions
      getYourTradePositions();
    }
  }

  /*-----------------------------------------------*/
  /*        Save pending order to backend          */
  /*-----------------------------------------------*/
  Future<void> _savePendingOrderToBackend(PendingOrder order) async {
    if (selectedMode.value != "Real") {
      return;
    }
    try {
      // Convert pending order to Position-like JSON format
      final pendingOrderJson = {
        "tradeid": order.orderId,
        "userid": order.userid,
        "side": order.side == TradeSide.buy ? "buy" : "sell",
        "lots": order.lots,
        "entryPrice": order.entryPrice,
        "contractSize": order.contractSize,
        "marginUsed": order.marginUsed,
        "openedAt": DateFormat("yyyy-MM-dd HH:mm:ss").format(order.createdAt),
        "symbol": order.symbol,
        "stopLoss": order.stopLoss > 0 ? order.stopLoss : null,
        "takeProfit": order.takeProfit > 0 ? order.takeProfit : null,
        "status": "pending",
        "priceAtCreation": order.priceAtCreation,
        "hasPriceCrossedEntry": order.hasPriceCrossedEntry, // Save the flag
      };

      final response = await TradingServices.updatePositionsOfTrade(
        <Position>[], // Empty positions list
        selectedMode.value,
        pendingOrders: [pendingOrderJson],
      );

      if (response != null && response.statusCode == 200) {
        debugPrint("Pending order saved to backend: ${order.orderId}");
      }
    } catch (e) {
      debugPrint("Error saving pending order to backend: $e");
    }
  }

  /*-----------------------------------------------*/
  /*     Update pending order status in backend    */
  /*-----------------------------------------------*/
  Future<void> updatePendingOrderStatus(String orderId, String status) async {
    if (selectedMode.value != "Real") {
      return;
    }
    try {
      // Find the pending order
      final order = pendingOrders.firstWhere(
        (o) => o.orderId == orderId,
        orElse: () => throw Exception("Order not found"),
      );

      // Convert to JSON with updated status
      final updatedOrderJson = {
        "tradeid": order.orderId,
        "userid": order.userid,
        "side": order.side == TradeSide.buy ? "buy" : "sell",
        "lots": order.lots,
        "entryPrice": order.entryPrice,
        "contractSize": order.contractSize,
        "marginUsed": order.marginUsed,
        "openedAt": DateFormat("yyyy-MM-dd HH:mm:ss").format(order.createdAt),
        "symbol": order.symbol,
        "stopLoss": order.stopLoss > 0 ? order.stopLoss : null,
        "takeProfit": order.takeProfit > 0 ? order.takeProfit : null,
        "status": status,
        "priceAtCreation": order.priceAtCreation,
        "hasPriceCrossedEntry": order.hasPriceCrossedEntry, // Save the flag
      };

      final response = await TradingServices.updatePositionsOfTrade(
        <Position>[],
        selectedMode.value,
        pendingOrders: [updatedOrderJson],
      );

      if (response != null && response.statusCode == 200) {
        debugPrint("Pending order status updated: $orderId -> $status");
      }
    } catch (e) {
      debugPrint("Error updating pending order status: $e");
    }
  }

  /*-----------------------------------------------*/
  /*               get trade positions             */
  /*-----------------------------------------------*/
  Future<void> getYourTradePositions(
      {bool silent = false, bool force = false}) async {
    // Prevent concurrent fetches to avoid flickering
    if (_isFetchingPositions && !force) {
      return;
    }

    try {
      _isFetchingPositions = true;

      if (!silent) {
        isTradeLoader.value = true;
      }
      final response = await TradingServices.getyourTrades(selectedMode.value);
      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle response format - could be list or object with Data field
        List<dynamic> tradesData = [];
        if (data is List) {
          tradesData = data;
        } else if (data is Map && data.containsKey("Data")) {
          tradesData = data["Data"] as List<dynamic>;
        } else if (data is Map && data.containsKey("data")) {
          tradesData = data["data"] as List<dynamic>;
        }

        // Parse positions and pending orders from API
        final apiPositions = <Position>[];
        final apiPendingOrders = <PendingOrder>[];

        const pendingStatuses = {"pending", "waiting", "in order"};
        const executedStatuses = {
          "executed",
          "active",
          "running",
          "open",
          "closed",
          "completed",
          "filled"
        };

        for (final item in tradesData) {
          final json = item as Map<String, dynamic>;
          final rawStatus =
              ((json["status"] as String?) ?? "").trim().toLowerCase();
          final tradeId =
              json["tradeid"]?.toString() ?? json["orderId"]?.toString() ?? "";

          // CRITICAL: Skip if this trade is currently being executed (prevent race condition)
          if (_executingOrderIds.contains(tradeId)) {
            continue;
          }

          final isPendingStatus = rawStatus.contains("pending") ||
              rawStatus.contains("waiting") ||
              pendingStatuses.contains(rawStatus);
          final isExecutedStatus = rawStatus.contains("execut") ||
              executedStatuses.contains(rawStatus);

          if (isPendingStatus && !isExecutedStatus) {
            // Treat as pending order
            try {
              final pendingOrder = PendingOrder.fromJson(json);
              if (!pendingOrder.isExecuted &&
                  !_executingOrderIds.contains(pendingOrder.orderId)) {
                apiPendingOrders.add(pendingOrder);
              }
            } catch (e) {
              debugPrint("Error parsing pending order: $e");
            }
          } else {
            // Treat as executed/active position
            try {
              final position = Position.fromJson(json);
              if (!positions.any((p) => p.tradeid == position.tradeid)) {
                apiPositions.add(position);
              }
            } catch (e) {
              debugPrint("Error parsing position: $e");
            }
          }
        }

        final executedFromApiIds = apiPositions.map((p) => p.tradeid).toSet();
        apiPendingOrders.removeWhere(
            (pending) => executedFromApiIds.contains(pending.orderId));

        // Restore pending orders from API (replace local list with API data)
        // This ensures pending orders persist across app restarts and account switches
        final existingPendingOrderIds =
            pendingOrders.map((o) => o.orderId).toSet();
        final apiPendingOrderIds =
            apiPendingOrders.map((o) => o.orderId).toSet();

        // CRITICAL: Never remove pending orders that are still waiting
        // Only remove if they're executed or explicitly deleted from backend
        // Keep local orders that were just created (not yet synced to API) for 120 seconds
        pendingOrders.removeWhere((o) {
          // CRITICAL: Never remove if currently executing
          if (_executingOrderIds.contains(o.orderId)) {
            return false;
          }

          // Keep if: order exists in API, order was created recently (within last 120 seconds), or order is not executed
          final isRecent =
              DateTime.now().difference(o.createdAt).inSeconds < 120;
          // Only remove if order is NOT in API AND NOT recent AND NOT executed AND NOT executing
          // This ensures waiting orders NEVER disappear unless executed or manually closed
          final shouldRemove = !apiPendingOrderIds.contains(o.orderId) &&
              !isRecent &&
              !o.isExecuted;
          if (shouldRemove) {
            debugPrint(
                "Removing pending order ${o.orderId} - not in API, not recent, not executed");
            _pendingOrderReferencePrices.remove(o.orderId);
          }
          return shouldRemove;
        });

        // Add new pending orders from API that we don't have locally
        final apiPendingOrdersFiltered = apiPendingOrders
            .where((pending) => pending.lots > 0 && pending.orderId.isNotEmpty)
            .toList();
        for (final apiOrder in apiPendingOrdersFiltered) {
          if (!existingPendingOrderIds.contains(apiOrder.orderId)) {
            // Add new pending order from API
            // CRITICAL: Reset hasPriceCrossedEntry to false for orders from API
            // They must wait for price to actually cross, even if backend says they crossed
            apiOrder.hasPriceCrossedEntry = false;
            pendingOrders.add(apiOrder);
            final refPrice = apiOrder.priceAtCreation > 0
                ? apiOrder.priceAtCreation
                : apiOrder.entryPrice;
            _pendingOrderReferencePrices[apiOrder.orderId] = refPrice;
          } else {
            // Update existing pending order with API data
            final index =
                pendingOrders.indexWhere((o) => o.orderId == apiOrder.orderId);
            if (index != -1) {
              // Preserve hasPriceCrossedEntry if order was just created locally and not yet crossed
              final existingOrder = pendingOrders[index];
              final isRecent =
                  DateTime.now().difference(existingOrder.createdAt).inSeconds <
                      60;
              if (isRecent && !existingOrder.hasPriceCrossedEntry) {
                // Keep local hasPriceCrossedEntry if order is recent and not yet crossed
                apiOrder.hasPriceCrossedEntry = false;
              } else if (!existingOrder.hasPriceCrossedEntry) {
                // If order hasn't crossed locally, don't trust API - reset to false
                apiOrder.hasPriceCrossedEntry = false;
              }
              // Only update if order is not executed
              if (!apiOrder.isExecuted) {
                pendingOrders[index] = apiOrder;
                // CRITICAL: Clear cache to force rebuild of allTradeItems
                _cachedAllTradeItems = null;
                final refPrice = apiOrder.priceAtCreation > 0
                    ? apiOrder.priceAtCreation
                    : apiOrder.entryPrice;
                _pendingOrderReferencePrices[apiOrder.orderId] = refPrice;
              }
            }
          }
        }

        // CRITICAL: Clear cache if pending orders changed
        if (apiPendingOrders.isNotEmpty ||
            pendingOrders.length != existingPendingOrderIds.length) {
          _cachedAllTradeItems = null;
        }

        // Create a set of API trade IDs for quick lookup
        final apiTradeIds = apiPositions.map((p) => p.tradeid).toSet();

        // Merge with existing positions to preserve app-bought trades that haven't synced yet
        // Remove closed trades (not in API response) but keep app-bought trades
        final Map<String, Position> mergedPositions = {};

        // First add existing positions that are still active (in API) or are app-bought (recently added)
        // BUT exclude closed trades (prevent re-adding)
        for (final pos in positions) {
          // Skip if this trade was closed
          if (_closedTradeIds.contains(pos.tradeid)) {
            continue;
          }

          // Keep if in API response (still active) or if it's a recent app-bought trade (added in last 10 seconds)
          final isRecent =
              DateTime.now().difference(pos.openedAt).inSeconds < 10;

          if (apiTradeIds.contains(pos.tradeid) || isRecent) {
            mergedPositions[pos.tradeid] = pos;
          }
        }

        // Also filter out closed trades from API positions and add them
        // CRITICAL: Prevent duplicates - check if position already exists
        for (final pos in apiPositions) {
          if (_closedTradeIds.contains(pos.tradeid)) {
            continue; // Skip closed trades from API
          }
          // CRITICAL: Only add if not already in merged positions (prevent duplicates)
          if (!mergedPositions.containsKey(pos.tradeid)) {
            mergedPositions[pos.tradeid] = pos;
          }
        }

        // CRITICAL: Remove pending orders that were executed - prevent showing as both "Waiting" and "Executed"
        final executedOrderIds = mergedPositions.keys.toSet();
        final beforePendingCount = pendingOrders.length;
        pendingOrders.removeWhere((o) {
          // Remove if order ID matches an executed position (prevent duplicate display)
          if (executedOrderIds.contains(o.orderId)) {
            final hadLocalRef =
                _pendingOrderReferencePrices.containsKey(o.orderId);
            if (!hadLocalRef) {
              debugPrint(
                  "Removing pending order ${o.orderId} - now exists as executed position");
              _pendingOrderReferencePrices.remove(o.orderId);
              return true;
            }
            // If we have a local reference AND API also sees executed, consider it handled
            return false;
          }
          return false;
        });
        if (beforePendingCount != pendingOrders.length) {
          _cachedAllTradeItems = null; // Clear cache if pending orders changed
        }

        // Only update if positions actually changed to prevent unnecessary UI updates
        final newPositionsList = mergedPositions.values.toList();
        final currentIds = positions.map((p) => p.tradeid).toSet();
        final newIds = newPositionsList.map((p) => p.tradeid).toSet();

        // Check if there's an actual change
        if (currentIds.length != newIds.length ||
            !currentIds.containsAll(newIds) ||
            !newIds.containsAll(currentIds)) {
          positions.value = newPositionsList;
          // CRITICAL: Clear cache to force rebuild of allTradeItems
          _cachedAllTradeItems = null;
          await refreshChartTradeLines();
          // Recalculate account metrics after positions update
          await _recalcUsedMargin();
          _recalcAccount();
        }
      } else if (response != null && response.statusCode == 404) {
        // 404 means no active trades from API - but keep app-bought trades
        // Only clear if we have no local positions
        if (positions.isEmpty) {
          await refreshChartTradeLines();
        } else {
          // Remove closed trades (not in API) but keep recent app-bought trades
          final beforeLength = positions.length;
          positions.removeWhere((pos) {
            final isRecent =
                DateTime.now().difference(pos.openedAt).inSeconds < 10;
            return !isRecent; // Remove if not recent (closed)
          });
          if (beforeLength != positions.length) {
            // Check if changed
            await refreshChartTradeLines();
            await _recalcUsedMargin();
            _recalcAccount();
          }
        }
      } else {
        // Other errors - keep existing positions to preserve app-bought trades
      }
    } catch (e) {
      debugPrint("Error fetching trade positions: $e");
      // On error, keep existing positions to preserve app-bought trades
    } finally {
      _isFetchingPositions = false;
      if (!silent) {
        isTradeLoader.value = false;
      }
    }
  }

  /*-----------------------------------------------*/
  /*     Start polling for backend/admin trades   */
  /*-----------------------------------------------*/
  void _startPositionsPolling() {
    // Cancel existing timer if any
    _positionsPollTimer?.cancel();

    // CRITICAL: Poll every 15 seconds (increased from 8 to reduce blinking/flickering)
    // Only poll when not already fetching to prevent overlapping requests
    _positionsPollTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!isConnectedToInterNet.value || _isFetchingPositions) {
        return; // Skip polling if no internet or already fetching
      }

      // CRITICAL: Debounce to prevent rapid consecutive calls
      _fetchDebounceTimer?.cancel();
      _fetchDebounceTimer = Timer(const Duration(milliseconds: 2000), () {
        // Only fetch if not already fetching
        if (!_isFetchingPositions) {
          // Silently refresh active trades to detect backend/admin-added trades
          getYourTradePositions(
              silent: true, force: false); // Only refresh active trades API
        }
      });
    });
  }

  /*-----------------------------------------------*/
  /*     Stop polling for backend/admin trades     */
  /*-----------------------------------------------*/
  void _stopPositionsPolling() {
    _positionsPollTimer?.cancel();
  }

  /*-----------------------------------------------*/
  /*      Fetch active trades from confirmed API   */
  /*-----------------------------------------------*/
  Future<void> fetchConfirmedTrades({bool force = false}) async {
    // Prevent concurrent fetches to avoid flickering
    if (_isFetchingConfirmed && !force) {
      return;
    }

    try {
      _isFetchingConfirmed = true;
      isLoadingConfirmedTrades.value = true;

      final response = await TradingServices.getTradesHistory(
        100, // Fetch up to 100 recent trades
        0,
        null, // No date filter
        null,
      );

      if (response != null) {
        // Handle 404 - No trade history found (show empty state)
        if (response.statusCode == 404) {
          // Only clear if actually empty (not just updating)
          if (confirmedTrades.isNotEmpty) {
            confirmedTrades.clear();
          }
          return;
        }

        // Handle 200 - Success
        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body);

            // Handle null/empty response
            if (data == null) {
              if (confirmedTrades.isNotEmpty) {
                confirmedTrades.clear();
              }
              return;
            }

            // Check for TotalRecords field - if 0, show empty state
            if (data is Map) {
              final totalRecords = data['TotalRecords'] ??
                  data['totalRecords'] ??
                  data['total_records'];
              if (totalRecords != null) {
                final total = totalRecords is int
                    ? totalRecords
                    : int.tryParse(totalRecords.toString()) ?? 0;
                if (total == 0) {
                  if (confirmedTrades.isNotEmpty) {
                    confirmedTrades.clear();
                  }
                  return;
                }
              }

              // Check for error message in response body
              if (data['message'] != null) {
                final message = data['message'].toString().toLowerCase();
                if (message.contains('no trade history') ||
                    message.contains('not found') ||
                    message.contains('no trades')) {
                  if (confirmedTrades.isNotEmpty) {
                    confirmedTrades.clear();
                  }
                  return;
                }
              }
            }

            // Extract Data array from API response
            final List<dynamic> tradesJson;
            if (data is List) {
              tradesJson = data.isEmpty ? [] : data;
            } else if (data is Map) {
              tradesJson =
                  (data['Data'] ?? data['data'] ?? []) as List<dynamic>;
            } else {
              tradesJson = [];
            }

            // If no trades in Data array, show empty state
            if (tradesJson.isEmpty) {
              if (confirmedTrades.isNotEmpty) {
                confirmedTrades.clear();
              }
              return;
            }

            // Parse trades from API - these should be active/running trades
            final List<CloseTradesModel> apiTrades = tradesJson
                .map((x) {
                  try {
                    return CloseTradesModel.fromJson(x as Map<String, dynamic>);
                  } catch (e) {
                    debugPrint("Error parsing trade: $e");
                    return null;
                  }
                })
                .whereType<CloseTradesModel>()
                .toList();

            // Get active trade IDs from positions to avoid duplicates
            final activeTradeIds = positions.map((p) => p.tradeid).toSet();

            // Filter to only trades not in positions (active trades from backend/admin)
            final newConfirmedTrades = apiTrades
                .where((trade) => !activeTradeIds.contains(trade.tradeid))
                .toList();

            // Only update if data actually changed to prevent flickering
            final currentIds = confirmedTrades.map((t) => t.tradeid).toSet();
            final newIds = newConfirmedTrades.map((t) => t.tradeid).toSet();

            if (currentIds.length != newIds.length ||
                !currentIds.containsAll(newIds) ||
                !newIds.containsAll(currentIds)) {
              confirmedTrades.value = newConfirmedTrades;
            }
          } catch (e) {
            debugPrint("Error parsing confirmed trades response: $e");
            // Don't clear on parsing error - keep existing data
          }
        } else {
          debugPrint(
              "Error fetching confirmed trades: Status ${response.statusCode}");
          // Don't clear on error - keep existing data
        }
      }
    } catch (e) {
      debugPrint("Error fetching confirmed trades: $e");
      // Don't clear on exception - keep existing data
    } finally {
      _isFetchingConfirmed = false;
      isLoadingConfirmedTrades.value = false;
    }
  }

  /*-----------------------------------------------*/
  /*     Get all trades (ONLY active from chart)   */
  /*-----------------------------------------------*/
  List<dynamic> get allTrades {
    // Trade page shows ONLY active trades applied from chart screen
    // Never show closed/history trades - those go to history screen only
    return List<dynamic>.from(positions);
  }

  /*-----------------------------------------------*/
  /*     Get all items for trade screen (positions + pending orders) */
  /*-----------------------------------------------*/
  // Cache for allTradeItems to prevent unnecessary rebuilds
  List<dynamic>? _cachedAllTradeItems;
  DateTime? _lastAllTradeItemsUpdate;

  List<dynamic> get allTradeItems {
    // CRITICAL: Cache the list to prevent unnecessary rebuilds and blinking
    // Only rebuild if positions or pendingOrders actually changed
    final now = DateTime.now();
    final shouldRebuild = _cachedAllTradeItems == null ||
        _lastAllTradeItemsUpdate == null ||
        now.difference(_lastAllTradeItemsUpdate!).inMilliseconds >
            100; // Debounce to 100ms

    if (shouldRebuild) {
      // Combine active positions and pending orders (only non-executed)
      // CRITICAL: Only show waiting pending orders, never executed ones
      final List<dynamic> items = [];
      items.addAll(positions);
      // Only add pending orders that are NOT executed
      items.addAll(pendingOrders.where((o) => !o.isExecuted));
      _cachedAllTradeItems = items;
      _lastAllTradeItemsUpdate = now;
    }

    return _cachedAllTradeItems ?? [];
  }

  /*-----------------------------------------------*/
  /*          Refresh all trade data               */
  /*-----------------------------------------------*/
  Future<void> refreshAllTradeData() async {
    try {
      // Use force flag to bypass concurrent checks for manual refresh
      // Refresh only active trades and balance (no history/closed trades)
      await Future.wait([
        getYourTradePositions(force: true), // Force fetch active trades only
        getYourBalance(),
      ]);

      // Recalculate account metrics (balance/equity/margin)
      await _recalcUsedMargin();
      _recalcAccount();
    } catch (e) {
      debugPrint("Error refreshing trade data: $e");
    }
  }

  /*-----------------------------------------------*/
  /*               update your balance             */
  /*-----------------------------------------------*/
  Future<void> updateYourBalance() async {
    try {
      update();

      final response = await TradingServices.updateBalance(
        balance.value,
        marginUsed.value,
        selectedMode.value,
        credit.value,
      );
      if (response != null && response.statusCode == 200) {}
    } catch (e) {}
  }

  /*-----------------------------------------------*/
  /*                save completed trades          */
  /*-----------------------------------------------*/
  Future<void> saveCompletedTradesForHistory() async {
    try {
      // Only save if there are trades to save (prevent empty API calls)
      if (closeTradeList.isEmpty) return;

      // Create a copy to avoid issues if list is modified during API call
      final tradesToSave = List<CloseTradesModel>.from(closeTradeList);

      final response = await TradingServices.saveCompletedTrades(
        tradesToSave,
        selectedMode.value,
      );
      if (response != null && response.statusCode == 200) {
        // Successfully saved - clear the list
        closeTradeList.clear();
      }
    } catch (e) {
      debugPrint("Error saving completed trades: $e");
    } finally {
      // Always clear to prevent duplicates on retry
      closeTradeList.clear();
      update();
    }
  }

  /*-----------------------------------------------*/
  /*            Save liquited trade history        */
  /*-----------------------------------------------*/
  Future<void> saveLiquitedTradeHistory() async {
    if (positions.isEmpty) {
      // No liquidation needed.
      return;
    }

    try {
      final pl = totalUnrealizedPL;

      await TradingServices.saveLiquitedTrade(
        selectedMode.value,
        lastPrice.value.toString(),
        balance.value.toString(),
        equity.value.toString(),
        marginUsed.value.toString(),
        freeMargin.value.toString(),
        marginLevelPct.value.toString(),
        pl.toString(),
      );

      //  Keep closing worst trades until margin level > stopOutLevelPct
      while (positions.isNotEmpty &&
          (equity.value < 0 || marginLevelPct.value <= stopOutLevelPct.value)) {
        // Sort trades from worst to best
        final sorted = List<Position>.from(positions)
          ..sort((a, b) => _positionPL(a).compareTo(_positionPL(b)));

        final worstTrade = sorted.first;

        await closePosition(
          worstTrade.tradeid,
          isShowDilog: false,
          isCloseTrade: true,
        );

        //  Wait until the trade queue is fully processed
        await _waitForTradeQueueToFinish();

        //  Stop liquidation when threshold is restored
        final bool isFullyHedged = marginUsed.value.abs() <= 1e-9;
        if (isFullyHedged) {
          if (equity.value >= 0) {
            break;
          }
        } else {
          if (marginLevelPct.value > stopOutLevelPct.value) {
            break;
          }
        }
      }

      if (positions.isEmpty && marginLevelPct.value <= stopOutLevelPct.value) {}
    } catch (e) {
    } finally {
      isLiquidating = false;
      update();
    }
  }

  Future<void> _waitForTradeQueueToFinish() async {
    // Wait until _tradeQueue is empty and not processing
    while (_isProcessingTradeQueue || _tradeQueue.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}





























// class TradeChartController extends GetxController {
//   static final DateFormat formatter = DateFormat('dd/MM/yyyy');
//   // ===== Live market values =====
//   final RxDouble lastPrice = 0.0.obs; // last traded (mid if missing)
//   final RxDouble bidPrice = 0.0.obs; // best bid
//   final RxDouble askPrice = 0.0.obs; // best ask
//   final RxDouble spread = 0.0.obs; // ask - bid
//   final RxString volume = '0'.obs;
//   RxString selectedModeIsHedge = "hedgeMode".obs;
//   RxString selectedMode = "Real".obs;
//   RxDouble stopOutLevelPct = 50.0.obs;
//   final RxBool isLiveUpdatesPaused = false.obs;
//   final RxDouble credit = 0.0.obs;

//   // persistent webview widget container
//   Widget? _persistentWebViewWidget;
//   bool _createdWebViewWidget = false;

//   Timer? _syncTimer;

//   late AudioPlayer audioPlayer;

//   RxBool isTradeLoader = false.obs;
//   RxBool isbalanceLoader = false.obs;

//   // ===== App colors / toasts =====
//   final ColorConstants colorConstants = ColorConstants();
//   Map<String, dynamic>? userData;

//   // ===== Account settings =====
//   RxDouble balance = 0.0.obs;

//   final RxDouble leverage = 1000.0.obs; // e.g. 1000 => 1:1000

//   // ===== Contract size (XAUUSD ~ 100 oz/lot) =====
//   final double kGoldContractSizePerLot = 100.0;

//   // ===== Live plumbing =====
//   WebSocketChannel? chartChannel;
//   WebSocketChannel? tickerChannel;
//   InAppWebViewController? webViewController;

//   final RxString currentSymbol = 'XAUUSD'.obs;
//   final RxString currentInterval = '1m'.obs;

//   // ===== Lot input =====
//   double lotSize = 0.00;
//   final TextEditingController loteSizeController = TextEditingController();

//   // ===== Account metrics =====
//   final RxDouble equity = 0.0.obs;
//   final RxDouble marginUsed = 0.0.obs; // sum of all positions' margin
//   final RxDouble freeMargin = 0.0.obs;
//   final RxDouble marginLevelPct = 0.0.obs;
//   final RxBool isChartReady = false.obs;
//   final RxBool isConnectedToInterNet = false.obs;
//   RxDouble floatingMenuTop = 100.0.obs;
//   RxDouble floatingMenuRight = 20.0.obs;
//   RxBool marketOpen = false.obs;
//   RxBool isWebViewInitialized = false.obs;
//   bool isLiquidating = false;

//   // ===== Positions =====
//   final RxList<Position> positions = <Position>[].obs;
//   final RxList<CloseTradesModel> closeTradeList = <CloseTradesModel>[].obs;

//   /*-------------------------------------------------------------*/
//   /*                    Check Market closed function             */
//   /*-------------------------------------------------------------*/
//   void setMarketStatus() {
//     final now = DateTime.now().toLocal();
//     final weekday = now.weekday;
//     final hour = now.hour;

//     //Weekend close: Saturday 2:00 AM → Monday 3:00 AM
//     if ((weekday == DateTime.saturday && hour >= 2) || // Saturday after 2 AM
//         weekday == DateTime.sunday || // Full Sunday
//         (weekday == DateTime.monday && hour < 3)) {
//       // Monday before 3 AM
//       marketOpen.value = false;
//     } else {
//       //Daily maintenance: 2:00 AM → 2:59 AM (closed)
//       if (hour == 2) {
//         marketOpen.value = false;
//       } else {
//         marketOpen.value = true;
//       }
//     }
//   }

//   /// Returns a persistent InAppWebView widget. Call this from your UI build.
//   Widget createPersistentWebView() {
//     if (_createdWebViewWidget && _persistentWebViewWidget != null) {
//       return _persistentWebViewWidget!;
//     }

//     _persistentWebViewWidget = Focus(
//       focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
//       child: InAppWebView(
//         key: const ValueKey('persistent_chart_webview'),
//         initialData: InAppWebViewInitialData(
//           data: '', // blank initially — we will load HTML from controller

//           encoding: 'utf-8',
//           mimeType: 'text/html',
//         ),
//         initialOptions: InAppWebViewGroupOptions(
//           crossPlatform: InAppWebViewOptions(
//             javaScriptEnabled: true,
//             useShouldOverrideUrlLoading: true,
//             mediaPlaybackRequiresUserGesture: false,
//             allowUniversalAccessFromFileURLs: true,
//             allowFileAccessFromFileURLs: true,
//           ),
//         ),
//         onWebViewCreated: (controller) async {
//           webViewController = controller;

//           // add JS handler that chart.html will call when the chart is ready
//           controller.addJavaScriptHandler(
//             handlerName: 'chartReady',
//             callback: (args) async {
//               // args from JS: [{ ready: true }]
//               debugPrint('JS chartReady called: $args');
//               // initialize once
//               if (!isWebViewInitialized.value) {
//                 await initializeChartOnce();
//               }
//             },
//           );

//           // optional: console messages forwarded
//           controller.addJavaScriptHandler(
//             handlerName: 'consoleLog',
//             callback: (args) {
//               debugPrint('JS console: $args');
//             },
//           );

//           // Load HTML content once from asset (controller controls when)
//           await _loadChartHtmlToWebview();
//         },
//         onLoadStop: (controller, url) async {
//           debugPrint('WebView onLoadStop: $url');
//           // do nothing here because we wait for JS chartReady call
//         },
//         onConsoleMessage: (controller, consoleMsg) {
//           debugPrint('JS console: ${consoleMsg.message}');
//         },
//       ),
//     );

//     _createdWebViewWidget = true;
//     return _persistentWebViewWidget!;
//   }

//   /// Loads the chart.html content into the webview. Called once in onWebViewCreated.
//   Future<void> _loadChartHtmlToWebview() async {
//     if (webViewController == null) return;
//     try {
//       final html = await rootBundle.loadString('assets/chart.html');
//       await webViewController!.loadData(
//         data: html,
//         mimeType: 'text/html',
//         encoding: 'utf-8',
//         baseUrl: WebUri('http://localhost'), //  fixed here
//       );
//       debugPrint('Chart HTML loaded into WebView');
//     } catch (e) {
//       debugPrint('Error loading chart.html: $e');
//     }
//   }

//   /// Called exactly once (guarded) AFTER JS notifies chartReady
//   Future<void> initializeChartOnce() async {
//     if (!isWebViewInitialized.value) {
//       debugPrint('initializeChartOnce skipped — already initialized');
//       return;
//     }
//     if (webViewController == null) {
//       debugPrint('initializeChartOnce: webViewController not ready');
//       return;
//     }

//     debugPrint('initializeChartOnce: fetching history & setting up sockets');

//     try {
//       // 1) Apply theme (if you have SettingsController)
//       final theme =
//           (Get.isRegistered(/*SettingsController*/))
//               ? (Get.find().isDarkTheme.value ? 'dark' : 'light')
//               : 'dark';
//       await webViewController!.evaluateJavascript(
//         source: "changeTheme('$theme');",
//       );

//       // 2) Fetch historical candles and set them
//       final candles = await loadHistoricalData(
//         symbol: currentSymbol.value,
//         interval: currentInterval.value,
//         limit: 500,
//       );
//       if (candles.isNotEmpty) {
//         final jsonCandles = jsonEncode(candles);
//         // call setInitialCandles(candles)
//         await webViewController!.evaluateJavascript(
//           source: 'setInitialCandles($jsonCandles);',
//         );
//         debugPrint('setInitialCandles called with ${candles.length} bars');
//       } else {
//         debugPrint('No historical candles returned');
//       }

//       // 3) Fit & zoom
//       await Future.delayed(const Duration(milliseconds: 200));
//       await webViewController!.evaluateJavascript(source: 'fitChart();');
//       await Future.delayed(const Duration(milliseconds: 150));
//       await webViewController!.evaluateJavascript(source: 'zoomToLast(100);');

//       // 4) Draw existing positions (if any)
//       for (final p in positions) {
//         // Expect positions elements containing id, entry, tp, sl, side
//         try {
//           final tradeJson = jsonEncode({
//             'id': p.tradeid ?? Uuid().v4(),
//             'entry': p.entryPrice,
//             'tp': p.takeProfit,
//             'sl': p.stopLoss,
//             'side':
//                 (p.side is String)
//                     ? p.side
//                     : (p.side == TradeSide.buy ? 'buy' : 'sell'),
//           });
//           await webViewController!.evaluateJavascript(
//             source: 'drawTradeLines($tradeJson);',
//           );
//         } catch (e) {
//           debugPrint('drawTradeLines error for pos $p : $e');
//         }
//       }

//       // 5) Start live websockets (kline + ticker)
//       connectLiveChart(currentSymbol.value, currentInterval.value);
//       connectTickerSocket();

//       isWebViewInitialized.value = true;

//       debugPrint('Chart initialization complete');
//     } catch (e) {
//       debugPrint('initializeChartOnce error: $e');
//     }
//   }

//   /*-------------------------------------------------------------*/
//   /*                      Check internet connection              */
//   /*-------------------------------------------------------------*/
//   Future<void> checkInternet() async {
//     final connectivityResult = await Connectivity().checkConnectivity();

//     if (connectivityResult.contains(ConnectivityResult.mobile) ||
//         connectivityResult.contains(ConnectivityResult.wifi)) {
//       isConnectedToInterNet.value = true;
//       loadChartDataFunction();
//     } else {
//       setMarketStatus();
//       isConnectedToInterNet.value = false;
//       loteSizeController.text = lotSize.toStringAsFixed(2);
//       SharedPreferences sp = await SharedPreferences.getInstance();
//       selectedMode.value = sp.getString("selectedMode") ?? "Real";
//       selectedModeIsHedge.value = sp.getString("hedgeOrNetMode") ?? "hedgeMode";
//     }
//   }

//   RxBool isShowSellBuy = true.obs;
//   void showHideSellBuy() {
//     isShowSellBuy.value = !isShowSellBuy.value;
//   }

//   Future<void> loadSelectedMode() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     selectedMode.value = sp.getString("selectedMode") ?? "Real";
//     getYourBalance(isFirstLoad: true);
//     getYourTradePositions();
//     _recalcAccount(); // initialize UI totals
//     update();
//   }

//   void loadChartDataFunction() async {
//     setMarketStatus();

//     try {
//       if (isWebViewInitialized.value) return; // prevent re-initialization

//       createPersistentWebView();

//       isWebViewInitialized.value = true;
//     } catch (e) {
//       print('Error in loadChartDataFunction: $e');
//     }

//     loteSizeController.text = lotSize.toStringAsFixed(2);
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     selectedMode.value = sp.getString("selectedMode") ?? "Real";
//     selectedModeIsHedge.value = sp.getString("hedgeOrNetMode") ?? "hedgeMode";
//     // set balance based on saved mode

//     getYourBalance(isFirstLoad: true);
//     getYourTradePositions();
//     _recalcAccount(); // initialize UI totals
//   }

//   StreamSubscription? _subscription;
//   bool firstInit = true;
//   @override
//   void onInit() async {
//     super.onInit();
//     firstInit = false;
//     update();
//     checkInternet();
//     _subscription = Connectivity().onConnectivityChanged.listen((resultList) {
//       if (resultList.contains(ConnectivityResult.none)) {
//         isConnectedToInterNet.value = false;
//         update();
//         _onDisconnected();
//       } else {
//         isConnectedToInterNet.value = true;

//         if (!isWebViewInitialized.value) {
//           loadChartDataFunction();
//         }
//         Get.put(NavController()).getUserData();
//         _onReconnected();
//       }
//     });

//     audioPlayer = AudioPlayer();
//   }

//   void _onDisconnected() {
//     // Stop live WebSocket streams
//     try {
//       tickerChannel?.sink.close();
//       chartChannel?.sink.close();
//     } catch (_) {}
//   }

//   Future<void> _onReconnected() async {
//     // Pause updates while reconnecting
//     isLiveUpdatesPaused.value = true;

//     try {
//       await Future.delayed(
//         const Duration(seconds: 2),
//       ); // small delay for DNS to recover

//       //  Try reconnect sockets safely
//       connectTickerSocket();
//       connectLiveChart(currentSymbol.value, currentInterval.value);

//       // Refresh balance & positions
//       if (firstInit) {
//         await getYourBalance();
//         await getYourTradePositions();
//         await _recalcAccount();
//       }

//       try {
//         await webViewController?.evaluateJavascript(
//           source: "showReconnectNotice();",
//         );
//       } catch (_) {}

//       // FlushMessages.commonToast(
//       //   "Reconnected — Live data resumed",
//       //   backGroundColor: Colors.green,
//       // );
//       firstInit = true;
//       update();
//     } catch (e) {
//     } finally {
//       // Resume updates
//       isLiveUpdatesPaused.value = false;
//     }
//   }

//   @override
//   void onClose() {
//     try {
//       tickerChannel?.sink.close();
//     } catch (_) {}
//     try {
//       chartChannel?.sink.close();
//     } catch (_) {}
//     loteSizeController.dispose();
//     _syncTimer?.cancel();
//     _subscription?.cancel();

//     super.onClose();
//   }

//   /*-----------------------------------------------*/
//   /*      Live ticker → update bid/ask/spread      */
//   /*-----------------------------------------------*/
//   void connectTickerSocket() async {
//     if (_isTickerReconnecting) return;
//     _isTickerReconnecting = true;
//     // //  Don't attempt connection if no internet
//     // final hasInternet = await _checkInternet();
//     if (!isConnectedToInterNet.value) {
//       _isTickerReconnecting = false;
//       _handleTickerReconnect(); // schedule retry
//       return;
//     }

//     try {
//       tickerChannel?.sink.close();

//       final apiSymbol = getBinanceSymbol(currentSymbol.value).toLowerCase();
//       final url = 'wss://stream.binance.com:9443/ws/$apiSymbol@ticker';

//       tickerChannel = IOWebSocketChannel.connect(Uri.parse(url));

//       _tickerRetryDelay = 5; // reset delay on success

//       tickerChannel!.stream.listen(
//         (message) async {
//           final data = jsonDecode(message);
//           final c = double.tryParse('${data['c'] ?? '0'}') ?? 0.0;
//           final b = double.tryParse('${data['b'] ?? '0'}') ?? 0.0;
//           final a = double.tryParse('${data['a'] ?? '0'}') ?? 0.0;

//           if (c > 0) lastPrice.value = c;
//           if (b > 0) bidPrice.value = b;
//           if (a > 0) askPrice.value = a;

//           if (bidPrice.value > 0 && askPrice.value > 0) {
//             spread.value = (askPrice.value - bidPrice.value).abs();
//             if (lastPrice.value <= 0) {
//               lastPrice.value = (bidPrice.value + askPrice.value) / 2.0;
//             }
//           }

//           volume.value = '${data['v'] ?? '0'}';

//           setMarketStatus();
//           _recalcAccount();
//           checkSLTP();

//           try {
//             webViewController?.evaluateJavascript(
//               source:
//                   'updateSpreadLines(${bidPrice.value}, ${askPrice.value});',
//             );
//           } catch (_) {}
//         },
//         onError: (error) {
//           _handleTickerReconnect();
//         },
//         onDone: () {
//           _handleTickerReconnect();
//         },
//         cancelOnError: true,
//       );
//     } catch (e) {
//       _handleTickerReconnect();
//     } finally {
//       _isTickerReconnecting = false;
//     }
//   }

//   /// Draw a trade (entry, TP, SL) from Dart side on chart
//   Future<void> drawTradeOnChart({
//     required String tradeId,
//     required double entry,
//     double? tp,
//     double? sl,
//     required String side, // 'buy' or 'sell'
//   }) async {
//     if (webViewController == null) return;
//     final dto = {
//       'id': tradeId,
//       'entry': entry,
//       'tp': tp,
//       'sl': sl,
//       'side': side,
//     };
//     await webViewController!.evaluateJavascript(
//       source: 'drawTradeLines(${jsonEncode(dto)});',
//     );
//   }

//   Future<void> removeTradeLinesFromChart(String tradeId) async {
//     if (webViewController == null) return;
//     await webViewController!.evaluateJavascript(
//       source: "removeTradeLines('${tradeId}');",
//     );
//   }

//   Future<void> _handleTickerReconnect() async {
//     if (_isTickerReconnecting) return;
//     _isTickerReconnecting = true;

//     try {
//       // Check internet before retry
//       // final hasInternet = await _checkInternet();
//       if (!isConnectedToInterNet.value) {
//         await Future.delayed(Duration(seconds: _tickerRetryDelay));
//         _tickerRetryDelay = (_tickerRetryDelay * 2).clamp(5, 60);
//         _isTickerReconnecting = false;
//         _handleTickerReconnect(); // try again later
//         return;
//       }

//       await Future.delayed(Duration(seconds: _tickerRetryDelay));

//       connectTickerSocket();
//     } finally {
//       _isTickerReconnecting = false;
//     }
//   }

//   /*----------------------------------------------*/
//   /*              Chart socket (logic)            */
//   /*-----------------------------------------------*/
//   void connectLiveChart(String symbol, String interval) async {
//     if (_isChartReconnecting) return;
//     _isChartReconnecting = true;
//     // Don't attempt connection if no internet
//     // final hasInternet = await _checkInternet();
//     if (!isConnectedToInterNet.value) {
//       _isChartReconnecting = false;
//       _handleChartReconnect(symbol, interval); // schedule retry
//       return;
//     }

//     try {
//       chartChannel?.sink.close();

//       final apiSymbol = getBinanceSymbol(symbol).toLowerCase();
//       final wsUrl =
//           'wss://stream.binance.com:9443/ws/$apiSymbol@kline_$interval';

//       chartChannel = IOWebSocketChannel.connect(Uri.parse(wsUrl));

//       _chartRetryDelay = 5; // reset delay on success

//       chartChannel!.stream.listen(
//         (event) {
//           final decoded = jsonDecode(event);
//           final k = decoded['k'];
//           if (k == null) return;

//           final bar = {
//             'time': (k['t'] / 1000).floor(),
//             'open': double.parse(k['o']),
//             'high': double.parse(k['h']),
//             'low': double.parse(k['l']),
//             'close': double.parse(k['c']),
//           };

//           try {
//             webViewController?.evaluateJavascript(
//               source: 'updateCandle(${jsonEncode(bar)});',
//             );
//           } catch (_) {}
//         },
//         onError: (error) {
//           _handleChartReconnect(symbol, interval);
//         },
//         onDone: () {
//           _handleChartReconnect(symbol, interval);
//         },
//         cancelOnError: true,
//       );
//     } catch (e) {
//       _handleChartReconnect(symbol, interval);
//     } finally {
//       _isChartReconnecting = false;
//     }
//   }

//   Future<void> _handleChartReconnect(String symbol, String interval) async {
//     if (_isChartReconnecting) return;
//     _isChartReconnecting = true;

//     try {
//       // final hasInternet = await _checkInternet();
//       if (!isConnectedToInterNet.value) {
//         await Future.delayed(Duration(seconds: _chartRetryDelay));
//         _chartRetryDelay = (_chartRetryDelay * 2).clamp(5, 60);
//         _isChartReconnecting = false;
//         _handleChartReconnect(symbol, interval);
//         return;
//       }

//       await Future.delayed(Duration(seconds: _chartRetryDelay));

//       connectLiveChart(symbol, interval);
//     } finally {
//       _isChartReconnecting = false;
//     }
//   }

//   // ==============================
//   //  DRAW BUY/SELL/TP/SL LINES
//   // ==============================
//   Future<void> drawTradeLines({
//     required double entryPrice,
//     double? takeProfit,
//     double? stopLoss,
//     required bool isBuy,
//   }) async {
//     try {
//       await webViewController?.evaluateJavascript(
//         source:
//             "drawTradeLines(${entryPrice.toString()}, ${takeProfit ?? 'null'}, ${stopLoss ?? 'null'}, ${isBuy.toString()});",
//       );
//     } catch (e) {
//       print("drawTradeLines error: $e");
//     }
//   }

//   /*-----------------------------------------------*/
//   /*           Init / symbol / interval            */
//   /*-----------------------------------------------*/
//   Future<void> initializeChart() async {
//     try {
//       final candles = await loadHistoricalData(
//         symbol: currentSymbol.value,
//         interval: currentInterval.value,
//         limit: 500,
//       );
//       if (candles.isNotEmpty) {
//         await webViewController?.evaluateJavascript(
//           source: 'setInitialCandles(${jsonEncode(candles)});',
//         );
//       }

//       // If bid/ask already known (e.g., from a previous socket), draw them.
//       if (bidPrice.value > 0 && askPrice.value > 0) {
//         await webViewController?.evaluateJavascript(
//           source: 'updateSpreadLines(${bidPrice.value}, ${askPrice.value});',
//         );
//       }

//       connectLiveChart(currentSymbol.value, currentInterval.value);
//       connectTickerSocket();
//     } catch (e) {}
//   }

//   // Future<void> changeSymbol(String newSymbol) async {

//   /*-----------------------------------------------*/
//   /*  History data/candles loader from web socket  */
//   /*-----------------------------------------------*/

//   /// Fetch historical candles from Binance REST (returns list of maps with time/open/high/low/close)
//   Future<List<Map<String, dynamic>>> loadHistoricalData({
//     required String symbol,
//     String interval = '1m',
//     int limit = 500,
//   }) async {
//     try {
//       final apiSymbol = getBinanceSymbol(symbol);
//       final url = Uri.parse(
//         'https://api.binance.com/api/v3/klines?symbol=$apiSymbol&interval=$interval&limit=$limit',
//       );
//       final resp = await http.get(url).timeout(const Duration(seconds: 10));
//       if (resp.statusCode != 200) return [];
//       final List raw = jsonDecode(resp.body) as List;
//       final list =
//           raw.map((c) {
//             return {
//               'time': (c[0] / 1000).floor(),
//               'open': double.parse(c[1].toString()),
//               'high': double.parse(c[2].toString()),
//               'low': double.parse(c[3].toString()),
//               'close': double.parse(c[4].toString()),
//             };
//           }).toList();
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint('loadHistoricalData error: $e');
//       return [];
//     }
//   }
//   // Future<List<Map<String, dynamic>>> loadHistoricalData({
//   //   required String symbol,
//   //   String interval = '1m',
//   //   int limit = 500,
//   // }) async {
//   //   try {
//   //     final apiSymbol = getBinanceSymbol(symbol);
//   //     final baseUrl = 'https://api.binance.com/api/v3/klines';
//   //     final uri = Uri.parse(
//   //       '$baseUrl?symbol=$apiSymbol&interval=$interval&limit=$limit',
//   //     );
//   //     final resp = await http.get(uri).timeout(const Duration(seconds: 10));
//   //     if (resp.statusCode != 200) return [];
//   //     final List raw = jsonDecode(resp.body) as List;
//   //     return raw.map((c) {
//   //       return {
//   //         'time': (c[0] / 1000).floor(),
//   //         'open': double.parse(c[1].toString()),
//   //         'high': double.parse(c[2].toString()),
//   //         'low': double.parse(c[3].toString()),
//   //         'close': double.parse(c[4].toString()),
//   //       };
//   //     }).toList();
//   //   } catch (_) {
//   //     return [];
//   //   }
//   // }

//   /*-----------------------------------------------*/
//   /*                 get your Balance              */
//   /*-----------------------------------------------*/
//   Future<void> getYourBalance({bool isFirstLoad = false}) async {
//     try {
//       if (isFirstLoad) {
//         isbalanceLoader.value = true;
//       }

//       if (selectedMode.value == "Real") {
//         final response = await TradingServices.getYourBalanceApi();
//         if (response != null && response.statusCode == 200) {
//           final responseData = jsonDecode(response.body);

//           userData = responseData;
//           balance.value = double.parse("${userData?['balance'] ?? 0.0}");
//           leverage.value = double.parse("${userData?['leverage'] ?? 0.0}");
//           marginUsed.value = double.parse("${userData?['margin used'] ?? 0.0}");
//           credit.value = double.parse("${userData?['credit'] ?? 0.0}");
//         } else {
//           balance.value = 0.0;
//           leverage.value = 0.0;
//         }
//       } else {
//         //leverage.value = double.parse("${userData?['leverage'] ?? 0.0}");
//         leverage.value = 1000.0;
//         await getUserData();
//         await getDemoBalance();
//       }
//     } catch (e) {
//     } finally {
//       isbalanceLoader.value = false;
//     }
//   }

//   /*-----------------------------------------------*/
//   /*                  Lot handling                 */
//   /*-----------------------------------------------*/
//   void increaseValue() {
//     final step = getStepSize();
//     lotSize = double.parse((lotSize + step).toStringAsFixed(2));
//     syncTextField();
//     update();
//   }

//   void decreaseValue() {
//     final step = getStepSize();
//     if (lotSize - step >= 0) {
//       lotSize = double.parse((lotSize - step).toStringAsFixed(2));
//       syncTextField();
//       update();
//     }
//   }

//   double getStepSize() {
//     if (lotSize < 1) return 0.01;
//     if (lotSize < 10) return 0.1;
//     return 1.0;
//   }

//   void setValueFromInput(String input, {bool format = false}) {
//     final parsed = double.tryParse(input);
//     if (parsed != null && parsed >= 0) {
//       lotSize = format ? double.parse(parsed.toStringAsFixed(2)) : parsed;
//       if (format) {
//         syncTextField();
//         update();
//       }
//     }
//   }

//   void syncTextField() {
//     loteSizeController.text = lotSize.toStringAsFixed(2);
//   }

//   /*------------------------------------------------------------------*/
//   /*                    stop loss and Take profit                     */
//   /*------------------------------------------------------------------*/

//   // --- Reactive SL/TP values ---
//   final stopLossController = TextEditingController();
//   final takeProfitController = TextEditingController();

//   // --- Step size (change according to symbol) ---
//   final double priceStep = 0.10; // e.g. 0.10 USD per tick

//   void updateSLTPValue(double sL, double tP) {
//     if (sL <= 0.0 && tP > 0.0) {
//       stopLossController.clear();
//       takeProfitController.text = tP.toStringAsFixed(2);
//     } else if (tP <= 0.0 && sL > 0.0) {
//       takeProfitController.clear();
//       stopLossController.text = sL.toStringAsFixed(2);
//     } else if (sL <= 0.0 && tP <= 0.0) {
//       stopLossController.clear();
//       takeProfitController.clear();
//     } else {
//       takeProfitController.text = tP.toStringAsFixed(2);
//       stopLossController.text = sL.toStringAsFixed(2);
//     }
//   }

//   // --- SL Methods ---
//   void increaseSL(double entryPrice) {
//     if (stopLossController.text.isEmpty ||
//         stopLossController.text == "0" ||
//         stopLossController.text == "0.0") {
//       stopLossController.text = entryPrice.toStringAsFixed(2);
//       final value = double.tryParse(stopLossController.text) ?? 0.0;
//       stopLossController.text = (value + priceStep).toStringAsFixed(2);
//     } else {
//       final value = double.tryParse(stopLossController.text) ?? 0.0;
//       stopLossController.text = (value + priceStep).toStringAsFixed(2);
//     }
//   }

//   void decreaseSL(double entryPrice) {
//     if (stopLossController.text.isEmpty ||
//         stopLossController.text == "0" ||
//         stopLossController.text == "0.0") {
//       stopLossController.text = entryPrice.toStringAsFixed(2);
//       final value = double.tryParse(stopLossController.text) ?? 0.0;
//       stopLossController.text = ((value - priceStep).clamp(
//         0.0,
//         double.infinity,
//       )).toStringAsFixed(2);
//     } else {
//       final value = double.tryParse(stopLossController.text) ?? 0.0;
//       stopLossController.text = ((value - priceStep).clamp(
//         0.0,
//         double.infinity,
//       )).toStringAsFixed(2);
//     }
//   }

//   // --- TP Methods ---
//   void increaseTP(double entryPrice) {
//     if (takeProfitController.text.isEmpty ||
//         takeProfitController.text == "0" ||
//         takeProfitController.text == "0.0") {
//       takeProfitController.text = entryPrice.toStringAsFixed(2);
//       final value = double.tryParse(takeProfitController.text) ?? 0.0;
//       takeProfitController.text = (value + priceStep).toStringAsFixed(2);
//     } else {
//       final value = double.tryParse(takeProfitController.text) ?? 0.0;
//       takeProfitController.text = (value + priceStep).toStringAsFixed(2);
//     }
//   }

//   void decreaseTP(double entryPrice) {
//     if (takeProfitController.text.isEmpty ||
//         takeProfitController.text == "0" ||
//         takeProfitController.text == "0.0") {
//       takeProfitController.text = entryPrice.toStringAsFixed(2);
//       final value = double.tryParse(takeProfitController.text) ?? 0.0;
//       takeProfitController.text = ((value - priceStep).clamp(
//         0.0,
//         double.infinity,
//       )).toStringAsFixed(2);
//     } else {
//       final value = double.tryParse(takeProfitController.text) ?? 0.0;
//       takeProfitController.text = ((value - priceStep).clamp(
//         0.0,
//         double.infinity,
//       )).toStringAsFixed(2);
//     }
//   }

//   /*-----------------------------------------------*/
//   /*          stop loss take profit logic          */
//   /*-----------------------------------------------*/
//   RxBool isSlSet = false.obs;
//   RxBool isTPSet = false.obs;

//   void setSLTP(String tradeId, {double? sl, double? tp}) async {
//     isSlSet = false.obs;
//     isTPSet = false.obs;

//     final idx = positions.indexWhere((pos) => pos.tradeid == tradeId);
//     if (idx == -1) return;

//     final pos = positions[idx];
//     final currentPrice =
//         (pos.side == TradeSide.buy) ? askPrice.value : bidPrice.value;

//     // -------------------- STOP LOSS VALIDATION --------------------
//     if (sl != null && sl != 0.0) {
//       if (pos.side == TradeSide.buy) {
//         if (sl >= pos.entryPrice) {
//           FlushMessages.commonToast(
//             "SL must be lower than entry price for Buy trade",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//           return;
//         }
//         if (sl >= currentPrice) {
//           FlushMessages.commonToast(
//             "SL must be lower than current price for Buy trade",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//           return;
//         }
//       } else if (pos.side == TradeSide.sell) {
//         if (sl <= pos.entryPrice) {
//           FlushMessages.commonToast(
//             "SL must be higher than entry price for Sell trade",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//           return;
//         }
//         if (sl <= currentPrice) {
//           FlushMessages.commonToast(
//             "SL must be higher than current price for Sell trade",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//           return;
//         }
//       }

//       isSlSet.value = true;
//       pos.stopLoss = sl;
//     } else {
//       pos.stopLoss = 0.0;
//     }

//     // -------------------- TAKE PROFIT VALIDATION --------------------
//     if (tp != null && tp != 0.0) {
//       if (pos.side == TradeSide.buy) {
//         if (tp <= pos.entryPrice) {
//           FlushMessages.commonToast(
//             "TP must be higher than entry price for Buy trade",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//           return;
//         }
//         if (tp <= currentPrice) {
//           FlushMessages.commonToast(
//             "TP must be higher than current price for Buy trade",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//           return;
//         }
//       } else if (pos.side == TradeSide.sell) {
//         if (tp >= pos.entryPrice) {
//           FlushMessages.commonToast(
//             "TP must be lower than entry price for Sell trade",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//           return;
//         }
//         if (tp >= currentPrice) {
//           FlushMessages.commonToast(
//             "TP must be lower than current price for Sell trade",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//           return;
//         }
//       }

//       isTPSet.value = true;
//       pos.takeProfit = tp;
//     } else {
//       pos.takeProfit = 0.0;
//     }

//     // -------------------- SUCCESS MESSAGES --------------------
//     if (isSlSet.value && isTPSet.value) {
//       FlushMessages.commonToast(
//         "SL/TP updated successfully",
//         backGroundColor: colorConstants.secondaryColor,
//       );
//       Get.back();
//     } else if (isSlSet.value) {
//       FlushMessages.commonToast(
//         "SL updated successfully",
//         backGroundColor: colorConstants.secondaryColor,
//       );
//       Get.back();
//     } else if (isTPSet.value) {
//       FlushMessages.commonToast(
//         "TP updated successfully",
//         backGroundColor: colorConstants.secondaryColor,
//       );
//       Get.back();
//     } else {
//       Get.back();
//     }

//     positions[idx] = pos; // Update in list

//     try {
//       await updateYourTradePositions();
//     } catch (e) {}
//   }

//   void checkSLTP() {
//     if (bidPrice.value > 0 && askPrice.value > 0) {
//       for (var p in positions.toList()) {
//         final exitPrice =
//             (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;

//         final hitSL =
//             p.stopLoss != null &&
//             p.stopLoss != 0.0 &&
//             ((p.side == TradeSide.buy && exitPrice <= p.stopLoss!) ||
//                 (p.side == TradeSide.sell && exitPrice >= p.stopLoss!));

//         final hitTP =
//             p.takeProfit != null &&
//             p.takeProfit != 0.0 &&
//             ((p.side == TradeSide.buy && exitPrice >= p.takeProfit!) ||
//                 (p.side == TradeSide.sell && exitPrice <= p.takeProfit!));

//         if (hitSL || hitTP) {
//           // Reset the opposite so it doesn’t re-trigger
//           if (hitSL) p.takeProfit = 0.0;
//           if (hitTP) p.stopLoss = 0.0;
//           _triggerClose(p);
//         }
//       }
//     }
//   }

//   void _triggerClose(Position p) {
//     closePosition(p.tradeid, isShowDilog: false);
//   }

//   /*-----------------------------------------------*/
//   /*               Symbol mapping                  */
//   /*-----------------------------------------------*/
//   String getBinanceSymbol(String uiSymbol) {
//     if (uiSymbol.toUpperCase() == 'XAUUSD') return 'PAXGUSDT';
//     return uiSymbol.toUpperCase();
//   }

//   /*-----------------------------------------------*/
//   /*                Core math helpers              */
//   /*-----------------------------------------------*/
//   // Correct margin: price * contractSize * lots / leverage
//   double _marginRequired({required double lots, required double price}) {
//     if (price <= 0 || lots <= 0) return 0;
//     final lev = leverage.value <= 0 ? 1 : leverage.value;
//     return price * lots * kGoldContractSizePerLot / lev;
//   }

//   // Unrealized P&L uses *exit* prices:
//   // - long closes at bid
//   // - short closes at ask
//   double _positionPL(Position p) {
//     if (bidPrice.value <= 0 || askPrice.value <= 0) return 0;
//     final exitPrice =
//         (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;
//     final diff =
//         (p.side == TradeSide.buy)
//             ? (exitPrice - p.entryPrice)
//             : (p.entryPrice - exitPrice);
//     return diff * p.lots * p.contractSize;
//   }

//   double get totalUnrealizedPL {
//     double sum = 0;
//     for (final p in positions) {
//       sum += _positionPL(p);
//     }
//     return sum;
//   }

//   double _midOrLast() {
//     if (bidPrice.value > 0 && askPrice.value > 0) {
//       return (bidPrice.value + askPrice.value) / 2.0;
//     }
//     return lastPrice.value;
//   }

//   /*-----------------------------------------------*/
//   /*           Eligibility & open trade            */
//   /*-----------------------------------------------*/

//   // ---------------- Queue System ----------------
//   final List<Future Function()> _tradeQueue = [];
//   bool _isProcessingTradeQueue = false;
//   final Set<String> _closingTrades = {}; // prevent duplicate closes
//   //  Add trade operation to queue (for background sync, not blocking)

//   void _enqueueTrade(Future Function() op, {bool isCloseTrade = false}) {
//     _tradeQueue.add(op);
//     _processTradeQueue(isCloseTrade: isCloseTrade);
//   }

//   Future<void> _processTradeQueue({bool isCloseTrade = false}) async {
//     if (_isProcessingTradeQueue) return;
//     _isProcessingTradeQueue = true;

//     while (_tradeQueue.isNotEmpty) {
//       final op = _tradeQueue.removeAt(0);
//       try {
//         await op();
//         await _recalcUsedMargin(); // always recalc locally

//         //No direct server calls here — handled by _scheduleServerSync()
//         if (isCloseTrade) {
//           if (positions.isEmpty && (equity.value < 0 || balance.value < 0)) {
//             balance.value = 0.0;
//           }
//           await saveCompletedTradesForHistory();
//           await updateYourTradePositions();
//           await updateYourBalance();
//           await getYourBalance();
//         }
//       } catch (e) {}
//     }
//     _isProcessingTradeQueue = false;
//   }

//   // ---------------- Open Trade ----------------

//   Future<void> openTrade(TradeSide side) async {
//     if (isLiquidating) return;

//     //  Validate *before* adding to queue
//     if (!isConnectedToInterNet.value) {
//       FlushMessages.commonToast(
//         "Please check your internet connection",
//         backGroundColor: colorConstants.dimGrayColor,
//       );
//       return;
//     }

//     if (lotSize <= 0) {
//       FlushMessages.commonToast(
//         "Enter a lot > 0",
//         backGroundColor: colorConstants.dimGrayColor,
//       );
//       return;
//     }

//     if (bidPrice.value <= 0 || askPrice.value <= 0) {
//       FlushMessages.commonToast(
//         "Waiting for live bid/ask...",
//         backGroundColor: colorConstants.dimGrayColor,
//       );
//       return;
//     }

//     final priceForMargin = _midOrLast();
//     final req = _marginRequired(lots: lotSize, price: priceForMargin);

//     if (freeMargin.value < req || req <= 0) {
//       FlushMessages.commonToast(
//         "Not enough margin. Required ${req.toStringAsFixed(2)}, Free ${freeMargin.value.toStringAsFixed(2)}",
//         backGroundColor: colorConstants.dimGrayColor,
//       );
//       return;
//     }

//     //  Passed all validation → now enqueue the trade
//     _enqueueTrade(() async {
//       final sp = await SharedPreferences.getInstance();
//       final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

//       final entry = (side == TradeSide.buy) ? askPrice.value : bidPrice.value;

//       final pos = Position(
//         tradeid: Uuid().v4(),
//         userid: userId,
//         side: side,
//         lots: lotSize,
//         entryPrice: entry,
//         contractSize: kGoldContractSizePerLot,
//         marginUsed: req,
//         openedAt: DateTime.now(),
//         symbol: currentSymbol.value,
//       );

//       HapticFeedback.heavyImpact();
//       positions.add(pos);

//       FlushMessages.commonToast(
//         "Opened ${side == TradeSide.buy ? 'BUY' : 'SELL'} ${lotSize.toStringAsFixed(2)} @ ${entry.toStringAsFixed(2)}",
//         backGroundColor: colorConstants.secondaryColor,
//       );
//       // Schedule server sync after last click
//       _scheduleServerSync();
//     });
//   }

//   void _scheduleServerSync() {
//     _syncTimer?.cancel(); // cancel previous timer if still counting
//     _syncTimer = Timer(const Duration(seconds: 3), () async {
//       try {
//         await updateYourTradePositions(); // send all current positions
//         await updateYourBalance();
//         await getYourBalance();
//       } catch (e) {}
//     });
//   }

//   /*-------------------------------------------------------------*/
//   /*                      credit calculations                    */
//   /*-------------------------------------------------------------*/
//   Future<void> creditCalculations(double pl) async {
//     if (pl > 0) {
//       // Profit directly adds to balance (reduces negative if any)
//       balance.value += pl;
//     } else {
//       //  Loss handling
//       final loss = pl.abs();

//       if (balance.value >= loss) {
//         //  Enough balance to cover loss fully
//         balance.value -= loss;
//       } else {
//         //  Balance not enough
//         double remainingLoss = loss - balance.value;

//         // If balance is already negative or goes below zero
//         balance.value -= loss; // allow temporary negative

//         // Step 1: Try to cover remaining loss from credit
//         if (credit.value > 0) {
//           if (credit.value >= remainingLoss) {
//             //  Credit fully covers the shortfall
//             credit.value -= remainingLoss;
//           } else {
//             //  Credit not enough, use all credit and let balance go more negative
//             credit.value = 0.0;
//             // balance.value -= remainingLoss; // still negative, handled later
//           }
//         }
//       }
//     }
//   }
//   /*-------------------------------------------------------------*/
//   /*                     close single trade                      */
//   /*-------------------------------------------------------------*/

//   // ---------------- Close Trade ----------------
//   Future<void> closePosition(
//     String id, {
//     bool isShowDilog = true,
//     isCloseTrade = true,
//   }) async {
//     _enqueueTrade(() async {
//       if (_closingTrades.contains(id)) return; // skip if already closing
//       _closingTrades.add(id);
//       try {
//         final idx = positions.indexWhere((p) => p.tradeid == id);
//         if (idx == -1) return;

//         final p = positions[idx];
//         final pl = _positionPL(p); // uses current bid/ask

//         // Calculate new balance safely

//         await creditCalculations(pl);

//         // close trade and save trades for history
//         final sp = await SharedPreferences.getInstance();
//         final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

//         final exitPrice =
//             (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;

//         DateTime today = DateTime.now();
//         String toDayDate = formatter.format(today).toString();

//         final closeTrade = CloseTradesModel(
//           tradeid: p.tradeid,
//           userid: userId,
//           symbol: p.symbol ?? "",
//           side: p.side == TradeSide.buy ? 'BUY' : 'SELL',
//           lots: p.lots,
//           startPrice: p.entryPrice,
//           currentPrice: exitPrice,
//           dateTime: toDayDate,
//           profitLose: pl,
//           stopLoss: p.stopLoss ?? 0.0,
//           takeProfit: p.takeProfit ?? 0.0,
//         );

//         closeTradeList.add(closeTrade);

//         // remove position
//         positions.removeAt(idx);

//         if (isShowDilog) {
//           FlushMessages.commonToast(
//             "Closed ${p.side == TradeSide.buy ? 'BUY' : 'SELL'} ${p.lots.toStringAsFixed(2)} | P/L ${pl.toStringAsFixed(2)}",
//             backGroundColor: colorConstants.secondaryColor,
//           );
//         }
//       } finally {
//         _closingTrades.remove(id);
//       }
//     }, isCloseTrade: isCloseTrade);
//   }

//   /*-------------------------------------------------------------*/
//   /*                      close all trades                       */
//   /*-------------------------------------------------------------*/

//   Future<void> closeAllPositions() async {
//     if (positions.isEmpty) return;
//     double realized = 0;

//     for (final p in positions) {
//       // close trades and save trades for histry
//       final sp = await SharedPreferences.getInstance();
//       final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

//       final exitPrice =
//           (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;
//       final pl = _positionPL(p);
//       DateTime today = DateTime.now();
//       String toDayDate = formatter.format(today).toString();
//       final closeTrade = CloseTradesModel(
//         tradeid: p.tradeid,
//         userid: userId,
//         symbol: p.symbol ?? "",
//         side: p.side == TradeSide.buy ? 'BUY' : 'SELL',
//         lots: p.lots,
//         startPrice: p.entryPrice,
//         currentPrice: exitPrice,
//         dateTime: toDayDate,
//         profitLose: pl,
//         stopLoss: p.stopLoss ?? 0.0,
//         takeProfit: p.takeProfit ?? 0.0,
//       );

//       closeTradeList.add(closeTrade);

//       realized += _positionPL(p);
//     }

//     await creditCalculations(realized);
//     // balance.value += realized;
//     positions.clear();

//     await _recalcUsedMargin();
//     if (positions.isEmpty && (equity.value < 0 || balance.value < 0)) {
//       balance.value = 0.0;
//     }

//     FlushMessages.commonToast(
//       "Closed ALL positions | P/L ${realized.toStringAsFixed(2)}",
//       backGroundColor: colorConstants.secondaryColor,
//     );

//     try {
//       await saveCompletedTradesForHistory();

//       await updateYourTradePositions();
//       await updateYourBalance();
//       await getYourBalance();
//     } catch (_) {
//     } finally {}
//   }

//   /*-------------------------------------------------------------*/
//   /*                    close profit trades                      */
//   /*-------------------------------------------------------------*/
//   Future<void> closeProfitablePositions() async {
//     if (positions.isEmpty) return;

//     final toClose = positions.where((p) => _positionPL(p) > 0.0).toList();
//     if (toClose.isEmpty) return;

//     double realized = 0;
//     for (final p in toClose) {
//       // close trades and save trades for histry
//       final sp = await SharedPreferences.getInstance();
//       final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

//       final exitPrice =
//           (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;
//       final pl = _positionPL(p);
//       DateTime today = DateTime.now();
//       String toDayDate = formatter.format(today).toString();
//       final closeTrade = CloseTradesModel(
//         tradeid: p.tradeid,
//         userid: userId,
//         symbol: p.symbol ?? "",
//         side: p.side == TradeSide.buy ? 'BUY' : 'SELL',
//         lots: p.lots,
//         startPrice: p.entryPrice,
//         currentPrice: exitPrice,
//         dateTime: toDayDate,
//         profitLose: pl,
//         stopLoss: p.stopLoss ?? 0.0,
//         takeProfit: p.takeProfit ?? 0.0,
//       );

//       closeTradeList.add(closeTrade);

//       realized += _positionPL(p);
//       positions.removeWhere((x) => x.tradeid == p.tradeid);
//     }

//     await creditCalculations(realized);
//     // balance.value += realized;

//     await _recalcUsedMargin();

//     if (positions.isEmpty && (equity.value < 0 || balance.value < 0)) {
//       balance.value = 0.0;
//     }

//     FlushMessages.commonToast(
//       "Closed PROFIT positions | P/L ${realized.toStringAsFixed(2)}",
//       backGroundColor: colorConstants.secondaryColor,
//     );

//     try {
//       await saveCompletedTradesForHistory();
//       await updateYourTradePositions();
//       await updateYourBalance();
//       await getYourBalance();
//     } catch (_) {
//     } finally {}
//   }

//   /*-------------------------------------------------------------*/
//   /*                     close lossing trade                     */
//   /*-------------------------------------------------------------*/
//   Future<void> closeLosingPositions() async {
//     if (positions.isEmpty) return;

//     final toClose = positions.where((p) => _positionPL(p) < 0.0).toList();
//     if (toClose.isEmpty) return;

//     double realized = 0;
//     for (final p in toClose) {
//       // close trades and save trades for histry
//       final sp = await SharedPreferences.getInstance();
//       final userId = int.tryParse(sp.getString("userId").toString()) ?? 0;

//       final exitPrice =
//           (p.side == TradeSide.buy) ? bidPrice.value : askPrice.value;
//       final pl = _positionPL(p);
//       DateTime today = DateTime.now();
//       String toDayDate = formatter.format(today).toString();
//       final closeTrade = CloseTradesModel(
//         tradeid: p.tradeid,
//         userid: userId,
//         symbol: p.symbol ?? "",
//         side: p.side == TradeSide.buy ? 'BUY' : 'SELL',
//         lots: p.lots,
//         startPrice: p.entryPrice,
//         currentPrice: exitPrice,
//         dateTime: toDayDate,
//         profitLose: pl,
//         stopLoss: p.stopLoss ?? 0.0,
//         takeProfit: p.takeProfit ?? 0.0,
//       );

//       closeTradeList.add(closeTrade);

//       realized += _positionPL(p);
//       positions.removeWhere((x) => x.tradeid == p.tradeid);
//     }
//     await creditCalculations(realized);
//     //balance.value += realized;

//     await _recalcUsedMargin();
//     if (positions.isEmpty && (equity.value < 0 || balance.value < 0)) {
//       balance.value = 0.0;
//     }

//     FlushMessages.commonToast(
//       "Closed LOSING positions | P/L ${realized.toStringAsFixed(2)}",
//       backGroundColor: colorConstants.secondaryColor,
//     );

//     try {
//       await saveCompletedTradesForHistory();
//       await updateYourTradePositions();
//       await updateYourBalance();
//       await getYourBalance();
//     } catch (_) {
//     } finally {}
//   }

//   /*-------------------------------------------------------------*/
//   /*                     account recalculations                  */
//   /*-------------------------------------------------------------*/
//   bool _isRecalcInProgress = false;

//   Future<void> _recalcUsedMargin() async {
//     if (_isRecalcInProgress) return;
//     _isRecalcInProgress = true;

//     try {
//       if (selectedModeIsHedge.value == "hedgeMode") {
//         marginUsed.value = 0.0;
//         final Map<String, double> buyLots = {};
//         final Map<String, double> sellLots = {};

//         for (final p in positions) {
//           final symbol = p.symbol ?? "XAUUSD";
//           if (p.side == TradeSide.buy) {
//             buyLots[symbol] = (buyLots[symbol] ?? 0) + p.lots.abs();
//           } else {
//             sellLots[symbol] = (sellLots[symbol] ?? 0) + p.lots.abs();
//           }
//         }

//         final priceForMargin = _midOrLast(); // compute once
//         final allSymbols = {...buyLots.keys, ...sellLots.keys};

//         for (final symbol in allSymbols) {
//           final buy = buyLots[symbol] ?? 0.0;
//           final sell = sellLots[symbol] ?? 0.0;
//           final unhedgedLots = (buy - sell).abs();

//           if (unhedgedLots > 0) {
//             marginUsed.value += _marginRequired(
//               lots: unhedgedLots,
//               price: priceForMargin,
//             );
//           }
//         }
//       } else {
//         double sum = 0.0;
//         for (final p in positions) {
//           sum += p.marginUsed;
//         }
//         marginUsed.value = sum;
//       }

//       await _recalcAccount();
//     } finally {
//       //  Always reset the flag, no matter what
//       _isRecalcInProgress = false;
//     }
//   }

//   Future<void> _recalcAccount() async {
//     final pl = totalUnrealizedPL;
//     equity.value =
//         selectedMode.value == "Real"
//             ? balance.value + credit.value + pl
//             : balance.value + pl;
//     freeMargin.value = equity.value - marginUsed.value;
//     // marginLevelPct.value =
//     //     marginUsed.value > 0 ? (equity.value / marginUsed.value) * 100.0 : 0.0;

//     if (marginUsed.value > 0) {
//       marginLevelPct.value = (equity.value / marginUsed.value) * 100.0;
//     } else {
//       marginLevelPct.value = double.infinity;
//     }

//     if (isLiquidating) return;

//     final bool isFullyHedged = marginUsed.value.abs() <= 1e-9;

//     bool shouldLiquidate = false;
//     if (isFullyHedged) {
//       shouldLiquidate = positions.isNotEmpty && (equity.value < 0);
//     } else {
//       shouldLiquidate =
//           positions.isNotEmpty &&
//           (marginUsed.value > 0) &&
//           (equity.value < 0 || marginLevelPct.value <= stopOutLevelPct.value);
//     }

//     if (shouldLiquidate &&
//         bidPrice.value > 0 &&
//         askPrice.value > 0 &&
//         isbalanceLoader.value == false) {
//       isLiquidating = true;
//       update();
//       await saveLiquitedTradeHistory();
//     }
//   }

//   bool _isTickerReconnecting = false;
//   bool _isChartReconnecting = false;
//   int _tickerRetryDelay = 5;
//   int _chartRetryDelay = 5;

//   /*----------------------------------------------------------------------*/
//   /*                              get demo balance                         */
//   /*----------------------------------------------------------------------*/

//   Future<void> getDemoBalance() async {
//     try {
//       update();
//       var response = await HomeServices.getDemoBalance();
//       if (response != null) {
//         if (response.statusCode == 200) {
//           var responseData = jsonDecode(response.body);
//           balance.value = double.parse(responseData['demobalance']);
//           credit.value = 0.0;
//         }
//       }
//     } catch (e) {}
//   }

//   /*--------------------------------------------------*/
//   /*              get demo margin in profile          */
//   /*---------------------------------------------------*/
//   Future<void> getUserData() async {
//     try {
//       var response = await AuthenticationService.getUserDataApi();
//       if (response != null) {
//         if (response.statusCode == 200) {
//           var responseData = jsonDecode(response.body);
//           userData = responseData['data'];
//           marginUsed.value = double.parse(
//             userData?['demousedmargin'].toString() ?? "0.0",
//           );
//         }
//       }
//     } catch (e) {}
//   }

//   /*-----------------------------------------------*/
//   /*               update your balance             */
//   /*-----------------------------------------------*/
//   Future<void> updateYourTradePositions() async {
//     try {
//       final response = await TradingServices.updatePositionsOfTrade(
//         positions,
//         selectedMode.value,
//       );
//       if (response != null && response.statusCode == 200) {}
//     } catch (_) {
//     } finally {
//       getYourTradePositions();
//     }
//   }

//   /*-----------------------------------------------*/
//   /*               get trade positions             */
//   /*-----------------------------------------------*/
//   Future<void> getYourTradePositions() async {
//     try {
//       isTradeLoader.value = true;
//       final response = await TradingServices.getyourTrades(selectedMode.value);
//       if (response != null && response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         positions.value = List<Position>.from(
//           data["Data"].map((item) => Position.fromJson(item)),
//         );
//       } else {
//         positions.clear();
//       }
//     } catch (e) {
//       positions.clear();
//     } finally {
//       isTradeLoader.value = false;
//     }
//   }

//   /*-----------------------------------------------*/
//   /*               update your balance             */
//   /*-----------------------------------------------*/
//   Future<void> updateYourBalance() async {
//     try {
//       update();

//       final response = await TradingServices.updateBalance(
//         balance.value,
//         marginUsed.value,
//         selectedMode.value,
//         credit.value,
//       );
//       if (response != null && response.statusCode == 200) {}
//     } catch (e) {}
//   }

//   /*-----------------------------------------------*/
//   /*                save completed trades          */
//   /*-----------------------------------------------*/
//   Future<void> saveCompletedTradesForHistory() async {
//     try {
//       final response = await TradingServices.saveCompletedTrades(
//         closeTradeList,
//         selectedMode.value,
//       );
//       if (response != null && response.statusCode == 200) {}
//     } catch (_) {
//     } finally {
//       closeTradeList.clear();
//       update();
//     }
//   }

//   /*-----------------------------------------------*/
//   /*            Save liquited trade history        */
//   /*-----------------------------------------------*/
//   Future<void> saveLiquitedTradeHistory() async {
//     if (positions.isEmpty) {
//       // No liquidation needed.
//       return;
//     }

//     try {
//       final pl = totalUnrealizedPL;

//       await TradingServices.saveLiquitedTrade(
//         selectedMode.value,
//         lastPrice.value.toString(),
//         balance.value.toString(),
//         equity.value.toString(),
//         marginUsed.value.toString(),
//         freeMargin.value.toString(),
//         marginLevelPct.value.toString(),
//         pl.toString(),
//       );

//       //  Keep closing worst trades until margin level > stopOutLevelPct
//       while (positions.isNotEmpty &&
//           (equity.value < 0 || marginLevelPct.value <= stopOutLevelPct.value)) {
//         // Sort trades from worst to best
//         final sorted = List<Position>.from(positions)
//           ..sort((a, b) => _positionPL(a).compareTo(_positionPL(b)));

//         final worstTrade = sorted.first;

//         await closePosition(
//           worstTrade.tradeid,
//           isShowDilog: false,
//           isCloseTrade: true,
//         );

//         //  Wait until the trade queue is fully processed
//         await _waitForTradeQueueToFinish();

//         //  Stop liquidation when threshold is restored
//         final bool isFullyHedged = marginUsed.value.abs() <= 1e-9;
//         if (isFullyHedged) {
//           if (equity.value >= 0) {
//             break;
//           }
//         } else {
//           if (marginLevelPct.value > stopOutLevelPct.value) {
//             break;
//           }
//         }
//       }

//       if (positions.isEmpty && marginLevelPct.value <= stopOutLevelPct.value) {}
//     } catch (e) {
//     } finally {
//       isLiquidating = false;
//       update();
//     }
//   }

//   Future<void> _waitForTradeQueueToFinish() async {
//     // Wait until _tradeQueue is empty and not processing
//     while (_isProcessingTradeQueue || _tradeQueue.isNotEmpty) {
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }
// }