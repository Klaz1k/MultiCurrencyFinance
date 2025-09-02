import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_currency_finance/controller/account/repository/hive/hive_account_repository.dart';
import 'package:multi_currency_finance/controller/account/services/create_account_service.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/entities/currency_data.dart';
import 'package:multi_currency_finance/controller/currency/repository/hive/hive_currency_repository.dart';
// import 'package:multi_currency_finance/controller/currency/repository/memory_currency_repository.dart';
import 'package:multi_currency_finance/controller/currency/services/get_all_currencies_service.dart';
import 'package:multi_currency_finance/model/account/repository/account_repository.interface.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/view/currency/create_currency_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  CreateAccountScreenState createState() => CreateAccountScreenState();
}

class CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _initialAmountController = TextEditingController();
  final _mainCurrencyEquivalentController = TextEditingController();

  //Temp
  final ICurrencyRepository _currencyRepository = HiveCurrencyRepository.instance;
  final IAccountRepository _accountRepository = HiveAccountRepository.instance;
  late final IService<GetAllCurrenciesRequest, GetAllCurrenciesResponse> _getAllCurrenciesService; 
  late final IService<CreateAccountRequest, CreateAccountResponse> _createAccountService;

  List<CurrencyData> _currencies = [];
  CurrencyData? _selectedCurrency;
  bool _isLoadingCurrencies = true;

  @override
  void initState() {
    super.initState();
    this._getAllCurrenciesService = GetAllCurrenciesService(currencyRepository: this._currencyRepository);
    this._createAccountService = CreateAccountService(
      accountRepository: this._accountRepository,
      currencyRepository: this._currencyRepository
    ); 

    _fetchCurrencies();
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _descriptionController.dispose();
    _initialAmountController.dispose();
    _mainCurrencyEquivalentController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final currenciesResult = await this._getAllCurrenciesService.execute(GetAllCurrenciesRequest());

      if (currenciesResult.isError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currenciesResult.error.runtimeType.toString()),
              duration: Durations.medium2,
            )
          );
        }
        return;
      }

      setState(() {
        _currencies = currenciesResult.value.currencies;
        _isLoadingCurrencies = false;
      });
    } catch (e) {
      // Handle error fetching currencies
      setState(() {
        _isLoadingCurrencies = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final createResult = await this._createAccountService.execute(
        CreateAccountRequest(
          accountName: _accountNameController.text, 
          currencyId: _selectedCurrency!.id, 
          amount: double.parse(_initialAmountController.text), 
          mainCurrencyEquivalent: double.parse(_mainCurrencyEquivalentController.text), 
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text
        )
      );
      late final String snackBarText;
      if (createResult.isError) {
        snackBarText = "Account Could not be Created";
      } else {
        snackBarText = "Account Succesfully Created";
      }
      if (mounted) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackBarText))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _accountNameController,
                decoration: InputDecoration(labelText: 'Account Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              _isLoadingCurrencies
                  ? Center(child: CircularProgressIndicator())
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<CurrencyData>(
                            decoration: InputDecoration(labelText: 'Currency'),
                            value: _selectedCurrency,
                            items: _currencies.map((currency) {
                              return DropdownMenuItem<CurrencyData>(
                                value: currency,
                                child: Text(currency.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCurrency = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a currency';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateCurrencyScreen(),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _fetchCurrencies(); // Refresh currency list
                              }
                            });
                          },
                        ),
                      ],
                    ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                ),
                maxLines: 3,
              ),
              TextFormField(
                controller: _initialAmountController,
                decoration: InputDecoration(labelText: 'Initial Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an initial amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mainCurrencyEquivalentController,
                decoration: InputDecoration(labelText: 'Main Currency Equivalent'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an equivalent';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
