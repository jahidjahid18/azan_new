import 'dart:math';

import 'package:azan_app/ads/sticky_bottom_banner_ad.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  static const String _assetPrefix = 'assets/images/puzzle/';
  static const List<String> _fallbackImages = <String>[
    'assets/images/puzzle/imagee1.jpg',
  ];
  static const List<_PuzzleLevel> _levels = <_PuzzleLevel>[
    _PuzzleLevel(label: 'Easy', size: 3),
    _PuzzleLevel(label: 'Medium', size: 4),
    _PuzzleLevel(label: 'Hard', size: 5),
  ];

  final Random _random = Random();

  bool _isLoading = true;
  String? _errorText;
  int _selectedGridSize = 3;
  List<String> _imageAssets = <String>[];
  String? _selectedImage;
  List<Uint8List> _tileImages = <Uint8List>[];
  List<int> _tiles = <int>[];
  int _moves = 0;
  bool _isSolved = false;
  bool _isShowingHint = false;

  int get _tileCount => _selectedGridSize * _selectedGridSize;

  @override
  void initState() {
    super.initState();
    _loadImagesAndStart();
  }

  Future<void> _loadImagesAndStart() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
      _imageAssets = <String>[];
      _selectedImage = null;
      _tileImages = <Uint8List>[];
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
    await _startPuzzle();
  }

  Future<void> _startPuzzle({bool useRandomImage = false}) async {
    if (_imageAssets.isEmpty) return;

    setState(() => _isLoading = true);

    if (useRandomImage) {
      _selectedImage = _imageAssets[_random.nextInt(_imageAssets.length)];
    } else {
      _selectedImage ??= _imageAssets.first;
    }

    try {
      final tiles = await _splitImageIntoTiles(
        imagePath: _selectedImage!,
        gridSize: _selectedGridSize,
      );

      if (!mounted) return;

      final order = List<int>.generate(_tileCount, (i) => i)..shuffle(_random);
      if (_isOrdered(order)) {
        final last = order.last;
        order[_tileCount - 1] = order[_tileCount - 2];
        order[_tileCount - 2] = last;
      }

      setState(() {
        _isLoading = false;
        _errorText = null;
        _tileImages = tiles;
        _tiles = order;
        _moves = 0;
        _isSolved = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Unable to load puzzle image.';
      });
    }
  }

  Future<List<Uint8List>> _splitImageIntoTiles({
    required String imagePath,
    required int gridSize,
  }) async {
    final imageBytes = await rootBundle.load(imagePath);
    final raw = imageBytes.buffer.asUint8List(
      imageBytes.offsetInBytes,
      imageBytes.lengthInBytes,
    );
    final decoded = img.decodeImage(raw);
    if (decoded == null) {
      throw Exception('Unable to decode image: $imagePath');
    }

    final edge = min(decoded.width, decoded.height);
    final offsetX = (decoded.width - edge) ~/ 2;
    final offsetY = (decoded.height - edge) ~/ 2;
    final square = img.copyCrop(
      decoded,
      x: offsetX,
      y: offsetY,
      width: edge,
      height: edge,
    );

    final tileWidth = square.width ~/ gridSize;
    final tileHeight = square.height ~/ gridSize;
    final pieces = <Uint8List>[];

    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        final x = col * tileWidth;
        final y = row * tileHeight;
        final width = col == gridSize - 1 ? square.width - x : tileWidth;
        final height = row == gridSize - 1 ? square.height - y : tileHeight;

        final tile = img.copyCrop(
          square,
          x: x,
          y: y,
          width: width,
          height: height,
        );
        pieces.add(Uint8List.fromList(img.encodePng(tile)));
      }
    }

    return pieces;
  }

  Future<void> _nextImage() async {
    if (_imageAssets.isEmpty) return;
    final current = _selectedImage ?? _imageAssets.first;
    final index = _imageAssets.indexOf(current);
    final nextIndex = index < 0 ? 0 : (index + 1) % _imageAssets.length;
    _selectedImage = _imageAssets[nextIndex];
    await _startPuzzle();
  }

  Future<void> _showHint() async {
    if (_selectedImage == null || _isShowingHint) return;
    setState(() => _isShowingHint = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isShowingHint = false);
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
    final solved = _isOrdered(next);

    setState(() {
      _tiles = next;
      _moves += 1;
      _isSolved = solved;
    });

    if (solved) {
      _showCompletedDialog();
    }
  }

  Future<void> _showCompletedDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Puzzle Completed!'),
          content: const Text('MashaAllah, you matched all the pieces.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _startPuzzle();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final hasImages = _imageAssets.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Puzzle')),
      bottomNavigationBar: const StickyBottomBannerAd(topSpacing: 8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
              children: <Widget>[
                if (_errorText != null)
                  AppSurfaceCard(
                    child: Text(_errorText!, textAlign: TextAlign.center),
                  )
                else if (!hasImages)
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('Moves: $_moves'),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<int>(
                          showSelectedIcon: false,
                          segments: _levels
                              .map(
                                (level) => ButtonSegment<int>(
                                  value: level.size,
                                  label: Text(
                                    '${level.label} ${level.size}x${level.size}',
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          selected: <int>{_selectedGridSize},
                          onSelectionChanged: (Set<int> values) async {
                            final size = values.first;
                            if (_selectedGridSize == size) {
                              return;
                            }
                            setState(() => _selectedGridSize = size);
                            await _startPuzzle();
                          },
                        ),
                        const SizedBox(height: 10),
                        AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: _selectedGridSize,
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
                                    builder:
                                        (context, candidateData, rejectedData) {
                                          final highlighted =
                                              candidateData.isNotEmpty;
                                          return Draggable<int>(
                                            data: index,
                                            feedback: SizedBox(
                                              width: 92,
                                              height: 92,
                                              child: _PuzzlePieceTile(
                                                imageBytes:
                                                    _tileImages[pieceIndex],
                                                highlighted: true,
                                              ),
                                            ),
                                            childWhenDragging: Opacity(
                                              opacity: 0.35,
                                              child: _PuzzlePieceTile(
                                                imageBytes:
                                                    _tileImages[pieceIndex],
                                              ),
                                            ),
                                            child: _PuzzlePieceTile(
                                              imageBytes:
                                                  _tileImages[pieceIndex],
                                              highlighted: highlighted,
                                            ),
                                          );
                                        },
                                  );
                                },
                              ),
                              AnimatedOpacity(
                                opacity: _isShowingHint ? 1 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: IgnorePointer(
                                  ignoring: !_isShowingHint,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.asset(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Chip(label: Text('Hint')),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _PuzzleActionButton(
                                    icon: Icons.lightbulb_outline_rounded,
                                    label: 'Hint',
                                    onTap: () async {
                                      await _showHint();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _PuzzleActionButton(
                                    icon: Icons.image_search_rounded,
                                    label: 'Change Image',
                                    onTap: () async {
                                      await _startPuzzle(useRandomImage: true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _PuzzleActionButton(
                                    icon: Icons.refresh_rounded,
                                    label: 'Reset Image',
                                    onTap: () async {
                                      await _startPuzzle();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _PuzzleActionButton(
                                    icon: Icons.skip_next_rounded,
                                    label: 'Next Image',
                                    onTap: () async {
                                      await _nextImage();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PuzzleLevel {
  const _PuzzleLevel({required this.label, required this.size});

  final String label;
  final int size;
}

class _PuzzlePieceTile extends StatelessWidget {
  const _PuzzlePieceTile({required this.imageBytes, this.highlighted = false});

  final Uint8List imageBytes;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
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
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

class _PuzzleActionButton extends StatelessWidget {
  const _PuzzleActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () async {
        await onTap();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        textStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
