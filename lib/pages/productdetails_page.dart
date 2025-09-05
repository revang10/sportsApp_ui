import 'package:flutter/material.dart';

class ProductDetailsPage extends StatefulWidget {
  // final String image;
  final String name;
  final String description;
  final dynamic price;

  const ProductDetailsPage({
    Key? key,
    // required this.image,
    required this.name,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              // child: Image.network(
              //   widget.image,
              //   height: 200,
              //   fit: BoxFit.contain,
              // ),
            ),
            SizedBox(height: 16),

            Text(
              widget.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Price: ${widget.price}",
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${widget.name} added to cart!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Description:", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(
              widget.description,
              maxLines: 10,
              style: const TextStyle(fontSize: 18),
            ),
            // const Spacer(),
            SizedBox(height: 16),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Center(
          child: SizedBox(
            width: 380, // 👈 customize here
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Added to Cart Sucessfull !"))
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Go to Cart", style: TextStyle(color: Colors.white,fontSize: 22)),
            ),
          ),
        ),
      ),
      
    );
  }
}
