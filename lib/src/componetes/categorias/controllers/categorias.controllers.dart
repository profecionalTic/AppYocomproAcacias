import 'package:comproacacias/src/componetes/categorias/data/categorias.repositorio.dart';
import 'package:comproacacias/src/componetes/categorias/models/categoria.model.dart';
import 'package:comproacacias/src/componetes/empresas/models/empresa.model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriasController extends GetxController {
  final CategoriaRepositorio repositorio;

  CategoriasController({this.repositorio});
  String categoria = '';
  List<Empresa> empresas = [];
  List<Categoria> categorias = [];
  ScrollController controllerListEmpresas;
  int _pagina = 0;

  @override
  void onInit() {
    super.onInit();
   
    this.getCategorias();
  }

  void _animationFinalController() {
  if(controllerListEmpresas.position.pixels != 0)
    controllerListEmpresas.animateTo(
        controllerListEmpresas.position.pixels + 100,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn);
  }

  void getEmpresasByCategoria(String categoria) async {
    _pagina++;
    final empresasList =
        await repositorio.getEmpresasByCategoria(categoria, _pagina);
    if (empresasList.length > 0) {
      empresas.addAll(empresasList);
      if (_pagina > 1) this._animationFinalController();
      update(['categorias']);
    }
  }
  void getEmpresasByCategoriaInitial(String categoria) async {
    this._resetScroll();
    this.empresas = [];
    this.categoria = categoria;
    final empresasList =
        await repositorio.getEmpresasByCategoria(categoria, 0);
    if (empresasList.length > 0) {
      empresas.addAll(empresasList);
      if (_pagina > 1) this._animationFinalController();
      update(['categorias']);
    }
  }

 
  getCategorias() async {
    this.categorias = await this.repositorio.getCategorias();
    update();
  }

  void _resetScroll(){
    this.controllerListEmpresas?.dispose();
    this.controllerListEmpresas = ScrollController(initialScrollOffset: 0);
    this.controllerListEmpresas.addListener(() {
      if (controllerListEmpresas.position.pixels == 
         controllerListEmpresas.position.maxScrollExtent && controllerListEmpresas.position.pixels != 0 )
        this.getEmpresasByCategoria(this.categoria);
    });
  }


}
