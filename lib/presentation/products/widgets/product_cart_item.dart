import 'package:flutter/material.dart';
import 'package:shopping_app/domain/products/product.dart';
import 'package:shopping_app/presentation/core/utils/global_variables.dart';

class ProductCartItem extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductCartItem({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
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
              product.imageUrl ?? productImagePlaceholder,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(product.name!),
                Text('₹ ${product.price}'),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(52, 134, 134, 231),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: onDecrement,
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: onIncrement,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
