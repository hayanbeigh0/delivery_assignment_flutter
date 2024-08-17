import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopping_app/application/current_user_cubit/current_user_cubit.dart';
import 'package:shopping_app/application/delivery/delivery_request_cubit/delivery_request_cubit.dart';
import 'package:shopping_app/application/order/get_orders_cubit/get_orders_cubit.dart';
import 'package:shopping_app/application/order/order_cubit/order_cubit.dart';
import 'package:shopping_app/injection.dart';
import 'package:shopping_app/presentation/core/utils/global_variables.dart';
import 'package:shopping_app/presentation/core/widgets/app_card.dart';
import 'package:shopping_app/presentation/core/widgets/app_scaffold.dart';
import 'package:shopping_app/presentation/core/widgets/buttons/primary_text_button.dart';

import 'package:shopping_app/presentation/core/widgets/spinner_overlay.dart';
import 'package:shopping_app/presentation/products/product_detail.dart';

@RoutePage()
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<CurrentUserCubit>()..getCurrentSavedUser(),
        ),
        BlocProvider(
          create: (context) => getIt<DeliveryRequestCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<OrderCubit>(),
        ),
      ],
      child: AppScaffold(
        appBarTitle: 'Orders',
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: BlocBuilder<CurrentUserCubit, CurrentUserState>(
            builder: (context, state) {
              return state.maybeMap(
                orElse: () => const SizedBox(),
                success: (userValue) => BlocProvider<GetOrdersCubit>(
                  create: (context) => getIt<GetOrdersCubit>()
                    ..getOrders(
                      role: userValue.user.role!,
                    ),
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<OrderCubit, OrderState>(
                        listener: (context, state) {
                          state.maybeMap(
                            orElse: () {},
                            loading: (value) {
                              SpinnerOverlay().show(context);
                            },
                            success: (value) {
                              SpinnerOverlay().hide();
                              BlocProvider.of<GetOrdersCubit>(context)
                                  .getOrders(
                                role: userValue.user.role!,
                              );
                            },
                          );
                        },
                      ),
                      BlocListener<DeliveryRequestCubit, DeliveryRequestState>(
                        listener: (context, state) {
                          state.maybeMap(
                            orElse: () {},
                            loading: (value) {
                              SpinnerOverlay().show(context);
                            },
                            success: (value) {
                              SpinnerOverlay().hide();
                              BlocProvider.of<GetOrdersCubit>(context)
                                  .getOrders(
                                role: userValue.user.role!,
                              );
                            },
                            failed: (value) {
                              SpinnerOverlay().hide();
                            },
                          );
                        },
                      ),
                    ],
                    child: BlocBuilder<GetOrdersCubit, GetOrdersState>(
                      builder: (context, state) {
                        return state.maybeMap(
                          orElse: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          loading: (value) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          failed: (value) => Center(
                            child: Text(value.failure.maybeMap(
                              orElse: () => '',
                              cancelledByUser: (_) => 'Cancelled by user!',
                              orderNotFound: (_) => 'Orders not found!',
                              serverError: (_) => 'Server error!',
                              unKnownError: (_) => 'Unknown error!',
                            )),
                          ),
                          success: (value) {
                            if (value.orders.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'No orders yet!',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 40.0,
                                      ),
                                      child: Text(
                                        'You will see the orders here once a users buys any of your products.',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        BlocProvider.of<GetOrdersCubit>(context)
                                            .getOrders(
                                          role: userValue.user.role!,
                                        );
                                      },
                                      child: const Text('Refresh'),
                                    )
                                  ],
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 20,
                              ),
                              itemCount: value.orders.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: AppCard(
                                    onTap: () async {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                            order: value.orders[index]),
                                      ))
                                          .then((_) {
                                        BlocProvider.of<GetOrdersCubit>(context)
                                            .getOrders(
                                          role: userValue.user.role!,
                                        );
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  15,
                                                ),
                                              ),
                                              height: 120.w,
                                              width: 120.w,
                                              child: Image.network(
                                                value.orders[index].product
                                                        .imageUrl ??
                                                    productImagePlaceholder,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                value.orders[index].product.name
                                                    .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.clip,
                                                style: GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromARGB(
                                                      189, 0, 0, 0),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                value.orders[index].buyer.name
                                                    .toString(),
                                                maxLines: 3,
                                                overflow: TextOverflow.fade,
                                                style: GoogleFonts.lato(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '₹ ${value.orders[index].product.price.toString()}',
                                                    style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    value.orders[index].status
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.clip,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: value.orders[index]
                                                                  .status ==
                                                              'PLACED'
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 187, 159, 73)
                                                          : value.orders[index]
                                                                      .status ==
                                                                  'ACCEPTED'
                                                              ? Colors.orange
                                                              : value
                                                                          .orders[
                                                                              index]
                                                                          .status ==
                                                                      'IN-TRANSIT'
                                                                  ? Colors.blue
                                                                  : value.orders[index].status ==
                                                                          'FULFILED'
                                                                      ? Colors
                                                                          .green
                                                                      : const Color
                                                                          .fromARGB(
                                                                          189,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                        ),
                                                    ),
                                                  ),
                                                  if (value.orders[index]
                                                              .status ==
                                                          'PLACED' &&
                                                      userValue.user.role ==
                                                          'SELLER')
                                                    AppTextButton(
                                                      onPressed: () async {
                                                        BlocProvider.of<
                                                                    OrderCubit>(
                                                                context)
                                                            .updateOrderStatus(
                                                          status: 'ACCEPTED',
                                                          orderId: value
                                                              .orders[index].id,
                                                        );
                                                      },
                                                      child:
                                                          const Text('Accept'),
                                                    ),
                                                  if (value.orders[index]
                                                              .status ==
                                                          'ACCEPTED' &&
                                                      userValue.user.role ==
                                                          'SELLER')
                                                    AppTextButton(
                                                      onPressed: () async {
                                                        BlocProvider.of<
                                                                    DeliveryRequestCubit>(
                                                                context)
                                                            .requestDelivery(
                                                          orderId: value
                                                              .orders[index].id,
                                                        );
                                                      },
                                                      child: const Text(
                                                        'Mark as ready',
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
