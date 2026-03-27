import 'dart:async';
import 'dart:io';

import 'package:azan_app/ads/sticky_bottom_banner_ad.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  static const MethodChannel _tasbihFeedbackChannel = MethodChannel(
    'azan_app/tasbih_feedback',
  );
  bool _showCustomCounter = false;
  int _customCount = 0;
  bool _enableVibration = true;
  bool _enableSound = true;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final style = context.select<AppController, ThemeStyleOption>(
      (c) => c.themeStyle,
    );
    final l10n = context.l10n;
    final isCompleted = controller.isTasbihCompleted;
    final stepLabel = 'Step ${controller.currentStep} of 3';
    final currentName = controller.currentTasbihName;
    final currentCount = controller.currentTasbihStepCount;
    final currentTarget = controller.currentTasbihTarget;
    final totalCount = controller.tasbihCount;

    final autoPresetTarget = _autoPresetTarget(totalCount);
    final presetCount = totalCount > autoPresetTarget
        ? autoPresetTarget
        : totalCount;
    final presetProgress = autoPresetTarget == 0
        ? 0.0
        : (presetCount / autoPresetTarget).clamp(0.0, 1.0);

    return Scaffold(
      bottomNavigationBar: const StickyBottomBannerAd(topSpacing: 8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.tr('tasbihCounter'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.tr('resetCounter'),
                  onPressed: () => _confirmReset(context, controller),
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ],
            ),
            Text(
              l10n.tr('tasbihSubtitle'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            AppSurfaceCard(
              gradient: AppGradients.alternativeFor(style),
              child: Column(
                children: <Widget>[
                  _FeedbackToggleRow(
                    enableSound: _enableSound,
                    enableVibration: _enableVibration,
                    onToggleSound: (value) {
                      setState(() => _enableSound = value);
                      if (value) {
                        _playSoundFeedback();
                      }
                    },
                    onToggleVibration: (value) {
                      setState(() => _enableVibration = value);
                      if (value) {
                        unawaited(_playVibrationFeedback());
                      }
                    },
                    darkSurface: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tip: Enable touch sound and haptic feedback in phone settings.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 274,
                    width: 274,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox.expand(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(end: presetProgress),
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 9,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.18,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.secondary,
                                ),
                              );
                            },
                          ),
                        ),
                        _TapCounterButton(
                          enabled: !isCompleted,
                          count: presetCount,
                          target: autoPresetTarget,
                          onTap: () async {
                            _triggerTapFeedback();
                            await controller.incrementTasbih();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$currentName: $currentCount / $currentTarget',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: <Widget>[
                      _PresetStagePill(
                        label: '33',
                        active: autoPresetTarget == 33,
                      ),
                      _PresetStagePill(
                        label: '66',
                        active: autoPresetTarget == 66,
                      ),
                      _PresetStagePill(
                        label: '99',
                        active: autoPresetTarget == 99,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$presetCount / $autoPresetTarget',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isCompleted) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      'Completed. MashaAllah!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _showCustomCounter = !_showCustomCounter);
              },
              icon: Icon(
                _showCustomCounter
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              label: const Text('Custom Count'),
            ),
            if (_showCustomCounter) ...<Widget>[
              const SizedBox(height: 10),
              AppSurfaceCard(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Custom Count',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.tr('resetCounter'),
                          onPressed: () => setState(() => _customCount = 0),
                          icon: const Icon(Icons.restart_alt_rounded),
                        ),
                      ],
                    ),
                    _FeedbackToggleRow(
                      enableSound: _enableSound,
                      enableVibration: _enableVibration,
                      onToggleSound: (value) {
                        setState(() => _enableSound = value);
                        if (value) {
                          _playSoundFeedback();
                        }
                      },
                      onToggleVibration: (value) {
                        setState(() => _enableVibration = value);
                        if (value) {
                          unawaited(_playVibrationFeedback());
                        }
                      },
                      darkSurface: false,
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    _CustomCounterButton(
                      count: _customCount,
                      onTap: () {
                        _triggerTapFeedback();
                        setState(() => _customCount += 1);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _autoPresetTarget(int totalCount) {
    if (totalCount >= 66) return 99;
    if (totalCount >= 33) return 66;
    return 33;
  }

  void _triggerTapFeedback() {
    if (_enableSound) {
      _playSoundFeedback();
    }

    if (_enableVibration) {
      unawaited(_playVibrationFeedback());
    }
  }

  void _playSoundFeedback() {
    if (!kIsWeb && Platform.isAndroid) {
      unawaited(_playNativeTickAndroid());
      return;
    }

    Feedback.forTap(context);
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  Future<void> _playNativeTickAndroid() async {
    try {
      await _tasbihFeedbackChannel.invokeMethod<void>('playTick');
    } catch (_) {
      if (!mounted) return;
      Feedback.forTap(context);
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> _playVibrationFeedback() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 12));
      await HapticFeedback.selectionClick();
    } catch (_) {
      try {
        await HapticFeedback.vibrate();
      } catch (_) {
        await HapticFeedback.mediumImpact();
      }
    }
  }

  Future<void> _confirmReset(
    BuildContext context,
    AppController controller,
  ) async {
    final l10n = context.l10n;
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.tr('resetCounter')),
          content: const Text('Reset your tasbih progress?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.tr('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.tr('resetCounter')),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      await controller.resetTasbih();
    }
  }
}

class _TapCounterButton extends StatefulWidget {
  const _TapCounterButton({
    required this.enabled,
    required this.count,
    required this.target,
    required this.onTap,
  });

  final bool enabled;
  final int count;
  final int target;
  final Future<void> Function() onTap;

  @override
  State<_TapCounterButton> createState() => _TapCounterButtonState();
}

class _TapCounterButtonState extends State<_TapCounterButton> {
  bool _pressed = false;

  Future<void> _handleTap() async {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
    await widget.onTap();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (!mounted) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: _pressed ? 0.965 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? _handleTap : null,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 238,
            height: 238,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  const Color(0xFF10213A),
                  widget.enabled
                      ? scheme.secondary
                      : scheme.secondary.withValues(alpha: 0.45),
                ],
              ),
              border: Border.all(
                color: widget.enabled
                    ? scheme.secondary.withValues(alpha: 0.72)
                    : scheme.secondary.withValues(alpha: 0.34),
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: scheme.secondary.withValues(
                    alpha: widget.enabled ? 0.32 : 0.16,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    '${widget.count}',
                    key: ValueKey<int>(widget.count),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 66,
                      height: 1.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '/ ${widget.target}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    height: 1.0,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.enabled ? l10n.tr('tap') : l10n.tr('done'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomCounterButton extends StatefulWidget {
  const _CustomCounterButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  State<_CustomCounterButton> createState() => _CustomCounterButtonState();
}

class _CustomCounterButtonState extends State<_CustomCounterButton> {
  bool _pressed = false;

  Future<void> _handleTap() async {
    setState(() => _pressed = true);
    widget.onTap();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: <Color>[
                  scheme.primary.withValues(alpha: 0.88),
                  scheme.secondary.withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  '${widget.count}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to count',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.94),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetStagePill extends StatelessWidget {
  const _PresetStagePill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active
            ? Theme.of(context).colorScheme.secondary
            : Colors.white.withValues(alpha: 0.12),
        border: Border.all(
          color: active
              ? Theme.of(context).colorScheme.secondary
              : Colors.white.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: active
              ? Theme.of(context).colorScheme.onSecondary
              : Colors.white.withValues(alpha: 0.92),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeedbackToggleRow extends StatelessWidget {
  const _FeedbackToggleRow({
    required this.enableSound,
    required this.enableVibration,
    required this.onToggleSound,
    required this.onToggleVibration,
    required this.darkSurface,
    this.compact = false,
  });

  final bool enableSound;
  final bool enableVibration;
  final ValueChanged<bool> onToggleSound;
  final ValueChanged<bool> onToggleVibration;
  final bool darkSurface;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 16.0 : 18.0;
    final scheme = Theme.of(context).colorScheme;
    final selectedShadowColor = Colors.black.withValues(alpha: 0.22);
    final selectedForeground =
        ThemeData.estimateBrightnessForColor(scheme.secondary) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
    final baseForeground = darkSurface
        ? Colors.white.withValues(alpha: 0.92)
        : scheme.onSurface.withValues(alpha: 0.86);
    final baseBg = darkSurface
        ? Colors.white.withValues(alpha: 0.09)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.85);
    final baseBorder = darkSurface
        ? Colors.white.withValues(alpha: 0.28)
        : scheme.outline.withValues(alpha: 0.45);
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: baseForeground,
      fontWeight: FontWeight.w700,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: <Widget>[
        FilterChip(
          selected: enableVibration,
          onSelected: onToggleVibration,
          showCheckmark: true,
          checkmarkColor: selectedForeground,
          elevation: enableVibration ? 3 : 0,
          pressElevation: 0,
          shadowColor: selectedShadowColor,
          avatar: Icon(
            enableVibration
                ? Icons.vibration_rounded
                : Icons.vibration_outlined,
            color: enableVibration ? selectedForeground : baseForeground,
            size: iconSize,
          ),
          label: Text(
            'Vibration',
            style: textStyle?.copyWith(
              color: enableVibration ? selectedForeground : baseForeground,
              fontWeight: enableVibration ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
          selectedColor: scheme.secondary,
          backgroundColor: baseBg,
          side: BorderSide(
            color: enableVibration ? scheme.secondary : baseBorder,
            width: enableVibration ? 1.8 : 1.0,
          ),
        ),
        FilterChip(
          selected: enableSound,
          onSelected: onToggleSound,
          showCheckmark: true,
          checkmarkColor: selectedForeground,
          elevation: enableSound ? 3 : 0,
          pressElevation: 0,
          shadowColor: selectedShadowColor,
          avatar: Icon(
            enableSound ? Icons.graphic_eq_rounded : Icons.graphic_eq_outlined,
            color: enableSound ? selectedForeground : baseForeground,
            size: iconSize,
          ),
          label: Text(
            'Sound',
            style: textStyle?.copyWith(
              color: enableSound ? selectedForeground : baseForeground,
              fontWeight: enableSound ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
          selectedColor: scheme.secondary,
          backgroundColor: baseBg,
          side: BorderSide(
            color: enableSound ? scheme.secondary : baseBorder,
            width: enableSound ? 1.8 : 1.0,
          ),
        ),
      ],
    );
  }
}
