import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  /// Helper: Capitalize first letter, rest lowercase
  String formatText(String? input) {
    if (input == null || input.isEmpty) return "N/A";
    input = input.trim().toLowerCase();
    return input[0].toUpperCase() + input.substring(1);
  }

  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      print("⚠️ Date parsing failed for: $dateString, error: $e");
      return dateString; // fallback if parsing fails
    }
  }

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController employeeIDController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? selectedLeave;
  String? selectedStartDayType;

  List<dynamic> leaveRequests = [];
  bool isLoading = true;

  //StartDayType
  final Map<String, int> startdaytypeMap = {"Full Day": 1, "Half Day": 2};

  final Map<int, String> startdaytypeName = {1: "Full Day", 2: "Half Day"};

  //LeaveType
  final Map<String, int> leavetypeMap = {
    "Sick Leave": 0,
    "Casual Leave": 1,
    "Paid Leave": 2,
  };

  final Map<int, String> leaveTypeName = {
    0: "Sick Leave",
    1: "Casual Leave",
    2: "Paid Leave",
  };

  @override
  void initState() {
    super.initState();
    print("🚀 LeavePage initialized");
    fetchLeaveRequests();
  }

  /// Fetch all leave requests
  Future<void> fetchLeaveRequests() async {
    print("📡 Fetching leave requests...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("🔑 Token: $token");

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("https://api.repro360.in/api/LeaveRequest"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📥 GET Response Status: ${response.statusCode}");
      print("📥 GET Response Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          leaveRequests = jsonDecode(response.body);
          leaveRequests = leaveRequests.reversed.toList(); // Show latest first
          isLoading = false;
        });
        print("✅ Leave requests loaded: ${leaveRequests.length}");
      } else {
        setState(() => isLoading = false);
        print("❌ Failed to fetch leave requests: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to load leave requests")),
        );
      }
    } catch (e) {
      print("🔥 Exception in fetchLeaveRequests: $e");
      setState(() => isLoading = false);
    }
  }

  /// Submit leave request
  Future<void> submitLeaveRequest(BuildContext dialogContext) async {
    print("📡 Submitting leave request...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("✅ Token in SharedPreferences: $token");

    final empId = int.tryParse(employeeIDController.text) ?? 0;

    final body = {
      "EmployeeId": empId,
      "LeaveTypeId": leavetypeMap[selectedLeave] ?? 0,
      "StartDate": startDate?.toUtc().toIso8601String(),
      "EndDate": endDate?.toUtc().toIso8601String(),
      "StartDateType":
          startdaytypeMap[selectedStartDayType], //to change flaggggg
      "EndDateType": 0,
      "Reason": reasonController.text,
      "CreatedDate": DateTime.now().toUtc().toIso8601String(),
      "CreatedBy": empId,
      "ModifiedDate": DateTime.now().toUtc().toIso8601String(),
      "ModifiedBy": empId,
      "IsDeleted": false,
      "DeletedDate": null,
      "DeletedBy": null,
    };

    print("📤 Sending Payload: $body");

    try {
      final response = await http.post(
        Uri.parse("https://api.repro360.in/api/LeaveRequest/AddNew"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("📥 POST Response Status: ${response.statusCode}");
      print("📥 POST Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Leave request submitted successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Leave request submitted successfully"),
          ),
        );
        Navigator.pop(dialogContext);
        fetchLeaveRequests(); // 🔄 Refresh list after submit
      } else {
        print("❌ Leave request failed: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: ${response.body}")));
      }
    } catch (e) {
      print("🔥 Exception while submitting leave request: $e");
    }
  }

  //Card Detail Dialog
  void openDetailDialog(Map<String, dynamic> req) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: EdgeInsets.zero, // Remove default padding
          title: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1076FF), // Blue background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  "Leave Request Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.98, // 90% of screen width
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reason
                    Row(
                      children: [
                        const Icon(Icons.notes, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatText(req['Reason']),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Type
                    Row(
                      children: [
                        const Icon(Icons.category, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatText(leaveTypeName[req['LeaveTypeId']]),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // From Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "From: ${formatDate(req['StartDate'])}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // To Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "To: ${formatDate(req['EndDate'])}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // actions: [
          //   TextButton(
          //     onPressed: () => Navigator.pop(context),
          //     child: const Text(
          //       "Close",
          //       style: TextStyle(
          //         color: Color(0xFF1076FF),
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ],
        );
      },
    );
  }

  //  Leave Request Dialog
  void openDialog() {
    print("📂 Opening leave request dialog...");
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Leave Request"),
          content: SizedBox(
            width: 900, // 👈 custom width
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Employee ID
                  TextField(
                    controller: employeeIDController,
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      hintText: 'Enter Employee ID',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        print("✏️ Employee ID entered: $value"),
                  ),
                  const SizedBox(height: 12),

                  // Leave Tenure Type Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      prefix: Icon(Icons.timelapse),
                      labelText: "Leave Tenure Type",
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    initialValue: selectedStartDayType,
                    items: ["Full Day", "Half Day"]
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStartDayType = value!;
                      });
                      print("✅ Leave Tenure: $selectedStartDayType");
                    },
                  ),
                  const SizedBox(height: 12),

                  // Start Date
                  TextField(
                    controller: startDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      hintText: 'Select Date',
                      prefixIcon: Icon(Icons.date_range),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      print("📅 Start date picker opened");
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2050),
                        initialDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          startDate = pickedDate;
                          startDateController.text =
                              "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                        });
                        print("✅ Start date selected: $startDate");
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // End Date
                  TextField(
                    controller: endDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      hintText: 'Select Date',
                      prefixIcon: Icon(Icons.date_range),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      print("📅 End date picker opened");
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2050),
                        initialDate: startDate ?? DateTime.now(),
                      );
                      if (pickedDate != null) {
                        if (startDate != null &&
                            pickedDate.isBefore(startDate!)) {
                          print("⚠️ End date is before start date");
                          endDateController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "⚠️ End date must be after Start date",
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            endDate = pickedDate;
                            endDateController.text =
                                "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                          });
                          print("✅ End date selected: $endDate");
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Reason
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      hintText: 'Enter Reason',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => print("✏️ Reason entered: $value"),
                  ),
                  const SizedBox(height: 12),

                  // Leave Type Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Leave Type",
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    value: selectedLeave,
                    items: ["Sick Leave", "Casual Leave", "Paid Leave"]
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLeave = value!;
                      });
                      print("✅ Leave type selected: $selectedLeave");
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("❌ Cancel clicked");
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                print("📤 Submit clicked");
                if (startDate == null ||
                    endDate == null ||
                    reasonController.text.isEmpty ||
                    selectedLeave == null ||
                    employeeIDController.text.isEmpty) {
                  print("⚠️ Validation failed: Missing fields");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Please fill all fields")),
                  );
                } else {
                  submitLeaveRequest(dialogContext);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("🔄 Building LeavePage UI");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Request Page"),
        backgroundColor: const Color(0xFF1076FF),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaveRequests.isEmpty
          ? const Center(child: Text("No Leave Requests"))
          : ListView.builder(
              itemCount: leaveRequests.length,
              itemBuilder: (context, index) {
                final req = leaveRequests[index];
                print("📝 Rendering leave request");
                return InkWell(
                  onTap: () {
                    openDetailDialog(req); // 👈 opens dialog with details
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reason
                          Text(
                            "Reason: ${formatText(req['Reason'])}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Type
                          Row(
                            children: [
                              const Icon(
                                Icons.category,
                                size: 18,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Type: ${formatText(leaveTypeName[req['LeaveTypeId']])}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // From Date
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "From: ${formatDate(req['StartDate'])}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // To Date
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "To: ${formatDate(req['EndDate'])}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("➕ FloatingActionButton clicked");
          openDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF1076FF),
      ),
    );
  }
}
