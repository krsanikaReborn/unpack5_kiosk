import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/services/services_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ServicesBloc>().add(const ServicesEvent.openBarcodePort());
    return const Scaffold(
      backgroundColor: Colors.black,
    );
  }
}
