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
    'DRAPE_BAD_KEY': 'مش قادرين نفتح المتجر بالرابط ده. ارجعي لصفحة المنتج وجرّبي تاني.',
    'DRAPE_UNAUTHORIZED': 'مش قادرين نبدأ الجلسة. ارجعي لصفحة المنتج وابدئي تاني.',
    'DRAPE_SESSION_NOT_FOUND': 'الجلسة انتهت. ابدئي من صفحة المنتج تاني.',
    'DRAPE_DOMAIN_NOT_ALLOWED': 'مش مسموح بفتح المتجر من الموقع ده.',
    'DRAPE_PRODUCT_NOT_FOUND': 'المنتج ده مش متاح للتجربة حالياً.',
    'DRAPE_IMAGE_INVALID': 'الصورة فاضية أو صيغتها مش مدعومة. اختاري صورة JPG أو PNG.',
    'DRAPE_IMAGE_TOO_LARGE': 'حجم الصورة أكبر من ١٠ ميجابايت. اختاري صورة أصغر.',
    'DRAPE_PHOTO_MISSING': 'ضيفي صورتك الأول عشان نكمل.',
    'DRAPE_BUDGET_EXHAUSTED': 'جرّبتي بالفعل لون المتجر لسه ما بيبيعوش.',
    'DRAPE_INTERNAL': 'حصلت مشكلة عندنا. جربي تاني بعد شوية.',
  };
  static const _jobAr = {
    'error_face_angle_downward': 'ارفعي دقنك شوية وبصّي للكاميرا مباشرة.',
    'error_face_angle_upward': 'نزّلي دقنك شوية وبصّي للكاميرا مباشرة.',
    'error_face_angle': 'خلّي وشك في مواجهة الكاميرا مباشرة.',
    'error_no_face': 'مش قادرين نحدّد وشك في الصورة. قرّبي وخلّي وشك في مواجهة الكاميرا.',
    'error_face_too_small': 'قرّبي لحد ما وشك يملا الإطار البيضاوي.',
    'error_multi_person': 'لازم تكوني لوحدك في الصورة.',
    'error_pose': 'اقفي في مواجهة الكاميرا، وابعّدي دراعاتك شوية عن جسمك.',
    'error_lighting': 'اختاري مكان بإضاءة ناعمة وموزّعة بالتساوي، وجرّبي تاني.',
    'error_face_parsing': 'مش قادرين نحدّد مكان ودانك عشان نعرض الحلق. مفيش مشكلة، لون المعدن المناسب ليكي لسه ظاهر في الإطلالة.',
    'error_nsfw_content_detected': 'مش هينفع نستخدم الصورة دي. اختاري صورة تانية.',
    'poll_deadline': 'التجربة أخدت وقت أطول من المتوقع. جرّبي تاني.',
    'http_429': 'خدمة تجربة الملابس عليها ضغط دلوقتي. جرّبي تاني بعد دقيقة.',
    'http_401': 'تجربة الملابس بصورتك متوقفة دلوقتي. هنعرضلك معاينة على الموديل التجريبي.',
  };

  String apiError(String code, String fallback) => lang == Lang.ar ? (_apiAr[code] ?? somethingWrong) : fallback;
  String jobError(String? code, String fallback) => lang == Lang.ar ? (_jobAr[code] ?? somethingWrong) : fallback;

  String get brand => 'Drape';
  String get langToggle => _('العربية', 'English');
  String get back => _('Back', 'رجوع');

  // landing
  String get landingTitle => _('Buy the colour that suits you', 'اشتري اللون اللي يليق عليكي');
  String get landingBody => _(
      'One face photo reads your skin, hair and eye colours. Then you see each colour of a garment on your own body, side by side.',
      'بصورة واحدة لوشك، بنحلّل ألوان بشرتك وشعرك وعينيكي. بعدها تقدري تشوفي ألوان القطعة عليكي وتقارني بينها جنب بعض.');
  String get usePhoto => _('Use my photo', 'استخدام صورتي');
  String get trySample => _('Try with the sample person', 'جرّبي على الموديل التجريبي');
  String get sampleExplain => _('No photo needed. See the full flow with our sample person.', 'مش محتاجة تضيفي صورتك. شوفي التجربة كاملة على الموديل التجريبي.');

  // capture
  String get faceTitle => _('A clear photo of your face', 'صورة واضحة لوشك');
  String get faceHint => _('Face the camera, chin level, soft even light, no sunglasses.', 'خلّي وشك في مواجهة الكاميرا، من غير ما ترفعي دقنك أو تنزّليها. اختاري إضاءة ناعمة وموزّعة بالتساوي، ومن غير نظارة شمس.');
  String get bodyTitle => _('A full-length photo', 'صورة ليكي من راسك لرجليكي');
  String get bodyHint => _('Stand facing the camera, one person only, your whole body in the frame.', 'اقفي في مواجهة الكاميرا، لوحدك، وخلي جسمك كله ظاهر من راسك لرجليكي.');
  String get takePhoto => _('Take or choose a photo', 'صوّري أو اختاري صورة');
  String get liveOff => _('Trying on with your own photo is switched off in this demo, so we show the full flow with our sample person.', 'تجربة الملابس بصورتك مش مفعّلة في النسخة التجريبية، فهنوريكي التجربة كاملة على الموديل التجريبي.');
  String get sampleResult => _('This is the sample person, not you: demo mode doesn\'t use your photo.', 'دي صورة الموديل، مش صورتك. النسخة التجريبية مش بتستخدم صورتك.');
  String get privacy => _('Your photos are deleted after 24 hours. You can delete them now at any time.', 'صورك بتتحذف بعد ٢٤ ساعة. وتقدري تحذفيها بنفسك في أي وقت.');
  String get tryWithout => _('Try without your photo', 'جرّبي من غير صورتك');
  String get uploading => _('Preparing your photo…', 'بنجهّز صورتك…');
  String get photoReadFail => _('We couldn’t open that image. Try a JPEG or PNG photo.', 'مش قادرين نفتح الصورة دي. جرّبي صورة JPEG أو PNG.');

  // reveal
  String get reading => _('Reading your skin, hair and eyes…', 'بنحلّل ألوان بشرتك وشعرك وعينيكي…');
  String get yourColours => _('Your colours', 'ألوانك');
  String get liftsYou => _('Lifts your colouring', 'بينوّر ملامحك');
  String get fightsYou => _('Fights your colouring', 'بيطفي ملامحك');
  String undertone(String u) => switch (u) {
        'warm' => _('Warm undertone', 'أندرتون دافي'),
        'cool' => _('Cool undertone', 'أندرتون بارد'),
        _ => _('Neutral undertone', 'أندرتون محايد'),
      };
  String contrast(String c) => switch (c) {
        'high' => _('high contrast', 'تباين عالي'),
        'low' => _('soft contrast', 'تباين ناعم'),
        _ => _('medium contrast', 'تباين متوسط'),
      };
  String metal(String m) => switch (m) {
        'gold' => _('Gold', 'ذهبي'),
        'silver' => _('Silver', 'فضي'),
        _ => _('Rose gold', 'ذهبي وردي'),
      };
  String get metalLabel => _('Your metal', 'لون المعدن المناسب ليكي');
  String get suitsLabel => _('Colours that work with you', 'ألوان لايقة عليكي');
  String get avoidLabel => _('Colours that fight your colouring', 'ألوان ممكن تطفي ملامحك');
  String get notMe => _('That’s not me:', 'النتيجة مش شبهي:');
  String get warmer => _('Warmer', 'أدفأ');
  String get cooler => _('Cooler', 'أبرد');
  String get shopColours => _('Shop your colours', 'تسوّقي الألوان اللي تليق عليكي');

  // shop
  String get shopTitle => _('Sorted by what suits you', 'مرتّبة حسب الألوان اللي تليق عليكي');
  String get verdictYours => _('Yours', 'لايق عليكي');
  String get verdictAvoid => _('Not your colour', 'مش من ألوانك');
  String get verdictNeutral => _('Could work', 'ممكن يليق عليكي');
  String get noneMatch => _('None of this store’s colours match yet — here are the closest.', 'مفيش ألوان في المتجر مطابقة لألوانك المناسبة دلوقتي. دي أقرب اختيارات ليكي.');
  String get tryOn => _('See it on me', 'شوفيها عليكي');

  // compare
  String dressing(String colour) => _('Dressing you in $colour…', 'بنجهّز معاينة للقطعة عليكي بلون $colour…');
  String get compareTitle => _('Same piece, two colours', 'نفس القطعة بلونين');
  String get noOffPalette => _('Every colour of this piece works with you. Here is the strongest one.', 'كل ألوان القطعة دي لايقة عليكي. وده أكتر لون مناسب ليكي.');
  String get notRecorded => _('This colour isn’t available to preview in demo mode yet.', 'معاينة اللون ده لسه مش متاحة في النسخة التجريبية.');
  String get retry => _('Try again', 'جرّبي تاني');
  String get completeLook => _('Complete the look', 'كمّلي الإطلالة');
  String get needBody => _('For the try-on we need one full-length photo.', 'عشان تجرّبي القطعة، محتاجين صورة واحدة ليكي من راسك لرجليكي.');

  // look
  String get earringsInMetal => _('Earrings in your metal', 'حلق بلون المعدن المناسب ليكي');
  String get earringUnavailable => _('Earring preview isn’t available in demo mode', 'معاينة الحلق مش متاحة في النسخة التجريبية');
  String get makeupUnavailable => _('Makeup preview isn’t available in demo mode', 'معاينة المكياج مش متاحة في النسخة التجريبية');
  String get lipShade => _('Your lip shade', 'لون الروج المناسب ليكي');
  String get matchingMakeup => _('Matching makeup', 'مكياج متناسق');
  String get lookCard => _('Your look', 'إطلالتك');
  String get addBundle => _('Add the look to cart', 'ضيفي الإطلالة للسلة');
  String get addedAtStore => _('Added to your cart at the store.', 'الإطلالة اتضافت لسلتك في المتجر.');
  String get demoCheckout => _('Demo checkout — nothing is charged.', 'دي تجربة للدفع، ومش هيتخصم منك أي مبلغ.');
  String get orderPlaced => _('Demo order placed', 'الطلب التجريبي اتسجّل');
  String get deletePhotos => _('Delete my photos', 'حذف صوري');
  String get deleted => _('Your photos and results are deleted.', 'صورك ونتايجك اتحذفت.');
  String get startOver => _('Start over', 'ابدئي من جديد');

  // layout
  String stepOf(int n) => _('Step $n of 4', 'الخطوة ${'٠١٢٣٤'[n]} من ٤');
  String get stepShop => _('Shop', 'تسوّقي');
  String get stepCompare => _('Compare', 'قارني');
  String get landingEyebrow => _('Colour-matched try-on', 'جرّبي الملابس بالألوان اللي تليق عليكي');
  String get how1Title => _('Read your colours', 'اكتشفي ألوانك');
  String get how1Body => _('One face photo, read by YouCam Facial Color Tones.', 'بنحلّل ألوانك من صورة واحدة لوشك باستخدام YouCam Facial Color Tones.');
  String get how2Title => _('See both colours on you', 'شوفي اللونين عليكي');
  String get how2Body => _('The colour that fights you beside the one that lifts you.', 'قارني اللون اللي بيطفي ملامحك باللون اللي بينوّرها.');
  String get how3Title => _('Complete the look', 'كمّلي الإطلالة');
  String get how3Body => _('Matching lip shade and metal, then straight to the cart.', 'لون روج ولون معدن لايقين عليكي، وبعدها ضيفي الإطلالة للسلة على طول.');
  String get poweredBy => _('Try-on powered by YouCam API', 'تجربة الملابس بتقنية YouCam API');
  String get compareLead => _('The same piece on you in two colours. Look at your face, not the fabric.', 'نفس القطعة عليكي بلونين. بصّي على وشك، مش على القماش.');
  String get lookLead => _('Outfit, lip shade and metal chosen from one reading.', 'الطقم ولون الروج ولون المعدن، كلهم بناءً على نفس تحليل الألوان.');
  String get yourPick => _('Your pick', 'اختيارك');

  // catalogue across stores
  String get searchHint => _('Search products', 'دوّري على منتج');
  String get allStores => _('All stores', 'كل المتاجر');
  String soldBy(String store) => _('Sold by $store', 'بيبيعه $store');
  String buyAt(String store) => _('Buy at $store', 'اشتري من $store');
  String get noResults => _('No products match. Try another word or store.', 'مفيش منتجات مطابقة. جرّبي كلمة أو متجر تاني.');
  String get buyAtNote => _('You finish checkout on the store’s own site.', 'هتكمّلي الدفع على موقع المتجر نفسه.');

  // not sold yet (YouCam AI Fabric)
  String get noneYoursHere => _('None of these colours is yours.', 'مفيش لون من دول مناسب ليكي.');
  String seeItIn(String colour) => _('See it in $colour', 'شوفيها بلون $colour');
  String get notSoldTitle => _('In your colour, not sold yet', 'بلون يليق عليكي، ولسه مش متاحة للبيع');
  String notSoldLead(String product, String colour, String closest) => _(
      '$product, re-made in $colour, close to your $closest. The store doesn’t sell it yet.',
      'معاينة لـ $product بلون $colour، قريب من لون $closest المناسب ليكي. المتجر لسه ما بيبيعش القطعة باللون ده.');
  String get notSoldBadge => _('Not sold yet', 'لسه مش متاحة للبيع');
  String get settledLabel => _('What you’d buy today', 'اختيارك لو هتشتري النهارده');
  String closeToYour(String colour) => _('Close to your $colour', 'قريب من لون $colour المناسب ليكي');
  String askStore(String colour) => _('Ask the store to make it in $colour', 'اطلبي من المتجر يوفّرها بلون $colour');
  String get askedStore => _('Request sent. The store sees it in its Drape console.', 'طلبك اتبعت. المتجر هيشوفه في لوحة تحكّم Drape.');
  String get previewUnavailable => _('The preview isn’t available right now, but you can still ask the store.', 'المعاينة مش متاحة دلوقتي، بس تقدري تطلبي اللون من المتجر.');
  String completeWith(String colour) => _('Complete the look with $colour', 'كمّلي الإطلالة بلون $colour');

  // Colour and fabric display names (customer-facing). Internal ids and the English names stay unchanged.
  // One mapping, used everywhere a colour is shown; listed in docs/submission/arabic-review-strings.md for review.
  static const _colourAr = {
    'Emerald': 'أخضر زمردي', 'Olive': 'زيتي', 'Terracotta': 'طوبي', 'Mustard': 'مستردة', 'Camel': 'جملي',
    'Deep teal': 'تيل غامق', 'Tomato red': 'أحمر طماطمي', 'Cream': 'كريمي', 'Icy pink': 'وردي ثلجي', 'Cool grey': 'رمادي بارد',
    'Lavender': 'موف فاتح', 'Fuchsia': 'فوشيا', 'Bubblegum pink': 'بينك فاقع', 'Navy': 'كحلي', 'Berry': 'توتي',
    'Cherry red': 'أحمر كرزي', 'Icy blue': 'لبني ثلجي', 'Charcoal': 'رمادي فحمي', 'Sapphire': 'أزرق ياقوتي', 'Pure white': 'أبيض ناصع',
    'Orange': 'برتقالي', 'Jade': 'أخضر يشمي', 'Dusty rose': 'روز مطفي', 'Soft navy': 'كحلي فاتح', 'Taupe': 'بيج رمادي',
    'Soft teal': 'تيل فاتح', 'Plum': 'برقوقي', 'Off white': 'أوف وايت', 'Neon yellow': 'أصفر نيون', 'Electric orange': 'برتقالي فاقع',
    'Jet black': 'أسود فاحم', 'Crisp white': 'أبيض صافي', 'Black': 'أسود', 'Aqua': 'أكوا', 'Saffron': 'زعفراني', 'Blush pink': 'بينك هادي',
    'Brick coral': 'كورال طوبي', 'Rose': 'روز',
    'Sea Green Silk': 'حرير أخضر بحري', 'Blue Wool': 'صوف أزرق', 'Green Velvet': 'قطيفة خضرا', 'Red Silk': 'حرير أحمر',
    'Red Velvet': 'قطيفة حمرا', 'Beige Linen': 'كتان بيج', 'Grey Cotton': 'قطن رمادي', 'Pink Cotton': 'قطن بينك',
    'Mint Green Wool': 'صوف أخضر نعناعي', 'Smokey Green Cotton': 'قطن أخضر مدخّن', 'Black Cotton': 'قطن أسود',
  };
  String colour(String name) => rtl ? (_colourAr[name] ?? name) : name;

  // generic
  String get somethingWrong => _('Something went wrong.', 'حصلت مشكلة.');
  String get sampleBadge => _('Sample person', 'الموديل التجريبي');
}
