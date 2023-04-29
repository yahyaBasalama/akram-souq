// @dart=2.11
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multiselect/multiselect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/actions/validateInputs.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/myStores.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';

import '../../../controller/NavigationService.dart';
import '../../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class myStores extends StatefulWidget {
  myStoresState createState() => myStoresState();
}

class myStoresState extends State  {

  ScrollToTop scrolling = ScrollToTop();

  /* Start Variables */
  var showLoading = false;
  var store_dropdownStoreType = 'محل فرعي';
  List<String> store_selectedStores = [];

  var store_dropdownGroupValueArray;
  var store_dropdownPriceType;
  var store_priceType = ['آجل-debit', 'cash-كاش'];

  var store_dropdownWhichPrice;
  var store_dropdownGroupValues = [  AppLocalizations.of(NavigationService.navigatorKey.currentContext).priceName+""+AppLocalizations.of(NavigationService.navigatorKey.currentContext).first, AppLocalizations.of(NavigationService.navigatorKey.currentContext).priceName+""+AppLocalizations.of(NavigationService.navigatorKey.currentContext).sconed, AppLocalizations.of(NavigationService.navigatorKey.currentContext).priceName+""+AppLocalizations.of(NavigationService.navigatorKey.currentContext).third, AppLocalizations.of(NavigationService.navigatorKey.currentContext).priceName+""+AppLocalizations.of(NavigationService.navigatorKey.currentContext).fourth];
  final store_cashBalance = TextEditingController();
  final store_name = TextEditingController();
  final store_userName = TextEditingController();
  final store_phoneNumber = TextEditingController();
  final store_email = TextEditingController();
  final store_companyName = TextEditingController();
  final store_address = TextEditingController();

  bool store_status = true;
  inputValidator validateInput = new inputValidator();
  List<String> getActiveStoresName = [];
  var getActiveStores = [];

  final storesSearch = TextEditingController();
  /* End Variables */

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldkeyEdit = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldkeytwo = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldkeyRetrieveBalance = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldkeyAddBalanceRemoveDepth = new GlobalKey<ScaffoldState>();

  clearFormData () {
    store_name.text = "";
    store_userName.text ="" ;
    store_phoneNumber.text = "";
    store_email.text = "";
    store_companyName.text = "";
    store_address.text = "";
    store_status = false;
  }

  /* Add New Edit */
  addNeworEdit ({String type, String id, index}) async {

    if (store_phoneNumber.text == "") {
      if (type == "edit") {
        _scaffoldkeyEdit.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).input_phone_number),
          duration: Duration(seconds: 2),
        ));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).input_phone_number),
          duration: Duration(seconds: 2),
        ));
      }
    } else if (store_userName.text == "") {
      if (type == "edit") {
        _scaffoldkeyEdit.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).input_username),
          duration: Duration(seconds: 2),
        ));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).input_username),
          duration: Duration(seconds: 2),
        ));
      }
    } else if (store_name.text == "") {
      if (type == "edit") {
        _scaffoldkeyEdit.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).input_storename),
          duration: Duration(seconds: 2),
        ));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).input_storename),
          duration: Duration(seconds: 2),
        ));
      }
    } else {


      setState(() {
        showLoading = true;
      });
      showLoadingFun(context);

      var store_StoreOfStoresPriceName = '';
      if (store_dropdownWhichPrice == store_dropdownGroupValues[0]) {
        store_StoreOfStoresPriceName = 'storesOfStoresPricesDifference_groupOne';
      } else if (store_dropdownWhichPrice == store_dropdownGroupValues[1]) {
        store_StoreOfStoresPriceName = 'storesOfStoresPricesDifference_groupTwo';
      } else if (store_dropdownWhichPrice == store_dropdownGroupValues[2]) {
        store_StoreOfStoresPriceName = 'storesOfStoresPricesDifference_groupThree';
      } else if (store_dropdownWhichPrice == store_dropdownGroupValues[3]) {
        store_StoreOfStoresPriceName = 'storesOfStoresPricesDifference_groupFour';
      }

      storesController storesClass = new storesController(
          store_id: id,
          store_storeType: "محل فرعي",
          store_StoreOfStoresPriceName: store_StoreOfStoresPriceName,
          store_priceType: store_dropdownPriceType,
          store_cashBalance: store_cashBalance.text,
          store_debtBalance: store_cashBalance.text,
          store_status: store_status.toString(),
          store_userName: store_userName.text,
          store_phoneNumber: store_phoneNumber.text,
          store_email: store_email.text,
          store_companyName: store_companyName.text,
          store_address: store_address.text,
          store_name: store_name.text,
          subStore: true,
      );

      var insertOrEdit = await storesClass.insertOrEdit(type: type);

      if (insertOrEdit["status"] == "inserted" || insertOrEdit["status"] == "edited") {

        if (insertOrEdit["status"] == "inserted") {

        }

        setState(() {


          var data = insertOrEdit;

          if (insertOrEdit["status"] == "inserted") {
            data['store_StoreOfStoresPriceName'] = store_dropdownWhichPrice;
            getStoresData.insert(0, data);
            getStoresDataSearch = getStoresData;
          } else if (insertOrEdit["status"] == "edited") {
            getStoresData[index]['store_StoreOfStoresPriceName'] = store_dropdownWhichPrice;
            getStoresData[index]['store_status'] = data['store_status'];
            getStoresData[index]['store_statusCheckBox'] = data['store_statusCheckBox'];
            getStoresData[index]['store_name'] = data['store_name'];
            getStoresData[index]['store_userName'] = data['store_userName'];
            getStoresData[index]['store_phoneNumber'] = data['store_phoneNumber'];
            getStoresData[index]['store_email'] = data['store_email'];
            getStoresData[index]['store_companyName'] = data['store_companyName'];
            getStoresData[index]['store_address'] = data['store_address'];
            getStoresData[index]['store_name'] = data['store_name'];

            clearFormData();
            store_status = true;
            getStoresDataSearch = getStoresData;
          }


        });

        if (type == "edit") {

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);
          return "edited";
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).add_ok),
            duration: Duration(seconds: 2),
          ));

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);
        }

      } else if (insertOrEdit["status"] == "phoneNumberExistBefore") {
        if (type == "edit") {
          _scaffoldkeyEdit.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).phone_numer_found),
            duration: Duration(seconds: 2),
          ));

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          return "phoneNumberExistBefore";
        } else {
          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).phone_numer_found),
            duration: Duration(seconds: 2),
          ));
        }
      } else if (insertOrEdit["status"] == "emailExistBefore") {
        if (type == "edit") {
          _scaffoldkeyEdit.currentState.showSnackBar(SnackBar(
            content: Text( AppLocalizations.of(context).email_found),
            duration: Duration(seconds: 2),
          ));

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          return "emailExistBefore";
        } else {
          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).email_found),
            duration: Duration(seconds: 2),
          ));
        }
      }  else if (insertOrEdit["status"] == "storeCannotAddOrEdit") {
        if (type == "edit") {
          _scaffoldkeyEdit.currentState.showSnackBar(SnackBar(
            content: Text( AppLocalizations.of(context).no_store_edite),
            duration: Duration(seconds: 2),
          ));

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          return "storeCannotAddOrEdit";
        } else {
          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text( AppLocalizations.of(context).no_store_add),
            duration: Duration(seconds: 2),
          ));
        }
      }
    }
  }

  /* Edit */
  edit(BuildContext context, index) async {

    setState(() {
      store_name.text = getStoresData[index]["store_name"];
      store_userName.text = getStoresData[index]["store_userName"];
      store_phoneNumber.text = getStoresData[index]["store_phoneNumber"];
      store_email.text = getStoresData[index]["store_email"];
      // store_dropdownGroupName = getStoresData[index]["store_storeGroupName"];
      store_companyName.text = getStoresData[index]["store_companyName"];
      store_address.text = getStoresData[index]["store_address"];

      store_dropdownWhichPrice = getStoresData[index]["store_StoreOfStoresPriceName"];

      if (getStoresData[index]["store_status"] == AppLocalizations.of(context).enable) {
        store_status = true;
        //  store_statusEdit = true;
      } else {
        store_status = false;
        // store_statusEdit = false;
      }
    });


    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).cancel),
      onPressed:  () {
        setState(() {
          clearFormData();

          store_status = true;
        });
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context).edite),
      onPressed:  () async {
        var edit = await addNeworEdit(type: "edit", index: index, id: getStoresData[index]['docid']);

        if (edit == "edited") {
          Navigator.pop(context);

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).edite_ok),
            duration: Duration(seconds: 2),
          ));
        }

      },
    );


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).update_data_march),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter state) {
            return Scaffold(
                backgroundColor: Colors.transparent,
                key: _scaffoldkeyEdit,
                body: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text(
                              AppLocalizations.of(context).chose_price,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.right
                          ),
                        ),

                        // Group Prices
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: store_dropdownWhichPrice,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              width: double.infinity,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String newValue) async {
                              state(() {
                                store_dropdownWhichPrice = newValue;
                              });
                            },
                            items: store_dropdownGroupValues
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),

                        Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row (
                              children: [
                                Checkbox(
                                  value: store_status,
                                  onChanged: (bool value) {
                                    state(() {
                                      store_status = value;
                                    });


                                  },
                                ),
                                Text( AppLocalizations.of(context).enable)
                              ],
                            )
                        ),



                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            controller: store_name,
                            //initialValue: '',
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).name_store,
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            controller: store_userName,
                            //initialValue: '',
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).username,
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                            ),
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                          //  textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9+]+'))],
                            autofocus: false,
                            controller: store_phoneNumber,
                            //initialValue: '',
                            decoration: InputDecoration(
                              hintText:  AppLocalizations.of(context).phonenumber,
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                            ),
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            //  textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            //inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9+]+'))],
                            autofocus: false,
                            controller: store_email,
                            //initialValue: '',
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).email,
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                            ),
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            controller: store_companyName,
                            //initialValue: '',
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).name_cpmany,
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                            ),
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            controller: store_address,
                            //initialValue: '',
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).address,
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                            ),
                          ),
                        ),
                      ],
                    ))
            );
          }),

      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }



  final addBlance = TextEditingController();
  final addRemoveDepthBlance = TextEditingController();
  var selectBalanceType;

  addRemoveDepthBalance (BuildContext context, index) {

    setState(() {
      showLoading = true;
    });
    showLoadingFun(context);

    setState(() {
      addBlance.text = '';
      addRemoveDepthBlance.text = '';
      selectBalanceType = store_priceType[0];
    });

    setState(() {
      showLoading = false;
    });
    showLoadingFun(context);

    final formBalanceIndebtednessGlobalKey = GlobalKey<FormState>();

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).cancel),
      onPressed:  () {
        setState(() {
          //clearFormData();
        });
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context).add),
      onPressed:  () async {

        if (addBlance.text == "" && addRemoveDepthBlance.text == "") {
          _scaffoldkeyAddBalanceRemoveDepth.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).alert_input_money),
            duration: Duration(seconds: 2),
          ));
          return;
        }
        
        if (formBalanceIndebtednessGlobalKey.currentState.validate()) {
          formBalanceIndebtednessGlobalKey.currentState.save();
          // use the email provided here
        } else {
          return;
        }

        setState(() {
          showLoading = true;
        });
        showLoadingFun(context);

        storesController storesClass = new storesController(
            store_id: getStoresData[index]['docid'],
            store_addBalance: addBlance.text.toString(),
            store_addDepthBalance: addRemoveDepthBlance.text.toString(),
            store_priceType: selectBalanceType,
            subStore: true
        );

        var updateBalance = await storesClass.addBalance();

        if (updateBalance["status"] == "updated") {
          setState(() {
            if (addBlance.text != "") {
              myBalance["store_totalBalance"] = (double.parse(myBalance["store_totalBalance"].toString()) - double.parse(addBlance.text)).toString();

              if (selectBalanceType == "آجل-debit") {
                getStoresData[index]['store_debtBalance'] = updateBalance['store_debtBalance'];
                getStoresData[index]['store_indebtedness'] = updateBalance['store_indebtedness'];
              } else if (selectBalanceType == "cash-كاش") {
                getStoresData[index]['store_cashBalance'] = updateBalance['store_cashBalance'];
              }

              var price = double.parse(getStoresData[index]['store_allBalance']) + double.parse(addBlance.text);
              getStoresData[index]['store_allBalance'] = price.toString();
            }

            if (addRemoveDepthBlance.text != "") {
              getStoresData[index]['store_indebtedness'] = updateBalance['store_indebtedness'];
            }

          });

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).add_ok),
            duration: Duration(seconds: 2),
          ));

          Navigator.pop(context);

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);
        } else if (updateBalance["status"] == "noAvailableBalance") {
          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          _scaffoldkeyAddBalanceRemoveDepth.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).not_price),
            duration: Duration(seconds: 2),
          ));



        } else if (updateBalance["status"] == "balanceLessThenZero") {
          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          _scaffoldkeyAddBalanceRemoveDepth.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).prce_less_zero),
            duration: Duration(seconds: 2),
          ));
        }


      },
    );


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).add_price),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              key:_scaffoldkeyAddBalanceRemoveDepth,
              body: SingleChildScrollView(
                  child: Column(
                    children: [

                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                            "كاش-cash" + " : " + getStoresData[index]['store_cashBalance'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.right
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                            "آجل-debit" + " : " + getStoresData[index]['store_debtBalance'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.right
                        ),
                      ),

                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                            AppLocalizations.of(context).sum + " : " + (double.parse(getStoresData[index]['store_cashBalance']) + double.parse(getStoresData[index]['store_debtBalance'])).toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.right
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                            AppLocalizations.of(context).indebtedness + " : " + getStoresData[index]['store_indebtedness'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.right
                        ),
                      ),

                      Form(
                        key: formBalanceIndebtednessGlobalKey,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                autofocus: false,
                                controller: addBlance,
                                //textAlign: TextAlign.left,
                                textDirection: TextDirection.ltr,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+'))],
                                //initialValue: '',
                                decoration: InputDecoration(
                                  hintText:  AppLocalizations.of(context).input_price,
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                                ),
                                validator: (val)  {
                                  var check = validateInput.validateDotsPrice(val);
                                  
                                  return check;
                                },
                              ),
                            ),


                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 10),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectBalanceType,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  width: double.infinity,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String newValue) async {
                                  setState(() {
                                    selectBalanceType = newValue;
                                  });


                                },
                                items: store_priceType
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                autofocus: false,
                                controller: addRemoveDepthBlance,
                             //   textAlign: TextAlign.left,
                                textDirection: TextDirection.ltr,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.-]+'))],
                                //initialValue: '',
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context).input_money_t,
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                                ),
                                validator: (val)  {
                                  var check = validateInput.validateDotsPrice(val);
                                  
                                  return check;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  )),
            );
          }),

      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  /* Start Retrieve Balance */
  final removeBalanceInput = TextEditingController();
  final formRetrieveGlobalKey = GlobalKey<FormState>();
  removeBalance (BuildContext context, index) {
    setState(() {
      showLoading = true;
    });
    showLoadingFun(context);

    setState(() {
      removeBalanceInput.text = '';
      selectBalanceType = store_priceType[0];
    });

    setState(() {
      showLoading = false;
    });
    showLoadingFun(context);

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).cancel),
      onPressed:  () {
        setState(() {
          //clearFormData();
        });
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context).return_price),
      onPressed:  () async {

        if (removeBalanceInput.text.toString() == "") {
          _scaffoldkeyRetrieveBalance.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).input_price),
            duration: Duration(seconds: 2),
          ));

          return "";
        }

        if (formRetrieveGlobalKey.currentState.validate()) {
          formRetrieveGlobalKey.currentState.save();
          // use the email provided here
        } else {

          return "";
        }

        setState(() {
          showLoading = true;
        });
        showLoadingFun(context);

        storesController storesClass = new storesController(
          store_id: getStoresData[index]['docid'],
          store_removeBalance: removeBalanceInput.text.toString(),
          store_priceType: selectBalanceType,
        );

        var removeBalance = await storesClass.retrieveBalance();

        if (removeBalance["status"] == "updated") {

          setState(() {
            myBalance["store_totalBalance"] = (double.parse(myBalance["store_totalBalance"].toString()) + double.parse(removeBalanceInput.text)).toString();
          });

          setState(() {
            if (selectBalanceType == "آجل-debit") {
              getStoresData[index]['store_debtBalance'] = removeBalance['store_debtBalance'];
            } else if (selectBalanceType == "كاش-cash") {
              getStoresData[index]['store_cashBalance'] = removeBalance['store_cashBalance'];
            }

            var price = double.parse(getStoresData[index]['store_allBalance']) - double.parse(removeBalanceInput.text);
            getStoresData[index]['store_allBalance'] = price.toString();
          });

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).return_ok),
            duration: Duration(seconds: 2),
          ));

          Navigator.pop(context);

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);
        } else if (removeBalance["status"] == "bigBalance" || removeBalance["status"] == "lessThanZero") {
          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          _scaffoldkeyRetrieveBalance.currentState.showSnackBar(SnackBar(
            content: Text(removeBalance["alert"]),
            duration: Duration(seconds: 2),
          ));
        }


      },
    );


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).return_price),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter state) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              key:_scaffoldkeyRetrieveBalance,
              body: SingleChildScrollView(
                  child: Column(
                    children: [

                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                            AppLocalizations.of(context).cash + " : " + getStoresData[index]['store_cashBalance'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.right
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                            AppLocalizations.of(context).debit + " : " + getStoresData[index]['store_debtBalance'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.right
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                            AppLocalizations.of(context).sum + " : " + (double.parse(getStoresData[index]['store_cashBalance']) + double.parse(getStoresData[index]['store_debtBalance'])).toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.right
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                            AppLocalizations.of(context).indebtedness+ " : " + getStoresData[index]['store_indebtedness'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.right
                        ),
                      ),

                      Form(
                        key: formRetrieveGlobalKey,
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            autofocus: false,
                            controller: removeBalanceInput,
                            //textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+'))],
                            //initialValue: '',
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).input_price,
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                            ),
                            validator: (val)  {
                              var check = validateInput.validateDotsPrice(val);
                              
                              return check;
                            },
                          ),
                        ),
                      ),


                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectBalanceType,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            width: double.infinity,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String newValue) async {
                            state(() {
                              selectBalanceType = newValue;
                            });


                          },
                          items: store_priceType
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                    ],
                  )
              ),
            );
          }),

      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }





  balanceHisotry (BuildContext context, index) async {

    setState(() {
      showLoading = true;
    });
    showLoadingFun(context);

    storesController storesClass = new storesController(
        store_id: getStoresData[index]['docid']
    );

    var balanceHistoryFun = await storesClass.getBalanceHistory();

    List balanceHistoryVar = [];

    setState(() {
      balanceHistoryVar = balanceHistoryFun;
    });

    setState(() {
      showLoading = false;
    });
    showLoadingFun(context);

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("إلغاء"),
      onPressed:  () {
        setState(() {
          // clearFormData();
        });
        Navigator.pop(context);
      },
    );


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).hostory_price_store),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView (
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            DataTable(
                                showBottomBorder: true,
                                dividerThickness: 5.0,
                                columns: <DataColumn>[
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).conter,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).date,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).money_send,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).type_mony,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).money_cash_befo_send,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).money_cash_after_send,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).money_debit_befo_send,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).money_debit_after_send,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).money_indebtedness_befo_send,
                                      style: TextStyle(),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      AppLocalizations.of(context).money_indebtedness_after_send,
                                      style: TextStyle(),
                                    ),
                                  ),
                                ],
                                rows: balanceHistoryVar.map((item) =>
                                    DataRow(
                                        cells: <DataCell>[
                                          DataCell(
                                              Container(
                                                child: Text((balanceHistoryVar.indexOf(item) + 1).toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_date'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_addPrice'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_priceType'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_beforeCashPrice'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_afterCashPrice'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_beforeDebtPrice'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_afterDebtPrice'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_BeforeIndebtednessPrice'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                          DataCell(
                                              Container(
                                                child: Text(item['balanceHistory_AfterIndebtednessPrice'].toString(), textScaleFactor: 1,),
                                                padding: EdgeInsets.all(5),
                                              )
                                          ),
                                        ]
                                    )
                                ).toList()
                            )
                          ],
                        ),
                      ),


                    ],

                  ),
                )
            );
          }),

      actions: [
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // getStoresDataFun();

    getTheDataVar = getStoresDataFun();

    // Price Type
    store_dropdownPriceType = store_priceType[0];
    store_dropdownWhichPrice = store_dropdownGroupValues[0];
  }


  List getStoresData = [];
  List getStoresDataSearch = [];
  var getTheDataVar;

  /* Get Data */
  getStoresDataFun () async {
    storesController storesClass = new storesController(subStore: true);



    var data = await storesClass.getAllData();

    setState(() {
      getStoresData = data;
      getStoresDataSearch = data;

      for (var i = 0; i < getStoresData.length; i = i + 1) {
        final dataKey = new GlobalKey();
        getStoresData[i]['dataKey'] = dataKey;

        getStoresData[i]['color'] = Colors.transparent;
      }
    });
    getStoresData = data;
    return getStoresData;

    /*  setState(() {
      showLoading = false;
    });
    showLoadingFun(context);*/

  }


  var store_getStores = Container();


  showLoadingFun(BuildContext context) {
    if (showLoading) {
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

  /* Activate Or Deactivate */
  activateOrDeactivate(BuildContext context, id, index, status, howMany, arrayOfId, state) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).cancel),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context).yes),
      onPressed:  () async {
        setState(() {
          showLoading = true;
        });
        showLoadingFun(context);

        storesController storeClass = new storesController(store_id: id, store_status: status.toString(), store_howMany: howMany, store_arrayOfStoresId: arrayOfId, subStore: true);
        var activateOrDeactivateVar = await storeClass.activateOrDeactivateStores();

        if (activateOrDeactivateVar['status'] == "edited") {
          Navigator.pop(context);

          if (status == true) {
            if (howMany == "all") {
              setState(() {
                getStoresData.map((item) {
                  item['store_status'] = AppLocalizations.of(context).enable;
                  item['store_statusCheckBox'] = true;
                }).toList();
              });

              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context).enable_ok),
                duration: Duration(seconds: 2),
              ));
            } else {
              setState(() {
                getStoresData[index]['store_status'] = AppLocalizations.of(context).enable;
                getStoresData[index]['store_statusCheckBox'] = true;
              });

              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context).enable_ok),
                duration: Duration(seconds: 2),
              ));
            }
          } else {

            if (howMany == "all") {
              setState(() {
                getStoresData.map((item) {
                  item['store_status'] = AppLocalizations.of(context).disenable;
                  item['store_statusCheckBox'] = false;
                }).toList();
              });

              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context).disenable_ok),
                duration: Duration(seconds: 2),
              ));
            } else {
              setState(() {
                getStoresData[index]['store_status'] = AppLocalizations.of(context).disenable;
                getStoresData[index]['store_statusCheckBox'] = false;
              });

              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context).disenable_ok),
                duration: Duration(seconds: 2),
              ));
            }

          }


          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);
        }
      },
    );

    String title;
    if (howMany == "all") {
      if (status == true) {
        title = AppLocalizations.of(context).are_enable_stores;
      } else if (status == false) {
        title = AppLocalizations.of(context).are_disenable_stores;
      }
    } else {
      if (status == true) {
        title = AppLocalizations.of(context).are_enable_store;
      } else if (status == false) {
        title = AppLocalizations.of(context).are_disenable_store;
      }
    }

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text( AppLocalizations.of(context).are_sure),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: _scaffoldKey,
      drawer: asideMenu(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: MenuBar(),
      ),
      bottomNavigationBar: bottomBar(context),
      body: SingleChildScrollView(
          controller: scrolling.returnTheVariable(),
          child: Container(
            margin: EdgeInsets.only(top: 15, left: 0), // (MediaQuery.of(context).size.height / 2)
            padding: const EdgeInsets.only(top: 100, bottom: 100, left: 10, right: 10),
            child: Column(
              children: [


                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      AppLocalizations.of(context).add_store,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
                  ),
                ),


                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      AppLocalizations.of(context).chose_price,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.right
                  ),
                ),

                // Group Prices
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: store_dropdownWhichPrice,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      width: double.infinity,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) async {
                      setState(() {
                        store_dropdownWhichPrice = newValue;
                      });
                    },
                    items: store_dropdownGroupValues
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),

                Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row (
                      children: [
                        Checkbox(
                          value: store_status,
                          onChanged: (bool value) {
                            setState(() {
                              store_status = value;
                            });
                          },
                        ),
                        Text( AppLocalizations.of(context).enable)
                      ],
                    )
                ),


                // Choose Price Type
                /*Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      "إختار نوع السعر",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.right
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: store_dropdownPriceType,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      width: double.infinity,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) async {
                      setState(() {
                        store_dropdownPriceType = newValue;
                      });


                    },
                    items: store_priceType
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+'))],
                    autofocus: false,
                    controller: store_cashBalance,
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText: 'السعر',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                    validator: (val)  {
                      var check = validateInput.validateDotsPrice(val);

                      if (val.length < 1) {
                        return "أضف سعر";
                      }
                      return check;
                    }
                  ),
                ),*/

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    controller: store_name,
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText:  AppLocalizations.of(context).input_storename,
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    controller: store_userName,
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).username,
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                 //   textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9+]+'))],
                    autofocus: false,
                    controller: store_phoneNumber,
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText:  AppLocalizations.of(context).phonenumber,
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    //   textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    //inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9+]+'))],
                    autofocus: false,
                    controller: store_email,
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText:  AppLocalizations.of(context).email,
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    controller: store_companyName,
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText:  AppLocalizations.of(context).name_cpmany,
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    controller: store_address,
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText:  AppLocalizations.of(context).address,
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),

                Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(bottom: 10),
                    child: RaisedButton(
                      child: Text( AppLocalizations.of(context).add_store, style: TextStyle(color: Colors.white,), ),
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: () async {
                        await addNeworEdit(type: "add");
                      },
                    )
                ),



                /* Start All Categories */
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                      AppLocalizations.of(context).all_stores,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    controller: storesSearch,
                    onChanged: (value) {
                      var results = [];
                      if (value.isEmpty) {
                        // if the search field is empty or only contains white-space, we'll display all users
                        results = getStoresDataSearch;
                      } else {
                        results = getStoresDataSearch
                            .where((doc) =>
                            doc.toString().toLowerCase().contains(value.toLowerCase()))
                            .toList();
                        // we use the toLowerCase() method to make it case-insensitive
                      }

                      // Refresh the UI
                      setState(() {
                        getStoresData = results;
                      });
                    },
                    //initialValue: '',
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).search,
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    ),
                  ),
                ),


                FutureBuilder(
                  future: getTheDataVar,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData == false) {
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return Container(
                          child: Text("")
                      );
                    }
                  },
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                      showBottomBorder: true,
                      dividerThickness: 5.0,

                      columns: <DataColumn>[
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).conter,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).name_store,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).shorcut,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).address_store,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).name_cpmany,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).username,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).phonenumber,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).email,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).name_price,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).price,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).indebtedness,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).price_debit,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).price_cash,
                            style: TextStyle(),
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).staus,
                                style: TextStyle(),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              TextButton.icon(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                  ),
                                  onPressed: () {
                                    activateOrDeactivate(context, '', '', true, 'all', [], null);
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  label: Text(AppLocalizations.of(context).all_enable, style: TextStyle(color: Colors.white, fontSize: 10),)
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              TextButton.icon(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    activateOrDeactivate(context, '', '', false, 'all', [], null);
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  label: Text(AppLocalizations.of(context).cancel_all_enable, style: TextStyle(color: Colors.white, fontSize: 10),)
                              ),
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            AppLocalizations.of(context).edite,
                            style: TextStyle(),
                          ),
                        ),
                      ],
                      rows: getStoresData.map((item) =>
                          DataRow(
                              cells: <DataCell>[
                                DataCell(
                                    Container(
                                      child: Text((getStoresData.indexOf(item) + 1).toString(), textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_name"], textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.monetization_on),
                                            color: Colors.green,
                                            onPressed: () async {
                                              addRemoveDepthBalance(context, getStoresData.indexOf(item));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_right),
                                            color: Colors.green,
                                            onPressed: () async {
                                              for (var i = 0; i < getStoresData.length; i = i + 1) {
                                                getStoresData[i]['color'] = Colors.transparent;
                                              }

                                              setState(() {
                                                item["color"] = Colors.green;
                                              });
                                              Scrollable.ensureVisible(item["dataKey"].currentContext);
                                            },
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_address"], textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_companyName"], textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_userName"], textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_phoneNumber"], textScaleFactor: 1, textDirection: TextDirection.ltr,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_email"], textScaleFactor: 1, textDirection: TextDirection.ltr,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_StoreOfStoresPriceName"], textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_allBalance"].toString(), textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_indebtedness"].toString(), textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_debtBalance"].toString(), textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                    Container(
                                      child: Text(item["store_cashBalance"].toString(), textScaleFactor: 1,),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                                DataCell(
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(item["store_status"], textScaleFactor: 1,),
                                        Checkbox(
                                          value: item["store_statusCheckBox"],
                                          onChanged: (bool value) {
                                            activateOrDeactivate(context, item['docid'], getStoresData.indexOf(item), value, '', [], null);
                                          },
                                        )
                                      ],
                                    ),
                                    padding: EdgeInsets.all(5),
                                  ),
                                ),
                                DataCell(
                                    Container(
                                      color: item['color'],
                                      child: Row(
                                        key: item["dataKey"],
                                        children: [
                                          TextButton.icon(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.lightBlue,
                                              ),
                                              onPressed: () {
                                                edit(context, getStoresData.indexOf(item));
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              label: Text(AppLocalizations.of(context).edite, style: TextStyle(color: Colors.white, fontSize: 12),)
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          TextButton.icon(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.lightBlue,
                                              ),
                                              onPressed: () {
                                                addRemoveDepthBalance(context, getStoresData.indexOf(item));
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              label: Text(AppLocalizations.of(context).alert_input_money, style: TextStyle(color: Colors.white, fontSize: 12),)
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          TextButton.icon(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.lightBlue,
                                              ),
                                              onPressed: () {
                                                removeBalance(context, getStoresData.indexOf(item));
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              label: Text(AppLocalizations.of(context).return_price, style: TextStyle(color: Colors.white, fontSize: 12),)
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          TextButton.icon(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.lightBlue,
                                              ),
                                              onPressed: () {
                                                balanceHisotry(context, getStoresData.indexOf(item));
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              label: Text(AppLocalizations.of(context).show_hostory_price, style: TextStyle(color: Colors.white, fontSize: 12),)
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(5),
                                    )
                                ),
                              ]
                          )
                      ).toList()
                  ),
                ),

              ],
            ),
          )
      ),
      floatingActionButton: scrolling.buttonLayout()
    );
  }
}

