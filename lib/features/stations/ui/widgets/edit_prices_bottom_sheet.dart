import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/station_model.dart';
import '../../models/price_model.dart';
import '../../models/fuel_type.dart';
import '../../cubit/station_cubit.dart';

class EditPricesBottomSheet extends StatefulWidget {
  final StationModel station;

  const EditPricesBottomSheet({super.key, required this.station});

  @override
  State<EditPricesBottomSheet> createState() => _EditPricesBottomSheetState();
}

class _EditPricesBottomSheetState extends State<EditPricesBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  final Map<String, TextEditingController> _controllers = {};

  final List<String> fuelTypes = FuelType.values.map((e) => e.displayName).toList();

  @override
  void initState() {
    super.initState();
    for (var type in fuelTypes) {
      final existingPrice = widget.station.prices.firstWhere(
        (p) => p.fuelType == type, 
        orElse: () => PriceModel(fuelType: type, price: 0.0, updatedAt: DateTime.now())
      );
      _controllers[type] = TextEditingController(
        text: existingPrice.price > 0 ? existingPrice.price.toStringAsFixed(2) : ''
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _savePrices() {
    if (_formKey.currentState!.validate()) {
      List<PriceModel> newPrices = [];
      for (var type in fuelTypes) {
        final text = _controllers[type]!.text.replaceAll(',', '.');
        final double price = double.tryParse(text) ?? 0.0;
        if (price > 0) {
          newPrices.add(PriceModel(fuelType: type, price: price, updatedAt: DateTime.now()));
        }
      }

      final newPricesMap = newPrices.map((p) => p.toMap()).toList();
      context.read<StationCubit>().updatePrices(widget.station.id, newPricesMap);
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preços atualizados com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Editar Preços - ${widget.station.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...fuelTypes.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _controllers[type],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: type,
                    border: const OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final val = double.tryParse(value.replaceAll(',', '.'));
                      if (val == null) return 'Valor inválido';
                    }
                    return null;
                  },
                ),
              )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePrices,
                child: const Text('Salvar Preços'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
