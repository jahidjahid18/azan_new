class QuranReciter {
  const QuranReciter({required this.name, required this.directory});

  final String name;
  final String directory;
}

const List<QuranReciter> kQuranReciters = <QuranReciter>[
  QuranReciter(name: 'Alafasy', directory: 'Alafasy_128kbps'),
  QuranReciter(name: 'Abdul Basit', directory: 'Abdul_Basit_Murattal_192kbps'),
  QuranReciter(name: 'Husary', directory: 'Husary_128kbps'),
];
