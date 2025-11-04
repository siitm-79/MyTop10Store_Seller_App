import 'dart:async';
import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart'; // Added missing import
import 'package:eshopmultivendor/Helper/AppBtn.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/ContainerDesing.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:eshopmultivendor/Screen/Authentication/SetNewPassword.dart';
import 'package:eshopmultivendor/Screen/Home.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Removed: Not used for current OTP flow
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'CreateAccount.dart';

class NumberVerifyOtp extends StatefulWidget {
  final String? mobileNumber, countryCode, title;
  var otp;

  NumberVerifyOtp(
      {Key? key,
        required String this.mobileNumber,
        this.countryCode,
        this.title,
        this.otp})
      : assert(mobileNumber != null),
        super(key: key);

  @override
  _MobileOTPState createState() => new _MobileOTPState();
}

class _MobileOTPState extends State<NumberVerifyOtp>
    with TickerProviderStateMixin {
  final dataKey = new GlobalKey();
  String? password, mobile, countrycode;
  String? otp;
  bool isCodeSent = false;
  // late String _verificationId; // Removed: Firebase variable not used
  String signature = "";
  bool _isClickable = false;
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Removed: Firebase object not used

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper(); // Initialize API helper

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    getUserDetails();
    getSingature();
    Future.delayed(Duration(seconds: 60)).then(
          (_) {
        _isClickable = true;
      },
    );
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
  }

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    await SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    mobile = await getPrefrence(Mobile);
    countrycode = await getPrefrence(COUNTRY_CODE);
    setState(
          () {},
    );
  }

  Future<void> checkNetworkOtp() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (_isClickable) {
        resendOtp();
      } else {
        setSnackbar(getTranslated(context, "OTPWR")!);
      }
    } else {
      setState(
            () {
          _isNetworkAvail = false;
        },
      );

      Future.delayed(Duration(seconds: 60)).then((_) async {
        bool avail = await isNetworkAvailable();
        if (avail) {
          if (_isClickable)
            verifiedOtpCheck();
          else {
            setSnackbar(getTranslated(context, "OTPWR")!);
          }
        } else {
          await buttonController!.reverse();
          setSnackbar(getTranslated(context, "somethingMSg")!);
        }
      });
    }
  }

  verifyBtn() {
    return AppBtn(
      title: getTranslated(context, "VERIFY_AND_PROCEED")!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        // Using local API OTP check instead of Firebase
        verifiedOtpCheck();
      },
    );
  }

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

  void verifiedOtpCheck() async {
    if (widget.otp.toString() == otp.toString()) {
      setSnackbar(getTranslated(context, 'OTPMSG')!);
      saveUserDetail(mobile: widget.mobileNumber);

      Future.delayed(Duration(seconds: 2)).then((_) {
        // Navigate to the next step: Create Account
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CreateAccount(mobileNumber: widget.mobileNumber.toString()),
          ),
        );
      });
    } else {
      setSnackbar(
          getTranslated(context, 'INVALID_OTP') ?? "Please enter a valid OTP");
    }
  }

  // NOTE: Removed unused Firebase verification methods: _onVerifyCode, _onFormSubmitted

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  monoVarifyText() {
    return Padding(
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: Center(
        child: new Text(getTranslated(context, "MOBILE_NUMBER_VARIFICATION")!,
            // FIX: Replaced subtitle1 with titleLarge
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: fontColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  otpText() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child: Center(
        child: new Text(
          getTranslated(context, "SENT_VERIFY_CODE_TO_NO_LBL")!,
          // FIX: Replaced subtitle2 with bodyMedium
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: fontColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  mobText() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.0,
        left: 20.0,
        right: 20.0,
        top: 10.0,
      ),
      child: Center(
        child: Text(
          "+$countrycode-$mobile",
          // FIX: Replaced subtitle1 with titleLarge
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: fontColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  OTP() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.0,
        left: 20.0,
        right: 20.0,
        top: 10.0,
      ),
      child: Center(
        child: Text(
          "${widget.otp}",
          // FIX: Replaced subtitle1 with titleLarge
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: fontColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  otpLayout() {
    return Padding(
      padding: EdgeInsets.only(
        left: 50.0,
        right: 50.0,
      ),
      child: Center(
        child: PinFieldAutoFill(
          decoration: UnderlineDecoration(
            textStyle: TextStyle(
              fontSize: 20,
              color: fontColor,
            ),
            colorBuilder: FixedColorBuilder(lightWhite),
          ),
          currentCode: otp,
          codeLength: 4,
          onCodeChanged: (String? code) {
            otp = code;
          },
          onCodeSubmitted: (String code) {
            otp = code;
          },
        ),
      ),
    );
  }

  resendText() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 30.0,
        left: 25.0,
        right: 25.0,
        top: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getTranslated(context, "DIDNT_GET_THE_CODE")!,
            // FIX: Replaced caption with labelSmall
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: fontColor,
              fontWeight: FontWeight.normal,
              fontSize: 12, // Setting size to match old caption
            ),
          ),
          InkWell(
            onTap: () async {
              await buttonController!.reverse();
              checkNetworkOtp();
            },
            child: Text(
              getTranslated(context, "RESEND_OTP")!,
              // FIX: Replaced caption with labelSmall
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: fontColor,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.normal,
                fontSize: 12, // Setting size to match old caption
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NOTE: Removed unused expandedBottomView widget

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: primary,
      key: _scaffoldKey,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            // decoration: back(),
          ),
          Image.asset(
            'assets/images/doodle.png',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          getLoginContainer(),
          getLogo(),
        ],
      ),
    );
  }

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      top: MediaQuery.of(context).size.height * 0.2,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom * 0.6,
          ),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: white,
          child: Form(
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      monoVarifyText(),
                      otpText(),
                      mobText(),
                      // Text("${widget.otp}"), // Commented out debug line
                      otpLayout(),
                      verifyBtn(),
                      resendText(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - 50,
      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset(
          'assets/images/loginlogo.png',
        ),
      ),
    );
  }

  Future<void> resendOtp() async {
    // Ensuring 'mobile' is not null before using it
    if (mobile == null) {
      setSnackbar("Mobile number not found. Please go back and try again.");
      return;
    }

    var data = {
      Mobile: mobile,
      ResendOtp: 'true',
    };

    apiBaseHelper.postAPICall(verifySellerApi, data).then(
          (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        print(data);
        print(getdata);
        await buttonController!.reverse();

        if (!error) {
          int otpValue = getdata["data"]["otp"];
          // Update the OTP in the widget state to reflect the new code
          setState(() {
            widget.otp = otpValue.toString();
          });
          setSnackbar(msg!);
          _isClickable = false;
          delayClickable();
        } else {
          setSnackbar(msg!);
        }
      },
      onError: (error) async {
        print(error);
        await buttonController!.reverse();
      },
    );
  }

  delayClickable() {
    Future.delayed(Duration(seconds: 60)).then(
          (_) {
        _isClickable = true;
      },
    );
  }
}
