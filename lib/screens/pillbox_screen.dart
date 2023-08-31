import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/pill.dart';
import '../widget/pillform.dart';

class PillBoxScreen extends StatefulWidget {
  const PillBoxScreen({Key? key}) : super(key: key);

  @override
  State<PillBoxScreen> createState() => PillBoxScreenState();
}

class PillBoxScreenState extends State<PillBoxScreen> {
  List<Pill> pillList = [];
  bool isLoading = true;
  bool isEditing = false; // 수정 버튼 상태
  int? pillid;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // 로딩 상태 변경
    });
    var url = Uri.parse("http://172.20.10.6:8080/pills");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));

        if (jsonData != null && jsonData is List) {
          List<Pill> tempList = [];
          for (var item in jsonData) {
            var quantity = item['quantity'] as int? ?? 0;
            var timesData = item['times'] as List<dynamic>? ?? [];
            List<String> times =
                timesData.map((time) => time.toString()).toList();
            tempList.add(Pill(
              id: item['id'],
              name: item['name'],
              quantity: quantity,
              times: times,
            ));
          }
          setState(() {
            pillList = tempList;
          });
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  Future<void> postData(String name, int quantity, List<String> times) async {
    var url = Uri.parse("http://172.20.10.6:8080/pills");

    try {
      var convertedTimes = times.map((time) {
        if (time == '아침') {
          return 'MORNING';
        } else if (time == '점심') {
          return 'LUNCH';
        } else if (time == '저녁') {
          return 'DINNER';
        }
        return '';
      }).toList();

      var body = json.encode({
        'name': name,
        'quantity': quantity,
        'times': convertedTimes,
      });

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchData();
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  Future<void> deleteData(int id) async {
    var url = Uri.parse("http://172.20.10.6:8080/pills/$id");

    try {
      var response = await http.delete(url);
      if (response.statusCode == 200 || response.statusCode == 204) {
        fetchData();
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  void showPillForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '약 정보 입력',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: PillForm(
            onSave: (name, quantity, times) {
              postData(name, quantity, times);
            },
            initialName: '', // 초기값을 지정해주세요
            initialQuantity: 0, initialTimes: const [],
          ),
        );
      },
    );
  }

  void showPillInfo(String name, int quantity) {
    // ignore: prefer_typing_uninitialized_variables
    var selectedPill;
    for (var pill in pillList) {
      if (pill.name == name && pill.quantity == quantity) {
        selectedPill = pill;
        break;
      }
    }

    if (selectedPill != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('약 정보'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('약 이름: ${selectedPill.name}'),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '개수: ${selectedPill.quantity}',
                    style: TextStyle(
                      color: selectedPill.quantity == 0 ? Colors.red : null,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('복용 시간:'),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selectedPill.times.contains('아침'))
                        buildTimeButton('아침', selectedPill),
                      const SizedBox(width: 10),
                      if (selectedPill.times.contains('점심'))
                        buildTimeButton('점심', selectedPill),
                      const SizedBox(width: 10),
                      if (selectedPill.times.contains('저녁'))
                        buildTimeButton('저녁', selectedPill),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('약 정보 수정'),
                            content: PillForm(
                              initialName: selectedPill.name,
                              initialQuantity: selectedPill.quantity,
                              initialTimes: const [], // 기존 약의 시간 정보를 초기값으로 설정
                              onSave: (name, quantity, times) {
                                editPillData(name, quantity, selectedPill.id);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      '수정',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                    ),
                    child: const Text('닫기'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  Widget buildTimeButton(String time, Pill selectedPill) {
    final isSelected = selectedPill.times.contains(time);
    const cyanColor = Colors.cyan;
    const defaultColor = Color(0xffeaeaea);

    return ElevatedButton(
      onPressed: () {
        // 복용 시간 버튼 누를 때 처리
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isSelected ? cyanColor : defaultColor,
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  void onDeletePill(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('약 삭제'),
          content: const Text('정말로 이 약을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                deleteData(id);
                Navigator.pop(context);
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> editPillData(String name, int quantity, int id) async {
    var url = Uri.parse("http://3.37.208.162:8080/pills/$id");

    try {
      var body = json.encode({
        'name': name,
        'quantity': quantity,
      });

      var response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        fetchData();
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          '약 보관함',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                  // 수정 버튼 상태 변경
                });
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  isEditing ? '완료' : '수정',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pillList.length,
                itemBuilder: (context, index) {
                  var pill = pillList[index];
                  var name = pill.name;
                  var textColor =
                      pill.quantity == 0 ? Colors.red : Colors.black;

                  return Container(
                    alignment: Alignment.center,
                    width: 200,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xffeaeaea),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isEditing)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                onDeletePill(pill.id); // 약 삭제 동작
                              },
                            ),
                        ],
                      ),
                      onTap: () {
                        showPillInfo(name, pill.quantity);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showPillForm();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              tooltip: null, // 아무 동작도 하지 않도록 설정
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital_outlined),
              label: 'Search',
              tooltip: null, // 아무 동작도 하지 않도록 설정
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              label: 'Favorites',
              tooltip: null, // 아무 동작도 하지 않도록 설정
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Profile',
              tooltip: null, // 아무 동작도 하지 않도록 설정
            ),
          ],
          selectedFontSize: 14, // 선택된 아이콘의 글꼴 크기
          unselectedFontSize: 14, // 선택되지 않은 아이콘의 글꼴 크기
          selectedItemColor: Colors.grey[500], // 선택되지 않은 아이콘의 색상
        ),
      ),
    );
  }
}
