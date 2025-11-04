import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart';
import 'package:eshopmultivendor/Helper/AppBtn.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/Constant.dart';
import 'package:eshopmultivendor/Helper/PushNotificationService.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:eshopmultivendor/Localization/Language_Constant.dart';
import 'package:eshopmultivendor/Model/CategoryModel/categoryModel.dart';
import 'package:eshopmultivendor/Model/OrdersModel/OrderModel.dart';
import 'package:eshopmultivendor/Model/ZipCodesModel/ZipCodeModel.dart';
import 'package:eshopmultivendor/Screen/Add_Product.dart';
import 'package:eshopmultivendor/Screen/Authentication/Login.dart';
import 'package:eshopmultivendor/Screen/TermFeed/Contact_Us.dart';
import 'package:eshopmultivendor/Screen/Customers.dart';
import 'package:eshopmultivendor/Screen/OrderList.dart';
import 'package:eshopmultivendor/Screen/TermFeed/Privacy_Policy.dart';
import 'package:eshopmultivendor/Screen/ProductList.dart';
import 'package:eshopmultivendor/Screen/WalletHistory.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/Color.dart';
import '../Helper/Indicator.dart';
import '../main.dart';
import 'Profile.dart';
import 'TermFeed/Terms_Conditions.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

int? total, offset;
List<Order_Model> orderList = [];
bool _isLoading = true;
bool isLoadingmore = true;
// List<PersonModel> delBoyList = [];
List<ZipCodeModel> zipCodeList = [];
List<CategoryModel> catagoryList = [];
String? delPermission;
ApiBaseHelper apiBaseHelper = ApiBaseHelper();

class _HomeState extends State<Home> with TickerProviderStateMixin {
//==============================================================================
//============================= Variables Declaration ==========================
  int curDrwSel = 0;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String?> languageList = [];
  List<Order_Model> tempList = [];
  String? all,
      received,
      processed,
      shipped,
      delivered,
      cancelled,
      returned,
      awaiting;
  String _searchText = "";
  String? totalorderCount,
      totalproductCount,
      totalcustCount,
      totaldelBoyCount,
      totalsoldOutCount,
      totallowStockCount;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  ScrollController? controller; // = new ScrollController();
  int? selectLan;
  bool _isNetworkAvail = true;
  String? activeStatus;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  List<String> statusList = [
    ALL,
    PLACED,
    PROCESSED,
    SHIPED,
    DELIVERD,
    CANCLED,
    RETURNED,
    awaitingPayment
  ];

//==============================================================================
//===================================== For Chart ==============================

  int curChart = 0;
  Map<int, LineChartData>? chartList;
  List? days = [], dayEarning = [];
  List? months = [], monthEarning = [];
  List? weeks = [], weekEarning = [];
  List? catCountList = [], catList = [];
  List colorList = [];
  int? touchedIndex;

//==============================================================================
//============================= For Language Selection =========================

  List<String> langCode = [
    ENGLISH,
    HINDI,
    CHINESE,
    SPANISH,
    ARABIC,
    RUSSIAN,
    JAPANESE,
    DEUTSCH
  ];

//==============================================================================
//============================= initState Method ===============================

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ));
    final pushNotificationService = PushNotificationService(context: context);
    pushNotificationService.initialise();
    offset = 0;
    total = 0;
    chartList = {0: dayData(), 1: weekData(), 2: monthData()};

    orderList.clear();
    getSaveDetail();
    getStatics();
    getSallerDetail();
    //  getDeliveryBoy();
    getZipCodes();
    getCategories();
    //  getOrder();

    buttonController = new AnimationController(
      duration: new Duration(milliseconds: 2000),
      vsync: this,
    );

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
    controller = ScrollController(keepScrollOffset: true);
    // controller!.addListener(_scrollListener);
    new Future.delayed(
      Duration.zero,
          () {
        languageList = [
          getTranslated(context, 'English'),
          getTranslated(context, 'Hindi'),
          getTranslated(context, 'Chinese'),
          getTranslated(context, 'Spanish'),
          getTranslated(context, 'Arabic'),
          getTranslated(context, 'Russian'),
          getTranslated(context, 'Japanese'),
          getTranslated(context, 'Deutch'),
        ];
      },
    );
    super.initState();
  }

//==============================================================================
//============================= For Animation ==================================

  getSaveDetail() async {
    print("we are here");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String getlng = await getPrefrence(LAGUAGE_CODE) ?? '';

    selectLan = langCode.indexOf(getlng == '' ? "en" : getlng);
  }

//==============================================================================
//============================= For Animation ==================================

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

//==============================================================================
//============================= Build Method ===================================

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: white, // status bar color
    //     systemNavigationBarColor: black,
    //   ),
    // );
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: lightWhite,
        appBar: getAppBar(context),
        drawer: getDrawer(context),
        body: getBodyPart(),
        // floatingActionButton: floatingBtn(),
      ),
    );
  }

//==============================================================================
//=============================== floating Button ==============================

  floatingBtn() {
    return FloatingActionButton(
      backgroundColor: white,
      child: Icon(
        Icons.add,
        size: 32,
        color: fontColor,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProduct(),
          ),
        );
      },
    );
  }

//==============================================================================
//=============================== chart coding  ================================

  getChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        height: 250,
        child: Card(
          elevation: 0,
          margin: EdgeInsets.only(top: 10, left: 5, right: 15),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8),
                  child: Text(
                    getTranslated(context, "ProductSales")!,
                    // FIX: headline6 -> titleLarge
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: primary),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: curChart == 0
                        ? TextButton.styleFrom(
                      // FIX: primary -> foregroundColor
                      foregroundColor: Colors.white,
                      backgroundColor: primary,
                      onSurface: Colors.grey,
                    )
                        : null,
                    onPressed: () {
                      setState(
                            () {
                          curChart = 0;
                        },
                      );
                    },
                    child: Text(
                      getTranslated(context, "Day")!,
                    ),
                  ),
                  TextButton(
                    style: curChart == 1
                        ? TextButton.styleFrom(
                      // FIX: primary -> foregroundColor
                      foregroundColor: Colors.white,
                      backgroundColor: primary,
                      onSurface: Colors.grey,
                    )
                        : null,
                    onPressed: () {
                      setState(
                            () {
                          curChart = 1;
                        },
                      );
                    },
                    child: Text(
                      getTranslated(context, "Week")!,
                    ),
                  ),
                  TextButton(
                    style: curChart == 2
                        ? TextButton.styleFrom(
                      // FIX: primary -> foregroundColor
                      foregroundColor: Colors.white,
                      backgroundColor: primary,
                      onSurface: Colors.grey,
                    )
                        : null,
                    onPressed: () {
                      setState(
                            () {
                          curChart = 2;
                        },
                      );
                    },
                    child: Text(
                      getTranslated(context, "Month")!,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: LineChart(
                  chartList![curChart]!,
                  swapAnimationDuration: const Duration(milliseconds: 250),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

//1. LineChartData

  LineChartData dayData() {
    if (dayEarning!.length == 0) {
      dayEarning!.add(0);
      days!.add(0);
    }
    List<FlSpot> spots = dayEarning!.asMap().entries.map((e) {
      return FlSpot(double.parse(days![e.key].toString()),
          double.parse(e.value.toString()));
    }).toList();

    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: 2,
          colors: [
            grad2Color,
          ],
          belowBarData: BarAreaData(
            show: true,
            colors: [primary.withOpacity(0.5)],
          ),
          aboveBarData: BarAreaData(
            show: true,
            colors: [fontColor.withOpacity(0.2)],
          ),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
      minY: 0,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 3,
            // FIX: getTextStyles is replaced by getTitlesWidget
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: black,
                    fontSize: 9,
                  ),
                ),
              );
            },
            // margin: 10, // Removed as margin is now part of AxisTitles/SideTitles properties
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // FIX: getTextStyles is replaced by getTitlesWidget
            getTitlesWidget: (value, meta) {
              return Text(
                meta.formattedValue,
                style: const TextStyle(
                  color: black,
                  fontSize: 9,
                ),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false, // Generally better for clean line charts
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: fontColor.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  //2. catChart (It seems this method is actually for WeekData)

  LineChartData weekData() {
    if (weekEarning!.length == 0) {
      weekEarning!.add(0);
      weeks!.add(0);
    }
    List<FlSpot> spots = weekEarning!.asMap().entries.map((e) {
      return FlSpot(
          double.parse(e.key.toString()), double.parse(e.value.toString()));
    }).toList();

    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: 2,
          colors: [
            grad2Color,
          ],
          belowBarData: BarAreaData(
            show: true,
            colors: [
              primary.withOpacity(0.5),
            ],
          ),
          aboveBarData: BarAreaData(
            show: true,
            colors: [fontColor.withOpacity(0.2)],
          ),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
      minY: 0,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 4,
            // FIX: getTextStyles is replaced by getTitlesWidget
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  weeks![value.toInt()].toString(),
                  style: const TextStyle(
                    color: black,
                    fontSize: 9,
                  ),
                ),
              );
            },
            // margin: 10, // Removed
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // FIX: getTextStyles is replaced by getTitlesWidget
            getTitlesWidget: (value, meta) {
              return Text(
                meta.formattedValue,
                style: const TextStyle(
                  color: black,
                  fontSize: 9,
                ),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: fontColor.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  //2. monthData

  LineChartData monthData() {
    if (monthEarning!.length == 0) {
      monthEarning!.add(0);
      months!.add(0);
    }

    List<FlSpot> spots = monthEarning!.asMap().entries.map((e) {
      return FlSpot(
          double.parse(e.key.toString()), double.parse(e.value.toString()));
    }).toList();

    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: 2,
          colors: [
            grad2Color,
          ],
          belowBarData: BarAreaData(
            show: true,
            colors: [primary.withOpacity(0.5)],
          ),
          aboveBarData: BarAreaData(
            show: true,
            colors: [fontColor.withOpacity(0.2)],
          ),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
      minY: 0,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // FIX: getTextStyles is replaced by getTitlesWidget
            getTitlesWidget: (value, meta) {
              return Text(
                meta.formattedValue,
                style: const TextStyle(
                  color: black,
                  fontSize: 9,
                ),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 3,
            // FIX: getTextStyles is replaced by getTitlesWidget
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  months![value.toInt()],
                  style: const TextStyle(
                    color: black,
                    fontSize: 9,
                  ),
                ),
              );
            },
            // margin: 10, // Removed
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: fontColor.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  Color generateRandomColor() {
    Random random = Random();
    // Pick a random number in the range [0.0, 1.0)
    double randomDouble = random.nextDouble();

    return Color((randomDouble * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

//==============================================================================
//========================= getZipcodesApi API =================================

  Future<void> getCategories() async {
    CUR_USERID = await getPrefrence(Id);
    var parameter = {
      SellerId: CUR_USERID,
    };
    apiBaseHelper.postAPICall(getCategoriesApi, parameter).then(
          (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          catagoryList.clear();
          var data = getdata["data"];
          catagoryList = (data as List)
              .map((data) => new CategoryModel.fromJson(data))
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
//==============================================================================
//========================= getZipcodesApi API =================================

  Future<void> getZipCodes() async {
    var parameter = {};
    apiBaseHelper.postAPICall(getZipcodesApi, parameter).then(
          (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          zipCodeList.clear();
          var data = getdata["data"];
          zipCodeList = (data as List)
              .map((data) => new ZipCodeModel.fromJson(data))
              .toList();
        } else {
          // setSnackbar(msg!);
        }
      },
      onError: (error) {
        // setSnackbar(error.toString());
      },
    );
  }

//==============================================================================
//========================= getDeliveryBoy API =================================

  // Future<void> getDeliveryBoy() async {
  //   CUR_USERID = await getPrefrence(Id);
  //   var parameter = {
  //     SellerId: CUR_USERID,
  //   };
  //   apiBaseHelper.postAPICall(getDeliveryBoysApi, parameter).then(
  //     (getdata) async {
  //       bool error = getdata["error"];
  //       String? msg = getdata["message"];

  //       if (!error) {
  //         delBoyList.clear();
  //         var data = getdata["data"];
  //         delBoyList = (data as List)
  //             .map((data) => new PersonModel.fromJson(data))
  //             .toList();
  //       } else {
  //         setSnackbar(msg!);
  //       }
  //     },
  //     onError: (error) {
  //       setSnackbar(error.toString());
  //     },
  //   );
  // }

//==============================================================================
//========================= getStatics API =====================================

  Future<Null> getStatics() async {
    CUR_USERID = await getPrefrence(Id);
    CUR_USERNAME = await getPrefrence(Username);
    var parameter = {SellerId: CUR_USERID};

    apiBaseHelper.postAPICall(getStatisticsApi, parameter).then(
          (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          CUR_CURRENCY = getdata["currency_symbol"];
          var count = getdata['counts'][0];
          totalorderCount = count["order_counter"];
          totalproductCount = count["product_counter"];
          totalsoldOutCount = count['count_products_sold_out_status'];
          totallowStockCount = count["count_products_low_status"];
          totalcustCount = count["user_counter"];
          delPermission = count["permissions"]['assign_delivery_boy'];
          weekEarning = getdata['earnings'][0]["weekly_earnings"]['total_sale'];
          days = getdata['earnings'][0]["daily_earnings"]['day'];
          dayEarning = getdata['earnings'][0]["daily_earnings"]['total_sale'];
          months = getdata['earnings'][0]["monthly_earnings"]['month_name'];
          monthEarning =
          getdata['earnings'][0]["monthly_earnings"]['total_sale'];

          weeks = getdata['earnings'][0]["weekly_earnings"]['week'];
          //  if (chartList != null) chartList!.clear();
          chartList = {0: dayData(), 1: weekData(), 2: monthData()};

          catCountList = getdata['category_wise_product_count']['counter'];
          catList = getdata['category_wise_product_count']['cat_name'];
          colorList.clear();
          for (int i = 0; i < catList!.length; i++)
            colorList.add(generateRandomColor());
        } else {
          setSnackbar(msg!);
        }

        setState(() {
          _isLoading = false;
        });
      },
      onError: (error) {
        setSnackbar(error.toString());
      },
    );
    return null;
  }

//==============================================================================
//========================= get_seller_details API =============================

  Future<Null> getSallerDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      CUR_USERID = await getPrefrence(Id);

      var parameter = {Id: CUR_USERID};
      apiBaseHelper.postAPICall(getSellerDetails, parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];

          if (!error) {
            var data = getdata["data"][0];
            print("Seller data : $data");
            CUR_BALANCE = double.parse(data[BALANCE]).toStringAsFixed(2);
            LOGO = data["logo"].toString();
            RATTING = data[Rating] ?? "";
            NO_OFF_RATTING = data[NoOfRatings] ?? "";
            NO_OFF_RATTING = data[NoOfRatings] ?? "";
            var id = data[Id];
            var username = data[Username];
            var email = data[Email];
            var mobile = data[Mobile];
            var address = data[Address];
            CUR_USERID = id!;
            CUR_USERNAME = username!;
            var srorename = data[Storename];
            var storeurl = data[Storeurl];
            var storeDesc = data[storeDescription];
            var accNo = data[accountNumber];
            var accname = data[accountName];
            var bankCode = data[BankCOde];
            var bankName = data[bankNAme];
            var latitutute = data[Latitude];
            var longitude = data[Longitude];
            var taxname = data[taxName];
            var tax_number = data[taxNumber];
            var pan_number = data[panNumber];
            var status = data[STATUS];
            var storeLogo = data[StoreLogo];

            print("bank name : $bankName");
            saveUserDetail(
              userId: id!,
              name: username!,
              email: email!,
              mobile: mobile!,
              address: address!,
              storename: srorename!,
              storeurl: storeurl!,
              storeDesc: storeDesc!,
              accNo: accNo!,
              accname: accname!,
              bankCode: bankCode ?? "",
              bankName: bankName ?? "",
              latitutute: latitutute ?? "",
              longitude: longitude ?? "",
              taxname: taxname ?? "",
              tax_number: tax_number!,
              pan_number: pan_number!,
              status: status!,
              storelogo: storeLogo!,
            );
          }
          setState(() {
            _isLoading = false;
          });
        },
        onError: (error) {
          setSnackbar(error.toString());
        },
      );
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
    }

    return null;
  }

//==============================================================================
//============================ AppBar ==========================================

  getAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        appName,
        style: TextStyle(
          color: grad2Color,
        ),
      ),
      backgroundColor: white,
      iconTheme: IconThemeData(color: grad2Color),
    );
  }

//==============================================================================
//================================ SnackBar ====================================

  setSnackbar(String msg) {
    Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: primary,
        textColor: Colors.white,
        fontSize: 16.0);
  }

//==============================================================================
//============================= Drawer Implimentation ==========================

  getDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Container(
          color: white,
          child: ListView(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              _getHeader(),
              Divider(),
              _getDrawerItem(
                  0, getTranslated(context, "HOME")!, Icons.home_outlined),
              _getDrawerItem(1, getTranslated(context, "ORDERS")!,
                  Icons.shopping_basket_outlined),
              Divider(),
              _getDrawerItem(
                  2, getTranslated(context, "CUSTOMERS")!, Icons.person),
              Divider(),
              _getDrawerItem(3, getTranslated(context, "WALLETHISTORY")!,
                  Icons.account_balance_wallet_outlined),
              Divider(),
              // _getDrawerItem(4, getTranslated(context, "PRODUCTS")!,
              //     Icons.production_quantity_limits_outlined),
              // _getDrawerItem(
              //     10, getTranslated(context, "Add Product")!, Icons.add),
              // Divider(),
              // _getDrawerItem(5, getTranslated(context, "ChangeLanguage")!,
              //     Icons.translate),
              _getDrawerItem(6, getTranslated(context, "T_AND_C")!,
                  Icons.speaker_notes_outlined),
              Divider(),
              _getDrawerItem(7, getTranslated(context, "PRIVACYPOLICY")!,
                  Icons.lock_outline),
              _getDrawerItem(
                  9, getTranslated(context, "CONTACTUS")!, Icons.contact_page),
              Divider(),
              _getDrawerItem(
                  8, getTranslated(context, "LOGOUT")!, Icons.home_outlined),
              Divider(),
              _getDrawerItem(8, getTranslated(context, "Delete_account")!,
                  Icons.home_outlined),
            ],
          ),
        ),
      ),
    );
  }

//  => Drawer Header

  _getHeader() {
    return InkWell(
      child: Container(
        decoration: back(),
        padding: EdgeInsets.only(left: 10.0, bottom: 10),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 10),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CUR_USERNAME!,
                      // FIX: subtitle1 -> titleMedium
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      getTranslated(context, "WALLET_BAL")! +
                          ": " +
                          CUR_CURRENCY +
                          "" +
                          CUR_BALANCE,
                      // FIX: caption -> bodySmall
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getTranslated(context, "EDIT_PROFILE_LBL")!,
                            // FIX: caption -> bodySmall
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: white),
                          ),
                          Icon(
                            Icons.arrow_right_outlined,
                            color: white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(top: 20, right: 20),
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1.0,
                  color: white,
                ),
              ),
              child: LOGO != ''
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: sallerLogo(62),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: imagePlaceHolder(62),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(),
          ),
        ).then((value) {
          print("back frome profile screen");
          getStatics();
          getSallerDetail();
          //  getDeliveryBoy();
          getZipCodes();
          getCategories();
          setState(() {});
          Navigator.pop(context);
        });
        setState(() {});
      },
    );
  }

//  => PlaceHolder Image For Drawer Header
  sallerLogo(double size) {
    return CircleAvatar(
      backgroundImage: NetworkImage(LOGO),
      radius: 25,
    );
  }

  imagePlaceHolder(double size) {
    return new Container(
      height: size,
      width: size,
      child: Icon(
        Icons.account_circle,
        color: Colors.white,
        size: size,
      ),
    );
  }

//  => Drawer Item List

  Widget _getDrawerItem(int index, String title, IconData icn) {
    return ListTile(
      leading: Icon(icn, color: Colors.white),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          curDrwSel = index;
        });
      },
    );
  }

}
