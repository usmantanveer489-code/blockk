import 'dart:math';

class Position {
  String symbol;
  String type;
  double entryPrice;
  double lot;
  double currentPrice;
  double? exitPrice;
  DateTime openTime;
  DateTime? closeTime;

  Position({
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.lot,
    required this.currentPrice,
    DateTime? openTime,
    this.exitPrice,
    this.closeTime,
  }) : openTime = openTime ?? DateTime.now();

  double get profitLoss {
    if (type == "Buy") {
      return (currentPrice - entryPrice) * lot;
    } else {
      return (entryPrice - currentPrice) * lot;
    }
  }

  void updateCurrentPrice() {
    currentPrice += (Random().nextDouble() - 0.5) * 0.5;
  }
}

class TradeManager {
  static List<Position> allPositions = [];

  static List<Position> closedPositions = [];

  static void addPosition(Position position) {
    allPositions.add(position);
  }

  static void closePosition(int index) {
    if (index >= 0 && index < allPositions.length) {
      final pos = allPositions[index];
      pos.exitPrice = pos.currentPrice;
      pos.closeTime = DateTime.now();

      closedPositions.add(pos);
      allPositions.removeAt(index);
    }
  }

  static void updateAllPositions() {
    for (var pos in allPositions) {
      pos.updateCurrentPrice();
    }
  }

  static void clearAll() {
    allPositions.clear();
    closedPositions.clear();
  }
}


