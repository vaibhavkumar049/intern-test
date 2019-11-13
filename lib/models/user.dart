import 'package:intern/repo/db_creator.dart';

class User{
  int id;
  String userName;
  double lat;
  double long;
  String img;

  User(this.id,this.userName,this.lat,this.long,this.img);

  User.fromJson(Map<String,dynamic> json){
    this.id=json[DBCreator.id];
    this.userName=json[DBCreator.userName];
    this.lat=json[DBCreator.lat];
    this.long=json[DBCreator.long];
    this.img=json[DBCreator.img];
  }
}