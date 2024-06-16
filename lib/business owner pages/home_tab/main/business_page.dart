import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyBusinessScreen extends StatefulWidget {
  final String businessId;
  final Map<String, dynamic> businessData;

  MyBusinessScreen({required this.businessId, required this.businessData});

  @override
  State<MyBusinessScreen> createState() => MyBusinessScreenState();
}

class MyBusinessScreenState extends State<MyBusinessScreen> {
  late Map<String, dynamic> businessDataMap;

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      print('Image picked: ${pickedFile.path}');
    } else {
      print('No image picked');
    }
  }

  @override
  void initState() {
    super.initState();
    businessDataMap = widget.businessData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${businessDataMap['name']}',
          style: TextStyle(
            fontFamily: "Roboto",
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            GridView.builder(
              itemCount: 5,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text(
                                  'Choose from Gallery',
                                  style: TextStyle(fontFamily: "Roboto"),
                                ),
                                onTap: () {
                                  _getImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text(
                                  'Take a Photo',
                                  style: TextStyle(fontFamily: "Roboto"),
                                ),
                                onTap: () {
                                  _getImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Text(
              'Business Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Divider(height: 0, thickness: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(Icons.store, color: Colors.blue),
                    title: Text(
                      'Business Name:',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    subtitle: Text(
                      '${businessDataMap['name']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(height: 0, thickness: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text(
                      'Description:',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    subtitle: Text(
                      '${businessDataMap['description']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.place, color: Colors.blue),
                    title: Text(
                      'Location:',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    subtitle: Text(
                      '${businessDataMap['location']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(height: 0, thickness: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(Icons.phone_android, color: Colors.blue),
                    title: Text(
                      'Phone Number:',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    subtitle: Text(
                      '${businessDataMap['phone_number']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
