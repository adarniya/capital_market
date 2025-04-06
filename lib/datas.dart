class UserData {
  String username;
  String accountNumber;
  double loanAmount;
  double moneyTaken;
  double moneyAvailable;
  String stockSymbol;
  int sharesPledged;

  UserData({
    required this.username,
    required this.accountNumber,
    required this.loanAmount,
    required this.moneyTaken,
    required this.moneyAvailable,
    required this.stockSymbol,
    required this.sharesPledged,
  });
}

// Simulating a temporary database with a list of users
List<UserData> userList = [
  UserData(
    username: 'John Doe',
    accountNumber: '1234567890',
    loanAmount: 10000.0,
    moneyTaken: 5000.0,
    moneyAvailable: 2000.0,
    stockSymbol: 'AAPL',
    sharesPledged: 50,
  ),
  UserData(
    username: 'Jane Smith',
    accountNumber: '0987654321',
    loanAmount: 15000.0,
    moneyTaken: 7000.0,
    moneyAvailable: 3000.0,
    stockSymbol: 'TSLA',
    sharesPledged: 100,
  ),
];
