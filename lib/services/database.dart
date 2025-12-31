import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/data/model/FridgeProduct.dart';
import 'package:meal_planner/data/model/Product.dart';
import 'package:path/path.dart';

class Database {
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');
  final CollectionReference fridgeCollection =
      FirebaseFirestore.instance.collection('refrigerator');

  // ========== FRIDGE METHODS ==========

  // ========== GROUP METHODS ==========

  // ========== STORAGE METHODS ==========
}
