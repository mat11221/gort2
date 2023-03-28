import 'package:flutter/material.dart';

class EasyColorPicker extends StatelessWidget {
  /// The current selected color from color picker
  final Color selected;

  /// Function that returns the current selected color clicked by user
  final Function(Color) onChanged;

  /// The size for each color selector option
  final double colorSelectorSize;

  /// Border radius for each color selector
  final double colorSelectorBorderRadius;

  /// Margin to applied between options
  final double optionsMargin;

  /// Icon to be displayed on top of current select color option
  final IconData selectedIcon;

  /// Icon size for current selected color option
  final double selectedIconSize;

  /// Icon color for current selected color option
  final Color selectedIconColor;
  final Color selectedBorderColor;

  /// List of color to be displayed for selection
  final List<Color> colors;

  /// Easy color picker widget
  EasyColorPicker(
      {required Key key,
      required this.selected,
      required this.onChanged,
      this.colorSelectorBorderRadius = 5,
      this.optionsMargin = 3,
      this.colorSelectorSize = 30,
      this.selectedIcon = Icons.check_rounded,
      this.selectedIconSize = 20,
      this.selectedIconColor = Colors.white,
      this.selectedBorderColor = Colors.white,
      this.colors = const [
        Colors.blue,
        Colors.pink,
        Colors.green,
        Colors.amber,
        Colors.orange,
        Colors.blueGrey,
      ]})
      : assert(colors.isNotEmpty, 'Color list cannot be empty'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        alignment: WrapAlignment.center,
        children: List.generate(colors.length, (index) {
          return Container(
              width: colorSelectorSize,
              margin: EdgeInsets.all(optionsMargin),
              child: AspectRatio(
                  aspectRatio: 1,
                  child: GestureDetector(
                      child: Container(
                          decoration: BoxDecoration(
                              color: colors[index],
                              borderRadius: BorderRadius.circular(
                                  colorSelectorBorderRadius),
                              border: Border.all(
                                color: selected.value == colors[index].value
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 1,
                              )),
                          child: Visibility(
                              visible: selected.value == colors[index].value,
                              child: Icon(selectedIcon,
                                  size: selectedIconSize,
                                  color: selectedIconColor))),
                      onTap: () => onChanged(colors[index]))));
        }));
  }
}
