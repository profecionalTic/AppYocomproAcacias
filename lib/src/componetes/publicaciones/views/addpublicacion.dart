import 'package:cached_network_image/cached_network_image.dart';
import 'package:comproacacias/src/componetes/home/controllers/home.controller.dart';
import 'package:comproacacias/src/componetes/publicaciones/controllers/formPublicacion.controller.dart';
import 'package:comproacacias/src/componetes/publicaciones/data/publicaciones.repositorio.dart';
import 'package:comproacacias/src/componetes/publicaciones/models/publicacion.model.dart';
import 'package:comproacacias/src/componetes/widgets/InputForm.widget.dart';
import 'package:comproacacias/src/componetes/widgets/dialogAlert.widget.dart';
import 'package:comproacacias/src/componetes/widgets/dialogImage.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class FormPublicacionPage extends StatelessWidget {
  final bool update;
  final Publicacion publicacion;
  final int index;
  FormPublicacionPage({Key key,this.update = false,this.publicacion,this.index}) : super(key: key);
  final String urlImagenLogo = Get.find<HomeController>().urlImagenes;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
           child: GetBuilder<FormPublicacionesController>(
                  id: 'formulario_publicaciones',
                  init: FormPublicacionesController(repositorio: PublicacionesRepositorio(),publicacion: publicacion,updatePublicacion: update),
                  builder: (state) {
                    return Scaffold(
                               appBar: AppBar(
                                       title     : Text('Agrega tu Publicación'),
                                       elevation : 0,
                               ),
                               body  : SingleChildScrollView(
                                       padding : EdgeInsets.all(20),
                                       child   : Form(
                                                 key   : state.formKey,
                                                 child : Column(
                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                         children: [
                                                              InputForm(
                                                              placeholder : 'Escribe Tu publicación',
                                                              controller  : state.publicacionController,
                                                              textarea    : true,
                                                              requerido   : true, 
                                                              ),
                                                              _escogerEmpresa(state),
                                                              SizedBox(height: 10),
                                                              Text('Imagenes (máximo 5)'),
                                                              SizedBox(height: 10),
                                                              _imagenes(state)
                                                         ]
                                                 )
                                       ),
                               ),
                               floatingActionButton: FloatingActionButton.extended(
                                                     heroTag         : 'publicar',
                                                     backgroundColor : Get.theme.primaryColor,
                                                     icon            : Icon(Icons.add,color: Colors.white),
                                                     label           : Text('${update ? 'Actualizar' : 'Publicar'}',style:TextStyle(color: Colors.white)),
                                                     onPressed       : (){
                                                       if(state.formKey.currentState.validate() && 
                                                          (state.imagenes.length > 0 || state.imagenesUpdate.length > 0) && 
                                                          state.empresa.id > 0){
                                                          this._loadingDialog();
                                                          if(!update)
                                                          state.addPublicacion();
                                                          if(update)
                                                          state.updatePublicaciones(index);
                                                       }
                                                       else Get.snackbar('Error', 'Faltan datos o imagenes');
                                                     }
                                                     ),
                            );
                  }
                  ),
           onTap: ()=>FocusScope.of(context).unfocus(),
    );
  }

Widget _escogerEmpresa(FormPublicacionesController state) {
  return ListTile(
         leading : Icon(Icons.business),
         // ignore: can_be_null_after_null_aware
         title   : Text('${state.empresa?.nombre.isNull ? 'Selecione una empresa' : state.empresa.nombre}'),
         onTap   : update  ? null : ()=>_dialogEmpresas(state),
  );
}

  _dialogEmpresas(FormPublicacionesController state) {
    Get.bottomSheet(
    Container(
    height : Get.height * 0.5,
    color  : Colors.white,
    child  : _empresas(state),  
    )
    ).whenComplete((){
      if(state.status == PublicacionState.notAuthEmpresa)
      Get.snackbar('Error', 'Empresa No autorizada para publicar');
    });
  }

Widget _empresas(FormPublicacionesController state) {
  if(state.empresas.length == 0)
     return Center(child: Text('No hay empresas registradas'));
  return ListView.builder(
         itemCount  : state.empresas.length,
         itemBuilder: (_,i){
            return ListTile(
                   title    : Text(state.empresas[i].nombre),
                   subtitle : Text(state.empresas[i].nit),
                   leading  : CircleAvatar(
                              backgroundImage: state.empresas[i].urlLogo == ''
                                               ?
                                               AssetImage('assets/imagenes/no_logo_img.png')
                                               :
                                               NetworkImage('$urlImagenLogo/logo/${state.empresas[i].urlLogo}')
                   ),
                   onTap    : ()=>state.selectEmpresa(state.empresas[i])
            );
         }
  );
}

Widget _imagenes(FormPublicacionesController state) {
  return Wrap(
         spacing: 2,
         runSpacing: 2,
         children: [
             if(state.imagenes.length < 5 && state.imagenesUpdate.length < 5)
               GestureDetector(
               child: Container(
                      height : 100,
                      width  : Get.width *0.29,
                      color  : Colors.grey[350],
                      child  : Center(child:Icon(Icons.add,color: Colors.white)),
               ),
               onTap: ()=>DialogImagePicker.openDialog(
                          titulo       : 'Selecione una Imagen',
                          onTapArchivo : ()=>state.getImage('archivo'),
                          onTapCamera  : ()=>state.getImage('camara'),
                          complete     : (){
                                          if(state.status == PublicacionState.notImage)
                                          Get.snackbar('Error', 'No seleciono una imagen');  
                          }
               ),
               ),
              if(!update)
              ...state.imagenes.asMap()
                               .entries
                               .map((imagen) => GestureDetector(
                                                child: FadeInImage(
                                                       height : 100,
                                                       width  : Get.width *0.29,
                                                       fit    : BoxFit.cover,
                                                       placeholder: AssetImage('assets/imagenes/load_image.gif'), 
                                                       image: FileImage(imagen.value.file),
                                                ),
                                                onTap: ()=>DialogImagePicker.openDialog(
                                                           titulo       : 'Cambia la Imagen',
                                                           onTapArchivo : ()=>state.getImage('archivo',true,imagen.key),
                                                           onTapCamera  : ()=>state.getImage('camara',true,imagen.key),
                                                           complete     : (){
                                                                          if(state.status == PublicacionState.notImage)
                                                                          Get.snackbar('Error', 'No seleciono una imagen');  
                                                           }
                                                ),
                               )
               
              ),
              if(update)
              ...state.imagenesUpdate.asMap()
                                     .entries
                                     .map((imagen) => GestureDetector(
                                                      child: FadeInImage(
                                                             height      : 100,
                                                             width       : Get.width *0.29,
                                                             fit         : BoxFit.cover,
                                                             placeholder : AssetImage('assets/imagenes/load_image.gif'), 
                                                             image       : imagen.value.isaFile
                                                                           ? FileImage(imagen.value.file)
                                                                           : CachedNetworkImageProvider('$urlImagenLogo/galeria/${imagen.value.nombre}')
                                                      ),
                                                      onTap: ()=>DialogImagePicker.openDialog(
                                                                 titulo       : 'Cambia la Imagen',
                                                                 onTapArchivo : ()=>state.getImage('archivo',true,imagen.key),
                                                                 onTapCamera  : ()=>state.getImage('camara',true,imagen.key),
                                                                 complete     : (){
                                                                                if(state.status == PublicacionState.notImage)
                                                                                Get.snackbar('Error', 'No seleciono una imagen');  
                                                                 }
                                                      ),
                                      )
                                     
                                     )
         ]
  );
}
_loadingDialog(){
   Get.dialog(
      AlertDialogLoading(titulo: 'Publicando...'),
      barrierDismissible: false
    ).whenComplete(() => Get.back());
}
}