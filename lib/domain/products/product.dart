import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    String? id,
    String? imageUrl,
    Seller? seller,
    String? category,
    String? name,
    String? description,
    double? price,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    Location? location,
    File? imageFile,
  }) = _Product;

  factory Product.empty() => Product(
        id: '',
        imageUrl: '',
        seller: Seller.empty(),
        category: '',
        name: '',
        description: '',
        price: 0.0,
        quantity: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        location: Location.empty(),
      );
}

@freezed
abstract class Seller with _$Seller {
  const factory Seller({
    required String id,
    required String name,
    required String email,
    required String role,
  }) = _Seller;

  factory Seller.empty() => const Seller(
        id: '',
        name: '',
        email: '',
        role: '',
      );
}

@freezed
abstract class Location with _$Location {
  const factory Location({
    required String type,
    String? address,
    int? pin,
    required List<double> coordinates,
  }) = _Location;

  factory Location.empty() => const Location(
        type: 'Point',
        coordinates: [],
        address: '',
        pin: null,
      );
}
