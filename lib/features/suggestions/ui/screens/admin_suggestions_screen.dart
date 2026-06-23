import 'package:combustivel_ap/components/custom_snack_bar.dart' show CustomSnackBar;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../stations/cubit/station_cubit.dart';
import '../../../stations/cubit/station_state.dart';
import '../../../stations/models/price_model.dart';
import '../../cubit/suggestion_cubit.dart';
import '../../cubit/suggestion_state.dart';

class AdminSuggestionsScreen extends StatelessWidget {
  const AdminSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprovações Pendentes'),
      ),
      body: BlocBuilder<SuggestionCubit, SuggestionState>(
        builder: (context, state) {
          if (state is SuggestionLoading || state is SuggestionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SuggestionError) {
            return Center(child: Text('Erro: ${state.message}'));
          }

          if (state is SuggestionLoaded) {
            if (state.suggestions.isEmpty) {
              return const Center(child: Text('Nenhuma sugestão pendente no momento.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = state.suggestions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.stationName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Combustível: ${suggestion.fuelType}', style: const TextStyle(fontSize: 16)),
                        Text(
                          'Preço Sugerido: R\$ ${suggestion.suggestedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                context.read<SuggestionCubit>().rejectSuggestion(suggestion.id);
                                CustomSnackBar.error(context, 'Sugestão rejeitada.');
                              },
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text('Rejeitar', style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final stationCubit = context.read<StationCubit>();
                                final suggestionCubit = context.read<SuggestionCubit>();
                                
                                final stationState = stationCubit.state;
                                
                                if (stationState is StationLoaded) {
                                  try {
                                    final station = stationState.stations.firstWhere((s) => s.id == suggestion.stationId);
                                    
                                    final newPrices = station.prices.map((p) => p).toList();
                                    final existingIndex = newPrices.indexWhere((p) => p.fuelType == suggestion.fuelType);
                                    
                                    if (existingIndex >= 0) {
                                      newPrices[existingIndex] = newPrices[existingIndex].copyWith(
                                        price: suggestion.suggestedPrice,
                                        updatedAt: DateTime.now(),
                                      );
                                    } else {
                                      newPrices.add(PriceModel(
                                        fuelType: suggestion.fuelType,
                                        price: suggestion.suggestedPrice,
                                        updatedAt: DateTime.now(),
                                      ));
                                    }

                                    final newPricesMap = newPrices.map((p) => p.toMap()).toList();
                                    
                                    // 1. Atualiza primeiro o preço globalmente
                                    await stationCubit.updatePrices(suggestion.stationId, newPricesMap);

                                    // 2. Só depois aprova o status (o que fará o botão sumir)
                                    await suggestionCubit.approveSuggestion(suggestion.id);

                                    CustomSnackBar.success(context, 'Sugestão APROVADA e preço atualizado!');
                                  } catch (e) {
                                    CustomSnackBar.error(context, 'Erro: $e');
                                  }
                                } else {
                                  CustomSnackBar.error(context, 'Erro: Postos não carregados ainda.');
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Aprovar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
