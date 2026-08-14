import 'package:flutter/material.dart';

import '../../../core/data/models/notification_values.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class NotificationTemplateEditor extends StatefulWidget {
  const NotificationTemplateEditor({
    super.key,
    required this.label,
    required this.initialTemplate,
    required this.variables,
    required this.enabled,
    required this.onChanged,
    this.hintText = 'Escribe el texto',
    this.maxLines = 2,
  });

  final String label;
  final String initialTemplate;
  final List<NotificationTemplateVariable> variables;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String hintText;
  final int maxLines;

  @override
  State<NotificationTemplateEditor> createState() =>
      _NotificationTemplateEditorState();
}

class _NotificationTemplateEditorState
    extends State<NotificationTemplateEditor> {
  final Map<int, TextEditingController> _textControllers = {};
  final Map<int, FocusNode> _focusNodes = {};
  final Map<int, GlobalKey> _textPartKeys = {};
  final Map<int, _DropCaretPosition> _dragCarets = {};
  List<_EditorPart> _parts = const [];
  int _nextPartId = 0;
  int? _activeTextPartId;
  TextSelection? _activeSelection;

  @override
  void initState() {
    super.initState();
    _resetParts(widget.initialTemplate);
  }

  @override
  void didUpdateWidget(covariant NotificationTemplateEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTemplate != widget.initialTemplate &&
        serializeNotificationTemplate(_toPublicParts()) !=
            widget.initialTemplate) {
      _resetParts(widget.initialTemplate);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _resetParts(String template) {
    _disposeControllers();
    final allowed = widget.variables.map((variable) => variable.key).toSet();
    final parsed = parseNotificationTemplate(
      template,
      allowedVariables: allowed,
    );
    _parts = parsed
        .map(
          (part) => _EditorPart(
            id: _nextPartId++,
            text: part.isToken ? '' : part.value,
            token: part.token,
          ),
        )
        .toList(growable: true);
    if (_parts.isEmpty) {
      _parts.add(_EditorPart(id: _nextPartId++, text: ''));
    }
    _activeTextPartId = null;
    _activeSelection = null;
    _dragCarets.clear();
  }

  void _disposeControllers() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _textControllers.clear();
    _focusNodes.clear();
  }

  List<NotificationTemplatePart> _toPublicParts() {
    return _parts
        .map(
          (part) => part.isToken
              ? NotificationTemplatePart.token(part.token!)
              : NotificationTemplatePart.text(part.text),
        )
        .toList(growable: false);
  }

  void _emitChanged() {
    widget.onChanged(serializeNotificationTemplate(_toPublicParts()));
    if (mounted) {
      setState(() {});
    }
  }

  TextEditingController _controllerFor(_EditorPart part) {
    return _textControllers.putIfAbsent(part.id, () {
      final controller = TextEditingController(text: part.text);
      controller.addListener(() {
        if (mounted && _focusNodes[part.id]?.hasFocus == true) {
          _setActiveTextPart(part, controller.selection);
        }
      });
      return controller;
    });
  }

  FocusNode _focusNodeFor(_EditorPart part) {
    return _focusNodes.putIfAbsent(part.id, FocusNode.new);
  }

  NotificationTemplateVariable? _variableFor(String key) {
    for (final variable in widget.variables) {
      if (variable.key == key) {
        return variable;
      }
    }
    return null;
  }

  void _setActiveTextPart(_EditorPart part, [TextSelection? selection]) {
    _activeTextPartId = part.id;
    _activeSelection = selection ?? _controllerFor(part).selection;
  }

  void _updateText(_EditorPart part, String value) {
    part.text = value;
    _setActiveTextPart(part);
    _emitChanged();
  }

  void _insertVariable(NotificationTemplateVariable variable) {
    final hasTokens = _parts.any((part) => part.isToken);
    if (!hasTokens) {
      final textIndex = _parts.lastIndexWhere(
        (part) => !part.isToken && part.text.isNotEmpty,
      );
      if (textIndex >= 0) {
        final textPart = _parts[textIndex];
        _insertTokenAtText(textPart, variable.key, textPart.text.length);
        return;
      }

      final emptyTextIndex = _parts.indexWhere((part) => !part.isToken);
      if (emptyTextIndex >= 0) {
        _insertTokenAtText(_parts[emptyTextIndex], variable.key, 0);
        return;
      }
    }

    final activeId = _activeTextPartId;
    final activeIndex = activeId == null
        ? -1
        : _parts.indexWhere((part) => part.id == activeId && !part.isToken);
    if (activeIndex >= 0) {
      final active = _parts[activeIndex];
      final controller = _controllerFor(active);
      final selection = _activeSelection ?? controller.selection;
      final offset = selection.baseOffset.clamp(0, active.text.length);
      _insertTokenAtText(active, variable.key, offset);
      return;
    }

    _parts.addAll([
      _EditorPart(id: _nextPartId++, token: variable.key),
      _EditorPart(id: _nextPartId++, text: ''),
    ]);
    _emitChanged();
  }

  void _insertTokenAtText(_EditorPart textPart, String token, int offset) {
    final textIndex = _parts.indexWhere((part) => part.id == textPart.id);
    if (textIndex < 0) {
      return;
    }
    final safeOffset = offset.clamp(0, textPart.text.length);
    final before = textPart.text.substring(0, safeOffset);
    final after = textPart.text.substring(safeOffset);
    final replacement = <_EditorPart>[];
    if (before.isNotEmpty) {
      replacement.add(_EditorPart(id: textPart.id, text: before));
    }
    replacement.add(_EditorPart(id: _nextPartId++, token: token));
    final trailing = _EditorPart(
      id: before.isEmpty ? textPart.id : _nextPartId++,
      text: after,
    );
    replacement.add(trailing);
    _disposePartController(textPart.id);
    _parts.replaceRange(textIndex, textIndex + 1, replacement);
    _activeTextPartId = trailing.id;
    _activeSelection = const TextSelection.collapsed(offset: 0);
    _emitChanged();
  }

  void _removeVariable(int index) {
    if (!_parts[index].isToken) {
      return;
    }
    _parts.removeAt(index);
    if (index > 0 &&
        index < _parts.length &&
        !_parts[index - 1].isToken &&
        !_parts[index].isToken) {
      final left = _parts[index - 1];
      final right = _parts.removeAt(index);
      left.text += right.text;
      _disposePartController(right.id);
    }
    if (_parts.isEmpty) {
      _parts.add(_EditorPart(id: _nextPartId++, text: ''));
    }
    _emitChanged();
  }

  void _moveVariable(int fromIndex, int targetIndex) {
    if (fromIndex < 0 ||
        fromIndex >= _parts.length ||
        !_parts[fromIndex].isToken) {
      return;
    }
    final part = _parts.removeAt(fromIndex);
    var insertionIndex = targetIndex.clamp(0, _parts.length);
    if (fromIndex < targetIndex) {
      insertionIndex--;
    }
    _parts.insert(insertionIndex, part);
    _emitChanged();
  }

  GlobalKey _textPartKeyFor(_EditorPart part) {
    return _textPartKeys.putIfAbsent(part.id, GlobalKey.new);
  }

  _DropCaretPosition _dropCaretFor(
    _EditorPart part,
    Offset globalPosition,
    double maxWidth,
  ) {
    final renderObject = _textPartKeyFor(
      part,
    ).currentContext?.findRenderObject();
    if (renderObject is! RenderBox) {
      return _DropCaretPosition(
        offset: part.text.length,
        localOffset: const Offset(4, 7),
      );
    }

    final localPosition = renderObject.globalToLocal(globalPosition);
    final style = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final textPainter = TextPainter(
      text: TextSpan(text: part.text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: widget.maxLines,
    )..layout(maxWidth: (maxWidth - 8).clamp(1.0, maxWidth).toDouble());
    final textPosition = textPainter.getPositionForOffset(
      Offset(
        (localPosition.dx - 4).clamp(0.0, maxWidth),
        (localPosition.dy - 7).clamp(0.0, double.infinity),
      ),
    );
    final caretOffset = textPainter.getOffsetForCaret(textPosition, Rect.zero);
    return _DropCaretPosition(
      offset: textPosition.offset.clamp(0, part.text.length),
      localOffset: Offset(caretOffset.dx + 4, caretOffset.dy + 7),
    );
  }

  bool _canDropOnText(_EditorPart part, int fromIndex) {
    return widget.enabled &&
        fromIndex >= 0 &&
        fromIndex < _parts.length &&
        _parts[fromIndex].isToken &&
        !identical(_parts[fromIndex], part);
  }

  void _moveVariableIntoText({
    required int fromIndex,
    required _EditorPart target,
    required int offset,
  }) {
    if (!_canDropOnText(target, fromIndex)) {
      return;
    }
    final token = _parts[fromIndex].token!;
    _parts.removeAt(fromIndex);
    final targetIndex = _parts.indexWhere((part) => part.id == target.id);
    if (targetIndex < 0) {
      return;
    }

    final currentTarget = _parts[targetIndex];
    final safeOffset = offset.clamp(0, currentTarget.text.length);
    final before = currentTarget.text.substring(0, safeOffset);
    final after = currentTarget.text.substring(safeOffset);
    final replacement = <_EditorPart>[];
    if (before.isNotEmpty) {
      replacement.add(_EditorPart(id: currentTarget.id, text: before));
    }
    replacement.add(_EditorPart(id: _nextPartId++, token: token));
    replacement.add(
      _EditorPart(
        id: before.isEmpty ? currentTarget.id : _nextPartId++,
        text: after,
      ),
    );
    _disposePartController(currentTarget.id);
    _parts.replaceRange(targetIndex, targetIndex + 1, replacement);
    _dragCarets.remove(target.id);
    _emitChanged();
  }

  void _disposePartController(int id) {
    _textControllers.remove(id)?.dispose();
    _focusNodes.remove(id)?.dispose();
  }

  Widget _dropTarget(int index) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) =>
          widget.enabled && details.data != index,
      onAcceptWithDetails: (details) => _moveVariable(details.data, index),
      builder: (context, candidates, rejected) {
        final highlighted = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: highlighted ? 18 : 6,
          height: 42,
          decoration: BoxDecoration(
            color: highlighted
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: AppRadius.small,
          ),
        );
      },
    );
  }

  Widget _textPart(_EditorPart part, {required double maxWidth}) {
    final controller = _controllerFor(part);
    final focusNode = _focusNodeFor(part);
    final textPartKey = _textPartKeyFor(part);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 42, maxWidth: maxWidth),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) =>
            _canDropOnText(part, details.data),
        onMove: (details) {
          final caret = _dropCaretFor(part, details.offset, maxWidth);
          if (_dragCarets[part.id]?.offset != caret.offset && mounted) {
            setState(() => _dragCarets[part.id] = caret);
          }
        },
        onLeave: (_) {
          if (mounted) {
            setState(() => _dragCarets.remove(part.id));
          }
        },
        onAcceptWithDetails: (details) {
          final caret = _dropCaretFor(part, details.offset, maxWidth);
          _moveVariableIntoText(
            fromIndex: details.data,
            target: part,
            offset: caret.offset,
          );
        },
        builder: (context, candidates, rejected) {
          final caret = _dragCarets[part.id];
          return Stack(
            key: textPartKey,
            clipBehavior: Clip.none,
            children: [
              TextField(
                key: ValueKey('template-text-${part.id}'),
                controller: controller,
                focusNode: focusNode,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: widget.maxLines,
                onTap: () {
                  _setActiveTextPart(part);
                  if (mounted) {
                    setState(() {});
                  }
                },
                onChanged: (value) => _updateText(part, value),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: part.text.isEmpty ? widget.hintText : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 7,
                  ),
                ),
              ),
              if (caret != null && candidates.isNotEmpty)
                Positioned(
                  left: caret.localOffset.dx,
                  top: caret.localOffset.dy,
                  child: IgnorePointer(
                    child: Container(
                      width: 2,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: AppRadius.small,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _tokenPart(
    _EditorPart part,
    int index, {
    required double maxLabelWidth,
  }) {
    final variable = _variableFor(part.token!);
    final label = variable?.label ?? part.token!;
    final displayLabel = variable?.displayLabel ?? part.token!;
    final chip = InputChip(
      label: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxLabelWidth),
        child: Text(displayLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      deleteButtonTooltipMessage: 'Quitar $label',
      onDeleted: widget.enabled ? () => _removeVariable(index) : null,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    if (!widget.enabled) {
      return chip;
    }
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(color: Colors.transparent, child: chip),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: chip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0;
        final maxPartWidth = (availableWidth - 24)
            .clamp(42.0, 260.0)
            .toDouble();
        final maxChipLabelWidth = (availableWidth - 100)
            .clamp(60.0, 170.0)
            .toDouble();
        final variableKeys = widget.variables
            .map((variable) => variable.key)
            .toSet();
        final hasTokens = _parts.any((part) => part.isToken);
        final showVariableToolbar =
            widget.enabled && (hasTokens || _activeTextPartId != null);
        final parts = <Widget>[];
        if (!hasTokens) {
          final textPart = _parts.firstWhere((part) => !part.isToken);
          parts.add(_textPart(textPart, maxWidth: maxPartWidth));
        } else {
          for (var index = 0; index < _parts.length; index++) {
            parts.add(_dropTarget(index));
            final part = _parts[index];
            parts.add(
              part.isToken
                  ? _tokenPart(part, index, maxLabelWidth: maxChipLabelWidth)
                  : _textPart(part, maxWidth: maxPartWidth),
            );
          }
          parts.add(_dropTarget(_parts.length));
        }

        return InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            alignLabelWithHint: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 2,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: parts,
              ),
              if (showVariableToolbar)
                const SizedBox(
                  key: ValueKey('notification-template-toolbar-gap'),
                  height: AppSpacing.sm,
                ),
              if (showVariableToolbar)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.variables
                      .where((variable) => variableKeys.contains(variable.key))
                      .map(
                        (variable) => Tooltip(
                          message: variable.label,
                          child: ActionChip(
                            label: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxChipLabelWidth,
                              ),
                              child: Text(
                                variable.displayLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onPressed: () => _insertVariable(variable),
                            avatar: Icon(
                              Icons.add_rounded,
                              size: 17,
                              color: scheme.primary,
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EditorPart {
  _EditorPart({required this.id, this.text = '', this.token});

  final int id;
  String text;
  final String? token;

  bool get isToken => token != null;
}

class _DropCaretPosition {
  const _DropCaretPosition({required this.offset, required this.localOffset});

  final int offset;
  final Offset localOffset;
}
