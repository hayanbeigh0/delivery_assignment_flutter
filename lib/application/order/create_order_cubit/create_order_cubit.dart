import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopping_app/domain/product_order/i_product_order.dart';
import 'package:shopping_app/domain/product_order/product_order.dart';
import 'package:shopping_app/domain/product_order/product_order_failure.dart';
import 'package:shopping_app/domain/products/product.dart';

part 'create_order_state.dart';
part 'create_order_cubit.freezed.dart';

@injectable
class CreateOrderCubit extends Cubit<CreateOrderState> {
  final IProductOrderRepository _iProductOrderRepository;

  CreateOrderCubit(this._iProductOrderRepository)
      : super(
          const CreateOrderState.initial(),
        );

  Future<void> createOrdersForProducts(
      List<Map<String, dynamic>> products) async {
    emit(const CreateOrderState.loading());

    // List to hold the results of each order creation
    final List<Either<ProductOrderFailure, ProductOrder>> results = [];

    for (var product in products) {
      final order = ProductOrderItem(
        productId: product['productId'],
        address: Address(
          type: 'Point',
          address: product['address']!.address!,
          coordinates: product['address']!.coordinates!,
        ),
        quantity: product['quantity']!,
      );
      final result = await createOrder(order); // Collect result
      results.add(result);
    }

    // Check if there is any failure
    final failureResult = results.firstOrNull!;

    // If there's a failure, emit the first failure state
    failureResult.fold(
      (l) => emit(CreateOrderState.failed(failure: l)),
      (r) => emit(CreateOrderState.success(order: r)),
    );
  }

  Future<Either<ProductOrderFailure, ProductOrder>> createOrder(
      ProductOrderItem product) async {
    return await _iProductOrderRepository.createOrder(
      productId: product.productId,
      address: product.address,
      quantity: product.quantity,
    );
  }
}

class ProductOrderItem {
  final String productId;
  final Address address;
  final int quantity;

  ProductOrderItem({
    required this.productId,
    required this.address,
    required this.quantity,
  });
}
