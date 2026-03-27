import 'dart:async';
import 'dart:math';

import 'package:azan_app/ads/sticky_bottom_banner_ad.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class Puzzle2Screen extends StatefulWidget {
  const Puzzle2Screen({super.key});

  @override
  State<Puzzle2Screen> createState() => _Puzzle2ScreenState();
}

class _Puzzle2ScreenState extends State<Puzzle2Screen> {
  static const String _assetPrefix = 'assets/images/puzzle/';
  static const List<String> _fallbackImages = <String>[
    'assets/images/puzzle/imagee1.jpg',
  ];
  static const List<_Puzzle2Level> _levels = <_Puzzle2Level>[
    _Puzzle2Level(label: 'Easy', size: 3),
    _Puzzle2Level(label: 'Medium', size: 4),
    _Puzzle2Level(label: 'Hard', size: 5),
  ];

  final Random _random = Random();
  final Stopwatch _stopwatch = Stopwatch();

  bool _isLoading = true;
  String? _errorText;
  int _gridSize = 3;
  List<String> _imageAssets = <String>[];
  String? _selectedImage;
  List<Uint8List?> _tileImages = <Uint8List?>[];
  List<int> _board = <int>[];
  int _moves = 0;
  Duration _elapsed = Duration.zero;
  bool _isSolved = false;
  Timer? _ticker;

  int get _tileCount => _gridSize * _gridSize;
  int get _emptyTileId => _tileCount - 1;

  @override
  void initState() {
    super.initState();
    _loadImagesAndStart();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _loadImagesAndStart() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
      _imageAssets = <String>[];
      _selectedImage = null;
      _tileImages = <Uint8List?>[];
      _board = <int>[];
      _moves = 0;
      _elapsed = Duration.zero;
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
      // Use fallback assets when manifest parsing fails.
    }

    final assets = discovered.toList()..sort();
    if (!mounted) return;

    if (assets.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorText = 'No puzzle images found.';
      });
      return;
    }

    _imageAssets = assets;
    _selectedImage = _imageAssets[_random.nextInt(_imageAssets.length)];
    await _startPuzzle();
  }

  Future<void> _startPuzzle({bool randomizeImage = false}) async {
    if (_imageAssets.isEmpty) return;
    setState(() => _isLoading = true);

    if (randomizeImage) {
      _selectedImage = _imageAssets[_random.nextInt(_imageAssets.length)];
    } else {
      _selectedImage ??= _imageAssets.first;
    }

    try {
      final tiles = await _splitImageIntoTiles(
        imagePath: _selectedImage!,
        gridSize: _gridSize,
      );
      final board = _createSolvableBoard();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = null;
        _tileImages = tiles;
        _board = board;
        _moves = 0;
        _elapsed = Duration.zero;
        _isSolved = false;
      });
      _startTimer();
    } catch (_) {
      _stopTimer();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Unable to load puzzle image.';
      });
    }
  }

  Future<List<Uint8List?>> _splitImageIntoTiles({
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
    final pieces = List<Uint8List?>.filled(_tileCount, null, growable: false);

    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        final index = row * gridSize + col;
        if (index == _tileCount - 1) {
          continue;
        }

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
        pieces[index] = Uint8List.fromList(img.encodePng(tile));
      }
    }

    return pieces;
  }

  List<int> _createSolvableBoard() {
    final board = List<int>.generate(_tileCount, (i) => i);
    do {
      board.shuffle(_random);
    } while (!_isSolvable(board) || _isSolvedBoard(board));
    return board;
  }

  bool _isSolvable(List<int> board) {
    var inversions = 0;
    for (var i = 0; i < board.length; i++) {
      for (var j = i + 1; j < board.length; j++) {
        final left = board[i];
        final right = board[j];
        if (left == _emptyTileId || right == _emptyTileId) {
          continue;
        }
        if (left > right) {
          inversions++;
        }
      }
    }

    if (_gridSize.isOdd) {
      return inversions.isEven;
    }

    final blankIndex = board.indexOf(_emptyTileId);
    final blankRowFromBottom = _gridSize - (blankIndex ~/ _gridSize);
    if (blankRowFromBottom.isEven) {
      return inversions.isOdd;
    }
    return inversions.isEven;
  }

  bool _isSolvedBoard(List<int> board) {
    for (var i = 0; i < board.length; i++) {
      if (board[i] != i) {
        return false;
      }
    }
    return true;
  }

  void _startTimer() {
    _ticker?.cancel();
    _stopwatch
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isSolved) return;
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    });
  }

  void _stopTimer() {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();
  }

  Future<void> _showHint() async {
    if (_selectedImage == null) return;
    var hintOpen = true;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Puzzle Hint',
                    style: Theme.of(dialogContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(_selectedImage!, fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((_) {
        hintOpen = false;
      }),
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted || !hintOpen) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  bool _tryMoveTile(int boardIndex, {int? requiredEmptyIndex}) {
    if (_isLoading || _isSolved) return false;
    final emptyIndex = _board.indexOf(_emptyTileId);
    if (requiredEmptyIndex != null && emptyIndex != requiredEmptyIndex) {
      return false;
    }
    if (!_isAdjacent(boardIndex, emptyIndex)) {
      return false;
    }

    final next = List<int>.from(_board);
    final tapped = next[boardIndex];
    next[boardIndex] = _emptyTileId;
    next[emptyIndex] = tapped;

    final solved = _isSolvedBoard(next);
    setState(() {
      _board = next;
      _moves += 1;
      _isSolved = solved;
      _elapsed = _stopwatch.elapsed;
    });

    if (solved) {
      _stopTimer();
      _showCompletedDialog();
    }
    return true;
  }

  void _onTileTap(int boardIndex) {
    _tryMoveTile(boardIndex);
  }

  void _onTileSwipe(int boardIndex, DragEndDetails details) {
    if (_isSolved || _isLoading) return;
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.distanceSquared < 2000) {
      return;
    }

    final row = boardIndex ~/ _gridSize;
    final col = boardIndex % _gridSize;
    int expectedEmpty = -1;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx > 0 && col < _gridSize - 1) {
        expectedEmpty = boardIndex + 1;
      } else if (velocity.dx < 0 && col > 0) {
        expectedEmpty = boardIndex - 1;
      }
    } else {
      if (velocity.dy > 0 && row < _gridSize - 1) {
        expectedEmpty = boardIndex + _gridSize;
      } else if (velocity.dy < 0 && row > 0) {
        expectedEmpty = boardIndex - _gridSize;
      }
    }

    if (expectedEmpty >= 0) {
      _tryMoveTile(boardIndex, requiredEmptyIndex: expectedEmpty);
    }
  }

  bool _isAdjacent(int a, int b) {
    final rowA = a ~/ _gridSize;
    final colA = a % _gridSize;
    final rowB = b ~/ _gridSize;
    final colB = b % _gridSize;
    final distance = (rowA - rowB).abs() + (colA - colB).abs();
    return distance == 1;
  }

  Future<void> _showCompletedDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Puzzle Completed!'),
          content: Text(
            'MashaAllah!\nMoves: $_moves\nTime: ${_formatDuration(_elapsed)}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _startPuzzle(randomizeImage: true);
              },
              child: const Text('Next Puzzle'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Puzzle 2')),
      bottomNavigationBar: const StickyBottomBannerAd(topSpacing: 8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 96 + bottomPadding),
              children: <Widget>[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: AppSurfaceCard(
                      radius: 22,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (_errorText != null) ...<Widget>[
                            const SizedBox(height: 14),
                            Text(
                              _errorText!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ] else ...<Widget>[
                            const SizedBox(height: 12),
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
                              selected: <int>{_gridSize},
                              onSelectionChanged: (values) async {
                                final selected = values.first;
                                if (selected == _gridSize) return;
                                setState(() {
                                  _gridSize = selected;
                                });
                                await _startPuzzle();
                              },
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _InfoChip(
                                    icon: Icons.swap_horiz_rounded,
                                    label: 'Moves',
                                    value: '$_moves',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _InfoChip(
                                    icon: Icons.timer_outlined,
                                    label: 'Time',
                                    value: _formatDuration(_elapsed),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            AspectRatio(
                              aspectRatio: 1,
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: _gridSize,
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 6,
                                    ),
                                itemCount: _tileCount,
                                itemBuilder: (context, boardIndex) {
                                  final tileId = _board[boardIndex];
                                  final isEmpty = tileId == _emptyTileId;
                                  final bytes = isEmpty
                                      ? null
                                      : _tileImages[tileId];
                                  final emptyIndex = _board.indexOf(
                                    _emptyTileId,
                                  );
                                  final isMovable =
                                      !isEmpty &&
                                      !_isSolved &&
                                      _isAdjacent(boardIndex, emptyIndex);

                                  final tile = _SlidingTile(
                                    imageBytes: bytes,
                                    isEmpty: isEmpty,
                                    isMovable: isMovable,
                                    onTap: () => _onTileTap(boardIndex),
                                    onDragEnd: (details) =>
                                        _onTileSwipe(boardIndex, details),
                                    highlighted: false,
                                  );
                                  if (isEmpty) {
                                    return DragTarget<int>(
                                      onWillAcceptWithDetails: (details) {
                                        return !_isSolved &&
                                            _isAdjacent(
                                              details.data,
                                              boardIndex,
                                            );
                                      },
                                      onAcceptWithDetails: (details) {
                                        _tryMoveTile(
                                          details.data,
                                          requiredEmptyIndex: boardIndex,
                                        );
                                      },
                                      builder:
                                          (
                                            context,
                                            candidateData,
                                            rejectedData,
                                          ) {
                                            return _SlidingTile(
                                              imageBytes: null,
                                              isEmpty: true,
                                              isMovable: false,
                                              highlighted:
                                                  candidateData.isNotEmpty,
                                              onTap: () {},
                                            );
                                          },
                                    );
                                  }

                                  return Draggable<int>(
                                    data: boardIndex,
                                    feedback: SizedBox(
                                      width: 92,
                                      height: 92,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: _SlidingTile(
                                          imageBytes: bytes,
                                          isEmpty: false,
                                          isMovable: isMovable,
                                          highlighted: true,
                                          onTap: () {},
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.35,
                                      child: tile,
                                    ),
                                    child: tile,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tip: Tap adjacent tile, swipe, or drag tile to empty slot.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _BottomAction(
                                    icon: Icons.lightbulb_outline_rounded,
                                    label: 'Hint',
                                    onTap: _showHint,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _BottomAction(
                                    icon: Icons.image_search_rounded,
                                    label: 'Change',
                                    onTap: () =>
                                        _startPuzzle(randomizeImage: true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _BottomAction(
                                    icon: Icons.refresh_rounded,
                                    label: 'Reset',
                                    onTap: _startPuzzle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Puzzle2Level {
  const _Puzzle2Level({required this.label, required this.size});

  final String label;
  final int size;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 17),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SlidingTile extends StatelessWidget {
  const _SlidingTile({
    required this.imageBytes,
    required this.isEmpty,
    required this.isMovable,
    required this.onTap,
    this.onDragEnd,
    this.highlighted = false,
  });

  final Uint8List? imageBytes;
  final bool isEmpty;
  final bool isMovable;
  final VoidCallback onTap;
  final ValueChanged<DragEndDetails>? onDragEnd;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlighted
        ? Theme.of(context).colorScheme.secondary
        : isMovable
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.outlineVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: highlighted || isMovable ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanEnd: isEmpty ? null : onDragEnd,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: isEmpty ? null : onTap,
            child: isEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.memory(imageBytes!, fit: BoxFit.cover),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
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
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(42),
        textStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
