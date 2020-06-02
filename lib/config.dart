import 'package:blooprtest/asset_management/custom_icons_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  static Color OUTLINE_COLOR = Colors.grey[500];
  static Color SECONDARY_COLOR = Color(0xffFCFCFC);
  static Color BACKGROUND_COLOR = Colors.white;
  static Color HIGHLIGHT_COLOR = Color(0xff718EDD);
  static Color INACTIVE_COLOR_DARK = Colors.grey[700];
  static Color INACTIVE_COLOR_LIGHT = Colors.white;
  static Color DARK_TEXT = Colors.black;
  static Color LIGHT_TEXT = Colors.white;
  static Color GREY_TEXT = Colors.grey[500];

  static int MAX_IMAGE_SIZE = 7 * 1024 * 1024;
  static int SWIPE_ANIMATION_DURATION = 200; // length of full swipe animation in milliseconds

  static IconData EXPLORE_PAGE_ICON = Icons.search;
  static IconData SWIPE_PAGE_ICON = Icons.content_copy;
  static IconData PROFILE_PAGE_ICON = Icons.perm_identity;

  static IconData EXPLORE_PAGE_SELECTED_ICON = CustomIcons.ExploreSelected;
  static IconData EXPLORE_PAGE_UNSELECTED_ICON = CustomIcons.ExploreUnselected;
  static IconData SWIPE_PAGE_SELECTED_ICON = CustomIcons.SwipingSelected;
  static IconData SWIPE_PAGE_UNSELECTED_ICON = CustomIcons.SwipingUnselected;
  static IconData PROFILE_PAGE_SELECTED_ICON = CustomIcons.ProfileSelected;
  static IconData PROFILE_PAGE_UNSELECTED_ICON = CustomIcons.ProfileUnselected;



  static IconData GRID = CustomIcons.Grid;




  static String DEFAULT_PROFILE_PICTURE_LOCATION = 'gs://bloopr-test.appspot.com/app/images/profile_image_placeholder.png';
  static String EULA_AGREEMENT_TEXT = "Welcome to Bloopr \n This agreement governs your use of Bloopr. When you create an account or use bloopr, you agree to these terms.\nIf you wish to end this agreement email unsubscribe@bloopr.org\nSection 1: Safety\nBloopr includes User Generated content Objectionable Content\nObjectionable content including but not limited to Racism, Hate speech and sexual content is not tolerated unequivocally. Users are able to select “report” to report objectionable content. Any content that is flagged or found to be “objectionable” will be reviewed and removed appropriately within 24hrs of a flagging. Any individual who violates our policy of “Objectionable Content” will have their use of the app suspended then terminated. By accepting this license agreement you are accepting this policy All content queries can alternatively be resolved at report@bloopr.orgData SecurityOur app empoys security measure to ensure proper handling of user data and will not distribute itto a third party (See Section 5 for more information). \nSection 2: Performance\nThis app complies with the regulations surrounding bugs and performance. Test flight will only be used as it is stated in Section 2 of https://developer.apple.com/app-store/review/guidelines/#safetyThe meta data we include on the app store is appropriate to all audiences and complies with the rules specified with on the Apple App review wesbite. The app is selfcontained and does not execute any external processes. \nSection 3: Business\nThis app does not include any in app purchases nor does it cost any money to download nor doesit generate revenue of any currency including but not limited to cryptocurrency or have any form of monetization including but not limited to adverts. Nor does it facillate payments of third party apps and complies with the regulations indicated by apple. \nSection 4: Design\nThis App is independently designed and is unique. Our app does not use a third party signin service\nSection 5: Legal\nOur app complies with all local, national and international laws Our App employs careful privacy strategies detailed below:Data We Collect..When you, the user, creates an account we collect your email address. We collect your interactions with the app, including the posts that you upload and comments you add. We will never distribute your email address to a third party, nor will we make your account details public or give a third party access to them. You are able to withdraw permission to every agreement. This app complies with the General Data Protection Law. Any images or comments that you input onto the app are made publicly available to any other user on the app. When you upload an image the app and all its users are able to share and distribute this data freely. We employ data minimization and only request data that is significant to allow the app to function. We will respect the users permission settings. This app complies with and abides to the COPPA and (EU)GDPR We do not collect any other data other than the aforementioned. Restrictions on Use: You shall use the Application strictly in accordance with the SEULA agreement along with these Related Agreements and shall not a.Decompile the application adapt or obtain the source codeb.Vioate any applicable laws, rules or regulations in connection to your use of the appc.Use the app for any commercial purpose it was not intended ford.Make the app available on another platforme.Use the app for creating a product service or software that is directly or indirectly competitive with the services offered with this appf.Use any proprietary information or interfaces or other intellectual property of the company. We will not attempt to manipulate customers or use the data they provide or attempt o gain access to more data.";

  static TextStyle TEXT_STYLE_HEADER_DARK = GoogleFonts.getFont('Open Sans', color: DARK_TEXT, fontSize: 20.0);
  static TextStyle TEXT_STYLE_HEADER_GREY = GoogleFonts.getFont('Open Sans', color: GREY_TEXT, fontSize: 20.0);
  static TextStyle TEXT_STYLE_HEADER_HIGHLIGHT = GoogleFonts.getFont('Open Sans', color: HIGHLIGHT_COLOR, fontSize: 20.0);
  static TextStyle TEXT_STYLE_HEADER_LIGHT = GoogleFonts.getFont('Open Sans', color: LIGHT_TEXT, fontSize: 20.0);
  static TextStyle TEXT_STYLE_CAPTION_DARK = GoogleFonts.getFont('Open Sans', color: DARK_TEXT, fontSize: 16.0);
  static TextStyle TEXT_STYLE_CAPTION_LIGHT = GoogleFonts.getFont('Open Sans', color: LIGHT_TEXT, fontSize: 16.0);
  static TextStyle TEXT_STYLE_CAPTION_GREY = GoogleFonts.getFont('Open Sans', color: GREY_TEXT, fontSize: 16.0);
  static TextStyle TEXT_STYLE_DARK = GoogleFonts.getFont('Open Sans', color: DARK_TEXT, fontWeight: FontWeight.w300);
  static TextStyle TEXT_STYLE_LIGHT = GoogleFonts.getFont('Open Sans', color: LIGHT_TEXT, fontWeight: FontWeight.w300);
  static TextStyle TEXT_STYLE_HINT_BLACK = GoogleFonts.getFont('Open Sans', color: DARK_TEXT, fontSize: 12.0);
  static TextStyle TEXT_STYLE_HINT_DARK = GoogleFonts.getFont('Open Sans', color: GREY_TEXT, fontSize: 12.0);
  static TextStyle TEXT_STYLE_HINT_LIGHT = GoogleFonts.getFont('Open Sans', color: LIGHT_TEXT, fontSize: 12.0);
  static TextStyle TEXT_STYLE_LARGE_NUMBERS_DARK = GoogleFonts.getFont('Open Sans', color: DARK_TEXT, fontSize: 18.0, fontWeight:  FontWeight.w500);
}

enum language {
  english,
  spanish
}