


class Command{
  String command,from,to;
  Command({required this.command, required this.from,required this.to});

  Map<String,dynamic> toMap(){
    return {
        'Commands':{
        'command': command,
        'from': from,
        'to': to,
      }
    };
  }

  static Command toObject(data){
    return Command(
      command:data['command'],
      from:data['from'],
      to:data['to'],
    );
  }
}