import 'dart:io';

import 'package:comproacacias/src/componetes/empresas/models/empresa.model.dart';
import 'package:comproacacias/src/componetes/home/controllers/home.controller.dart';
import 'package:comproacacias/src/componetes/publicaciones/controllers/publicaciones.controller.dart';
import 'package:comproacacias/src/componetes/publicaciones/data/publicaciones.repositorio.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/imageFile.model.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/publicacion.model.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/reponse.model.dart';
import 'package:comproacacias/src/componetes/response/models/error.model.dart';
import 'package:comproacacias/src/plugins/compress.image.dart';
import 'package:comproacacias/src/plugins/image_piker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class FormPublicacionesController extends GetxController {
  final PublicacionesRepositorio repositorio;
  final bool updatePublicacion;
  final Publicacion publicacion;
  FormPublicacionesController(
      {this.repositorio, this.updatePublicacion, this.publicacion});

  TextEditingController publicacionController = TextEditingController();
  List<ImageFile> imagenes = [];
  List<String> imagenesUpdate = [];
  ImageCapture imageCapture = ImageCapture();
  List<Empresa> empresas;
  Empresa empresa;
  PublicacionState status = PublicacionState.noAction;

  final formKey = GlobalKey<FormState>();
  final uid = Uuid();

  @override
  void onInit() {
    if(updatePublicacion){
       publicacionController.text = publicacion.texto;
       imagenesUpdate = publicacion.imagenes;
       empresa = publicacion.empresa;
    }
    this.empresas = Get.find<HomeController>().usuario.empresas;
    super.onInit();
  }

  void getImage(String tipo, [bool cambiar = false, int index]) async {
    final imagecapture = await imageCapture.getImage(tipo);
    if (!imagecapture.isNullOrBlank) {
      final image = await CompressImagePlugin.getImage(imagecapture);
      if (cambiar)
        this._updateImage(image, index);
      else
        this._addImage(image);
    }
    if (imagecapture.isNullOrBlank) {
      status = PublicacionState.notImage;
      Get.back();
    }
    Get.back();
    update(['formulario_publicaciones']);
  }

  void selectEmpresa(Empresa empresa) {
    Get.back();
    if (empresa.estado) {
      this.empresa = empresa;
      update(['formulario_publicaciones']);
    } else {
      status = PublicacionState.notAuthEmpresa;
      update(['formulario_publicaciones']);
    }
  }

  void addPublicacion() async {
    final response =
        await repositorio.addPublicacion(this._getPublicacion(), imagenes);
    if (response is ResponsePublicacion) this._addPublicacionList(response.id);
    if (response is ErrorResponse) print(response.getError);
  }

  void _addImage(File image) {
    imagenes.add(ImageFile(file: image, nombre: '${uid.v4()}.jpg'));
  }

  Publicacion _getPublicacion([int id]) {
    return Publicacion(
        id: id ?? null,
        texto: publicacionController.text,
        empresa: empresa,
        fecha: DateTime.now().toString(),
        numeroComentarios: 0,
        likes: 0,
        usuariosLike: [],
        imagenes: imagenes.map<String>((imagen) => imagen.nombre).toList(),
        megusta: false,
        editar: true);
  }

  void _updateImage(File image, int index) {
    if(!updatePublicacion)
    this.imagenes[index] = this.imagenes[index].copyWith(file: image);
  }

  void _addPublicacionList(int id) {
    Get.find<PublicacionesController>()
        .addPublicacion(this._getPublicacion(id));
    Get.back();
  }
}

enum PublicacionState { notImage, notAuthEmpresa, errorForm, noAction }
