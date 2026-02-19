import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mobile_flutter/core/constants/iap_ids.dart';
import 'package:mobile_flutter/data/services/purchase_service.dart';

class PaywallWidget extends ConsumerStatefulWidget {
  const PaywallWidget({super.key});

  @override
  ConsumerState<PaywallWidget> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends ConsumerState<PaywallWidget> {
  List<ProductDetails>? _products;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      // Load available products - using fullCityAccess as default
      final products = await ref.read(purchaseServiceProvider.notifier).fetchProducts({IAPIds.fullCityAccess});
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseServiceProvider);

    // Listen to success state to close the paywall
    ref.listen(purchaseServiceProvider, (previous, next) {
      if (next.status == PurchaseStatusState.success || next.status == PurchaseStatusState.restored) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access Granted!')),
        );
      }
    });

    return Container(
      padding: const EdgeInsets.all(24.0),
      // Use standard bottom sheet height or wrap content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Unlock All Features',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildFeatureList(context),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text('Error: $_error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)
          else 
            ..._buildProductButtons(context, purchaseState),
          
          const SizedBox(height: 16),
          TextButton(
            onPressed: purchaseState.status == PurchaseStatusState.pending 
                ? null 
                : () => ref.read(purchaseServiceProvider.notifier).restorePurchases(),
            child: const Text('Restore Purchases'),
          ),
          if (purchaseState.status == PurchaseStatusState.error && purchaseState.error != null)
             Text(
               purchaseState.error!,
               style: const TextStyle(color: Colors.red),
               textAlign: TextAlign.center,
             ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    return Column(
      children: const [
        _FeatureItem(icon: Icons.headphones, text: 'Full Audio Narrations'),
        _FeatureItem(icon: Icons.map, text: 'Offline Maps'),
        _FeatureItem(icon: Icons.lock_open, text: 'Access to All Tours'),
      ],
    );
  }

  List<Widget> _buildProductButtons(BuildContext context, PurchaseState state) {
    if (_products == null || _products!.isEmpty) {
      // Fallback if no products found (e.g. emulator without store)
      return [
        const Text(
          'No products available. Please check store configuration.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        )
      ];
    }

    return _products!.map((product) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton(
          onPressed: state.status == PurchaseStatusState.pending
              ? null
              : () => ref.read(purchaseServiceProvider.notifier).buy(product),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Buy ${product.title} - ${product.price}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
