import 'package:artisnal_app/features/learn/widgets/guide_diagram.dart';

/// One screen of a display's shooting guide: how to set the shot up, or a
/// worked example of the finished shot.
class GuideStep {
  const GuideStep({
    required this.title,
    required this.subtitle,
    this.art,
    this.showExample = false,
    this.caption,
  });

  final String title;
  final String subtitle;

  /// Line drawing of the setup. Null on an example step.
  final GuideArt? art;

  /// Shows the chosen material's photo of this display.
  final bool showExample;

  final String? caption;
}

const _fullDisplay = <GuideStep>[
  GuideStep(
    title: 'Lay the whole piece flat',
    subtitle: 'Floor or table · plain sheet under it',
    art: GuideArt.spread,
  ),
  GuideStep(
    title: 'Straighten every edge',
    subtitle: 'Borders even · no folds',
    art: GuideArt.grid,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'The whole piece in frame, laid flat',
    showExample: true,
    caption: 'Show every edge. Keep it flat, not hanging.',
  ),
];

const _mekhalaFull = <GuideStep>[
  GuideStep(
    title: 'Lay both pieces flat',
    subtitle: 'Mekhela and sador side by side · plain sheet under them',
    art: GuideArt.mekhalaSpread,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'Both pieces in frame, laid flat',
    showExample: true,
    caption: 'Show every edge. Keep both pieces flat, not hanging.',
  ),
];

const _closeUp = <GuideStep>[
  GuideStep(
    title: 'One hand-span away',
    subtitle:
        'Hold the phone 15–30 cm above the fabric — close enough to count '
        'threads',
    art: GuideArt.distance,
  ),
  GuideStep(
    title: 'Frame the detail',
    subtitle: 'Fill the centre box · edges parallel',
    art: GuideArt.close,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'So close you can count the threads',
    showExample: true,
  ),
];

const _draped = <GuideStep>[
  GuideStep(
    title: 'Good example',
    subtitle: 'Pleats falling free — or over the back of a chair',
    showExample: true,
    caption: 'A dark background makes pale silk glow.',
  ),
];

const _border = <GuideStep>[
  GuideStep(
    title: 'Find the border',
    subtitle:
        'Close on the extra-weft buta of the pallu — that is the handwork',
    art: GuideArt.border,
  ),
  GuideStep(
    title: 'Motif on a crossing point',
    subtitle: 'Use the grid — motif where lines cross',
    art: GuideArt.grid,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'Border filling the frame, folds giving it depth',
    showExample: true,
    caption: 'The border is where the weaver’s hours show.',
  ),
];

const _shawlFull = <GuideStep>[
  GuideStep(
    title: 'Hang the shawl straight',
    subtitle: 'On a rod · border down the side · tassels along the bottom',
    art: GuideArt.shawlFull,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'Whole shawl in frame, hanging straight',
    showExample: true,
    caption: 'Show the border and the tassels. Keep it straight, not draped.',
  ),
];

const _shawlFolded = <GuideStep>[
  GuideStep(
    title: 'One folded shawl',
    subtitle: 'Shot from above · border on the side · tassels along the front',
    art: GuideArt.shawlFolded,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'One fold in frame — tassels along the bottom',
    showExample: true,
    caption: 'Fold it so the border and tassels show.',
  ),
];

const _stoleFull = <GuideStep>[
  GuideStep(
    title: 'Hang the stole straight',
    subtitle: 'On a rod · borders down the sides · tassels along the bottom',
    art: GuideArt.stoleFull,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'Whole stole in frame, hanging straight',
    showExample: true,
    caption: 'Show the borders and the tassels. Keep it straight, not draped.',
  ),
];

const _stoleFolded = <GuideStep>[
  GuideStep(
    title: 'One folded stole',
    subtitle: 'Shot from above · border and tassels along the front edge',
    art: GuideArt.stoleFolded,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'One fold in frame — tassels along the bottom',
    showExample: true,
    caption: 'Fold it so the border and tassels show.',
  ),
];

const _mekhalaFolded = <GuideStep>[
  GuideStep(
    title: 'Stack the two pieces',
    subtitle:
        'Mekhela on top · sador underneath, border and tassels along the bottom',
    art: GuideArt.mekhalaFolded,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'Both pieces folded — sador border and tassels showing',
    showExample: true,
    caption:
        'The mekhela sits on top. The sador border runs along the bottom.',
  ),
];

const _folded = <GuideStep>[
  GuideStep(
    title: 'One folded sari in the box',
    subtitle: 'Shot from above — not a pile, a single stack',
    art: GuideArt.foldedStackInBox,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'One stack in frame — border strip visible on the side',
    showExample: true,
    caption: 'Layers tell the buyer how heavy the cloth is.',
  ),
];

const _mekhalaHanging = <GuideStep>[
  GuideStep(
    title: 'Hang both pieces',
    subtitle:
        'Mekhela on the left, shorter · sador on the right, with tassels',
    art: GuideArt.mekhalaHanging,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'Both pieces on hangers — sador longer, tassels at the bottom',
    showExample: true,
    caption: 'Hang them straight. The sador is the long piece with tassels.',
  ),
];

const _hanging = <GuideStep>[
  GuideStep(
    title: 'Hang it dead centre',
    subtitle: 'Rod or hanger · piece on the center vertical axis',
    art: GuideArt.hangingDisplayCentre,
  ),
  GuideStep(
    title: 'Good example',
    subtitle: 'Hung straight — whole piece in frame, not draped',
    showExample: true,
    caption: 'Hang it straight so the whole piece shows. Do not drape it.',
  ),
];

const _cushionSofa = <GuideStep>[
  GuideStep(
    title: 'Sit the cover on the sofa',
    subtitle: 'Close on one side of the sofa · whole cover in frame',
    art: GuideArt.cushionSofa,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'Cover against the back, only part of the sofa in frame',
    showExample: true,
    caption: 'Show the whole cover. Do not crop the corners.',
  ),
];

const _cushionFlat = <GuideStep>[
  GuideStep(
    title: 'Lay the cover flat',
    subtitle: 'Shot from above · all four corners in frame',
    art: GuideArt.cushionFlat,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'Laid flat so the whole cover is in frame',
    showExample: true,
    caption: 'Keep it flat and show every corner.',
  ),
];

const _gamusaFull = <GuideStep>[
  GuideStep(
    title: 'Hang the gamusa straight',
    subtitle: 'On a rod · borders on both sides · tassels along the bottom',
    art: GuideArt.gamusaFull,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'Whole gamusa in frame, hanging straight',
    showExample: true,
    caption: 'Show the end border and the tassels. Keep it straight.',
  ),
];

const _gamusaFolded = <GuideStep>[
  GuideStep(
    title: 'One folded gamusa',
    subtitle: 'Shot from above · end border across · tassels along the front',
    art: GuideArt.gamusaFolded,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'One fold in frame — tassels along the bottom',
    showExample: true,
    caption: 'Fold it so the end border and tassels show.',
  ),
];

const _jodHanging = <GuideStep>[
  GuideStep(
    title: 'Hang both pieces',
    subtitle: 'One rod · wide cloth on the left · narrow piece with tassels',
    art: GuideArt.jodHanging,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'Both pieces in frame, hanging straight',
    showExample: true,
    caption: 'Show the wide border and the tassels. Keep both pieces straight.',
  ),
];

const _yardageHanging = <GuideStep>[
  GuideStep(
    title: 'Hang the yardage straight',
    subtitle: 'On a rod · motifs scattered across · no border or tassels',
    art: GuideArt.yardageHanging,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'Whole cloth in frame, hanging from the rod',
    showExample: true,
    caption: 'Show the scattered motifs. Keep the cloth straight.',
  ),
];

const _yardageClose = <GuideStep>[
  GuideStep(
    title: 'Fill the frame with the weave',
    subtitle: 'Close on the cloth · a few motifs in the shot',
    art: GuideArt.yardageClose,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'So close the weave and motifs fill the frame',
    showExample: true,
    caption: 'Count the threads. Keep a few motifs in the shot.',
  ),
];

const _jodFolded = <GuideStep>[
  GuideStep(
    title: 'Lay both pieces side by side',
    subtitle: 'Wide fold on the left · smaller piece with tassels on the right',
    art: GuideArt.jodFolded,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'Both folds in frame — tassels along the small piece',
    showExample: true,
    caption: 'Keep them side by side so the border and the tassels show.',
  ),
];

const _guides = <String, List<GuideStep>>{
  'full_display': _fullDisplay,
  'close-up_texture': _closeUp,
  'draped_look': _draped,
  'embroidery_and_border': _border,
  'folded_stack': _folded,
  'hanging_display': _hanging,
  'sofa_seated_display': _cushionSofa,
  'flat_lay_display': _cushionFlat,
};

/// Steps for a display, by its [DisplayOption.key].
List<GuideStep> guideFor(String displayKey, {String? product}) {
  if (displayKey == 'full_display' && product == 'Mekhala sador') {
    return _mekhalaFull;
  }
  if (displayKey == 'hanging_display' && product == 'Mekhala sador') {
    return _mekhalaHanging;
  }
  if (displayKey == 'folded_stack' && product == 'Mekhala sador') {
    return _mekhalaFolded;
  }
  if (displayKey == 'full_display' && product == 'Stole') {
    return _stoleFull;
  }
  if (displayKey == 'folded_stack' && product == 'Stole') {
    return _stoleFolded;
  }
  if (displayKey == 'full_display' && product == 'Shawl') {
    return _shawlFull;
  }
  if (displayKey == 'folded_stack' && product == 'Shawl') {
    return _shawlFolded;
  }
  if (displayKey == 'full_display' && product == 'Gamusa') {
    return _gamusaFull;
  }
  if (displayKey == 'folded_stack' && product == 'Gamusa') {
    return _gamusaFolded;
  }
  if (displayKey == 'hanging_display' && product == 'Jod kappur') {
    return _jodHanging;
  }
  if (displayKey == 'folded_stack' && product == 'Jod kappur') {
    return _jodFolded;
  }
  if (displayKey == 'hanging_display' && product == 'Yardages') {
    return _yardageHanging;
  }
  if (displayKey == 'close-up_texture' && product == 'Yardages') {
    return _yardageClose;
  }
  return _guides[displayKey] ?? _fullDisplay;
}
