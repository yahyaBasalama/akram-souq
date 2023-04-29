import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:storeapp/providers/user_info.dart';

import '../controller/printer.dart';
import '../controller/productsAndCart.dart';
import '../controller/share.dart';
import '../database/userinfoDatabase.dart';
import '../main.dart';


class ProductsProvider extends ChangeNotifier{


  // List getProducts = [];
  /// String company id, list of its products
  Map<String, List> products = {};
  /// string product id , list of the cards available
  Map<String, dynamic> cards = {};
  var noData = Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(left: 15, right: 15),
    child: Text("لاتوجد منتجات متاحة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
  );
  bool check = false;
  bool productsLoading = true;
  var textSize = 14;
  userinfoDatabase userInfo = new userinfoDatabase();
  // var countItemsArr= [];
  Map<String, List> countItemsArr= {};
  var showLoading = false;
  var showLoadingSimple = false;
  static const platform =  MethodChannel("com.cybitsec.souqcardstoreapp/text");
  // final GlobalKey<ScaffoldState> _scaffoldkeyValidate = new GlobalKey<ScaffoldState>();





  getProductsFun (String companyId, BuildContext context, {var myRole}) async {
    productsLoading = true;
    notifyListeners();
    if (products.containsKey(companyId)){
      productsLoading = false;
      if (products[companyId].isNotEmpty){
        print ("check is now true with ${products[companyId].length} products");
        check = true;
      }else {
        check = false;
      }

      notifyListeners();
    }
    productsCartsController getProductsClass = new productsCartsController(productsCartsController_companyId: companyId);
    // var getProductsForDisplay = await getProductsClass.getProducts();
    print ("getting product ${DateTime.now()}");
    var getProductsForDisplay = await getProductsClass.getCardsForSpecificProductsAfterStoresPutsDifference2(context, myRole: myRole);
    print ("got product ${DateTime.now()}");
    if (getProductsForDisplay["status"] == "available") {
        check = true;
        // getProducts = getProductsForDisplay["data"];
        List arrayTemp = [];
        if (products.containsKey(companyId)){
          products[companyId] = [];
          products[companyId] = getProductsForDisplay["data"] ;
        }else {
          products.addAll({companyId: getProductsForDisplay["data"]});
        }
        if (products.containsKey(companyId) && products[companyId].isNotEmpty){
          for (var pro in products[companyId]){
            print ("added");
            arrayTemp.add(1);
          }
        }

        countItemsArr.addAll({companyId:arrayTemp});

          try{
            cards = getProductsForDisplay["cards"];
          }catch(e){
          print ("in provider can not add the map $e");
          }

        productsLoading = false;
        notifyListeners();
      return products[companyId];
    } else {
      print ("hii no data here ${companyId}");
        check = false;
        productsLoading = false;
      products.addAll({companyId: []});
      noData = Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Text("لاتوجد منتجات متاحة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        );
        notifyListeners();
      return check;
    }
  }

  quantityPlusMinusTextSize(sign, state) {
    state(() {
      if(sign == '+'){
        if (textSize >= 50) {

        } else {
          textSize = textSize + 1;
          userInfo.updateUserTextSize(size: textSize.toString());
        }
      }
      else {
        if (textSize <= 1) {
          textSize = 1;
          userInfo.updateUserTextSize(size: textSize.toString());
        }
        else {
          textSize = textSize - 1;
          userInfo.updateUserTextSize(size: textSize.toString());
        }
      }
    });

  }

  quantityPlusMinus(index, sign, hasOtherState, state, compnyID) {
    // _getSize();
    if (hasOtherState == true) {
      state(() {
        if(sign == '+'){
          if (countItemsArr[compnyID][index] >= 5) {

          } else {
            countItemsArr[compnyID][index] = countItemsArr[compnyID][index] + 1;
            products[compnyID][index]["product_price"] = (double.parse(countItemsArr[compnyID][index].toString()) * double.parse(products[compnyID][index]["main_price"])).toString();
          }

        }
        else {
          if (countItemsArr[compnyID][index] <= 1) {
            countItemsArr[compnyID][index] = 1;
            products[compnyID][index]["product_price"] = (products[compnyID][index]["main_price"]).toString();
          }
          else {
            countItemsArr[compnyID][index] = countItemsArr[compnyID][index] - 1;

            if (countItemsArr[compnyID][index] == 1) {
              products[compnyID][index]["product_price"] = (products[compnyID][index]["main_price"]).toString();
            } else {
              products[compnyID][index]["product_price"] = (double.parse(countItemsArr[compnyID][index].toString()) * double.parse(products[compnyID][index]["main_price"])).toString();
            }

          }
        }
      });
    }
    else {

        if(sign == '+'){
          if (countItemsArr[compnyID][index] >= 5) {

          } else {
            countItemsArr[compnyID][index] = countItemsArr[compnyID][index] + 1;
            products[compnyID][index]["product_price"] = (double.parse(countItemsArr[compnyID][index].toString()) * double.parse(products[compnyID][index]["main_price"])).toString();
          }
        }
        else {
          if (countItemsArr[compnyID][index] <= 1) {
            countItemsArr[compnyID][index] = 1;
            products[compnyID][index]["product_price"] = (products[compnyID][index]["main_price"]).toString();
            notifyListeners();
          }
          else {
            countItemsArr[compnyID][index] = countItemsArr[compnyID][index] - 1;

            if (countItemsArr[compnyID][index] == 1) {
              products[compnyID][index]["product_price"] = (products[compnyID][index]["main_price"]).toString();
            } else {
              products[compnyID][index]["product_price"] = (double.parse(countItemsArr[compnyID][index].toString()) * double.parse(products[compnyID][index]["main_price"])).toString();
            }

          }
          notifyListeners();

        }
    }

  }
  showLoadingFun(BuildContext context) {
    if (showLoading) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: Image.asset("assets/images/cardLoading.gif", width: 280, height: 280, fit: BoxFit.cover,),
            );
          });
    } else {
      Navigator.pop(context);

      return;
    }
  }

  showLoadingFunSimple(BuildContext context) {
    if (showLoadingSimple) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    } else {
      Navigator.pop(context);

      return;
    }
  }




  getUserTextSize () async {
    var getSize = await userInfo.getUserTextSize();

    if (getSize == "empty") {
      textSize = 14;
    } else {
      textSize = int.parse(getSize);
    }
  }

  ///
  validateAndCheck(BuildContext context, index, String companyId,  Function() setTheState) async {

    final companyEditName = TextEditingController();

    var displayCards = null;

    List displayCardsNumbers = [];
    List displayCardsSerials = [];
    List displayCardsDate = [];

    var myState;
    var dailogState;

    var mainQuantity = countItemsArr[companyId][index];
    var mainPrice = products[companyId][index]['product_price'];
    var buyResult = "";

    var printerClass = new printer();
    var checkConnection = await printerClass.connectToPrinter();

    var shippingMethod = "";
    var getCompanyImage = "";
    var getCompanyName = "";
    bool stopBuyer = false;

    //  var checkConnection = "connected";
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("إلغاء", style: TextStyle(color: HexColor("#F65D12"),),),
      onPressed:  () {


          countItemsArr[companyId][index] = mainQuantity;
          products[companyId][index]['product_price'] = mainPrice;
          buyResult = "";

          notifyListeners();



        Navigator.pop(context);
      },
    );
    Widget continueButton = Consumer<UserInfoProvider>(builder: (context, user, child) => TextButton(
      child: Text(AppLocalizations.of(context).sure_buy, style: TextStyle(color: HexColor("#F65D12"),),),
      onPressed:  () async {
        print("now buying ${DateTime.now().toString()}");

        showLoading = true;

        notifyListeners();
        showLoadingFun(context);
        productsCartsController card = new productsCartsController(productsCartsController_productId: products[companyId][index]['docid'], productsCartsController_howmany: countItemsArr[companyId][index].toString());
        var buyTheCards = await card.buyTheCard2(
          getMyStoreOfStoresPrice: user.getMyStoreOfStoresPrice,
          getMyWhichPrice: user.getMyWhichPrice,
          myStoreOfStoreId: user.myStoreOfStoreId,
          storeId: user.myId,
          userActive: user.userActive,
          userExist: user.userExist,
        );
        // var buyTheCards = await card.buyTheCard();
        myState(() {
          displayCards = buyTheCards;
          displayCardsNumbers = buyTheCards['saveCradsNumbers'];
          displayCardsSerials = buyTheCards['saveCradsSerial'];
          displayCardsDate = buyTheCards['saveCardsExpiryDate'];
          print("displayCards");
          print(displayCards);
        });

        print ("getting the company details ${DateTime.now().toString()}");
        if (buyTheCards['status'] == "success") {
          var company = await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .get();
          print ("got the company details ${DateTime.now().toString()}");

          shippingMethod = company.get("companies_shippingCompanyMethod");

          getCompanyImage = company.get("companies_printinglogo");

          getCompanyName = company.get("companies_name");

          myState(() {
            buyResult = AppLocalizations.of(context).sure_buy_ok;
          });

          dailogState((){
            stopBuyer = true;
          });

          //  var printerClass = new printer();
          // var checkConnection = await printerClass.connectToPrinter();
          if (checkConnection == "notconnected") {
            // myState(() {
            //   buyResult = "تم الشراء لست موصول بالطابعة";
            // });
          }
          else if (checkConnection == "connected") {

            for (var i = 0; i < countItemsArr[companyId][index]; i = i + 1) {
              try {
                var value = await platform.invokeMethod('print', {
                  "companyImage": getCompanyImage,
                  "productName": products[companyId][index]['product_name'],
                  "textSize": textSize,
                  "productNumber": buyTheCards['saveCradsNumbers'][i],
                  "product_broughtDate": buyTheCards["broughtDate"],
                  "productSerial": buyTheCards['saveCradsSerial'][i],
                  "product_expiryDate": products[companyId][index]['product_expiryDate'],
                  "product_shippingMethod": shippingMethod,
                });
              } on PlatformException catch (e) {

              }
            }
            myState(() {
              buyResult = AppLocalizations.of(context).sure_buy_print;
            });


          }
        } else if (buyTheCards['status'] == "userNotActive") {
          myState(() {
            buyResult = AppLocalizations.of(context).cancel_enable_acount;
          });
        } else if (buyTheCards['status'] == "userNotExist") {
          myState(() {
            buyResult = AppLocalizations.of(context).delete_ok;
          });
        } else if (buyTheCards['status'] == "needMoreBalance") {
          myState(() {
            buyResult = AppLocalizations.of(context).price_not_engh;
          });
        } else if (buyTheCards['status'] == "notAvailableQuantity") {
          myState(() {
            buyResult = AppLocalizations.of(context).quantity_not_found;
          });
        } else if (buyTheCards['status'] == "lessThenZero") {
          myState(() {
            buyResult = AppLocalizations.of(context).quantity_less_zero ;
          });
        } else if (buyTheCards['status'] == "myStoreOfStoreNotExist") {
          myState(() {
            buyResult = AppLocalizations.of(context).not_found_merch;
          });
        }else {
          myState(() {
            buyResult = buyTheCards['status'];
          });
        }

        showLoading = false;
        notifyListeners();
        showLoadingFun(context);
        print("now loading will finish ${DateTime.now().toString()}");
        if (buyTheCards['status'] == "success") {

          myBalance["store_totalBalance"] = buyTheCards["newTotalBalance"];
          setTheState();
          notifyListeners();

          //Navigator.pop(context);


        }
        // Navigator.pop(context);
      },
    ),);


    // set up the AlertDialog
    Widget alert = StatefulBuilder(builder: (context, state) {
      quantityPlusMinus(index, '+', true, state, companyId);
      quantityPlusMinus(index, '-', true, state, companyId);
      return AlertDialog(
        backgroundColor: HexColor("#1B1B1D"),
        title: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1.0, color: Colors.white),
          ),
          child: Text(products[companyId][index]['product_name'], style: TextStyle(fontSize: 16,color: Colors.white,),),
        ),
        content: StatefulBuilder(
          // key: _scaffoldkeyValidate,
            builder: (BuildContext context, StateSetter state2) {
              myState = state2;
              dailogState = state ;
              return SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      quantityPlusMinus(index, '+', true, state, companyId);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 25,
                                      width: 25,
                                      child: Text('+',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30.0),
                                          color: HexColor("#F65D12")
                                      ),
                                    ),
                                  ),
                                  // Quantity
                                  Container(
                                    height: 25,
                                    width: 25,
                                    margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: HexColor("#C0A7C1")),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(countItemsArr[companyId][index].toString(), style: TextStyle(fontSize: 14,color: HexColor("#F65D12"),)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      quantityPlusMinus(index, '-', true, state, companyId);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 25,
                                      width: 25,
                                      child: Text('-',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30.0),
                                          color: HexColor("#F65D12")
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              flex: 5,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(right: 5,),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(products[companyId][index]["product_price"] + " SAR", textDirection: TextDirection.ltr, style: TextStyle(fontWeight:FontWeight.bold, fontSize: 12,color: Colors.white,)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(width: 1.0, color: Colors.white),
                                  //borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 5, bottom: 10),
                        child: Text(AppLocalizations.of(context).alert_price, style: TextStyle(fontWeight:FontWeight.bold, fontSize: 12, color: HexColor("#F65D12"),)),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 5, bottom: 10),
                        child: Text(buyResult, style: TextStyle(fontWeight:FontWeight.bold, fontSize: 16, color: Colors.white,)),
                      ),

                      displayCardsNumbers.length != 0?
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(bottom: 10,),
                        child: Text(AppLocalizations.of(context).font_size_printer, style: TextStyle(color: HexColor("#F65D12"),),),
                      ) : Text(""),

                      displayCardsNumbers.length != 0?
                      Container(
                        margin: EdgeInsets.only(bottom: 10,),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                quantityPlusMinusTextSize('+', state);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 25,
                                child: Text('+',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: HexColor("#F65D12")
                                ),
                              ),
                            ),
                            // Quantity
                            Container(
                              height: 25,
                              width: 25,
                              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              decoration: BoxDecoration(
                                border: Border.all(color: HexColor("#C0A7C1")),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: Text(textSize.toString(), style: TextStyle(fontSize: 14,color: HexColor("#F65D12"),)),
                            ),
                            GestureDetector(
                              onTap: () {
                                quantityPlusMinusTextSize('-', state);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 25,
                                child: Text('-',style: TextStyle(fontWeight:FontWeight.bold, fontSize: 18,color: Colors.white,)),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: HexColor("#F65D12")
                                ),
                              ),
                            ),
                          ],
                        ),
                      ) : Text(""),

                      displayCardsNumbers.length != 0?
                      Container(
                        margin: EdgeInsets.only(bottom: 10,),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          //   mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 70,
                              child: RaisedButton(
                                padding: EdgeInsets.all(0),
                                child: Text(AppLocalizations.of(context).print_all,
                                  style: TextStyle(color: Colors.white, fontSize: 12,),),
                                color: HexColor("#F65D12"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius
                                      .circular(10),
                                ),
                                onPressed: () async {
                                  print("displayCards");
                                  print(displayCards);

                                  print("getCompanyImage");
                                  print(getCompanyImage);

                                  print("shippingMethod");
                                  print(shippingMethod);

                                  if (checkConnection == "notconnected") {
                                    myState(() {
                                      buyResult = AppLocalizations.of(context).printer_notconnected;
                                    });
                                  } else if (checkConnection == "connected") {

                                    showLoadingSimple = true;
                                    notifyListeners();
                                    showLoadingFunSimple(context);

                                    for (var i = 0; i < countItemsArr[companyId][index]; i = i + 1) {
                                      try {
                                        var value = await platform.invokeMethod('print', {
                                          "companyImage": getCompanyImage,
                                          "textSize": textSize,
                                          "productName": products[companyId][index]['product_name'],
                                          "productNumber": displayCards['saveCradsNumbers'][i],
                                          "product_broughtDate": displayCards["broughtDate"],
                                          "productSerial": displayCards['saveCradsSerial'][i],
                                          "product_expiryDate": displayCards['saveCardsExpiryDate'][i],
                                          "product_shippingMethod": shippingMethod,
                                        });
                                      } on PlatformException catch (e) {

                                      }
                                    }
                                    myState(() {
                                      buyResult = AppLocalizations.of(context).sure_buy_print;
                                    });


                                    showLoadingSimple = false;
                                    notifyListeners();
                                    showLoadingFunSimple(context);


                                  }
                                },
                              ),
                            ),

                            SizedBox(
                              width: 10,
                            ),

                            SizedBox(
                              width: 70,
                              child: RaisedButton(
                                padding: EdgeInsets.all(0),
                                child: Text(AppLocalizations.of(context).share_all,
                                  style: TextStyle(color: Colors.white, fontSize: 10,),),
                                color: HexColor("#F65D12"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius
                                      .circular(10),
                                ),
                                onPressed: () async {

                                  var textData = "";

                                  for (var i = 0; i < countItemsArr[companyId][index]; i = i + 1) {
                                    textData = textData +  "${AppLocalizations.of(context).name_cpmany}: " + getCompanyName + "\n${AppLocalizations.of(context).productName}: " + products[companyId][index]['product_name'] + "\n${AppLocalizations.of(context).cardNumber}: \n" + displayCards['saveCradsNumbers'][i].toString().split(" ").join("") +"\n${AppLocalizations.of(context).cardSerial}: \n" + displayCards['saveCradsSerial'][i].toString().split(" ").join("") +"\n${AppLocalizations.of(context).expiryDate} : " + displayCards['saveCardsExpiryDate'][i] + " \n \n \n --------------- \n \n \n ";
                                  }

                                  print(textData);

                                  sharingData(context, textData,
                                      textData);
                                },
                              ),
                            )


                          ],
                        ),
                      ):Container(child: Text(""),),

                      // Display The Cards
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 5, ),
                        child: Column(
                          children: displayCardsNumbers.length != 0?displayCardsNumbers.map((item) {

                            return Container(
                              child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.only(bottom: 5, ),
                                      child: Text(AppLocalizations.of(context).cardNumber+":", style: TextStyle(color: Colors.white, fontSize: 14,),),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.only(bottom: 10, ),
                                      child: Text(displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)], textDirection: TextDirection.ltr, textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14,),),
                                    ),

                                    Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.only(bottom: 5, ),
                                      child: Text(AppLocalizations.of(context).cardSerial+":", style: TextStyle(color: Colors.white, fontSize: 14,),),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.only(bottom: 10, ),
                                      child: Text(displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)], textDirection: TextDirection.ltr, textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14,),),
                                    ),

                                    Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.only(bottom: 5, ),
                                      child: Text(AppLocalizations.of(context).expiryDate+":", style: TextStyle(color: Colors.white, fontSize: 14,),),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.only(bottom: 10, ),
                                      child: Text(displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)], style: TextStyle(color: Colors.white, fontSize: 14,),),
                                    ),


                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      //   mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: RaisedButton(
                                            padding: EdgeInsets.all(0),
                                            child: Text(AppLocalizations.of(context).printer,
                                              style: TextStyle(color: Colors.white, fontSize: 10,),),
                                            color: HexColor("#F65D12"),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                            ),
                                            onPressed: () async {
                                              showLoadingSimple = true;
                                              notifyListeners();
                                              showLoadingFunSimple(context);

                                              /*print("getCompanyImage");
                                                print(getCompanyImage);

                                                print("products[compnyID][index]['product_name']");
                                                print(products[compnyID][index]['product_name']);

                                                print("displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)]");
                                                print(displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)]);

                                                print("displayCards['broughtDate']");
                                                print(displayCards["broughtDate"]);

                                                print("displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)]");
                                                print(displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)]);

                                                print("displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]");
                                                print(displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]);

                                                print("shippingMethod");
                                                print(shippingMethod);*/

                                              if (checkConnection == "notconnected") {
                                                myState(() {
                                                  buyResult = AppLocalizations.of(context).printer_notconnected;
                                                });
                                              } else if (checkConnection == "connected") {
                                                try {
                                                  var value = await platform.invokeMethod('print', {
                                                    "companyImage": getCompanyImage,
                                                    "textSize": textSize,
                                                    "productName": products[companyId][index]['product_name'],
                                                    "productNumber": displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)],
                                                    "product_broughtDate": displayCards["broughtDate"],
                                                    "productSerial": displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)],
                                                    "product_expiryDate": displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)],
                                                    "product_shippingMethod": shippingMethod,
                                                  });
                                                } on PlatformException catch (e) {

                                                }
                                              }

                                              showLoadingSimple = false;
                                              notifyListeners();
                                              showLoadingFunSimple(context);
                                            },
                                          ),
                                        ),

                                        SizedBox(
                                          width: 10,
                                        ),

                                        SizedBox(
                                          width: 70,
                                          child: RaisedButton(
                                            padding: EdgeInsets.all(0),
                                            child: Text(AppLocalizations.of(context).share,
                                              style: TextStyle(color: Colors.white, fontSize: 10,),),
                                            color: HexColor("#F65D12"),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                            ),
                                            onPressed: () async {
                                              sharingData(context, "${AppLocalizations.of(context).name_cpmany}: " + getCompanyName + "\n${AppLocalizations.of(context).productName}: " + products[companyId][index]['product_name'] + "\n${AppLocalizations.of(context).cardNumber}: \n" + displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\n${AppLocalizations.of(context).cardSerial}: \n" + displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\n${AppLocalizations.of(context).expiryDate}: " + displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)],
                                                  "${AppLocalizations.of(context).name_cpmany}: " + getCompanyName + "\n${AppLocalizations.of(context).productName}: " + products[companyId][index]['product_name'] + "\n${AppLocalizations.of(context).cardNumber}: \n" + displayCards['saveCradsNumbers'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\n${AppLocalizations.of(context).cardSerial}: \n" + displayCards['saveCradsSerial'][displayCards['saveCradsNumbers'].indexOf(item)].toString().split(" ").join("") + "\n${AppLocalizations.of(context).expiryDate} : " + displayCards['saveCardsExpiryDate'][displayCards['saveCradsNumbers'].indexOf(item)]);
                                            },
                                          ),
                                        )


                                      ],
                                    ),

                                  ]
                              ),
                            );
                          }).toList(): [],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

        actions: displayCardsNumbers.length != 0 ? [cancelButton]:[
          cancelButton,
          continueButton,
        ],
      );
    });

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

   validate2 (BuildContext context, String comID, int index ){
     showDialog(context: context, builder: (BuildContext context){
      return Consumer<UserInfoProvider>(
        builder: (context, user, child) =>  StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('stores').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> userData){
            var userData2 = userData.data.docs.firstWhere((element) => element.id == user.myId).data();
            var currentProduct = products[comID][index];
            return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cards')
                    .where("card_sellingStatus", isEqualTo: "false")
                    .where("card_status", isEqualTo: "true")
                    .where("card_productId", isEqualTo: products[comID][index]['docid']).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> cards){
                  List<QueryDocumentSnapshot> cards2 = cards.data.docs;
                  print ("available cards are ${cards2.first.data()}");
                  return Container();
                });
            }),
      );
    });
  }








}