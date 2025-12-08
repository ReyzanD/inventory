import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RupiahText extends StatelessWidget {
  final double amount;
  final bool withDecimals;
  final TextStyle? style;
  final TextAlign? textAlign;

  const RupiahText({
    Key? key,
    required this.amount,
    this.withDecimals = false,
    this.style,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedAmount;
    if (withDecimals) {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 2,
      );
      formattedAmount = formatter.format(amount);
    } else {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      formattedAmount = formatter.format(amount);
    }

    return Text(
      formattedAmount,
      style: style,
      textAlign: textAlign,
    );
  }
}

class NumberText extends StatelessWidget {
  final double number;
  final TextStyle? style;
  final TextAlign? textAlign;

  const NumberText({
    Key? key,
    required this.number,
    this.style,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    final formattedNumber = formatter.format(number);

    return Text(
      formattedNumber,
      style: style,
      textAlign: textAlign,
    );
  }
}