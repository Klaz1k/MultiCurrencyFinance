import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_entities.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_entities.dart';
import 'package:multi_currency_finance/controller/transaction/repository/hive/hive_transaction_entities.dart';
import 'package:multi_currency_finance/view/account/accounts_screen.dart';
import 'package:multi_currency_finance/view/settings/settings_screen.dart';
import 'package:multi_currency_finance/view/transaction/transactions_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    Hive.init("Web");
  } else {
    Hive.init((await getApplicationDocumentsDirectory()).path);
  }

  Hive.registerAdapter(AccountHiveObjectAdapter());
  Hive.registerAdapter(BalanceHiveObjectAdapter());
  Hive.registerAdapter(CurrencyHiveObjectAdapter());
  Hive.registerAdapter(TransactionHiveObjectAdapter());
  Hive.registerAdapter(TransactionTypeHiveObjectAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Currency Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _page = 0;
  final PageController _pageController = PageController();
  // final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final List<Widget> _screens = [AccountsScreen(), TransactionsScreen(), SettingsScreen()];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: _screens[_page],
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => {
          setState(() {
            _page = index;
          })
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        onTap: (index) {
          setState(() {
            _page = index;
            _pageController.animateToPage(
              _page, 
              duration: Durations.medium1, 
              curve: Curves.ease
            );
          });
        },
        selectedItemColor: Theme.of(
          context,
        ).colorScheme.primary, // Color of the highlight
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true, // Show label for selected item
        showUnselectedLabels: false, // Hide label for unselected items
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        enableFeedback: true, // Provides haptic feedback on tap
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
