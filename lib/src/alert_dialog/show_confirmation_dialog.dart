import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Show [confirmation dialog](https://material.io/components/dialogs#confirmation-dialog),
/// whose appearance is adaptive according to platform
///
/// For Cupertino, fallback to ActionSheet.
///
/// If [shrinkWrap] is true, material dialog height is determined by the
/// contents. This argument defaults to `true`. If you know the content height
/// is taller than the height of screen, it is recommended to set to `false`
/// for performance optimization.
Future<T> showConfirmationDialog<T>({
  @required BuildContext context,
  @required String title,
  String message,
  String okLabel,
  String cancelLabel,
  double contentMaxHeight,
  List<AlertDialogAction<T>> actions = const [],
  bool barrierDismissible = true,
  AdaptiveStyle style = AdaptiveStyle.adaptive,
  bool useRootNavigator = true,
  bool shrinkWrap = true,
}) {
  void pop(T key) => Navigator.of(
        context,
        rootNavigator: useRootNavigator,
      ).pop(key);
  final theme = Theme.of(context);
  return style.isCupertinoStyle(theme)
      ? showModalActionSheet(
          context: context,
          title: title,
          message: message,
          cancelLabel: cancelLabel,
          actions: actions.convertToSheetActions(),
          style: style,
          useRootNavigator: useRootNavigator,
        )
      : showModal(
          context: context,
          useRootNavigator: useRootNavigator,
          configuration: FadeScaleTransitionConfiguration(
            barrierDismissible: barrierDismissible,
          ),
          builder: (context) => _ConfirmationDialog(
            title: title,
            onSelect: pop,
            message: message,
            okLabel: okLabel,
            cancelLabel: cancelLabel,
            actions: actions,
            contentMaxHeight: contentMaxHeight,
            shrinkWrap: shrinkWrap,
          ),
        );
}

class _ConfirmationDialog<T> extends StatefulWidget {
  const _ConfirmationDialog({
    Key key,
    @required this.title,
    @required this.onSelect,
    @required this.message,
    @required this.okLabel,
    @required this.cancelLabel,
    @required this.actions,
    @required this.contentMaxHeight,
    @required this.shrinkWrap,
  }) : super(key: key);

  final String title;
  final ValueChanged<T> onSelect;
  final String message;
  final String okLabel;
  final String cancelLabel;
  final List<AlertDialogAction<T>> actions;
  final double contentMaxHeight;
  final bool shrinkWrap;

  @override
  _ConfirmationDialogState<T> createState() => _ConfirmationDialogState<T>();
}

class _ConfirmationDialogState<T> extends State<_ConfirmationDialog<T>> {
  T _selectedValue;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.headline6,
                ),
                if (widget.message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.message,
                      style: theme.textTheme.caption,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 0),
          Flexible(
            child: SizedBox(
              height: widget.contentMaxHeight,
              child: ListView(
                // This switches physics automatically, so if there is enough
                // height, `NeverScrollableScrollPhysics` will be set.
                controller: _scrollController,
                shrinkWrap: widget.shrinkWrap,
                children: widget.actions
                    .map((action) => RadioListTile<T>(
                          title: Text(action.label),
                          value: action.key,
                          groupValue: _selectedValue,
                          onChanged: (value) {
                            setState(() {
                              _selectedValue = value;
                            });
                          },
                          // TODO(mono): Not supported at 1.17.0
//                          toggleable: true,
                        ))
                    .toList(),
              ),
            ),
          ),
          const Divider(height: 0),
          ButtonBar(
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            children: [
              TextButton(
                child: Text(
                  widget.cancelLabel ??
                      MaterialLocalizations.of(context).cancelButtonLabel,
                ),
                onPressed: () => widget.onSelect(null),
              ),
              TextButton(
                child: Text(
                  widget.okLabel ??
                      MaterialLocalizations.of(context).okButtonLabel,
                ),
                onPressed: _selectedValue == null
                    ? null
                    : () => widget.onSelect(_selectedValue),
              )
            ],
          )
        ],
      ),
    );
  }
}
