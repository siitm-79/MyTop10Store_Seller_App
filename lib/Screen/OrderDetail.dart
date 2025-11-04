import 'dart:async';
import 'dart:io';
import 'package:eshopmultivendor/Helper/AppBtn.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:eshopmultivendor/Model/OrdersModel/OrderItemsModel.dart';
import 'package:eshopmultivendor/Model/OrdersModel/OrderModel.dart';
import 'package:eshopmultivendor/Model/Person/PersonModel.dart';
import 'package:eshopmultivendor/Screen/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetail extends StatefulWidget {
  // final Order_Model? model;
  // final Function? updateHome;
  final String? id;

  const OrderDetail({
    Key? key,
    // this.model,
    // this.updateHome,
    this.id,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

List<PersonModel> delBoyList = [];

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController controller = new ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  
  void setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
    ));
  }
  
  Future<void> updateOrder(String? status, Uri api, String? id, bool item, int index) async {
    // Implementation for updating order
    setState(() {
      // Update order logic would go here
    });
  }
  
  Widget shippingDetails() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Shipping details would be displayed here"),
      ),
    );
  }
  
  Widget productItem(Order_Model model) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Product Item", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Product details would be displayed here"),
          ],
        ),
      ),
    );
  }
  
  Widget bankProof(Order_Model model) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bank Proof", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Bank proof details would be displayed here"),
          ],
        ),
      ),
    );
  }

  Order_Model? model;
  String? pDate, prDate, sDate, dDate, cDate, rDate;
  List<String> statusList = [
    PLACED,
    PROCESSED,
    SHIPED,
    DELIVERD,
    CANCLED,
    RETURNED,
  ];
  bool isLoading = true;

  List<Order_Model> tempList = [];
  bool? _isCancleable, _isReturnable;
  bool _isProgress = false;
  String? curStatus;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController? otpC;
  final List<DropdownMenuItem> items = [];
  List<PersonModel> searchList = [];
  // String? selectedValue;
  int? selectedDelBoy;
  final TextEditingController _controller = TextEditingController();
  late StateSetter delBoyState;
  bool fabIsVisible = true;

  @override
  void initState() {
    super.initState();
    getDeliveryBoy();
    Future.delayed(Duration.zero, this.getOrderDetail);
    controller = ScrollController();
    controller.addListener(
          () {
        setState(
              () {
            fabIsVisible = controller.position.userScrollDirection ==
                ScrollDirection.forward;
          },
        );
      },
    );
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = new Tween(
      begin: width * 0.7,
      end: 50.0,
    ).animate(
      new CurvedAnimation(
        parent: buttonController!,
        curve: new Interval(
          0.0,
          0.150,
        ),
      ),
    );
    _controller.addListener(
          () {
        searchOperation(_controller.text);
      },
    );
  }

//==============================================================================
//========================= getDeliveryBoy API =================================

  Future<void> getDeliveryBoy() async {
    CUR_USERID = await getPrefrence(Id);
    var parameter = {
      SellerId: CUR_USERID,
    };

    apiBaseHelper.postAPICall(getDeliveryBoysApi, parameter).then(
          (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          delBoyList.clear();
          var data = getdata["data"];
          delBoyList = (data as List)
              .map((data) => new PersonModel.fromJson(data))
              .toList();
        } else {
          setSnackbar(msg!);
        }
      },
      onError: (error) {
        setSnackbar(error.toString());
      },
    );
  }

  Future<Null> getOrderDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      CUR_USERID = await getPrefrence(Id);
      var parameter = {
        SellerId: CUR_USERID,
        Id: widget.id,
      };
      apiBaseHelper.postAPICall(getOrdersApi, parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];

          if (!error) {
            var data = getdata["data"];
            if (data.length != 0) {
              tempList = (data as List)
                  .map((data) => new Order_Model.fromJson(data))
                  .toList();

              for (int i = 0; i < tempList[0].itemList!.length; i++)
                tempList[0].itemList![i].curSelected =
                    tempList[0].itemList![i].status;
              searchList.isEmpty
                  ? searchList.addAll(delBoyList)
                  : print("cool");

              if (tempList[0].itemList![0].deliveryBoyId != null)
                selectedDelBoy = delBoyList.indexWhere(
                        (f) => f.id == tempList[0].itemList![0].deliveryBoyId);

              if (selectedDelBoy == -1) selectedDelBoy = null;

              if (tempList[0].payMethod == "Bank Transfer") {
                statusList.removeWhere((element) => element == PLACED);
              }
              curStatus = tempList[0].itemList![0].activeStatus!;
              if (tempList[0].listStatus!.contains(PLACED)) {
                pDate = tempList[0]
                    .listDate![tempList[0].listStatus!.indexOf(PLACED)];

                if (pDate != null) {
                  List d = pDate!.split(" ");
                  pDate = d[0] + "\n" + d[1];
                }
              }
              if (tempList[0].listStatus!.contains(PROCESSED)) {
                prDate = tempList[0]
                    .listDate![tempList[0].listStatus!.indexOf(PROCESSED)];
                if (prDate != null) {
                  List d = prDate!.split(" ");
                  prDate = d[0] + "\n" + d[1];
                }
              }
              if (tempList[0].listStatus!.contains(SHIPED)) {
                sDate = tempList[0]
                    .listDate![tempList[0].listStatus!.indexOf(SHIPED)];
                if (sDate != null) {
                  List d = sDate!.split(" ");
                  sDate = d[0] + "\n" + d[1];
                }
              }
              if (tempList[0].listStatus!.contains(DELIVERD)) {
                dDate = tempList[0]
                    .listDate![tempList[0].listStatus!.indexOf(DELIVERD)];
                if (dDate != null) {
                  List d = dDate!.split(" ");
                  dDate = d[0] + "\n" + d[1];
                }
              }
              if (tempList[0].listStatus!.contains(CANCLED)) {
                cDate = tempList[0]
                    .listDate![tempList[0].listStatus!.indexOf(CANCLED)];
                if (cDate != null) {
                  List d = cDate!.split(" ");
                  cDate = d[0] + "\n" + d[1];
                }
              }
              if (tempList[0].listStatus!.contains(RETURNED)) {
                rDate = tempList[0]
                    .listDate![tempList[0].listStatus!.indexOf(RETURNED)];
                if (rDate != null) {
                  List d = rDate!.split(" ");
                  rDate = d[0] + "\n" + d[1];
                }
              }
              model = tempList[0];
              _isCancleable = model!.isCancleable == "1" ? true : false;
              _isReturnable = model!.isReturnable == "1" ? true : false;
            } else {
              setSnackbar(msg!);
            }
            setState(
                  () {
                isLoading = false;
              },
            );
          } else {}
        },
        onError: (error) {
          setSnackbar(error.toString());
        },
      );
    } else {
      if (mounted)
        setState(
              () {
            _isNetworkAvail = false;
          },
        );
    }

    return null;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, "TRY_AGAIN_INT_LBL")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(Duration(seconds: 2)).then(
                      (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => super.widget));
                    } else {
                      await buttonController!.reverse();
                      setState(
                            () {},
                      );
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    print(delBoyList);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(getTranslated(context, "ORDER_DETAIL")!, context),
      floatingActionButton: AnimatedOpacity(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // FloatingActionButton(
            //   backgroundColor: white,
            //   child: Image.asset(
            //     'assets/images/whatsapp.png',
            //     width: 25,
            //     height: 25,
            //     color: primary,
            //   ),
            //   onPressed: () async {
            //     String text =
            //         'Hello ${tempList[0].name},\nYour order with id : ${tempList[0].id} is ${tempList[0].itemList![0].activeStatus}. If you have further query feel free to contact us.Thank you.';
            //     await launch(
            //         "https://wa.me/${tempList[0].countryCode! + "" + tempList[0].mobile!}?text=$text");
            //   },
            //   heroTag: null,
            // ),
            SizedBox(
              height: 10,
            ),
            // FloatingActionButton(
            //   backgroundColor: white,
            //   child: Icon(
            //     Icons.message,
            //     color: primary,
            //   ),
            //   onPressed: () async {
            //     String text =
            //         'Hello ${tempList[0].name},\nYour order with id : ${tempList[0].id} is ${tempList[0].itemList![0].activeStatus}. If you have further query feel free to contact us.Thank you.';
            //
            //     var uri = 'sms:${tempList[0].mobile}?body=$text';
            //     await launch(uri);
            //   },
            //   heroTag: null,
            // )
          ],
        ),
        duration: Duration(milliseconds: 100),
        opacity: fabIsVisible ? 1 : 0,
      ),
      body: _isNetworkAvail
          ? WillPopScope(
        onWillPop: onWill,
        child: Stack(
          children: [
            isLoading
                ? shimmer()
                : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Card(
                            elevation: 0,
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        getTranslated(context,
                                            "ORDER_ID_LBL")! +
                                            " - ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall! // Changed from subtitle2
                                            .copyWith(color: grey),
                                      ),
                                      Text(
                                        model!.id!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall! // Changed from subtitle2
                                            .copyWith(color: black),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        getTranslated(context,
                                            "ORDER_DATE")! +
                                            " - ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall! // Changed from subtitle2
                                            .copyWith(color: grey),
                                      ),
                                      Text(
                                        model!.orderDate!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall! // Changed from subtitle2
                                            .copyWith(color: black),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        getTranslated(context,
                                            "PAYMENT_MTHD")! +
                                            " - ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall! // Changed from subtitle2
                                            .copyWith(color: grey),
                                      ),
                                      Text(
                                        model!.payMethod!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall! // Changed from subtitle2
                                            .copyWith(color: black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          model!.delDate != null &&
                              model!.delDate!.isNotEmpty
                              ? Card(
                            elevation: 0,
                            child: Padding(
                              padding:
                              const EdgeInsets.all(12.0),
                              child: Text(
                                getTranslated(context,
                                    "PREFER_DATE_TIME")! +
                                    ": " +
                                    model!.delDate! +
                                    " - " +
                                    model!.delTime!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall! // Changed from subtitle2
                                    .copyWith(
                                    color: lightBlack2),
                              ),
                            ),
                          )
                              : Container(),
                          //iteam's here
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: model!.itemList!.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, i) {
                              OrderItem orderItem =
                              model!.itemList![i];
                              return productItem(
                                  orderItem, model!, i);
                            },
                          ),
                          //complete
                          model!.payMethod == "Bank Transfer"
                              ? bankProof(model!)
                              : Container(),
                          shippingDetails(),
                          priceDetails(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            showCircularProgress(_isProgress, primary),
          ],
        ),
      )
          : noInternet(context),
    );
  }

  Future<bool> onWill() async {
    Navigator.pop(context, true);
    return Future.value();
  }

  Future<void> searchOperation(String searchText) async {
    searchList.clear();
    for (int i = 0; i < delBoyList.length; i++) {
      PersonModel map = delBoyList[i];

      if (map.name!.toLowerCase().contains(searchText)) {
        searchList.add(map);
      }
    }

    if (mounted) delBoyState(() {});
  }

  Future<void> delboyDialog(String status, int index) async {
    int itemindex = index;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                delBoyState = setStater;
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        5.0,
                      ),
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
                        child: Text(
                          getTranslated(context, "SELECTDELBOY")!,
                          style: Theme.of(this.context)
                              .textTheme
                              .titleMedium! // Changed from subtitle1
                              .copyWith(color: fontColor),
                        ),
                      ),
                      TextField(
                        controller: _controller,
                        autofocus: false,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                          prefixIcon: Icon(Icons.search, color: primary, size: 17),
                          hintText: getTranslated(context, "Search")!,
                          hintStyle: TextStyle(color: primary.withOpacity(0.5)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                        ),
                      ),
                      Divider(color: lightBlack),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: () {
                              return searchList
                                  .asMap()
                                  .map(
                                    (index, element) => MapEntry(
                                  index,
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      isLoading = true;
                                      if (mounted) {
                                        selectedDelBoy = index;
                                        updateOrder(status, updateOrderItemApi,
                                            model!.id, true, itemindex);
                                        setState(
                                              () {},
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: double.maxFinite,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          searchList[index].name!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  .values
                                  .toList();
                            }(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  List<Widget> getLngList() {
    return searchList
        .asMap()
        .map(
          (index, element) => MapEntry(
        index,
        InkWell(
          onTap: () {
            if (mounted)
              setState(() {
                selectedDelBoy = index;
                Navigator.of(context).pop();
              });
          },
          child: Container(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                searchList[index].name!,
              ),
            ),
          ),
        ),
      ),
    )
        .values
        .toList();
  }

  otpDialog(String? curSelected, String? otp, String? id, bool item,
      int index) async {
    otpC = TextEditingController(text: otp); // Added initialization for otpC
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, "OTP_LBL")!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .titleMedium! // Changed from subtitle1
                                  .copyWith(color: fontColor),
                            )),
                        Divider(color: lightBlack),
                        Form(
                            key: _formkey,
                            child: new Column(
                              children: <Widget>[
                                Padding(
                                    padding:
                                    EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      validator: (String? value) {
                                        if (value!.length == 0)
                                          return getTranslated(
                                              context, "FIELD_REQUIRED")!;
                                        else if (value.trim() != otp)
                                          return getTranslated(
                                              context, "OTPERROR")!;
                                        else
                                          return null;
                                      },
                                      autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        hintText: getTranslated(
                                            context, "OTP_ENTER")!,
                                        hintStyle: Theme.of(this.context)
                                            .textTheme
                                            .titleMedium! // Changed from subtitle1
                                            .copyWith(
                                            color: lightBlack,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      controller: otpC,
                                    )),
                              ],
                            ))
                      ])),
              actions: <Widget>[
                new ElevatedButton(
                    child: Text(
                      getTranslated(context, "CANCEL")!,
                      style: Theme.of(this.context)
                          .textTheme
                          .bodySmall! // Changed from subtitle2
                          .copyWith(
                          color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                new ElevatedButton(
                  child: Text(
                    getTranslated(context, "SEND_LBL")!,
                    style: Theme.of(this.context)
                        .textTheme
                        .bodySmall! // Changed from subtitle2
                        .copyWith(
                        color: fontColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final form = _formkey.currentState!;
                    if (form.validate()) {
                      form.save();
                      setState(() {
                        Navigator.pop(context);
                      });
                      updateOrder(
                          curSelected, updateOrderItemApi, id, item, index);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  _launchMap(lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url =
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url =
      "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }

    await launch(url);
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  priceDetails() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Text(
                getTranslated(context, "PRICE_DETAIL")!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: primary, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(color: lightBlack),
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, "PRICE_LBL")!} :",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: lightBlack2),
                  ),
                  Text(
                    "$CUR_CURRENCY ${tempList.isNotEmpty ? (tempList[0].subTotal ?? '') : ''}",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: lightBlack2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

