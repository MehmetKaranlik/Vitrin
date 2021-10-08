import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../api/api_util.dart';
import '../../models/AppData.dart';
import '../../models/MyResponse.dart';
import '../../models/Shop.dart';
import '../../utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../controllers/HomeFilterController.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../HomeScreen.dart';

class HomeFilterScreen extends StatefulWidget {
  @override
  _HomeFilterScreenState createState() => _HomeFilterScreenState();
}

class _HomeFilterScreenState extends State<HomeFilterScreen> {
  //UI variables
  List<AppData>? appdata;
  Position? position;
  late ThemeData themeData;
  CustomAppTheme? customAppTheme;
  OutlineInputBorder? allTFBorder;
  TextStyle? allTFStyle, allTFHintStyle;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  GoogleMapController? mapController;
  Set<Marker> _markers = HashSet();
  double? enlem = 0.0;
  double? boylam = 0.0;
  late LatLng currentPosition;
  List<Shop>? shops;
  Marker marker = Marker(markerId: MarkerId("1"), position: LatLng(0.0, 0.0));

  bool isInProgress = false;
  double _currentSliderValue = 0;
  Set<Circle>? myCircles = Set.from([
    Circle(
        circleId: CircleId('1'),
        center: LatLng(0.0, 0.0),
        radius: 15,
        strokeWidth: 1,
        strokeColor: Colors.blue.withOpacity(0.3),
        fillColor: Colors.blue.withOpacity(0.3))
  ]);
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
    getShops();
    _getLocation();
  }

  getShops() async {
    MyResponse<Map<String, dynamic>> myResponse =
        await HomeFilterController.getAllShops();
    if (myResponse.data != null) {
      shops = myResponse.data![HomeFilterController.shops];
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      //showMessage(message: myResponse.errorText);
    }
  }

  _getLocation() async {
    position = await Geolocator.getCurrentPosition();
  }

  @override
  dispose() {
    super.dispose();
    mapController!.dispose();
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

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    setState(() {
      _markers.add(marker);
    });
  }

  Future<void> gettingLocation() async {
    LocationPermission locationPermission = await _setupLocationPermission();
    if (locationPermission != LocationPermission.always &&
        locationPermission != LocationPermission.whileInUse) {
      return;
    }
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double zoom = await mapController!.getZoomLevel();
      myCircles = Set.from([
        Circle(
            circleId: CircleId('1'),
            center: LatLng(position.latitude, position.longitude),
            radius: _currentSliderValue,
            strokeWidth: 1,
            strokeColor: Colors.blue.withOpacity(0.3),
            fillColor: Colors.blue.withOpacity(0.3))
      ]);
      setState(() {});
      _changeLocation(zoom, LatLng(position.latitude, position.longitude));
    } catch (error) {}
  }

  void _onMapTap(LatLng latLong) {
    mapController!
        .getZoomLevel()
        .then((zoom) => {_changeLocation(zoom, latLong)});
    myCircles = Set.from([
      Circle(
          circleId: CircleId('1'),
          center: latLong,
          fillColor: Colors.blue.withOpacity(0.3),
          radius: _currentSliderValue,
          strokeWidth: 1,
          strokeColor: Colors.blue.withOpacity(0.3))
    ]);
    setState(() {
      enlem = latLong.latitude;
      boylam = latLong.longitude;
    });
  }

  void _changeLocation(double zoom, LatLng latLng) {
    double newZoom = zoom;
    currentPosition = latLng;
    setState(() {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: newZoom)));
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('1'),
        position: latLng,
      ));
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
                floatingActionButton: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: FloatingActionButton(
                    backgroundColor: appdata == null
                        ? Colors.purple
                        : HexColor(appdata!.first.mainColor),
                    onPressed: () {
                      gettingLocation();
                    },
                    child: Icon(
                      MdiIcons.mapMarkerOutline,
                      color: themeData.colorScheme.onPrimary,
                    ),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endTop,
                body: enlem == 0.0
                    ? _loading()
                    : Container(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                                child: GoogleMap(
                              onMapCreated: _onMapCreated,
                              markers: _markers,
                              circles: myCircles!,
                              onTap: _onMapTap,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(enlem!, boylam!), zoom: 15),
                              mapType: MapType.normal,
                              //myLocationEnabled: true,
                            )),
                            Container(
                                padding: Spacing.fromLTRB(24, 8, 24, 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: themeData.cardTheme.color,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeData
                                                .cardTheme.shadowColor!
                                                .withAlpha(28),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: Spacing.top(16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            child: Center(
                                              child: SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                  activeTrackColor:
                                                      appdata == null
                                                          ? Colors.purple
                                                          : HexColor(appdata!
                                                              .first.mainColor),
                                                  inactiveTrackColor:
                                                      appdata == null
                                                          ? Colors.purple
                                                          : HexColor(appdata!
                                                              .first
                                                              .secondColor),
                                                  trackShape:
                                                      RoundedRectSliderTrackShape(),
                                                  trackHeight: 4.0,
                                                  thumbShape:
                                                      RoundSliderThumbShape(
                                                          enabledThumbRadius:
                                                              12.0),
                                                  thumbColor: appdata == null
                                                      ? Colors.purple
                                                      : HexColor(appdata!
                                                          .first.mainColor),
                                                  //overlayColor: appdata == null ? Colors.purple : HexColor(appdata!.first.mainColor),
                                                  overlayShape:
                                                      RoundSliderOverlayShape(
                                                          overlayRadius: 28.0),
                                                  tickMarkShape:
                                                      RoundSliderTickMarkShape(),
                                                  activeTickMarkColor:
                                                      Colors.white,
                                                  inactiveTickMarkColor:
                                                      Colors.white,
                                                  valueIndicatorShape:
                                                      PaddleSliderValueIndicatorShape(),
                                                  valueIndicatorColor:
                                                      appdata == null
                                                          ? Colors.purple
                                                          : HexColor(appdata!
                                                              .first.mainColor),
                                                  valueIndicatorTextStyle:
                                                      TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                child: Slider(
                                                  value: _currentSliderValue,
                                                  min: 0,
                                                  max: 15000,
                                                  divisions: 15,
                                                  label: _currentSliderValue
                                                      .round()
                                                      .toString(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      myCircles = Set.from([
                                                        Circle(
                                                            circleId:
                                                                CircleId('1'),
                                                            center: LatLng(
                                                                enlem!,
                                                                boylam!),
                                                            radius:
                                                                _currentSliderValue,
                                                            strokeWidth: 1,
                                                            strokeColor: Colors
                                                                .blue
                                                                .withOpacity(
                                                                    0.3),
                                                            fillColor: Colors
                                                                .blue
                                                                .withOpacity(
                                                                    0.3))
                                                      ]);
                                                      _currentSliderValue =
                                                          value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        margin: Spacing.top(16),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: appdata == null
                                                        ? Colors.purple
                                                        : HexColor(appdata!
                                                            .first.mainColor)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                /*child: Icon(
                                            MdiIcons.chevronLeft,
                                            color: themeData.colorScheme.onBackground,
                                          ),*/
                                                child: Text("Back"),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary: appdata == null
                                                        ? Colors.purple
                                                        : HexColor(appdata!
                                                            .first.mainColor)),
                                                onPressed: () async {
                                                  Navigator.pop(context,
                                                      _currentSliderValue);
                                                },
                                                child: Text("Apply Filter"),
                                              )
                                            ]))
                                  ],
                                ))
                          ],
                        ),
                      )));
      },
    );
  }

  void getData() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      enlem = position.latitude;
      boylam = position.longitude;
      marker = Marker(
          onTap: () {
            print('Tapped');
          },
          draggable: true,
          markerId: MarkerId('1'),
          position: LatLng(position.latitude, position.longitude),
          onDragEnd: ((newPosition) {}));
      currentPosition = LatLng(position.latitude, position.longitude);

      myCircles = Set.from([
        Circle(
            circleId: CircleId('1'),
            center: LatLng(position.latitude, position.longitude),
            radius: _currentSliderValue,
            strokeWidth: 1,
            strokeColor: Colors.blue.withOpacity(0.3),
            fillColor: Colors.blue.withOpacity(0.3))
      ]);
    });
  }

  _loading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
