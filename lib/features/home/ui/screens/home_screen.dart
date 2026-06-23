import 'package:flutter/material.dart';
import 'dart:async';
import 'package:combustivel_ap/theme/app_colors.dart';
import 'package:combustivel_ap/components/custom_button.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../stations/ui/widgets/add_station_bottom_sheet.dart';
import '../../../stations/cubit/station_cubit.dart';
import '../../../stations/cubit/station_state.dart';
import '../../../profile/ui/screens/profile_screen.dart';
import '../../../stations/ui/screens/station_details_screen.dart';
import '../../../stations/ui/screens/station_list_tab.dart';
import '../../../stations/models/fuel_type.dart';
import '../../cubit/filter_cubit.dart';
import '../../cubit/filter_state.dart';
import '../../cubit/home_navigation_cubit.dart';
import '../../cubit/home_navigation_state.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  bool _hasInternet = true;
  bool _hasSetInitialFuelFilter = false;
  LatLng? _currentPosition;
  final MapController _mapController = MapController();
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _determinePosition();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated && !_hasSetInitialFuelFilter) {
        if (authState.user.favoriteFuelType != null) {
          final fuelType = FuelType.values.firstWhere(
            (f) => f.displayName == authState.user.favoriteFuelType,
            orElse: () => FuelType.gasolinaComum,
          );
          context.read<FilterCubit>().updateSelectedFuel(fuelType);
        }
        _hasSetInitialFuelFilter = true;
      }
    });

    _serviceStatusStreamSubscription = Geolocator.getServiceStatusStream().listen(
      (ServiceStatus status) {
        if (status == ServiceStatus.enabled) {
          _determinePosition();
        } else {
          if (mounted) {
            setState(() {
              _currentPosition = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Atenção: O GPS do dispositivo foi desligado!')),
            );
          }
        }
      }
    );
  }

  @override
  void dispose() {
    _serviceStatusStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _hasInternet = !connectivityResult.contains(ConnectivityResult.none);
    });

    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _hasInternet = !result.contains(ConnectivityResult.none);
      });
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atenção: O GPS do dispositivo está desligado!')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A permissão de GPS foi negada.')),
          );
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, 15.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tentar encontrar o GPS: $e. Verifique se o emulador tem uma localização configurada.')),
        );
      }
    }
  }

  Widget _buildMap() {
    if (!_hasInternet) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: AppColors.disabled),
            SizedBox(height: 20),
            Text('Sem conexão com a internet', style: TextStyle(fontSize: 18, color: AppColors.disabled, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition ?? const LatLng(-28.4670, -49.0075), // Tubarão, SC
          initialZoom: 15.0,
          onTap: (tapPosition, point) {
            context.read<HomeNavigationCubit>().clearHighlight();
          },
          onLongPress: (tapPosition, point) {
            final authState = context.read<AuthCubit>().state;
            if (authState is Authenticated && authState.user.isAdmin) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddStationBottomSheet(position: point),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Apenas administradores podem adicionar postos. Vá no Firebase e mude isAdmin: true na sua conta para testar.')),
              );
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.jvictorgcruz.combustivelapp',
          ),
          if (_currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition!,
                  width: 160,
                  height: 100,
                  child: Builder(
                    builder: (context) {
                      final navState = context.watch<HomeNavigationCubit>().state;
                      final isHighlighted = navState.highlightedStationId == 'USER_LOCATION';
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isHighlighted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Você',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (isHighlighted)
                            const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 16),
                          const Icon(
                            Icons.my_location,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              return BlocBuilder<StationCubit, StationState>(
                builder: (context, state) {
                  if (state is StationLoaded) {
                    final filteredStations = state.stations.where((s) {
                      if (filterState.searchQuery.isNotEmpty && !s.name.toLowerCase().contains(filterState.searchQuery.toLowerCase())) {
                        return false;
                      }
                      if (filterState.selectedFuel != null) {
                        final hasFuel = s.prices.any((p) => p.fuelType == filterState.selectedFuel!.displayName && p.price > 0);
                        if (!hasFuel) return false;
                      }
                      if (filterState.maxDistanceRadius != null && _currentPosition != null) {
                        final distance = Geolocator.distanceBetween(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          s.latitude,
                          s.longitude,
                        );
                        if (distance > filterState.maxDistanceRadius! * 1000) {
                          return false;
                        }
                      }
                      return true;
                    }).toList();

                    return MarkerLayer(
                      markers: filteredStations.map((station) {
                    return Marker(
                      point: LatLng(station.latitude, station.longitude),
                      width: 160,
                      height: 100,
                      child: Builder(
                        builder: (context) {
                          final navState = context.watch<HomeNavigationCubit>().state;
                          final authState = context.watch<AuthCubit>().state;
                          final isHighlighted = navState.highlightedStationId == station.id;
                          final isFavorite = authState is Authenticated && authState.user.favoriteStationId == station.id;

                          return GestureDetector(
                            onTap: () {
                              context.read<HomeNavigationCubit>().highlightStation(station.id);
                              showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_gas_station, size: 40, color: AppColors.primary),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              station.name,
                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              station.brand.isNotEmpty ? station.brand : 'Sem Bandeira',
                                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Builder(
                                    builder: (context) {
                                      final filterState = context.watch<FilterCubit>().state;
                                      final selectedFuel = filterState.selectedFuel;
                                      if (selectedFuel != null) {
                                        try {
                                          final priceModel = station.prices.firstWhere((p) => p.fuelType == selectedFuel.displayName);
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: Text(
                                              '${selectedFuel.displayName}: R\$ ${priceModel.price.toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                            ),
                                          );
                                        } catch (_) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: Text(
                                              'Sem preço para ${selectedFuel.displayName}',
                                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                                            ),
                                          );
                                        }
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          station.address,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  CustomButton(
                                    text: 'Ver Detalhes e Preços',
                                    backgroundColor: AppColors.primary,
                                    textColor: Colors.white,
                                    fontSize: 16,
                                    onPressed: () {
                                      Navigator.pop(context); // Fechar modal
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StationDetailsScreen(initialStation: station),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isHighlighted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  station.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (isHighlighted)
                              const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 16),
                            Icon(
                              Icons.local_gas_station,
                              color: isFavorite ? AppColors.favorite : AppColors.negative,
                              size: 40,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, 15.0);
            context.read<HomeNavigationCubit>().highlightStation('USER_LOCATION');
          } else {
            _determinePosition();
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildMap(),
      StationListTab(currentPosition: _currentPosition),
      const ProfileScreen(),
    ];

    return MultiBlocListener(
      listeners: [
        BlocListener<HomeNavigationCubit, HomeNavigationState>(
          listener: (context, navState) {
            if (navState.centerMapPoint != null) {
              _mapController.move(navState.centerMapPoint!, 15.0);
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (authState is Authenticated && !_hasSetInitialFuelFilter) {
              if (authState.user.favoriteFuelType != null) {
                final fuelType = FuelType.values.firstWhere(
                  (f) => f.displayName == authState.user.favoriteFuelType,
                  orElse: () => FuelType.gasolinaComum,
                );
                context.read<FilterCubit>().updateSelectedFuel(fuelType);
              }
              _hasSetInitialFuelFilter = true;
            }
          },
        ),
      ],
      child: BlocBuilder<HomeNavigationCubit, HomeNavigationState>(
        builder: (context, navState) {
          final currentIndex = navState.tabIndex;
          return Scaffold(
          backgroundColor: AppColors.background,
          appBar: (currentIndex == 0 || currentIndex == 1) 
          ? AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: _isSearching 
              ? TextField(
                  autofocus: true,
                  style: const TextStyle(color: AppColors.primary),
                  decoration: const InputDecoration(
                    hintText: 'Buscar posto...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.disabled),
                  ),
                  onChanged: (val) => context.read<FilterCubit>().updateSearchQuery(val),
                )
              : const Text(
                  'Postos Próximos',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
            iconTheme: const IconThemeData(color: AppColors.primary),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      context.read<FilterCubit>().updateSearchQuery('');
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => const FilterBottomSheet(),
                  );
                },
              ),
            ],
          ) : null,
          body: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.disabled,
            backgroundColor: AppColors.background,
            selectedLabelStyle: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            elevation: 10,
            onTap: (index) {
              context.read<HomeNavigationCubit>().changeTab(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Mapa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.attach_money),
                label: 'Preços',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    ),
    );
  }
}
