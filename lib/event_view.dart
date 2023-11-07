import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eee/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventView extends StatefulWidget {
  final DateTime date;
  final String docId;
  const EventView({
    required this.date,
    this.docId = '',
    super.key,
  });

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final db = FirebaseFirestore.instance.collection('events');
  final courseStream = FirebaseFirestore.instance
      .collection('root')
      .doc('courses')
      .snapshots()
      .distinct();
  final eventNameController = TextEditingController();
  String? pickedTime;
  late DateTime pickedDate = widget.date;

  @override
  void initState() {
    super.initState();
    if(widget.docId.isNotEmpty) {
      var event = eventDB.firstWhere((element) => element['docId'] == widget.docId,);
      eventNameController.text = event['name'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        centerTitle: true,
        actions: [
          Visibility(
            visible: widget.docId.isNotEmpty,
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Navigator.pop(context);
                db.doc(widget.docId).delete();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(DateFormat('EEEE, MMM d').format(pickedDate)),
            onTap: () async{
              var date = await showDatePicker(
                  context: context,
                  initialDate: widget.date,
                  firstDate: DateTime.utc(2010),
                  lastDate: DateTime.utc(2040));
              setState(() {
                pickedDate = date!;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: eventNameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Event Name',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete(
                  optionsBuilder: (textEditingValue) {
                    if(textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return events.where((element) => element
                          .toLowerCase()
                          .contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                      );
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      focusNode: focusNode,
                      controller: textEditingController,
                      onFieldSubmitted: (value) => onFieldSubmitted,
                      decoration: const InputDecoration(
                        hintText: 'Event Type',
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 56*3,
                              maxWidth: constraints.maxWidth,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  onTap: () {
                                    return onSelected(option);
                                  },
                                  title: Text(option),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },

                );
              }
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                syncCourses();
                return Autocomplete(
                  optionsBuilder: (textEditingValue) {
                    if(textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return courses.where((element) => element
                          .toLowerCase()
                          .contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                      );
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      focusNode: focusNode,
                      controller: textEditingController,
                      onFieldSubmitted: (value) => onFieldSubmitted,
                      decoration: const InputDecoration(
                        hintText: 'Course ID',
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 56*3,
                              maxWidth: constraints.maxWidth,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  onTap: () {
                                    return onSelected(option);
                                  },
                                  title: Text(option),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },

                );
              }
            ),
          ),
          const SizedBox(height: 12),
          
          ListTile(
            onTap: () async{
              var time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              var timeString = time != null && context.mounted
                  ? time.format(this.context).padLeft(8, '0')
                  : '';
              if(timeString.isNotEmpty) {
                if(slots.contains(timeString)) {
                  setState(() {
                    pickedTime = timeString;
                  });
                } else {
                  tempSlots = List.from(slots);
                  setState(() {
                    tempSlots.insert(0, timeString);
                    pickedTime = timeString;
                  }); 
                }
              }
            },
            leading: const Icon(Icons.access_time_filled),
            title: const Text('Set Time'),
            trailing: InkWell(
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton(
                    borderRadius: BorderRadius.circular(16),
                    value: pickedTime,
                    items: tempSlots.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        pickedTime = value as String?;
                      });
                    },
                    hint: const Text('None'),
                  ),
                ),
              ),
              onLongPress: () {
                tempSlots = List.from(slots);
                setState(() {
                  pickedTime = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> courses = List.empty(growable: true);
  syncCourses() async{
    var list = List<String>.empty(growable: true);
    var db = FirebaseFirestore.instance.collection('root').doc('courses');
    await db.get().then((value) {
      if(value.data() != null) {
        value.data()!.forEach((key, value) {
          list.add(value['id']);
        });
      }
    });
    courses = list;
  }

  var events = ['CT','Assignment','Lab Report'];
  Iterable slots = [
    '09:00 AM',
    '09:45 AM',
    '10:30 AM',
    '11:30 AM',
    '12:15 PM',
    '02:00 PM',
  ];
  late var tempSlots = List.from(slots);

  @override
  void dispose() {
    var doc = {
      'name': eventNameController.text,
      'date': DateFormat('yyyy-MM-d').format(pickedDate),
    };
    
    if(eventNameController.text.isNotEmpty) {
      if(widget.docId.isEmpty) {
        db.add(doc).then((docRef) {
          docRef.update({'docId': docRef.id});
        });
      } else {
        db.doc(widget.docId).update(doc);
      }
    }
    super.dispose();
  }
}