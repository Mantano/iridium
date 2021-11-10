// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/theme.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_framework/styles/common_sizes.dart';

class ThemeEditorDropdown extends StatefulWidget {
  const ThemeEditorDropdown({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeEditorDropdownState();
}

class ThemeEditorDropdownState extends State<ThemeEditorDropdown> {
  String _value;

  @override
  void initState() {
    super.initState();
    _value = 'Montserrat Light';
  }

  @override
  Widget build(BuildContext context) {
    MantanoTheme bookariTheme =
        BlocProvider.of<ThemeBloc>(context).currentTheme;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: CommonSizes.defaultMargin),
      decoration: BoxDecoration(
        color: Colors.white10,
        border: Border.all(
          color: Colors.white,
          width: 1.0,
        ),
      ),
      child: Theme(
        data: ThemeData(
          canvasColor: bookariTheme.secondaryColor.colorLight,
        ),
        child: LayoutBuilder(
            builder: (context, constraint) => DropdownButton<String>(
                  value: _value,
                  underline: Container(),
                  icon: Padding(
                    padding:
                        const EdgeInsets.only(left: CommonSizes.defaultMargin),
                    child: SvgAssets.orderDesc.widget(
                      color: bookariTheme.primaryColor.colorLight,
                    ),
                  ),
                  items: <String>['Montserrat Light', 'A', 'B', 'C', 'D']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: SizedBox(
                              width: constraint.maxWidth -
                                  CommonSizes.large2Margin,
                              child: Text(
                                value.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: (value == _value)
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                    ),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _value = value);
                  },
                )),
      ),
    );
  }
}
