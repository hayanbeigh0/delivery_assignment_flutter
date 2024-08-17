import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopping_app/application/current_user_cubit/current_user_cubit.dart';
import 'package:shopping_app/application/products/product_cart_cubit/product_cart_cubit.dart';
import 'package:shopping_app/application/products/products_cubit/products_cubit.dart';
import 'package:shopping_app/injection.dart';
import 'package:shopping_app/presentation/core/widgets/app_scaffold.dart';
import 'package:shopping_app/presentation/products/cart_page.dart';
import 'package:shopping_app/presentation/products/widgets/product_list.dart';

@RoutePage()
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProductsCubit>()..getAllProducts(),
        ),
      ],
      child: const ProductsPageWidget(),
    );
  }
}

class ProductsPageWidget extends StatelessWidget {
  const ProductsPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: 'Products',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'All products',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                return state.maybeMap(
                  orElse: () => const SizedBox(),
                  initial: (value) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loading: (value) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e) => Center(
                    child: Text(
                      e.failure.map(
                        cancelledByUser: (value) => 'Cancelled by user!',
                        serverError: (value) => 'Server error!',
                        productsNotFound: (value) => 'No product found!',
                        unKnownError: (value) => 'Unknown error occurred!',
                      ),
                    ),
                  ),
                  loaded: (value) {
                    return BlocBuilder<CurrentUserCubit, CurrentUserState>(
                      builder: (context, state) {
                        return state.maybeMap(
                          orElse: () => const SizedBox(),
                          success: (userValue) => ProductList(
                            productList: value.products,
                            user: userValue.user,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        onTap: (value) {
          if (value == 0) {
            context.router.pushNamed('/orders');
          } else if (value == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<
                      ProductCartCubit>(), // Pass the existing Bloc instance
                  child: const CartPage(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
