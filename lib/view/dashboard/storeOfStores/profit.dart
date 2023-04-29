// @dart=2.11


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storeapp/actions/scrollToTop.dart';
import 'package:storeapp/alerts/exitAlertMessage.dart';
import 'package:storeapp/controller/balance.dart';
import 'package:storeapp/controller/profit.dart';
import 'package:storeapp/includes/appBar.dart';
import 'package:storeapp/includes/asideMenu.dart';
import 'package:storeapp/includes/bottomBar.dart';

import '../../colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class profit extends StatefulWidget {
  profitState createState() => profitState();
}

class profitState extends State  {

  var showLoading = false;
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

  ScrollToTop scrolling = ScrollToTop();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    getTheDataVar = getProfitRequestsData();
  }


  /* Get Data */
  List profit_nothing = [];
  List profit_pending = [];
  List profit_accepted = [];
  double totalProfit_nothing = 0;
  double totalProfit_pending = 0;
  double totalProfit_accepted = 0;
  bool hasProfit = false;
  getProfitRequestsData () async {
    profitController profit = new profitController();
    var profitRequestsFun = await profit.getMyProfit();


    setState(() {
      profit_nothing = profitRequestsFun['profit_nothing'];
      profit_pending = profitRequestsFun['profit_pending'];

      profit_accepted = profitRequestsFun['profit_accepted'];

      if (profitRequestsFun['totalProfit_nothing'].toString() != "") {
        totalProfit_nothing = profitRequestsFun['totalProfit_nothing'];
        if (totalProfit_nothing.toString() != "0.0") {
          hasProfit = true;
        }
      }

      if (profitRequestsFun['totalProfit_pending'].toString() != "") {
        totalProfit_pending = profitRequestsFun['totalProfit_pending'];
      }

      if (profitRequestsFun['totalProfit_accepted'].toString() != "") {
        totalProfit_accepted = profitRequestsFun['totalProfit_accepted'];
      }
    });
    return profitRequestsFun;
  }

  /* Request Balance */
  requestYourProfit(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).cancel),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context).request),
      onPressed:  () async {
        setState(() {
          showLoading = true;
        });
        showLoadingFun(context);

        profitController cardsClass = new profitController();
        var requestProfit = await cardsClass.requestMyProfit();

        if (requestProfit['status'] == "success") {
          setState(() {
            profit_pending = profit_nothing + profit_pending;

            profit_nothing = [];
            totalProfit_pending = totalProfit_pending + totalProfit_nothing;
            totalProfit_nothing = 0;
          });

          setState(() {
            showLoading = false;
          });
          showLoadingFun(context);

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).request_ok),
            duration: Duration(seconds: 5),
          ));



          Navigator.pop(context);

          Navigator.pushNamed(context, '/profit');
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).request_earn),
      content: Text(AppLocalizations.of(context).sum_earn+": " + totalProfit_nothing.toString()),
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

  Future getTheDataVar;

  displayRequestsData ({List data}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
            showBottomBorder: true,
            dividerThickness: 5.0,
            dataRowHeight: 100,
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
                  AppLocalizations.of(context).name_card,
                  style: TextStyle(),
                ),
              ),
              DataColumn(
                label: Text(
                  AppLocalizations.of(context).image_card,
                  style: TextStyle(),
                ),
              ),
              DataColumn(
                label: Text(
                  AppLocalizations.of(context).price_buy,
                  style: TextStyle(),
                ),
              ),
              DataColumn(
                label: Text(
                  AppLocalizations.of(context).earn_buy,
                  style: TextStyle(),
                ),
              ),
              DataColumn(
                label: Text(
                  AppLocalizations.of(context).date_buy,
                  style: TextStyle(),
                ),
              ),
              DataColumn(
                label: Text(
                  AppLocalizations.of(context).name_store,
                  style: TextStyle(),
                ),
              ),
            ],
            rows: data.map((item) =>
                DataRow(
                    cells: <DataCell>[
                      DataCell(
                          Container(
                            child: Text((data.indexOf(item) + 1).toString(), textScaleFactor: 1,),
                            padding: EdgeInsets.all(5),
                          )
                      ),
                      DataCell(
                          Container(
                            child: Text(item['card_date'].toString(), textScaleFactor: 1,),
                            padding: EdgeInsets.all(5),
                          )
                      ),
                      DataCell(
                          Container(
                            child: Text(item['card_productName'].toString(), textScaleFactor: 1,),
                            padding: EdgeInsets.all(5),
                          )
                      ),
                      DataCell(
                          Container(
                            child: Image.network(
                              item["card_productImage"],
                              fit: BoxFit.fill,
                            ),
                            padding: EdgeInsets.all(5),
                            width: 100,
                            height: 300,
                          )
                      ),
                      DataCell(
                          Container(
                            child: Text(item['card_BroughtPrice'].toString(), textScaleFactor: 1,),
                            padding: EdgeInsets.all(5),
                          )
                      ),
                      DataCell(
                          Container(
                            child: Text(item['card_storeOfStoreProfit'].toString(), textScaleFactor: 1,),
                            padding: EdgeInsets.all(5),
                          )
                      ),
                      DataCell(
                          Container(
                            child: Text(item['card_broughtDate'].toString(), textScaleFactor: 1,),
                            padding: EdgeInsets.all(5),
                          )
                      ),
                      DataCell(
                          Container(
                            child: Text(item['card_whoBroughtName'].toString(), textScaleFactor: 1,),
                            padding: EdgeInsets.all(5),
                          )
                      ),
                    ]
                )
            ).toList()
        ),
      ),

    );
  }

  var taha = "Taha";
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
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                      AppLocalizations.of(context).earn_card,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      textAlign: TextAlign.right
                  ),
                ),

                FutureBuilder(
                  future: getTheDataVar,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData == false) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 5, top: 50),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return Column(
                        children: [



                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 30, bottom: 30),
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text(AppLocalizations.of(context).earn, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                        ),
                                        Container(
                                          child: Text(totalProfit_nothing.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 30, bottom: 30),
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text(AppLocalizations.of(context).earn_wait, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                        ),
                                        Container(
                                          child: Text(totalProfit_pending.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                            ),
                          ),

                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 30, bottom: 30),
                                    decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Text(AppLocalizations.of(context).earn_done, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                        ),
                                        Container(
                                          child: Text(totalProfit_accepted.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white,),),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          hasProfit == true? Container(
                            margin: EdgeInsets.only(bottom: 10),
                            width: double.infinity,
                            child: RaisedButton(
                              onPressed: () async {
                                await requestYourProfit(context);
                              },
                              child: Text(AppLocalizations.of(context).requst_sum_earn, style: TextStyle(color: Colors.white,),),
                              color: secondColor,
                            ),
                          ) : Text(""),



                          Container(
                            height: 400,
                            width: double.infinity,
                            child: DefaultTabController(
                              length: 3,
                              child: new Scaffold(
                                appBar: new PreferredSize(
                                  preferredSize: Size.fromHeight(kToolbarHeight),
                                  child: new Container(
                                    height: 50.0,
                                    child: new TabBar(
                                      tabs: [
                                        Tab(text: AppLocalizations.of(context).earn_add,),
                                        Tab(text: AppLocalizations.of(context).earn_wait,),
                                        Tab(text: AppLocalizations.of(context).earn_done),
                                      ],
                                    ),
                                  ),
                                ),
                                body: TabBarView(
                                  children: [
                                    profit_nothing.length != 0?displayRequestsData(data: profit_nothing): Container(alignment: Alignment.center, child: Text(AppLocalizations.of(context).no_eran),),
                                    profit_pending.length != 0?displayRequestsData(data: profit_pending): Container(alignment: Alignment.center, child: Text(AppLocalizations.of(context).no_earn_wait),),
                                    profit_accepted.length != 0?displayRequestsData(data: profit_accepted): Container(alignment: Alignment.center, child: Text(AppLocalizations.of(context).no_earn_ok),),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),

              ],
            ),
          )
      ),
      floatingActionButton: scrolling.buttonLayout()
    );
  }
}

