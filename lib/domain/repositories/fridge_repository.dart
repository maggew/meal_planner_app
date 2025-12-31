import 'package:meal_planner/data/model/FridgeProduct.dart';
import 'package:meal_planner/data/model/Product.dart';

abstract class FridgeRepository {
  Future<List<Product>> getProductList(String groupID);

  Future<void> removeProductFromList(String groupID, Product product);

  Future<void> saveGoodiesPerCategoryList(
      String groupID, String category, List<FridgeProduct> goodies);

  Future<void> updateGoodiesPerCategoryList(
      String groupID, String category, List<FridgeProduct> goodies);

  Future<List<FridgeProduct>> getGoodiesPerCategory(
      String groupID, String category);

  Future<bool> addProductToList(String groupID, Product product);
}
