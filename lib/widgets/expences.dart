import 'package:flutter/material.dart';
import 'package:expences_tracker/widgets/new_expence.dart';
import 'package:expences_tracker/model/expence_model.dart';
import 'package:expences_tracker/widgets/chart/chart.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../service/database_helper.dart';
import 'expences_item.dart';
import 'user_info_page.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Expences extends StatefulWidget {
  final String userName;
  final String userEmail;

  const Expences({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExpencesState();
  }
}

class _ExpencesState extends State<Expences> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late List<ExpenceModel> _registeredExpences = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() async {
    final expenses = await DatabaseHelper.getAllExpences();
    if (expenses != null) {
      setState(() {
        _registeredExpences = expenses;
      });
    }
  }

  void _addExpence() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => NewExpence(onAddExpence: _registerExpence),
    );
  }

  void _registerExpence(ExpenceModel expence) async {
    await DatabaseHelper.addExpense(expence);
    _loadExpenses();
  }

  void _onRemovedExpence(ExpenceModel expence, BuildContext context) async {
    await DatabaseHelper.deleteExpense(expence);
    setState(() {
      _registeredExpences.remove(expence);
    });

    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: const Text("Expense Deleted"),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () async {
          int undoResult = await DatabaseHelper.addExpense(expence);
          if (undoResult > 0) {
            _loadExpenses();
          }
          _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        },
      ),
    );

    _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  Future<void> _downloadExpenses() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expenses.txt');

      // Prepare expense data for download
      String content = _registeredExpences
          .map((e) => '${e.title}, ${DateFormat.yMMMd().format(e.date)}, \$${e.price}')
          .join('\n');

      // Write content to the file
      await file.writeAsString(content);

      // Check if the file exists
      bool fileExists = await file.exists();
      print('File exists: $fileExists'); // Debug line

      // Notify user about download completion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expenses downloaded successfully!')),
      );
    } catch (e) {
      // Handle errors
      print('Error downloading expenses: $e'); // Debug line
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download expenses: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Expences Tracker",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _addExpence,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.userName,
                style: const TextStyle(color: Colors.black),
              ),
              accountEmail: Text(
                widget.userEmail,
                style: const TextStyle(color: Colors.black),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0] : '',
                  style: const TextStyle(fontSize: 40.0, color: Colors.black),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('User Information'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserInfoPage(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.money),
                          title: const Text('Expenses'),
                          onTap: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                    left: 16,
                                    right: 16,
                                    top: 16,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppBar(
                                        title: const Text('Your Expenses'),
                                        actions: [
                                          IconButton(
                                            icon: const Icon(Icons.download),
                                            onPressed: () {
                                              _downloadExpenses();
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final picked = await showDateRangePicker(
                                            context: context,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              // Apply filter based on picked dates
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.calendar_today),
                                        label: const Text('Filter by Date'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _registeredExpences.length,
                                          itemBuilder: (context, index) {
                                            var expense = _registeredExpences[index];
                                            return ListTile(
                                              title: Text(expense.title),
                                              subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                                              trailing: Text('\$${expense.price}'),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('ChatBot'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatBotPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Chart(
              expenses: _registeredExpences,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _registeredExpences.length,
                itemBuilder: (context, index) => Dismissible(
                  background: Container(
                    color: Colors.redAccent,
                    margin: EdgeInsets.symmetric(
                      horizontal: Theme.of(context).cardTheme.margin!.horizontal,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.delete),
                  ),
                  key: ValueKey(index),
                  onDismissed: (direction) {
                    _onRemovedExpence(_registeredExpences[index], context);
                  },
                  child: ExpencesItem(
                    expence: _registeredExpences[index],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final userMessage = _controller.text;

    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({'role': 'user', 'text': userMessage});
        _messages.add({'role': 'bot', 'text': _getBotResponse(userMessage)});
      });
      _controller.clear();
    }
  }

  String _getBotResponse(String userMessage) {
    // Simple logic to return a response based on user input
    if (userMessage.toLowerCase().contains('hello')) {
      return 'Hi there! How can I assist you today?';
    } else if (userMessage.toLowerCase().contains('how are you')) {
      return 'I\'m just a bot, but thanks for asking!';
    } else {
      return 'Sorry, I didn\'t understand that.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['text']!),
                  subtitle: Text(message['role'] == 'user' ? 'You' : 'Bot'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Ask something...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
