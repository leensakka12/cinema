import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movie.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Cinema',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.orange,
          centerTitle: true,
          elevation: 5,
        ),
        body: const Center(
          child: MoviesSection(),
        ),
      ),
    );
  }
}

class MoviesSection extends StatefulWidget {
  const MoviesSection({super.key});

  @override
  State<MoviesSection> createState() => _MoviesSectionState();
}

class _MoviesSectionState extends State<MoviesSection> {
  List<Movie> movies = [];
  List<Movie> selectedMovies = [];
  TextEditingController searchController = TextEditingController();
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  void loadMovies() async {
    const url = 'http://localhost/mobile/getMovie.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        movies = data.map<Movie>((obj) {
          return Movie(
            name: obj['name'],
            quantity: int.parse(obj['quantity']),
            price: double.parse(obj['price']),
            category: obj['category'],
          );
        }).toList();
      });
    }
  }

  void searchMovies(String name) async {
    String url = 'http://localhost/mobile/search.php?name=$name';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        movies = data.map<Movie>((obj) {
          return Movie(
            name: obj['name'],
            quantity: int.parse(obj['quantity']),
            price: double.parse(obj['price']),
            category: obj['category'],
          );
        }).toList();
      });
    }
  }

  void calculateTotalPrice() {
    double price = 0.0;
    for (var movie in selectedMovies) {
      price += movie.price;
    }
    setState(() {
      totalPrice = price;
    });
  }

  void showReceipt() {
    String receipt = "Receipt:\n";
    for (var movie in selectedMovies) {
      receipt += "${movie.name} - \$${movie.price}\n";
    }
    receipt += "\nTotal: \$${totalPrice.toStringAsFixed(2)}";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Receipt"),
          content: Text(receipt),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Movies',
                labelStyle: const TextStyle(color: Colors.orange),
                hintText: 'Enter movie name...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
              ),
              onChanged: (name) {
                searchMovies(name);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        movies[index].name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category: ${movies[index].category}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Quantity: ${movies[index].quantity}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Price: \$${movies[index].price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: selectedMovies.contains(movies[index]),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected != null && selected) {
                              selectedMovies.add(movies[index]);
                            } else {
                              selectedMovies.remove(movies[index]);
                            }
                            calculateTotalPrice();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Price: \$${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        if (totalPrice > 0)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: showReceipt,
              child: const Text(
                'Get Receipt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}