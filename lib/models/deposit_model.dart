class DepositModel {
  final String id;
  final String number;
  final String name;
  final String date;
  final String tillDate;
  final String status;
  final int amount;
  final int currentAmount;
  final int currentBenefit;
  final double? interest;
  final bool hasCashInterest;

  const DepositModel({
    required this.id,
    required this.number,
    required this.name,
    required this.date,
    required this.tillDate,
    required this.status,
    required this.amount,
    required this.currentAmount,
    required this.currentBenefit,
    required this.hasCashInterest,
    this.interest,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: json['id'] as String,
      number: json['number'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      tillDate: json['till_date'] as String,
      status: json['status'] as String,
      amount: json['amount'] as int,
      currentAmount: json['current_amount'] as int,
      currentBenefit: json['current_benefit'] as int,
      hasCashInterest: json['has_cash_interest'] as bool,
      interest: (json['interest'] as num?)?.toDouble(),
    );
  }
}
