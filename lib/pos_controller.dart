import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pos_payment/channels_constants.dart';
import 'package:pos_payment/pos_response_handler.dart';

class POSController {
  final channel = const MethodChannel(ChannelsConstants.channelName);

  Future<POSResponseHandler> makePayment() async {
    //get current process ID
    int taskId = pid;
    log(taskId.toString());
    Map<String, dynamic> requestParams = {
      "headers": {
        "APIId": "1001",
        "clientAppId": "com.brandverse.chikoo",
        "serviceName": "PAYMENT_API",
        "userName": "Test",
        "userPassword": "Testing123",
        "processId": taskId.toString()
      },
      "body": {
        "txnAmount": "1298.75",
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

    ///response
    ///"code": "0000",
    /// "message": "Acknowledged",
    /// "ref": "9999999999999"
  }

  Future<POSResponseHandler> checkPaymentStatus(String reference) async {
    int taskId = pid;
    log(taskId.toString());
    Map<String, dynamic> requestParams = {
      "header": {
        "APIId": "1002",
        "clientAppId": "com.brandverse.chikoo",
        "serviceName": "GET_STATUS_PAYMENT",
        "processId": taskId.toString()
      },
      "body": {"ref": reference}
    };

    final response = await channel.invokeMethod(
        ChannelsConstants.paymentStatus, {"data": jsonEncode(requestParams)});
    print(response);
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
    int taskId = pid;
    log(taskId.toString());
    Map<String, dynamic> requestParams = {
      "header": {
        "APIId": "1005",
        "clientAppId": "com.brandverse.chikoo",
        "serviceName": "PRINTER_API",
        "userName": "Test",
        "userPassword": "Testing123",
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

    ///Response
    //"code": "0000",
    // "message": "Acknowledged",
    // "ref": "9999999999999"
  }

  Future<POSResponseHandler> checkPrinterStatus(String reference) async {
    int taskId = pid;
    log(taskId.toString());
    Map<String, dynamic> requestParams = {
      "header": {
        "APIId": "1006",
        "clientAppId": "com.brandverse.chikoo",
        "serviceName": "GET_STATUS_PRINTER",
        "processId": taskId.toString()
      },
      "body": {"ref": reference}
    };

    final response = await channel.invokeMethod(
        ChannelsConstants.printerStatus, {"data": jsonEncode(requestParams)});
    print(response);
    POSResponseHandler responseHandler = POSResponseHandler();
    responseHandler.handleStatusCall(response);
    return responseHandler;
  }
}
