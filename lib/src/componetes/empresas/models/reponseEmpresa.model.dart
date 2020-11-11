import 'package:comproacacias/src/componetes/empresas/models/calificacion.model.dart';
import 'package:comproacacias/src/componetes/empresas/models/empresa.model.dart';
import 'package:comproacacias/src/componetes/response/models/response.model.dart';

class ResponseEmpresa extends ResponseModel {
  final int id;
  final bool delete;
  final bool update;
  final int  idProducto;
  final Calificacion calificacion;
  final List<Empresa> empresas;
  ResponseEmpresa(
      {this.id, this.delete, this.update, this.calificacion, this.idProducto,this.empresas});
}
