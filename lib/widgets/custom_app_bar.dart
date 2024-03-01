import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CareCompanion/patient/search_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<String?> Function() fetchUsername;
  final Function()? onSearchPressed;
  final Function()? onNotificationPressed;

  const CustomAppBar({
    Key? key,
    required this.fetchUsername,
    this.onSearchPressed,
    this.onNotificationPressed,
  }) : super(key: key);

  void _onSearchPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey,
          child: CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage("assets/images/pm.png"),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _onSearchPressed(context), // Pass the context here
          icon: const Icon(
            Icons.search,
            color: Colors.black54,
          ),
        ),
        IconButton(
          onPressed: onNotificationPressed,
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.black54,
          ),
        ),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String?>(
                future: fetchUsername(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  );
                },
              ),
            ],
          ),
          // Add other widgets if needed in the Row
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Future<String?> fetchUsername() async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userInfoDoc =
          await FirebaseFirestore.instance
              .collection('user_info')
              .doc(currentUser.uid)
              .get();
      if (userInfoDoc.exists) {
        // Check if the document exists
        var username = userInfoDoc['name'] ?? '';
        var familyName = userInfoDoc['family_name'] ?? '';

        if (username.isNotEmpty && familyName.isNotEmpty) {
          return '$username $familyName';
        }
      }
    }

    return 'Loading...';
  } catch (e) {
    print('Error fetching username: $e');
    return 'Error';
  }
}
