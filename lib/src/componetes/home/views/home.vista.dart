import 'package:animate_do/animate_do.dart';
import 'package:comproacacias/src/componetes/home/controllers/home.controller.dart';
import 'package:comproacacias/src/componetes/publicaciones/views/publicaciones.page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).accentColor;
    return Scaffold(
           body  : GetBuilder<HomeController>(
                   id: 'bottomBar',
                   builder: (state){
                     return IndexedStack(
                            index: state.page,
                            children: <Widget>[
                             Stack(
                             children: <Widget>[
                                   _cortina(),
                                   _logo(),
                                   _search(accentColor)
                             ],
                             ),
                             PublicacionesPage(),
                             Container(),
                             Container(),
                             Container()
                             
                            ],
                     );

                   /*    if(state.page == 1){
                        return PublicacionesPage();
                      }
                      return Stack(
                             children: <Widget>[
                                   _cortina(),
                                   _logo(),
                                   _search(accentColor)
                             ],
                      ); */
                   }
                   ),
           bottomNavigationBar: CurvedNavigationBar(
                                index: 0,
                                height: 65.0,
                                items: <Widget>[
                                        Icon(Icons.home, size: 30,color: Colors.white),
                                        Icon(Icons.message, size: 30,color: Colors.white),
                                        Icon(Icons.list, size: 30,color: Colors.white),
                                        Icon(Icons.star, size: 30,color: Colors.white),
                                        Icon(Icons.more_vert, size: 30,color: Colors.white),
                                ],
                                color: Theme.of(context).primaryColor,
                                buttonBackgroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Colors.transparent,
                                onTap: (index)=>Get.find<HomeController>().selectPage(index),

        ),
           
    );
  }

Widget  _cortina() {
  return  SlideInDown(
          //manualTrigger: true,
          controller   : (controller)=> Get.find<HomeController>().controller = controller,
          delay        : Duration(milliseconds: 100),
          duration     : Duration(milliseconds: 300),
          child        : Image.asset('assets/imagenes/cortina.png')
          );
}

Widget _logo() {
  return  Container(
          margin    : EdgeInsets.only(top:40),
          alignment : Alignment(0.0,-0.8),
          child     : Image.asset(
                     'assets/imagenes/logo.png',
                      width  : 250,
                      height : 250,
          ),
  );
}

Widget _search(Color accentColor) {
  return Container(
         height     : 30,
         alignment  : Alignment(0.0,-0.5),
         child      : Text('Buscar'),
         decoration : BoxDecoration(
                      border: Border.all(
                              color: accentColor,
                              style: BorderStyle.solid,
                              width: 1)
         ),
  );
}

}
