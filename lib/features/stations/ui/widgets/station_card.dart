import 'package:combustivel_ap/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../models/station_model.dart';
import '../../models/fuel_type.dart';
import '../screens/station_details_screen.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final authState = context.watch<AuthCubit>().state;
    final isFavorite = authState is Authenticated && authState.user.favoriteStationId == station.id;

    Widget bottomRow;

    if (selectedFuel != null) {
      double price = 0.0;
      try {
        final priceModel = station.prices.firstWhere(
          (p) => p.fuelType == selectedFuel!.displayName,
        );
        price = priceModel.price;
      } catch (_) {}

      bottomRow = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedFuel!.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Preço p/ litro',
                style: TextStyle(fontSize: 11, color: AppColors.disabled),
              ),
              Text(
                price > 0 ? 'R\$${price.toStringAsFixed(2)}' : 'S/ Preço',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      bottomRow = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Combustíveis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            station.prices.length == 1 ? '${station.prices.length} tipo' : '${station.prices.length} tipos',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StationDetailsScreen(initialStation: station),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: (isFavorite ? AppColors.favorite : AppColors.primary).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_gas_station_outlined,
                            color: isFavorite ? AppColors.favorite : AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    distanceInMeters != null
                                        ? Icons.location_on_outlined
                                        : Icons.local_offer_outlined,
                                    size: 16,
                                    color: AppColors.disabled,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    distanceInMeters != null
                                        ? _formatDistance(distanceInMeters!)
                                        : "Sem Informação",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.disabled,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      "\u2022",
                                      style: TextStyle(
                                        color: AppColors.disabled,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    station.brand.isNotEmpty
                                        ? station.brand
                                        : 'Sem Bandeira',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.disabled,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, thickness: 1, color: AppColors.disabled.withValues(alpha: .5)),
                    const SizedBox(height: 12),
                    bottomRow,
                  ],
                ),
              ),
            ),
          ),
          if (isFavorite)
            const Positioned(
              top: 16,
              right: 20,
              child: Icon(
                Icons.star,
                color: AppColors.favorite,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}
