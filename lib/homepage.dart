import 'dart:async';
import 'dart:developer';
import 'package:capital_market/accountpage.dart';
import 'package:capital_market/loanam.dart';
import 'package:capital_market/mongodbhelper.dart';
import 'package:capital_market/mvoui.dart';
import 'package:capital_market/portfolioclac.dart';
//import 'package:capital_market/stock_details_page.dart';
import 'package:capital_market/testui.dart';
import 'package:flutter/material.dart';
import 'package:capital_market/auctionpage.dart';
import 'package:capital_market/portfolio.dart';
import 'package:capital_market/notificationpage.dart';
import 'package:capital_market/portfoliochange.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'datas.dart'; // Import the temporary database file


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isHomeSelected = false;
  int _selectedIndex = 0;

  // ignore: prefer_final_fields
  PageController _pageController = PageController(initialPage: 0);
   final TextEditingController _stockController = TextEditingController();
  int _currentPage = 0;
  final String photoUrls = 'assets/anishjpgs.jpg';
  final String descriptionText = 'description yeta rakhne';
  int show = 0;

  @override
  void initState() {
    super.initState();
    _startAutomaticScroll();
  }

  void _startAutomaticScroll() {
    Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      _currentPage = (_currentPage + 1) % 10; // Assuming 10 items
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

     void _navigateToStockDetails(String stockController) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailPageee(stockSymbol: stockController),
      ),
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.white,
  leading: IconButton(
    icon: const Icon(
      Icons.perm_identity_outlined,
      color: Colors.black,
      size: 35,
    ),
    onPressed: () {
      setState(() {
        _selectedIndex = 3;
      });
    },
  ),
  title: TypeAheadField<String>(
    suggestionsCallback: (query) async {
      // Only return suggestions if the text field is focused and has content
      if (query.isNotEmpty) {
        return await MongoDBHelper.getStockSuggestions(query);
      }
      return [];
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideOnError: true,
    builder: (context, controller, focusNode) {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search Stock Symbol',
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        onTap: () {
          // Trigger suggestions when tapped
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        },
      );
    },
    itemBuilder: (context, stockController) {
      return ListTile(
        title: Text(stockController),
      );
    },
    onSelected: (stockController) {
      // Clear the controller and close suggestions
      _stockController.clear();
      FocusScope.of(context).unfocus();
     
      
      // Navigate to stock details or perform desired action
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StockDetailPageee(stockSymbol: stockController),
        ),
      );
    },
    controller: _stockController,
  ),
  actions: [
    IconButton(
      icon: const Icon(
        Icons.notifications_none_rounded,
        color: Colors.black,
        size: 30,
      ),
      onPressed: () {
       
      },
    ),
  ],
),
      
      
       
    
      
  

      body: Builder(
        builder: (BuildContext context) {
          if (_selectedIndex == 0) {
           return const PortfolioPage(
             
            );} 
            else if (_selectedIndex == 1) {
            return LoanAmortizationPage();
          
          } else if (_selectedIndex == 2) {
            return PortfolioChangeScreen();
          } else if (_selectedIndex == 3) {
            return  AccountPage();
          } else {
            return const Center(
              child: Text('Invalid Index'),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedFontSize: 14,
          selectedFontSize: 14,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'portfolio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              activeIcon: Icon(Icons.local_offer),
              label: 'loan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'add stocks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity_outlined),
              activeIcon: Icon(Icons.person),
              label: 'My Account',
            ),
          ],
        ),
      ),
    );
  }
}
