import 'package:flutter/material.dart';
import '../../models/station_model.dart';
import '../../models/fuel_type.dart';
import '../screens/station_details_screen.dart';

class StationCard extends StatelessWidget {
  final StationModel station;
  final double? distanceInMeters;
  final FuelType? selectedFuel;

  const StationCard({
    super.key,
    required this.station,
    this.distanceInMeters,
    this.selectedFuel,
  });

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget priceWidget = const SizedBox.shrink();

    if (selectedFuel != null) {
      try {
        final priceModel = station.prices.firstWhere((p) => p.fuelType == selectedFuel!.displayName);
        priceWidget = Text(
          'R\$ ${priceModel.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        );
      } catch (_) {}
    } else {
      priceWidget = Text(
        '${station.prices.length} combustíveis disponíveis',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StationDetailsScreen(initialStation: station),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.local_gas_station, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      station.brand.isNotEmpty ? station.brand : 'Sem Bandeira',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    priceWidget,
                  ],
                ),
              ),
              if (distanceInMeters != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(height: 4),
                    Text(
                      _formatDistance(distanceInMeters!),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
