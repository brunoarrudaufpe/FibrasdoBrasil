import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final PopupController _popupController = PopupController();
  MapController _mapController = MapController();

  List<List<dynamic>> data = [];
  List<Marker> markers = [];
  List<Marker> rows = [];
  bool isReplay = false;

  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => MapSearch()),
    );
    setState(() {
      List<String> tempList = result.split(" ");
      double latitude = double.parse(tempList[0]);
      double longitude = double.parse(tempList[1]);

      _mapController.move(LatLng(latitude, longitude), 20);
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
  @override
  Widget build(BuildContext context) {
    setState(() {
    markers = List.from(markers);
    rows = List.from(markers);
  });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: () {
          _navigateAndDisplaySelection(context);
        },
        child: Icon(Icons.search),
      ),
      body: Stack(
        fit: StackFit.loose,
        children: [
          FlutterMap(
            options: MapOptions(
              center: points[0],
              zoom: 5,
              maxZoom: 15,
              plugins: [
                MarkerClusterPlugin(),
              ],
              onTap: (_) => _popupController
                  .hidePopup(), // Hide popup when the map is tapped.
            ),
            mapController: _mapController,
            layers: [
              TileLayerOptions(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerClusterLayerOptions(
                maxClusterRadius: 120,
                size: Size(40, 40),
                anchor: AnchorPos.align(AnchorAlign.center),
                fitBoundsOptions: FitBoundsOptions(
                  padding: EdgeInsets.all(50),
                ),
                markers: markers,
                polygonOptions: PolygonOptions(
                    borderColor: Colors.blueAccent,
                    color: Colors.black12,
                    borderStrokeWidth: 3),
                popupOptions: PopupOptions(
                    popupSnap: PopupSnap.markerTop,
                    popupController: _popupController,
                    popupBuilder: (_, marker) => Container(
                      width: 200,
                      height: 80,
                      color: Colors.grey,
                      child: Column(
                        children: <Widget>[
                          Container(
                              height: 40,
                              color: Colors.grey,
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.map, color: Colors.white),
                                  Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: '${marker.name}', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),

                                    ),
                                  ),
                                ],
                              )
                          ),
                          Container(
                              height: 40,
                              color: Colors.black45,
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.speed, color: Colors.white),
                                  Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: 'Qualidade:', style: TextStyle(color: Colors.white, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  if (marker.perdas <0.01) RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      text: 'Ótimo', style: TextStyle(color: Colors.green, fontSize: 15),
                                    ),
                                  ),
                                  if (marker.perdas >=0.01 && marker.perdas <1.0) RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      text: 'Boa', style: TextStyle(color: Colors.green, fontSize: 15),
                                    ),
                                  ),
                                  if (marker.perdas >=1.0 && marker.perdas <3.0) RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      text: 'Regular', style: TextStyle(color: Colors.yellow, fontSize: 15),
                                    ),
                                  ),
                                  if (marker.perdas >3.0) RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      text: 'Ruim', style: TextStyle(color: Colors.red, fontSize: 15),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),
                    )
                ),
                builder: (context, markers) {
                  return FloatingActionButton(
                    onPressed: null,
                    child: Text(markers.length.toString()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
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

class MapSearch extends StatefulWidget {

  @override
  State<MapSearch> createState() => _MapSearchState();
}


class _MapSearchState extends State<MapSearch> {
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
                      String texto1 = marker.point.latitude.toString();
                      String texto2 = marker.point.longitude.toString();
                      String textToSendBack = '$texto1 $texto2';
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


