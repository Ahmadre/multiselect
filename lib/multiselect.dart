library multiselect;

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class _TheState {}

var _theState = RM.inject(() => _TheState());

class _SelectRow extends StatelessWidget {
  final Function(bool) onChange;
  final bool selected;
  final Widget child;

  const _SelectRow({
    Key? key,
    required this.onChange,
    required this.selected,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      title: child,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0).copyWith(left: 0),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (x) {
        onChange(x!);
        _theState.notify();
      },
    );
  }
}

///
/// A Dropdown multiselect menu
///
///
class DropDownMultiSelect extends StatefulWidget {
  /// The options form which a user can select
  final List options;

  /// Selected Values
  final List selectedValues;

  /// This function is called whenever a value changes
  final ValueChanged<List> onChanged;

  /// defines whether the field is dense
  final bool isDense;

  /// defines whether the widget is enabled;
  final bool enabled;

  /// Input decoration
  final InputDecoration? decoration;

  /// this text is shown when there is no selection
  final String? whenEmpty;

  /// a function to build custom childern
  final Widget Function(List selectedValues)? childBuilder;

  /// a function to build custom menu items
  final Widget Function(dynamic option)? menuItembuilder;

  /// a function to validate
  final String Function(dynamic selectedOptions)? validator;

  /// defines whether the widget is read-only
  final bool readOnly;

  final double height;

  final Color? fadeoutColor;

  const DropDownMultiSelect({
    Key? key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.whenEmpty,
    this.childBuilder,
    this.menuItembuilder,
    this.isDense = false,
    this.enabled = true,
    this.decoration,
    this.validator,
    this.readOnly = false,
    this.height = 100,
    this.fadeoutColor,
  }) : super(key: key);

  @override
  _DropDownMultiSelectState createState() => _DropDownMultiSelectState();
}

class _DropDownMultiSelectState extends State<DropDownMultiSelect> {
  Color fadeoutColor = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.fadeoutColor == null) {
        fadeoutColor = Theme.of(context).scaffoldBackgroundColor;
      } else {
        fadeoutColor = widget.fadeoutColor!;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              _theState.rebuilder(
                () => widget.childBuilder != null
                    ? widget.childBuilder!(widget.selectedValues)
                    : Align(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                                  .copyWith(right: 32),
                          child: widget.menuItembuilder != null &&
                                  widget.selectedValues.length > 0
                              ? ClipRRect(
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: widget.selectedValues.map((e) {
                                        if (widget.selectedValues.indexOf(e) <
                                            widget.selectedValues.length - 1) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              widget.menuItembuilder!(e),
                                              Text(',')
                                            ],
                                          );
                                        }
                                        return widget.menuItembuilder!(e);
                                      }).toList(),
                                    ),
                                  ),
                                )
                              : Text(widget.selectedValues.length > 0
                                  ? widget.selectedValues
                                      .map((e) => e.toString())
                                      .reduce((a, b) => a + ' , ' + b)
                                  : widget.whenEmpty ?? ''),
                        ),
                        alignment: Alignment.centerLeft),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: DropdownButtonFormField(
                  validator: widget.validator != null ? widget.validator : null,
                  decoration: widget.decoration != null
                      ? widget.decoration
                      : InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                        ),
                  isDense: true,
                  onChanged: widget.enabled ? (x) {} : null,
                  value: widget.selectedValues.length > 0
                      ? widget.selectedValues[0]
                      : null,
                  selectedItemBuilder: (context) {
                    return widget.options
                        .map((e) => DropdownMenuItem(
                              child: Container(),
                            ))
                        .toList();
                  },
                  items: widget.options
                      .map((x) => DropdownMenuItem(
                            child: _theState.rebuilder(() {
                              return _SelectRow(
                                selected: widget.selectedValues.contains(x),
                                child: widget.menuItembuilder != null
                                    ? widget.menuItembuilder!(x)
                                    : Text(
                                        x.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                onChange: (isSelected) {
                                  if (isSelected) {
                                    var ns = widget.selectedValues;
                                    ns.add(x);
                                    widget.onChanged(ns);
                                  } else {
                                    var ns = widget.selectedValues;
                                    ns.remove(x);
                                    widget.onChanged(ns);
                                  }
                                },
                              );
                            }),
                            value: x,
                            onTap: !widget.readOnly
                                ? () {
                                    if (widget.selectedValues.contains(x)) {
                                      var ns = widget.selectedValues;
                                      ns.remove(x);
                                      widget.onChanged(ns);
                                    } else {
                                      var ns = widget.selectedValues;
                                      ns.add(x);
                                      widget.onChanged(ns);
                                    }
                                  }
                                : null,
                          ))
                      .toList(),
                ),
              ),

              /// Fade-out Container for multiple selected elements
              IgnorePointer(
                child: Container(
                  margin: const EdgeInsets.only(right: 32, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.lerp(
                          Alignment.centerRight,
                          Alignment.center,
                          .2,
                        )!,
                        colors: [
                          fadeoutColor,
                          fadeoutColor.withOpacity(0),
                        ],
                        stops: [
                          0.0,
                          1.0
                        ]),
                  ),
                  child: Container(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
