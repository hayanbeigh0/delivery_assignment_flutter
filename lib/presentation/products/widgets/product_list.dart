import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/application/current_user_cubit/current_user_cubit.dart';
import 'package:shopping_app/application/order/create_order_cubit/create_order_cubit.dart';
import 'package:shopping_app/application/products/product_cart_cubit/product_cart_cubit.dart';
import 'package:shopping_app/application/products/products_cubit/products_cubit.dart';
import 'package:shopping_app/domain/product_order/product_order_failure.dart';
import 'package:shopping_app/domain/products/product.dart';
import 'package:shopping_app/domain/user/user.dart';
import 'package:shopping_app/injection.dart';

import 'package:shopping_app/presentation/core/widgets/spinner_overlay.dart';
import 'package:shopping_app/presentation/products/widgets/product_item.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    super.key,
    required this.productList,
    this.user,
  });
  final List<Product> productList;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrentUserCubit>(
          create: (context) => getIt<CurrentUserCubit>()..getCurrentSavedUser(),
        ),
        BlocProvider<CreateOrderCubit>(
          create: (context) => getIt<CreateOrderCubit>(),
        ),
      ],
      child: BlocListener<CreateOrderCubit, CreateOrderState>(
        listener: (context, state) {
          state.maybeMap(
            orElse: () {},
            loading: (value) {
              // showProgressIndicator(context);
              SpinnerOverlay().show(context);
            },
            failed: (value) {
              // context.router.popForced();
              SpinnerOverlay().hide();
              if (value.failure ==
                  const ProductOrderFailure.emailNotVerified()) {
                FlushbarHelper.createError(
                  duration: const Duration(seconds: 5),
                  message:
                      'Email not verified. Please verify your email by clicking on the link sent to your email!',
                ).show(context);
                return;
              }
              FlushbarHelper.createError(
                message: 'Failed placing the order!',
              ).show(context);
            },
            success: (value) {
              // context.router.popForced();
              SpinnerOverlay().hide();
              FlushbarHelper.createSuccess(
                message: 'Order placed sucessfully!',
              ).show(context);
            },
          );
        },
        child: BlocBuilder<CurrentUserCubit, CurrentUserState>(
          builder: (context, state) {
            return state.maybeMap(
              orElse: () => const SizedBox(),
              success: (userValue) {
                return RefreshIndicator(
                  onRefresh: () {
                    return BlocProvider.of<ProductsCubit>(context)
                        .getAllProducts();
                  },
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio:
                          userValue.user.role == "BUYER" ? 0.70 : 0.70,
                    ),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 0,
                      bottom: 20,
                    ),
                    shrinkWrap: true,
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      return BlocConsumer<ProductCartCubit, ProductCartState>(
                        listener: (context, state) {
                          state.maybeMap(
                            orElse: () {},
                            failed: (value) {
                              FlushbarHelper.createError(
                                duration: const Duration(milliseconds: 1000),
                                message: 'Item already in the cart!',
                              ).show(context);
                            },
                            added: (value) {
                              FlushbarHelper.createSuccess(
                                duration: const Duration(milliseconds: 1000),
                                message: 'Item added to the cart!',
                              ).show(context);
                            },
                            removed: (value) {
                              FlushbarHelper.createSuccess(
                                duration: const Duration(milliseconds: 1000),
                                message: 'Item removed to the cart!',
                              ).show(context);
                            },
                          );
                        },
                        builder: (context, state) {
                          return state.maybeMap(
                            orElse: () => const SizedBox(),
                            success: (value) {
                              return ProductGridItem(
                                user: user,
                                disableAddToCart:
                                    value.products.contains(productList[index]),
                                onAddToCart: () {
                                  BlocProvider.of<ProductCartCubit>(context)
                                      .addProduct(
                                    product: productList[index],
                                  );
                                },
                                onRemoveFromCart: () {
                                  BlocProvider.of<ProductCartCubit>(context)
                                      .removeProduct(
                                    product: productList[index],
                                  );
                                },
                                product: productList[index],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
