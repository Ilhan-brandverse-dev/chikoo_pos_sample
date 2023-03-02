import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pos_payment/channels_constants.dart';
import 'package:pos_payment/pos_response_handler.dart';

class POSController {
  final channel = const MethodChannel(ChannelsConstants.channelName);

  checkProcessId() async {
    int taskId = pid;
    print("Process Id from Flutter :- $taskId");
    final response = await channel.invokeMethod("getProcessId");
    print("Process id from Android:- $response");
  }

  Future<POSResponseHandler> makePayment() async {
    var taskId = await channel.invokeMethod(ChannelsConstants.processId);
    Map<String, dynamic> requestParams = {
      "header": {
        "ApiId": "1001",
        "applicationIdentifier": "com.brandverse.chikoo",
        "serviceApi": "PAYMENT_API",
        "userName": "userid",
        "userPassword": "password",
        "processId": taskId.toString()
      },
      "body": {
        "txnAmount": "100",
        "txnDateTime": DateTime.now().toString(),
        "txnCurrency": "PKR",
        "invNumber": "000067",
        "txnType": "SALE"
      }
    };

    final response = await channel.invokeMethod(
        ChannelsConstants.paymentCall, {"data": jsonEncode(requestParams)});
    print(response);

    POSResponseHandler responseHandler = POSResponseHandler();
    responseHandler.handleProcessRequest(response);
    return responseHandler;

  }

  Future<POSResponseHandler> checkPaymentStatus(String reference) async {
    var response = await channel
        .invokeMethod(ChannelsConstants.paymentStatus, {"data": reference});
    print(response);
    int totalSeconds = 0;
    while (response == '{}') {
      print("in while");
      await Future.delayed(const Duration(seconds: 2));
      if (totalSeconds >= 45) {
        break;
      } else {
        response = await channel
            .invokeMethod(ChannelsConstants.paymentStatus, {"data": reference});
        if (response != '{}') {
          break;
        }
      }
      totalSeconds += 2;
    }

    print(response.toString());
    POSResponseHandler responseHandler = POSResponseHandler();
    responseHandler.handleStatusCall(response);
    return responseHandler;

    /// Response
    //{
    // "code": "0000",
    // "message": "Success",
    // "cardNumber": "123456******6789",
    // "paymentResponseCode": "00",
    // "invoiceNumber": "123312312",
    // "rrn":"12345678901",
    // "txnData": "20/01/23",
    // "txnTime": "1212",
    // "txnAmount":"1298.75",
    // "txnCurrency":"PKR"
    // }
  }

  Future<POSResponseHandler> printReceipt(
      List<String> header, List<String> body, List<String> footer) async {
    var taskId = await channel.invokeMethod(ChannelsConstants.processId);
    Map<String, dynamic> requestParams = {
      "header": {
        "ApiId": "1002",
        "applicationIdentifier": "com.brandverse.chikoo",
        "serviceApi": "PRINTER_API",
        "userName": "userid",
        "userPassword": "password",
        "processId": taskId.toString()
      },
      "body": {
        "printHeader": {"sList": header},
        "printBody": {"sList": body},
        "printFooter": {"sList": footer}
      }
    };
    final response = await channel.invokeMethod(
        ChannelsConstants.printerCall, {"data": jsonEncode(requestParams)});
    print(response);
    POSResponseHandler responseHandler = POSResponseHandler();
    responseHandler.handleProcessRequest(response);
    return responseHandler;
  }

  Future<POSResponseHandler> checkPrinterStatus(String reference) async {
    final response = await channel
        .invokeMethod(ChannelsConstants.printerStatus, {"data": reference});
    print(response);
    POSResponseHandler responseHandler = POSResponseHandler();
    responseHandler.handleStatusCall(response);
    return responseHandler;
  }
}
