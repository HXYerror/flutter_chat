import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awesome_help/utils/https.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:form_field_validator/form_field_validator.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Map userData = {};
  final _formkey = GlobalKey<FormState>();
  String? _name = '';
  String? _pw = '';
  String showMessage = '';
  // // 密码显示、隐藏
  bool _isObscure = true;
  final _controllerName = TextEditingController();
  final _controllerPwd = TextEditingController();

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Image(image: AssetImage('assets/logo.png')),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                  // validator: MultiValidator([
                                  //   RequiredValidator(
                                  //       errorText: 'Enter email address'),
                                  //   EmailValidator(
                                  //       errorText:
                                  //           'Please correct email filled'),
                                  // ]),
                                  onSaved: (val) => this._name = val,
                                  controller: _controllerName,
                                  decoration: const InputDecoration(
                                      hintText: 'UserName',
                                      labelText: 'UserName',
                                      prefixIcon: Icon(
                                        Icons.email,
                                        //color: Colors.green,
                                      ),
                                      errorStyle: TextStyle(fontSize: 18.0),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9.0)))))),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              // validator: MultiValidator([
                              //   RequiredValidator(
                              //       errorText: 'Please enter Password'),
                              //   MinLengthValidator(8,
                              //       errorText:
                              //           'Password must be atlist 8 digit'),
                              //   PatternValidator(r'(?=.*?[#!@$%^&*-])',
                              //       errorText:
                              //           'Password must be atlist one special character')
                              // ]),
                              onSaved: (val) => this._pw = val,
                              controller: _controllerPwd,
                              obscureText: _isObscure,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.key,
                                  color: Colors.green,
                                ),
                                errorStyle: TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9.0))),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: SizedBox(
                              child: ElevatedButton(
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                                onPressed: () {
                                  _getToken();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                            ),
                          ),
                        ]),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _getToken() async {
    _name = _controllerName.text;
    _pw = _controllerPwd.text;
    print(_name.toString() + _pw.toString());
    GetHttpResponse().getTokenResponse(_name.toString(), _pw.toString(),
        (String msg) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('user_token');
      showMessage = msg;
      _showMyToast();
    }, (String token) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final setTokenResult = await prefs.setString('user_token', token);
      await prefs.setString('name', _name.toString());
      showMessage = "success";
      _showMyToast();
      Navigator.pushNamed(context, '/');
    });
  }

  _showMyToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.indigoAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(this.showMessage),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
