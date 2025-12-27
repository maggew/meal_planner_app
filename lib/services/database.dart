import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/model/FridgeProduct.dart';
import 'package:meal_planner/model/Product.dart';
import 'package:meal_planner/model/Recipe.dart';
import 'package:path/path.dart';

import 'auth.dart';

class Database {
  Auth auth = Auth();

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');
  final CollectionReference recipeCollection =
      FirebaseFirestore.instance.collection('recipes');
  final CollectionReference fridgeCollection =
      FirebaseFirestore.instance.collection('refrigerator');

  /*Future saveProductsPerCategory(List<Product> products, String category) async{
    String groupID = await getCurrentGroupID();
    products.forEach((product) async {
        await fridgeCollection.doc(groupID).collection(category).add({
          'title': product.title,
          'category': product.category,
          'number': product.number,
          'unit': product.unit,
      });
    });
  }*/

  Future getProductList() async {
    List<dynamic>? data;
    List<Product> products = [];
    String groupID = await getCurrentGroupID();
    await fridgeCollection
        .doc(groupID)
        .collection("products")
        .get()
        .then((value) {
      data = value.docs.map((doc) => doc.data()).toList();
    });
    data?.forEach((element) {
      products.add(new Product(
          title: element["name"],
          number: element["number"].toDouble(),
          unit: element["unit"],
          category: element["category"]));
    });
    return products;
  }

  Future removeProductFromList(Product product) async {
    String groupID = await getCurrentGroupID();
    await fridgeCollection
        .doc(groupID)
        .collection("products")
        .doc(product.title)
        .delete();
  }

  Future saveGoodiesPerCategoryList(
      String category, List<FridgeProduct> goodies) async {
    String groupID = await getCurrentGroupID();
    List<Map<String, dynamic>> fridgeProducts = [];
    for (int i = 0; i < goodies.length; i++) {
      var entry = ({
        "name": goodies[i].title,
        "category": goodies[i].category,
        "number": goodies[i].number,
        "unit": goodies[i].unit,
      });
      fridgeProducts.add(entry);
    }
    await fridgeCollection
        .doc(groupID)
        .collection("goodies")
        .doc(category)
        .set({"goodies": fridgeProducts});
  }

  Future updateGoodiesPerCategoryList(
      String category, List<FridgeProduct> goodies) async {
    String groupID = await getCurrentGroupID();
    List<Map<String, dynamic>> fridgeProducts = [];
    for (int i = 0; i < goodies.length; i++) {
      var entry = ({
        "name": goodies[i].title,
        "category": goodies[i].category,
        "number": goodies[i].number,
        "unit": goodies[i].unit,
      });
      fridgeProducts.add(entry);
    }
    await fridgeCollection
        .doc(groupID)
        .collection("goodies")
        .doc(category)
        .update({"goodies": fridgeProducts});
  }

  Future getGoodiesPerCategory(String category) async {
    List<dynamic>? data;
    List<FridgeProduct> products = [];
    String groupID = await getCurrentGroupID();
    await fridgeCollection
        .doc(groupID)
        .collection("goodies")
        .doc(category)
        .get()
        .then((value) {
      data = value.data()?["goodies"];
    });
    data?.forEach((element) {
      products.add(new FridgeProduct(
          title: element["name"],
          number: element["number"].toDouble(),
          unit: element["unit"],
          category: element["category"]));
    });
    return products;
  }

  Future<bool> addProductToList(Product product) async {
    String groupID = await getCurrentGroupID();
    var doc = await fridgeCollection
        .doc(groupID)
        .collection("products")
        .doc(product.title)
        .get();

    if (!doc.exists) {
      await fridgeCollection
          .doc(groupID)
          .collection("products")
          .doc(product.title)
          .set({
        'name': product.title,
        'category': product.category,
        'number': product.number,
        'unit': product.unit,
      });
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  Future saveNewRecipe(String category, Recipe recipe) async {
    String groupID = await getCurrentGroupID();
    return await recipeCollection
        .doc(groupID)
        .collection(category)
        .add(recipe.toJson());
  }

  // get recipes from given category

  Future<List<Recipe>> getRecipesFromCategory(String category) async {
    final groupID = await getCurrentGroupID();

    final querySnapshot =
        await recipeCollection.doc(groupID).collection(category).get();

    final List<Map<String, dynamic>> docs =
        querySnapshot.docs.map((doc) => doc.data()).toList();

    final List<Recipe> recipeList = [];

    for (final data in docs) {
      if (data["recipe_pic"] == null || data["recipe_pic"] == "") {
        data["recipe_pic"] = 'assets/images/default_pic_2.jpg';
      }

      recipeList.add(Recipe.fromJson(data));
    }

    return recipeList;
  }

  // create new user document; groups need to be created later on
  Future saveNewUser(String name, String userID) async {
    return await userCollection.doc(userID).set({
      'name': name,
      'groups': [],
      'current_group': "",
    });
  }

  Future getAllMemberNames(List userIDs) async {
    var memberNames = [];
    await Future.forEach(userIDs, (userID) async {
      await getUserName(userID).then((value) {
        memberNames.add(value);
      });
    });
    return memberNames;
  }

  Future getUserName(String uid) async {
    var userName;
    await userCollection.doc(uid).get().then((snapshot) {
      userName = snapshot.data();
    });
    return userName['name'];
  }

  // create new group document
  Future createGroup(String groupID, String name, String iconPath) async {
    return await groupCollection.doc(groupID).set({
      'name': name,
      'icon': iconPath,
      'members': [],
      'groupID': groupID,
    });
  }

  // check which group is currently active
  Future updateActiveGroup(String groupID) async {
    String uid = auth.getCurrentUser();
    return await userCollection.doc(uid).update({'current_group': groupID});
  }

  Future updateGroupPic(String groupID, String url) async {
    return await groupCollection.doc(groupID).update({'icon': url});
  }

  Future leaveGroup(String groupID) async {
    String uid = auth.getCurrentUser();
    var userInfo;
    var groupToDelete = [];
    var userToDelete = [];
    groupToDelete.add(groupID);
    userToDelete.add(uid);

    // remove group inside users document
    await userCollection
        .doc(uid)
        .update({'groups': FieldValue.arrayRemove(groupToDelete)});
    // remove user inside groups document
    await groupCollection
        .doc(groupID)
        .update({'members': FieldValue.arrayRemove(userToDelete)});

    //check if groups exist in user document
    await userCollection.doc(uid).get().then((snapshot) {
      userInfo = snapshot.data();
    });

    // change active group depending on existing groups
    if (userInfo['groups'].isEmpty) {
      updateActiveGroup("");
      return 'no_group';
    } else {
      updateActiveGroup(userInfo['groups'][0]);
      return userInfo['groups'][0];
    }
  }

  // get the current user group name to show in burger menu or in group overview screen
  Future getCurrentGroup() async {
    String groupID = await getCurrentGroupID();
    var groupName;
    await groupCollection.doc(groupID).get().then((snapshot) {
      groupName = snapshot.data();
    });
    return groupName;
  }

  Future getSingleGroupInfo(String groupID) async {
    var groupInfo;
    await Future.wait([
      groupCollection.doc(groupID).get().then((doc) {
        groupInfo = doc.data();
      })
    ]);
    return groupInfo;
  }

  Future getGroupsByUser() async {
    var groupIDs;
    String uid = auth.getCurrentUser();
    await userCollection.doc(uid).get().then((snapshot) {
      groupIDs = snapshot.data();
    });
    return groupIDs['groups'];
  }

  Future getAllGroupInfo() async {
    var groups;
    var groupInfo = [];

    await Future.wait([getGroupsByUser().then((data) => groups = data)]);

    await Future.forEach(groups, (element) async {
      await getSingleGroupInfo(element as String)
          .then((value) => groupInfo.add(value));
    });

    return groupInfo;
  }

  Future checkGroupID(String groupID) async {
    bool groupExists = false;
    String uid = auth.getCurrentUser();
    await groupCollection.get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        if (groupID == doc.id) {
          groupExists = true;
          updateUserGroups(groupID, uid);
          updateGroupUsers(groupID, uid);
          updateActiveGroup(groupID).whenComplete(() {
            return groupExists;
          });
        }
      });
    });
    return groupExists;
  }

  Future<String> getCurrentGroupID() async {
    String uid = auth.getCurrentUser();
    if (uid.isEmpty) return '';

    var groupID;
    await userCollection.doc(uid).get().then((ds) {
      groupID = ds.data();
    });

    if (groupID == null) return '';
    return groupID['current_group'] ?? '';
  }

  // update list of users in group document
  Future updateGroupUsers(String groupID, String userID) async {
    return await groupCollection.doc(groupID).update({
      'members': FieldValue.arrayUnion([userID]),
    });
  }

  // update list of groups in user document
  Future updateUserGroups(String groupID, String userID) async {
    return await userCollection.doc(userID).update({
      'groups': FieldValue.arrayUnion([groupID]),
    });
  }

  Future uploadGroupImageToFirebase(
      BuildContext context, File _imageFile) async {
    String fileName = basename(_imageFile.path);
    final destination = 'images/$fileName';
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(destination);
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    final urlDownload = await taskSnapshot.ref.getDownloadURL();
    print("Done: $urlDownload");
    return urlDownload.toString();
  }

  Future uploadRecipeImageToFirebase(
      BuildContext context, File _imageFile) async {
    String fileName = basename(_imageFile.path);
    final destination = 'images/recipes/$fileName';
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(destination);
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    final urlDownload = await taskSnapshot.ref.getDownloadURL();
    print("Done: $urlDownload");
    return urlDownload.toString();
  }

  Future deleteImageFromFirebase(String url) async {
    FirebaseStorage.instance.refFromURL(url).delete();
  }
}
