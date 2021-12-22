import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iridium_app/components/custom_alert.dart';
import 'package:iridium_app/util/consts.dart';

class Dialogs {
  showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomAlert(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 15.0),
              Text(
                Constants.appName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 25.0),
              const Text(
                'Are you sure you want to quit?',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    height: 40.0,
                    width: 130.0,
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        side: MaterialStateProperty.all(BorderSide(
                            color: Theme.of(context).colorScheme.secondary)),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                    width: 130.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.secondary),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => exit(0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
