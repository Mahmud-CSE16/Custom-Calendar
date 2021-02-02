
import 'package:flutter/material.dart';
import 'package:swipe_gesture_recognizer/swipe_gesture_recognizer.dart';

import 'calendar.dart';

enum CalendarViews{ dates, months, year }

class CustomCalendarWidget extends StatefulWidget {

  final DateTime selectedDateTimeStart;
  final DateTime selectedDateTimeEnd;
  final Function(DateTime,DateTime) onChangeDate;
  final Widget titleWidget;

  CustomCalendarWidget({this.selectedDateTimeStart,this.selectedDateTimeEnd,this.onChangeDate,this.titleWidget = const Text("Calendar",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)});


  @override
  _CustomCalendarWidgetState createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {

  ScrollController _scrollController = ScrollController();

  DateTime _currentDateTime;
  DateTime _selectedDateTimeStart;
  DateTime _selectedDateTimeEnd;
  List<Calendar> _sequentialDates;
  bool isGetStartDate=true;
  bool isGetEndDate=true;

  bool isFullCalender=false;

  int midYear;
  CalendarViews _currentView = CalendarViews.dates;
  final List<String> _weekDays = [ 'Sun','Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<String> _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  void initState() {
    super.initState();
    final date = DateTime.now();

    if(widget.selectedDateTimeStart!=null){
      _selectedDateTimeStart = widget.selectedDateTimeStart;
      _currentDateTime = widget.selectedDateTimeStart;
    }else{
      _selectedDateTimeStart = DateTime(date.year, date.month, date.day);
      _currentDateTime = DateTime(date.year, date.month);
    }

    if(widget.selectedDateTimeEnd != null){
      _selectedDateTimeEnd = widget.selectedDateTimeEnd;
    }else{
      _selectedDateTimeEnd = DateTime(date.year, date.month, date.day);
    }

    if(_selectedDateTimeStart == _selectedDateTimeEnd){
      isGetEndDate = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      setState(() => _getCalendar());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  scrollChangeTo(double index){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.animateTo(index*48, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }
  @override
  Widget build(BuildContext context) {


    if(_selectedDateTimeEnd.difference(_selectedDateTimeStart).isNegative){
      throw("Start date should be smaller or equal than End Date");
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: _datesView(),
      //child: (_currentView == CalendarViews.dates) ? _datesView() : (_currentView == CalendarViews.months) ? _showMonthsList() : _yearsView(midYear ?? _currentDateTime.year)
    );
  }

  // dates view
  Widget _datesView(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // header

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            widget.titleWidget,
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  // prev month button
                  _toggleBtn(false),
                  SizedBox(width: 3,),

                  // month and year
                  Center(
                    child: Text(
                      '${_monthNames[_currentDateTime.month-1]}, ${_currentDateTime.year}',
                      style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: 3,),

                  // next month button
                  _toggleBtn(true),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Flexible(child: _calendarBody()),
      ],
    );
  }

  // next / prev month buttons
  Widget _toggleBtn(bool next) {
    return InkWell(
      onTap: (){
        if(_currentView == CalendarViews.dates){
          setState(() => (next) ? _getNextMonth() : _getPrevMonth());
        }
        else if(_currentView == CalendarViews.year){
          if(next){
            midYear = (midYear == null) ? _currentDateTime.year + 9 : midYear + 9;
          }
          else{
            midYear = (midYear == null) ? _currentDateTime.year - 9 : midYear - 9;
          }
          setState(() {});
        }
      },
      child: Container(height:30,width: 25,child: Icon((next) ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded, color: Colors.black,size: 20,)),
    );
  }

  // calendar
  Widget _calendarBody() {
    if(_sequentialDates == null) return Container();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(!isFullCalender)Container(
          height: 60,
          child: ListView.separated(
            controller: _scrollController,
            separatorBuilder: (context,index)=>SizedBox(width: 8,),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _sequentialDates.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              //if(index < 7) return _weekDayTitle(index);

              if(_selectedDateTimeStart == _sequentialDates[index].date){
                scrollChangeTo(index.toDouble());
              }

              if((!_sequentialDates[index].date.difference(_selectedDateTimeStart).isNegative && _sequentialDates[index].date.difference(_selectedDateTimeEnd).isNegative) || _selectedDateTimeStart == _sequentialDates[index].date || _sequentialDates[index].date == _selectedDateTimeEnd)
                return _selector(_sequentialDates[index]);
              return _calendarDates(_sequentialDates[index]);
            },
          ),
        ),

        if(isFullCalender)SwipeGestureRecognizer(
          onSwipeLeft: (){
            setState(() {
              _getNextMonth();
            });
          },
          onSwipeRight: (){
            setState(() {
              _getPrevMonth();
            });
          },
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _sequentialDates.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: .7,
              mainAxisSpacing: 8,
              crossAxisCount: 7,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index){
              //if(index < 7) return _weekDayTitle(index);
              if((!_sequentialDates[index].date.difference(_selectedDateTimeStart).isNegative && _sequentialDates[index].date.difference(_selectedDateTimeEnd).isNegative) || _selectedDateTimeStart == _sequentialDates[index].date || _sequentialDates[index].date == _selectedDateTimeEnd)
                return _selector(_sequentialDates[index]);
              return _calendarDates(_sequentialDates[index]);
            },
          ),
        ),

        SizedBox(height: 2,),
        InkWell(
          onTap: (){
            setState(() {
              isFullCalender = !isFullCalender;
            });
          },
          child: Icon(isFullCalender?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,size: 30,))
      ],
    );
  }

  // // calendar header
  // Widget _weekDayTitle(int index){
  //   return Text(_weekDays[index], style: TextStyle(color: Colors.yellow, fontSize: 12),);
  // }

  // calendar element
  Widget _calendarDates(Calendar calendarDate){
    return InkWell(
      onTap: (){
          if(calendarDate.nextMonth){
            _getNextMonth();
          }
          else if(calendarDate.prevMonth){
            _getPrevMonth();
          }
          setState((){
            if((!isGetStartDate&&!isGetEndDate) || (isGetStartDate&&isGetEndDate)) {
              _selectedDateTimeEnd = calendarDate.date;
              _selectedDateTimeStart = calendarDate.date;
              isGetStartDate = true;
              isGetEndDate = false;
            }else{

              if(calendarDate.date.difference(_selectedDateTimeStart).isNegative){
                _selectedDateTimeEnd = calendarDate.date;
                _selectedDateTimeStart = calendarDate.date;
                isGetStartDate = true;
                isGetEndDate = false;
              }else{
                _selectedDateTimeEnd = calendarDate.date;
                isGetEndDate = true;
              }
            }

            if(widget.onChangeDate != null){
              widget.onChangeDate(_selectedDateTimeStart,_selectedDateTimeEnd);
            }

          });
      },
      child: Center(
        child: Container(
          padding: EdgeInsets.all(3),
          margin: EdgeInsets.all(2),
          height: 60,
          width: 40,
          decoration: BoxDecoration(
            color: Color(0xFFD2D8CF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${calendarDate.date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: (calendarDate.thisMonth) ? Colors.black : Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 5,),
              Text(
                '${_weekDays[calendarDate.date.weekday%7]}',
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: (calendarDate.thisMonth) ? Colors.black : Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // date selector
  Widget _selector(Calendar calendarDate) {
    return InkWell(
      onTap: (){
          if(calendarDate.nextMonth){
            _getNextMonth();
          }
          else if(calendarDate.prevMonth){
            _getPrevMonth();
          }
          setState((){
            if((!isGetStartDate&&!isGetEndDate) || (isGetStartDate&&isGetEndDate)) {
              _selectedDateTimeEnd = calendarDate.date;
              _selectedDateTimeStart = calendarDate.date;
              isGetStartDate = true;
              isGetEndDate = false;
            }else{
              _selectedDateTimeEnd = calendarDate.date;
              isGetEndDate = true;
            }
            print("Selected Date Time $_selectedDateTimeStart");
          });
      },
      child: Center(
        child: Container(
          padding: EdgeInsets.all(3),
          margin: EdgeInsets.all(2),
          height: 60,
          width: 40,
          decoration: BoxDecoration(
            color: calendarDate.date == _selectedDateTimeStart || calendarDate.date == _selectedDateTimeEnd? Color(0xFF69CC69): Color(0xFF69CC69).withOpacity(.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${calendarDate.date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: (calendarDate.thisMonth) ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 5,),
              Text(
                '${_weekDays[calendarDate.date.weekday%7]}',
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: (calendarDate.thisMonth) ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // get next month calendar
  void _getNextMonth(){
    if(_currentDateTime.month == 12) {
      _currentDateTime = DateTime(_currentDateTime.year+1, 1);
    }
    else{
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month+1);
    }

    scrollChangeTo(0);
    _getCalendar();
  }

  // get previous month calendar
  void _getPrevMonth(){
    if(_currentDateTime.month == 1){
      _currentDateTime = DateTime(_currentDateTime.year-1, 12);
    }
    else{
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month-1);
    }
    scrollChangeTo(0);
    _getCalendar();
  }

  // get calendar for current month
  void _getCalendar(){
    _sequentialDates = CustomCalendar().getMonthCalendar(_currentDateTime.month, _currentDateTime.year, startWeekDay: StartWeekDay.sunday);
  }

  // show months list
  Widget _showMonthsList(){
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => _currentView = CalendarViews.year),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('${_currentDateTime.year}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),),
          ),
        ),
        Divider(color: Colors.white,),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _monthNames.length,
            itemBuilder: (context, index) => ListTile(
              onTap: (){
                _currentDateTime = DateTime(_currentDateTime.year, index+1);
                _getCalendar();
                setState(() => _currentView = CalendarViews.dates);
              },
              title: Center(
                child: Text(
                  _monthNames[index],
                  style: TextStyle(fontSize: 18, color: (index == _currentDateTime.month-1) ? Colors.yellow : Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // years list views
  Widget _yearsView(int midYear){
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _toggleBtn(false),
            Spacer(),
            _toggleBtn(true),
          ],
        ),
        Expanded(
          child: GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index){
                int thisYear;
                if(index < 4){
                  thisYear = midYear - (4 - index);
                }
                else if(index > 4){
                  thisYear = midYear + (index - 4);
                }
                else{
                  thisYear = midYear;
                }
                return ListTile(
                  onTap: (){
                    _currentDateTime = DateTime(thisYear, _currentDateTime.month);
                    _getCalendar();
                    setState(() => _currentView = CalendarViews.months);
                  },
                  title: Text(
                    '$thisYear',
                    style: TextStyle(fontSize: 18, color: (thisYear == _currentDateTime.year) ? Colors.yellow : Colors.white),
                  ),
                );
              }
          ),
        ),
      ],
    );
  }
}
