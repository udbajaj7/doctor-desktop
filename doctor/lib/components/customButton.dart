import 'package:doctor/components/size_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final Color backgroundColor;
  final Function onPressed;
  final String text;
  const CustomButton(
      {Key? key,
      required this.backgroundColor,
      required this.onPressed,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
      onTap: () => onPressed(),
      child: Container(
        color: backgroundColor,
        height: getProportionateScreenHeight(47.95),
        width: getProportionateScreenWidth(169.88),
        child: Center(
          child: Text(text,
              style: GoogleFonts.publicSans(
                  color: backgroundColor == Colors.black
                      ? Colors.white
                      : Colors.black,
                  fontSize: 15.58,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
