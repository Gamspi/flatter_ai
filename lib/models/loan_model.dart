class LoanModel {
  final String id;
  final String number;
  final String name;
  final String date;
  final String status;
  final int amount;
  final int amountSpent;
  final String? tillDate;
  final double? interest;

  const LoanModel({
    required this.id,
    required this.number,
    required this.name,
    required this.date,
    required this.status,
    required this.amount,
    required this.amountSpent,
    this.tillDate,
    this.interest,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      number: json['number'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      amount: json['amount'] as int,
      amountSpent: json['amount_spent'] as int,
      tillDate: json['till_date'] as String?,
      interest: (json['interest'] as num?)?.toDouble(),
    );
  }
}
