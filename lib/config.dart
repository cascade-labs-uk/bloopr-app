import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  static Color OUTLINE_COLOR = Colors.grey[500];
  static Color SECONDARY_COLOR = Color(0xffEFEFEF);
  static Color BACKGROUND_COLOR = Colors.white;
  static Color HIGHLIGHT_COLOR = Color(0xff718EDD);
  static Color INACTIVE_COLOR_DARK = Colors.grey[700];
  static Color INACTIVE_COLOR_LIGHT = Colors.white;
  static Color DARK_TEXT = Colors.black;
  static Color LIGHT_TEXT = Colors.white;
  static Color GREY_TEXT = Colors.grey[500];
  static int MAX_IMAGE_SIZE = 7 * 1024 * 1024;

  static IconData EXPLORE_PAGE_ICON = Icons.search;
  static IconData SWIPE_PAGE_ICON = Icons.content_copy;
  static IconData PROFILE_PAGE_ICON = Icons.perm_identity;

  static String DEFAULT_PROFILE_PICTURE_LOCATION = 'gs://bloopr-test.appspot.com/app/images/profile_image_placeholder.png';

  static TextStyle TEXT_STYLE_HEADER_DARK = GoogleFonts.getFont('Roboto', color: DARK_TEXT, fontSize: 20.0);
  static TextStyle TEXT_STYLE_HEADER_GREY = GoogleFonts.getFont('Roboto', color: GREY_TEXT, fontSize: 20.0);
  static TextStyle TEXT_STYLE_HEADER_HIGHLIGHT = GoogleFonts.getFont('Roboto', color: HIGHLIGHT_COLOR, fontSize: 20.0);
  static TextStyle TEXT_STYLE_HEADER_LIGHT = GoogleFonts.getFont('Roboto', color: LIGHT_TEXT, fontSize: 20.0);
  static TextStyle TEXT_STYLE_CAPTION_DARK = GoogleFonts.getFont('Roboto', color: DARK_TEXT, fontSize: 16.0);
  static TextStyle TEXT_STYLE_CAPTION_LIGHT = GoogleFonts.getFont('Roboto', color: LIGHT_TEXT, fontSize: 16.0);
  static TextStyle TEXT_STYLE_CAPTION_GREY = GoogleFonts.getFont('Roboto', color: GREY_TEXT, fontSize: 16.0);
  static TextStyle TEXT_STYLE_DARK = GoogleFonts.getFont('Roboto', color: DARK_TEXT, fontWeight: FontWeight.w300);
  static TextStyle TEXT_STYLE_LIGHT = GoogleFonts.getFont('Roboto', color: LIGHT_TEXT, fontWeight: FontWeight.w300);
  static TextStyle TEXT_STYLE_HINT_DARK = GoogleFonts.getFont('Roboto', color: GREY_TEXT, fontSize: 12.0);
  static TextStyle TEXT_STYLE_HINT_LIGHT = GoogleFonts.getFont('Roboto', color: LIGHT_TEXT, fontSize: 12.0);
  static TextStyle TEXT_STYLE_LARGE_NUMBERS_DARK = GoogleFonts.getFont('Roboto', color: DARK_TEXT, fontSize: 18.0, fontWeight:  FontWeight.w500);
}

enum language {
  english,
  spanish
}