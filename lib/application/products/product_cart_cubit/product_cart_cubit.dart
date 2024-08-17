import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopping_app/domain/products/product.dart';

part 'product_cart_state.dart';
part 'product_cart_cubit.freezed.dart';

@injectable
class ProductCartCubit extends Cubit<ProductCartState> {
  ProductCartCubit() : super(const ProductCartState.initial());
  List<Product> products = [];
  List<Product> productsForCart = [];
  loadCartProducts() {
    emit(const ProductCartState.loading());
    emit(const ProductCartState.success(products: []));
  }

  addProduct({
    required Product product,
    bool fromCart = false,
  }) {
    emit(const ProductCartState.loading());
    productsForCart.add(product);
    if (products.any((el) => el.id == product.id) && !fromCart) {
      emit(const ProductCartState.failed());
      return;
    }
    products.add(product);
    emit(const ProductCartState.added());
    emit(ProductCartState.success(
      products: products,
      productsForCart: productsForCart,
    ));
  }

  increaseProductQuantity({required Product product}) {
    emit(const ProductCartState.loading());
    productsForCart.add(product);
    emit(ProductCartState.success(
      products: products,
      productsForCart: productsForCart,
    ));
  }

  decreaseProductQuantity({required Product product}) {
    emit(const ProductCartState.loading());
    productsForCart.remove(product);
    final newCartItemList = productsForCart.where((el) => el.id == product.id);
    if (newCartItemList.isEmpty) {
      products.removeWhere((el) => el.id == product.id);
    }
    emit(ProductCartState.success(
      products: products,
      productsForCart: productsForCart,
    ));
  }

  removeProduct({required Product product}) {
    emit(const ProductCartState.loading());
    products.removeWhere((el) => el.id == product.id);
    productsForCart.removeWhere((el) => el.id == product.id);
    emit(const ProductCartState.removed());
    emit(ProductCartState.success(products: products));
  }

  removeAll() {
    emit(const ProductCartState.loading());
    products.clear();
    productsForCart.clear();
    emit(ProductCartState.success(
      products: products,
      productsForCart: productsForCart,
    ));
  }
}
