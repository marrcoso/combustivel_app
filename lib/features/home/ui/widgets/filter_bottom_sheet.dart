import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../stations/models/fuel_type.dart';
import '../../cubit/filter_cubit.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedFuel = context.watch<FilterCubit>().state.selectedFuel;

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
                    Navigator.pop(context);
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
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
