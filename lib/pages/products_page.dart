import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sports_ui/pages/productdetails_page.dart'; // for JSON decoding


class ProductsPage extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details", style: TextStyle(color: Colors.white,)),backgroundColor: Colors.blueAccent,),
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
                    subtitle: Text("Price: ₹${product['price']}",style: TextStyle(fontWeight: FontWeight.bold),),
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

                      // showDialog(
                      //   context: context,
                      //   builder: (context) => AlertDialog(
                      //     title: Text(product['title']),
                      //     content: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Image.network(product['image'],fit: BoxFit.contain,height: 250,),
                      //         SizedBox(height: 8),
                      //         Text(product['description'],maxLines: 2,overflow: TextOverflow.ellipsis,),
                      //         SizedBox(height: 8),
                      //         Text("Category: ${product['category']}"),
                      //         SizedBox(height: 8),
                      //         Text("Price: ₹${product['price']}",style: TextStyle(fontWeight: FontWeight.bold),),
                      //       ],
                      //     ),
                      //     actions: [
                      //       TextButton(
                      //         onPressed: () => Navigator.pop(context),
                      //         child: Text("Close"),
                      //       ),
                      //     ],
                      //   ),
                      // );
                    

                    
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
