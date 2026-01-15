import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/services/iap_service.dart';
import 'package:gastronomic_os/features/premium/presentation/bloc/subscription_state.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final IAPService _iapService;

  SubscriptionCubit({required IAPService iapService})
      : _iapService = iapService,
        super(SubscriptionInitial()) {
     _checkStatus();
  }

  Future<void> _checkStatus() async {
    emit(SubscriptionLoading());
    final isPremium = await _iapService.isUserPremium();
    if (isPremium) {
      emit(SubscriptionPremium());
    } else {
      emit(SubscriptionFree());
    }
  }

  Future<void> purchasePackage(Package package) async {
    emit(SubscriptionLoading());
    final success = await _iapService.purchasePackage(package);
    if (success) {
      emit(SubscriptionPremium());
    } else {
      emit(SubscriptionFree());
      // In a real app we might want to emit an error state transiently or show a snackbar
    }
  }

  Future<void> restorePurchases() async {
    emit(SubscriptionLoading());
    final success = await _iapService.restorePurchases();
    if (success) {
      emit(SubscriptionPremium());
    } else {
      emit(SubscriptionFree());
    }
  }
}
