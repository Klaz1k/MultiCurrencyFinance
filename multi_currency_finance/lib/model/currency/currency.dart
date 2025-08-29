class Currency {
  late final String id;
  late String name;
  late String abbreviation;
  late String symbol;
  late final bool isMain; //TODO: Maybe find a way to make it changeable after it has been assigned (Meaning that exchange rates could change throughout the whole history and current accounts) Only maybe though

  Currency({required this.id, required this.name, required this.abbreviation, required this.symbol, required this.isMain});

  Currency clone() {
    return Currency(
      id: this.id, 
      name: this.name, 
      abbreviation: this.abbreviation, 
      symbol: this.symbol, 
      isMain: this.isMain
    );
  }
}
