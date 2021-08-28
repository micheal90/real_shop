import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/product.dart';
import 'package:real_shop/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static final routName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriotionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _editProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _isInit = true;
  var _isLoading = false;
  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  void _updateImageUrl() {
    if (_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future _saveForm() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) return;
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (e) {
        print(e);
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("An error ocurred!"),
                  content: Text("Something went wrong."),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Okay"))
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriotionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(15),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: "Tiltle"),
                        initialValue: _initValues['title'],
                        toolbarOptions: ToolbarOptions(
                            copy: true,
                            paste: true,
                            cut: true,
                            selectAll: true),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please provid a value";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: value,
                              description: _editProduct.description,
                              price: _editProduct.price,
                              imageUrl: _editProduct.imageUrl,
                              isFavorite: _editProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Price"),
                        initialValue: _initValues['price'],
                        focusNode: _priceFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        toolbarOptions: ToolbarOptions(
                            copy: true,
                            paste: true,
                            cut: true,
                            selectAll: true),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriotionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter a valid price.";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number.";
                          }
                          if (double.tryParse(value) <= 0) {
                            return "Please enter a number grater than zero.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: _editProduct.title,
                              description: _editProduct.description,
                              price: double.parse(value),
                              imageUrl: _editProduct.imageUrl,
                              isFavorite: _editProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Description"),
                        initialValue: _initValues['description'],
                        maxLines: 3,
                        focusNode: _descriotionFocusNode,
                        keyboardType: TextInputType.multiline,
                        toolbarOptions: ToolbarOptions(
                            copy: true,
                            paste: true,
                            cut: true,
                            selectAll: true),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter a description.";
                          }
                          if (value.length < 10) {
                            return "Shold be at least 10 characters long.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: _editProduct.title,
                              description: value,
                              price: _editProduct.price,
                              imageUrl: _editProduct.imageUrl,
                              isFavorite: _editProduct.isFavorite);
                        },
                      ),
                      Row(
                        children: [
                          Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(),
                              ),
                              margin: EdgeInsets.only(top: 8, right: 10),
                              child: _imageUrlController.text.isEmpty
                                  ? Center(child: Text("Enter a URL"))
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.fill,
                                      ),
                                    )),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: "Image URL"),
                              //initialValue: _initValues['imageUrl'],
                              controller: _imageUrlController,
                              keyboardType: TextInputType.url,
                              focusNode: _imageUrlFocusNode,
                              toolbarOptions: ToolbarOptions(
                                  copy: true,
                                  paste: true,
                                  cut: true,
                                  selectAll: true),

                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter a image URL.";
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return "Please enter a valid URL.";
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return "Please enter a valid image.";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _editProduct = Product(
                                    id: _editProduct.id,
                                    title: _editProduct.title,
                                    description: _editProduct.description,
                                    price: _editProduct.price,
                                    imageUrl: value,
                                    isFavorite: _editProduct.isFavorite);
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
