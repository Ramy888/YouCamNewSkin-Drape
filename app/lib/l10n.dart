// English + Arabic copy. Rules: judge the garment, never the skin; every "no" comes with a better "yes";
// never call the user dark, light or fair. Arabic is short MSA that reads naturally in Egypt and the Gulf
// (to be reviewed by a native speaker before launch).
import 'package:flutter/widgets.dart';

enum Lang { en, ar }

class S {
  S(this.lang);
  final Lang lang;

  bool get rtl => lang == Lang.ar;
  TextDirection get dir => rtl ? TextDirection.rtl : TextDirection.ltr;

  String _(String en, String ar) => lang == Lang.ar ? ar : en;

  String get brand => 'Drape';
  String get langToggle => _('العربية', 'English');
  String get back => _('Back', 'رجوع');

  // landing
  String get landingTitle => _('Buy the colour that suits you', 'اختاري اللون اللي يليق بك');
  String get landingBody => _(
      'One face photo reads your skin, hair and eye colours. Then you see each colour of a garment on your own body, side by side.',
      'صورة واحدة لوجهك تقرأ ألوان بشرتك وشعرك وعينيك. بعدها ترين كل لون من القطعة على جسمك، جنبًا إلى جنب.');
  String get usePhoto => _('Use my photo', 'استخدمي صورتي');
  String get trySample => _('Try with the sample person', 'جرّبي مع الشخص النموذجي');
  String get sampleExplain => _('No photo needed. See the full flow with our sample person.', 'من غير صور. شوفي التجربة كاملة مع الشخص النموذجي.');

  // capture
  String get faceTitle => _('A clear photo of your face', 'صورة واضحة لوجهك');
  String get faceHint => _('Face the camera, chin level, soft even light, no sunglasses.', 'وجهك للكاميرا، ذقنك مستقيم، إضاءة هادئة ومتساوية، من غير نظارة شمس.');
  String get bodyTitle => _('A full-length photo', 'صورة كاملة من الرأس للقدم');
  String get bodyHint => _('Stand facing the camera, one person only, your whole body in the frame.', 'قفي مواجهة الكاميرا، شخص واحد فقط، وجسمك كله داخل الصورة.');
  String get takePhoto => _('Take or choose a photo', 'التقطي أو اختاري صورة');
  String get liveOff => _('Trying on with your own photo is switched off in this demo, so we show the full flow with our sample person.', 'التجربة بصورتك متوقفة في النسخة التجريبية، فبنعرض لك التجربة كاملة مع الشخص النموذجي.');
  String get sampleResult => _('This is the sample person, not you: demo mode doesn\'t use your photo.', 'دي صورة الشخص النموذجي مش صورتك: النسخة التجريبية ما بتستخدمش صورتك.');
  String get privacy => _('Your photos are deleted after 24 hours. You can delete them now at any time.', 'صورك تُحذف بعد ٢٤ ساعة، وتقدرين تحذفينها الآن في أي وقت.');
  String get tryWithout => _('Try without your photo', 'جرّبي من غير صورتك');
  String get uploading => _('Preparing your photo…', 'جارٍ تجهيز صورتك…');
  String get photoReadFail => _('We couldn’t open that image. Try a JPEG or PNG photo.', 'ما قدرنا نفتح الصورة. جرّبي صورة JPEG أو PNG.');

  // reveal
  String get reading => _('Reading your skin, hair and eyes…', 'نقرأ ألوان بشرتك وشعرك وعينيك…');
  String get yourColours => _('Your colours', 'ألوانك');
  String get liftsYou => _('Lifts your colouring', 'يبرز ألوانك');
  String get fightsYou => _('Fights your colouring', 'يعاكس ألوانك');
  String undertone(String u) => switch (u) {
        'warm' => _('Warm undertone', 'درجة دافئة'),
        'cool' => _('Cool undertone', 'درجة باردة'),
        _ => _('Neutral undertone', 'درجة محايدة'),
      };
  String contrast(String c) => switch (c) {
        'high' => _('high contrast', 'تباين عالٍ'),
        'low' => _('soft contrast', 'تباين هادئ'),
        _ => _('medium contrast', 'تباين متوسط'),
      };
  String metal(String m) => switch (m) {
        'gold' => _('Gold', 'ذهبي'),
        'silver' => _('Silver', 'فضي'),
        _ => _('Rose gold', 'ذهبي وردي'),
      };
  String get metalLabel => _('Your metal', 'المعدن المناسب');
  String get suitsLabel => _('Colours that work with you', 'ألوان تناسبك');
  String get avoidLabel => _('Colours that fight your colouring', 'ألوان تعاكس ألوانك');
  String get notMe => _('That’s not me:', 'مش مظبوط:');
  String get warmer => _('Warmer', 'أدفأ');
  String get cooler => _('Cooler', 'أبرد');
  String get shopColours => _('Shop your colours', 'تسوّقي بألوانك');

  // shop
  String get shopTitle => _('Sorted by what suits you', 'مرتّبة حسب ما يناسبك');
  String get verdictYours => _('Yours', 'يناسبك');
  String get verdictAvoid => _('Not your colour', 'ليس لونك');
  String get verdictNeutral => _('Could work', 'ممكن');
  String get noneMatch => _('None of this store’s colours match yet — here are the closest.', 'لا توجد ألوان مطابقة لك هنا بعد — هذه الأقرب.');
  String get tryOn => _('See it on me', 'شوفيها عليّ');

  // compare
  String dressing(String colour) => _('Dressing you in $colour…', 'نُلبسك اللون $colour…');
  String get compareTitle => _('Same piece, two colours', 'نفس القطعة بلونين');
  String get noOffPalette => _('Every colour of this piece works with you. Here is the strongest one.', 'كل ألوان هذه القطعة تناسبك. هذا أقواها.');
  String get notRecorded => _('This colour isn’t available to preview in demo mode yet.', 'معاينة هذا اللون غير متاحة في وضع العرض بعد.');
  String get retry => _('Try again', 'حاولي مرة ثانية');
  String get completeLook => _('Complete the look', 'كمّلي الإطلالة');
  String get needBody => _('For the try-on we need one full-length photo.', 'للتجربة نحتاج صورة كاملة واحدة.');

  // look
  String get makeupUnavailable => _('Makeup preview isn’t available in demo mode', 'معاينة المكياج غير متاحة في وضع العرض');
  String get lipShade => _('Your lip shade', 'لون الشفاه المناسب');
  String get matchingMakeup => _('Matching makeup', 'مكياج متناسق');
  String get lookCard => _('Your look', 'إطلالتك');
  String get addBundle => _('Add the look to cart', 'أضيفي الإطلالة للسلة');
  String get addedAtStore => _('Added to your cart at the store.', 'تمت الإضافة إلى سلتك في المتجر.');
  String get demoCheckout => _('Demo checkout — nothing is charged.', 'دفع تجريبي — لن يتم خصم أي مبلغ.');
  String get orderPlaced => _('Demo order placed', 'تم الطلب التجريبي');
  String get deletePhotos => _('Delete my photos', 'احذفي صوري');
  String get deleted => _('Your photos and results are deleted.', 'تم حذف صورك ونتائجك.');
  String get startOver => _('Start over', 'ابدئي من جديد');

  // generic
  String get somethingWrong => _('Something went wrong.', 'حدث خطأ ما.');
  String get sampleBadge => _('Sample person', 'الشخص النموذجي');
}
