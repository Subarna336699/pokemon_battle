import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Card Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PokemonBattleScreen(),
    );
  }
}

class PokemonBattleScreen extends StatefulWidget {
  const PokemonBattleScreen({super.key});

  @override
  State<PokemonBattleScreen> createState() => _PokemonBattleScreenState();
}

class _PokemonBattleScreenState extends State<PokemonBattleScreen> {
  List<dynamic> pokemonCards = [];
  Map<String, dynamic>? card1;
  Map<String, dynamic>? card2;
  String? winner;

  @override
  void initState() {
    super.initState();
    loadRandomCards();
  }

  Future<void> loadRandomCards() async {
    final response = await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));
    if (response.statusCode == 200) {
      setState(() {
        pokemonCards = jsonDecode(response.body)['data'];
        // Get two random cards
        final random = Random();
        card1 = pokemonCards[random.nextInt(pokemonCards.length)];
        card2 = pokemonCards[random.nextInt(pokemonCards.length)];
        determineWinner();
      });
    }
  }

  void determineWinner() {
    if (card1 != null && card2 != null) {
      final hp1 = int.tryParse(card1!['hp'] ?? '0') ?? 0;
      final hp2 = int.tryParse(card2!['hp'] ?? '0') ?? 0;
      
      setState(() {
        if (hp1 > hp2) {
          winner = 'Card 1 wins!';
        } else if (hp2 > hp1) {
          winner = 'Card 2 wins!';
        } else {
          winner = 'It\'s a tie!';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Card Battle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (card1 != null && card2 != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Image.network(
                        card1!['images']['small'],
                        height: 200,
                        width: 150,
                      ),
                      const SizedBox(height: 10),
                      Text('HP: ${card1!['hp']}'),
                    ],
                  ),
                  Column(
                    children: [
                      Image.network(
                        card2!['images']['small'],
                        height: 200,
                        width: 150,
                      ),
                      const SizedBox(height: 10),
                      Text('HP: ${card2!['hp']}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                winner ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loadRandomCards,
              child: const Text('Load New Cards'),
            ),
          ],
        ),
      ),
    );
  }
} 