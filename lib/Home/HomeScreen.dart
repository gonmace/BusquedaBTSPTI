// ignore_for_file: file_names, dead_code, unnecessary_null_comparison, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:busquedabtspti/Backend/Backend.dart';
import 'package:busquedabtspti/Models/MainDataModel.dart';
import 'package:busquedabtspti/Models/RegistroCandidato.dart';
import 'package:busquedabtspti/Models/RegistroElectrico_model.dart';
import 'package:busquedabtspti/Models/RegistroLlegada_Model.dart';
import 'package:busquedabtspti/Models/RegistroLocalidad.dart';
import 'package:busquedabtspti/Models/RegistroPropiedad_Model.dart';
import 'package:busquedabtspti/Models/RegistroSitioImagenesModel.dart';
import 'package:busquedabtspti/Models/RegistroSitioModel.dart';
import 'package:busquedabtspti/Models/Sitio_Models.dart';
import 'package:busquedabtspti/Start/SigninUpScreen/IniciarSesion.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:entry/entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final PageController _pageController = PageController();
  TextEditingController comentario = TextEditingController();
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi)) {
        setState(() {
          loading = true;
        });

        Map<String, dynamic>? registroinicio = await pedirinfo(1);
        if (registroinicio != null) {
          await eliminarDatoLocalmente('inicio');
          Registrollegada registrorecargado =
              Registrollegada.fromJson(registroinicio);
          await Future.delayed(Duration(seconds: 2));
          MainData? candidato = await enviarDatos(registrorecargado);
          if (candidato != null) {
            if (candidato.success) {
              Map<String, dynamic>? localidadcargado = await pedirinfo(2);
              if (localidadcargado != null) {
                await eliminarDatoLocalmente('seconpage');
                Localidad registrorecargado2 =
                    Localidad.fromJson(localidadcargado);
                await enviarDatosLocalidad(registrorecargado2);
              }
              Map<String, dynamic>? localidadCandidato = await pedirinfo(3);
              if (localidadCandidato != null) {
                await eliminarDatoLocalmente('candidato');
                Registrocandidato registrorecargado2 =
                    Registrocandidato.fromJson(localidadCandidato);
                await enviarDatosCANDIDATO(registrorecargado2);
              }
              Map<String, dynamic>? localidadpropiedad = await pedirinfo(4);
              if (localidadpropiedad != null) {
                await eliminarDatoLocalmente('propiedad');
                RegistroPropiedad registrorecargado2 =
                    RegistroPropiedad.fromJson(localidadpropiedad);
                await enviarDatosPropiedad(registrorecargado2);
              }

              String? regsitio = await obtenerDatoLocalmente('regsitio');
              if (regsitio != null) {
                List<RegistroSitioImagenes> imagenesData =
                    await obtenerListaLocalmente();
                if (imagenesData.isNotEmpty) {
                  Map<String, dynamic> map = json.decode(regsitio);
                  RegistroSitios registrositio = RegistroSitios.fromJson(map);
                  await eliminarDatoLocalmente('registroSitioLista');
                  await eliminarDatoLocalmente('regsitio');
                  await enviarDatosRegistroSitio(imagenesData, registrositio);
                  String? localidadElectricidad =
                      await obtenerDatoLocalmente('electrico');
                  if (localidadElectricidad != null) {
                    await eliminarDatoLocalmente('electrico');
                    Map<String, dynamic> map =
                        json.decode(localidadElectricidad);
                    RegistroElectrico registrorecargado2 =
                        RegistroElectrico.fromJson(map);

                    await enviarDatosRegistroElectrico(registrorecargado2);
                  }
                }
              }
              CherryToast.success(
                toastDuration: const Duration(seconds: 5),
                title: Text("Datos offline cargados correctamente",
                    style: TextStyle(color: Colors.black)),
              ).show(context);
            } else {
              await eliminarDatoLocalmente('inicio');
              CherryToast.error(
                toastDuration: const Duration(seconds: 5),
                title: Text("${candidato.message}",
                    style: TextStyle(color: Colors.black)),
              ).show(context);
            }
          } else {
            CherryToast.error(
              toastDuration: const Duration(seconds: 5),
              title: Text("Hubo un problema tu ultimos datos",
                  style: TextStyle(color: Colors.black)),
            ).show(context);
          }
          /* await enviarDatos(registrorecargado);
          await eliminarDatoLocalmente('inicio'); */
        }
        setState(() {
          loading = false;
        });
      }
    });
  }

  Future<Map<String, dynamic>?> pedirinfo(int tipo) async {
    String? mapa;
    switch (tipo) {
      case 1:
        mapa = await obtenerDatoLocalmente('inicio');
        break;
      case 2:
        mapa = await obtenerDatoLocalmente('seconpage');
        break;
      case 3:
        mapa = await obtenerDatoLocalmente('candidato');
        break;
      case 4:
        mapa = await obtenerDatoLocalmente('propiedad');
        break;
      case 5:
        mapa = await obtenerDatoLocalmente('electrico');
        break;
      default:
    }

    if (mapa != null) {
      return jsonDecode(mapa);
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int? cantidato = 1;
  int ind = 0;

  //Variables para desactivar el funcionamiento
  bool registrolocalidad = false;
  bool registropropietario = false;
  bool registropropiedad = false;
  bool registrositio = false;
  bool registroelectrico = false;
  bool registrositioenviado = false;

  //Booleanos secundarias
  bool _inicio = false;
  bool _localidad = false;
  bool _propietario = false;
  bool _propiedad = false;
  bool _registrarsitio = false;
  bool _registroelectrico = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              Scaffold(
                  resizeToAvoidBottomInset: true,
                  key: _scaffoldKey,
                  drawer: Drawer(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 25),
                      child: Column(
                        children: [
                          const Divider(),
                          ListTile(
                            onTap: () async {
                              setState(() {
                                loading = true;
                              });
                              await deletesitios();
                              await clearUserData();
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      child: SignInScreen(
                                        firstMoment: false,
                                      ),
                                      type: PageTransitionType.rightToLeft));
                            },
                            title: Text(
                              "Cerrar Sesión",
                              style: GoogleFonts.nunito(
                                  color: Colors.black, fontSize: 17),
                            ),
                            trailing: const Icon(Icons.logout),
                          ),
                          const Divider()
                        ],
                      ),
                    ),
                  ),
                  appBar: AppBar(
                    elevation: 5.2,
                    scrolledUnderElevation: 0,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    shadowColor: Colors.grey,
                    title: Row(
                      children: [
                        sitioseleccionado == null
                            ? Expanded(
                                child: Text("Busqueda BTSPTI",
                                    style: GoogleFonts.nunito(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)))
                            : Container(),
                        sitioseleccionado != null
                            ? Expanded(
                                child: Text(
                                    "SITIO: ${sitioseleccionado!.ptiCellId}",
                                    style: GoogleFonts.nunito(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)))
                            : Container()
                      ],
                    ),
                    leadingWidth: 70,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () => _scaffoldKey.currentState!.openDrawer(),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: SvgPicture.asset('assets/logo3.svg'),
                          )),
                    ),
                  ),
                  body: Container(
                    padding:
                        const EdgeInsets.only(top: 25, left: 25, right: 25),
                    width: media.width * 1,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          //REGISTRAR LLEGADA
                          InkWell(
                            onTap: () {
                              if (enviadomain) {
                                return;
                              }
                              setState(() {
                                _inicio = !_inicio;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text("Inicio",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                  ],
                                )),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Divider(),
                          const SizedBox(
                            height: 15,
                          ),
                          //REGISTRAR LOCALIDAD
                          InkWell(
                            onTap: () {
                              if (!registrolocalidad) {
                                return;
                              }
                              setState(() {
                                _localidad = true;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text("Localidad",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Icon(
                                      registrolocalidad
                                          ? Icons.lock_open
                                          : Icons.lock_outline_rounded,
                                      color: registrolocalidad
                                          ? Color.fromARGB(255, 0, 255, 8)
                                          : Color.fromARGB(255, 255, 17, 0),
                                    )
                                  ],
                                )),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Divider(),
                          const SizedBox(
                            height: 15,
                          ),
                          // REGISTRAR PROPIETARIO Y PROPIEDAD
                          InkWell(
                            onTap: () {
                              if (!registropropietario) {
                                return;
                              }
                              setState(() {
                                _propietario = true;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text("Propietario",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Icon(
                                      registropropietario
                                          ? Icons.lock_open
                                          : Icons.lock_outline_rounded,
                                      color: registropropietario
                                          ? Color.fromARGB(255, 0, 255, 8)
                                          : Color.fromARGB(255, 255, 17, 0),
                                    )
                                  ],
                                )),
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          Divider(),
                          const SizedBox(
                            height: 15,
                          ),
                          // REGISTRAR PROPIEDAD
                          InkWell(
                            onTap: () {
                              if (!registropropiedad) {
                                return;
                              }
                              setState(() {
                                _propiedad = true;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text("Propiedad",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Icon(
                                      registropropiedad
                                          ? Icons.lock_open
                                          : Icons.lock_outline_rounded,
                                      color: registropropiedad
                                          ? Color.fromARGB(255, 0, 255, 8)
                                          : Color.fromARGB(255, 255, 17, 0),
                                    )
                                  ],
                                )),
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          Divider(),
                          const SizedBox(
                            height: 15,
                          ),
                          // REGISTRAR SITIO
                          InkWell(
                            onTap: () {
                              if (!registrositio) {
                                return;
                              }
                              setState(() {
                                _registrarsitio = true;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text("Sitio",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Icon(
                                      registrositio
                                          ? Icons.lock_open
                                          : Icons.lock_outline_rounded,
                                      color: registrositio
                                          ? Color.fromARGB(255, 0, 255, 8)
                                          : Color.fromARGB(255, 255, 17, 0),
                                    )
                                  ],
                                )),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Divider(),
                          const SizedBox(
                            height: 15,
                          ),
                          //Registro Electrico
                          InkWell(
                            onTap: () async {
                              if (!registroelectrico) {
                                return;
                              }
                              setState(() {
                                _registroelectrico = true;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text("Electrico",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Icon(
                                      registroelectrico
                                          ? Icons.lock_open
                                          : Icons.lock_outline_rounded,
                                      color: registroelectrico
                                          ? Color.fromARGB(255, 0, 255, 8)
                                          : Color.fromARGB(255, 255, 17, 0),
                                    )
                                  ],
                                )),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Divider(),
                          const SizedBox(
                            height: 15,
                          ),
                          //Registro Electrico
                          InkWell(
                            onTap: () async {
                              if (!registrositioenviado) {
                                return CherryToast.error(
                                  toastDuration: const Duration(seconds: 5),
                                  title: const Text(
                                      "Registra tu llegada y el sitio para finalizar.",
                                      style: TextStyle(color: Colors.black)),
                                ).show(context);
                              }
                              setState(() {
                                loading = true;
                              });
                              await showDialog<String>(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  String description = '';
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.white38,
                                    surfaceTintColor: Colors.white,
                                    title: const Text(
                                      "¿Estás seguro de concluir este registro en este sitio?",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'NO',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          clear();
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'SI',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              setState(() {
                                loading = false;
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text("Finalizar",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Icon(
                                      registrositioenviado
                                          ? Icons.lock_open
                                          : Icons.lock_outline_rounded,
                                      color: registrositioenviado
                                          ? Color.fromARGB(255, 0, 255, 8)
                                          : Color.fromARGB(255, 255, 17, 0),
                                    )
                                  ],
                                )),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  )),
              if (_inicio)
                multiscreen(mainForm(), () {
                  setState(() {
                    _inicio = false;
                  });
                }, "Registro de llegada"),
              if (_localidad)
                multiscreen(pageSecondary(), () {
                  setState(() {
                    _localidad = false;
                  });
                }, "Registro Localidad"),
              if (_propietario)
                multiscreen(thirdPageMain(), () {
                  setState(() {
                    _propietario = false;
                  });
                }, "Datos del Propietario"),
              if (_propiedad)
                multiscreen(propiedad(), () {
                  setState(() {
                    _propiedad = false;
                  });
                }, "Datos de la propiedad"),
              if (_registrarsitio)
                multiscreen(thirdpage(), () {
                  setState(() {
                    _registrarsitio = false;
                  });
                }, "Registro del sitio"),
              if (_registroelectrico)
                multiscreen(fourPage(), () {
                  setState(() {
                    _registroelectrico = false;
                  });
                }, "Registro Electrico"),
              if (loading)
                InkWell(
                  onTap: () => {
                    setState(() {
                      loading = false;
                    })
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget multiscreen(Widget data, void Function()? name, String title) {
    return Entry.offset(
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 25, left: 25, right: 25),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(
                  title,
                  style: GoogleFonts.nunito(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                )),
                IconButton(onPressed: name, icon: Icon(Icons.close)),
              ],
            ),
            Divider(),
            Expanded(child: data),
          ],
        ),
      ),
    );
  }

  String? _selectedOption;
  String? _selectedOptionTipopersonas;
  Sitio? sitioseleccionado;
  String? idcandidato;
  bool enviadomain = false;
  Widget mainForm() {
    var media = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () async {
              if (enviadomain) {
                return;
              }
              setState(() {
                loading = true;
              });
              List<Sitio> sitios = await loadSitiosFromPrefs();
              if (sitios.isNotEmpty) {
                Sitio? site = await sheetInfo(sitios);
                setState(() {
                  sitioseleccionado = site;
                });
              } else {
                CherryToast.error(
                  toastDuration: const Duration(seconds: 5),
                  title: const Text("No se encontraron sitios disponibles",
                      style: TextStyle(color: Colors.black)),
                ).show(context);
              }
              setState(() {
                loading = false;
              });
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black),
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                          sitioseleccionado != null
                              ? sitioseleccionado!.nombre
                              : "Seleccionar sitio",
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                    )
                  ],
                )),
          ),
          const SizedBox(
            height: 25,
          ),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text('Llegada',
                style: GoogleFonts.nunito(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            value: 'Llegada',
            activeColor: Colors.black,
            fillColor: const MaterialStatePropertyAll(Colors.black),
            groupValue: _selectedOption,
            onChanged: (String? value) {
              if (enviadomain) {
                return;
              }
              setState(() {
                _selectedOption = value;
              });
            },
          ),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text('Incidente',
                style: GoogleFonts.nunito(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            value: 'Incidente',
            activeColor: Colors.black,
            fillColor: const MaterialStatePropertyAll(Colors.black),
            groupValue: _selectedOption,
            onChanged: (String? value) {
              if (enviadomain) {
                return;
              }
              setState(() {
                _selectedOption = value;
              });
            },
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            width: media.width * .7,
            height: media.width * .12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    "Lat",
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  width: media.width * .5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    " ${latregistrollegad ?? ''}",
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: media.width * .7,
            height: media.width * .12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    "Log",
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: media.width * .5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    " ${logregistrollegad ?? ''}",
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              if (enviadomain) {
                return;
              }
              capturarlatlog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(25)),
              child: Text(
                "Capturar Ubicación",
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            height: media.width * .5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black)),
            child: TextFormField(
              controller: comentario,
              style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              maxLines: null,
              decoration: InputDecoration(
                  hintText: "Comentario",
                  hintStyle: GoogleFonts.nunito(
                      color: const Color.fromARGB(97, 63, 63, 63),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent))),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () async {
              if (enviadomain) {
                return;
              }
              if (_imageFileRegistrollegada != null) {
                setState(() {
                  _imageFileRegistrollegada = null;
                });
              } else {
                await _cameraRegistrollegada();
              }
            },
            child: Container(
              width: media.width * .4,
              height: media.width * .4,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black)),
              child: _imageFileRegistrollegada != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_imageFileRegistrollegada!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Icon(
                            Icons.camera_alt,
                            size: 70,
                          ),
                          Text(
                            "Tomar fotografia",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )
                        ]),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {
                  if (_selectedOption != null &&
                      sitioseleccionado != null &&
                      latregistrollegad != null &&
                      logregistrollegad != null &&
                      comentario.text.isNotEmpty &&
                      _imageFileRegistrollegada != null) {
                    setState(() {
                      loading = true;
                    });
                    var registro = Registrollegada(
                      candidato: Candidato(
                          sitio: sitioseleccionado!.ptiCellId,
                          usuario: dataUser!.userId.toString(),
                          candidato: cantidato!),
                      status: _selectedOption != 'Llegada' ? false : true,
                      latLlegada: latregistrollegad!,
                      lonLlegada: logregistrollegad!,
                      fechaLlegada: DateTime.now().toIso8601String(),
                      observaciones: comentario.text,
                      imagenLlegada: _imageFileRegistrollegada!.path,
                    );
                    if (await verificarConexionInternet()) {
                      MainData? candidato = await enviarDatos(registro);
                      if (candidato != null) {
                        print("aaas${candidato.success}");
                        if (candidato.success) {
                          if (candidato.data != null) {
                            if (_selectedOption != 'Llegada') {
                              setState(() {
                                latregistrollegad = null;
                                logregistrollegad = null;
                                cantidato = 1;
                                _selectedOption = null;
                                _imageFileRegistrollegada = null;
                                sitioseleccionado = null;
                                comentario.clear();
                                _inicio = false;
                              });
                              await Future.delayed(Duration(seconds: 2));
                              setState(() {
                                loading = false;
                              });
                            } else {
                              setState(() {
                                provincia.text =
                                    sitioseleccionado?.provincia ?? '';
                                municipio.text =
                                    sitioseleccionado?.municipio ?? '';
                                localidad.text =
                                    sitioseleccionado?.localidad ?? '';
                                _inicio = false;
                                enviadomain = true;
                                registrolocalidad = true;
                                registropropietario = true;
                                registropropiedad = true;
                                registrositio = true;
                                comentario.clear();
                                idcandidato =
                                    candidato.data!.candidato.candidato;
                              });
                              await Future.delayed(Duration(seconds: 2));
                              setState(() {
                                loading = false;
                              });
                            }
                          }
                        } else {
                          setState(() {
                            loading = false;
                            _imageFileRegistrollegada = null;
                          });
                          CherryToast.error(
                            toastDuration: const Duration(seconds: 5),
                            title: Text("${candidato.message}",
                                style: TextStyle(color: Colors.black)),
                          ).show(context);
                        }
                      }
                    } else {
                      guardarDatoLocalmente(
                          "inicio", jsonEncode(registro.toJson()));
                      if (_selectedOption != 'Llegada') {
                        setState(() {
                          latregistrollegad = null;
                          logregistrollegad = null;
                          cantidato = 1;
                          _selectedOption = null;
                          _imageFileRegistrollegada = null;
                          sitioseleccionado = null;
                          comentario.clear();
                          _inicio = false;
                          loading = false;
                        });
                      } else {
                        setState(() {
                          provincia.text = sitioseleccionado?.provincia ?? '';
                          municipio.text = sitioseleccionado?.municipio ?? '';
                          localidad.text = sitioseleccionado?.localidad ?? '';
                          _inicio = false;
                          enviadomain = true;
                          registrolocalidad = true;
                          registropropietario = true;
                          registropropiedad = true;
                          registrositio = true;
                          comentario.clear();
                          loading = false;
                          idcandidato = "";
                        });
                      }
                    }
                  } else {
                    CherryToast.error(
                      toastDuration: const Duration(seconds: 5),
                      title: const Text("Datos incompletos",
                          style: TextStyle(color: Colors.black)),
                      action: const Text(
                          "Debes llenar y seleccionar todos los campos",
                          style: TextStyle(color: Colors.black)),
                    ).show(context);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text("Continuar",
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  Future<Sitio?> sheetInfo(List<Sitio> sitios) async {
    Sitio? sitoo = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: sitios.length,
          itemBuilder: (context, index) {
            Sitio sitio = sitios[index];
            return Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(sitio.nombre),
                  subtitle: Text(sitio.ptiCellId),
                  onTap: () {
                    Navigator.pop(context, sitio);
                  },
                ),
                const Divider()
              ],
            );
          },
        );
      },
    );
    return sitoo;
  }

  bool existingEnergy = false;
  bool casado = false;

  TextEditingController provincia = TextEditingController();
  TextEditingController municipio = TextEditingController();
  TextEditingController localidad = TextEditingController();

  Widget pageSecondary() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25,
          ),
          Text("Provincia/Region",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: provincia,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 25),
          Text("Municipio/Comuna",
              style: GoogleFonts.nunito(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: municipio,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 25),
          Text("Localidad",
              style: GoogleFonts.nunito(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: localidad,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Checkbox(
                checkColor: Colors.white,
                activeColor: Colors.black,
                overlayColor: const MaterialStatePropertyAll(Colors.white),
                value: existingEnergy,
                onChanged: (value) {
                  setState(() {
                    existingEnergy = !existingEnergy;
                  });
                },
              ),
              Expanded(
                child: Text("Existe energia electrica",
                    style: GoogleFonts.nunito(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {
                  if (provincia.text.isNotEmpty &&
                      municipio.text.isNotEmpty &&
                      localidad.text.isNotEmpty &&
                      sitioseleccionado != null) {
                    setState(() {
                      loading = true;
                    });
                    var reglocaldiad = Localidad(
                      sitio: sitioseleccionado!.ptiCellId,
                      provincia: provincia.text,
                      usuario: dataUser!.userId,
                      municipio: municipio.text,
                      localidad: localidad.text,
                      energiaLocalidad: existingEnergy,
                    );
                    if (await verificarConexionInternet()) {
                      await enviarDatosLocalidad(reglocaldiad);
                    } else {
                      await guardarDatoLocalmente(
                          'seconpage', jsonEncode(reglocaldiad.toJson()));
                    }
                    setState(() {
                      _localidad = false;
                      registrolocalidad = false;
                    });
                    await Future.delayed(Duration(seconds: 2));
                    setState(() {
                      loading = false;
                    });
                  } else {
                    CherryToast.error(
                      toastDuration: const Duration(seconds: 5),
                      title: const Text("Datos incompletos",
                          style: TextStyle(color: Colors.black)),
                      action: const Text("Debes llenar todos los campos",
                          style: TextStyle(color: Colors.black)),
                    ).show(context);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text("Continuar",
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String? _descripcion;
  String? _descripcionDatosElectricos;
  String? _descripcionDatosElectricos2;
  double? _latitudDatosElectricos, _longitudDatosElectricos;

  //REGISTRO CANDIDATO
  TextEditingController nombre = TextEditingController();
  TextEditingController fechanacimiento = TextEditingController();
  String fechanacimientodate = "";
  TextEditingController documentoidentidad = TextEditingController();
  TextEditingController telefono = TextEditingController();

  TextEditingController email = TextEditingController();
  TextEditingController direccion = TextEditingController();
  TextEditingController estadocivil = TextEditingController();
  //PROPIETARIO DATOS CONTACTO
  TextEditingController contactonombre = TextEditingController();
  TextEditingController contactotel = TextEditingController();
  TextEditingController contactoemail = TextEditingController();
  TextEditingController contactorelacion = TextEditingController();

  //Registro propiedad
  TextEditingController rol = TextEditingController();
  TextEditingController escrituras = TextEditingController();
  TextEditingController registrocibil = TextEditingController();
  TextEditingController descripcionpropiedad = TextEditingController();
  TextEditingController comentarioPropiedad = TextEditingController();
  TextEditingController direccionPropiedad = TextEditingController();
  //Registro Sitio
  TextEditingController comentarioSitio = TextEditingController();
  TextEditingController propuestaNegociacionSitio = TextEditingController();
  TextEditingController espacioNegociadoSitio = TextEditingController();
  //Registro Electrico
  TextEditingController numerodepostes = TextEditingController();

  Widget thirdPageMain() {
    return SingleChildScrollView(
        child: Column(children: [
      const SizedBox(height: 25),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nombre y Apellido",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: nombre,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Propietario",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Text("Fecha de nacimiento",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          InkWell(
            onTap: () async {
              DateTime? date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1199),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme(
                              brightness: Brightness.light,
                              primary: Colors.white,
                              onPrimary: Colors.red,
                              secondary: Colors.blue,
                              onSecondary: Colors.yellow,
                              error: Colors.red,
                              onError: Colors.redAccent,
                              background: Colors.black,
                              onBackground: Colors.black,
                              surface: Colors.black,
                              onSurface: Colors.white)),
                      child: child!,
                    );
                  },
                  lastDate: DateTime.now());
              if (date != null) {
                setState(() {
                  String fechaFormateada =
                      DateFormat('dd/MM/yyyy').format(date);
                  fechanacimiento.text = fechaFormateada;
                  fechanacimientodate = date.toIso8601String();
                });
              }
            },
            child: TextFormField(
              controller: fechanacimiento,
              enabled: false,
              cursorColor: const Color.fromARGB(255, 0, 0, 0),
              style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              decoration: InputDecoration(
                  hintText: "Fecha de nacimiento",
                  hintStyle: GoogleFonts.nunito(
                      color: const Color.fromARGB(138, 56, 56, 56),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(138, 56, 56, 56))),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0)))),
            ),
          ),
          const SizedBox(height: 15),
          Text("Numero del documento",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: documentoidentidad,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Documento de identidad",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Text("Telefono de contacto",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: telefono,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Telefono de contacto",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Text("Correo electronico",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: email,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Correo electronico",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Text("Dirreción",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: direccion,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Dirección",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Checkbox(
                checkColor: Colors.white,
                activeColor: Colors.black,
                overlayColor: const MaterialStatePropertyAll(Colors.white),
                value: casado,
                onChanged: (value) {
                  setState(() {
                    casado = !casado;
                  });
                },
              ),
              Expanded(
                child: Text("Estado Civil Casado",
                    style: GoogleFonts.nunito(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text("Tipo de persona",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text('Natural',
                style: GoogleFonts.nunito(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            value: 'Natural',
            activeColor: Colors.black,
            fillColor: const MaterialStatePropertyAll(Colors.black),
            groupValue: _selectedOptionTipopersonas,
            onChanged: (String? value) {
              setState(() {
                _selectedOptionTipopersonas = value;
              });
            },
          ),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text('Juridica',
                style: GoogleFonts.nunito(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            value: 'Juridica',
            activeColor: Colors.black,
            fillColor: const MaterialStatePropertyAll(Colors.black),
            groupValue: _selectedOptionTipopersonas,
            onChanged: (String? value) {
              setState(() {
                _selectedOptionTipopersonas = value;
              });
            },
          ),
          Divider(),
          const SizedBox(height: 5),
          Text("Contacto",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text("Nombre y Apellido",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: contactonombre,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Nombre",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Text("Numero de telefono",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: contactotel,
            keyboardType: TextInputType.phone,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Telefono",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Text("Correo electronico",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: contactoemail,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Correo electronico",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Text("Relación con el propietario",
              style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(0, 0, 0, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: contactorelacion,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Relación",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          const SizedBox(height: 25),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () async {
              if (nombre.text.isNotEmpty &&
                  fechanacimiento.text.isNotEmpty &&
                  documentoidentidad.text.isNotEmpty &&
                  telefono.text.isNotEmpty &&
                  email.text.isNotEmpty &&
                  esCorreoValido(email.text) &&
                  _selectedOptionTipopersonas != null &&
                  direccion.text.isNotEmpty &&
                  // Validar campos opcionales solo si están llenos
                  (contactonombre.text.isEmpty ||
                      (contactoemail.text.isNotEmpty &&
                          esCorreoValido(contactoemail.text)))) {
                setState(() {
                  loading = true;
                });
                //CANDIDATO
                var candidato = Registrocandidato(
                    propietario_tipo_persona:
                        _selectedOptionTipopersonas!.toLowerCase(),
                    contacto_email: contactoemail.text,
                    contacto_nombre: contactonombre.text,
                    contacto_relacion: contactorelacion.text,
                    contacto_tel: contactotel.text,
                    propietario_email: email.text,
                    usuario: dataUser!.userId,
                    direccion: direccion.text,
                    propietarioNombreApellido: nombre.text,
                    propietarioBorn: fechanacimientodate,
                    propietarioCi: documentoidentidad.text,
                    propietarioTelf: documentoidentidad.text,
                    propietarioEstadoCivil: casado,
                    propietarioDireccion: "Dirreccion local",
                    sitio: sitioseleccionado!.ptiCellId);

                if (await verificarConexionInternet()) {
                  await enviarDatosCANDIDATO(candidato);
                } else {
                  await guardarDatoLocalmente(
                      "candidato", jsonEncode(candidato.toJson()));
                }
                setState(() {
                  _propietario = false;
                  registropropietario = false;
                });
                await Future.delayed(Duration(seconds: 2));
                setState(() {
                  loading = false;
                });
              } else {
                CherryToast.error(
                  toastDuration: const Duration(seconds: 5),
                  title: const Text("Datos incompletos",
                      style: TextStyle(color: Colors.black)),
                  action: const Text("Debes llenar todos los campos",
                      style: TextStyle(color: Colors.black)),
                ).show(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Text("Continuar",
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      const SizedBox(
        height: 25,
      )
    ]));
  }

  bool esCorreoValido(String correo) {
    return correo.isNotEmpty && correo.contains("@") && correo.contains(".");
  }

  Widget propiedad() {
    var media = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      children: [
        const SizedBox(height: 25),
        Column(
          children: [
            InkWell(
              onTap: () async {
                if (_imageFile != null) {
                  setState(() {
                    _imageFile = null;
                    _descripcion = null;
                  });
                } else {
                  _openCamera();
                }
              },
              child: Container(
                width: media.width * .5,
                height: media.width * .5,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white)),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              size: 90,
                            ),
                            Text("Tomar Foto",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
              ),
            ),
            Text(
                _descripcion != null ? _descripcion! : "Descripcion de la foto",
                style: GoogleFonts.nunito(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 15,
                )),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        TextFormField(
          controller: rol,
          cursorColor: const Color.fromARGB(255, 0, 0, 0),
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
              hintText: "Rol",
              hintStyle: GoogleFonts.nunito(
                  color: const Color.fromARGB(138, 56, 56, 56),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(138, 56, 56, 56))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: escrituras,
          cursorColor: const Color.fromARGB(255, 0, 0, 0),
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
              hintText: "Escrituras",
              hintStyle: GoogleFonts.nunito(
                  color: const Color.fromARGB(138, 56, 56, 56),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(138, 56, 56, 56))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: registrocibil,
          cursorColor: const Color.fromARGB(255, 0, 0, 0),
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
              hintText: "Registro civil",
              hintStyle: GoogleFonts.nunito(
                  color: const Color.fromARGB(138, 56, 56, 56),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(138, 56, 56, 56))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: direccionPropiedad,
          cursorColor: const Color.fromARGB(255, 0, 0, 0),
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
              hintText: "Dirección",
              hintStyle: GoogleFonts.nunito(
                  color: const Color.fromARGB(138, 56, 56, 56),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(138, 56, 56, 56))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          height: media.width * .5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black)),
          child: TextFormField(
            controller: comentarioPropiedad,
            style: GoogleFonts.nunito(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
            maxLines: null,
            decoration: InputDecoration(
                hintText: "Comentario",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(97, 63, 63, 63),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent))),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () async {
                if (_imageFile != null &&
                    rol.text.isNotEmpty &&
                    escrituras.text.isNotEmpty &&
                    direccionPropiedad.text.isNotEmpty &&
                    registrocibil.text.isNotEmpty &&
                    comentarioPropiedad.text.isNotEmpty) {
                  setState(() {
                    loading = true;
                  });

                  //PROPIEDAD
                  var propiedad = RegistroPropiedad(
                      propiedaddireccion: direccionPropiedad.text,
                      propiedadRol: rol.text,
                      propiedadEscritura: escrituras.text,
                      propiedadRegistroCivil: registrocibil.text,
                      sitio: sitioseleccionado!.ptiCellId,
                      propiedadDescripcion: comentarioPropiedad.text,
                      propiedadImagen: _imageFile!.path);
                  if (await verificarConexionInternet()) {
                    await enviarDatosPropiedad(propiedad);
                  } else {
                    await guardarDatoLocalmente(
                        "propiedad", jsonEncode(propiedad.toJson()));
                  }

                  setState(() {
                    _propiedad = false;
                    registropropiedad = false;
                  });
                  await Future.delayed(Duration(seconds: 2));
                  setState(() {
                    loading = false;
                  });
                } else {
                  CherryToast.error(
                    toastDuration: const Duration(seconds: 5),
                    title: const Text("Datos incompletos",
                        style: TextStyle(color: Colors.black)),
                    action: const Text("Debes llenar todos los campos",
                        style: TextStyle(color: Colors.black)),
                  ).show(context);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12)),
                child: Text("Continuar",
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 25,
        )
      ],
    ));
  }

  RegistroSitioImagenes? _imagensitioPunto;
  RegistroSitioImagenes? _imagensitiovalidacion;
  RegistroSitioImagenes? _imagensitioGps;

  Widget thirdpage() {
    var media = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            height: media.width * .5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black)),
            child: TextFormField(
              controller: comentarioSitio,
              style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              maxLines: null,
              decoration: InputDecoration(
                  hintText: "Comentario",
                  hintStyle: GoogleFonts.nunito(
                      color: const Color.fromARGB(97, 63, 63, 63),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent))),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Centro de la torre",
            style: GoogleFonts.nunito(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: media.width * .8,
            height: media.width * .12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Lat",
                  style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 25,
                ),
                Container(
                  width: media.width * .5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    " ${latregistrositio ?? ''}",
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: media.width * .8,
            height: media.width * .12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Lon",
                  style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 25,
                ),
                Container(
                  width: media.width * .5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    " ${logregistrositio ?? ''}",
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              setState(() {
                loading = true;
              });
              Position position = await _getLocation();
              setState(() {
                latregistrositio = position.latitude;
                logregistrositio = position.longitude;
                loading = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(25)),
              child: Text(
                "Capturar coordenadas",
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 35),
          TextFormField(
            controller: propuestaNegociacionSitio,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Propuesta de Negociacion",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: espacioNegociadoSitio,
            cursorColor: const Color.fromARGB(255, 0, 0, 0),
            style:
                GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                hintText: "Espacio negociado",
                hintStyle: GoogleFonts.nunito(
                    color: const Color.fromARGB(138, 56, 56, 56),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(138, 56, 56, 56))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color.fromARGB(255, 0, 0, 0)))),
          ),
          const SizedBox(height: 15),
          Divider(),
          Column(
            children: [
              InkWell(
                onTap: () {
                  if (latregistrositio == null && logregistrositio == null) {
                    return CherryToast.error(
                      toastDuration: const Duration(seconds: 5),
                      title: Text("Debes Capturar las coordenadas primero",
                          style: TextStyle(color: Colors.black)),
                    ).show(context);
                  }
                  _openmultiCamera();
                },
                child: Container(
                  width: media.width * .5,
                  height: media.width * .5,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Icon(
                          _imageList.isNotEmpty
                              ? Icons.add_a_photo
                              : Icons.camera_alt,
                          size: 80,
                        ),
                        Text("Capturar imagenes",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: media.width * .035,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () async {
                      if (latregistrositio == null &&
                          logregistrositio == null) {
                        return CherryToast.error(
                          toastDuration: const Duration(seconds: 5),
                          title: Text("Debes Capturar las coordenadas primero",
                              style: TextStyle(color: Colors.black)),
                        ).show(context);
                      }
                      if (_imagensitioPunto != null) {
                      } else {
                        RegistroSitioImagenes? img =
                            await _openCameraImagenesSitio();
                        if (img != null) {
                          setState(() {
                            _imagensitioPunto = img;
                          });
                        }
                        setState(() {
                          loading = false;
                        });
                      }
                    },
                    child: SizedBox(
                      width: media.width * .25,
                      height: media.width * .3,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            top: 0,
                            child: _imagensitioPunto == null
                                ? Column(
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 70,
                                      ),
                                      Text("Foto del sitio",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.nunito(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: media.width * .035,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        width: media.width * .2,
                                        height: media.width * .2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(_imagensitioPunto!
                                                .sitioImagenes),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Text(_imagensitioPunto!.sitioDescripcion,
                                          style: GoogleFonts.nunito(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontSize: 15,
                                          ))
                                    ],
                                  ),
                          ),
                          if (_imagensitioPunto != null)
                            Positioned(
                              right: 25,
                              top: 5,
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _imagensitioPunto = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(255, 255, 17, 0)),
                                    child: const Icon(
                                      Icons.delete_sharp,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (latregistrositio == null &&
                          logregistrositio == null) {
                        return CherryToast.error(
                          toastDuration: const Duration(seconds: 5),
                          title: Text("Debes Capturar las coordenadas primero",
                              style: TextStyle(color: Colors.black)),
                        ).show(context);
                      }
                      if (_imagensitiovalidacion != null) {
                      } else {
                        RegistroSitioImagenes? img =
                            await _openCameraImagenesSitio();
                        if (img != null) {
                          setState(() {
                            _imagensitiovalidacion = img;
                          });
                        }
                        setState(() {
                          loading = false;
                        });
                      }
                    },
                    child: SizedBox(
                      width: media.width * .25,
                      height: media.width * .3,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            top: 0,
                            left: 0,
                            right: 0,
                            child: _imagensitiovalidacion == null
                                ? Column(
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 70,
                                      ),
                                      Text("Foto de validacion",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.nunito(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: media.width * .035,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        width: media.width * .2,
                                        height: media.width * .2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(_imagensitiovalidacion!
                                                .sitioImagenes),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Text(
                                          _imagensitiovalidacion!
                                              .sitioDescripcion,
                                          style: GoogleFonts.nunito(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontSize: 15,
                                          ))
                                    ],
                                  ),
                          ),
                          if (_imagensitiovalidacion != null)
                            Positioned(
                              right: 25,
                              top: 5,
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _imagensitiovalidacion = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(255, 255, 17, 0)),
                                    child: const Icon(
                                      Icons.delete_sharp,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (latregistrositio == null &&
                          logregistrositio == null) {
                        return CherryToast.error(
                          toastDuration: const Duration(seconds: 5),
                          title: Text("Debes Capturar las coordenadas primero",
                              style: TextStyle(color: Colors.black)),
                        ).show(context);
                      }
                      if (_imagensitioGps != null) {
                      } else {
                        RegistroSitioImagenes? img =
                            await _openCameraImagenesSitio();
                        if (img != null) {
                          setState(() {
                            _imagensitioGps = img;
                          });
                        }
                        setState(() {
                          loading = false;
                        });
                      }
                    },
                    child: SizedBox(
                      width: media.width * .25,
                      height: media.width * .3,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            top: 0,
                            left: 0,
                            right: 0,
                            child: _imagensitioGps == null
                                ? Column(
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 70,
                                      ),
                                      Text("GPS",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.nunito(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: media.width * .035,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        width: media.width * .2,
                                        height: media.width * .2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(
                                                _imagensitioGps!.sitioImagenes),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Text(_imagensitioGps!.sitioDescripcion,
                                          style: GoogleFonts.nunito(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontSize: 15,
                                          ))
                                    ],
                                  ),
                          ),
                          if (_imagensitioGps != null)
                            Positioned(
                              right: 25,
                              top: 5,
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _imagensitioGps = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(255, 255, 17, 0)),
                                    child: const Icon(
                                      Icons.delete_sharp,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _imageList.isNotEmpty ? Divider() : Container(),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                padding: EdgeInsets.zero,
                itemCount: _imageList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  RegistroSitioImagenes siti = _imageList[index];
                  return SizedBox(
                    width: media.width * .3,
                    height: media.width * .3,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          top: 0,
                          child: Column(
                            children: [
                              SizedBox(
                                width: media.width * .2,
                                height: media.width * .2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(siti.sitioImagenes),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(siti.sitioDescripcion,
                                  style: GoogleFonts.nunito(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 15,
                                  ))
                            ],
                          ),
                        ),
                        Positioned(
                          right: 25,
                          top: 0,
                          child: InkWell(
                              onTap: () {
                                removeImageAtIndex(index);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 255, 17, 0)),
                                child: const Icon(
                                  Icons.delete_sharp,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              )),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {
                  if (_imageList.isNotEmpty &&
                      comentarioSitio.text.isNotEmpty &&
                      espacioNegociadoSitio.text.isNotEmpty &&
                      propuestaNegociacionSitio.text.isNotEmpty &&
                      (latregistrositio != null && logregistrositio != null) &&
                      _imagensitiovalidacion != null &&
                      _imagensitioPunto != null) {
                    setState(() {
                      loading = true;
                    });
                    List<RegistroSitioImagenes> data = [];
                    data.add(_imagensitioPunto!);
                    data.add(_imagensitiovalidacion!);
                    if (_imagensitioGps != null) {
                      data.add(_imagensitioGps!);
                    }
                    data.addAll(_imageList.map((registro) => registro));
                    RegistroSitios regsitio = RegistroSitios(
                        sitio_espacio_negociado: espacioNegociadoSitio.text,
                        sitio_propuesta_negociacion:
                            propuestaNegociacionSitio.text,
                        usuario: dataUser!.userId,
                        sitioLat: latregistrositio!,
                        sitio_fecha: DateTime.now().toIso8601String(),
                        sitioLon: logregistrositio!,
                        sitio: sitioseleccionado!.ptiCellId,
                        sitioDescripcion: comentarioSitio.text);
                    if (await verificarConexionInternet()) {
                      await enviarDatosRegistroSitio(data, regsitio);
                    } else {
                      await guardarDatoLocalmente(
                          "regsitio", jsonEncode(regsitio.toJson()));
                      await guardarListaLocalmente(data);
                    }
                    setState(() {
                      _registrarsitio = false;
                      registrositio = false;
                      registrositioenviado = true;
                      registroelectrico = true;
                    });
                    await Future.delayed(Duration(seconds: 15));
                    setState(() {
                      loading = false;
                    });
                  } else {
                    CherryToast.error(
                      toastDuration: const Duration(seconds: 5),
                      title: const Text(
                          "Debes subir Foto del sitio, Foto de validacion y al menos una foto de más.",
                          style: TextStyle(color: Colors.black)),
                    ).show(context);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text("Continuar",
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  Widget fourPage() {
    var media = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 25),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: numerodepostes,
              cursorColor: const Color.fromARGB(255, 0, 0, 0),
              style:
                  GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  hintText: "Poste N°",
                  hintStyle: GoogleFonts.nunito(
                      color: const Color.fromARGB(138, 56, 56, 56),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(138, 56, 56, 56))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0)))),
            ),
            const SizedBox(height: 25),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: media.width * .8,
              height: media.width * .12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Lat",
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Container(
                    width: media.width * .5,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(25)),
                    child: Text(
                      " ${_latitudDatosElectricos ?? ''}",
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: media.width * .8,
              height: media.width * .12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Lon",
                    style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Container(
                    width: media.width * .5,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(25)),
                    child: Text(
                      " ${_longitudDatosElectricos ?? ''}",
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                setState(() {
                  loading = true;
                });

                Position position = await _getLocation();
                setState(() {
                  _latitudDatosElectricos = position.latitude;
                  _longitudDatosElectricos = position.longitude;
                  loading = false;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  "Establacer coordenadas",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        Column(
          children: [
            Text("Fotografia",
                style: GoogleFonts.nunito(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            InkWell(
              onTap: () async {
                if (_imageFileDatosElectricos != null) {
                  setState(() {
                    _imageFileDatosElectricos = null;
                    _descripcionDatosElectricos = null;
                  });
                } else {
                  _openCameraDatosElectricos();
                }
              },
              child: Container(
                width: media.width * .5,
                height: media.width * .5,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white)),
                child: _imageFileDatosElectricos != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFileDatosElectricos!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.image,
                              size: 90,
                            ),
                            Text("Tomar Foto",
                                style: GoogleFonts.nunito(
                                    color: const Color(0xFFE80000),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
              ),
            ),
            Text(
                _descripcionDatosElectricos != null
                    ? _descripcionDatosElectricos!
                    : "Descripcion de la foto",
                style: GoogleFonts.nunito(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 15,
                )),
            const SizedBox(
              height: 10,
            ),
            Divider(),
            Text("Transformador existente",
                style: GoogleFonts.nunito(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            InkWell(
              onTap: () async {
                if (_imageFileDatosElectricos2 != null) {
                  setState(() {
                    _imageFileDatosElectricos2 = null;
                  });
                } else {
                  _openCameraDatosElectricos2();
                }
              },
              child: Container(
                width: media.width * .5,
                height: media.width * .5,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white)),
                child: _imageFileDatosElectricos2 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFileDatosElectricos2!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.image,
                              size: 90,
                            ),
                            Text("Tomar Foto",
                                style: GoogleFonts.nunito(
                                    color: const Color(0xFFE80000),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
              ),
            ),
            Text(
                _descripcionDatosElectricos2 != null
                    ? _descripcionDatosElectricos2!
                    : "Descripcion de la foto",
                style: GoogleFonts.nunito(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 15,
                )),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () async {
                if (numerodepostes.text.isNotEmpty &&
                    _imageFileDatosElectricos != null &&
                    _latitudDatosElectricos != null &&
                    _longitudDatosElectricos != null) {
                  setState(() {
                    loading = true;
                  });

                  var electrico = RegistroElectrico(
                      electricoImagen2: _imageFileDatosElectricos2?.path,
                      sitio: sitioseleccionado!.ptiCellId,
                      electricoLat: _latitudDatosElectricos!,
                      electricoLon: _longitudDatosElectricos!,
                      electricoNoPoste: numerodepostes.text,
                      electricoComentario: _descripcionDatosElectricos!,
                      electricoImagen: _imageFileDatosElectricos!.path);
                  if (await verificarConexionInternet()) {
                    await enviarDatosRegistroElectrico(electrico);
                  } else {
                    await guardarDatoLocalmente(
                        "electrico", jsonEncode(electrico.toJson()));
                  }
                  setState(() {
                    _registroelectrico = false;
                    registroelectrico = false;
                  });
                  await Future.delayed(Duration(seconds: 5));
                  setState(() {
                    loading = false;
                  });
                } else {
                  CherryToast.error(
                    toastDuration: const Duration(seconds: 5),
                    title: const Text("Datos incompletos",
                        style: TextStyle(color: Colors.black)),
                    action: const Text("Debes llenar todos los campos",
                        style: TextStyle(color: Colors.black)),
                  ).show(context);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12)),
                child: Text("Continuar",
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    ));
  }

  File? _imageFile;
  File? _imageFileDatosElectricos;
  File? _imageFileDatosElectricos2;
  File? _imageFileRegistrollegada;

  double? latregistrollegad;
  double? logregistrollegad;
  double? latregistrositio;
  double? logregistrositio;

  Future<RegistroSitioImagenes?> _openCameraImagenesSitio() async {
    setState(() {
      loading = true;
    });
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        loading = false;
      });
      // Mostrar un diálogo para que el usuario ingrese una descripción
      String? description = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          String description = '';
          return AlertDialog(
            backgroundColor: Colors.white,
            shadowColor: Colors.white38,
            surfaceTintColor: Colors.white,
            title: const Text(
              "Descripción",
              style: TextStyle(color: Colors.black),
            ),
            content: TextFormField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black))),
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                description = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, description);
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
      if (description != null) {
        var data = RegistroSitioImagenes(
            usuario: dataUser!.user,
            sitio: sitioseleccionado!.ptiCellId,
            sitioDescripcion: description,
            sitioImagenes: pickedFile.path);
        return data;
      }
    }
  }

  Future<void> _openCameraDatosElectricos() async {
    setState(() {
      loading = true;
    });
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFileDatosElectricos = File(pickedFile.path);
      });

      String? description = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          String description = '';
          return AlertDialog(
            backgroundColor: Colors.white,
            shadowColor: Colors.white38,
            surfaceTintColor: Colors.white,
            title: const Text(
              "Descripción",
              style: TextStyle(color: Colors.black),
            ),
            content: TextFormField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black))),
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                description = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, description);
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );

      if (description != null) {
        // Obtener coordenadas de longitud y latitud

        // Asignar valores a las variables
        setState(() {
          _descripcionDatosElectricos = description;

          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _openCameraDatosElectricos2() async {
    setState(() {
      loading = true;
    });
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Mostrar un diálogo para que el usuario ingrese una descripción
      String? description = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          String description = '';
          return AlertDialog(
            backgroundColor: Colors.white,
            shadowColor: Colors.white38,
            surfaceTintColor: Colors.white,
            title: const Text(
              "Descripción",
              style: TextStyle(color: Colors.black),
            ),
            content: TextFormField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black))),
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                description = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, description);
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
      setState(() {
        _imageFileDatosElectricos2 = File(pickedFile.path);
        _descripcionDatosElectricos2 = description;
      });
    }
    setState(() {
      loading = false;
    });
  }

  clear() {
    setState(() {
      email.clear();
      contactonombre.clear();
      contactotel.clear();
      contactoemail.clear();
      contactorelacion.clear();
      _descripcionDatosElectricos2 = null;
      _imagensitioPunto = null;
      _imagensitiovalidacion = null;
      _imagensitioGps = null;
      comentarioSitio.clear();
      existingEnergy = false;
      casado = false;
      direccion.clear();
      direccionPropiedad.clear();
      propuestaNegociacionSitio.clear();
      espacioNegociadoSitio.clear();
      provincia.clear();
      registrositioenviado = false;
      municipio.clear();
      localidad.clear();
      _descripcion = null;
      registropropiedad = false;
      registrolocalidad = false;
      registropropietario = false;
      registrositio = false;
      registroelectrico = false;
      _descripcionDatosElectricos = null;
      _latitudDatosElectricos = null;
      _longitudDatosElectricos = null;
      nombre.clear();
      fechanacimiento.clear();
      fechanacimientodate = '';
      documentoidentidad.clear();
      telefono.clear();
      rol.clear();
      escrituras.clear();
      registrocibil.clear();
      descripcionpropiedad.clear();
      numerodepostes.clear();
      _imageFile = null;
      _imageFileDatosElectricos = null;
      _imageFileDatosElectricos2 = null;
      _imageFileRegistrollegada = null;
      _imagemultifile = null;
      latregistrollegad = null;
      logregistrollegad = null;
      _imageList = [];
      latregistrositio = null;
      logregistrositio = null;
      comentario.clear();
      cantidato = 1;
      _selectedOption = null;
      sitioseleccionado = null;
      idcandidato = null;
      enviadomain = false;
    });
  }

  capturarlatlog() async {
    setState(() {
      loading = true;
    });

    Position pos = await _getLocation();

    setState(() {
      loading = false;
      latregistrollegad = pos.latitude;
      logregistrollegad = pos.longitude;
    });
  }

  Future<void> _cameraRegistrollegada() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFileRegistrollegada = File(pickedFile.path);
      });
    }
  }

  Future<void> _openCamera() async {
    setState(() {
      loading = true;
    });
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Mostrar un diálogo para que el usuario ingrese una descripción
      String? description = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          String description = '';
          return AlertDialog(
            backgroundColor: Colors.white,
            shadowColor: Colors.white38,
            surfaceTintColor: Colors.white,
            title: const Text(
              "Descripción",
              style: TextStyle(color: Colors.black),
            ),
            content: TextFormField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black))),
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                description = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, description);
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );

      if (description != null) {
        // Obtener coordenadas de longitud y latitud

        // Asignar valores a las variables
        setState(() {
          _descripcion = description;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    }
    setState(() {
      loading = false;
    });
  }

  File? _imagemultifile;
  void removeImageAtIndex(int index) {
    if (index >= 0 && index < _imageList.length) {
      setState(() {
        _imageList.removeAt(index);
      });
    } else {}
  }

  List<RegistroSitioImagenes> _imageList = [];
  Future<void> _openmultiCamera() async {
    setState(() {
      loading = true;
    });
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagemultifile = File(pickedFile.path);
      });

      // Mostrar un diálogo para que el usuario ingrese una descripción
      String? description = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          String description = '';
          return AlertDialog(
            backgroundColor: Colors.white,
            shadowColor: Colors.white38,
            surfaceTintColor: Colors.white,
            title: const Text(
              "Descripción",
              style: TextStyle(color: Colors.black),
            ),
            content: TextFormField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black))),
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                description = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, description);
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );

      if (description != null && _imagemultifile != null) {
        // Agregar la información de la imagen (ruta y descripción) a la lista
//{'path': _imagemultifile!.path, 'description': description}
        _imageList.add(RegistroSitioImagenes(
            usuario: dataUser!.user,
            sitio: sitioseleccionado!.ptiCellId,
            sitioDescripcion: description,
            sitioImagenes: _imagemultifile!.path));
        setState(() {
          loading = false;
        });
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<Position> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permiso de ubicación denegado';
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
