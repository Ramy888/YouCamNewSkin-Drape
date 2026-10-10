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

  // The server writes buyer messages in English. In Arabic we show our own text for every code we know,
  // and keep the server's English only for codes we have never seen.
  static const _apiAr = {
    'DRAPE_BAD_KEY': 'رابط المتجر غير صحيح. ارجعي لصفحة المنتج وجربي تاني.',
    'DRAPE_UNAUTHORIZED': 'الجلسة انتهت. ابدئي من صفحة المنتج تاني.',
    'DRAPE_SESSION_NOT_FOUND': 'الجلسة انتهت. ابدئي من صفحة المنتج تاني.',
    'DRAPE_DOMAIN_NOT_ALLOWED': 'المتجر ده مش مفعّل مع Drape لسه.',
    'DRAPE_PRODUCT_NOT_FOUND': 'المنتج ده مش متاح للتجربة حالياً.',
    'DRAPE_IMAGE_INVALID': 'الملف ده مش صورة. اختاري صورة JPG أو PNG.',
    'DRAPE_IMAGE_TOO_LARGE': 'الصورة كبيرة جداً. جربي صورة أصغر.',
    'DRAPE_PHOTO_MISSING': 'محتاجين صورتك الأول.',
    'DRAPE_BUDGET_EXHAUSTED': 'وصلنا للحد اليومي للتجربة الحية. هنعرض لك الشكل النموذجي.',
    'DRAPE_INTERNAL': 'حصلت مشكلة عندنا. جربي تاني بعد شوية.',
  };
  static const _jobAr = {
    'error_face_angle_downward': 'ارفعي ذقنك شوية وبصي للكاميرا على طول.',
    'error_face_angle_upward': 'نزّلي ذقنك شوية وبصي للكاميرا على طول.',
    'error_face_angle': 'بصي للكاميرا على طول.',
    'error_no_face': 'مش لاقيين وش في الصورة. قرّبي وبصي للكاميرا.',
    'error_face_too_small': 'قرّبي عشان وشك يملا الإطار.',
    'error_multi_person': 'لازم يكون في شخص واحد بس في الصورة.',
    'error_pose': 'اقفي في مواجهة الكاميرا وإيديكي بعيد شوية عن جسمك.',
    'error_lighting': 'دوري على نور هادي ومتساوي وجربي تاني.',
    'error_face_parsing': 'مش شايفين ودانك عشان نحط الحلق. مفيش مشكلة: لون معدنك ظاهر في الإطلالة.',
    'error_nsfw_content_detected': 'الصورة دي مينفعش نستخدمها. اختاري صورة تانية.',
    'poll_deadline': 'الموضوع أخد وقت أطول من اللازم. جربي تاني.',
    'http_429': 'الخدمة مشغولة. جربي تاني بعد دقيقة.',
    'http_401': 'التجربة الحية متوقفة حالياً. هنعرض لك الشكل النموذجي.',
  };

  String apiError(String code, String fallback) => lang == Lang.ar ? (_apiAr[code] ?? somethingWrong) : fallback;
  String jobError(String? code, String fallback) => lang == Lang.ar ? (_jobAr[code] ?? somethingWrong) : fallback;

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
  String get tryOn => _('See it on me', 'شوفيها');

  // compare
  String dressing(String colour) => _('Dressing you in $colour…', 'نُلبسك اللون $colour…');
  String get compareTitle => _('Same piece, two colours', 'نفس القطعة بلونين');
  String get noOffPalette => _('Every colour of this piece works with you. Here is the strongest one.', 'كل ألوان هذه القطعة تناسبك. هذا أقواها.');
  String get notRecorded => _('This colour isn’t available to preview in demo mode yet.', 'معاينة هذا اللون غير متاحة في وضع العرض بعد.');
  String get retry => _('Try again', 'حاولي مرة ثانية');
  String get completeLook => _('Complete the look', 'كمّلي الإطلالة');
  String get needBody => _('For the try-on we need one full-length photo.', 'للتجربة نحتاج صورة كاملة واحدة.');

  // look
  String get earringsInMetal => _('Earrings in your metal', 'حلق بلون معدنك');
  String get earringUnavailable => _('Earring preview isn’t available in demo mode', 'معاينة الحلق غير متاحة في وضع العرض');
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

  // layout
  String stepOf(int n) => _('Step $n of 4', 'الخطوة ${'٠١٢٣٤'[n]} من ٤');
  String get stepShop => _('Shop', 'تسوّقي');
  String get stepCompare => _('Compare', 'قارني');
  String get landingEyebrow => _('Colour-matched try-on', 'تجربة ملابس على ألوانك');
  String get how1Title => _('Read your colours', 'نقرأ ألوانك');
  String get how1Body => _('One face photo, read by YouCam Facial Color Tones.', 'صورة واحدة لوجهك تقرأها YouCam Facial Color Tones.');
  String get how2Title => _('See both colours on you', 'شوفي اللونين عليكي');
  String get how2Body => _('The colour that fights you beside the one that lifts you.', 'اللون اللي يعاكسك جنب اللون اللي يبرزك.');
  String get how3Title => _('Complete the look', 'كمّلي الإطلالة');
  String get how3Body => _('Matching lip shade and metal, then straight to the cart.', 'لون شفايف ومعدن متناسقين، وبعدها على السلة على طول.');
  String get poweredBy => _('Try-on powered by YouCam API', 'التجربة بتقنية YouCam API');
  String get compareLead => _('The same piece on you in two colours. Look at your face, not the fabric.', 'نفس القطعة عليكي بلونين. بصّي على وشك، مش على القماش.');
  String get lookLead => _('Outfit, lip shade and metal chosen from one reading.', 'الطقم ولون الشفايف والمعدن، كلهم من قراءة واحدة.');
  String get yourPick => _('Your pick', 'اختيارك');

  // generic
  String get somethingWrong => _('Something went wrong.', 'حدث خطأ ما.');
  String get sampleBadge => _('Sample person', 'الشخص النموذجي');
}
