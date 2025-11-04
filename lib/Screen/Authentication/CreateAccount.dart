import 'dart:convert';
import 'dart:io';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart'; // Ensure image_picker is imported for XFile
import 'package:http/http.dart' as http;
import '../../Helper/Color.dart';

class CreateAccount extends StatefulWidget {
  final String mobileNumber;
  CreateAccount({
    Key? key,
    required this.mobileNumber,
  })  : assert(mobileNumber != null),
        super(key: key);
  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  var size, height, width;
  String gender = "Male";
  String open = "Open";
  String dropdownValue = 'Select';

  // NOTE: Unused lists and controllers are kept but commented out for potential future use.
  List<String> categories = ['Select', 'Mart', 'Food'];
  List<String> pincodeList = [
    '----Select Pincode----',
    '452001',
    '452010',
    '560067'
  ];

  bool isLoading = false;
  TextEditingController dobController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController storestatusController = TextEditingController();
  TextEditingController ifsccodeController = TextEditingController();
  TextEditingController holdernameController = TextEditingController();
  TextEditingController logoController = TextEditingController();
  TextEditingController addressproofController = TextEditingController();
  TextEditingController gstfileController = TextEditingController();
  TextEditingController bankpassbookphotoController = TextEditingController();
  TextEditingController profilepictureController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();
  TextEditingController storeUrlController = TextEditingController();
  TextEditingController storeDescriptionController = TextEditingController();
  TextEditingController panNumberController = TextEditingController();
  TextEditingController taxNameController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController foodLicController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    mobileController.text = widget.mobileNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 78.0),
          child: Text(
            "Sign Up",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                TextButtonWidget(
                  hint: "Name",
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: mobileController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter Mobile Number",
                    prefix: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        "+91",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15),
                TextButtonWidget(
                  keyboardType: TextInputType.emailAddress,
                  hint: "Enter Email",
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                PasswordFild(
                  hint: "Password",
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                PasswordFild(
                  hint: "Enter Confirm Password",
                  controller: confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextButtonWidget(
                  hint: "Address",
                  controller: addressController,
                ),
                SizedBox(height: 15),

                TextFilePickWidget(
                    hint: "Upload Address Proof",
                    imagePathController: addressproofController),
                SizedBox(height: 15),
                TextFilePickWidget(
                    hint: "Upload Gst File",
                    imagePathController: gstfileController),
                SizedBox(height: 15),
                TextFilePickWidget(
                    hint: "Upload Bank Passbook",
                    imagePathController: bankpassbookphotoController),
                SizedBox(height: 15),
                TextFilePickWidget(
                    hint: "Upload Profile Picture",
                    imagePathController: profilepictureController),
                SizedBox(height: 15),
                TextButtonWidget(
                    hint: "DOB",
                    suffix: Icon(Icons.calendar_month),
                    controller: dobController,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: primary,
                              // FIX: Replaced deprecated accentColor with colorScheme and primary
                              colorScheme: ColorScheme.light(primary: primary),
                              buttonTheme: ButtonThemeData(
                                textTheme: ButtonTextTheme.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dobController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    }),
                SizedBox(height: 15),
                Text("Gender",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Radio<String>(
                      value: "Male",
                      groupValue: gender,
                      onChanged: (String? value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    Text("Male"),
                    Radio<String>(
                      value: "Female",
                      groupValue: gender,
                      onChanged: (String? value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    Text("Female"),
                    Radio<String>(
                      value: "Other",
                      groupValue: gender,
                      onChanged: (String? value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    Text("Other"),
                  ],
                ),
                SizedBox(height: 15),
                TextButtonWidget(
                    hint: "Pan Number", controller: panNumberController),
                SizedBox(height: 15),
                SizedBox(height: 15),
                Text("Store Details",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 15),
                TextButtonWidget(
                  hint: "Store Name",
                  controller: storeNameController,
                ),
                SizedBox(height: 15),
                TextButtonWidget(
                  hint: "Store URL",
                  controller: storeUrlController,
                ),
                SizedBox(height: 15),
                TextButtonWidget(
                  hint: " Store Description",
                  controller: storeDescriptionController,
                ),
                SizedBox(height: 15),
                SizedBox(height: 15),
                Text("Open/Close Store",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Radio<String>(
                      value: "Open",
                      groupValue: open,
                      onChanged: (String? value) {
                        setState(() {
                          open = value!;
                        });
                      },
                    ),
                    Text("Open"),
                    Radio<String>(
                      value: "Close",
                      groupValue: open,
                      onChanged: (String? value) {
                        setState(() {
                          open = value!;
                        });
                      },
                    ),
                    Text("Close"),
                  ],
                ),
                TextFilePickWidget(
                  hint: "Upload Logo",
                  imagePathController: logoController,
                ),
                SizedBox(height: 15),
                Text("Bank Details",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 15),
                TextButtonWidget(
                  hint: "Account Number",
                  controller: accountNumberController,
                ),
                SizedBox(height: 15),
                TextButtonWidget(
                  hint: "Account Holder Name",
                  controller: accountNameController,
                ),
                SizedBox(height: 15),
                TextButtonWidget(
                  hint: "IFSC Code",
                  controller: bankCodeController,
                ),
                SizedBox(height: 15),
                TextButtonWidget(
                  hint: "Bank Name",
                  controller: bankNameController,
                ),
                SizedBox(height: 15),
                loginBtn(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  loginBtn() {
    return TextButton(
      onPressed: () {
        if (_formKey.currentState!.validate() && isLoading == false) {
          registerUser();
        }
      },
      child: Container(
        height: height / 20,
        width: width / 1,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white,)
                : Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 16),
            )),
      ),
    );
  }

  registerUser() async {
    setState(() {
      isLoading = true;
    });
    var headers = {
      'Cookie': 'ci_session=df5385d665217dba30014022ebc9598ab69bb28d'
    };
    var request = http.MultipartRequest('POST', registerUserApi);
    request.fields.addAll({
      "mobile": mobileController.text,
      "email": emailController.text,
      "name": nameController.text,
      "password": passwordController.text,
      "confirm_password": confirmPasswordController.text,
      "address": addressController.text,
      "city": cityController.text,

      "store_status": storestatusController.text,
      "ifsc_code": ifsccodeController.text,
      "holder_name": holdernameController.text,
      "logo": logoController.text,
      "address_proof": addressproofController.text,
      "gst_file": gstfileController.text,
      "bank_passbook_photo": bankpassbookphotoController.text,
      "profile_picture": profilepictureController.text,
      "dob": dobController.text,
      "gender": gender,
      "store_name": storeNameController.text,
      "store_url": storeUrlController.text,
      "store_description": storeDescriptionController.text,
      "pan_number": panNumberController.text,
      "tax_name": taxNameController.text,
      "tax_number": taxNumberController.text,
      "bank_name": bankNameController.text,
      "bank_code": bankCodeController.text,
      "account_name": accountNameController.text,
      "account_number": accountNumberController.text,
      // NOTE: Using hardcoded lat/long - consider using actual location in a real app
      "latitude": "7.6445",
      "longitude": "7.7674"
    });
    print('Anjaliparameter____________${request.fields}');

    if (addressproofController.text.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
          'address_proof', addressproofController.text));
    }
    if (logoController.text.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath('logo', logoController.text));
    }
    if (gstfileController.text.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
          'gst_file', gstfileController.text));
    }
    if (foodLicController.text.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
          'food_lic', foodLicController.text));
    }
    if (bankpassbookphotoController.text.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
          'bank_passbook_photo', bankpassbookphotoController.text));
    }
    if (profilepictureController.text.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', profilepictureController.text));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      bool error = finalResult['error'];
      String msg = finalResult['message'];
      if (error) {
        Fluttertoast.showToast(msg: msg);
      } else {
        Fluttertoast.showToast(msg: msg);
        // On successful registration, typically you navigate to the home screen or login page
        Navigator.pop(context); // This will take them back to the OTP screen, maybe change this?
      }
    } else {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
    setState(() {
      isLoading = false;
    });
  }
}

class TextButtonWidget extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final Widget? suffix;
  final bool readOnly;
  final Widget? prefix;
  final TextInputType? keyboardType;

  TextButtonWidget({
    required this.hint,
    this.controller,
    this.onTap,
    this.readOnly = false,
    this.validator,
    this.suffix,
    this.prefix,
    this.keyboardType,
  });

  @override
  State<TextButtonWidget> createState() => _TextButtonWidgetState();
}

class _TextButtonWidgetState extends State<TextButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        child: TextFormField(
          keyboardType: widget.keyboardType,
          controller: widget.controller,
          onTap: widget.onTap,
          readOnly: widget.readOnly || widget.onTap != null, // Fixed readOnly logic
          validator: widget.validator,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10), // Adjusted vertical padding
            hintText: widget.hint,
            suffixIcon: widget.suffix,
            prefixIcon: widget.prefix,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

class TextFilePickWidget extends StatefulWidget {
  final String hint;
  TextEditingController imagePathController;
  TextFilePickWidget({required this.hint, required this.imagePathController});

  @override
  State<TextFilePickWidget> createState() => _TextFilePickWidgetState();
}

class _TextFilePickWidgetState extends State<TextFilePickWidget> {
  // FilePicker logic is correct, but ImagePickerGC needs updating.

  Future getImage(BuildContext context, ImgSource source) async {
    // Calling the updated ImagePickerGC method
    var image = await ImagePickerGC.pickImage(
      enableCloseButton: true,
      closeIcon: Icon(
        Icons.close,
        color: Colors.red,
        size: 12,
      ),
      context: context,
      source: source,
      barrierDismissible: true,
      cameraIcon: Icon(
        Icons.camera_alt,
        color: Colors.red,
      ),
      cameraText: Text(
        "From Camera",
        style: TextStyle(color: Colors.red),
      ),
      galleryText: Text(
        "From Gallery",
        style: TextStyle(color: Colors.blue),
      ),
    );

    if (image != null) {
      setState(() {
        // XFile has a 'path' property
        widget.imagePathController.text = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Adjusted height calculation for consistency
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 10),
            // Show file name or hint
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: widget.imagePathController.text.isNotEmpty
                    ? Text(
                  widget.imagePathController.text.split('/').last,
                  style: TextStyle(fontSize: 14, color: fontColor),
                  overflow: TextOverflow.ellipsis,
                )
                    : Text(
                  widget.hint,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
            // File Pick Button
            GestureDetector(
              onTap: () => getImage(context, ImgSource.Both),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width / 3,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1), // Added a subtle background color
                  border: Border(left: BorderSide(color: Colors.grey)),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Choose File",
                    style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordFild extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  PasswordFild({required this.hint, this.controller, this.validator});

  @override
  State<PasswordFild> createState() => _PasswordFildState();
}

class _PasswordFildState extends State<PasswordFild> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        child: TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10), // Adjusted vertical padding
            hintText: widget.hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

// FIX: ImagePickerGC class updated to use the non-deprecated 'pickImage' method which returns XFile.
class ImagePickerGC {
  static Future<XFile?> pickImage({
    required BuildContext context,
    required ImgSource source,
    bool? enableCloseButton,
    double? maxWidth,
    double? maxHeight,
    Icon? cameraIcon,
    Icon? galleryIcon,
    Widget? cameraText,
    Widget? galleryText,
    bool barrierDismissible = false,
    Icon? closeIcon,
    int? imageQuality,
  }) async {
    assert(imageQuality == null || (imageQuality >= 0 && imageQuality <= 100));

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight cannot be negative');
    }

    // Initialize ImagePicker
    final ImagePicker _picker = ImagePicker();

    switch (source) {
      case ImgSource.Camera:
      // FIX: Using pickImage
        return await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      case ImgSource.Gallery:
      // FIX: Using pickImage
        return await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      case ImgSource.Both:
        return await showDialog<XFile?>(
          context: context,
          barrierDismissible: barrierDismissible,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (enableCloseButton == true)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: closeIcon ?? Icon(Icons.close, size: 14),
                      ),
                    ),
                  InkWell(
                    onTap: () async {
                      // FIX: Using pickImage
                      _picker
                          .pickImage(
                        source: ImageSource.gallery,
                        maxWidth: maxWidth,
                        maxHeight: maxHeight,
                        imageQuality: imageQuality,
                      )
                          .then((image) {
                        Navigator.pop(context, image);
                      });
                    },
                    child: Container(
                      child: ListTile(
                        title: galleryText ?? Text("Gallery"),
                        leading: galleryIcon ??
                            Icon(Icons.image, color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 1,
                    color: Colors.black12,
                  ),
                  InkWell(
                    onTap: () async {
                      // FIX: Using pickImage
                      _picker
                          .pickImage(
                        source: ImageSource.camera,
                        maxWidth: maxWidth,
                        maxHeight: maxHeight,
                      )
                          .then((image) {
                        Navigator.pop(context, image);
                      });
                    },
                    child: Container(
                      child: ListTile(
                        title: cameraText ?? Text("Camera"),
                        leading: cameraIcon ??
                            Icon(Icons.camera, color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
    }
  }
}

enum ImgSource { Camera, Gallery, Both }
