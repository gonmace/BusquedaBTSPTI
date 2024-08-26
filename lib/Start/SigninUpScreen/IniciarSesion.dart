// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:developer';

import 'package:busquedabtspti/Backend/Backend.dart';
import 'package:busquedabtspti/Home/HomeScreen.dart';
import 'package:busquedabtspti/Models/UserModel.dart';
import 'package:busquedabtspti/Start/LoadingScreen/LoadingScreen.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class SignInScreen extends StatefulWidget {
  bool firstMoment;
  SignInScreen({super.key, required this.firstMoment});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscureText = false;
  List paises = [
    {'path': 'assets/colombia.png', 'name': 'Colombia'},
    {'path': 'assets/argentina.png', 'name': 'Argentina'},
    {'path': 'assets/bolivia.png', 'name': 'Bolivia'},
    {'path': 'assets/brazil.png', 'name': 'Brazil'},
    {'path': 'assets/chile.png', 'name': 'Chile'},
    {'path': 'assets/costarica.png', 'name': 'Costa Rica'},
    {'path': 'assets/peru.png', 'name': 'Peru'},
    {'path': 'assets/uruguay.png', 'name': 'Uruguay'},
    {'path': 'assets/venezuela.png', 'name': 'Venezuela'},
  ];
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  Map<String, dynamic> paisselect = {};
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Material(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 25,
                    left: 25,
                    right: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget.firstMoment)
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 25,
                              ),
                            )
                        ],
                      ),
                      SizedBox(height: media.width * .14),
                      Text("Vamos a iniciar sesión.",
                          style: GoogleFonts.nunito(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      Text("Bienvenido",
                          style: GoogleFonts.nunito(
                              color: const Color.fromARGB(255, 124, 124, 124),
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: media.width * .14),
                      Text("Nombre de Usuario",
                          style: GoogleFonts.nunito(
                              color: const Color.fromARGB(255, 61, 61, 61),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo no puede estar vacío';
                          }
                          return null; // devuelve null si la validación es exitosa
                        },
                        controller: username,
                        cursorColor: Colors.black,
                        style: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            hintText: "Usuario",
                            hintStyle: GoogleFonts.nunito(
                                color: const Color.fromARGB(255, 133, 133, 133),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    const BorderSide(color: Colors.grey))),
                      ),
                      const SizedBox(height: 25),
                      Text("Contraseña",
                          style: GoogleFonts.nunito(
                              color: const Color.fromARGB(255, 61, 61, 61),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo no puede estar vacío';
                          }
                          return null; // devuelve null si la validación es exitosa
                        },
                        controller: password,
                        autofocus: false,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscureText,
                        cursorColor: Colors.black,
                        style: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            hintText: "Contraseña",
                            hintStyle: GoogleFonts.nunito(
                                color: const Color.fromARGB(255, 133, 133, 133),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    const BorderSide(color: Colors.grey))),
                      ),
                      Expanded(child: Container()),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                loading = true;
                              });
                              if (_formKey.currentState!.validate()) {
                                UserModel? data =
                                    await login(username.text, password.text);
                                if (data != null) {
                                  await saveUserData(data);

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    PageTransition(
                                        child: const LoadingScreen(),
                                        type: PageTransitionType.rightToLeft),
                                    (route) => false,
                                  );
                                } else {
                                  CherryToast.error(
                                    toastDuration: const Duration(seconds: 5),
                                    title: const Text(
                                        "Usuario o contraseña incorrectos",
                                        style: TextStyle(color: Colors.black)),
                                  ).show(context);
                                }
                              }
                              if (mounted) {
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black),
                              padding: EdgeInsets.symmetric(
                                  horizontal: media.width * .25, vertical: 15),
                              child: Text("Iniciar Sesión",
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (loading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
