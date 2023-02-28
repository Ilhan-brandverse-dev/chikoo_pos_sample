import 'dart:convert';

class POSResponseHandler {

  String? reference;
  dynamic response;

  handleProcessRequest(String data){
    Map<String,dynamic> parsedData = jsonDecode(data);
    if(parsedData["code"]=="0000"){
      reference = parsedData['ref'];
    }else{
      throw parsedData['message'];
    }
  }

  handleStatusCall(String data){
    Map<String, dynamic> parsedData = jsonDecode(data);
    if(parsedData['code']=='0000'){
      response = parsedData;
    }else{
      throw parsedData['message'];
    }
  }

}