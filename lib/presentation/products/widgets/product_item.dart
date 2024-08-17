import 'package:flutter/material.dart';
import 'package:shopping_app/domain/products/product.dart';
import 'package:shopping_app/domain/user/user.dart';
import 'package:shopping_app/presentation/core/utils/global_variables.dart';
import 'package:shopping_app/presentation/core/widgets/buttons/primary_elevated_button.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;
  final bool disableAddToCart;
  final User? user;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.disableAddToCart,
    required this.onRemoveFromCart,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 249, 251, 255),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            offset: Offset(1, 1),
            blurRadius: 4,
            color: Color.fromARGB(255, 203, 218, 249),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: Image.network(
              product.imageUrl != null
                  ? product.imageUrl!
                  : productImagePlaceholder,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  product.name!,
                  style: TextStyle(
                    fontSize: user != null && user!.role == 'BUYER' ? 14 : 16,
                  ),
                ),
                if (user != null && user!.role == 'SELLER')
                  Text(product.description!),
                Text(
                  '₹ ${product.price}',
                  style: TextStyle(
                    fontSize: user != null && user!.role == 'BUYER' ? 14 : 16,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!disableAddToCart &&
                        user != null &&
                        user!.role == 'BUYER')
                      AppElevatedButton(
                        onPressed: onAddToCart,
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (disableAddToCart &&
                        user != null &&
                        user!.role == 'BUYER')
                      AppElevatedButton(
                        onPressed: onRemoveFromCart,
                        child: const Text(
                          'Remove from Cart',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
