import 'package:flutter/material.dart';

class CustomTextView extends StatefulWidget {
  final String text;

  const CustomTextView({Key key, this.text}) : super(key: key);
  
  @override
  _CustomTextViewState createState() => _CustomTextViewState();
}

class _CustomTextViewState extends State<CustomTextView> {
  bool seeMoreClicked = false;
  @override
  Widget build(BuildContext context) {
    return _text();
  }


  Widget _text() {
    var exceeded;
    return LayoutBuilder(builder: (context, size) {
      // Build the textspan
      var span = TextSpan(
        text:widget.text
            ,
        style: Theme.of(context).textTheme.body1,
      );

      // Use a textpainter to determine if it will exceed max lines
      var tp = TextPainter(
        maxLines: 4,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        text: span,
      );

      // trigger it to layout
      tp.layout(maxWidth: size.maxWidth);

      // whether the text overflowed or not
      exceeded = tp.didExceedMaxLines;

      // return Column(children: <Widget>[
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          child: exceeded && seeMoreClicked
              ? _seeMoreLess(span, "See Less ")
              : exceeded && !seeMoreClicked
                  ? _seeMoreLess(span, "See More", 4)
                  : Text.rich(
                      span,
                      overflow: TextOverflow.visible,
                    ),
        ),
      );
    });
  }

  Widget _seeMoreLess(TextSpan span, String _text, [int maxLine = 0]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        maxLine > 0
            ? Text.rich(
                span,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              )
            : Text.rich(
                span,
                overflow: TextOverflow.visible,
              ),
        InkWell(
            child: Text(
              _text,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.blue),
            ),
            onTap: () {
              setState(() {
                seeMoreClicked = !seeMoreClicked;
              });
            }),
      ],
    );
  }
}