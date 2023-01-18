import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final bool isImage;

  const LoadingWidget({super.key, this.isImage = false});

  @override
  Widget build(BuildContext context) => Center(
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    if (isImage) {
      return SpinKitRipple(
        color: Theme.of(context).colorScheme.secondary,
      );
    } else {
      return SpinKitWave(
        color: Theme.of(context).colorScheme.secondary,
      );
    }
  }
}
