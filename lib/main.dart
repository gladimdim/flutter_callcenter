// This example shows a [Scaffold] with an [AppBar], a [BottomAppBar] and a
// [FloatingActionButton]. The [body] is a [Text] placed in a [Center] in order
// to center the text within the [Scaffold] and the [FloatingActionButton] is
// centered and docked within the [BottomAppBar] using
// [FloatingActionButtonLocation.centerDocked]. The [FloatingActionButton] is
// connected to a callback that increments a counter.

import 'package:flutter/material.dart';
import 'package:flutter_callcenter/models/CallCenter.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample for material.Scaffold',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  CallCenter callCenter = CallCenter();

  addCall() {
    var random = Random();
    callCenter.dispatchCall(Call("Customer #${random.nextInt(50)}"));
  }

  endCall() {
    callCenter.endRandomCall();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Center'),
      ),
      body: StreamBuilder(
          stream: callCenter.changes,
          builder: (context, snapshot) {
            return Column(
              children: _buildBody() +
                  [_buildButton()] +
                  [_buildQueueView(callCenter.queueCalls)],
            );
          }),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> result = [];
    callCenter.allProcessors
        .forEach((group) => result.add(_buildResponderRow(group)));
    return result;
  }

  Widget _buildResponderRow(List<Responder> group) {
    return Container(
      height: 100.0,
      child: ListView.builder(
        itemCount: group.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _buildResponderView(group[index]);
        },
      ),
    );
  }

  Widget _buildQueueView(List<Call> queueCalls) {
    return Column(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: queueCalls.map((call) => Text(call.msg)).toList());
  }

  Widget _buildResponderView(Responder responder) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children: [
          Text(
            responder.name,
            style: TextStyle(
              color: responder.isBusy() ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold
            ),
          ),
          IconButton(
            icon: Icon(Icons.call_end),
            onPressed: responder.isBusy() ? responder.endCurrentCall : null,
          )
        ]),
      );
    }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: RaisedButton.icon(
            icon: Icon(Icons.call),
            onPressed: addCall,
            label: Text("Add Call"),
          ),
        ),
        RaisedButton.icon(
          icon: Icon(Icons.call_made),
          onPressed: endCall,
          label: Text("End Random Call"),
        )
      ],
    );
  }
}
