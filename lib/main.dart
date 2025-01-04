import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
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
        primarySwatch: Colors.teal, // Stylish primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cinema', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), // Big centered title
          backgroundColor: Colors.teal,
          centerTitle: true,  // Centered title
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
          title: Text("Receipt"),
          content: Text(receipt),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
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
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search Movies',
              hintText: 'Enter movie name...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.teal.shade50, // Light background color for the search bar
            ),
            onChanged: (name) {
              searchMovies(name);
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    movies[index].name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold), // Bigger font for movie name
                    textAlign: TextAlign.center, // Centered movie name
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: ${movies[index].category}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'Seats left: ${movies[index].quantity}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'Price: \$${movies[index].price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
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
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Price: \$${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
        if (totalPrice > 0)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: showReceipt,
              child: const Text(
                'Get Receipt',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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