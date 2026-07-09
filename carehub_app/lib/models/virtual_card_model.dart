class VirtualCardModel {

  final int memberId;
  final String name;
  final String relationship;
  final String policyCode;
  final String providerName;
  final String planName;
  final String status;
  final String cardNumber;

  final double coveragePercentage;
  final double annualLimit;
  final double usedAmount;
  final double remainingAmount;


  VirtualCardModel({
    required this.memberId,
    required this.name,
    required this.relationship,
    required this.policyCode,
    required this.providerName,
    required this.planName,
    required this.status,
    required this.cardNumber,
    required this.coveragePercentage,
    required this.annualLimit,
    required this.usedAmount,
    required this.remainingAmount,
  });


  factory VirtualCardModel.fromJson(Map<String,dynamic> json){

    double _toDouble(dynamic v) =>
        v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

    return VirtualCardModel(

      memberId: json["memberId"],
      name: json["name"],
      relationship: json["relationship"],
      policyCode: json["policyCode"],
      providerName: json["providerName"],
      planName: json["planName"],
      status: json["insuranceStatus"],
      cardNumber: json["cardNumber"],

      coveragePercentage: _toDouble(json["coveragePercentage"]),
      annualLimit: _toDouble(json["annualLimit"]),
      usedAmount: _toDouble(json["usedAmount"]),
      remainingAmount: _toDouble(json["remainingAmount"]),

    );

  }

}