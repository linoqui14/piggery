

class Baboy{
  String id;
  List<double> weight;
  List<double> area;
  List<int> date;

  Baboy({required this.id, required this.weight, required this.area,required this.date});

  Map<String,dynamic> toMap(){
    return {
      id:{
        'id': id,
        'weight': weight,
        'area': area,
        'date': date,
      }
    };
  }

  static Baboy toObject(data){
    return Baboy(
      id:data['id'],
      weight:data['weight'],
      area:data['area'],
      date:data['date'],
    );
  }
}