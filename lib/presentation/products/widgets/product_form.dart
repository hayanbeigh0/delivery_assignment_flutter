// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shopping_app/application/products/add_product_form_bloc/add_product_form_bloc.dart';
import 'package:shopping_app/domain/products/product.dart';
import 'package:shopping_app/presentation/core/utils/location_picker.dart';
import 'package:shopping_app/presentation/core/widgets/app_text_form_field.dart';
import 'package:shopping_app/presentation/core/widgets/buttons/primary_elevated_button.dart';
import 'package:shopping_app/presentation/core/widgets/spinner_overlay.dart';
import 'package:image_picker/image_picker.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  File? _image;

  void _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      if (mounted) {
        BlocProvider.of<AddProductFormBloc>(context).add(
          AddProductFormEvent.imageChanged(image: File(pickedFile.path)),
        );
      }
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductFormBloc, AddProductFormState>(
      listener: (context, state) {
        if (state.image == null) {
          FlushbarHelper.createError(
            message: 'Product should have an image.',
          ).show(context);
        }
        if (state.isSubmitting) {
          // showProgressIndicator(context);
          SpinnerOverlay().show(context);
        }
        if (state.productFailureOrSuccessOption.isSome()) {
          // context.router.popForced();
          SpinnerOverlay().hide();
        }
        if (state.productCreated) {
          // context.router.popForced();
          SpinnerOverlay().hide();
          context.router.popForced();
          FlushbarHelper.createSuccess(
            message: 'Product added sucessfully!',
          ).show(context);
        }
      },
      builder: (context, state) {
        return Form(
          autovalidateMode: state.showErrorMessages
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _showImageSourceOptions,
                  child: Stack(
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        height: 150,
                        // width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(53, 134, 134, 231),
                        ),
                        child: _image == null
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 48.0),
                                child: Icon(Icons.add_a_photo),
                              )
                            : Image.file(
                                FileImage(_image!).file,
                              ),
                      ),
                      if (_image != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _image = null;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Name',
                hintText: 'Ex: Coca Cola',
                onChanged: (value) {
                  BlocProvider.of<AddProductFormBloc>(context).add(
                    AddProductFormEvent.nameChanged(nameStr: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Category',
                hintText: 'Soft drink',
                onChanged: (value) {
                  BlocProvider.of<AddProductFormBloc>(context).add(
                    AddProductFormEvent.categoryChanged(categoryStr: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Description',
                hintText: 'Enter product description...',
                onChanged: (value) {
                  BlocProvider.of<AddProductFormBloc>(context).add(
                    AddProductFormEvent.descriptionChanged(
                        descriptionStr: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                label: 'Price',
                hintText: 'Ex: 50',
                onChanged: (value) {
                  BlocProvider.of<AddProductFormBloc>(context).add(
                    AddProductFormEvent.priceChanged(
                      price: double.parse(value),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const LocationFormField(),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppElevatedButton(
                  onPressed: () {
                    BlocProvider.of<AddProductFormBloc>(context).add(
                      const AddProductFormEvent.submitPressed(),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
        );
      },
    );
  }
}

class LocationFormField extends StatefulWidget {
  const LocationFormField({super.key});

  @override
  State<LocationFormField> createState() => _LocationFormFieldState();
}

class _LocationFormFieldState extends State<LocationFormField> {
  final locationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<AddProductFormBloc>(context),
      child: BlocBuilder<AddProductFormBloc, AddProductFormState>(
        builder: (context, state) {
          return AppTextFormField(
            controller: locationController,
            label: 'Address',
            hintText: 'Select address',
            enabled: true,
            suffix: InkWell(
              onTap: () {
                // showProgressIndicator(context);
                SpinnerOverlay().show(context);
                showPickupLocationSheet(
                  context: context,
                  onPlacePicked: (result) {
                    Location? location;
                    location = Location(
                      type: 'Point',
                      coordinates: [
                        result.geometry!.location.lat,
                        result.geometry!.location.lng,
                      ],
                      address: result.formattedAddress,
                    );
                    context.read<AddProductFormBloc>().add(
                          AddProductFormEvent.locationChanged(
                            location: location,
                          ),
                        );
                    context.router.popForced();
                  },
                ).then((_) {
                  locationController.text = context
                      .read<AddProductFormBloc>()
                      .state
                      .location
                      .address
                      .toString();
                  setState(() {});
                  context.router.popForced();
                  SpinnerOverlay().show(context);
                  SpinnerOverlay().hide();
                });
              },
              child: const Icon(Icons.map),
            ),
            onTap: () async {
              showPickupLocationSheet(
                context: context,
                onPlacePicked: (result) {
                  Location? location;
                  location = Location(
                    type: 'Point',
                    coordinates: [
                      result.geometry!.location.lat,
                      result.geometry!.location.lng,
                    ],
                    address: result.formattedAddress,
                  );
                  context.read<AddProductFormBloc>().add(
                      AddProductFormEvent.locationChanged(location: location));
                  Navigator.of(context).pop();
                },
              ).then((_) {
                locationController.text = context
                    .read<AddProductFormBloc>()
                    .state
                    .location
                    .address
                    .toString();
                setState(() {});
              });
            },
            onChanged: (value) {
              locationController.text = state.location.address.toString();
            },
          );
        },
      ),
    );
  }
}
