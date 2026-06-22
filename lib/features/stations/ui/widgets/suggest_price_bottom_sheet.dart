import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/station_model.dart';
import '../../models/fuel_type.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../suggestions/repositories/suggestion_repository.dart';

class SuggestPriceBottomSheet extends StatefulWidget {
  final StationModel station;
  final FuelType? initialFuelType;

  const SuggestPriceBottomSheet({super.key, required this.station, this.initialFuelType});

  @override
  State<SuggestPriceBottomSheet> createState() => _SuggestPriceBottomSheetState();
}

class _SuggestPriceBottomSheetState extends State<SuggestPriceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  FuelType? _selectedFuel;
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedFuel = widget.initialFuelType;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _submitSuggestion() async {
    if (_formKey.currentState!.validate() && _selectedFuel != null) {
      setState(() {
        _isLoading = true;
      });

      final authState = context.read<AuthCubit>().state;
      String userId = 'anonymous';
      if (authState is Authenticated) {
        userId = authState.user.uid;
      }

      try {
        await context.read<SuggestionRepository>().addSuggestion(
          stationId: widget.station.id,
          stationName: widget.station.name,
          userId: userId,
          fuelType: _selectedFuel!.displayName,
          suggestedPrice: double.parse(_priceController.text.replaceAll(',', '.')),
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sugestão enviada com sucesso! Ela será avaliada por um administrador.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao enviar sugestão. Tente novamente.')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_selectedFuel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de combustível')),
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
                'Sugerir Preço - ${widget.station.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FuelType>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedFuel,
                items: FuelType.values.map((FuelType type) {
                  return DropdownMenuItem<FuelType>(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (FuelType? newValue) {
                  setState(() {
                    _selectedFuel = newValue;
                  });
                },
                validator: (value) => value == null ? 'Selecione um combustível' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço Sugerido (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Digite um preço';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Preço inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitSuggestion,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Enviar Sugestão', style: TextStyle(fontSize: 16)),
                      ),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
