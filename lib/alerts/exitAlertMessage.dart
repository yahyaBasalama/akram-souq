import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

ExitAlertMessage(BuildContext context) {

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Color(0xFFF2F2F2),
    content: Container(
      alignment: Alignment.center,
      width: 300,
      height:120,
      child:Text(AppLocalizations.of(context).alert_logout,
        style: TextStyle(fontSize: 20),
      ),
    ),
    actions: <Widget>[
      TextButton(
        child:  Text(AppLocalizations.of(context).no,style: TextStyle(fontSize: 20,color: Colors.black),),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child:  Text(AppLocalizations.of(context).yes,style: TextStyle(fontSize: 20,color: Colors.black),),
        onPressed: () async {
          SystemNavigator.pop();
        },
      ),
    ],
  );
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}