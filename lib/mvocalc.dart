import 'dart:math';

class MVOCalculator {
  /// Step 1: Calculate daily returns (Formula 1)
  static List<double> calculateDailyReturns(List<Map<String, dynamic>> stockData) {
    List<double> dailyReturns = [];

    for (int i = 1; i < stockData.length; i++) {
      double prevClose = stockData[i - 1]['closePrice']?.toDouble() ?? 0.0;
      double currClose = stockData[i]['closePrice']?.toDouble() ?? 0.0;

      if (prevClose > 0) {
        dailyReturns.add((currClose - prevClose) / prevClose);
        print("daily return value is $dailyReturns");
      }
    }
    return dailyReturns;
  }

  /// Step 2: Compute expected return (Formula 1)
  static double calculateExpectedReturn(List<double> dailyReturns) {
    if (dailyReturns.isEmpty) return 0.0;
    return dailyReturns.reduce((a, b) => a + b) / dailyReturns.length;
  }

  /// Step 3: Compute variance & standard deviation (Formula 2)
  static Map<String, double> calculatePortfolioRisk(List<double> dailyReturns) {
    if (dailyReturns.isEmpty) return {"variance": 0.0, "stdDev": 0.0};

    double meanReturn = calculateExpectedReturn(dailyReturns);
    double variance = dailyReturns
            .map((r) => pow(r - meanReturn, 2))
            .reduce((a, b) => a + b) /
        dailyReturns.length;
    double stdDev = sqrt(variance);

    return {"variance": variance, "stdDev": stdDev};
  }

  /// Step 4: Calculate Sharpe Ratio (Formula 3)
  static double calculateSharpeRatio(double expectedReturn, double stdDev, double riskFreeRate) {
    if (stdDev == 0) return 0.0;
    return (expectedReturn - riskFreeRate) / stdDev;
  }

  /// Step 5: Optimize portfolio weights (Formula 4 - Placeholder)
  /// This function should be extended with optimization logic (not implemented here)
  static List<double> optimizePortfolioWeights(List<double> returns) {
    // Placeholder: Equal weight allocation (to be replaced with optimization logic)
    int n = returns.length;
    return List.filled(n, 1 / n);
  }

  /// Main function to calculate MVO
  static Map<String, dynamic> calculatePortfolio(List<Map<String, dynamic>> stockData, double riskFreeRate) {
    if (stockData.isEmpty) return {"error": "No data available"};

    List<double> dailyReturns = calculateDailyReturns(stockData);
    double expectedReturn = calculateExpectedReturn(dailyReturns);
    Map<String, double> risk = calculatePortfolioRisk(dailyReturns);
    double sharpeRatio = calculateSharpeRatio(expectedReturn, risk["stdDev"] ?? 0.0, riskFreeRate);
    List<double> weights = optimizePortfolioWeights(dailyReturns);

    return {
      "expectedReturn": expectedReturn,
      "variance": risk["variance"],
      "stdDev": risk["stdDev"],
      "sharpeRatio": sharpeRatio,
      "portfolioWeights": weights,
    };
  }
}
