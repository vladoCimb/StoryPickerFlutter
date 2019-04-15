import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final PageController ctrl = PageController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: FirestoreSlideShow(),
    ));
  }
}

class FirestoreSlideShow extends StatefulWidget {
  createState() => FirestoreSlideshowState();
}

class FirestoreSlideshowState extends State<FirestoreSlideShow> {
  final PageController ctrl = PageController(viewportFraction: 0.8);

  final Firestore db = Firestore.instance;
  Stream slides;

  String activeTag = 'favorites';

  int currentPage = 0;

  @override
  void initState() {
    _queryDb();

    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: slides,
        initialData: [],
        builder: (context, AsyncSnapshot snap) {
          List slideList = snap.data.toList();
          return PageView.builder(
            controller: ctrl,
            itemCount: slideList.length + 1,
            itemBuilder: (context, int currentIdx) {
              if (currentIdx == 0) {
                //return _buildTagPage();
                return _buildTagPage();
              } else if (slideList.length >= currentIdx) {
                bool active = currentIdx == currentPage;
                return _buildStoryPage(slideList[currentIdx - 1], active);
              }
            },
          );
        });
  }

  Stream _queryDb({ String tag ='favorites' }) {
    
    // Make a Query
    Query query = db.collection('stories').where('tags', arrayContains: tag);

    // Map the documents to the data payload
    slides = query.snapshots().map((list) => list.documents.map((doc) => doc.data));

    // Update the active tag
    setState(() {
      activeTag = tag;
    });

  }


_buildTagPage() {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Pick your stories',style:TextStyle(fontSize:40,fontWeight:FontWeight.bold),),
        Text('FILTER',style: TextStyle(color: Colors.black26),),
        _buildButton('favorites'),
        _buildButton('night'),
        _buildButton('cars')
      ],
    ),
  );
}


_buildButton(tag){
  Color color = tag == activeTag ? Colors.grey : Colors.white;
  return FlatButton(color: color,child: Text('#$tag'),onPressed: () => _queryDb(tag: tag));
}

_buildStoryPage(Map data, bool active) {
  final double blur = active ? 30 : 0;
  final double offset = active ? 20 : 0;
  final double top = active ? 100 : 200;

  return AnimatedContainer(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeOutQuint,
    margin: EdgeInsets.only(
      top: top,
      bottom: 50,
      right: 30,
    ),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(data['img']),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black87,
              blurRadius: blur,
              offset: Offset(offset, offset))
        ]),
    child: Center(
      child: Text(
        data['title'],
        style: TextStyle(fontSize: 40, color: Colors.white),
      ),
    ),
  );
}
}
