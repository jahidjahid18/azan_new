import 'dart:math';

import 'package:azan_app/ads/sticky_bottom_banner_ad.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  static const int _gridSize = 3;
  static const String _assetPrefix = 'assets/images/puzzle/';
  static const List<String> _fallbackImages = <String>[
    'assets/images/puzzle/imagee1.jpg',
  ];

  final Random _random = Random();

  bool _isLoading = true;
  List<String> _imageAssets = <String>[];
  String? _selectedImage;
  List<int> _tiles = <int>[];
  int _moves = 0;
  bool _isSolved = false;

  int get _tileCount => _gridSize * _gridSize;

  @override
  void initState() {
    super.initState();
    _loadImagesAndStart();
  }

  Future<void> _loadImagesAndStart() async {
    setState(() {
      _isLoading = true;
      _imageAssets = <String>[];
      _selectedImage = null;
      _tiles = <int>[];
      _moves = 0;
      _isSolved = false;
    });

    final discovered = <String>{..._fallbackImages};
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final puzzleAssets = manifest
          .listAssets()
          .where((path) => path.startsWith(_assetPrefix))
          .where(
            (path) =>
                path.toLowerCase().endsWith('.jpg') ||
                path.toLowerCase().endsWith('.jpeg') ||
                path.toLowerCase().endsWith('.png'),
          );
      discovered.addAll(puzzleAssets);
    } catch (_) {
      // Keep fallback image list so puzzle still works even if manifest parsing fails.
    }
    final puzzleAssets = discovered.toList()..sort();

    if (!mounted) return;
    if (puzzleAssets.isEmpty) {
      setState(() {
        _isLoading = false;
        _imageAssets = <String>[];
      });
      return;
    }

    _imageAssets = puzzleAssets;
    _selectedImage = _imageAssets.first;
    _startPuzzle();
  }

  void _startPuzzle({bool useRandomImage = false}) {
    if (_imageAssets.isEmpty) return;

    if (useRandomImage) {
      _selectedImage = _imageAssets[_random.nextInt(_imageAssets.length)];
    } else {
      _selectedImage ??= _imageAssets.first;
    }

    final tiles = List<int>.generate(_tileCount, (i) => i);
    for (var i = 0; i < 40; i++) {
      final a = _random.nextInt(_tileCount);
      final b = _random.nextInt(_tileCount);
      final temp = tiles[a];
      tiles[a] = tiles[b];
      tiles[b] = temp;
    }
    if (_isOrdered(tiles)) {
      final last = tiles.last;
      tiles[_tileCount - 1] = tiles[_tileCount - 2];
      tiles[_tileCount - 2] = last;
    }

    setState(() {
      _isLoading = false;
      _tiles = tiles;
      _moves = 0;
      _isSolved = false;
    });
  }

  void _nextImage() {
    if (_imageAssets.isEmpty) return;
    final current = _selectedImage ?? _imageAssets.first;
    final index = _imageAssets.indexOf(current);
    final nextIndex = index < 0 ? 0 : (index + 1) % _imageAssets.length;
    _selectedImage = _imageAssets[nextIndex];
    _startPuzzle();
  }

  bool _isOrdered(List<int> values) {
    return listEquals(values, List<int>.generate(_tileCount, (i) => i));
  }

  void _swapTiles(int from, int to) {
    if (from == to || _isSolved) return;
    final next = List<int>.from(_tiles);
    final temp = next[from];
    next[from] = next[to];
    next[to] = temp;

    setState(() {
      _tiles = next;
      _moves += 1;
      _isSolved = _isOrdered(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final hasImages = _imageAssets.isNotEmpty;
    final selectedFile = _selectedImage?.split('/').last ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Puzzle'),
      ),
      bottomNavigationBar: const StickyBottomBannerAd(topSpacing: 8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
              children: <Widget>[
                if (!hasImages)
                  const AppSurfaceCard(
                    child: Text(
                      'No puzzle images found.\nAdd files to assets/images/puzzle/ and restart the app.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Image: $selectedFile',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Moves: $_moves'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed: () => _startPuzzle(useRandomImage: true),
                              icon: const Icon(Icons.image_search_rounded),
                              label: const Text('Change Image'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _startPuzzle,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reset Image'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _nextImage,
                              icon: const Icon(Icons.skip_next_rounded),
                              label: const Text('Next Image'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AspectRatio(
                          aspectRatio: 1,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _gridSize,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            itemCount: _tileCount,
                            itemBuilder: (context, index) {
                              final pieceIndex = _tiles[index];
                              return DragTarget<int>(
                                onWillAcceptWithDetails: (details) {
                                  return details.data != index;
                                },
                                onAcceptWithDetails: (details) {
                                  _swapTiles(details.data, index);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  final highlighted = candidateData.isNotEmpty;
                                  return Draggable<int>(
                                    data: index,
                                    feedback: SizedBox(
                                      width: 92,
                                      height: 92,
                                      child: _PuzzlePieceTile(
                                        imagePath: _selectedImage!,
                                        pieceIndex: pieceIndex,
                                        gridSize: _gridSize,
                                        highlighted: true,
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.35,
                                      child: _PuzzlePieceTile(
                                        imagePath: _selectedImage!,
                                        pieceIndex: pieceIndex,
                                        gridSize: _gridSize,
                                      ),
                                    ),
                                    child: _PuzzlePieceTile(
                                      imagePath: _selectedImage!,
                                      pieceIndex: pieceIndex,
                                      gridSize: _gridSize,
                                      highlighted: highlighted,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (_isSolved) ...<Widget>[
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'MashaAllah! Puzzle completed.',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: _startPuzzle,
                                child: const Text('Play Again'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PuzzlePieceTile extends StatelessWidget {
  const _PuzzlePieceTile({
    required this.imagePath,
    required this.pieceIndex,
    required this.gridSize,
    this.highlighted = false,
  });

  final String imagePath;
  final int pieceIndex;
  final int gridSize;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final row = pieceIndex ~/ gridSize;
    final col = pieceIndex % gridSize;
    final alignment = Alignment(
      -1 + (2 * col + 1) / gridSize,
      -1 + (2 * row + 1) / gridSize,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: highlighted
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ClipRect(
          child: Align(
            alignment: alignment,
            widthFactor: 1 / gridSize,
            heightFactor: 1 / gridSize,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
