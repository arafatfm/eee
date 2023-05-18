import 'package:eee/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 
// ignore: must_be_immutable
class CourseView extends StatefulWidget {
  String? viewId;
  CourseView({super.key});
  CourseView.a(this.viewId, {super.key});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  TimeOfDay? pickedTime;
  var listViewItems = List.filled(1, Duration(), growable: true);
  String _id = "", _credit = "";

  @override
  void initState() {
    super.initState();
    
    if(widget.viewId != null) {
      var course = courses[courses.indexWhere((element) => element.id == widget.viewId)];
      _id = course.id;
      _credit = course.credit.toString();
      listViewItems = course.duration;
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Info"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            deleteCourse();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if(_id.isEmpty || _credit.isEmpty) return;
              if(listViewItems.isEmpty) return;
              for(var item in listViewItems) {
                if(item.weekDay == null) return;
                if(item.startTime.isEmpty || item.endTime.isEmpty) return;
              }
              var index = courses.indexWhere((course) => _id.contains(course.code));
              if(index == -1) {
                createCourse();
              } else {
                updateCourse(index);
              }
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: TextEditingController(
              text: _id,
            ),
            onChanged: (value) {
              _id = value;
            },
            decoration: const InputDecoration(
              labelText: "Course ID",
            ),
          ),
          TextField(
            controller: TextEditingController(
              text: _credit,
            ),
            onChanged: (value) {
              _credit = value;
            },
            decoration: const InputDecoration(
              labelText: "Course Credit",
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: listViewItems.length,
            itemBuilder: (context, index) => Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if(listViewItems.length > 1) {
                          setState(() {
                            listViewItems.removeAt(index);
                          });
                        }
                      },
                    ),
                    // const SizedBox(width: 20,),
                    DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      hint: const Text("WeekDay"),
                      value: listViewItems[index].weekDay,
                      items: weekDays.map((dow) => DropdownMenuItem(
                        value: dow,
                        child: Text(dow),
                      )).toList(),
                      onChanged: (value) => setState(() {
                        listViewItems[index].weekDay = value as String?;
                      }),
                    ),
                    // const SizedBox(width: 20,),
                    SizedBox(
                      width: 90,
                      child: Column(
                        children: [
                          TextField(
                            controller: TextEditingController(
                              text: listViewItems[index].startTime,
                            ),
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Start Time",
                            ),
                            onTap: () async {
                              pickedTime = await showTimePicker(
                                context: context, 
                                initialTime: TimeOfDay.now(),
                              );
                              setState(() {
                                listViewItems[index].startTime = pickedTime!.format(context).padLeft(8, '0');
                              });
                            },
                          ),
                          TextField(
                            controller: TextEditingController(
                              text: listViewItems[index].endTime,
                            ),
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "End Time"
                            ),
                            onTap: () async {
                              pickedTime = await showTimePicker(
                                context: context, 
                                initialTime: TimeOfDay.now(),
                              );
                              setState(() {
                                listViewItems[index].endTime = pickedTime!.format(context).padLeft(8,'0');
                              });
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            listViewItems.add(Duration());
          });
        },
      ),
    );
  }
  void createCourse() {
    var course = Course(_id ,int.parse(_credit), listViewItems);
    courses.add(course);
  }
  void deleteCourse() {
    courses.removeWhere((course) => _id.contains(course.code));
  }
  void updateCourse(int index) {
    courses[index].credit = int.parse(_credit);
    courses[index].duration = listViewItems;
  }
}
