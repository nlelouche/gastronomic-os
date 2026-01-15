import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/services/iap_service.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/features/premium/presentation/bloc/subscription_cubit.dart';
import 'package:gastronomic_os/features/premium/presentation/bloc/subscription_state.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  Offerings? _offerings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    final offerings = await sl<IAPService>().getOfferings();
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark/Premium feel
      body: BlocListener<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionPremium) {
            Navigator.of(context).pop(); // Close paywall on success
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Welcome to Gastronomic PRO!')),
            );
          }
        },
        child: Stack(
          children: [
            // Background Image (Optional, for now just gradient)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueGrey.shade900, Colors.black],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingPage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Close Button
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),

                    const SizedBox(height: AppDimens.spaceL),

                    // Header
                    const Icon(Icons.diamond_outlined, size: 64, color: Colors.amber),
                    const SizedBox(height: AppDimens.spaceM),
                    Text(
                      'Gastronomic PRO',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppDimens.spaceS),
                    Text(
                      'Unlock your kitchen\'s full potential.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: AppDimens.space2XL),

                    // Features List
                    _buildFeatureItem(Icons.block, 'Remove All Ads'),
                    _buildFeatureItem(Icons.group_add, 'Unlimited Family Members'),
                    _buildFeatureItem(Icons.medical_services, 'Advanced Clinical Filters'),
                    _buildFeatureItem(Icons.insights, 'Detailed Smart Match Analysis'),

                    const Spacer(),

                    // Loading or Products
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.amber)
                    else if (_offerings == null || _offerings!.current == null)
                      const Text(
                        'No offerings available. Check configuration.',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    else
                      _buildPurchaseButtons(_offerings!.current!),

                    const SizedBox(height: AppDimens.spaceL),

                    // Restore Button
                    TextButton(
                      onPressed: () {
                        context.read<SubscriptionCubit>().restorePurchases();
                      },
                      child: const Text(
                        'Restore Purchases',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceS),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: AppDimens.spaceM),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButtons(Offering offering) {
    return Column(
      children: offering.availablePackages.map((package) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.spaceM),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                ),
              ),
              onPressed: () {
                context.read<SubscriptionCubit>().purchasePackage(package);
              },
              child: Text(
                '${package.storeProduct.title} - ${package.storeProduct.priceString}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
