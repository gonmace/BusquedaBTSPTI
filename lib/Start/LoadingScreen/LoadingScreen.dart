// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:developer';

import 'package:busquedabtspti/Backend/Backend.dart';
import 'package:busquedabtspti/Home/HomeScreen.dart';
import 'package:busquedabtspti/Models/Sitio_Models.dart';
import 'package:busquedabtspti/Start/SigninUpScreen/IniciarSesion.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  PageController pageController = PageController();
  @override
  void initState() {
    super.initState();
    getData();
  }

  bool logisn = false;
  getData() async {
    initanimation();
    try {
      var datatem = await loadData();

      await Permission.location.request();
      await Future.delayed(const Duration(seconds: 5));
      _controller.stop();
      log(datatem.toString());
     
        if (datatem != null) {
          if (await verificarConexionInternet()) {
            await deletesitios();
            dataUser = await login(datatem.user, datatem.password);
            List<Sitio>? sitiosTemp =
                await fetchSitios(dataUser!.empresaId, dataUser!.token);
            if (sitiosTemp != null) {
              await saveSitiosInPrefs(sitiosTemp);
              if (sitiosTemp.isEmpty) { 
                CherryToast.error(
                  toastDuration: const Duration(seconds: 5),
                  title: const Text("No se encontraron sitios disponibles",
                      style: TextStyle(color: Colors.black)),
                ).show(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      child: const HomeScreen(),
                      type: PageTransitionType.rightToLeft),
                  (route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      child: const HomeScreen(),
                      type: PageTransitionType.rightToLeft),
                  (route) => false,
                );
              }
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    child: const HomeScreen(),
                    type: PageTransitionType.rightToLeft),
                (route) => false,
              );
            }
          } else {
            List<Sitio>? sitiosTemp =
                await fetchSitios(datatem.empresaId, datatem.token);
            dataUser = datatem;
            if (sitiosTemp != null) {
              await saveSitiosInPrefs(sitiosTemp);
              if (sitiosTemp.isEmpty) {
                CherryToast.error(
                  toastDuration: const Duration(seconds: 5),
                  title: const Text("No se encontraron sitios disponibles",
                      style: TextStyle(color: Colors.black)),
                ).show(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      child: const HomeScreen(),
                      type: PageTransitionType.rightToLeft),
                  (route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      child: const HomeScreen(),
                      type: PageTransitionType.rightToLeft),
                  (route) => false,
                );
              }
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    child: const HomeScreen(),
                    type: PageTransitionType.rightToLeft),
                (route) => false,
              );
            }
          }
        } else {
          setState(() {
            logisn = true;
          });
          pageController.nextPage(
              duration: const Duration(milliseconds: 100),
              curve: Curves.bounceIn);
        
      }
    } catch (e) {
      setState(() {
        logisn = true;
      });
      pageController.nextPage(
          duration: const Duration(milliseconds: 100), curve: Curves.bounceIn);
    }
  }

  initanimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    pageController.dispose();
    _controller.dispose(); // Liberar recursos cuando el widget se descarte
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Material(
        child: SafeArea(
          child: Column(
            children: [
              AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: logisn ? media.height * .4 : media.height * .6,
                  width: media.width * .5,
                  child: SvgPicture.asset(
                      'assets/logo.svg') /* Image.asset('assets/Logo4.png') */),
              Expanded(
                  child: Container(
                width: media.width * 1,
                color: const Color(0xFF181818),
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 45,
                        ),
                        Text("Busqueda BTS PTI",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: media.width * .1)),
                        const SizedBox(
                          height: 35,
                        ),
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        Text("Cargando datos...",
                            style: GoogleFonts.nunito(
                                color: Colors.white, fontSize: 15)),
                        Expanded(child: Container()),
                        Text("V 1.1.5",
                            style: GoogleFonts.nunito(
                                color: Colors.white, fontSize: 15)),
                      ],
                    ),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 45,
                          ),
                          Text("¡Bienvenido!",
                              style: GoogleFonts.nunito(
                                  color: Colors.white, fontSize: 35)),
                          SizedBox(
                            height: media.width * .5,
                          ),
                          InkWell(
                            onTap: () => Navigator.pushAndRemoveUntil(
                                context,
                                PageTransition(
                                    child: SignInScreen(
                                      firstMoment: true,
                                    ),
                                    type: PageTransitionType.rightToLeft),(Route<dynamic> route)=>false),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 45, vertical: 12),
                              child: Text("Iniciar Sesión",
                                  style: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
