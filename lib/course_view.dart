import 'package:eee/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CourseView extends StatefulWidget {
  const CourseView({super.key});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  TimeOfDay? pickedTime;
  var listViewItems = List.filled(1, ListViewItem(), growable: true);

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
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "Course ID",
              ),
            ),
            TextField(
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
                        onPressed: () => setState(() {
                          listViewItems.removeAt(index);
                        }),
                      ),
                      // const SizedBox(width: 20,),
                      DropdownButton(
                        borderRadius: BorderRadius.circular(10),
                        hint: const Text("WeekDay"),
                        value: listViewItems[index].dropdownValue,
                        items: weekDays.map((dow) => DropdownMenuItem(
                          value: dow,
                          child: Text(dow),
                        )).toList(),
                        onChanged: (value) => setState(() {
                          listViewItems[index].dropdownValue = value;
                        }),
                      ),
                      // const SizedBox(width: 20,),
                      SizedBox(
                        width: 90,
                        child: Column(
                          children: [
                            TextField(
                              controller: TextEditingController(
                                text: listViewItems[index].textStartTime,
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
                                  listViewItems[index].textStartTime = pickedTime!.format(context);
                                });
                              },
                            ),
                            TextField(
                              controller: TextEditingController(
                                text: listViewItems[index].textEndTime,
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
                                  listViewItems[index].textEndTime = pickedTime!.format(context);
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
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            listViewItems.add(ListViewItem());
          });
        },
      ),
    );
  }
}