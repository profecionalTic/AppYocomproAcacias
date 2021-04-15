import 'dart:convert';
import 'package:comproacacias/src/componetes/publicaciones/models/imageFile.model.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/publicacion.model.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/reponse.model.dart';
import 'package:comproacacias/src/componetes/response/models/error.model.dart';
import 'package:comproacacias/src/componetes/response/models/response.model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class PublicacionesRepositorio {
  Dio _dio = Get.find<Dio>();

  Future<List<Publicacion>> getPublicaciones(int page, int id) async {
    try {
      final response = await _dio
          .get('/publicaciones', queryParameters: {'page': page, 'id': id});
      return response.data
          .map<Publicacion>((publicacion) => Publicacion.toJson(publicacion))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future meGustaPublicacion(int idPublicacion, int idUsuario) async {
    final data =
        jsonEncode({'id_usuario': idUsuario, 'id_publicacion': idPublicacion});
    final response = await _dio.post('/likes/add', data: data);
    return response.data;
  }

  Future noMeGustaPublicacion(int idPublicacion, int idUsuario) async {
    final data =
        jsonEncode({'id_usuario': idUsuario, 'id_publicacion': idPublicacion});
    final response = await _dio.delete('/likes/delete', data: data);
    return response.data;
  }

  Future comentarPublicacion(
      String comentario, int idPublicacion, int idUsuario) async {
    final data = jsonEncode({
      'comentario': comentario,
      'id_publicacion': idPublicacion,
      'id_usuario': idUsuario
    });
    try {
      final response = await _dio.post('/comentarios/add', data: data);
      return response.data;
    } on DioError catch (error) {
      return error.response.data;
    }
  }

  Future<List<Publicacion>> getPublicacionesByEmpresa(
      int idEmpresa, int idUsuario) async {
    await new Future.delayed(new Duration(milliseconds: 500));
    final response = await _dio.get('/publicaciones/empresa/$idEmpresa',
        queryParameters: {'id': idUsuario});
    final publicaciones = response.data;
    return publicaciones
        .map<Publicacion>((e) => Publicacion.toJson(e))
        .toList();
  }

  Future<ResponseModel> addPublicacion(
      Publicacion publicacion, List<ImageFile> imagenes) async {
    FormData data = FormData.fromMap({...publicacion.toMap()});
    await Future.delayed(Duration(seconds: 6));
    imagenes.forEach((imagen) async {
      data.files.add(MapEntry(
        imagen.nombre,
        MultipartFile.fromFileSync(imagen.file.path, filename: imagen.nombre),
      ));
    });

    try {
      final response = await _dio.post('/publicaciones/add', data: data);
      return ResponsePublicacion(id: response.data);
    } on DioError catch (error) {
      return ErrorResponse(error);
    }
  }
}
