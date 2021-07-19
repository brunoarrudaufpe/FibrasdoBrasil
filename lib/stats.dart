import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ext_storage/ext_storage.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

/// This is the stateful widget that the main application instantiates.
class StatsPage extends StatefulWidget {

  @override
  State<StatsPage> createState() => _StatsPageState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _StatsPageState extends State<StatsPage> {


  List<List<dynamic>> data = [];
  List<Marker> markers = [];
  List<Marker> rows = [];
  final SearchBarController<Marker> _searchBarController = SearchBarController();
  bool isReplay = false;
  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => InstitutionSearch()),
    );
    setState(() {
      List<String> tempList = result.split(" ");
      nome = tempList[0];
      upload = tempList[1];
      download = tempList[2];
      perdas = double.parse(tempList[3]);
    });

  }


  int pointIndex;
  List points = [
    LatLng(-14.2400732, -53.1805017)
  ];

  @override
  void initState() {
    super.initState();
    loadAsset();
    pointIndex = 0;
  }
  String query = '';
  List results = [];
  TextEditingController tc;

  Future<List<Marker>> search(String search) async {
    await Future.delayed(Duration(microseconds: 1000));
    return results = rows
        .where((elem) =>
    elem.name
        .toString()
        .toLowerCase()
        .contains(search.toLowerCase()) ||
        elem.upload
            .toString()
            .toLowerCase()
            .contains(search.toLowerCase()))
        .toList();
  }


  loadAsset() async {
    var csv = await rootBundle.loadString("assets/data/DataCSV.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csv);
    setState(() {
      for(List row in csvTable){
        markers.add(
          Marker(
            name: row[1] as String,
            upload: row[2] as int,
            download: row[3] as int,
            downMedio: row[5] as double,
            ocupacaoUp: row[6] as double,
            ocupacaoDown: row[7] as double,
            perdas: row[8] as double,
            latencia: row[9] as double,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 40,
            width: 40,
            point: LatLng(row[10] as double, row[11] as double),
            builder: (ctx) => Icon(Icons.place,color:Colors.green),

          ),
        );
      }
      data = csvTable;
    });
  }



  static final List<String> chartDropdownItems = ['', 'Download' ];
  String actualDropdown = chartDropdownItems[0];
  int actualChart = 0;


  void _generateCsvFile() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    var csv = await rootBundle.loadString("assets/data/DataCSV.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csv);
    String csvNew = const ListToCsvConverter().convert(csvTable);


    String dir = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    print("dir $dir");
    String file = "$dir";

    File f = File(file + "/DadosConexao.csv");

    f.writeAsString(csvNew);


  }
  String nome = "Pesquise a Instituição";
  String upload = "";
  String download = "";
  String ocupacao = "";
  double perdas = -1.0;


  @override
  Widget build(BuildContext context)
  {
    setState(() {
      markers = List.from(markers);
      rows = List.from(markers);
    });
    return Scaffold
      (
        appBar: AppBar
          (
          elevation: 2.0,
          backgroundColor: Colors.white,
          title: Text('Estatísticas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 30.0)),
          actions:
          <Widget>[
            IconButton(
                    color: Colors.black45,
                    icon: const Icon(Icons.search),
                    tooltip: 'Pesquise a Instituição',
                    onPressed: () {
                      _navigateAndDisplaySelection(context);
                    },
                  ),
            IconButton(
              color: Colors.black45,
              icon: const Icon(Icons.arrow_drop_down_circle),
              tooltip: 'Baixe os Dados',
              onPressed: () {
                _generateCsvFile();
              },
            )
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            StaggeredGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: <Widget>[
                _buildTile(
                  Padding
                    (
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24.0),
                    child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>
                        [
                          Column
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Text('Instituição', style: TextStyle(color: Colors.blueAccent)),
                              Text(nome, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15.0))
                            ],
                          ),
                        ]
                    ),
                  ),
                ),
                _buildTile(
                  Padding
                    (
                    padding: const EdgeInsets.all(24.0),
                    child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>
                        [
                          Column
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Text('Taxa de Download', style: TextStyle(color: Colors.blueAccent)),
                              Text(download, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 34.0))
                            ],
                          ),
                          Material
                            (
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(24.0),
                              child: Center
                                (
                                  child: Padding
                                    (
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.arrow_downward, color: Colors.white, size: 30.0),
                                  )
                              )
                          )
                        ]
                    ),
                  ),
                ),
                _buildTile(
                  Padding
                    (
                    padding: const EdgeInsets.all(24.0),
                    child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>
                        [
                          Column
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Text('Taxa de Upload', style: TextStyle(color: Colors.blueAccent)),
                              Text(upload, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 34.0))
                            ],
                          ),
                          Material
                            (
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(24.0),
                              child: Center
                                (
                                  child: Padding
                                    (
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.arrow_upward, color: Colors.white, size: 30.0),
                                  )
                              )
                          )
                        ]
                    ),
                  ),
                ),
                _buildTile(
                  Padding
                    (
                    padding: const EdgeInsets.all(24.0),
                    child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>
                        [
                          Column
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Text('Qualidade', style: TextStyle(color: Colors.blueAccent)),
                              if (perdas < 0.0)
                                Text('', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 34.0)),
                              if (perdas>= 0.0 && perdas <0.01)
                                Text('Ótima', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 34.0)),
                              if (perdas>= 0.01 && perdas <1.0 )
                                Text('Boa', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 34.0)),
                              if (perdas>= 1.0 && perdas <3.0 )
                                Text('Regular', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.w700, fontSize: 34.0)),
                              if (perdas>= 3.0 )
                                Text('Ruim', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 34.0)),
                            ],
                          ),
                          Material
                            (
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(24.0),
                              child: Center
                                (
                                  child: Padding
                                    (
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.timeline, color: Colors.white, size: 30.0),
                                  )
                              )
                          )
                        ]
                    ),
                  ),
                ),

              ],
              staggeredTiles: [
                StaggeredTile.extent(2, 55.0),
                StaggeredTile.extent(2, 110.0),
                StaggeredTile.extent(2, 110.0),
                StaggeredTile.extent(2, 110.0),
              ],
            ),
          ],
        ),

    );


  }

  Widget _buildTile(Widget child, {Function() onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Color(0x802196F3),
        child: InkWell
          (
          // Do onTap() if it isn't null, otherwise do print()
            onTap: onTap != null ? () => onTap() : () { print('Not set yet'); },
            child: child
        )
    );
  }
}

class Detail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text("Detail"),
          ],
        ),
      ),
    );
  }
}
class InstitutionSearch extends StatefulWidget {

  @override
  State<InstitutionSearch> createState() => _InstitutionSearchState();
}


class _InstitutionSearchState extends State<InstitutionSearch> {
  List<List<dynamic>> data = [];
  List<Marker> markers = [];
  List<Marker> rows = [];
  final SearchBarController<Marker> _searchBarController = SearchBarController();
  bool isReplay = false;

  String query = '';
  List results = [];
  TextEditingController tc;
  int pointIndex;
  List points = [
    LatLng(-14.2400732, -53.1805017)
  ];

  @override
  void initState() {
    super.initState();
    loadAsset();
    pointIndex = 0;
  }


  Future<List<Marker>> search(String search) async {
    await Future.delayed(Duration(microseconds: 1000));
    return results = rows
        .where((elem) =>
    elem.name
        .toString()
        .toLowerCase()
        .contains(search.toLowerCase()) ||
        elem.upload
            .toString()
            .toLowerCase()
            .contains(search.toLowerCase()))
        .toList();
  }


  loadAsset() async {
    var csv = await rootBundle.loadString("assets/data/DataCSV.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csv);
    setState(() {
      for(List row in csvTable){
        markers.add(
          Marker(
            name: row[1] as String,
            upload: row[2] as int,
            download: row[3] as int,
            downMedio: row[5] as double,
            ocupacaoUp: row[6] as double,
            ocupacaoDown: row[7] as double,
            perdas: row[8] as double,
            latencia: row[9] as double,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 40,
            width: 40,
            point: LatLng(row[10] as double, row[11] as double),
            builder: (ctx) => Icon(Icons.place,color:Colors.green),

          ),
        );
      }
      data = csvTable;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      markers = List.from(markers);
      rows = List.from(markers);
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SearchBar<Marker>(
              searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
              headerPadding: EdgeInsets.symmetric(horizontal: 10),
              listPadding: EdgeInsets.symmetric(horizontal:10),
              onSearch: search,
              searchBarController: _searchBarController,
              hintText: ('Instituição ou velocidade...'),
              minimumChars: 1,
              emptyWidget: Text("empty"),
              //indexedScaledTileBuilder: (int index) => ScaledTile.count(1, index.isEven ? 2 : 1),
              onCancelled: () {
                print("Cancelled triggered");
              },
              mainAxisSpacing: 0,
              crossAxisSpacing: 10,
              //crossAxisCount: 2,
              onItemFound: (Marker marker, int index) {
                return Card(
                  margin: EdgeInsets.all(0.5),
                  color: Colors.white,
                  child: ListTile(
                    title: Text(marker.name),
                    subtitle: Text('${marker.upload} GB'),
                    isThreeLine: false,
                    onTap: () {
                      String texto1 = marker.name;
                      String texto2 = marker.upload.toStringAsFixed(1);
                      String texto3 = marker.download.toStringAsFixed(1);
                      String texto4 = marker.perdas.toString();
                      String textToSendBack = '$texto1 $texto2 $texto3 $texto4';
                      Navigator.pop(context, textToSendBack);
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),

          ],
        ),
      ),
    );
  }
}
