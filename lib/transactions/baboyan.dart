class Baboyan{
  String id;
  int time;

  Baboyan({required this.id, required this.time});

  Map<String,dynamic> toMap(){
    return {

        id:{
          'id': id,
          'time': time,
        }


    };
  }

  static Baboyan toObject(data){
    return Baboyan(
      id:data['id'],
      time:data['time'],
    );
  }
}