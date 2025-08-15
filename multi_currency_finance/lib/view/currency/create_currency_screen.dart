import 'package:flutter/material.dart';
import 'package:multi_currency_finance/controller/common/services/service.interface.dart';
import 'package:multi_currency_finance/controller/currency/services/create_currency_service.dart';
import 'package:multi_currency_finance/model/currency/repository/currency_repository.interface.dart';
import 'package:multi_currency_finance/controller/common/global-instances/memory_currency_repository_instance.dart';

class CreateCurrencyScreen extends StatefulWidget {
  const CreateCurrencyScreen({super.key});

  @override
  CreateCurrencyScreenState createState() => CreateCurrencyScreenState();
}

class CreateCurrencyScreenState extends State<CreateCurrencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _abbreviationController = TextEditingController();
  final _symbolController = TextEditingController();

  //Temp
  final ICurrencyRepository _currencyRepository = MemoryCurrencyRepositoryInstance.instance;
  late final IService<CreateCurrencyRequest, CreateCurrencyResponse> _createCurrencyService;

  @override
  void initState() {
    super.initState();

    _createCurrencyService = CreateCurrencyService(this._currencyRepository);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _abbreviationController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // final request = CreateCurrencyRequest(
      //   name: _nameController.text,
      //   abbreviation: _abbreviationController.text,
      //   symbol: _symbolController.text,
      // );
      // print('Collected Data: ${request.toJson()}');
      // Further processing (e.g., sending to an API) would go here

      this._createCurrencyService.execute(
        CreateCurrencyRequest(
          _nameController.text, 
          _abbreviationController.text, 
          _symbolController.text)
      );
      Navigator.pop(context, true); // Pop the screen and return true
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Currency')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Currency Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _abbreviationController,
                decoration: InputDecoration(labelText: 'Currency Abbreviation'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency abbreviation';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _symbolController,
                decoration: InputDecoration(labelText: 'Currency Symbol'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency symbol';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Create Currency'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
