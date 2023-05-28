// ignore_for_file: avoid_print, void_checks

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eee/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CourseView extends StatefulWidget {
  final String? viewId;
  const CourseView({this.viewId, super.key});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  final idController = TextEditingController();
  final creditController = TextEditingController();
  var listViewItems = List.filled(1, Duration(), growable: true);

  @override
  void initState() {
    super.initState();

    if (widget.viewId != null) {
      var course =
          courses[courses.indexWhere((element) => element.id == widget.viewId)];
      idController.text = course.id;
      creditController.text = course.credit.toString();
      listViewItems = course.duration;
    }
  }

  syncToFF() async {
    var docRef = FirebaseFirestore.instance.collection('root').doc('courses');
    var coursesJson = {
      for (var i = 0; i < courses.length; i++)
        '${courses[i].myId} $i': courses[i].toJson()
    };
    await docRef
        .set(coursesJson)
        .then((value) => print('Set doc success'))
        .catchError((error) => print('Failed to set data: $error'));
  }

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 125;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Info"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            if (widget.viewId == null) return;
            deleteCourse();
            Navigator.pop(context);
            syncToFF();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (idController.text.isEmpty || creditController.text.isEmpty) {
                return emptyFieldAlert();
              }
              if (listViewItems.isEmpty) return emptyFieldAlert();
              for (var item in listViewItems) {
                if (item.weekDay == null) return emptyFieldAlert();
                if (item.getStartTime().isEmpty || item.getEndTime().isEmpty) {
                  return emptyFieldAlert();
                }
              }
              if (widget.viewId != null) {
                updateCourse();
              } else if (!courses
                  .any((course) => idController.text.contains(course.code))) {
                createCourse();
              } else {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Course already exists'),
                  ));
                return;
              }
              Navigator.pop(context);
              syncToFF();
            },
          )
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: "Course ID",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: creditController,
                decoration: const InputDecoration(
                  labelText: "Course Credit",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 1,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: itemHeight * 3.6,
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: listViewItems.length,
                  itemBuilder: (context, index) {
                    var startTimePicker =
                        (listViewItems[index].startTime != null)
                            ? listViewItems[index].startTime
                            : TimeOfDay.now();
                    var endTimePicker = (listViewItems[index].endTime != null)
                        ? listViewItems[index].endTime
                        : TimeOfDay.now();

                    return SizedBox(
                      height: itemHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                if (listViewItems.length > 1) {
                                  setState(() {
                                    listViewItems.removeAt(index);
                                  });
                                }
                              },
                            ),
                            DropdownButton(
                              borderRadius: BorderRadius.circular(10),
                              hint: const Text("WeekDay"),
                              value: listViewItems[index].weekDay,
                              items: weekDays
                                  .map((dow) => DropdownMenuItem(
                                        value: dow,
                                        child: Text(dow),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(() {
                                listViewItems[index].weekDay = value as String?;
                              }),
                            ),
                            const SizedBox(
                              //empty space
                              width: 20,
                            ),
                            SizedBox(
                              width: 90,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: TextEditingController(
                                      text: listViewItems[index].getStartTime(),
                                    ),
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Start Time",
                                    ),
                                    onTap: () async {
                                      var pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: startTimePicker!,
                                      );
                                      setState(() {
                                        if (pickedTime != null) {
                                          listViewItems[index].startTime =
                                              pickedTime;
                                        }
                                      });
                                    },
                                  ),
                                  TextField(
                                    controller: TextEditingController(
                                      text: listViewItems[index].getEndTime(),
                                    ),
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        labelText: "End Time"),
                                    onTap: () async {
                                      var pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: endTimePicker!,
                                      );
                                      setState(() {
                                        if (pickedTime != null) {
                                          listViewItems[index].endTime =
                                              pickedTime;
                                        }
                                      });
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
    var course = Course(
      id: idController.text,
      credit: int.parse(creditController.text),
      duration: listViewItems,
    );
    courses.add(course);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Course create success'),
    ));
  }

  void deleteCourse() {
    courses.removeWhere((course) => course.id == widget.viewId);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Course delete success'),
    ));
  }

  void updateCourse() {
    int index = courses.indexWhere((course) => course.id == widget.viewId);
    courses[index].credit = int.parse(creditController.text);
    courses[index].duration = listViewItems;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Course update success'),
    ));
  }

  emptyFieldAlert() => {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Complete all fields'),
          ))
      };
}
