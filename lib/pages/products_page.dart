import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sports_ui/pages/productdetails_page.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = [];

  // ✅ POST method
  Future<void> postProduct(String name, String description, double price) async {
    final url = Uri.parse("http://10.0.2.2:8000/products"); // FastAPI endpoint

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": name,              // ✅ match backend
          "description": description,
          "price": price,            // ✅ number, not string
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {}); // ✅ Refresh after adding
        print("✅ Product added: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product added successfully")),
        );
        setState(() {}); // refresh UI
      } else {
        print("❌ Failed to post: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add product")),
        );
      }
    } catch (e) {
      print("⚠️ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  // ✅ Fetch all products
  Future<List<dynamic>> fetchProducts() async {
    print("Fetching Data...");
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/products/"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print("Fetched: $data");
      return data;
    } else {
      print("Error: ${response.statusCode}");
      return [];
    }
  }


  // ✅ DELETE PRODUCT
  Future<void> deleteProduct(int id) async {
  print("Deleting Product");
  final response = await http.delete(
    Uri.parse("http://10.0.2.2:8000/products/$id"),
  );

  if (response.statusCode == 200) {
    print("🗑️ Deleted product $id");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Product deleted")),
    );
    setState(() {}); 
  } else {
    print("❌ Failed to delete: ${response.body}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to delete product")),
    );
  }
  }
//  ✅ UPdATE PRODUCT
  Future<void> updateProduct(int id, String name, String description, double price) async {
    final response = await http.put(
    Uri.parse("http://10.0.2.2:8000/products/$id"),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'title': name,
      'price': price,
      'description': description,
    }),
    );

    if(response.statusCode == 200) {
      setState(() {});  // ✅ Refresh UI after update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product updated")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update product")),
      );
    }

  
  }


  // ✅ Dialog for adding product
  void showProductInputDialog() {
    final TextEditingController nameController = TextEditingController();
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
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
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
              String name = nameController.text.trim();
              String description = descController.text.trim();
              double price = double.tryParse(priceController.text.trim()) ?? 0.0;

              if (name.isNotEmpty && description.isNotEmpty && price > 0) {
                await postProduct(name, description, price);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void showEditDialog(int id, String oldName, String oldDesc, double oldPrice){
    final TextEditingController nameController = TextEditingController(text: oldName);
    final TextEditingController descController = TextEditingController(text: oldDesc);
    final TextEditingController priceController = TextEditingController(text: oldPrice.toString());

    showDialog(
      context : context,
      builder:(context) => AlertDialog(
        title: Text('Update Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'New Name'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'New Description'),  
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'New Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed:  () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: () async{
            await updateProduct(
              id,
              nameController.text.trim(),
              descController.text.trim(),
              double.tryParse(priceController.text.trim()) ?? 0.0,
            );
            Navigator.pop(context);
          }, child: Text("Update"),
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
                  elevation: 4,
                  margin: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(product['title']), // ✅ updated
                    subtitle: Text(
                      "Price: ₹${product['price']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    
                    trailing:Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () => showEditDialog(
                            product['id'],
                            product['title'],
                            product['description'] ?? "",
                            double.tryParse(product['price'].toString()) ?? 0.0,
                          ),
                          ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => deleteProduct(product['id']),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(
                            name: product["title"]!,
                            description: product["description"] ?? "",
                            price: product["price"]!.toString(),
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
