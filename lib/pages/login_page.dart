import 'package:flutter/material.dart';
import 'package:sports_ui/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true; // add this in your State class
  Map<String, String> fakedb={
    'username': 'admin',
    'password': 'admin123'
  };

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  void login_button() async{
    String username = usernameController.text;
    String password = passwordController.text;

    if (username == fakedb['username'] && password == fakedb['password']){
      
      
      //Save Token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0dXNlciIsImp0aSI6IjM0Y2IzOGUyLWRlZGItNDQ2OC1hMWNjLTY4NWM1YWIzZjA5ZiIsImV4cCI6MTc1NzU5MzUxNywiaXNzIjoieW91cl9pc3N1ZXIiLCJhdWQiOiJ5b3VyX2F1ZGllbmNlIn0.VFw3OvSyaQKd5yu7BdEpIkLTl_Dk13y294AG5onB_14');
      print("✅ Token saved ");

      // Navigate to HomePage
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }

    
     
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login/SignUp', style: TextStyle(color: Colors.blueAccent),),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 9,
      ),
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          // ✅ Use Column for multiple children
          mainAxisSize: MainAxisSize.min,

          children: [
            // First card (above)
            Card(
              color: Colors.blueAccent,
              margin: EdgeInsets.zero,
              elevation: 9,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                // side: BorderSide( // ✅ border added
                //   color: Colors.black,
                //   width: 1, // thickness
                // ),
              ),
              child: Container(
                width: 360,
                padding: EdgeInsets.all(20),
                child: Text(
                  "Login or Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: 10), // spacing between cards

            // Second card (login form)
            Card(
              margin: EdgeInsets.zero,
              elevation: 9,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                // side: BorderSide( // ✅ border added
                //   color: Colors.black,
                //   width: 1, // thickness
                // ),
              ),
              child: Container(
                width: 360,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                    SizedBox(height: 16), // spacing
                    TextField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText; // toggle password visibility
                              });
                            },
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    ElevatedButton(onPressed: login_button ,
                     child: Text('Login')
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
