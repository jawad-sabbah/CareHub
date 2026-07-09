import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../services/family_service.dart';
import '../../core/api_exception.dart';

const _brandBlue = Color(0xFF1E3FE0);

class GiveInsuranceScreen extends StatefulWidget {
  const GiveInsuranceScreen({super.key});

  @override
  State<GiveInsuranceScreen> createState() =>
      _GiveInsuranceScreenState();
}

class _GiveInsuranceScreenState extends State<GiveInsuranceScreen> {

  List<FamilyMember> _members = [];

  bool _isLoading = false;
  String? _error;

  final TextEditingController _searchController =
      TextEditingController();

  String _query = "";


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _searchMembers(String value) async {

    final term = value.trim();

    setState(() {
      _query = value;
      _error = null;
    });


    if (term.isEmpty) {

      setState(() {
        _members = [];
      });

      return;
    }


    setState(() {
      _isLoading = true;
    });


    try {

      final results =
          await FamilyService.searchEligibleMembers(term);


      setState(() {

        _members = results.map((e) {

          return FamilyMember(

            id: e.id,

            name: e.name,

            email: e.email,

            relation: "Eligible Member",

            gender: "",

            dateOfBirth: "",

            isPrimary: false,

            // search result does not return insurance status
            status: "inactive",

          );

        }).toList();


        _isLoading = false;

      });


    } on ApiException catch(e) {


      setState(() {

        _error = e.message;

        _isLoading = false;

      });


    }

  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),


      appBar: AppBar(

        backgroundColor:
            const Color(0xFFF5F6FA),

        elevation: 0,

        title: const Text(

          "Give Insurance",

          style: TextStyle(

            color: _brandBlue,

            fontWeight: FontWeight.bold,

          ),

        ),

        iconTheme:
            const IconThemeData(
              color: _brandBlue,
            ),

      ),



      body: Column(

        children: [


          Padding(

            padding:
              const EdgeInsets.all(20),


            child: TextField(

              controller:
                  _searchController,


              onChanged:
                  _searchMembers,


              decoration:
                  InputDecoration(

                hintText:
                    "Search member by name or email",


                prefixIcon:
                    const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),


                suffixIcon:

                  _query.isEmpty

                  ?

                  null

                  :

                  IconButton(

                    icon:
                      const Icon(
                        Icons.clear,
                        color: Colors.grey,
                      ),


                    onPressed:(){

                      _searchController.clear();

                      _searchMembers("");

                    },

                  ),



                filled:true,

                fillColor:
                    Colors.white,


                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(12),

                  borderSide:
                      BorderSide.none,

                ),

              ),

            ),

          ),




          Expanded(

            child:

            _isLoading

            ?

            const Center(
              child:
                CircularProgressIndicator(),
            )


            :

            _error != null

            ?

            Center(
              child:
                Text(
                  _error!,
                  style:
                    const TextStyle(
                      color: Colors.grey,
                    ),
                ),
            )


            :

            _members.isEmpty


            ?

            Center(

              child:

              Text(

                _query.isEmpty

                ?

                "Search for a member"

                :

                "No members found",

                style:
                  const TextStyle(
                    color: Colors.grey,
                  ),

              ),

            )


            :

            ListView.separated(

              padding:
                const EdgeInsets.symmetric(
                  horizontal:20,
                ),


              itemCount:
                  _members.length,


              separatorBuilder:
                (_,__) =>
                  const SizedBox(height:10),


              itemBuilder:
                (_,index)=>
                  _memberCard(
                    _members[index],
                  ),

            ),

          )


        ],

      ),

    );

  }




  Widget _memberCard(FamilyMember member) {


    return Container(

      padding:
          const EdgeInsets.all(14),


      decoration:
          BoxDecoration(

        color:
            Colors.white,


        borderRadius:
            BorderRadius.circular(14),

      ),



      child: Row(

        children:[


          CircleAvatar(

            backgroundColor:
                const Color(0xFFE3E9FF),


            child:
              Text(

                member.name.isNotEmpty
                ?
                member.name[0].toUpperCase()
                :
                "?",


                style:
                  const TextStyle(

                    color:_brandBlue,

                    fontWeight:
                      FontWeight.bold,

                  ),

              ),

          ),



          const SizedBox(width:12),



          Expanded(

            child:Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children:[


                Text(

                  member.name,

                  style:
                    const TextStyle(

                      fontWeight:
                          FontWeight.bold,

                    ),

                ),



                const SizedBox(height:5),



                Text(

                  member.email ?? "",

                  style:
                    const TextStyle(

                      color:Colors.grey,

                      fontSize:12,

                    ),

                ),

              ],

            ),

          ),



          const Icon(
            Icons.chevron_right,
            color:Colors.grey,
          )


        ],

      ),

    );

  }

}