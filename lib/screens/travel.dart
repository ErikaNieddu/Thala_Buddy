import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ThalassemiaCenter {
  final String name;
  final String city;
  final String country;
  final LatLng location;
  final String phone;
  final String address;

  const ThalassemiaCenter({
    required this.name,
    required this.city,
    required this.country,
    required this.location,
    required this.phone,
    required this.address,
  });
}

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  static const Color primaryRed = Color.fromARGB(255, 183, 38, 38);
  ThalassemiaCenter? _selectedCenter;
  final MapController _mapController = MapController();

  final List<ThalassemiaCenter> _centers = const [
    ThalassemiaCenter(
      name: 'Ospedale Microcitemico "Antonio Cao"',
      city: 'Cagliari',
      country: 'Italy',
      location: LatLng(39.2435, 9.1171),
      address: 'Via Alfonso Cao',
      phone: '+39 070 52961',
    ),
    ThalassemiaCenter(
      name: 'Azienda Ospedaliera di Padova - Hematology',
      city: 'Padova',
      country: 'Italy',
      location: LatLng(45.4024, 11.8860),
      address: 'Via Giustiniani, 2',
      phone: '+39 049 821 1111',
    ),
    ThalassemiaCenter(
      name: 'Centro della Microcitemia - Sant\'Anna',
      city: 'Ferrara',
      country: 'Italy',
      location: LatLng(44.8214, 11.6934),
      address: 'Via Aldo Moro, 8',
      phone: '+39 0532 236111',
    ),
    ThalassemiaCenter(
      name: 'Policlinico Umberto I - Hematology',
      city: 'Rome',
      country: 'Italy',
      location: LatLng(41.9062, 12.5118),
      address: 'Viale del Policlinico, 155',
      phone: '+39 06 49971',
    ),
    ThalassemiaCenter(
      name: 'Ospedale Cardarelli - Rare Diseases',
      city: 'Naples',
      country: 'Italy',
      location: LatLng(40.8652, 14.2343),
      address: 'Via Antonio Cardarelli, 9',
      phone: '+39 081 747 1111',
    ),
    ThalassemiaCenter(
      name: 'E.O. Ospedali Galliera - Microcythemia Center',
      city: 'Genoa',
      country: 'Italy',
      location: LatLng(44.4005, 8.9388),
      address: 'Mura delle Cappuccine, 14',
      phone: '+39 010 56321',
    ),
    ThalassemiaCenter(
      name: 'Policlinico di Bari - Hematology',
      city: 'Bari',
      country: 'Italy',
      location: LatLng(41.1091, 16.8617),
      address: 'Piazza Giulio Cesare, 11',
      phone: '+39 080 559 1111',
    ),
    ThalassemiaCenter(
      name: 'Ospedale Cervello - "Cutino" Campus',
      city: 'Palermo',
      country: 'Italy',
      location: LatLng(38.1542, 13.3086),
      address: 'Via Cruillas, 115',
      phone: '+39 091 680 2111',
    ),
    ThalassemiaCenter(
      name: 'Fondazione IRCCS Ca\' Granda Policlinico',
      city: 'Milan',
      country: 'Italy',
      location: LatLng(45.4601, 9.1963),
      address: 'Via Francesco Sforza, 35',
      phone: '+39 02 55031',
    ),
    ThalassemiaCenter(
      name: 'Ospedale San Luigi Gonzaga',
      city: 'Turin',
      country: 'Italy',
      location: LatLng(45.0064, 7.5501),
      address: 'Regione Gonzole, 10 (Orbassano)',
      phone: '+39 011 90261',
    ),
    ThalassemiaCenter(
      name: 'Laiko General Hospital - Thalassemia Unit',
      city: 'Athens',
      country: 'Greece',
      location: LatLng(37.9830, 23.7660),
      address: 'Agiou Thoma 17, Athina',
      phone: '+30 21 3206 1000',
    ),
    ThalassemiaCenter(
      name: 'AHEPA University Hospital - Haematology Clinic',
      city: 'Thessaloniki',
      country: 'Greece',
      location: LatLng(40.6292, 22.9566),
      address: 'Stilponos Kyriakidi 1',
      phone: '+30 231 330 3110',
    ),
    ThalassemiaCenter(
      name: 'Patras University General Hospital',
      city: 'Patras',
      country: 'Greece',
      location: LatLng(38.2631, 21.7871),
      address: 'Rion 265 04',
      phone: '+30 261 360 3000',
    ),
    ThalassemiaCenter(
      name: 'Nicosia General Hospital - Thalassemia Centre',
      city: 'Nicosia',
      country: 'Cyprus',
      location: LatLng(35.1436, 33.3517),
      address: 'Nea Ellados, Latsia',
      phone: '+357 22 603000',
    ),
    ThalassemiaCenter(
      name: 'Limassol General Hospital - Thalassemia Clinic',
      city: 'Limassol',
      country: 'Cyprus',
      location: LatLng(34.7072, 32.9994),
      address: 'Nikou Pattichi, Polemidia',
      phone: '+357 25 801100',
    ),
    ThalassemiaCenter(
      name: 'UCLH - Red Cell Centre',
      city: 'London',
      country: 'United Kingdom',
      location: LatLng(51.5246, -0.1340),
      address: '235 Euston Rd, London',
      phone: '+44 20 3456 7890',
    ),
    ThalassemiaCenter(
      name: 'Manchester Royal Infirmary - Haematology',
      city: 'Manchester',
      country: 'United Kingdom',
      location: LatLng(53.4632, -2.2274),
      address: 'Oxford Rd, Manchester',
      phone: '+44 161 276 1234',
    ),
    ThalassemiaCenter(
      name: 'Hôpital Necker - Malades Dépistage',
      city: 'Paris',
      country: 'France',
      location: LatLng(48.8448, 2.3134),
      address: '149 Rue de Sèvres, Paris',
      phone: '+33 1 44 49 40 00',
    ),
    ThalassemiaCenter(
      name: 'Hôpital de la Timone - Adult Haematology',
      city: 'Marseille',
      country: 'France',
      location: LatLng(43.2897, 5.4019),
      address: '264 Rue Saint-Pierre',
      phone: '+33 4 91 38 00 00',
    ),
    ThalassemiaCenter(
      name: 'Hospital Universitari Vall d\'Hebron',
      city: 'Barcelona',
      country: 'Spain',
      location: LatLng(41.4258, 2.1444),
      address: 'Passeig de la Vall d\'Hebron, 119',
      phone: '+34 934 89 30 00',
    ),
    ThalassemiaCenter(
      name: 'Hospital Universitario Ramón y Cajal',
      city: 'Madrid',
      country: 'Spain',
      location: LatLng(40.4878, -3.7042),
      address: 'Ctra. de Colmenar Viejo, km. 9.100',
      phone: '+34 913 36 80 00',
    ),
    ThalassemiaCenter(
      name: 'Charité - Universitätsmedizin',
      city: 'Berlin',
      country: 'Germany',
      location: LatLng(52.5250, 13.3764),
      address: 'Charitéplatz 1, Berlin',
      phone: '+49 30 45050',
    ),
    ThalassemiaCenter(
      name: 'Universitätsklinikum Ulm - Pädiatrische Hämatologie',
      city: 'Ulm',
      country: 'Germany',
      location: LatLng(48.4211, 9.9528),
      address: 'Albert-Einstein-Allee 23',
      phone: '+49 731 5000',
    ),
    ThalassemiaCenter(
      name: 'Erasmus MC - Hematology Department',
      city: 'Rotterdam',
      country: 'Netherlands',
      location: LatLng(51.9105, 4.4714),
      address: 'Doctor Molewaterplein 40',
      phone: '+31 10 704 0704',
    ),
    ThalassemiaCenter(
      name: 'Hôpital Universitaire Des Enfants Reine Fabiola',
      city: 'Brussels',
      country: 'Belgium',
      location: LatLng(50.8876, 4.3323),
      address: 'Avenue Jean Joseph Crocq 15',
      phone: '+32 2 477 31 11',
    ),
    ThalassemiaCenter(
      name: 'Akdeniz University Thalassemia Center',
      city: 'Antalya',
      country: 'Turkey',
      location: LatLng(36.8972, 30.6481),
      address: 'Pınarbaşı, Dumlupınar Blv.',
      phone: '+90 242 227 4343',
    ),
  ];

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Travel Mode', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            const Text('Find specialized thalassemia centers across Europe and travel safely.', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 24),
            
            Container(
              height: 360,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: LatLng(42.5000, 12.5000), 
                        initialZoom: 5.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.thalabuddy.app',
                        ),
                        MarkerLayer(
                          markers: _centers.map((center) {
                            final isSelected = _selectedCenter?.name == center.name;
                            return Marker(
                              point: center.location,
                              width: 45,
                              height: 45,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCenter = center;
                                  });
                                },
                                child: AnimatedScale(
                                  scale: isSelected ? 1.3 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: isSelected ? Colors.amber.shade800 : primaryRed,
                                    size: 40,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: "btnZoomIn",
                            onPressed: _zoomIn,
                            backgroundColor: Colors.white,
                            elevation: 4,
                            child: const Icon(Icons.add, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: "btnZoomOut",
                            onPressed: _zoomOut,
                            backgroundColor: Colors.white,
                            elevation: 4,
                            child: const Icon(Icons.remove, color: Colors.black87),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedCenter != null
                  ? Container(
                      key: ValueKey(_selectedCenter!.name),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedCenter!.city.toUpperCase()} • ${_selectedCenter!.country.toUpperCase()}',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.2),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                onPressed: () => setState(() => _selectedCenter = null),
                              )
                            ],
                          ),
                          Text(
                            _selectedCenter!.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.map_outlined, size: 14, color: Colors.black54),
                              const SizedBox(width: 6),
                              Expanded(child: Text(_selectedCenter!.address, style: const TextStyle(fontSize: 13, color: Colors.black54))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(_selectedCenter!.phone, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Tap a marker to view center details',
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}