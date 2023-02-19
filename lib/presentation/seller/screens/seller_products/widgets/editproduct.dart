import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sample_project/presentation/authentication/login.dart';
import 'package:sample_project/presentation/seller/screens/seller_products/seller_product.dart';

class EditProductForm extends StatefulWidget {
  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isWholesale = false;
  late String _productName;
  late int _maxQuantity;
  late int _minQuantity;
  late int _productPrice;
  late String _productDesc ;  

  final kpname = TextEditingController() ;
  final kdesc = TextEditingController() ;
  final kprice = TextEditingController();
  final kminqty = TextEditingController() ;
  final kmaxqty = TextEditingController() ;
  final kselltype = TextEditingController() ;
  final kcat = TextEditingController() ;
  
  final _imageController = TextEditingController();

  String? productImgUrl;
  File? image;
  UploadTask? uploadTask;
  
  Future pickimagefromgallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imgtemp = File(image.path);
      setState(() {
        this.image = imgtemp;
      });
    } on PlatformException catch (e) {
      return ('failed to pick image: $e ');
    }
  }

  Future pickusingcamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imgtemp = File(image.path);
      setState(() {
        this.image = imgtemp;
      });
    } on PlatformException catch (e) {
      return ('failed to pick image: $e ');
    }
  }

 Future<String> uploadImage(File image) async {
  // Generate a unique file name
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();

  // Create a reference to the file location in Firebase Storage
  Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');

  // Upload the file to Firebase Storage
  uploadTask = ref.putFile(image);

  final snapshot = await uploadTask!.whenComplete(() {});

  // Get the download URL for the file
  String downloadURL = await snapshot.ref.getDownloadURL();

  // Return the download URL
  return downloadURL;
}

  @override
  Widget build(BuildContext context) {
    


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  child: image != null
                      ? Image.file(
                          image!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : FlutterLogo(
                          size: 160,
                        ),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.black,
                    width: 10,
                  )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(),
                        onPressed: () {
                          pickusingcamera();
                        },
                        icon: Icon(Icons.camera_alt_rounded),
                        label: Text('Capture Image')),
                    ElevatedButton.icon(
                        onPressed: () {
                          pickimagefromgallery();
                        },
                        icon: Icon(Icons.folder_copy_rounded),
                        label: Text('Pick from Gallery')),
                  ],
                ),
                TextFormField(
                  controller: kpname,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name for the product';
                    }
                    return null;
                  },
                  onSaved: (value) => _productName = value!,
                ),
                TextFormField(
                  controller: kdesc,
                  decoration: InputDecoration(labelText: 'Product Desciption'),
                  maxLines: 4,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a desciption for the product';
                    }
                    return null;
                  },
                  onSaved: (value) => _productDesc = value!,
                ),
                TextFormField(
                  controller: kprice,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the price';
                    }
                    return null;
                  },
                  onSaved: (value) => _productPrice = int.parse(value!),
                ),
                TextFormField(
                  controller: kmaxqty,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Maximum Quantity to Order'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the maximum quantity';
                    }
                    else if (int.parse(kmaxqty.text)<=int.parse(kminqty.text))
                    {
                      return 'Maximum should be greater than Minimum';
                    }
                    return null;
                  },
                  onSaved: (value) => _maxQuantity = int.parse(value!),
                ),
                TextFormField(
                  controller: kminqty,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Minimum Quantity to Order'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the minimum quantity';
                    }
                    return null;
                  },
                  onSaved: (value) => _minQuantity = int.parse(value!),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Retail",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                      Switch(value: _isWholesale, onChanged: (value) {
                    setState(() {
                      _isWholesale = value;
                    });
                  },),
                      const Text("Wholesale",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))
                    ],
                  ),

                
                

               
                // SwitchListTile(
                //   title: const Text('Wholesale'),
                //   value: !_isRetail,
                //   onChanged: (value) {
                //     setState(() {
                //       _isRetail = !value;
                //     });
                //   },
                // ),
                ElevatedButton(
                  onPressed: () async{
                    
                    if (_formKey.currentState!.validate()) { 
                      if (image!=null){
                        productImgUrl = await uploadImage(image!);
                        
                        final user=FirebaseAuth.instance.currentUser;
                      final db=FirebaseFirestore.instance;

                    if(productImgUrl!.isNotEmpty){
                      db.collection("Products").doc().set({
                                    'product_name' :kpname.text,
                                    'image_url': productImgUrl, 
                                    'description':kdesc.text,
                                    'product_price':kprice.text,
                                    'category':'fashion',
                                    'product_seller_id':user?.uid,
                                    'min_quantity':kminqty.text,
                                    'max_quantity':kmaxqty.text,
                                    'product_rating':0.0,
                                    'no_of_rating':0,
                                    'sell_type': _isWholesale?'w':'r',
                                    'upload_time':DateTime.now()
                                  });

                                  Navigator.pop(context);}
                      }
                      else{
                          customsnackbar(errortext: 'Please Upload Image Of Product', errorcolor: Colors.lightBlue);
                      }
                      



                      _formKey.currentState!.save();
                     
    
                      // Add logic to save the product here
                      // ...
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}