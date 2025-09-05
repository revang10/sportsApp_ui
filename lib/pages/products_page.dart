import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sports_ui/pages/productdetails_page.dart'; // for JSON decoding

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = [];

  Future<void> postProduct(
    String title,
    String description,
    double price,
  ) async {
    final url = Uri.parse(
      "https://fakestoreapi.com/products",
    ); // replace with your API endpoint
    final body = {
      "title": title,
      "description": description,
      "price": price.toString(),
    };

    try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Product added: ${response.body}");

      // ⬇️ Trigger rebuild + fetch again
      setState(() {});
    } else {
      print("❌ Failed to post: ${response.body}");
    }
  } catch (e) {
    print("⚠️ Error: $e");
  }
  }

  Future<List<dynamic>> fetchProducts() async {
    print("Fetching Data...");
    final response = await http.get(
      Uri.parse("https://fakestoreapi.com/products"),
    );
    // return jsonDecode(response.body);
    if (response.statusCode == 200) {
      print("Data fetched successfully");
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data");
    }
  }

  //Function to show the dialog for adding a new product
  void showProductInputDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Add Product"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 2,
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Price",
                  prefixText: "₹ ",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String title = titleController.text.trim();
              String desc = descController.text.trim();
              double price =
                  double.tryParse(priceController.text.trim()) ?? 0.0;

              if (title.isNotEmpty && desc.isNotEmpty && price > 0) {
                await postProduct(title, desc, price);
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 4, // shadow
                  margin: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(product['title']),
                    subtitle: Text(
                      "Price: ₹${product['price']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: Image.network(
                      product['image'],
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(
                            image: product["image"]!,
                            name: product["title"]!,
                            description: product["description"]!,
                            price: product["price"]!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showProductInputDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
