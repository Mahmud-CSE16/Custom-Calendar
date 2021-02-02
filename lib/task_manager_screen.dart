import 'package:flutter/material.dart';

import 'CustomCalender/custom_calendar.dart';

class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5E5E5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: CustomCalendarWidget(

                titleWidget: Row(
                  children: [
                    Icon(Icons.psychology_outlined,size: 40,),
                    SizedBox(width: 3,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Task Manager",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700),),
                        Text("Task Manager",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400),),
                      ],
                    )
                  ],
                ),

                //here should pass exact date without time like bellow
                selectedDateTimeStart: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day),
                selectedDateTimeEnd: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+5),

                onChangeDate: (startAt,endAt){
                  print("Selected Start Date $startAt");
                  print("Selected End Date $endAt");
                },
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("To Do",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
                      SizedBox(height: 15,),

                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
