import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

class RoomCodeField extends StatefulWidget {
  const RoomCodeField({
    super.key,
    required this.digits,
    required this.onChanged,
    this.enabled = true,
  });

  final String digits;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<RoomCodeField> createState() => _RoomCodeFieldState();
}

class _RoomCodeFieldState extends State<RoomCodeField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.digits);
    _focus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant RoomCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digits != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.digits,
        selection: TextSelection.collapsed(offset: widget.digits.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.inputSurface : AppColors.lightSurface;
    final dashColor = isDark
        ? AppColors.secondaryText
        : AppColors.lightTextSecondary;
    final digitColor =
        isDark ? AppColors.white : AppColors.lightTextPrimary;
    final lime = AppColors.joinLime;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.enabled ? _focus.requestFocus : null,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _focus.hasFocus ? lime : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  final char =
                      i < widget.digits.length ? widget.digits[i] : '—';
                  final isDigit = i < widget.digits.length;
                  return AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          color: isDigit ? digitColor : dashColor,
                        ),
                    child: Text(char),
                  );
                }),
              ),
              TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                showCursor: false,
                style: TextStyle(
                  color: Colors.transparent.withValues(alpha: 0),
                  fontSize: 28,
                  height: 1.1,
                ),
                cursorColor: Colors.transparent,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: widget.onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
