import 'dart:math';

class VaRCalculatord {
  /// Calculates Value at Risk (VaR) using the historical simulation method.
  static double calculateHistoricalVaR(List<double> returns, double confidenceLevel) {
    if (returns.isEmpty) return 0.0;

    // Sort returns in ascending order
    List<double> sortedReturns = List.from(returns)..sort();

    // Get index for the given confidence level
    int index = ((1 - confidenceLevel) * sortedReturns.length).floor();
    index = max(0, min(index, sortedReturns.length - 1));

    // VaR is the negative return at this index (loss)
    return -sortedReturns[index];
  }

  /// Converts percentage return VaR to actual monetary VaR
  static double calculateVaRValue(double portfolioValue, double varPercent) {
    return portfolioValue * varPercent;
  }
}
