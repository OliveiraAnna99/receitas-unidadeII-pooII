import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataService with ChangeNotifier {
  List<Map<String, dynamic>> _tableState = [];
  String _dataType = "cafes";

  List<Map<String, dynamic>> get tableState => _tableState;

  static const Map<String, List<String>> columnNamesMap = {
    "cafes": ["Nome", "Estilo", "IBU"],
    "cervejas": ["Nome", "Estilo", "IBU"],
    "nacoes": ["Nome", "Região", "População"],
  };

  static const Map<String, List<String>> propertyNamesMap = {
    "cafes": ["name", "style", "ibu"],
    "cervejas": ["name", "style", "ibu"],
    "nacoes": ["name", "style", "population"],
  };

  static const Map<String, List<Map<String, dynamic>>> dataMap = {
    "cafes": [
      {"name": "Latte", "style": "Expresso", "ibu": "Forte"},
      {"name": "Frappe", "style": "Americado", "ibu": "Forte"},
      {"name": "Mocha", "style": "Expresso", "ibu": "Forte"}
    ],
    "cervejas": [
      {"name": "La Fin Du Monde", "style": "Bock", "ibu": "65"},
      {"name": "Sapporo Premiume", "style": "Sour Ale", "ibu": "54"},
      {"name": "Duvel", "style": "Pilsner", "ibu": "82"}
    ],
    "nacoes": [
      {"name": "Nação X", "style": "América do Sul", "population": "100 milhões"},
      {"name": "Nação Y", "style": "Europa", "population": "50 milhões"},
      {"name": "Nação Z", "style": "Ásia", "population": "200 milhões"}
    ],
  };

  void carregar(int index) {
    final List<String> dataTypes = dataMap.keys.toList();
    index = index.clamp(0, dataTypes.length - 1);
    _dataType = dataTypes[index];
    _tableState = dataMap[_dataType]!;
    notifyListeners();
  }

  List<String> getColumnNames() {
    return columnNamesMap[_dataType] ?? [];
  }

  List<String> getPropertyNames() {
    return propertyNamesMap[_dataType] ?? [];
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DataService(),
      child: MyApp(),
    ),
  );
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
        body: Consumer<DataService>(
          builder: (_, value, __) {
            return DataTableWidget(
              jsonObjects: value.tableState,
              columnNames: value.getColumnNames(),
              propertyNames: value.getPropertyNames(),
            );
          },
        ),
        bottomNavigationBar: NewNavBar(),
      ),
    );
  }
}

class NewNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (index) {
        context.read<DataService>().carregar(index);
      },
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(
          label: "Cafés",
          icon: Icon(Icons.coffee_outlined),
        ),
        BottomNavigationBarItem(
          label: "Cervejas",
          icon: Icon(Icons.local_drink_outlined),
        ),
        BottomNavigationBarItem(
          label: "Nações",
          icon: Icon(Icons.flag_outlined),
        ),
      ],
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;
  final List<String> columnNames;
  final List<String> propertyNames;

  DataTableWidget({
    this.jsonObjects = const [],
    this.columnNames = const ["Nome", "Estilo", "IBU"],
    this.propertyNames = const ["name", "style", "ibu"],
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columnNames
          .map(
            (name) => DataColumn(
              label: Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          )
          .toList(),
      rows: jsonObjects
          .map(
            (obj) => DataRow(
              cells: propertyNames
                  .map(
                    (propName) => DataCell(
                      Text(obj[propName]),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
