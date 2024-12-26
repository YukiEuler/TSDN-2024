import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: user != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                        child: user.photoURL == null
                          ? Icon(Icons.person, size: 50)
                          : null,
                      ),
                    ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      user.displayName ?? 'N/A',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      user.email ?? 'N/A',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('UID'),
                    subtitle: Text(user.uid),
                  ),
                ],
              ),
            )
          : const Center(
              child: Text(
                'No user is currently signed in.',
                style: TextStyle(fontSize: 18),
              ),
            ),
    );
  }
}