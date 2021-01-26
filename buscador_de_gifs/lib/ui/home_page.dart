import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty)
      response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=PBsW8NoL2cw6kccCDQNFkz9XDacdDUaG&limit=20&rating=g');
    else
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=PBsW8NoL2cw6kccCDQNFkz9XDacdDUaG&q=$_search&limit=19&offset=$_offset&rating=g&lang=en');
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: buildSearchField(),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return buildLoadingIndicator();
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildLoadingIndicator() {
    return Container(
                    width: 200.0,
                    height: 200.0,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 5.0,
                    ),
                  );
  }

  TextField buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        icon: Icon(
          Icons.search,
          color: Colors.white,
          size: 32.0,
        ),
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
      ),
      style: TextStyle(color: Colors.white, fontSize: 24.0),
      textAlign: TextAlign.center,
      onSubmitted: (text) {
        setState(() {
          _search = text;
          _offset = 0;
        });
      },
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length)
          return buildGestureDetectorGifs(snapshot, index, context);
        else {
          return buildCarregarMais();
        }
      },
    );
  }

  Container buildCarregarMais() {
    return Container(
      child: GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            Text(
              'Carregar mais ...',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _offset += 19;
          });
        },
      ),
    );
  }

  GestureDetector buildGestureDetectorGifs(
      AsyncSnapshot snapshot, int index, BuildContext context) {
    return GestureDetector(
      child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          height: 300.0,
          fit: BoxFit.cover,
          image: snapshot.data["data"][index]["images"]["fixed_height"]["url"]),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GifPage(snapshot.data["data"][index])));
      },
      onLongPress: () {
        Share.share(
            snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
      },
    );
  }
}
