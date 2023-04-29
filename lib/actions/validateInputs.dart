// @dart=2.11
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../controller/NavigationService.dart';

class inputValidator {

  String inputValue;

  inputValidator({
    this.inputValue,
  });

  factory inputValidator.fromJson(Map<String, dynamic>json){
    return inputValidator(
      inputValue: json['inputValue'],
    );
  }


  validatePrice (String value)  {
    if (value.length < 1) {
      return AppLocalizations.of(NavigationService.navigatorKey.currentContext).add_money;
    } else if (value.split(".").length > 2) {
      return AppLocalizations.of(NavigationService.navigatorKey.currentContext).error_add_money;
    }

   return null;
  }

  validateDotsPrice (String value)  {
    if (value.split(".").length > 2) {
      return AppLocalizations.of(NavigationService.navigatorKey.currentContext).error_add_money;
    }

    return null;
  }
}