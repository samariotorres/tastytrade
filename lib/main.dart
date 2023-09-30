import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _tickerController = TextEditingController();
  String? _sessionToken;
  String? _latestPrice;
  String? _optionChain;
  List<OptionItem> _optionItems = [];

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('https://api.tastyworks.com/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'X-Tastyworks-OTP': _otpController.text,
      },
      body: jsonEncode({
        'login': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode < 300) {
      print(response.body);
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        _sessionToken = data['data']['session-token'];
        print('The session token is now: $_sessionToken');
      });
    } else {
      print('Response status code: ${response.statusCode}');
      print('Failed to login: ${response.body}');
    }
  }

  Future<void> _fetchData() async {
    if (_sessionToken == null) {
      print('You need to login first');
      return;
    }

    // final ticker = _tickerController.text;

    // Update the URLs based on your actual Tastytrade API endpoints.
    // The URLs below are placeholders and need to be replaced.
    // final priceResponse = await http.get(
    //   Uri.parse('https://api.tastyworks.com/instruments/$ticker/price'),
    //   headers: {
    //     'Authorization': '$_sessionToken',
    //   },
    // );

    final optionChainResponse = await http.get(
      Uri.parse('https://api.tastyworks.com/option-chains/${_tickerController.text}'),
      headers: {
        'Authorization': '$_sessionToken',
      },
    );

    if (optionChainResponse.statusCode < 300) {
      setState(() {
        final optionChainJson = jsonDecode(optionChainResponse.body);
        final List<dynamic>? options = optionChainJson['data']['items'];
        print(options![0]);
        if (options != null) {
          _optionItems = List<OptionItem>.from(
            options.map((item) => OptionItem.fromJson(item)),
          );
          print('_optionItems: $_optionItems');
        } else {
          print('No items found in optionChainJson');
        }
      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    // _usernameController.text = '';
    // _passwordController.text = '';
    _tickerController.text = 'AAPL';
    return Scaffold(
      appBar: AppBar(title: Text('TastyWorks API Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Login Section
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'OTP'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            if (_sessionToken != null) Text('Session Token: $_sessionToken'),

            // Ticker Input and Data Fetch Section
            TextField(
              controller: _tickerController,
              decoration: InputDecoration(labelText: 'Enter Ticker Symbol'),
            ),
            ElevatedButton(
              onPressed: _fetchData,
              child: Text('Fetch Data'),
            ),
            _optionItems.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _optionItems.length,
                      itemBuilder: (context, index) {
                        final option = _optionItems[index];
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _optionItems.length,
                          itemBuilder: (context, index) {
                            final option = _optionItems[index];
                            return ListTile(
                              title: Text(
                                option.symbol,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Instrument Details', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Symbol: ${option.symbol}'),
                                    Text('Instrument Type: ${option.instrumentType}'),
                                    Text('Active: ${option.active}'),
                                    Text('Strike Price: ${option.strikePrice}'),
                                    Text('Root Symbol: ${option.rootSymbol}'),
                                    Text('Underlying Symbol: ${option.underlyingSymbol}'),
                                    Text('Expiration Date: ${option.expirationDate}'),
                                    Text('Exercise Style: ${option.exerciseStyle}'),
                                    Text('Shares Per Contract: ${option.sharesPerContract}'),
                                    Text('Option Type: ${option.optionType}'),
                                    Text('Option Chain Type: ${option.optionChainType}'),
                                    Text('Expiration Type: ${option.expirationType}'),
                                    Text('Settlement Type: ${option.settlementType}'),
                                    Text('Stops Trading At: ${option.stopsTradingAt}'),
                                    Text('Market Time Instrument Collection: ${option.marketTimeInstrumentCollection}'),
                                    Text('Days To Expiration: ${option.daysToExpiration}'),
                                    Text('Expires At: ${option.expiresAt}'),
                                    Text('Is Closing Only: ${option.isClosingOnly}'),
                                    Text('Streamer Symbol: ${option.streamerSymbol}'),
                                    Divider(),
                                    Text('Instrument Type: ${option.instrumentType}'),
                                    SizedBox(height: 4),
                                    Text('Active: ${option.active}'),
                                    SizedBox(height: 4),
                                    Text('Strike Price: ${option.strikePrice}'),
                                    // ... repeat for other fields
                                    SizedBox(height: 4),
                                    Text('Streamer Symbol: ${option.streamerSymbol}'),
                                  ],
                                ),
                              ),
                              isThreeLine: true,
                              leading: Icon(Icons.label),
                              trailing: Icon(Icons.arrow_forward_ios),
                            );
                          },
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
            // if (_latestPrice != null) Text('Latest Price: $_latestPrice'),
            if (_optionChain != null) Text('Option Chain: $_optionChain'),
          ],
        ),
      ),
    );
  }
}

class OptionItem {
  final String symbol;
  final String instrumentType;
  final bool active;
  final String strikePrice;
  final String rootSymbol;
  final String underlyingSymbol;
  final String expirationDate;
  final String exerciseStyle;
  final int sharesPerContract;
  final String optionType;
  final String optionChainType;
  final String expirationType;
  final String settlementType;
  final String stopsTradingAt;
  final String marketTimeInstrumentCollection;
  final int daysToExpiration;
  final String expiresAt;
  final bool isClosingOnly;
  final String streamerSymbol;

  OptionItem({
    required this.symbol,
    required this.instrumentType,
    required this.active,
    required this.strikePrice,
    required this.rootSymbol,
    required this.underlyingSymbol,
    required this.expirationDate,
    required this.exerciseStyle,
    required this.sharesPerContract,
    required this.optionType,
    required this.optionChainType,
    required this.expirationType,
    required this.settlementType,
    required this.stopsTradingAt,
    required this.marketTimeInstrumentCollection,
    required this.daysToExpiration,
    required this.expiresAt,
    required this.isClosingOnly,
    required this.streamerSymbol,
  });

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      symbol: json['symbol'] ?? '',
      instrumentType: json['instrument-type'] ?? '',
      active: json['active'] ?? false,
      strikePrice: json['strike-price'] ?? 0.0,
      rootSymbol: json['root-symbol'] ?? '',
      underlyingSymbol: json['underlying-symbol'] ?? '',
      expirationDate: json['expiration-date'] ?? '',
      exerciseStyle: json['exercise-style'] ?? '',
      sharesPerContract: json['shares-per-contract'] ?? 0,
      optionType: json['option-type'] ?? '',
      optionChainType: json['option-chain-type'] ?? '',
      expirationType: json['expiration-type'] ?? '',
      settlementType: json['settlement-type'] ?? '',
      stopsTradingAt: json['stops-trading-at'] ?? '',
      marketTimeInstrumentCollection: json['market-time-instrument-collection'] ?? '',
      daysToExpiration: json['days-to-expiration'] ?? 0,
      expiresAt: json['expires-at'] ?? '',
      isClosingOnly: json['is-closing-only'] ?? false,
      streamerSymbol: json['streamer-symbol'] ?? '',
    );
  }
}
