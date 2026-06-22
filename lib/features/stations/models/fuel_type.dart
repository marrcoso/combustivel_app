enum FuelType {
  gasolinaComum('Gasolina Comum'),
  gasolinaAditivada('Gasolina Aditivada'),
  etanol('Etanol'),
  dieselComum('Diesel Comum'),
  dieselS10('Diesel S10'),
  gnv('GNV');

  final String displayName;
  const FuelType(this.displayName);
}
