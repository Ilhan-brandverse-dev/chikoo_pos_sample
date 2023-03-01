import 'package:flutter/material.dart';
import 'package:pos_payment/channels_constants.dart';
import 'package:pos_payment/pos_controller.dart';
import 'package:pos_payment/pos_response_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic data = '', error = '';
  late POSController controller;

  @override
  void initState() {
    super.initState();
    controller = POSController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("DATA RECEIVED: $data",
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(
                "ERROR: $error",
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () => makePayment(),
                  child: const Text('Payment call')),
              const SizedBox(height: 12),
              // ElevatedButton(
              //     onPressed: () {
              //       controller.checkPaymentStatus("9999999999999");
              //     },
              //     child: const Text('Payment Status')),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () => printReceipt(),
                  child: const Text('Printer call')),
              const SizedBox(height: 12),
              // ElevatedButton(onPressed: () {}, child: const Text('Printer status')),
            ],
          ),
        ),
      ),
    );
  }

  makePayment() async {
    try {
      POSResponseHandler paymentResponse = await controller.makePayment();
      if (paymentResponse.reference != null) {
        POSResponseHandler statusResponse =
            await controller.checkPaymentStatus(paymentResponse.reference!);
        data = statusResponse.response;
      } else {
        throw 'Payment reference not found';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {});
    }
  }

  printReceipt() async {
    try {
      POSResponseHandler printerResponse =
          await controller.printReceipt(header, getPaymentDetails(), footer);
      if (printerResponse.reference != null) {
        POSResponseHandler statusResponse =
            await controller.checkPrinterStatus(printerResponse.reference!);
        data = statusResponse.response;
      } else {
        throw 'Printer reference not found';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {});
    }
  }

  List<String> getPaymentDetails() {
    List<String> body = [];
    print(data);
    if (data != null && data!='') {
      data.forEach((key, value) {
        body.add("$key : $value");
      });
    }
    return body;
  }
}
