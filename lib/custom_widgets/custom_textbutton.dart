

import 'package:flutter/material.dart';

import '../tools/variables.dart';

class CustomTextButton extends StatelessWidget{
  const CustomTextButton(
      {
        Key? key,
        this.onPressed,
        this.text="Text Here",
        this.rTR=10,this.rTl=10,
        this.rBR=10,this.rBL=10,
        this.allRadius,
        this.color=MyColors.skyBlueDead,
        this.width = 100,
        this.height = 30,
        this.padding = EdgeInsets.zero,
        this.onHold,
        this.style,
        this.icon
      }) : super(key: key);

  final Function()? onPressed;
  final String text;
  final double rTl,rTR,rBL,rBR;
  final double? allRadius;
  final Color color;
  final double width;
  final double height;
  final EdgeInsets padding;
  final Function()? onHold;
  final TextStyle? style;
  final Widget? icon;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(

        onLongPress: onHold,
        onPressed: onPressed,
        child: Container(
            height: height,
            padding: padding,
            alignment: Alignment.center,
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon!=null?Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: icon!,
                ):Center(),
                Text(text,style: style!=null?style!:const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ],
            )
        ),
        style: ButtonStyle(

            backgroundColor: MaterialStateProperty.all(color),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(allRadius!=null?allRadius!:rBL),
                    bottomRight:  Radius.circular(allRadius!=null?allRadius!:rBR),
                    topLeft: Radius.circular(allRadius!=null?allRadius!:rTl),
                    topRight:  Radius.circular(allRadius!=null?allRadius!:rTR),

                  ),

                )
            )
        )
    );
  }
}
