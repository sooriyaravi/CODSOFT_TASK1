import 'package:alarmapp/alarmringingpage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alarmapp/alarmhelper.dart';

class Alarmpage extends StatefulWidget {
  const Alarmpage({super.key});

  @override
  State<Alarmpage> createState() => _AlarmpageState();
}

class _AlarmpageState extends State<Alarmpage> {
  String currentTime = '';
  String currentDate = '';
  TimeOfDay? AlarmTime;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AlarmHelper alarmHelper = AlarmHelper();
  List<bool> alarmStatus = [];
  List<String> selectedRingtones = [];
  List<TimeOfDay> alarms = [];

  final List<String> ringtones = ['alarm.mp3', 'alarm1.mp3', 'alarm2.mp3'];
  @override
  void initState() {
    super.initState();
    alarmHelper.initializeNotifications();
    updatetime();
  }

  void updatetime() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        DateTime now = DateTime.now();
        currentTime = DateFormat('hh:mm:ss a').format(now);
        currentDate = DateFormat('MMM d,EEE,yyyy').format(now);
        checkAlarm(now);
      });
    });
  }

  void checkAlarm(DateTime now) {
    for (int i = 0; i < alarms.length; i++) {
      if (alarmStatus[i]) {
        final alarm = alarms[i];
        if (alarm.hour == now.hour && alarm.minute == now.minute) {
          playRingtone(selectedRingtones[i]);
          showAlarmDialog(alarm);
          setState(() {
            alarmStatus[i] = false;
          });
        }
      }
    }
  }

  void showAlarmDialog(TimeOfDay alarm) {
    String formattedTime = alarm.format(context);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            AlarmRingPage(alarmTime: formattedTime, onSnooze: () {})));
  }

  Future<void> playRingtone(String ringtone) async {
    await _audioPlayer.play(AssetSource(ringtone));
    Future.delayed(Duration(seconds: 60), () {
      stopRingtone();
    });
  }

  Future<void> stopRingtone() async {
    await _audioPlayer.stop();
  }

  void scheduleAlarm(TimeOfDay selectedTime, String ringtone) {
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(
        now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }
    selectedRingtones.add(ringtone);
    String alarmLabel = "Alarm at ${selectedTime.format(context)}";
    alarmHelper.scheduleAlarm(scheduledTime, alarmLabel);
  }

  void alarmpicker(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      String? selectedRingtone = await ringtonePicker(context);
      if (selectedRingtone != null) {
        setState(() {
          alarms.add(selectedTime);
          alarmStatus.add(true);
        });
        scheduleAlarm(selectedTime, selectedRingtone);
      }
    }
  }

  Future<String?> ringtonePicker(BuildContext context) async {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Ringtone'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: ringtones.map((ringtone) {
                return ListTile(
                  title: Text(ringtone),
                  onTap: () {
                    Navigator.of(context).pop(ringtone);
                  },
                );
              }).toList(),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black45,
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 30.0),
                child: Text(currentTime,
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white)),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                child: Text(
                  currentDate,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: alarms.isEmpty
                    ? const Center(
                        child: Text(
                          'no Alarm set',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = alarms[index];
                          return Column(
                            children: [
                              Dismissible(
                                key: Key(alarms.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  setState(() {
                                    alarms.removeAt(index);
                                    alarmStatus.removeAt(index);
                                    selectedRingtones.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Alarm deleted'),
                                  ));
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.white.withOpacity(0.2))
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Ring in :${alarm.format(context)}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w200,
                                              color: Colors.white),
                                        ),
                                      ),
                                      Text(
                                        selectedRingtones[index],
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14),
                                      ),
                                      Switch(
                                        value: alarmStatus[index],
                                        inactiveTrackColor:
                                            Colors.grey.shade400,
                                        activeTrackColor:
                                            Colors.red.withOpacity(0.5),
                                        onChanged: (bool value) {
                                          setState(() {
                                            alarmStatus[index] = value;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        alarmpicker(context);
      },
      backgroundColor: Colors.white.withOpacity(0.2),
      elevation:0,
      shape: const CircleBorder(),
      child:const Icon(
        Icons.add,
        size:40,
        color:Colors.white,
      ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

