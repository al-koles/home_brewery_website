import 'dart:html';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home_brewery_website/Api/Auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../models/user.dart';
import '../translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class Authorization extends StatefulWidget {
  const Authorization({Key? key}) : super(key: key);

  @override
  State<Authorization> createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {
  Future<void> toast({required String message, required Color color}) async {
    await Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  bool login = true;
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  buildLoginAlert(context) {
    Alert(
        closeIcon: const Icon(FontAwesomeIcons.rectangleXmark),
        context: context,
        title: login ? LocaleKeys.login.tr() : LocaleKeys.register.tr(),
        content: Form(
          key: loginFormKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your email.";
                  }
                  return null;
                },
                controller: emailController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.account_circle),
                  labelText: LocaleKeys.email.tr(),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your email.";
                  }
                  return null;
                },
                controller: passController,
                obscureText: true,
                decoration: InputDecoration(
                  icon: const Icon(Icons.lock),
                  labelText: LocaleKeys.password.tr(),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () {
                    login = !login;
                    Navigator.pop(context);
                    buildLoginAlert(context);
                  },
                  child: Text(
                    login
                        ? LocaleKeys.not_registered.tr()
                        : LocaleKeys.already_registered.tr(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              if (!loginFormKey.currentState!.validate()) {
                return;
              }
              try {
                if (login) {
                  final response = await Auth().loginAsync(
                      emailController.text.trim(), passController.text.trim());
                  if (response.statusCode == HttpStatus.ok) {
                    var jwt = await Auth().getJwtAsync();
                    var user = await Auth().fetchCurrentUserAsync(jwt);
                    toast(
                      message: "Welcome back ${user.email}.",
                      color: Colors.blue,
                    );
                    setState(() {});
                    Navigator.pop(context);
                  } else if (response.statusCode == HttpStatus.notFound) {
                    toast(
                      message: "User not found",
                      color: Colors.red,
                    );
                  } else {
                    toast(
                      message: "Error. $response.body",
                      color: Colors.red,
                    );
                  }
                } else {
                  var email = emailController.text.trim();
                  final pass = passController.text.trim();
                  final response = await Auth().registerAsync(email, pass);
                  if (response.statusCode == HttpStatus.created) {
                    toast(
                      message: "Registered $email",
                      color: Colors.blue,
                    );
                    setState(() {
                      login = true;
                    });
                  } else {
                    toast(
                      message: "Error. ${response.body}",
                      color: Colors.red,
                    );
                  }
                }
              } catch (e) {
                await toast(
                  message: 'Something went wrong. $e',
                  color: Colors.red,
                );
              }
            },
            child: Text(
              login ? LocaleKeys.login.tr() : LocaleKeys.register.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  Widget buildLoginButton() {
    return TextButton(
      onPressed: () => {buildLoginAlert(context)},
      child: const Text("Log In"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: Auth().getJwtAsync(),
        builder: (_, jwtSnapshot) {
          if (jwtSnapshot.hasData) {
            var jwt = jwtSnapshot.data!;
            if (jwt == "") {
              return buildLoginButton();
            }
            return FutureBuilder<User>(
              future: Auth().fetchCurrentUserAsync(jwt),
              builder: (_, userSnapshot) {
                if (userSnapshot.hasData) {
                  var user = userSnapshot.data;
                  if (user!.id == 0) {
                    return buildLoginButton();
                  }
                  return Row(
                    children: [
                      Text(userSnapshot.data!.email.toString()),
                      TextButton(
                        onPressed: () async {
                          await Auth().deleteJwtAsync();
                          toast(
                            message: "Logged out",
                            color: Colors.blue,
                          );
                          setState(() {});
                        },
                        child: const Text("Log out"),
                      )
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
