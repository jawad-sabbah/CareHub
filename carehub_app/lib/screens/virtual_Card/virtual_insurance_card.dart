import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/virtual_card_model.dart';
import '../../services/insurance_service.dart';
import '../../core/api_exception.dart';


const _brandBlue = Color(0xFF1E3FE0);


class VirtualInsuranceCardScreen extends StatefulWidget {

  final int memberId;

  const VirtualInsuranceCardScreen({
    super.key,
    required this.memberId,
  });


  @override
  State<VirtualInsuranceCardScreen> createState() =>
      _VirtualInsuranceCardScreenState();

}



class _VirtualInsuranceCardScreenState
    extends State<VirtualInsuranceCardScreen> {


  VirtualCardModel? _card;

  bool _isLoading = true;

  String? _error;



  @override
  void initState() {
    super.initState();
    _load();
  }



  Future<void> _load() async {

    setState(() {
      _isLoading = true;
      _error = null;
    });


    try {

      final card =
          await InsuranceService.getCard(widget.memberId);


      setState(() {

        _card = card;

        _isLoading = false;

      });


    } on ApiException catch(e){

      setState(() {

        _error = e.message;

        _isLoading = false;

      });

    }

  }




  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: const Color(0xFFF5F6FA),


      appBar: AppBar(

        backgroundColor: const Color(0xFFF5F6FA),

        elevation: 0,

        title: const Text(
          "Virtual Insurance Card",
          style: TextStyle(
            color: _brandBlue,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),



      body:

      _isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )


          : _error != null

          ? Center(

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  Text(_error!),


                  const SizedBox(height:12),


                  ElevatedButton(

                    onPressed: _load,

                    child: const Text("Retry"),

                  )

                ],

              ),

            )


          : RefreshIndicator(

              onRefresh: _load,

              child: ListView(

                padding: const EdgeInsets.all(20),

                children: [

                  _insuranceCard(_card!),


                  const SizedBox(height:20),


                  _memberInfo(_card!),


                  const SizedBox(height:20),


                  _qrCard(_card!),


                ],

              ),

            ),


    );

  }






  Widget _insuranceCard(VirtualCardModel c){


    return Container(

      padding: const EdgeInsets.all(22),


      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [

            Color(0xFF1E3FE0),

            Color(0xFF1652D6),

          ],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

        ),


        borderRadius: BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(

            color: Colors.blue.withOpacity(.25),

            blurRadius: 15,

            offset: const Offset(0,8),

          )

        ],

      ),



      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,


        children: [



          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [


              const Text(

                "CAREHUB",

                style: TextStyle(

                  color: Colors.white,

                  fontSize:24,

                  fontWeight:FontWeight.bold,

                ),

              ),



              Icon(

                Icons.health_and_safety_outlined,

                color: Colors.white.withOpacity(.8),

                size:32,

              )


            ],

          ),



          const SizedBox(height:25),



          Text(

            c.name,

            style: const TextStyle(

              color: Colors.white,

              fontSize:26,

              fontWeight:FontWeight.bold,

            ),

          ),



          const SizedBox(height:8),



          Text(

            c.relationship,

            style: const TextStyle(

              color: Colors.white70,

              fontSize:15,

            ),

          ),



          const SizedBox(height:20),



          const Text(

            "INSURANCE PLAN",

            style: TextStyle(

              color: Colors.white70,

              fontSize:11,

            ),

          ),



          Text(

            c.planName,

            style: const TextStyle(

              color: Colors.white,

              fontSize:18,

              fontWeight:FontWeight.bold,

            ),

          ),



          const SizedBox(height:5),



          Text(

            c.providerName,

            style: const TextStyle(

              color: Colors.white70,

              fontSize:14,

            ),

          ),



          const SizedBox(height:18),



          Row(

            children: [


              const Text(

                "STATUS",

                style: TextStyle(

                  color: Colors.white70,

                  fontSize:11,

                ),

              ),



              const Spacer(),



              Container(

                padding: const EdgeInsets.symmetric(
                    horizontal:12,
                    vertical:5
                ),

                decoration: BoxDecoration(

                  color: Colors.greenAccent,

                  borderRadius: BorderRadius.circular(20),

                ),


                child: Text(

                  c.status.toUpperCase(),

                  style: const TextStyle(

                    color: Colors.black87,

                    fontSize:12,

                    fontWeight:FontWeight.bold,

                  ),

                ),

              )


            ],

          )


        ],

      ),

    );


  }








  Widget _memberInfo(VirtualCardModel c){


    return Container(

      padding: const EdgeInsets.all(18),


      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

      ),



      child: Column(

        children: [


          _row(
            "Member ID",
            c.memberId.toString(),
          ),

          _row(
            "Policy Code",
            c.policyCode,
          ),



          _row(
            "Relationship",
            c.relationship,
          ),



          _row(
            "Provider",
            c.providerName,
          ),



          _row(
            "Plan",
            c.planName,
          ),



        ],

      ),

    );

  }






  Widget _row(String title,String value){


    return Padding(

      padding: const EdgeInsets.symmetric(vertical:8),


      child: Row(

        children: [


          Text(

            title,

            style: const TextStyle(

              color: Colors.grey,

            ),

          ),



          const Spacer(),



          Flexible(

            child: Text(

              value,

              textAlign: TextAlign.right,

              style: const TextStyle(

                fontWeight:FontWeight.bold,

              ),

            ),

          )


        ],

      ),

    );


  }








  Widget _qrCard(VirtualCardModel c){


    return Container(

      padding: const EdgeInsets.all(20),


      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

      ),



      child: Column(

        children: [



          const Text(

            "Insurance Verification QR",

            style: TextStyle(

              fontSize:18,

              fontWeight:FontWeight.bold,

            ),

          ),



          const SizedBox(height:15),



          QrImageView(

            data:
            "${c.memberId}|${c.cardNumber}|${c.policyCode}",

            size:160,

          ),



          const SizedBox(height:10),



          const Text(

            "Scan to verify insurance",

            style: TextStyle(

              color: Colors.grey,

              fontSize:12,

            ),

          )


        ],

      ),

    );


  }


}