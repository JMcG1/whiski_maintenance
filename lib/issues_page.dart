import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'issue_details_page.dart'; // Import the IssueDetailsPage

enum SortOrder { newest, oldest }

class IssuesPage extends StatefulWidget {
  const IssuesPage({Key? key}) : super(key: key);

  @override
  _IssuesPageState createState() => _IssuesPageState();
}

class _IssuesPageState extends State<IssuesPage> {
  SortOrder _sortOrder = SortOrder.newest;

  Stream<QuerySnapshot> _loadIssues() {
    return FirebaseFirestore.instance
        .collection('issues')
        .orderBy('timestamp', descending: _sortOrder == SortOrder.newest)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issues List'),
        actions: <Widget>[
          PopupMenuButton<SortOrder>(
            onSelected: (SortOrder result) {
              setState(() {
                _sortOrder = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOrder>>[
              const PopupMenuItem<SortOrder>(
                value: SortOrder.newest,
                child: Text('Newest'),
              ),
              const PopupMenuItem<SortOrder>(
                value: SortOrder.oldest,
                child: Text('Oldest'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _loadIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No issues found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

              if (data == null) {
                // Handle the case where data is null
                return ListTile(
                  title: Text('No data available'),
                );
              }

              String title = data['title'] ?? 'No Title';
              DateTime? issueDate = (data['timestamp'] as Timestamp?)?.toDate();
              String formattedDate = issueDate != null
                  ? DateFormat('yyyy-MM-dd – kk:mm').format(issueDate)
                  : 'No Date';

              return ListTile(
                title: Text(title),
                subtitle: Text('Date: $formattedDate'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => IssueDetailsPage(issueDocument: document),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IssueDetailsPage(issueDocument: null),
            ),
          );
        },
        child: Icon(Icons.add),
      ),

    );
  }
}
