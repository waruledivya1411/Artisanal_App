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
    subtitle: 'Corners square · borders even · no folds',
    art: GuideArt.grid,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'The whole piece in frame, laid flat',
    showExample: true,
    caption: 'Show every edge. Keep it flat, not hanging.',
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
    title: 'Rake the light across',
    subtitle:
        'Light from one side, low at about 30° — the tiny shadows make the '
        'weave stand up',
    art: GuideArt.rake,
  ),
  GuideStep(
    title: 'Frame the detail',
    subtitle: 'Fill the centre box · edges parallel',
    art: GuideArt.close,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'So close you can count the threads',
    showExample: true,
    caption: 'The shadows in the weave are the raking light doing the work.',
  ),
];

const _draped = <GuideStep>[
  GuideStep(
    title: 'Throw one end over',
    subtitle: 'Let it fall in natural folds',
    art: GuideArt.drape,
  ),
  GuideStep(
    title: 'Good examples',
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
    title: 'Good examples',
    subtitle: 'Border filling the frame, folds giving it depth',
    showExample: true,
    caption: 'The border is where the weaver’s hours show.',
  ),
];

const _folded = <GuideStep>[
  GuideStep(
    title: 'Fold from the middle',
    subtitle: 'Flat on the floor · fold in half',
    art: GuideArt.foldHalf,
  ),
  GuideStep(
    title: 'Fold a corner back',
    subtitle: 'The folded edge shows the thickness',
    art: GuideArt.foldCorner,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'Folded stacks — layers show body and weight',
    showExample: true,
    caption: 'Layers tell the buyer how heavy the cloth is.',
  ),
];

const _hanging = <GuideStep>[
  GuideStep(
    title: 'Hang it dead centre',
    subtitle: 'Rod or hanger · piece on the center vertical axis',
    art: GuideArt.hang,
  ),
  GuideStep(
    title: 'Let the fringe hang free',
    subtitle: 'Straighten the tassels · keep both edges symmetric',
    art: GuideArt.drape,
  ),
  GuideStep(
    title: 'Good examples',
    subtitle: 'Hung straight — whole piece in frame, not draped',
    showExample: true,
    caption: 'Hang it straight so the whole piece shows. Do not drape it.',
  ),
];

const _guides = <String, List<GuideStep>>{
  'full_display': _fullDisplay,
  'close-up_texture': _closeUp,
  'draped_look': _draped,
  'embroidery_and_border': _border,
  'folded_stack': _folded,
  'hanging_display': _hanging,
};

/// Steps for a display, by its [DisplayOption.key].
List<GuideStep> guideFor(String displayKey) =>
    _guides[displayKey] ?? _fullDisplay;
