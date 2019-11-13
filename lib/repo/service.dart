import 'package:intern/models/user.dart';
import 'package:intern/repo/db_creator.dart';

class UserService{
  static Future<List<User>> getAllUser() async {
    final sql= 'SELECT * FROM ${DBCreator.table}';
    final data = await db.rawQuery(sql);

    List <User> users = List(); 

    for (final node in data){
      final user = User.fromJson(node);
      users.add(user);
    }
    return users;
  }

  static Future <void> addUser(User user) async {
    final sql = 'INSERT INTO ${DBCreator.table}(${DBCreator.id},${DBCreator.userName},${DBCreator.lat},${DBCreator.long},${DBCreator.img}) VALUES (?,?,?,?,?)';
    List <dynamic> params = [user.id,user.userName,user.lat,user.long,user.img];
    final result = await db.rawInsert(sql,params);
  }

  static Future<int> usersCount() async {
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DBCreator.table}''');

    int count = data[0].values.elementAt(0);
    int idForNewItem = count++;
    return idForNewItem;
  }
}
                                               