import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntentData;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Tutorial'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            onLoading(context);
            await makePayment();
          },
          child: const Text(
            'Pay',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData =
          await createPaymentIntent('20', 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: const PaymentSheetApplePay(
                merchantCountryCode: "US",
              ),
              customerId: "aldha98d24u92894",
              style: ThemeMode.system,
              googlePay: const PaymentSheetGooglePay(
                  merchantCountryCode: "US", testEnv: true),
              merchantDisplayName: 'Ali Hassan'));
      // await Stripe.instance
      //     .handleCardAction(paymentIntentData!['client_secret'])
      //     .then((value) => print(value.id));

      ///now finally display payment sheeet

      await displayPaymentSheet();
      //that method return the the payment id
      await Stripe.instance
          .handleNextAction(paymentIntentData!['client_secret'])
          .then((value) {
        Navigator.pop(context);
        print(value.toJson());
      });
    } catch (e) {
      Navigator.pop(context);
      throw Exception(e);
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (_) {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      Navigator.pop(context);
      throw Exception(e);
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount('20'),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer enter you secret key',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body);
    } catch (err) {
      Navigator.pop(context);
      throw Exception(err);
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  void onLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: const Center(child: CircularProgressIndicator()));
      },
    );
  }
}
