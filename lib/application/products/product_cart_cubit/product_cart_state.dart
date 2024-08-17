part of 'product_cart_cubit.dart';

@freezed
class ProductCartState with _$ProductCartState {
  const factory ProductCartState.initial() = _Initial;
  const factory ProductCartState.loading() = _Loading;
  const factory ProductCartState.failed() = _Failed;
  const factory ProductCartState.added() = _Added;
  const factory ProductCartState.removed() = _Removed;
  const factory ProductCartState.success({
    required List<Product> products,
    List<Product>? productsForCart,
  }) = _Success;
}
