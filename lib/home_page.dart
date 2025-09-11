import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sports_ui/pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/notifications_page.dart';
import 'pages/schedule_page.dart';
import 'pages/exercises_page.dart';
import 'pages/trainingplan_page.dart';
import 'pages/products_page.dart';
import 'pages/weight_page.dart';
import 'pages/sleep_page.dart';
import 'pages/settings_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // String userName = "David Jones"; // ✅ stores user name
  List<Map<String, String>> schedule = []; // ✅ stores schedule events

  Future<String?> get_Token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String,dynamic>> fetchEmployeInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("✅ Token in HomePage: $token");

    final response = await http.get(
      Uri.parse("https://api.repro360.in/api/EmployeeMaster_API/74"),
      headers: {
        'Authorization' : 'Bearer $token',
      },
    );

    if (response.statusCode==200){
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');

    }
  }

  

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> cardData = [
      {
        "title": "Profile",
        "icon": Icons.person,
        "page": ProfilePage(
          // currentName: userName,
          // onSave: (newName) {
          //   setState(() {
          //     userName = newName;
          //   });
          // },
        ),
      },
      {
        "title": "Notifications",
        "icon": Icons.notifications,
        "page": NotificationsPage()
      },
      {
        "title": "Schedule",
        "icon": Icons.event_note,
        // ✅ Pass schedule list & onAdd callback
        "page": SchedulePage(
          schedule: schedule,
          onAdd: (event) {
            setState(() {
              schedule.add(event);
            });
          },
        ),
      },
      {
        "title": "Exercises",
        "icon": Icons.sports_gymnastics,
        "page": ExercisesPage()
      },
      {
        "title": "Training Plan",
        "icon": Icons.list,
        "page": TrainingPlanPage()
      },
      {
        "title": "Products",
        "icon": Icons.hourglass_empty,
        "page": ProductPage()
      },
      {
        "title": "Weight",
        "icon": Icons.fitness_center,
        "page": WeightPage()
      },
      {"title": "Sleep", "icon": Icons.bedtime, "page": SleepPage()},
      {"title": "Settings", "icon": Icons.settings, "page": SettingsPage()},
    ];

    return Scaffold(
      //backgroundColor:   Color.fromARGB(255, 43, 123, 226),
      backgroundColor:   Colors.white60,

      appBar: AppBar(
        title: Text(
          "Home Page",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 16, 120, 255),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
             ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // just close drawer
              },
            ),

            Spacer(), // takes up all available space


            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async{
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                print("✅ Token removed ");
                // ✅ Replace current screen with LoginPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔹 Background Image
          Container(
            height: screenHeight * 0.28,
            width: double.infinity,
            child: Image.asset('assets/images/himg1.jpg', fit: BoxFit.cover),
          ),

          // // 🔹 Profile Info Container
          // Container(
          //   margin: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          //   padding: EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(12),
          //     color: Colors.white,
          //     boxShadow: [
          //       BoxShadow(
          //           color: Colors.black45, blurRadius: 6, offset: Offset(0, 0))
          //     ],
          //   ),
          //   child: Row(
          //     children: [
          //       CircleAvatar(
          //           radius: 40,
          //           backgroundImage: AssetImage('assets/images/profile.jpeg')),
          //       SizedBox(width: 16),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(userName,
          //               style: TextStyle(
          //                   fontSize: 20,
          //                   fontWeight: FontWeight.bold,
          //                   color: Colors.black87)),
          //           SizedBox(height: 4),
          //           Text("Active User",
          //               style: TextStyle(fontSize: 14, color: Colors.black54)),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          // 🔹 Profile Info Container with API
              FutureBuilder<Map<String, dynamic>>(
                  future: fetchEmployeInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        child: Text("Error : ${snapshot.error}", style: TextStyle(color: Colors.red)),
                      );
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;

                      String fullName =
                          "${data['FirstName'] ?? ''} ${data['MiddleName'] ?? ''} ${data['LastName'] ?? ''}".trim();
                      String status = (data['IsActive'] == true) ? "Active" : "Inactive";

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 0))
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: data['ProfileImagePath'] != null
                                  ? NetworkImage(data['ProfileImagePath'])
                                  : AssetImage('assets/images/profile.jpeg') as ImageProvider,
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName.isNotEmpty ? fullName : "Unknown User",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  status,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: status == "Active" ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),

          // 🔹 Grid Menu
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 8, bottom: 8), 
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                padding: EdgeInsets.all(4),
                childAspectRatio: 3 / 3,
                children: List.generate(cardData.length, (index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 400),
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              cardData[index]["page"],
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            final offsetAnimation = Tween<Offset>(
                              begin: Offset(0.2, 1.0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: animation, curve: Curves.easeOutCubic));

                            final fadeAnimation = Tween<double>(
                                    begin: 0.0, end: 1.0)
                                .animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeIn));

                            return FadeTransition(
                              opacity: fadeAnimation,
                              child: SlideTransition(
                                  position: offsetAnimation, child: child),
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45,
                              blurRadius: 6,
                              offset: Offset(0, 0))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cardData[index]["icon"],
                              size: 40, color: Color(0xFF1076FF)),
                          SizedBox(height: 8),
                          Text(cardData[index]["title"],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
