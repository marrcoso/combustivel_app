import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:combustivel_ap/theme/app_colors.dart';
import 'package:combustivel_ap/components/custom_button.dart';
import 'package:combustivel_ap/features/auth/cubit/auth_cubit.dart';
import 'package:combustivel_ap/features/auth/cubit/auth_state.dart';
import 'package:combustivel_ap/features/home/cubit/filter_cubit.dart';
import 'package:combustivel_ap/features/home/cubit/home_navigation_cubit.dart';
import 'package:combustivel_ap/features/stations/models/station_model.dart';
import 'package:combustivel_ap/features/stations/ui/screens/station_details_screen.dart';

class StationMarkerWidget extends StatelessWidget {
  final StationModel station;
  final double scale;

  const StationMarkerWidget({
    super.key,
    required this.station,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final filterState = context.watch<FilterCubit>().state;
    final navState = context.watch<HomeNavigationCubit>().state;
    final authState = context.watch<AuthCubit>().state;

    final isHighlighted = navState.highlightedStationId == station.id;
    final isFavorite = authState is Authenticated && authState.user.favoriteStationId == station.id;

    Widget markerIcon;
    if (filterState.selectedFuel != null) {
      double price = 0.0;
      try {
        price = station.prices.firstWhere((p) => p.fuelType == filterState.selectedFuel!.displayName).price;
      } catch (_) {}

      if (price > 0) {
        markerIcon = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isHighlighted 
                ? (isFavorite ? AppColors.favorite : Colors.black87) 
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFavorite ? AppColors.favorite : (isHighlighted ? Colors.black87 : Colors.grey.shade300),
              width: isFavorite ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFavorite) ...[
                Icon(
                  Icons.star,
                  color: isHighlighted ? Colors.white : AppColors.favorite,
                  size: 14,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                'R\$ ${price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isHighlighted ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: isHighlighted ? 15 : 13,
                ),
              ),
            ],
          ),
        );
      } else {
        markerIcon = Icon(
          Icons.local_gas_station,
          color: isFavorite ? AppColors.favorite : AppColors.primary,
          size: 40,
        );
      }
    } else {
      markerIcon = Icon(
        Icons.local_gas_station,
        color: isFavorite ? AppColors.favorite : AppColors.primary,
        size: 40,
      );
    }

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
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_gas_station,
                          size: 40,
                          color: isFavorite ? AppColors.favorite : AppColors.primary,
                        ),
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
                        final modalFilterState = context.watch<FilterCubit>().state;
                        final selectedFuel = modalFilterState.selectedFuel;
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StationDetailsScreen(initialStation: station)));
                      },
                    ),
                  ],
                ),
                if (isFavorite)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.star,
                      color: AppColors.favorite,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      child: Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            markerIcon,
            if (isHighlighted)
              Positioned(
                bottom: 65,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFavorite ? AppColors.favorite : Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        station.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: isFavorite ? AppColors.favorite : Colors.black87, size: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
