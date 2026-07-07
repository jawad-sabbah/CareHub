class VirtualCardModel {

  final int memberId;
  final String name;
  final String relationship;
  final String policyCode;
  final String providerName;
  final String planName;
  final String status;
  final String cardNumber;


  VirtualCardModel({
    required this.memberId,
    required this.name,
    required this.relationship,
    required this.policyCode,
    required this.providerName,
    required this.planName,
    required this.status,
    required this.cardNumber,
  });


  factory VirtualCardModel.fromJson(Map<String,dynamic> json){

    return VirtualCardModel(

      memberId: json["memberId"],
      name: json["name"],
      relationship: json["relationship"],
      policyCode: json["policyCode"],
      providerName: json["providerName"],
      planName: json["planName"],
      status: json["insuranceStatus"],
      cardNumber: json["cardNumber"],

    );

  }

}