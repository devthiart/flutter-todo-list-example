import 'package:flutter/material.dart';
import 'package:project/login.dart';

String registerEmail = '';
String registerPassword = '';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Title(
                title: 'Lista de Tarefas',
                color: Colors.lightBlueAccent,
                child: Text(
                    'Lista de Tarefas',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    )
                ),
              ),
              SizedBox(height: 40),
              Text(
                  'Registre-se',
                  style: TextStyle(fontSize: 20)
              ),
              TextField(
                onChanged: (text) {
                  registerEmail = text;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (text) {
                  registerPassword = text;
                },
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Senha',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (registerEmail != '' && registerPassword != '') {
                    showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          title: Text('Registrado com sucesso!'),
                          content: Text(
                            'Por favor, faça o login.',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                registerEmail = '';
                                registerPassword = '';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                              child: Text('Fechar'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Erro ao Registrar'),
                          content: Text(
                            'Por favor, utilize um email e uma senha válida.',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close alert.
                              },
                              child: Text('Fechar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlueAccent),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 22)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
