// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eee/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

final coursesStream =
    FirebaseFirestore.instance.collection('courses').snapshots().distinct();

class CourseView extends StatefulWidget {
  final String ref;
  const CourseView({
    this.ref = '',
    super.key,
  });

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  final idController = TextEditingController();
  final creditController = TextEditingController();
  var listViewItems = List.filled(1, Period(), growable: true);
  int listLength = 1;
  late final ValueNotifier<int> valueListener;
  final db = FirebaseFirestore.instance.collection('courses');

  @override
  void initState() {
    super.initState();
    valueListener = ValueNotifier(listLength);
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
            if (widget.ref.isEmpty) return;
            deleteCourse();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (idController.text.isEmpty || creditController.text.isEmpty) {
                emptyFieldAlert();
                return;
              }
              for (var item in listViewItems) {
                if (item.weekDay == null ||
                    item.getStartTime().isEmpty ||
                    item.getEndTime().isEmpty) {
                  emptyFieldAlert();
                  return;
                }
              }
              if (widget.ref.isNotEmpty) {
                updateCourse();
                Navigator.pop(context);
                return;
              }

              db.get().then((snapshot) {
                for (QueryDocumentSnapshot docSnapshot in snapshot.docs) {
                  if (idController.text.contains(docSnapshot['code'])) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text('Course already exists'),
                      ));
                    return;
                  }
                }
                createCourse();
                Navigator.pop(context);
              });
            },
          )
        ],
      ),
      body: StreamBuilder(
          stream: coursesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                heightFactor: 5,
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData) {
              return const Text('No data');
            }

            if (widget.ref.isNotEmpty) {
              var course = snapshot.data!.docs
                  .firstWhereOrNull((docSnap) => docSnap.id == widget.ref);   //added package:collection only for this funcion
              if (course != null) {
                idController.text = course['id'];
                creditController.text = course['credit'].toString();
                List<Period> list = List.empty(growable: true);
                for (Map<String, dynamic> time in course['time']) {
                  list.add(Period.fromJson(time));
                }
                listViewItems = list;
                updateUI();
              }
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: "Course ID",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: creditController,
                    decoration: const InputDecoration(
                      labelText: "Course Credit",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ValueListenableBuilder(
                          valueListenable: valueListener,
                          builder: (context, value, child) {
                            return ListView.separated(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 16,
                                // bottom: 8,
                              ),
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: listViewItems.length,
                              itemBuilder: (context, index) {
                                var startTimePicker =
                                    (listViewItems[index].startTime != null)
                                        ? listViewItems[index].startTime
                                        : TimeOfDay.now();
                                var endTimePicker =
                                    (listViewItems[index].endTime != null)
                                        ? listViewItems[index].endTime
                                        : TimeOfDay.now();

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        if (listViewItems.length > 1) {
                                          listViewItems.removeAt(index);
                                          updateUI();
                                        }
                                      },
                                    ),
                                    StatefulBuilder(
                                        builder: (context, setState) {
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          // underline: const SizedBox(),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          hint: const Text("WeekDay"),
                                          value: listViewItems[index].weekDay,
                                          items: weekDays
                                              .map((dow) => DropdownMenuItem(
                                                    value: dow,
                                                    child: Text(dow),
                                                  ))
                                              .toList(),
                                          onChanged: (value) => setState(() {
                                            listViewItems[index].weekDay =
                                                value as String?;
                                          }),
                                        ),
                                      );
                                    }),
                                    // const SizedBox(
                                    //   //empty space
                                    //   width: 20,
                                    // ),
                                    SizedBox(
                                      width: 80,
                                      child: Column(
                                        children: [
                                          StatefulBuilder(
                                              builder: (context, setState) {
                                            return TextField(
                                              controller: TextEditingController(
                                                text: listViewItems[index]
                                                    .getStartTime(),
                                              ),
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                labelText: "Start Time",
                                              ),
                                              onTap: () async {
                                                var pickedTime =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime: startTimePicker!,
                                                );
                                                setState(() {
                                                  if (pickedTime != null) {
                                                    listViewItems[index]
                                                        .startTime = pickedTime;
                                                  }
                                                });
                                              },
                                            );
                                          }),
                                          StatefulBuilder(
                                              builder: (context, setState) {
                                            return TextField(
                                              controller: TextEditingController(
                                                text: listViewItems[index]
                                                    .getEndTime(),
                                              ),
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                labelStyle: TextStyle(),
                                                border: InputBorder.none,
                                                labelText: "End Time",
                                              ),
                                              onTap: () async {
                                                var pickedTime =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime: endTimePicker!,
                                                );
                                                setState(() {
                                                  if (pickedTime != null) {
                                                    listViewItems[index]
                                                        .endTime = pickedTime;
                                                  }
                                                });
                                              },
                                            );
                                          })
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
                              separatorBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                return const Divider(
                                  thickness: 0.75,
                                  indent: 30,
                                  endIndent: 20,
                                );
                              },
                            );
                          }),
                    ),
                  ),
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          listViewItems.add(Period());
          updateUI();
        },
      ),
    );
  }

  void updateUI() {
    valueListener.value = listViewItems.length;
  }

  void createCourse() {
    List list = List.empty(growable: true);
    for (Period period in listViewItems) {
      list.add(period.toJson());
    }
    db.doc(idController.text).set({
      'id': idController.text,
      'credit': int.parse(creditController.text),
      'code': idController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      'time': list,
    }).onError((error, stackTrace) => print('error $error'));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Course create success'),
    ));
  }

  void deleteCourse() {
    db.doc(idController.text).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Course delete success'),
    ));
  }

  void updateCourse() {
    List list = List.empty(growable: true);
    for (Period period in listViewItems) {
      list.add(period.toJson());
    }
    db.doc(idController.text).update({
      'credit': int.parse(creditController.text),
      'time': list,
    });
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
