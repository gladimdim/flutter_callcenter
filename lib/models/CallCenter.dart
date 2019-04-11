import 'dart:async';
import 'dart:math';
import 'package:async/async.dart' show StreamGroup;

class CallCenter {
  List<Responder> workers = [];
  List<Responder> managers = [];
  List<Responder> directors = [];
  List<List<Responder>> allProcessors = [];
  List<Call> queueCalls = [];

  StreamController<List<List<Responder>>> _responderStream = StreamController();
  StreamController<List<Call>> _queue = StreamController();
  Stream changes;

  CallCenter() {
    workers.addAll([
      Responder(type: ResponderType.Worker, name: "Responder A"),
      Responder(type: ResponderType.Worker, name: "Responder B"),
      Responder(type: ResponderType.Worker, name: "Responder C"),
      Responder(type: ResponderType.Worker, name: "Responder D"),
    ]);

    managers.addAll([
      Responder(type: ResponderType.Manager, name: "Manager A"),
      Responder(type: ResponderType.Manager, name: "Manager B"),
      Responder(type: ResponderType.Manager, name: "Manager C"),
    ]);

    directors.addAll([
      Responder(type: ResponderType.Director, name: "Director A"),
      Responder(type: ResponderType.Director, name: "Director B"),
    ]);

    allProcessors.add(workers);
    allProcessors.add(managers);
    allProcessors.add(directors);

    changes = StreamGroup.merge([_responderStream.stream, _queue.stream]);

  }

  dispatchCall(Call call) {
    Responder processor;
    for (var i = 0; i < allProcessors.length; i++) {
      try {
        processor = allProcessors[i].firstWhere((Responder p) => !p.isBusy());
      } catch (e) {
        print('Switching to next level');
        continue;
      }
      if (processor != null) {
        break;
      }
    }
    if (processor == null) {
      queueCalls.add(call);
      _queue.sink.add(queueCalls);
    } else {
      processor.respondToCall(call);
      call.addEndCallback(callEnded);
      _responderStream.sink.add(allProcessors);
    }
  }

  endRandomCall() {
    Random random = Random();
    var groupRandom = random.nextInt(allProcessors.length);
    var subGroupRandom = random.nextInt(allProcessors[groupRandom].length);
    allProcessors[groupRandom][subGroupRandom].endCurrentCall();
  }

  callEnded() {
    _responderStream.sink.add(allProcessors);
    if (queueCalls.length > 0) {
      dispatchCall(queueCalls[0]);
      queueCalls.removeAt(0);
      _queue.sink.add(queueCalls);
    }
  }
}

enum ResponderType { Manager, Director, Worker }

class Responder {
  final ResponderType type;
  Call call;
  final String name;

  Responder({this.type, this.name});

  void respondToCall(Call incoming) {
    if (isBusy()) {
      throw ResponderBusyException('Responder $name of type $type is busy.');
    }
    call = incoming;
  }

  bool isBusy() {
    return this.call != null;
  }

  endCurrentCall() {
    if (this.isBusy()) {
      var temp = call;
      call = null;
      temp.endCall();
    }
  }
}

class Call {
  String msg;
  List<Function> endCallCallbacks = [];

  Call(this.msg);

  addEndCallback(Function callback) {
    endCallCallbacks.add(callback);
  }

  endCall() {
    endCallCallbacks.forEach((f) => f());
  }
}

class ResponderBusyException implements Exception {
  String msg;

  ResponderBusyException(this.msg);
}
