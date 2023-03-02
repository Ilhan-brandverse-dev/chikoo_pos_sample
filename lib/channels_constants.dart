class ChannelsConstants {
  static const String channelName = "brandverse.chikoo/POS";
  static const String paymentCall = "makePaymentCall";
  static const String paymentStatus = "checkPaymentStatus";
  static const String printerCall = "makePrinterCall";
  static const String printerStatus = "checkPrinterStatus";
  static const String processId =  "getProcessId";
}


List<String> header = [
  "Powered by : Chikoo",
  "DateTime: ${DateTime.now()}",
  "Done by: Syed Ilhan Shah"
];

List<String> footer= [
  "Purpose: This receipt is used only for testing purpose"
];