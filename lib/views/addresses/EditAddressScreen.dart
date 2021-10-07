import 'dart:collection';

import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/controllers/AddressController.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/models/UserAddress.dart';
import 'package:vitrinint/services/AppLocalizations.dart';
import 'package:vitrinint/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';

class EditAddressScreen extends StatefulWidget {
  final UserAddress userAddress;

  const EditAddressScreen({Key? key, required this.userAddress})
      : super(key: key);

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  //UI variables
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();

  //Google Maps
  bool loaded = false;
  final Set<Marker> _markers = HashSet();
  late LatLng currentPosition;

  //Other
  bool isInProgress = false;

  late UserAddress userAddress;

  //UI variables
  OutlineInputBorder? allTFBorder;
  TextStyle? allTFStyle, allTFHintStyle;

  //Selected Address Type
  int selectedAddressType = UserAddress.HOME;

  //Google Maps
  late GoogleMapController mapController;
  BitmapDescriptor? pinLocationIcon;
  late LatLng _center;
  late Marker marker;

  //Text Controller
  TextEditingController? addressTFController,
      address2TFController,
      cityTFController,
      pincodeTFController;

  @override
  void initState() {
    super.initState();
    userAddress = widget.userAddress;
    addressTFController = TextEditingController(text: userAddress.address);
    address2TFController = TextEditingController(text: userAddress.address2);
    cityTFController = TextEditingController(text: userAddress.city);
    pincodeTFController =
        TextEditingController(text: userAddress.pincode.toString());
    selectedAddressType = userAddress.type;
    _center = LatLng(userAddress.latitude, userAddress.longitude);
    currentPosition = _center;
    marker = Marker(
      markerId: MarkerId('1'),
      position: _center,
    );
    WidgetsBinding.instance!.addPostFrameCallback((_) => {_changeLoaded()});
  }

  _changeLoaded() {
    setState(() {
      loaded = true;
    });
  }

  _initUI() {
    allTFBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        borderSide: BorderSide.none);

    allTFStyle = AppTheme.getTextStyle(themeData.textTheme.subtitle2,
        fontWeight: 500, letterSpacing: 0.2);

    allTFHintStyle = AppTheme.getTextStyle(themeData.textTheme.subtitle2,
        fontWeight: 500,
        letterSpacing: 0,
        color: themeData.colorScheme.onBackground.withAlpha(180));
  }

  _setupLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      Geolocator.openAppSettings();
    }
    return permission;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.add(marker);
    });
  }

  Future<void> gettingLocation() async {
    LocationPermission locationPermission = await _setupLocationPermission();

    if (locationPermission != LocationPermission.always &&
        locationPermission != LocationPermission.whileInUse) {
      // Navigator.pop(context, locationPermission);
      return;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      double zoom = await mapController.getZoomLevel();
      _changeLocation(zoom, LatLng(position.latitude, position.longitude));
    } catch (error) {}
  }

  void _onMapTap(LatLng latLong) {
    mapController
        .getZoomLevel()
        .then((zoom) => {_changeLocation(zoom, latLong)});
  }

  void _changeLocation(double zoom, LatLng latLng) {
    double newZoom = zoom > 15 ? zoom : 15;
    currentPosition = latLng;
    setState(() {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: newZoom)));
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('1'),
        position: latLng,
      ));
    });
  }

  _updateAddress() async {
    String address = addressTFController!.text;
    String address2 = address2TFController!.text;
    String city = cityTFController!.text;
    String pincodeText = pincodeTFController!.text;
    int? pincode;
    if (pincodeText.isNotEmpty) {
      pincode = int.parse(pincodeTFController!.text);
    }

    if (address.isEmpty) {
      showMessage(message: Translator.translate("please_fill_address"));
    } else if (city.isEmpty) {
      showMessage(message: Translator.translate("please_fill_city"));
    } else if (pincode == null) {
      showMessage(message: Translator.translate("please_fill_pincode"));
    } else {
      if (mounted) {
        setState(() {
          isInProgress = true;
        });
      }

      double latitude = currentPosition.latitude;
      double longitude = currentPosition.longitude;
      MyResponse myResponse = await AddressController.updateAddress(
          userAddress.id,
          latitude: latitude != userAddress.latitude ? latitude : null,
          address2: address2 != userAddress.address2 ? address2 : null,
          address: address != userAddress.address ? address : null,
          city: city != userAddress.city ? city : null,
          longitude: longitude != userAddress.longitude ? longitude : null,
          pincode: pincode != userAddress.pincode ? pincode : null,
          type: selectedAddressType != userAddress.type
              ? selectedAddressType
              : null);

      if (myResponse.success) {
        Navigator.pop(context, true);
      } else {
        ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
        showMessage(message: myResponse.errorText);
      }

      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        _initUI();
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                key: _scaffoldKey,
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    gettingLocation();
                  },
                  child: Icon(
                    MdiIcons.mapMarkerOutline,
                    color: themeData.colorScheme.onPrimary,
                  ),
                ),
                body: Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: loaded
                            ? GoogleMap(
                                onMapCreated: _onMapCreated,
                                markers: _markers,
                                onTap: _onMapTap,
                                initialCameraPosition: CameraPosition(
                                  target: _center,
                                  zoom: 11.0,
                                ),
                              )
                            : Container(),
                      ),
                      Container(
                          padding: Spacing.fromLTRB(24, 8, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                children: [
                                  Radio<int>(
                                      value: UserAddress.HOME,
                                      groupValue: selectedAddressType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAddressType = value!;
                                        });
                                      }),
                                  Text(
                                    Translator.translate("home"),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      color: themeData.colorScheme.onBackground,
                                    ),
                                  ),
                                  Spacing.width(8),
                                  Radio<int>(
                                      value: UserAddress.WORK,
                                      groupValue: selectedAddressType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAddressType = value!;
                                        });
                                      }),
                                  Text(
                                    Translator.translate("work"),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      color: themeData.colorScheme.onBackground,
                                    ),
                                  ),
                                  Spacing.width(8),
                                  Radio<int>(
                                      value: UserAddress.OTHER,
                                      groupValue: selectedAddressType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAddressType = value!;
                                        });
                                      }),
                                  Text(
                                    Translator.translate("other"),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      color: themeData.colorScheme.onBackground,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: themeData.cardTheme.color,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeData.cardTheme.shadowColor!
                                          .withAlpha(28),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    TextFormField(
                                      style: allTFStyle,
                                      decoration: InputDecoration(
                                        hintStyle: allTFHintStyle,
                                        hintText:
                                            Translator.translate("address") +
                                                " 1",
                                        border: allTFBorder,
                                        enabledBorder: allTFBorder,
                                        focusedBorder: allTFBorder,
                                        prefixIcon: Icon(
                                            MdiIcons.mapMarkerOutline,
                                            size: 24),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: addressTFController,
                                    ),
                                    Divider(
                                      height: 0,
                                    ),
                                    TextFormField(
                                      style: allTFStyle,
                                      decoration: InputDecoration(
                                        hintStyle: allTFHintStyle,
                                        hintText:
                                            Translator.translate("address") +
                                                " 2",
                                        border: allTFBorder,
                                        enabledBorder: allTFBorder,
                                        focusedBorder: allTFBorder,
                                        prefixIcon: Icon(
                                          MdiIcons.mapMarkerPlusOutline,
                                          size: 24,
                                        ),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: address2TFController,
                                    ),
                                    Divider(
                                      height: 0,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            style: allTFStyle,
                                            decoration: InputDecoration(
                                              hintStyle: allTFHintStyle,
                                              hintText:
                                                  Translator.translate("city"),
                                              border: allTFBorder,
                                              enabledBorder: allTFBorder,
                                              focusedBorder: allTFBorder,
                                              prefixIcon: Icon(
                                                MdiIcons.homeCityOutline,
                                                size: 24,
                                              ),
                                            ),
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: cityTFController,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: Spacing.left(8),
                                            child: TextFormField(
                                              style: allTFStyle,
                                              decoration: InputDecoration(
                                                hintStyle: allTFHintStyle,
                                                hintText:
                                                    Translator.translate("PIN"),
                                                border: allTFBorder,
                                                enabledBorder: allTFBorder,
                                                focusedBorder: allTFBorder,
                                                prefixIcon: Icon(
                                                  MdiIcons.numeric,
                                                  size: 24,
                                                ),
                                              ),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(),
                                              controller: pincodeTFController,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: Spacing.top(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Icon(
                                        MdiIcons.chevronLeft,
                                        color:
                                            themeData.colorScheme.onBackground,
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all(
                                                        Spacing.xy(24, 12)),
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ))),
                                            onPressed: () {
                                              _updateAddress();
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  margin: Spacing.right(16),
                                                  child: isInProgress
                                                      ? Container(
                                                          width: 16,
                                                          height: 16,
                                                          child: CircularProgressIndicator(
                                                              valueColor: AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  themeData
                                                                      .colorScheme
                                                                      .onPrimary),
                                                              strokeWidth: 1.4),
                                                        )
                                                      : ClipOval(
                                                          child: Icon(
                                                            MdiIcons.check,
                                                            color: themeData
                                                                .colorScheme
                                                                .onPrimary,
                                                            size: 18,
                                                          ),
                                                        ),
                                                ),
                                                Text(
                                                    Translator.translate(
                                                            "update_address")
                                                        .toUpperCase(),
                                                    style:
                                                        AppTheme.getTextStyle(
                                                            themeData.textTheme
                                                                .caption,
                                                            fontSize: 12,
                                                            fontWeight: 600,
                                                            letterSpacing: 0.5,
                                                            color: themeData
                                                                .colorScheme
                                                                .onPrimary)),
                                              ],
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ))
                    ],
                  ),
                )));
      },
    );
  }

  void showMessage({String message = "Something wrong", Duration? duration}) {
    if (duration == null) {
      duration = Duration(seconds: 3);
    }
    _scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(message,
            style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData.colorScheme.onPrimary)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}
