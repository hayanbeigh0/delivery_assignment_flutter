import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/application/order/create_order_cubit/create_order_cubit.dart';
import 'package:shopping_app/application/products/product_cart_cubit/product_cart_cubit.dart';
import 'package:shopping_app/application/products/products_cubit/products_cubit.dart';
import 'package:shopping_app/domain/product_order/product_order.dart';
import 'package:shopping_app/domain/product_order/product_order_failure.dart';
import 'package:shopping_app/domain/products/product.dart';
import 'package:shopping_app/injection.dart';
import 'package:shopping_app/presentation/core/utils/location_picker.dart';
import 'package:shopping_app/presentation/core/widgets/app_scaffold.dart';
import 'package:shopping_app/presentation/core/widgets/buttons/primary_elevated_button.dart';
import 'package:shopping_app/presentation/core/widgets/spinner_overlay.dart';
import 'package:shopping_app/presentation/products/widgets/product_cart_item.dart';

@RoutePage()
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: 'Cart',
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => getIt<CreateOrderCubit>(),
          ),
        ],
        child: BlocConsumer<CreateOrderCubit, CreateOrderState>(
          listener: (context, state) {
            state.maybeMap(
              orElse: () {
                SpinnerOverlay().show(context);
              },
              loading: (value) {
                SpinnerOverlay().show(context);
              },
              failed: (value) {
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
                SpinnerOverlay().hide();
                FlushbarHelper.createSuccess(
                  message: 'Order placed sucessfully!',
                ).show(context);
                BlocProvider.of<ProductCartCubit>(context).removeAll();
              },
            );
          },
          builder: (context, state) {
            return BlocBuilder<ProductCartCubit, ProductCartState>(
              builder: (context, state) {
                return state.maybeMap(
                  orElse: () => const SizedBox(),
                  success: (value) {
                    return RefreshIndicator(
                      onRefresh: () {
                        return BlocProvider.of<ProductsCubit>(context)
                            .getAllProducts();
                      },
                      child: Visibility(
                        replacement: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(58.0),
                            child: Text(
                              'You don\'t have any products in the cart!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        visible: value.products.isNotEmpty,
                        child: Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.75,
                                ),
                                padding: const EdgeInsets.all(16),
                                shrinkWrap: true,
                                itemCount: value.products.length,
                                itemBuilder: (context, index) {
                                  return BlocConsumer<ProductCartCubit,
                                      ProductCartState>(
                                    listener: (context, state) {
                                      state.maybeMap(
                                        orElse: () {},
                                      );
                                    },
                                    builder: (context, state) {
                                      return state.maybeMap(
                                        orElse: () => const SizedBox(),
                                        success: (value) {
                                          return ProductCartItem(
                                            onAddToCart: () {
                                              BlocProvider.of<ProductCartCubit>(
                                                      context)
                                                  .addProduct(
                                                product: value.products[index],
                                              );
                                            },
                                            product: value.products[index],
                                            onDecrement: () {
                                              BlocProvider.of<ProductCartCubit>(
                                                      context)
                                                  .decreaseProductQuantity(
                                                product: value.products[index],
                                              );
                                            },
                                            onIncrement: () {
                                              BlocProvider.of<ProductCartCubit>(
                                                      context)
                                                  .increaseProductQuantity(
                                                product: value.products[index],
                                              );
                                            },
                                            quantity: value.productsForCart!
                                                .where((el) =>
                                                    el.id ==
                                                    value.products[index].id)
                                                .length,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            BlocBuilder<ProductCartCubit, ProductCartState>(
                              builder: (context, state) {
                                return state.maybeMap(
                                  orElse: () => const SizedBox(),
                                  success: (value) {
                                    return state.maybeMap(
                                      orElse: () => const SizedBox(),
                                      success: (value) {
                                        if (value.products.isNotEmpty) {
                                          return Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16.0),
                                            child: AppElevatedButton(
                                              child: const Text('Checkout'),
                                              onPressed: () {
                                                showPickupLocationSheet(
                                                  context: context,
                                                  onPlacePicked: (result) {
                                                    Location? location;
                                                    location = Location(
                                                      type: 'Point',
                                                      coordinates: [
                                                        result.geometry!
                                                            .location.lat,
                                                        result.geometry!
                                                            .location.lng,
                                                      ],
                                                      address: result
                                                          .formattedAddress,
                                                    );
                                                    BlocProvider.of<
                                                                CreateOrderCubit>(
                                                            context)
                                                        .createOrdersForProducts(
                                                            value.products
                                                                .map(
                                                                  (el) => {
                                                                    "productId":
                                                                        el.id!,
                                                                    "address":
                                                                        Address(
                                                                      type:
                                                                          'Point',
                                                                      address:
                                                                          location!
                                                                              .address!,
                                                                      coordinates:
                                                                          LocationCoordinates(
                                                                        latitude:
                                                                            location.coordinates[0],
                                                                        longitude:
                                                                            location.coordinates[1],
                                                                      ),
                                                                    ),
                                                                    "quantity": value
                                                                        .productsForCart!
                                                                        .where((ele) =>
                                                                            ele.id ==
                                                                            el.id)
                                                                        .length,
                                                                  },
                                                                )
                                                                .toList());
                                                    context.router.popForced();
                                                  },
                                                );
                                              },
                                            ),
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
