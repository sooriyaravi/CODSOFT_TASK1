import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmRingPage extends StatefulWidget {
  final String alarmTime;
  const AlarmRingPage(
      {Key? key, required this.alarmTime, required Null Function() onSnooze})
      : super(key: key);

  @override
  State<AlarmRingPage> createState() => _AlarmRingPageState();
}

class _AlarmRingPageState extends State<AlarmRingPage> {
  double _dragPosition = 0.0;
  Timer? _snoozeTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final double dragThreshold = 100.0;
  @override
  void dispose() {
    _snoozeTimer?.cancel();
    super.dispose();
  }

  Future<void> stopRingtone() async {
    await _audioPlayer.stop();
  }

  void _startSnoozeTimer() {
    _snoozeTimer = Timer(const Duration(minutes: 2), () {
      setState(() {
        _showAlarmRinging();
      });
    });
  }

  void _showAlarmRinging() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alarm is ringing again after snoozed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.6),
              ),
              child: const Icon(
                Icons.alarm,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text('Alarm is ringing!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Time:${widget.alarmTime}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30.0),
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(35)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          'snooze',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Text(
                          'Stop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition += details.delta.dx;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition > dragThreshold) {
                      Navigator.pop(context);
                      stopRingtone();
                    } else if (_dragPosition < -dragThreshold) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Snoozed')),
                      );
                      setState(() {});
                      _startSnoozeTimer();
                    }
                    setState(() {
                      _dragPosition = 0.0;
                    });
                  },
                  child: Transform.translate(
                    offset: Offset(_dragPosition, 0),
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.alarm,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
