import 'package:combustivel_ap/components/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

import '../../models/station_model.dart';
import '../../models/fuel_type.dart';
import '../../cubit/station_cubit.dart';
import '../../cubit/station_state.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../home/cubit/home_navigation_cubit.dart';
import '../widgets/edit_prices_bottom_sheet.dart';
import '../widgets/suggest_price_bottom_sheet.dart';

class StationDetailsScreen extends StatelessWidget {
  final StationModel initialStation;

  const StationDetailsScreen({super.key, required this.initialStation});

  Future<void> _openMap(BuildContext context, StationModel station) async {
    final geoUrl = Uri.parse('geo:${station.latitude},${station.longitude}?q=${station.latitude},${station.longitude}');

    try {
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl);
      } else {
        if (context.mounted) {
          CustomSnackBar.error(context, 'Nenhum aplicativo de mapas encontrado no dispositivo.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.error(context, 'Erro ao tentar abrir o mapa.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final isAdmin = authState is Authenticated && authState.user.isAdmin;

    return BlocBuilder<StationCubit, StationState>(
      builder: (context, state) {
        StationModel station = initialStation;
        if (state is StationLoaded) {
          try {
            station = state.stations.firstWhere((s) => s.id == initialStation.id);
          } catch (_) {}
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Posto'),
            actions: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final isFavorite = authState is Authenticated && authState.user.favoriteStationId == station.id;
                  if (authState is Authenticated) {
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.amber : null,
                      ),
                      onPressed: () {
                        context.read<AuthCubit>().toggleFavoriteStation(station.id);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_gas_station, size: 60, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            station.brand.isNotEmpty ? station.brand : 'Sem Bandeira',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        station.address,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _openMap(context, station),
                  icon: const Icon(Icons.directions),
                  label: const Text('Traçar Rota'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<HomeNavigationCubit>().showOnMap(LatLng(station.latitude, station.longitude), station.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Mostrar no Mapa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Preços',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (station.prices.isEmpty)
                  const Center(child: Text('Nenhum preço cadastrado.'))
                else
                  ...station.prices.map((p) => Card(
                    child: InkWell(
                      onTap: isAdmin ? null : () {
                        final fuelType = FuelType.values.firstWhere(
                          (t) => t.displayName == p.fuelType,
                          orElse: () => FuelType.gasolinaComum,
                        );
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => SuggestPriceBottomSheet(
                            station: station,
                            initialFuelType: fuelType,
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(p.fuelType, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(
                          'R\$ ${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => isAdmin 
                    ? EditPricesBottomSheet(station: station)
                    : SuggestPriceBottomSheet(station: station),
              );
            },
            icon: Icon(isAdmin ? Icons.edit : Icons.lightbulb),
            label: Text(isAdmin ? 'Editar Preços' : 'Sugerir Preço'),
          ),
        );
      },
    );
  }
}
