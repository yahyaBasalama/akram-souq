import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storeapp/database/userinfoDatabase.dart';
import 'package:storeapp/view/dashboard/stores/printer.dart';

class printer {
  //static const platform =  MethodChannel("com.thiqacartlive.live/text");
  static MethodChannel platform =  MethodChannel("com.thiqacartlive.live/text");

  connectToPrinter () async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    platform =  MethodChannel(packageInfo.packageName +"/text");
    userinfoDatabase userInfo = new userinfoDatabase();
    var printerAddress = await userInfo.getPrinterAddress();

    String result = "";

    if (printerAddress != "empty") {
      String value;
      try {
        value = await platform.invokeMethod('connectToPrinter',{"printerAddress": printerAddress});

        if (value.toString() == "connect") {
          userinfoDatabase userInfo = new userinfoDatabase();
          await userInfo.updatePrinterAddress(printerAddress: printerAddress);

          result = "connected";
        } else {
          result = "notconnected";
        }

      } on PlatformException catch (e) {
        result = "notconnected";
      }

      return result;
    } else {
      return "notconnected";
    }

  }
}