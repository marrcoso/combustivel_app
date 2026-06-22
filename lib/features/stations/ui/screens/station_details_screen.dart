import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/station_model.dart';
import '../../cubit/station_cubit.dart';
import '../../cubit/station_state.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../widgets/edit_prices_bottom_sheet.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum aplicativo de mapas encontrado no dispositivo.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao tentar abrir o mapa.')),
        );
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
                    child: ListTile(
                      title: Text(p.fuelType, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(
                        'R\$ ${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )).toList(),
              ],
            ),
          ),
          floatingActionButton: isAdmin ? FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => EditPricesBottomSheet(station: station),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar Preços'),
          ) : null,
        );
      },
    );
  }
}
