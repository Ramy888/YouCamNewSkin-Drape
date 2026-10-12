# Arabic review: every string in the app

> **Status 2026-10-12:** the reviewer's 90 edits are applied in `app/lib/l10n.dart` (row 9 without its second sentence: no sample fallback happens there). Colour and fabric names are new below.

How to review: for each row, leave **Your edit** empty to approve it, or write the corrected Arabic there.
When done, tell me "Arabic review done" and I'll apply every edit to `app/lib/l10n.dart`, rebuild and redeploy.

Open questions (answer at the bottom): one dialect for the whole app (Egyptian colloquial or light MSA)? Keep colour names
(Emerald, Lavender…) and fabric names (Sea Green Silk…) in English inside Arabic sentences, or translate them?

| # | Screen | English | Arabic (current) | Your edit |
|---|---|---|---|---|
| 1 | error message | That publishable key doesn't match any store. | رابط المتجر غير صحيح. ارجعي لصفحة المنتج وجربي تاني. | مش قادرين نفتح المتجر بالرابط ده. ارجعي لصفحة المنتج وجرّبي تاني. |
| 2 | error message | Seller key missing or wrong. / This session is missing or has expired. | الجلسة انتهت. ابدئي من صفحة المنتج تاني. | مش قادرين نبدأ الجلسة. ارجعي لصفحة المنتج وابدئي تاني. |
| 3 | error message | This session has ended. | الجلسة انتهت. ابدئي من صفحة المنتج تاني. |  |
| 4 | error message | <site> is not on the store's allowed list. | المتجر ده مش مفعّل مع Drape لسه. | مش مسموح بفتح المتجر من الموقع ده. |
| 5 | error message | This product isn't on Drape yet. | المنتج ده مش متاح للتجربة حالياً. |  |
| 6 | error message | The photo is empty. / The file is not a JPEG or PNG image. | الملف ده مش صورة. اختاري صورة JPG أو PNG. | الصورة فاضية أو صيغتها مش مدعومة. اختاري صورة JPG أو PNG. |
| 7 | error message | The photo is larger than 10 MB. | الصورة كبيرة جداً. جربي صورة أصغر. | حجم الصورة أكبر من ١٠ ميجابايت. اختاري صورة أصغر. |
| 8 | error message | We need your face photo first. / We need a full-body photo for the try-on. | محتاجين صورتك الأول. | ضيفي صورتك الأول عشان نكمل. |
| 9 | error message | You've already seen one colour the store doesn't sell yet. | وصلنا للحد اليومي للتجربة الحية. هنعرض لك الشكل النموذجي. | جرّبتي بالفعل لون المتجر لسه ما بيبيعوش. هنعرضلك معاينة على الموديل التجريبي. |
| 10 | error message | Server misconfigured. / Something went wrong on our side. | حصلت مشكلة عندنا. جربي تاني بعد شوية. |  |
| 11 | error message | Lift your chin a little and look straight at the camera. | ارفعي ذقنك شوية وبصي للكاميرا على طول. | ارفعي دقنك شوية وبصّي للكاميرا مباشرة. |
| 12 | error message | Lower your chin a little and look straight at the camera. | نزّلي ذقنك شوية وبصي للكاميرا على طول. | نزّلي دقنك شوية وبصّي للكاميرا مباشرة. |
| 13 | error message | Face the camera straight on. | بصي للكاميرا على طول. | خلّي وشك في مواجهة الكاميرا مباشرة. |
| 14 | error message | We couldn't find a face. Move closer and face the camera. | مش لاقيين وش في الصورة. قرّبي وبصي للكاميرا. | مش قادرين نحدّد وشك في الصورة. قرّبي وخلّي وشك في مواجهة الكاميرا. |
| 15 | error message | Move closer so your face fills the oval. | قرّبي عشان وشك يملا الإطار. | قرّبي لحد ما وشك يملا الإطار البيضاوي. |
| 16 | error message | Only one person should be in the photo. | لازم يكون في شخص واحد بس في الصورة. | لازم تكوني لوحدك في الصورة. |
| 17 | error message | Stand facing the camera with your arms slightly away from your body. | اقفي في مواجهة الكاميرا وإيديكي بعيد شوية عن جسمك. | اقفي في مواجهة الكاميرا، وابعّدي دراعاتك شوية عن جسمك. |
| 18 | error message | Find softer, even light and try again. | دوري على نور هادي ومتساوي وجربي تاني. | اختاري مكان بإضاءة ناعمة وموزّعة بالتساوي، وجرّبي تاني. |
| 19 | error message | We couldn't see your ears to place the earrings. That's fine: your metal still shows in the look. | مش شايفين ودانك عشان نحط الحلق. مفيش مشكلة: لون معدنك ظاهر في الإطلالة. | مش قادرين نحدّد مكان ودانك عشان نعرض الحلق. مفيش مشكلة، لون المعدن المناسب ليكي لسه ظاهر في الإطلالة. |
| 20 | error message | This photo can't be used. Please choose a different one. | الصورة دي مينفعش نستخدمها. اختاري صورة تانية. | مش هينفع نستخدم الصورة دي. اختاري صورة تانية. |
| 21 | error message | This is taking too long. Try again. | الموضوع أخد وقت أطول من اللازم. جربي تاني. | التجربة أخدت وقت أطول من المتوقع. جرّبي تاني. |
| 22 | error message | The try-on service is busy. Try again in a minute. | الخدمة مشغولة. جربي تاني بعد دقيقة. | خدمة تجربة الملابس عليها ضغط دلوقتي. جرّبي تاني بعد دقيقة. |
| 23 | error message | Live try-on is paused. Showing the demo look instead. | التجربة الحية متوقفة حالياً. هنعرض لك الشكل النموذجي. | تجربة الملابس بصورتك متوقفة دلوقتي. هنعرضلك معاينة على الموديل التجريبي. |
| 24 | general | العربية | English |  |
| 25 | general | Back | رجوع |  |
| 26 | landing | Buy the colour that suits you | اختاري اللون اللي يليق بك | اشتري اللون اللي يليق عليكي |
| 27 | landing | Use my photo | استخدمي صورتي | استخدام صورتي |
| 28 | landing | Try with the sample person | جرّبي مع الشخص النموذجي | جرّبي على الموديل التجريبي |
| 29 | landing | No photo needed. See the full flow with our sample person. | من غير صور. شوفي التجربة كاملة مع الشخص النموذجي. | مش محتاجة تضيفي صورتك. شوفي التجربة كاملة على الموديل التجريبي. |
| 30 | capture | A clear photo of your face | صورة واضحة لوجهك | صورة واضحة لوشك |
| 31 | capture | Face the camera, chin level, soft even light, no sunglasses. | وجهك للكاميرا، ذقنك مستقيم، إضاءة هادئة ومتساوية، من غير نظارة شمس. | خلّي وشك في مواجهة الكاميرا، من غير ما ترفعي دقنك أو تنزّليها. اختاري إضاءة ناعمة وموزّعة بالتساوي، ومن غير نظارة شمس. |
| 32 | capture | A full-length photo | صورة كاملة من الرأس للقدم | صورة ليكي من راسك لرجليكي |
| 33 | capture | Stand facing the camera, one person only, your whole body in the frame. | قفي مواجهة الكاميرا، شخص واحد فقط، وجسمك كله داخل الصورة. | اقفي في مواجهة الكاميرا، لوحدك، وخلي جسمك كله ظاهر من راسك لرجليكي. |
| 34 | capture | Take or choose a photo | التقطي أو اختاري صورة | صوّري أو اختاري صورة |
| 35 | capture | Trying on with your own photo is switched off in this demo, so we show the full flow with our sample person. | التجربة بصورتك متوقفة في النسخة التجريبية، فبنعرض لك التجربة كاملة مع الشخص النموذجي. | تجربة الملابس بصورتك مش مفعّلة في النسخة التجريبية، فهنوريكي التجربة كاملة على الموديل التجريبي. |
| 36 | capture | This is the sample person, not you: demo mode doesn't use your photo. | دي صورة الشخص النموذجي مش صورتك: النسخة التجريبية ما بتستخدمش صورتك. | دي صورة الموديل، مش صورتك. النسخة التجريبية مش بتستخدم صورتك. |
| 37 | capture | Your photos are deleted after 24 hours. You can delete them now at any time. | صورك تُحذف بعد ٢٤ ساعة، وتقدرين تحذفينها الآن في أي وقت. | صورك بتتحذف بعد ٢٤ ساعة. وتقدري تحذفيها بنفسك في أي وقت. |
| 38 | capture | Try without your photo | جرّبي من غير صورتك |  |
| 39 | capture | Preparing your photo… | جارٍ تجهيز صورتك… | بنجهّز صورتك… |
| 40 | capture | We couldn’t open that image. Try a JPEG or PNG photo. | ما قدرنا نفتح الصورة. جرّبي صورة JPEG أو PNG. | مش قادرين نفتح الصورة دي. جرّبي صورة JPEG أو PNG. |
| 41 | reveal | Reading your skin, hair and eyes… | نقرأ ألوان بشرتك وشعرك وعينيك… | بنحلّل ألوان بشرتك وشعرك وعينيكي… |
| 42 | reveal | Your colours | ألوانك |  |
| 43 | reveal | Lifts your colouring | يبرز ألوانك | بينوّر ملامحك |
| 44 | reveal | Fights your colouring | يعاكس ألوانك | بيطفي ملامحك |
| 45 | reveal | Warm undertone | درجة دافئة | أندرتون دافي |
| 46 | reveal | Cool undertone | درجة باردة | أندرتون بارد |
| 47 | reveal | Neutral undertone | درجة محايدة | أندرتون محايد |
| 48 | reveal | high contrast | تباين عالٍ | تباين عالي |
| 49 | reveal | soft contrast | تباين هادئ | تباين ناعم |
| 50 | reveal | medium contrast | تباين متوسط |  |
| 51 | reveal | Gold | ذهبي |  |
| 52 | reveal | Silver | فضي |  |
| 53 | reveal | Rose gold | ذهبي وردي |  |
| 54 | reveal | Your metal | المعدن المناسب | لون المعدن المناسب ليكي |
| 55 | reveal | Colours that work with you | ألوان تناسبك | ألوان لايقة عليكي |
| 56 | reveal | Colours that fight your colouring | ألوان تعاكس ألوانك | ألوان ممكن تطفي ملامحك |
| 57 | reveal | That’s not me: | مش مظبوط: | النتيجة مش شبهي: |
| 58 | reveal | Warmer | أدفأ |  |
| 59 | reveal | Cooler | أبرد |  |
| 60 | reveal | Shop your colours | تسوّقي بألوانك | تسوّقي الألوان اللي تليق عليكي |
| 61 | shop | Sorted by what suits you | مرتّبة حسب ما يناسبك | مرتّبة حسب الألوان اللي تليق عليكي |
| 62 | shop | Yours | يناسبك | لايق عليكي |
| 63 | shop | Not your colour | ليس لونك | مش من ألوانك |
| 64 | shop | Could work | ممكن | ممكن يليق عليكي |
| 65 | shop | None of this store’s colours match yet — here are the closest. | لا توجد ألوان مطابقة لك هنا بعد — هذه الأقرب. | مفيش ألوان في المتجر مطابقة لألوانك المناسبة دلوقتي. دي أقرب اختيارات ليكي. |
| 66 | shop | See it on me | شوفيها | شوفيها عليكي |
| 67 | compare | Dressing you in $colour… | نُلبسك اللون $colour… | بنجهّز معاينة للقطعة عليكي بلون $colour… |
| 68 | compare | Same piece, two colours | نفس القطعة بلونين |  |
| 69 | compare | Every colour of this piece works with you. Here is the strongest one. | كل ألوان هذه القطعة تناسبك. هذا أقواها. | كل ألوان القطعة دي لايقة عليكي. وده أكتر لون مناسب ليكي. |
| 70 | compare | This colour isn’t available to preview in demo mode yet. | معاينة هذا اللون غير متاحة في وضع العرض بعد. | معاينة اللون ده لسه مش متاحة في النسخة التجريبية. |
| 71 | compare | Try again | حاولي مرة ثانية | جرّبي تاني |
| 72 | compare | Complete the look | كمّلي الإطلالة |  |
| 73 | compare | For the try-on we need one full-length photo. | للتجربة نحتاج صورة كاملة واحدة. | عشان تجرّبي القطعة، محتاجين صورة واحدة ليكي من راسك لرجليكي. |
| 74 | look | Earrings in your metal | حلق بلون معدنك | حلق بلون المعدن المناسب ليكي |
| 75 | look | Earring preview isn’t available in demo mode | معاينة الحلق غير متاحة في وضع العرض | معاينة الحلق مش متاحة في النسخة التجريبية |
| 76 | look | Makeup preview isn’t available in demo mode | معاينة المكياج غير متاحة في وضع العرض | معاينة المكياج مش متاحة في النسخة التجريبية |
| 77 | look | Your lip shade | لون الشفاه المناسب | لون الروج المناسب ليكي |
| 78 | look | Matching makeup | مكياج متناسق |  |
| 79 | look | Your look | إطلالتك |  |
| 80 | look | Add the look to cart | أضيفي الإطلالة للسلة | ضيفي الإطلالة للسلة |
| 81 | look | Added to your cart at the store. | تمت الإضافة إلى سلتك في المتجر. | الإطلالة اتضافت لسلتك في المتجر. |
| 82 | look | Demo checkout — nothing is charged. | دفع تجريبي — لن يتم خصم أي مبلغ. | دي تجربة للدفع، ومش هيتخصم منك أي مبلغ. |
| 83 | look | Demo order placed | تم الطلب التجريبي | الطلب التجريبي اتسجّل |
| 84 | look | Delete my photos | احذفي صوري | حذف صوري |
| 85 | look | Your photos and results are deleted. | تم حذف صورك ونتائجك. | صورك ونتايجك اتحذفت. |
| 86 | look | Start over | ابدئي من جديد |  |
| 87 | layout | Step $n of 4 | الخطوة ${ | الخطوة $n من ٤ |
| 88 | layout | Shop | تسوّقي |  |
| 89 | layout | Compare | قارني |  |
| 90 | layout | Colour-matched try-on | تجربة ملابس على ألوانك | جرّبي الملابس بالألوان اللي تليق عليكي |
| 91 | layout | Read your colours | نقرأ ألوانك | اكتشفي ألوانك |
| 92 | layout | One face photo, read by YouCam Facial Color Tones. | صورة واحدة لوجهك تقرأها YouCam Facial Color Tones. | بنحلّل ألوانك من صورة واحدة لوشك باستخدام YouCam Facial Color Tones. |
| 93 | layout | See both colours on you | شوفي اللونين عليكي |  |
| 94 | layout | The colour that fights you beside the one that lifts you. | اللون اللي يعاكسك جنب اللون اللي يبرزك. | قارني اللون اللي بيطفي ملامحك باللون اللي بينوّرها. |
| 95 | layout | Complete the look | كمّلي الإطلالة |  |
| 96 | layout | Matching lip shade and metal, then straight to the cart. | لون شفايف ومعدن متناسقين، وبعدها على السلة على طول. | لون روج ولون معدن لايقين عليكي، وبعدها ضيفي الإطلالة للسلة على طول. |
| 97 | layout | Try-on powered by YouCam API | التجربة بتقنية YouCam API | تجربة الملابس بتقنية YouCam API |
| 98 | layout | The same piece on you in two colours. Look at your face, not the fabric. | نفس القطعة عليكي بلونين. بصّي على وشك، مش على القماش. |  |
| 99 | layout | Outfit, lip shade and metal chosen from one reading. | الطقم ولون الشفايف والمعدن، كلهم من قراءة واحدة. | الطقم ولون الروج ولون المعدن، كلهم بناءً على نفس تحليل الألوان. |
| 100 | layout | Your pick | اختيارك |  |
| 101 | not sold yet (YouCam AI Fabric) | None of these colours is yours. | مفيش لون من دول يناسبك. | مفيش لون من دول مناسب ليكي. |
| 102 | not sold yet (YouCam AI Fabric) | See it in $colour | شوفيها بـ $colour | شوفيها بلون $colour |
| 103 | not sold yet (YouCam AI Fabric) | In your colour, not sold yet | بلونك، ولسه مش معروضة | بلون يليق عليكي، ولسه مش متاحة للبيع |
| 104 | not sold yet (YouCam AI Fabric) | Not sold yet | لسه مش معروضة | لسه مش متاحة للبيع |
| 105 | not sold yet (YouCam AI Fabric) | What you’d buy today | اللي هتشتريه النهارده | اختيارك لو هتشتري النهارده |
| 106 | not sold yet (YouCam AI Fabric) | Close to your $colour | قريب من لونك $colour | قريب من لون $colour المناسب ليكي |
| 107 | not sold yet (YouCam AI Fabric) | Ask the store to make it in $colour | اطلبي من المحل يعملها بـ $colour | اطلبي من المتجر يوفّرها بلون $colour |
| 108 | not sold yet (YouCam AI Fabric) | Request sent. The store sees it in its Drape console. | طلبك اتبعت. المحل هيشوفه في لوحة Drape. | طلبك اتبعت. المتجر هيشوفه في لوحة تحكّم Drape. |
| 109 | not sold yet (YouCam AI Fabric) | The preview isn’t available right now, but you can still ask the store. | المعاينة مش متاحة دلوقتي، بس تقدري تطلبي من المحل. | المعاينة مش متاحة دلوقتي، بس تقدري تطلبي اللون من المتجر. |
| 110 | not sold yet (YouCam AI Fabric) | Complete the look with $colour | كمّلي الإطلالة بـ $colour | كمّلي الإطلالة بلون $colour |
| 111 | generic | Something went wrong. | حدث خطأ ما. | حصلت مشكلة. |
| 112 | generic | Sample person | الشخص النموذجي | الموديل التجريبي |
| 113 | general | One face photo reads your skin, hair and eye colours. Then you see each colour of a garment on your own body, side by side. | صورة واحدة لوجهك تقرأ ألوان بشرتك وشعرك وعينيك. بعدها ترين كل لون من القطعة على جسمك، جنبًا إلى جنب. | بصورة واحدة لوشك، بنحلّل ألوان بشرتك وشعرك وعينيكي. بعدها تقدري تشوفي ألوان القطعة عليكي وتقارني بينها جنب بعض. |
| 114 | general | $product, re-made in $colour, close to your $closest. The store doesn’t sell it yet. | $product بـ $colour، قريبة من لونك $closest. المحل لسه ما بيبيعهاش. | معاينة لـ $product بلون $colour، قريب من لون $closest المناسب ليكي. المتجر لسه ما بيبيعش القطعة باللون ده. |

## Answers

- Dialect: Egyptian colloquial throughout: natural, friendly, professional, and addressed to a female customer. Avoid literal translations, Gulf forms, and switching between MSA and colloquial. Use consistent Egyptian forms such as ليكي، عليكي، تقدري، جرّبي، اختاري.
- Colour names: Translate customer-facing colour names into familiar Arabic labels, using one consistent mapping (e.g. Emerald → أخضر زمردي; Lavender → موف فاتح). Keep internal colour keys unchanged. Do not machine-translate product identifiers or insert an extra لون into placeholder values. The actual colour-name list is not supplied here and still needs a separate review.
- Fabric names: Translate descriptive fabric/colour labels naturally (e.g. Sea Green Silk → حرير أخضر بحري). Preserve brands, registered product names, and internal IDs. For an official English product name, keep the name as sold, with an Arabic descriptor if useful. The actual fabric-name list is not supplied here and still needs a separate review.

## Reviewer notes for implementation

- **Review status:** Arabic review done for all 114 supplied rows. A blank **Your edit** cell approves the existing Arabic; every populated cell is its replacement.
- **Scope:** This is a linguistic review of the supplied strings. No app source, error-code mapping, screenshots, colour catalogue, or fabric catalogue was supplied. Keep these notes separate from user-facing strings.
- **Rows 1, 2, 4 and 9:** Corrected messages that misrepresented the English condition. Row 2 uses a shared, neutral failure message because its English cell combines a wrong/missing seller key with a missing/expired session. If the app has distinct error codes, use distinct messages; reserve «الجلسة انتهت» for an actual expiry/end.
- **Row 6:** Covers both an empty image and an unsupported image format. If separate messages are available, use «الصورة فاضية. اختاري صورة تانية.» for an empty image and «صيغة الصورة مش مدعومة. اختاري صورة JPG أو PNG.» for an unsupported format.
- **Row 8:** The shared replacement avoids asking for the wrong photo type. Prefer distinct messages when the implementation can distinguish them: face → «ضيفي صورة واضحة لوشك الأول.»; full body → «ضيفي صورة ليكي من راسك لرجليكي عشان تجرّبي القطعة.».
- **Row 9:** The English says one unsupported colour has already been tried; it does not say a daily limit was reached. The replacement retains the existing demo fallback description. Confirm the fallback actually occurs when this error is shown; otherwise omit its second sentence.
- **Row 24:** Keep **English** if this button switches the current Arabic interface to English. The mismatch with the English column can be intentional for a language toggle; confirm the actual action before changing it.
- **Rows 27 and 84:** «استخدام صورتي» and «حذف صوري» are first-person action labels. They avoid an imperative that sounds as though the customer is being asked to act on the app's photos.
- **Rows 45–47:** Use «أندرتون» for the warm/cool/neutral undertone category; these are not just the visible skin shade. If a help label is available, explain it as «الميل الدافي أو البارد في لون بشرتك». Avoid changing the app's analysis logic.
- **Row 87:** The existing Arabic is truncated. The reviewed text is «الخطوة $n من ٤». Preserve the real Dart interpolation variable and syntax used in the source; do not paste the broken literal ${.
- **Placeholders:** Preserved $n, $colour, $product and $closest exactly as shown in the English cells. In the code, use the existing interpolation syntax and pass localized display names while preserving identifiers.
- **Privacy and demo claims (especially rows 23, 35–37, 82 and 85):** Wording follows the supplied behaviour claims. Verify these against actual photo deletion, demo, billing and deletion behaviour before deploying; this review does not establish that the claims are implemented.
- **Consistency:** Use «المتجر» for the shop, «الموديل التجريبي» for the sample person, «النسخة التجريبية» for demo mode, «لون الروج» for lip shade, and «لون المعدن المناسب ليكي» for the gold/silver/rose-gold recommendation. Preserve Drape and YouCam product/API names.

## Colour and fabric names (applied 2026-10-12, please confirm)

Shown in the Arabic screens instead of the English names. Leave **Your edit** empty to approve.

| English | Arabic (applied) | Your edit |
|---|---|---|
| Emerald | أخضر زمردي |  |
| Olive | زيتي |  |
| Terracotta | طوبي |  |
| Mustard | مستردة |  |
| Camel | جملي |  |
| Deep teal | تيل غامق |  |
| Tomato red | أحمر طماطمي |  |
| Cream | كريمي |  |
| Icy pink | وردي ثلجي |  |
| Cool grey | رمادي بارد |  |
| Lavender | موف فاتح |  |
| Fuchsia | فوشيا |  |
| Bubblegum pink | بينك فاقع |  |
| Navy | كحلي |  |
| Berry | توتي |  |
| Cherry red | أحمر كرزي |  |
| Icy blue | لبني ثلجي |  |
| Charcoal | رمادي فحمي |  |
| Sapphire | أزرق ياقوتي |  |
| Pure white | أبيض ناصع |  |
| Orange | برتقالي |  |
| Jade | أخضر يشمي |  |
| Dusty rose | روز مطفي |  |
| Soft navy | كحلي فاتح |  |
| Taupe | بيج رمادي |  |
| Soft teal | تيل فاتح |  |
| Plum | برقوقي |  |
| Off white | أوف وايت |  |
| Neon yellow | أصفر نيون |  |
| Electric orange | برتقالي فاقع |  |
| Jet black | أسود فاحم |  |
| Crisp white | أبيض صافي |  |
| Black | أسود |  |
| Aqua | أكوا |  |
| Saffron | زعفراني |  |
| Blush pink | بينك هادي |  |
| Brick coral | كورال طوبي |  |
| Rose | روز |  |
| Sea Green Silk | حرير أخضر بحري |  |
| Blue Wool | صوف أزرق |  |
| Green Velvet | قطيفة خضرا |  |
| Red Silk | حرير أحمر |  |
| Red Velvet | قطيفة حمرا |  |
| Beige Linen | كتان بيج |  |
| Grey Cotton | قطن رمادي |  |
| Pink Cotton | قطن بينك |  |
| Mint Green Wool | صوف أخضر نعناعي |  |
| Smokey Green Cotton | قطن أخضر مدخّن |  |
| Black Cotton | قطن أسود |  |
