import 'dart:ffi';
AppUser loggedUser = AppUser(id:"", name:"");
enum Status{open, closed}
enum PaymentMethod{dolars, zinli, banesco, binance, bolivares}

Map paymentMethods = {
  "dolars": "Dolares Efectivo",
  "zinli": "Zinli USD",
  "banesco": "Banesco Panamá",
  "binance": "Binance USDT",
  "bolivares": "Bolivares",
};

class AppUser{
  AppUser({required this.id, required this.name});
  late String id;
  late String? name;
}


class Bills{
  Bills({this.id, this.userId, this.title, this.total, this.date, this.participants});
  late String? id; //PK
  late String? userId; //FK AppUser.id
  late String? title;
  late double? total;
  late DateTime? date;
  late List<String>? participants; //FK []AppUser.id
}

class Debt{
  late String id;
  late String description;
  late String issuerId;   //FK AppUser.id
  late String receiverId;   //FK AppUser.id
  late Float amount;
  late DateTime date;
  late String billId = "";  //FK Bills.id
  late Status status;
}

class Payments{
  late String id;
  late String userId; //FK AppUser.id
  late String debtId; //FK Debt.id
  late PaymentMethod type;
  late Float amount;
  late DateTime date;
}