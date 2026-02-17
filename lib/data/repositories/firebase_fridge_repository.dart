// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:meal_planner/core/constants/firebase_constants.dart';
// import 'package:meal_planner/data/model/FridgeProduct.dart';
// import 'package:meal_planner/data/model/Product.dart';
// import 'package:meal_planner/domain/repositories/fridge_repository.dart';
//
// class FirebaseFridgeRepository implements FridgeRepository {
//   final FirebaseFirestore firestore;
//   final FirebaseStorage storage;
//   final String Function() getCurrentGroupId;
//
//   FirebaseFridgeRepository({
//     required this.firestore,
//     required this.storage,
//     required this.getCurrentGroupId,
//   });
//   CollectionReference get fridgeCollection =>
//       firestore.collection(FirebaseConstants.fridgeCollection);
//
//   @override
//   Future<List<Product>> getProductList(String groupID) async {
//     List<dynamic>? data;
//     List<Product> products = [];
//     await fridgeCollection
//         .doc(groupID)
//         .collection("products")
//         .get()
//         .then((value) {
//       data = value.docs.map((doc) => doc.data()).toList();
//     });
//     data?.forEach((element) {
//       products.add(Product(
//           title: element["name"],
//           number: element["number"].toDouble(),
//           unit: element["unit"],
//           category: element["category"]));
//     });
//     return products;
//   }
//
//   @override
//   Future<void> removeProductFromList(String groupID, Product product) async {
//     await fridgeCollection
//         .doc(groupID)
//         .collection("products")
//         .doc(product.title)
//         .delete();
//   }
//
//   @override
//   Future<void> saveGoodiesPerCategoryList(
//       String groupID, String category, List<FridgeProduct> goodies) async {
//     List<Map<String, dynamic>> fridgeProducts = [];
//     for (int i = 0; i < goodies.length; i++) {
//       var entry = {
//         "name": goodies[i].title,
//         "category": goodies[i].category,
//         "number": goodies[i].number,
//         "unit": goodies[i].unit,
//       };
//       fridgeProducts.add(entry);
//     }
//     await fridgeCollection
//         .doc(groupID)
//         .collection("goodies")
//         .doc(category)
//         .set({"goodies": fridgeProducts});
//   }
//
//   @override
//   Future<void> updateGoodiesPerCategoryList(
//       String groupID, String category, List<FridgeProduct> goodies) async {
//     List<Map<String, dynamic>> fridgeProducts = [];
//     for (int i = 0; i < goodies.length; i++) {
//       var entry = {
//         "name": goodies[i].title,
//         "category": goodies[i].category,
//         "number": goodies[i].number,
//         "unit": goodies[i].unit,
//       };
//       fridgeProducts.add(entry);
//     }
//     await fridgeCollection
//         .doc(groupID)
//         .collection("goodies")
//         .doc(category)
//         .update({"goodies": fridgeProducts});
//   }
//
//   @override
//   Future<List<FridgeProduct>> getGoodiesPerCategory(
//       String groupID, String category) async {
//     List<dynamic>? data;
//     List<FridgeProduct> products = [];
//     await fridgeCollection
//         .doc(groupID)
//         .collection("goodies")
//         .doc(category)
//         .get()
//         .then((value) {
//       data = value.data()?["goodies"];
//     });
//     data?.forEach((element) {
//       products.add(FridgeProduct(
//           title: element["name"],
//           number: element["number"].toDouble(),
//           unit: element["unit"],
//           category: element["category"]));
//     });
//     return products;
//   }
//
//   @override
//   Future<bool> addProductToList(String groupID, Product product) async {
//     var doc = await fridgeCollection
//         .doc(groupID)
//         .collection("products")
//         .doc(product.title)
//         .get();
//
//     if (!doc.exists) {
//       await fridgeCollection
//           .doc(groupID)
//           .collection("products")
//           .doc(product.title)
//           .set({
//         'name': product.title,
//         'category': product.category,
//         'number': product.number,
//         'unit': product.unit,
//       });
//       return true;
//     } else {
//       return false;
//     }
//   }
// }
