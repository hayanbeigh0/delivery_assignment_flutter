// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:flutter/material.dart' as _i14;
import 'package:shopping_app/domain/product_order/product_order.dart' as _i15;
import 'package:shopping_app/presentation/delivery/delivery_page.dart' as _i4;
import 'package:shopping_app/presentation/delivery/widgets/active_deliveries.dart'
    as _i1;
import 'package:shopping_app/presentation/delivery/widgets/initiated_deliveries.dart'
    as _i5;
import 'package:shopping_app/presentation/orders/orders_page.dart' as _i6;
import 'package:shopping_app/presentation/products/add_product.dart' as _i2;
import 'package:shopping_app/presentation/products/cart_page.dart' as _i3;
import 'package:shopping_app/presentation/products/product_detail.dart' as _i7;
import 'package:shopping_app/presentation/products/products_page.dart' as _i8;
import 'package:shopping_app/presentation/products/seller_products_page.dart'
    as _i9;
import 'package:shopping_app/presentation/sign_in/sign_in_page.dart' as _i10;
import 'package:shopping_app/presentation/sign_up/sign_up_page.dart' as _i11;
import 'package:shopping_app/presentation/splash/splash_page.dart' as _i12;

abstract class $AppRouter extends _i13.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i13.PageFactory> pagesMap = {
    ActiveDeliveriesRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.ActiveDeliveriesPage(),
      );
    },
    AddProductRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AddProductPage(),
      );
    },
    CartRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.CartPage(),
      );
    },
    DeliveryRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.DeliveryPage(),
      );
    },
    InitiatedDeliveries.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.InitiatedDeliveries(),
      );
    },
    OrdersRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.OrdersPage(),
      );
    },
    ProductDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ProductDetailRouteArgs>();
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.ProductDetailPage(
          key: args.key,
          order: args.order,
        ),
      );
    },
    ProductsRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.ProductsPage(),
      );
    },
    SellerProductsRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.SellerProductsPage(),
      );
    },
    SignInRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.SignInPage(),
      );
    },
    SignUpRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.SignUpPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return _i13.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.SplashPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.ActiveDeliveriesPage]
class ActiveDeliveriesRoute extends _i13.PageRouteInfo<void> {
  const ActiveDeliveriesRoute({List<_i13.PageRouteInfo>? children})
      : super(
          ActiveDeliveriesRoute.name,
          initialChildren: children,
        );

  static const String name = 'ActiveDeliveriesRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AddProductPage]
class AddProductRoute extends _i13.PageRouteInfo<void> {
  const AddProductRoute({List<_i13.PageRouteInfo>? children})
      : super(
          AddProductRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddProductRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CartPage]
class CartRoute extends _i13.PageRouteInfo<void> {
  const CartRoute({List<_i13.PageRouteInfo>? children})
      : super(
          CartRoute.name,
          initialChildren: children,
        );

  static const String name = 'CartRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i4.DeliveryPage]
class DeliveryRoute extends _i13.PageRouteInfo<void> {
  const DeliveryRoute({List<_i13.PageRouteInfo>? children})
      : super(
          DeliveryRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeliveryRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i5.InitiatedDeliveries]
class InitiatedDeliveries extends _i13.PageRouteInfo<void> {
  const InitiatedDeliveries({List<_i13.PageRouteInfo>? children})
      : super(
          InitiatedDeliveries.name,
          initialChildren: children,
        );

  static const String name = 'InitiatedDeliveries';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i6.OrdersPage]
class OrdersRoute extends _i13.PageRouteInfo<void> {
  const OrdersRoute({List<_i13.PageRouteInfo>? children})
      : super(
          OrdersRoute.name,
          initialChildren: children,
        );

  static const String name = 'OrdersRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i7.ProductDetailPage]
class ProductDetailRoute extends _i13.PageRouteInfo<ProductDetailRouteArgs> {
  ProductDetailRoute({
    _i14.Key? key,
    required _i15.ProductOrder order,
    List<_i13.PageRouteInfo>? children,
  }) : super(
          ProductDetailRoute.name,
          args: ProductDetailRouteArgs(
            key: key,
            order: order,
          ),
          initialChildren: children,
        );

  static const String name = 'ProductDetailRoute';

  static const _i13.PageInfo<ProductDetailRouteArgs> page =
      _i13.PageInfo<ProductDetailRouteArgs>(name);
}

class ProductDetailRouteArgs {
  const ProductDetailRouteArgs({
    this.key,
    required this.order,
  });

  final _i14.Key? key;

  final _i15.ProductOrder order;

  @override
  String toString() {
    return 'ProductDetailRouteArgs{key: $key, order: $order}';
  }
}

/// generated route for
/// [_i8.ProductsPage]
class ProductsRoute extends _i13.PageRouteInfo<void> {
  const ProductsRoute({List<_i13.PageRouteInfo>? children})
      : super(
          ProductsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProductsRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i9.SellerProductsPage]
class SellerProductsRoute extends _i13.PageRouteInfo<void> {
  const SellerProductsRoute({List<_i13.PageRouteInfo>? children})
      : super(
          SellerProductsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SellerProductsRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i10.SignInPage]
class SignInRoute extends _i13.PageRouteInfo<void> {
  const SignInRoute({List<_i13.PageRouteInfo>? children})
      : super(
          SignInRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignInRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i11.SignUpPage]
class SignUpRoute extends _i13.PageRouteInfo<void> {
  const SignUpRoute({List<_i13.PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}

/// generated route for
/// [_i12.SplashPage]
class SplashRoute extends _i13.PageRouteInfo<void> {
  const SplashRoute({List<_i13.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const _i13.PageInfo<void> page = _i13.PageInfo<void>(name);
}
