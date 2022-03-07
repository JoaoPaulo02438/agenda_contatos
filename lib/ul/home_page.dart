// @dart=2.9
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ul/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  // ignore: deprecated_member_use
  List<Contact> contacts = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de A-Z"),
                  value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOptions.orderza,
                ),
              ],
            onSelected: _orderList,
          ),
        ],
      ),
      //Botão inserir novo contato
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (contect, index){
            return _contactCard(context, index);
      }
    ),
      );
  }
  Widget _contactCard (BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null ?
                      FileImage(File(contacts[index].img)) :
                      AssetImage("images/person.png"),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(contacts[index].name ?? "",
                  style: TextStyle(fontSize: 22.0,
                  fontWeight: FontWeight.bold),
                    ),
                  Text(contacts[index].email ?? "",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(contacts[index].phone ?? "",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),)
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: () {  },
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        child: Text("LIGAR",
                          style: TextStyle(
                              color: Colors.red, fontSize: 20.0
                          ),
                        ),
                        //Função para ligar para contato
                        onPressed: (){
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context); //fechar janela
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        child: Text("EDITAR",
                          style: TextStyle(
                              color: Colors.red, fontSize: 20.0
                          ),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        child: Text("EXCLUIR",
                          style: TextStyle(
                              color: Colors.red, fontSize: 20.0
                          ),
                        ),
                        onPressed: (){
                          helper.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    )
                  ],
                ),
              );
            },


          );
    }
    );
  }

  void _showContactPage({Contact contact}) async{
    final recContact = await Navigator.push(context,
    MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );
    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);
        _getAllContacts();
      }else{
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }

  }
  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result){
      switch(result){
        case OrderOptions.orderaz:

          contacts.sort((a, b){
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          break;
        case OrderOptions.orderza:

          contacts.sort((a, b){
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          });
          break;
      }
      setState(() {

      });
  }
}
