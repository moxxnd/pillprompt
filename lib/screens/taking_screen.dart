import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TakingScreen extends StatefulWidget {
  const TakingScreen({Key? key}) : super(key: key);

  @override
  TakingScreenState createState() => TakingScreenState();
}

class TakingScreenState extends State<TakingScreen> {
  late String _selectedTime;
  Map<String, bool> pillStatus = {
    "morning": false,
    "lunch": false,
    "dinner": false,
  };
  List<String> pillList = [];
  Map<String, bool> _selectedItems = {};

  int _hour = 0;
  int _minute = 0;
  int _second = 0;
  late String _displayHour;
  late String _displayMinute;
  late String _displaySecond;

  @override
  void initState() {
    super.initState();
    _selectedTime = "아침";
    _displayHour = '';
    _displayMinute = '';
    _displaySecond = '';
    onTimeButtonPressed("아침");
  }

  void onTimeButtonPressed(String time) {
    if (time == "아침") {
      time = "morning";
    } else if (time == "점심") {
      time = "lunch";
    } else if (time == "저녁") {
      time = "dinner";
    } else {
      return;
    }
    setState(() {
      _selectedTime = time;
      _selectedItems.clear();
    });
    _fetchPillDataForSelectedTime(time);
    _updateSelectedTimeDisplay(time);
  }

  void _updateSelectedTimeDisplay(String time) {
    setState(() {
      _selectedTime = time;
    });
  }

  Future<void> _fetchPillDataForSelectedTime(String time) async {
    try {
      String apiUrl = "http://223.194.160.130/pills/by-time/$time";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final filteredPills = jsonData
            .where((pill) => (pill['times'] as List<dynamic>)
                .any((time) => _selectedTime == _convertTimeToKorean(time)))
            .toList();

        List<String> newPillList = [];
        Map<String, bool> newPillTakenStatus = {};

        for (var pill in filteredPills) {
          final pillName = pill['name'];
          newPillList.add(pillName);
          newPillTakenStatus[pillName] =
              pill['taken_${time.toLowerCase()}'] ?? false;
          // time 변수를 사용하여 pill 데이터를 가져오도록 수정
        }

        setState(() {
          pillList = newPillList;
          _selectedItems = newPillTakenStatus;
          _selectedTime = time; // 선택한 시간으로 UI 업데이트
        });

        Map<String, dynamic> takingTimeData = jsonData
            .firstWhere((element) => element['phase'] == time.toUpperCase(),
                orElse: () => {
                      'hour': 0,
                      'minute': 0,
                      'second': 0,
                    })
            .cast<String, dynamic>();

        setState(() {
          _hour = takingTimeData['hour'];
          _minute = takingTimeData['minute'];
          _second = takingTimeData['second'];
          _displayHour = _hour.toString().padLeft(2, '0');
          _displayMinute = _minute.toString().padLeft(2, '0');
          _displaySecond = '00';
        });
      } else {
        debugPrint('서버 응답: ${response.body}');

        for (var pillName in pillList) {
          debugPrint('$pillName: ${_selectedItems[pillName]}');
        }
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  String _convertTimeToKorean(String time) {
    switch (time) {
      case "MORNING":
        return "아침";
      case "LUNCH":
        return "점심";
      case "DINNER":
        return "저녁";
      default:
        return "";
    }
  }

  void _showTimeSettingModal() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _hour = pickedTime.hour;
        _minute = pickedTime.minute;
        _second = 0;
        _displayHour = _hour.toString().padLeft(2, '0');
        _displayMinute = _minute.toString().padLeft(2, '0');
        _displaySecond = '00';
        _savePillData(); // Save pill data when a time is selected.
      });
    }
  }

  Future<void> _savePillData() async {
    if (_selectedTime.isEmpty) {
      debugPrint('시간을 설정해주세요.');
      return;
    }
    if (pillList.isEmpty) {
      debugPrint('약 정보가 없습니다.');
      return;
    }
    try {
      String name;
      if (_selectedTime == "아침") {
        name = "morning";
      } else if (_selectedTime == "점심") {
        name = "lunch";
      } else if (_selectedTime == "저녁") {
        name = "dinner";
      } else {
        return;
      }
      String apiUrl = "http://3.37.208.162:8080/taking-time/$name/edit";

      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "hour": _hour,
          "minute": _minute,
          "second": _second,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('복용시간을 저장했습니다.');
        debugPrint(response.body);
      } else {
        debugPrint('${response.statusCode}');
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          '복용 현황',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: 240,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffeaeaea),
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                _showTimeSettingModal();
              },
              child: Text(
                "시간 설정: $_displayHour:$_displayMinute:$_displaySecond",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(0.2),
            height: 60,
            width: 240,
            decoration: const BoxDecoration(
              color: Color(0xffeaeaea),
              borderRadius: BorderRadius.all(
                Radius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildTimeButton("아침", "아침"),
                buildTimeButton("점심", "점심"),
                buildTimeButton("저녁", "저녁"),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pillList.length,
              itemBuilder: (context, index) {
                String pillName = pillList[index];
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xffeaeaea),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(pillName),
                    trailing: Icon(
                      Icons.check_circle_outline,
                      color: _selectedItems[pillName] == true
                          ? Colors.cyan
                          : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedItems[pillName] = !_selectedItems[pillName]!;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeButton(String time, String buttonText) {
    bool isSelected = false;

    if (_selectedTime == "morning" && time == "아침") {
      isSelected = true;
    } else if (_selectedTime == "lunch" && time == "점심") {
      isSelected = true;
    } else if (_selectedTime == "dinner" && time == "저녁") {
      isSelected = true;
    }

    return Container(
      margin: const EdgeInsets.all(7),
      child: ElevatedButton(
        onPressed: () {
          onTimeButtonPressed(time);
        },
        style: ButtonStyle(
          padding: const MaterialStatePropertyAll(EdgeInsets.all(12)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            isSelected || _selectedTime == time ? Colors.cyan : Colors.white,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 17,
              color: isSelected || _selectedTime == time
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
