import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class IAPService {
  // Replace with your actual RevenueCat API Keys
  static const _googleApiKey = 'goog_...'; // TO BE FILLED
  static const _appleApiKey = 'appl_...';   // TO BE FILLED

  static const _entitlementID = 'professional_chef';

  Future<void> initialize() async {
    if (kIsWeb) return;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    } else {
      return;
    }

    await Purchases.configure(configuration);
    debugPrint('RevenueCat initialized');
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error getting offerings: $e');
      return null;
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  Future<bool> isUserPremium() async {
    if (kIsWeb) return false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }
}
