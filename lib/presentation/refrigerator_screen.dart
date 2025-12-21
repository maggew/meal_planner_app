import 'package:async/async.dart';
//import 'package:bi_counter_field/bi_counter_field.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/appstyle/app_icons.dart';
import 'package:meal_planner/model/FridgeProduct.dart';
import 'package:meal_planner/model/Product.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/services/database.dart';
import 'package:meal_planner/widgets/DoubleCounter_widget.dart';
import 'package:multi_split_view/multi_split_view.dart';

class RefrigeratorScreen extends StatefulWidget {
  static const route = '/refrigerator';

  @override
  State<RefrigeratorScreen> createState() => _RefrigeratorScreen();
}

class _RefrigeratorScreen extends State<RefrigeratorScreen> {
  late AsyncMemoizer _memoizer;

  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getScreenHeightExcludeSafeArea(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return height - padding.top - padding.bottom;
  }

  double getHeightOfDropDownMenu(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return padding.top;
  }

  _fetchData() async {
    return this._memoizer.runOnce(() async {
      // This below code will call only ones. This will return the same data directly without performing any Future task.
      allProducts = await Database().getProductList();
      iceProducts = await Database().getGoodiesPerCategory("ice");
      berryProducts = await Database().getGoodiesPerCategory("berry");
      vegetableProducts = await Database().getGoodiesPerCategory("vegetable");
      potatoProducts = await Database().getGoodiesPerCategory("potato");
      animalProducts = await Database().getGoodiesPerCategory("animal");
      otherProducts = await Database().getGoodiesPerCategory("others");
    });
  }

  GlobalKey<FormState> _formCheck = new GlobalKey();

  // MultiSplitViewController _controller =
  //     MultiSplitViewController(weights: [0.1, 0.5]);

  final ScrollController _firstController = ScrollController();
  final ScrollController _secondController = ScrollController();

  String unit = "kg";
  late double number;

  List productUnits = [
    {'label': 'kg', 'value': '1'},
    {'label': 'Port.', 'value': '2'},
    {'label': 'Pck.', 'value': '3'},
  ];

  String category = "Eis";
  List _categories = [
    {'label': 'Eis,\nDesserts', 'value': '1'},
    {'label': 'Beeren,\nObst', 'value': '2'},
    {'label': 'Gemüse,\nKräuter', 'value': '3'},
    {'label': 'Kartoffel-\nprodukte', 'value': '4'},
    {'label': 'Fleisch,\nFisch', 'value': '5'},
    {'label': 'Sonstiges,\nGekochtes', 'value': '6'},
  ];

  List<FridgeProduct> iceProducts = [];
  List<FridgeProduct> berryProducts = [];
  List<FridgeProduct> vegetableProducts = [];
  List<FridgeProduct> potatoProducts = [];
  List<FridgeProduct> animalProducts = [];
  List<FridgeProduct> otherProducts = [];

  List<Product> allProducts = [];

  //Screen is locked to landscape mode
  @override
  void initState() {
    super.initState();
    _memoizer = AsyncMemoizer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //TODO add circularProgressIndicator, ohne dass die Scrollbar wieder nach oben springt

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Opacity(
            opacity: 0.55,
            child: RotatedBox(
              quarterTurns: 3,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image(
                  image: AssetImage('assets/images/background.png'),
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            centerTitle: true,
            /*title: FittedBox(
              child: Text(
                "Gefriertruhe",
                style: Theme.of(context).textTheme.headline2,
              ),
            ),*/
          ),
          body: FutureBuilder(
              future: _fetchData(),
              builder: (context, snapshot) {
                /*if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(
                    color: Colors.green,
                  ));
                }*/
                return MultiSplitViewTheme(
                  data: MultiSplitViewThemeData(
                    dividerThickness: 50,
                    dividerPainter: DividerPainters.dashed(
                        thickness: 2,
                        color: Colors.teal[600]!,
                        highlightedColor: Colors.teal[300]),
                  ),
                  child: MultiSplitView(
                    //onSizeChange: (int childIndex1, int childIndex2) {},
                    axis: Axis.horizontal,
                    //controller: _controller,
                    //minimalWeight: 0.1,
                    //   children: [
                    //     Column(
                    //       children: [
                    //         FittedBox(
                    //           child: Row(
                    //             children: [
                    //               Text(
                    //                 "Produkte",
                    //                 style:
                    //                     Theme.of(context).textTheme.displayMedium,
                    //               ),
                    //               Container(
                    //                 height: 30,
                    //                 child: FloatingActionButton(
                    //                   onPressed: () => showDialog(
                    //                       barrierDismissible: true,
                    //                       context: context,
                    //                       builder: (BuildContext context) =>
                    //                           addProduct()),
                    //                   backgroundColor: Colors.lightGreen[100],
                    //                   child: Icon(
                    //                     AppIcons.plus_1,
                    //                     size: 25,
                    //                     color: Colors.black,
                    //                   ),
                    //                   elevation: 3,
                    //                 ),
                    //               ),
                    //               SizedBox(height: 35),
                    //             ],
                    //           ),
                    //         ),
                    //         SizedBox(height: 15),
                    //         Expanded(
                    //           child: Container(
                    //             height: MediaQuery.of(context).size.height,
                    //             width: MediaQuery.of(context).size.width,
                    //             margin: EdgeInsets.all(5),
                    //             decoration: BoxDecoration(
                    //               color: Colors.white,
                    //               boxShadow: [
                    //                 BoxShadow(
                    //                   color: Colors.black26,
                    //                   blurRadius: 10.0,
                    //                   spreadRadius: 0.0,
                    //                   offset: Offset(5.0,
                    //                       5.0), // shadow direction: bottom right
                    //                 ),
                    //               ],
                    //             ),
                    //             child: Scrollbar(
                    //               radius: Radius.circular(10),
                    //               interactive: true,
                    //               controller: _firstController,
                    //               thickness: 10,
                    //               thumbVisibility: true,
                    //               child: ListView.builder(
                    //                 controller: _firstController,
                    //                 itemCount: allProducts.length,
                    //                 itemBuilder: (context, i) {
                    //                   return GestureDetector(
                    //                     onLongPress: () {
                    //                       showDialog(
                    //                           barrierColor: Colors.transparent,
                    //                           barrierDismissible: true,
                    //                           context: context,
                    //                           builder: (BuildContext context) {
                    //                             return showDeleteDialog(
                    //                                 allProducts[i]);
                    //                           });
                    //                     },
                    //                     child: Draggable<Product>(
                    //                       feedback: buildProductContainer(
                    //                           allProducts[i]),
                    //                       data: allProducts[i],
                    //                       childWhenDragging:
                    //                           buildProductContainer(
                    //                               allProducts[i]),
                    //                       child: buildProductContainer(
                    //                           allProducts[i]),
                    //                     ),
                    //                   );
                    //                 },
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     Column(
                    //       children: [
                    //         FittedBox(
                    //           child: Row(
                    //             children: [
                    //               Text(
                    //                 "Gefriertruhe",
                    //                 style:
                    //                     Theme.of(context).textTheme.displayMedium,
                    //               ),
                    //               SizedBox(width: 20),
                    //               DragTarget<FridgeProduct>(onAcceptWithDetails:
                    //                   (FridgeProduct fridgeProduct) {
                    //                 removeProductFromFridge(fridgeProduct);
                    //                 setState(() {});
                    //               }, builder: (
                    //                 BuildContext context,
                    //                 List<dynamic> accepted,
                    //                 List<dynamic> rejected,
                    //               ) {
                    //                 return Container(
                    //                   height: 35,
                    //                   width: 35,
                    //                   child: Icon(
                    //                     AppIcons.trash_bin,
                    //                     color: Colors.black,
                    //                   ),
                    //                 );
                    //               }),
                    //             ],
                    //           ),
                    //         ),
                    //         SizedBox(height: 15),
                    //         Expanded(
                    //           flex: 1,
                    //           child: Scrollbar(
                    //             thumbVisibility: true,
                    //             controller: _secondController,
                    //             interactive: true,
                    //             thickness: 10,
                    //             scrollbarOrientation: ScrollbarOrientation.left,
                    //             child: SingleChildScrollView(
                    //               controller: _secondController,
                    //               child: DragTarget<Product>(
                    //                 onAcceptWithDetails: (Product product) {
                    //                   checkProductCategory(product);
                    //                   setState(() {});
                    //                 },
                    //                 builder: (
                    //                   BuildContext context,
                    //                   List<dynamic> accepted,
                    //                   List<dynamic> rejected,
                    //                 ) {
                    //                   return Container(
                    //                     color: Colors.grey[50],
                    //                     child: Column(
                    //                       children: [
                    //                         Container(
                    //                           height: 180,
                    //                           width: MediaQuery.of(context)
                    //                               .size
                    //                               .width,
                    //                           margin: EdgeInsets.only(
                    //                               left: 10,
                    //                               right: 10,
                    //                               top: 10,
                    //                               bottom: 5),
                    //                           child: GridView.builder(
                    //                             itemCount: iceProducts.length,
                    //                             itemBuilder: (context, i) {
                    //                               return buildGoodsContainer(
                    //                                   iceProducts[i]);
                    //                             },
                    //                             gridDelegate:
                    //                                 SliverGridDelegateWithFixedCrossAxisCount(
                    //                               crossAxisCount: 2,
                    //                               mainAxisExtent: 80,
                    //                             ),
                    //                           ),
                    //                           decoration: BoxDecoration(
                    //                             image: DecorationImage(
                    //                               fit: BoxFit.cover,
                    //                               colorFilter:
                    //                                   new ColorFilter.mode(
                    //                                       Colors.black
                    //                                           .withOpacity(0.6),
                    //                                       BlendMode.dstATop),
                    //                               image: new AssetImage(
                    //                                 'assets/images/ice_cube.jpg',
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         Container(
                    //                           height: 180,
                    //                           width: MediaQuery.of(context)
                    //                               .size
                    //                               .width,
                    //                           margin: EdgeInsets.only(
                    //                               left: 10,
                    //                               right: 10,
                    //                               top: 5,
                    //                               bottom: 5),
                    //                           child: GridView.builder(
                    //                             itemCount: berryProducts.length,
                    //                             itemBuilder: (context, i) {
                    //                               return buildGoodsContainer(
                    //                                   berryProducts[i]);
                    //                             },
                    //                             gridDelegate:
                    //                                 SliverGridDelegateWithFixedCrossAxisCount(
                    //                               crossAxisCount: 2,
                    //                               mainAxisExtent: 80,
                    //                             ),
                    //                           ),
                    //                           decoration: BoxDecoration(
                    //                             image: DecorationImage(
                    //                               fit: BoxFit.cover,
                    //                               colorFilter:
                    //                                   new ColorFilter.mode(
                    //                                       Colors.black
                    //                                           .withOpacity(0.6),
                    //                                       BlendMode.dstATop),
                    //                               image: new AssetImage(
                    //                                 'assets/images/berries.jpg',
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         Container(
                    //                           height: 180,
                    //                           width: MediaQuery.of(context)
                    //                               .size
                    //                               .width,
                    //                           margin: EdgeInsets.only(
                    //                               left: 10,
                    //                               right: 10,
                    //                               top: 5,
                    //                               bottom: 5),
                    //                           child: GridView.builder(
                    //                             itemCount:
                    //                                 vegetableProducts.length,
                    //                             itemBuilder: (context, i) {
                    //                               return buildGoodsContainer(
                    //                                   vegetableProducts[i]);
                    //                             },
                    //                             gridDelegate:
                    //                                 SliverGridDelegateWithFixedCrossAxisCount(
                    //                               crossAxisCount: 2,
                    //                               mainAxisExtent: 80,
                    //                             ),
                    //                           ),
                    //                           decoration: BoxDecoration(
                    //                             image: DecorationImage(
                    //                               fit: BoxFit.cover,
                    //                               colorFilter:
                    //                                   new ColorFilter.mode(
                    //                                       Colors.black
                    //                                           .withOpacity(0.6),
                    //                                       BlendMode.dstATop),
                    //                               image: new AssetImage(
                    //                                 'assets/images/peas.jpg',
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         Container(
                    //                           height: 180,
                    //                           width: MediaQuery.of(context)
                    //                               .size
                    //                               .width,
                    //                           margin: EdgeInsets.only(
                    //                               left: 10,
                    //                               right: 10,
                    //                               top: 5,
                    //                               bottom: 5),
                    //                           child: GridView.builder(
                    //                             itemCount: potatoProducts.length,
                    //                             itemBuilder: (context, i) {
                    //                               return buildGoodsContainer(
                    //                                   potatoProducts[i]);
                    //                             },
                    //                             gridDelegate:
                    //                                 SliverGridDelegateWithFixedCrossAxisCount(
                    //                               crossAxisCount: 2,
                    //                               mainAxisExtent: 80,
                    //                             ),
                    //                           ),
                    //                           decoration: BoxDecoration(
                    //                             image: DecorationImage(
                    //                               fit: BoxFit.cover,
                    //                               colorFilter:
                    //                                   new ColorFilter.mode(
                    //                                       Colors.black
                    //                                           .withOpacity(0.6),
                    //                                       BlendMode.dstATop),
                    //                               image: new AssetImage(
                    //                                 'assets/images/potatoes.jpg',
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         Container(
                    //                           height: 180,
                    //                           width: MediaQuery.of(context)
                    //                               .size
                    //                               .width,
                    //                           margin: EdgeInsets.only(
                    //                               left: 10,
                    //                               right: 10,
                    //                               top: 5,
                    //                               bottom: 5),
                    //                           child: GridView.builder(
                    //                             itemCount: animalProducts.length,
                    //                             itemBuilder: (context, i) {
                    //                               return buildGoodsContainer(
                    //                                   animalProducts[i]);
                    //                             },
                    //                             gridDelegate:
                    //                                 SliverGridDelegateWithFixedCrossAxisCount(
                    //                               crossAxisCount: 2,
                    //                               mainAxisExtent: 80,
                    //                             ),
                    //                           ),
                    //                           decoration: BoxDecoration(
                    //                             image: DecorationImage(
                    //                               fit: BoxFit.cover,
                    //                               colorFilter:
                    //                                   new ColorFilter.mode(
                    //                                       Colors.black
                    //                                           .withOpacity(0.6),
                    //                                       BlendMode.dstATop),
                    //                               image: new AssetImage(
                    //                                 'assets/images/shrimps.jpg',
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         Container(
                    //                           height: 180,
                    //                           width: MediaQuery.of(context)
                    //                               .size
                    //                               .width,
                    //                           margin: EdgeInsets.only(
                    //                               left: 10,
                    //                               right: 10,
                    //                               top: 5,
                    //                               bottom: 10),
                    //                           child: GridView.builder(
                    //                             itemCount: otherProducts.length,
                    //                             itemBuilder: (context, i) {
                    //                               return buildGoodsContainer(
                    //                                   otherProducts[i]);
                    //                             },
                    //                             gridDelegate:
                    //                                 SliverGridDelegateWithFixedCrossAxisCount(
                    //                               crossAxisCount: 2,
                    //                               mainAxisExtent: 80,
                    //                             ),
                    //                           ),
                    //                           decoration: BoxDecoration(
                    //                             image: DecorationImage(
                    //                               fit: BoxFit.cover,
                    //                               colorFilter:
                    //                                   new ColorFilter.mode(
                    //                                       Colors.black
                    //                                           .withOpacity(0.6),
                    //                                       BlendMode.dstATop),
                    //                               image: new AssetImage(
                    //                                 'assets/images/pizza_1.jpg',
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   );
                    //                 },
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ),
                );
              }),
        )
      ],
    );
  }

  Widget addProduct() {
    String pTitle = "";
    String pCategory = "ice";
    double pNumber = 1.0;
    String pUnit = "kg";

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 540,
        child: SingleChildScrollView(
          child: AlertDialog(
            contentPadding: EdgeInsets.only(left: 20, top: 20),
            actionsPadding: EdgeInsets.only(right: 21),
            insetPadding: EdgeInsets.only(left: 30, right: 30, top: 50),
            elevation: 10,
            backgroundColor: Colors.lightGreen[100],
            title: Stack(
              children: [
                Text(
                  "Welches Produkt möchtest du hinzufügen?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.aBeeZee().fontFamily,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  top: -15,
                  right: -14,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
            content: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 27),
                  child: Form(
                    key: _formCheck,
                    child: TextFormField(
                      //validator: _validateProductName,
                      autovalidateMode: AutovalidateMode.disabled,
                      onChanged: (v) {
                        pTitle = v;
                      },
                      decoration: InputDecoration(
                        hintText: "Produkt eingeben",
                        labelText: "Produktbezeichnung",
                        errorStyle: Theme.of(context).textTheme.bodyLarge,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueGrey,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Kategorie",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(width: 15),
                    // CoolDropdown(
                    //   gap: 0,
                    //   isAnimation: false,
                    //   isTriangle: false,
                    //   dropdownWidth: 156,
                    //   dropdownBD: BoxDecoration(
                    //     border: Border.all(color: Colors.blueGrey, width: 1.5),
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.all(Radius.circular(3)),
                    //   ),
                    //   dropdownItemTopGap: 10,
                    //   selectedItemTS: TextStyle(
                    //     color: Colors.green,
                    //     fontFamily: GoogleFonts.quicksand(
                    //       fontWeight: FontWeight.w500,
                    //     ).fontFamily,
                    //     fontSize: 15,
                    //   ),
                    //   unselectedItemTS: TextStyle(
                    //     color: Colors.black,
                    //     fontFamily: GoogleFonts.quicksand(
                    //       fontWeight: FontWeight.w500,
                    //     ).fontFamily,
                    //     fontSize: 15,
                    //   ),
                    //   resultTS:
                    //       Theme.of(context).inputDecorationTheme.hintStyle,
                    //   resultBD: BoxDecoration(
                    //     border: Border.all(color: Colors.blueGrey, width: 1.5),
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.all(Radius.circular(3)),
                    //   ),
                    //   resultHeight: 60,
                    //   resultWidth: 179,
                    //   dropdownHeight: 345,
                    //   dropdownList: _categories,
                    //   defaultValue: _categories[0],
                    //   onChange: (v) {
                    //     var result = v.values.toList();
                    //     pCategory = adjustCategory(result[0]);
                    //   },
                    // ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Anzahl",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(width: 37),
                    DoubleCounter(
                        width: 178,
                        borderWidth: 1.5,
                        borderColor: Colors.blueGrey,
                        supportFraction: true,
                        enabled: true,
                        minLimit: 0.1,
                        maxLimit: 100,
                        stepValue: 0.1,
                        initialValue: 1.0,
                        onChanged: (value) {
                          if (value == null)
                            pNumber = 1.0;
                          else {
                            pNumber = double.parse(value);
                          }
                        }),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Einheit",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(width: 42),
                    // CoolDropdown(
                    //   gap: 0,
                    //   isAnimation: false,
                    //   isTriangle: false,
                    //   dropdownWidth: 156,
                    //   dropdownBD: BoxDecoration(
                    //     border: Border.all(color: Colors.blueGrey, width: 1.5),
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.all(Radius.circular(3)),
                    //   ),
                    //   dropdownItemTopGap: 10,
                    //   selectedItemTS: TextStyle(
                    //     color: Colors.green,
                    //     fontFamily: GoogleFonts.quicksand(
                    //       fontWeight: FontWeight.w500,
                    //     ).fontFamily,
                    //     fontSize: 15,
                    //   ),
                    //   unselectedItemTS: TextStyle(
                    //     color: Colors.black,
                    //     fontFamily: GoogleFonts.quicksand(
                    //       fontWeight: FontWeight.w500,
                    //     ).fontFamily,
                    //     fontSize: 15,
                    //   ),
                    //   resultTS:
                    //       Theme.of(context).inputDecorationTheme.hintStyle,
                    //   resultBD: BoxDecoration(
                    //     border: Border.all(color: Colors.blueGrey, width: 1.5),
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.all(Radius.circular(3)),
                    //   ),
                    //   resultHeight: 45,
                    //   resultWidth: 179,
                    //   dropdownHeight: 180,
                    //   dropdownList: productUnits,
                    //   defaultValue: productUnits[0],
                    //   onChange: (v) {
                    //     var result = v.values.toList();
                    //     pUnit = result[0];
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
            actions: [
              SizedBox(
                height: 60,
                width: 100,
                child: FittedBox(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Colors.lightGreen[300],
                      ),
                      onPressed: () {
                        if (_formCheck.currentState?.validate() == true) {
                          Product newProduct = new Product(
                              title: pTitle,
                              category: pCategory,
                              number: pNumber,
                              unit: pUnit);
                          Database().addProductToList(newProduct).then((value) {
                            if (!value) {
                              Fluttertoast.showToast(
                                msg: newProduct.title + " existiert schon.",
                                timeInSecForIosWeb: 5,
                              );
                            } else {
                              allProducts.add(newProduct);
                              allProducts
                                  .sort((a, b) => a.title.compareTo(b.title));
                              Navigator.pop(context);
                            }
                          });
                        }
                      },
                      child: Text("Speichern")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkProductCategory(Product product) {
    FridgeProduct fridgeProduct = new FridgeProduct(
        title: product.title,
        category: product.category,
        unit: product.unit,
        number: product.number);

    if (fridgeProduct.category == 'ice') {
      if (!iceProducts.any((item) => item.title == fridgeProduct.title)) {
        iceProducts.add(fridgeProduct);
        Database().updateGoodiesPerCategoryList("ice", iceProducts);
      } else {
        Fluttertoast.showToast(
          timeInSecForIosWeb: 5,
          msg: fridgeProduct.title + " befindet sich schon im Gefrierschrank!",
        );
      }
    } else if (fridgeProduct.category == 'berry') {
      if (!berryProducts.any((item) => item.title == fridgeProduct.title)) {
        berryProducts.add(fridgeProduct);
        Database().updateGoodiesPerCategoryList("berry", berryProducts);
      } else {
        Fluttertoast.showToast(
          timeInSecForIosWeb: 5,
          msg: fridgeProduct.title + " befindet sich schon im Gefrierschrank!",
        );
      }
    } else if (fridgeProduct.category == 'vegetable') {
      if (!vegetableProducts.any((item) => item.title == fridgeProduct.title)) {
        vegetableProducts.add(fridgeProduct);
        Database().updateGoodiesPerCategoryList("vegetable", vegetableProducts);
      } else {
        Fluttertoast.showToast(
          timeInSecForIosWeb: 5,
          msg: fridgeProduct.title + " befindet sich schon im Gefrierschrank!",
        );
      }
    } else if (fridgeProduct.category == 'potato') {
      if (!potatoProducts.any((item) => item.title == fridgeProduct.title)) {
        potatoProducts.add(fridgeProduct);
        Database().updateGoodiesPerCategoryList("potato", potatoProducts);
      } else {
        Fluttertoast.showToast(
          timeInSecForIosWeb: 5,
          msg: fridgeProduct.title + " befindet sich schon im Gefrierschrank!",
        );
      }
    } else if (fridgeProduct.category == 'animal') {
      if (!animalProducts.any((item) => item.title == fridgeProduct.title)) {
        animalProducts.add(fridgeProduct);
        Database().updateGoodiesPerCategoryList("animal", animalProducts);
      } else {
        Fluttertoast.showToast(
          timeInSecForIosWeb: 5,
          msg: fridgeProduct.title + " befindet sich schon im Gefrierschrank!",
        );
      }
    } else {
      if (!otherProducts.any((item) => item.title == fridgeProduct.title)) {
        otherProducts.add(fridgeProduct);
        Database().updateGoodiesPerCategoryList("others", otherProducts);
      } else {
        Fluttertoast.showToast(
          timeInSecForIosWeb: 5,
          msg: fridgeProduct.title + " befindet sich schon im Gefrierschrank!",
        );
      }
    }
  }

  void changeProductFromFridge(
      FridgeProduct fridgeProduct, double newNumber, String newUnit) {
    int index;
    if (fridgeProduct.category == 'ice') {
      index = iceProducts.indexOf(fridgeProduct);
      iceProducts[index].number = newNumber;
      iceProducts[index].unit = newUnit;
    } else if (fridgeProduct.category == 'berry') {
      index = berryProducts.indexOf(fridgeProduct);
      berryProducts[index].number = newNumber;
      berryProducts[index].unit = newUnit;
    } else if (fridgeProduct.category == 'vegetable') {
      index = vegetableProducts.indexOf(fridgeProduct);
      vegetableProducts[index].number = newNumber;
      vegetableProducts[index].unit = newUnit;
    } else if (fridgeProduct.category == 'potato') {
      index = potatoProducts.indexOf(fridgeProduct);
      potatoProducts[index].number = newNumber;
      potatoProducts[index].unit = newUnit;
    } else if (fridgeProduct.category == 'animal') {
      index = animalProducts.indexOf(fridgeProduct);
      animalProducts[index].number = newNumber;
      animalProducts[index].unit = newUnit;
    } else {
      index = otherProducts.indexOf(fridgeProduct);
      otherProducts[index].number = newNumber;
      otherProducts[index].unit = newUnit;
    }
  }

  void removeProductFromFridge(FridgeProduct fridgeProduct) {
    if (fridgeProduct.category == 'ice') {
      iceProducts.remove(fridgeProduct);
      Database().updateGoodiesPerCategoryList("ice", iceProducts);
    } else if (fridgeProduct.category == 'berry') {
      berryProducts.remove(fridgeProduct);
      Database().updateGoodiesPerCategoryList("berry", berryProducts);
    } else if (fridgeProduct.category == 'vegetable') {
      vegetableProducts.remove(fridgeProduct);
      Database().updateGoodiesPerCategoryList("vegetable", vegetableProducts);
    } else if (fridgeProduct.category == 'potato') {
      potatoProducts.remove(fridgeProduct);
      Database().updateGoodiesPerCategoryList("potato", potatoProducts);
    } else if (fridgeProduct.category == 'animal') {
      animalProducts.remove(fridgeProduct);
      Database().updateGoodiesPerCategoryList("animal", animalProducts);
    } else {
      otherProducts.remove(fridgeProduct);
      Database().updateGoodiesPerCategoryList("others", otherProducts);
    }
  }

  Widget buildProductContainer(Product product) {
    Color containerColor = getProductColor(product);
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          height: 40,
          margin: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
          padding: EdgeInsets.only(top: 3, bottom: 5, left: 15, right: 15),
          alignment: Alignment.centerRight,
          child: FittedBox(
            child: Text(
              product.title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }

  Color getProductColor(Product product) {
    Color containerColor;
    if (product.category == 'ice') {
      containerColor = Colors.lightBlue[50]!;
    } else if (product.category == 'berry') {
      containerColor = Colors.purple[100]!;
    } else if (product.category == 'vegetable') {
      containerColor = Colors.lightGreen[100]!;
    } else if (product.category == 'potato') {
      containerColor = Colors.yellow[200]!;
    } else if (product.category == 'animal') {
      containerColor = Colors.red[100]!;
    } else {
      containerColor = Colors.brown[100]!;
    }
    return containerColor;
  }

  Color getGoodsColor(FridgeProduct product) {
    Color containerColor;
    if (product.category == 'ice') {
      containerColor = Colors.lightBlue[50]!;
    } else if (product.category == 'berry') {
      containerColor = Colors.purple[100]!;
    } else if (product.category == 'vegetable') {
      containerColor = Colors.lightGreen[100]!;
    } else if (product.category == 'potato') {
      containerColor = Colors.yellow[200]!;
    } else if (product.category == 'animal') {
      containerColor = Colors.red[100]!;
    } else {
      containerColor = Colors.brown[100]!;
    }
    return containerColor;
  }

  //method for building dragable products in the refridgerator (right side)
  Widget buildGoodsContainer(FridgeProduct product) {
    Color containerColor = getGoodsColor(product);
    return Align(
      child: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return showEditDialog(product);
            },
          );
          setState(() {});
        },
        child: Draggable<FridgeProduct>(
          feedback: buildDraggableContainer(product, containerColor),
          child: buildDraggableContainer(product, containerColor),
          data: product,
          childWhenDragging: Container(),
        ),
      ),
    );
  }

  Widget buildDraggableContainer(
      FridgeProduct fridgeProduct, Color containerColor) {
    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      height: 70,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.only(top: 3, bottom: 5, left: 10, right: 10),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          fridgeProduct.title +
              "\n" +
              fridgeProduct.number.toString() +
              " " +
              fridgeProduct.unit,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget showDeleteDialog(Product product) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(left: 50, right: 50),
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: getProductColor(product),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.only(top: 20, left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title + " löschen?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("Nein"),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("Ja"),
                  ),
                  onPressed: () {
                    Database().removeProductFromList(product);
                    allProducts.remove(product);
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget showEditDialog(FridgeProduct fridgeProduct) {
    List<FridgeProduct> currentGoodies = checkCurrentProductList(fridgeProduct);
    String currentUnit = fridgeProduct.unit;
    int counter = 0;
    for (var map in productUnits) {
      if (map.containsKey("label")) {
        if (map["label"] == currentUnit) {
          break;
        }
      }
      counter++;
    }
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        child: AlertDialog(
          contentPadding: EdgeInsets.only(top: 3, left: 8, right: 8, bottom: 8),
          backgroundColor: getGoodsColor(fridgeProduct),
          titlePadding: EdgeInsets.only(left: 29, top: 20),
          title: Text(
            fridgeProduct.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DoubleCounter(
                  borderWidth: 1.5,
                  borderColor: Colors.blueGrey,
                  width: 120,
                  supportFraction: true,
                  enabled: true,
                  minLimit: 0.1,
                  maxLimit: 100,
                  stepValue: 0.1,
                  initialValue: fridgeProduct.number,
                  onChanged: (value) {
                    if (value == null)
                      number = fridgeProduct.number;
                    else {
                      number = double.parse(value);
                    }
                  }),
              SizedBox(width: 10),
              // CoolDropdown(
              //   gap: 0,
              //   isAnimation: false,
              //   isTriangle: false,
              //   dropdownWidth: 68,
              //   dropdownBD: BoxDecoration(
              //     border: Border.all(color: Colors.blueGrey, width: 1.5),
              //     color: Colors.white,
              //     borderRadius: BorderRadius.all(Radius.circular(3)),
              //   ),
              //   dropdownItemTopGap: 10,
              //   selectedItemTS: TextStyle(
              //     color: Colors.green,
              //     fontFamily: GoogleFonts.quicksand(
              //       fontWeight: FontWeight.w500,
              //     ).fontFamily,
              //     fontSize: 15,
              //   ),
              //   unselectedItemTS: TextStyle(
              //     color: Colors.black,
              //     fontFamily: GoogleFonts.quicksand(
              //       fontWeight: FontWeight.w500,
              //     ).fontFamily,
              //     fontSize: 15,
              //   ),
              //   resultTS: Theme.of(context).inputDecorationTheme.hintStyle,
              //   resultBD: BoxDecoration(
              //     border: Border.all(color: Colors.blueGrey, width: 1.5),
              //     color: Colors.white,
              //     borderRadius: BorderRadius.all(Radius.circular(3)),
              //   ),
              //   resultHeight: 35,
              //   resultWidth: 90,
              //   dropdownHeight: 180,
              //   dropdownList: productUnits,
              //   defaultValue: productUnits[counter],
              //   onChange: (v) {
              //     setState(() {
              //       var result = v.values.toList();
              //       unit = result[0];
              //     });
              //   },
              // ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Database().updateGoodiesPerCategoryList(
                      fridgeProduct.category, currentGoodies);
                  setState(() {
                    changeProductFromFridge(fridgeProduct, number, unit);
                  });
                  Navigator.pop(context);
                },
                icon: Icon(Icons.check))
          ],
        ),
      ),
    );
  }

  List<FridgeProduct> checkCurrentProductList(FridgeProduct frProduct) {
    if (iceProducts.contains(frProduct)) {
      return iceProducts;
    } else if (berryProducts.contains(frProduct)) {
      return berryProducts;
    } else if (vegetableProducts.contains(frProduct)) {
      return vegetableProducts;
    } else if (potatoProducts.contains(frProduct)) {
      return potatoProducts;
    } else if (animalProducts.contains(frProduct)) {
      return animalProducts;
    } else {
      return otherProducts;
    }
  }

  String adjustCategory(String oldName) {
    String newName;
    if (oldName == 'Eis,\nDesserts') {
      newName = "ice";
    } else if (oldName == 'Beeren,\nObst') {
      newName = "berry";
    } else if (oldName == 'Gemüse,\nKräuter') {
      newName = "vegetable";
    } else if (oldName == 'Kartoffel-\nprodukte') {
      newName = "potato";
    } else if (oldName == 'Fleisch,\nFisch') {
      newName = "animal";
    } else {
      newName = "others";
    }
    return newName;
  }

  String? _validateProductName(String name) {
    if (name.isEmpty) {
      return "Bitte Produktnamen eingeben";
    }
  }
}
