import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataService with ChangeNotifier {
  List<Map<String, dynamic>> _tableState = [];

  List<Map<String, dynamic>> get tableState => _tableState;

  void carregar(int index) {
    final List<Function> actions = [
      carregarCafes,
      carregarCervejas,
      carregarNacoes,
    ];

    index = index.clamp(0, actions.length - 1);
    actions[index]();
    notifyListeners();
  }

  void carregarCervejas() {
    _tableState = [
      {"name": "La Fin Du Monde", "style": "Bock", "ibu": "65"},
      {"name": "Sapporo Premiume", "style": "Sour Ale", "ibu": "54"},
      {"name": "Duvel", "style": "Pilsner", "ibu": "82"}
    ];
  }

  void carregarCafes() {
    _tableState = [
      {"name": "Latte", "style": "Expresso", "ibu": "Forte"},
      {"name": "Frappe", "style": "Americado", "ibu": "Forte"},
      {"name": "Mocha", "style": "Expresso", "ibu": "Forte"}
    ];
  }

  void carregarNacoes() {
    _tableState = [
      {"name": "Nação X", "style": "América do Sul", "ibu": "100 milhões"},
      {"name": "Nação Y", "style": "Europa", "ibu": "50 milhões"},
      {"name": "Nação Z", "style": "Ásia", "ibu": "200 milhões"}
    ];
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
              columnNames: ["Nome", "Estilo", "IBU"],
              propertyNames: ["name", "style", "ibu"],
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
