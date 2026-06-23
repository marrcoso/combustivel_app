import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../stations/models/fuel_type.dart';
import '../../cubit/filter_cubit.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final filterState = context.watch<FilterCubit>().state;
    final selectedFuel = filterState.selectedFuel;
    final maxDistance = filterState.maxDistanceRadius;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrar por Combustível',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (selectedFuel != null)
                TextButton(
                  onPressed: () {
                    context.read<FilterCubit>().updateSelectedFuel(null);
                  },
                  child: const Text('Limpar'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: FuelType.values.map((type) {
              final isSelected = selectedFuel == type;
              return ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  context.read<FilterCubit>().updateSelectedFuel(selected ? type : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Distância Máxima',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (maxDistance != null)
                TextButton(
                  onPressed: () {
                    context.read<FilterCubit>().updateMaxDistance(null);
                  },
                  child: const Text('Ilimitado'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            maxDistance == null ? 'Distância Ilimitada' : 'Até ${maxDistance.toInt()} km',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: maxDistance ?? 50.0,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            label: maxDistance == null ? 'Ilimitado' : '${maxDistance.toInt()} km',
            onChanged: (value) {
              context.read<FilterCubit>().updateMaxDistance(value == 50.0 ? null : value);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar Filtros'),
          ),
        ],
      ),
    );
  }
}
