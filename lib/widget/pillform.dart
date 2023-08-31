import 'package:flutter/material.dart';

class PillForm extends StatefulWidget {
  final Function(String, int, List<String>) onSave;
  final String initialName;
  final int initialQuantity;
  final List<String> initialTimes;

  const PillForm({
    Key? key,
    required this.onSave,
    required this.initialName,
    required this.initialQuantity,
    required this.initialTimes,
  }) : super(key: key);

  @override
  PillFormState createState() => PillFormState();
}

class PillFormState extends State<PillForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  List<String> _selectedTimes = <String>[];

  @override
  void initState() {
    super.initState();
    _selectedTimes = List.from(widget.initialTimes);
    nameController.text = widget.initialName;
    quantityController.text = widget.initialQuantity.toString();
    _selectedTimes = List.from(widget.initialTimes);
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void saveData() {
    final name = nameController.text;
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final times = _selectedTimes.toList();

    widget.onSave(name, quantity, times);
    Navigator.pop(context);
  }

  Widget buildTimeButton(String time) {
    final isSelected = _selectedTimes.contains(time);

    return ElevatedButton(
      onPressed: () {
        setState(() {
          onTimeButtonPressed(time);
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isSelected ? Colors.cyan : const Color(0xffeaeaea),
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

  void onTimeButtonPressed(String time) {
    if (_selectedTimes.contains(time)) {
      _selectedTimes.remove(time);
    } else {
      _selectedTimes.add(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '약 이름',
          ),
        ),
        TextFormField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '약 수량'),
          onFieldSubmitted: (value) => saveData(),
        ),
        const SizedBox(height: 10),
        const Text('복용 시간'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTimeButton('아침'),
            const SizedBox(width: 10),
            buildTimeButton('점심'),
            const SizedBox(width: 10),
            buildTimeButton('저녁'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: saveData,
              child: const Text(
                '저장',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xffeaeaea)),
              ),
              child: const Text('취소'),
            ),
          ],
        ),
      ],
    );
  }
}
