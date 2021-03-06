import 'package:comproacacias/src/componetes/home/controllers/home.controller.dart';
import 'package:comproacacias/src/componetes/home/models/loginEnum.model.dart';
import 'package:comproacacias/src/componetes/publicaciones/data/publicaciones.repositorio.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/cometario.model.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/like.model.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/publicacion.model.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/reponse.model.dart';
import 'package:comproacacias/src/componetes/response/models/error.model.dart';
import 'package:comproacacias/src/componetes/usuario/models/usuario.model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PublicacionesController extends GetxController {
  final PublicacionesRepositorio repositorio;

  PublicacionesController({this.repositorio});

  HomeController homeController = Get.find<HomeController>();
  List<Publicacion> publicaciones = [];
  List<Publicacion> publicacionesByempresa = [];
  ScrollController controller;
  int _pagina = 0;
  TextEditingController comentarioController = TextEditingController();
  bool loading = false, deleteDialogo = false;

  final box = GetStorage();
  int idUsuario;
  bool anonimo = false;
  @override
  void onInit() async {
    if (homeController.anonimo == EnumLogin.notLogin) {
      await homeController.getTokenAnonimo();
      this.anonimo = true;
    }
    if (homeController.anonimo == EnumLogin.anonimo) {
      this.anonimo = true;
    }
    idUsuario = box.read('id') ?? 1;
    controller = ScrollController(initialScrollOffset: 0);
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent)
        this.getPublicaciones();
    });
    this.getPublicaciones();
    super.onInit();
  }

  @override
  void onClose() {
    if (controller.hasClients || controller.hasClients == null)
      controller?.dispose();
    super.onClose();
  }

  Future dispose() async {
    if (controller.hasClients || controller.hasClients == null)
      controller?.dispose();
  }

  void getPublicaciones() async {
    publicaciones
        .addAll(await repositorio.getPublicaciones(_pagina, idUsuario));
    if (_pagina > 1) this._animationFinalController();
    _pagina++;
    update(['publicaciones']);
  }

  void getNewPublicaciones() async {
    publicaciones = await repositorio.getPublicaciones(0, idUsuario);
    update(['publicaciones']);
  }

  void _animationFinalController() {
    controller.animateTo(controller.position.pixels + 100,
        duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
  }

  void getPublicacionesByempresa(int id) async {
    this.loading = true;
    this.publicacionesByempresa =
        await repositorio.getPublicacionesByEmpresa(id, idUsuario);
    this.loading = false;
    update(['empresa']);
  }

  void megustaAction(int idPublicacion, int index, int idUsuarioEmpresa) async {
    final usuario = Get.find<HomeController>().usuario;
    await repositorio.meGustaPublicacion(idPublicacion, idUsuario,idUsuarioEmpresa);
    this._addusuarioLike(usuario, index);
    update(['publicaciones']);
  }

  void noMegustaAction(int idPublicacion, int index) async {
    await repositorio.noMeGustaPublicacion(idPublicacion, idUsuario);
    this._removeUsuarioLike(index);
    update(['publicaciones']);
  }

  void comentarPublicacion(int idPublicacion, int index, int idUsuarioEmpresa) async {
    final usuario = Get.find<HomeController>().usuario;
    if (comentarioController.text.isNotEmpty) {
      await repositorio.comentarPublicacion(
          comentarioController.text, idPublicacion, idUsuario,idUsuarioEmpresa);
      this._addComentario(usuario, index);
      comentarioController?.clear();
      update(['comentarios', 'publicaciones']);
    }
  }

 Future<void> updateIdUsuario() async {
   this.idUsuario = await box.read('id');
   this.getNewPublicaciones();
   update(['publicaciones']);
 }
  void _addComentario(Usuario usuario, int index) {
    final comentarios = publicaciones[index].numeroComentarios;
    final comentario = Comentario(
        comentario: comentarioController.text,
        fecha: DateTime.now().toString(),
        usuario: Usuario(
            nombre: usuario.nombre, imagen: usuario.imagen, id: usuario.id));
    publicaciones[index].comentarios.insert(0, comentario);
    publicaciones[index] =
        publicaciones[index].copyWith(numeroComentarios: (comentarios + 1));
  }

  void _addusuarioLike(Usuario usuario, int index) {
    final likes = publicaciones[index].likes;
    publicaciones[index] =
        publicaciones[index].copyWith(megusta: true, likes: (likes + 1));
    publicaciones[index].usuariosLike.add(LikePublicacion(
        fecha: DateTime.now().toString(),
        usuario: Usuario(
            id: usuario.id, imagen: usuario.imagen, nombre: usuario.nombre)));
  }

  void _removeUsuarioLike(int index) {
    final likes = publicaciones[index].likes;
    publicaciones[index] =
        publicaciones[index].copyWith(megusta: false, likes: (likes - 1));
    publicaciones[index].usuariosLike.removeAt(publicaciones[index]
        .usuariosLike
        .indexWhere((like) => like.usuario.id == idUsuario));
  }

  void addPublicacion(Publicacion publicacion) {
    this.publicaciones.insert(0, publicacion);
    update(['publicaciones']);
  }
  void updatePublicacion(Publicacion publicacion, int index) {
    this.publicaciones[index] = this.publicaciones[index].copyWith(texto: publicacion.texto,imagenes: publicacion.imagenes);
    Get.back();
    update(['publicaciones']);
  }

  void deletePublicacion(int index, int idPublicacion) async {
   final response = await this.repositorio.deletePublicacion(idPublicacion);
   this.deleteDialogo = true;
   update(['delete_dialogo']);
   if(response is ResponsePublicacion && response.delete) {
    this.publicaciones.removeAt(index);
    this.deleteDialogo = false;
    Get.back();
    update(['publicaciones','delete_publicacion']);
  }
  if(response is ErrorResponse)print(response.error);
}
}