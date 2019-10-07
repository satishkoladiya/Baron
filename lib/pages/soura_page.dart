import 'dart:async';
import 'package:Baron/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class SouraPage extends StatefulWidget {
  @override
  _SouraPageState createState() => _SouraPageState();
}

class _SouraPageState extends State<SouraPage> {
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
  bool _isAvailable = true;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  void _initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (_isAvailable) {
      await _getProducts();
      _verifyPurchase();
      _subscription = _iap.purchaseUpdatedStream.listen(
        (data) => setState(() {
          _purchases.addAll(data);
        }),
      );
    }
  }

  Future<void> _getProducts() async {
    Set<String> ids = Set.from(['elements']);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    setState(() {
      _products = response.productDetails;
    });
  }

  PurchaseDetails _hasPurchased(String productId) {
    return _purchases.firstWhere((purchase) => purchase.productID == productId,
        orElse: () => null);
  }

  void _verifyPurchase() {
    PurchaseDetails purchase = _hasPurchased('');
    if (purchase != null && purchase.status == PurchaseStatus.purchased) {}
  }

  void buyProduct(ProductDetails prod) {
    final PurchaseParam param = PurchaseParam(productDetails: prod);
    _iap.buyConsumable(purchaseParam: param, autoConsume: true);
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<User>(context);
    return Scaffold(
      body: _isAvailable
          ? Container(
              child: Column(
                children: <Widget>[
                  Text(
                    'Buy Soura',
                    style: TextStyle(fontSize: 20),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for (var prod in _products)
                          Card(
                            child: Container(
                              height: 200,
                              width: 150,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    '${prod.title}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    '${prod.price}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    '${userDetails.badge}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            )
          : Text('Purchase not Available'),
    );
  }

  upgradeAccount(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }
}
