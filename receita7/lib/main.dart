import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataService {
  final ValueNotifier<List> tableStateNotifier = ValueNotifier([]);
  final ValueNotifier<int> selectedOptionNotifier = ValueNotifier(5);

  Future<void> carregar(int index) async {
    switch (index) {
      case 0:
        await carregarCafes();
        break;
      case 1:
        await carregarNacoes();
        break;
      default:
        break;
    }
  }

  Future<void> carregarCafes() async {
    var cafesUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/coffee/random_coffee',
      queryParameters: {'size': selectedOptionNotifier.value.toString()},
    );

    var jsonString = await http.read(cafesUri);
    var cafesJson = jsonDecode(jsonString);

    tableStateNotifier.value = cafesJson;
  }

  Future<void> carregarNacoes() async {
    var nacoesUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/nation/random_nation',
      queryParameters: {'size': selectedOptionNotifier.value.toString()},
    );

    var jsonString = await http.read(nacoesUri);
    var nacoesJson = jsonDecode(jsonString);

    tableStateNotifier.value = nacoesJson;
  }
}

final dataService = DataService();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Dicas"),
        ),
        body: ValueListenableBuilder(
          valueListenable: dataService.tableStateNotifier,
          builder: (_, value, __) {
            List<String> columnNames = [
              "Nome",
              "Origem",
              "Variedade",
              "Notas",
              "Intensificador"
            ];

            return DataTableWidget(
              jsonObjects: value,
              propertyNames: [
                "blend_name",
                "origin",
                "variety",
                "notes",
                "intensifier"
              ],
              columnNames: columnNames,
            );
          },
        ),
        bottomNavigationBar:
            NewNavBar(itemSelectedCallback: dataService.carregar),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return NumberPickerDialog();
              },
            );
          },
          child: Icon(Icons.settings),
        ),
      ),
    );
  }
}

class NewNavBar extends HookWidget {
  final _itemSelectedCallback;

  NewNavBar({itemSelectedCallback})
      : _itemSelectedCallback = itemSelectedCallback;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.coffee),
          label: 'Cafés',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: 'Nações',
        ),
      ],
      onTap: (int index) {
        _itemSelectedCallback(index);
      },
    );
  }
}

class NumberPickerDialog extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final selectedOption = useState(5);

    return AlertDialog(
      title: const Text('Selecionar Quantidade'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<int>(
            title: const Text('5'),
            value: 5,
            groupValue: selectedOption.value,
            onChanged: (value) {
              selectedOption.value = value!;
            },
          ),
          RadioListTile<int>(
            title: const Text('10'),
            value: 10,
            groupValue: selectedOption.value,
            onChanged: (value) {
              selectedOption.value = value!;
            },
          ),
          RadioListTile<int>(
            title: const Text('15'),
            value: 15,
            groupValue: selectedOption.value,
            onChanged: (value) {
              selectedOption.value = value!;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            dataService.selectedOptionNotifier.value = selectedOption.value;
            dataService.carregar(dataService.selectedOptionNotifier.value);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;
  final List<String> propertyNames;
  final List<String> columnNames;

  DataTableWidget({
    required this.jsonObjects,
    required this.propertyNames,
    required this.columnNames,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: List<DataColumn>.generate(
          columnNames.length,
          (index) => DataColumn(label: Text(columnNames[index])),
        ),
        rows: List<DataRow>.generate(
          jsonObjects.length,
          (index) {
            var jsonObject = jsonObjects[index];
            return DataRow(
              cells: List<DataCell>.generate(
                propertyNames.length,
                (cellIndex) {
                  var propertyName = propertyNames[cellIndex];
                  var cellValue = jsonObject[propertyName].toString();
                  return DataCell(Text(cellValue));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
