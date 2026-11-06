/// Writes the prompt an artisan copies into their own AI tool, from a few taps.
///
/// Prompts stay short and in English whatever language the app is in: the
/// artisan only copies them, and AI tools follow English most reliably.
library;

enum AiGoal { cleanBackground, betterLight, newDisplay, addProps, makeClothes }

/// Something the artisan can tap: its [label] on screen, and its [line], which
/// is the words it adds to the prompt or the help under the label.
class AiChoice {
  const AiChoice(this.label, this.line, {this.withModel = false});

  final String label;
  final String line;

  /// The picture shows a person wearing the product, so the prompt must not
  /// say "no people".
  final bool withModel;
}

class _Scenes {
  const _Scenes({
    required this.displays,
    required this.props,
    this.clothes = const [],
  });

  final List<AiChoice> displays;
  final List<AiChoice> props;

  /// Clothes sewn from the fabric, for products sold by the metre.
  final List<AiChoice> clothes;
}

/// A new display or scene cannot be made from one photo: the AI needs to see
/// the whole product, and the motif up close to copy it.
const aiNeededPhotos = <AiChoice>[
  AiChoice('Full photo', 'The whole product in one photo'),
  AiChoice('Close-up of the motif', 'Close enough to see the threads'),
];

bool aiNeedsBothPhotos(AiGoal goal) =>
    goal == AiGoal.newDisplay ||
    goal == AiGoal.addProps ||
    goal == AiGoal.makeClothes;

const _productWords = <String, String>{
  'Saree': 'saree',
  'Mekhala sador': 'mekhela sador set',
  'Stole': 'stole',
  'Gamusa': 'gamusa',
  'Shawl': 'shawl',
  'Jod kappur': 'jod kappur set (wide cloth and smaller tasseled piece)',
  'Yardages': 'fabric',
  'Cushion covers': 'cushion cover',
};

// Close-ups are left out on purpose: a close-up has to be a real photo,
// because it is the proof of the handwork.
const _scenes = <String, _Scenes>{
  'Saree': _Scenes(
    displays: [
      AiChoice(
        'Draped',
        'Show this saree draped on a plain mannequin, with neat front pleats and the pallu over the shoulder.',
      ),
      AiChoice(
        'Hanging',
        'Show this saree hanging straight from a wooden rod against a plain wall, with the whole piece in frame.',
      ),
      AiChoice(
        'Folded',
        'Show this saree neatly folded on a wooden table, with the pallu on top and the border along the edge.',
      ),
    ],
    props: [
      AiChoice(
        'Mannequin',
        'Show this saree worn on a full-length plain mannequin, standing in a bright, simple room.',
      ),
      AiChoice(
        'Real model',
        'Show a real woman wearing this saree, traditionally draped, with neat front pleats and the pallu over her shoulder, against a plain background.',
        withModel: true,
      ),
      AiChoice(
        'Wooden hanger',
        'Hang this saree on a wooden hanger against a plain wall, with the pallu falling in front.',
      ),
      AiChoice(
        'Chair',
        'Drape this saree over the back of a wooden chair, with the pallu hanging down.',
      ),
      AiChoice(
        'Festive setting',
        'Place this saree, neatly folded, on a wooden table with a brass lamp and a few flowers beside it.',
      ),
    ],
  ),
  'Mekhala sador': _Scenes(
    displays: [
      AiChoice(
        'Draped',
        'Show this mekhela and sador worn on a plain mannequin, with the sador over the shoulder and both borders visible.',
      ),
      AiChoice(
        'Hanging',
        'Show the mekhela and sador hanging side by side from a wooden rod against a plain wall, with both pieces in frame.',
      ),
      AiChoice(
        'Folded',
        'Show the mekhela and sador neatly folded and stacked on a wooden table, with both borders along the edge.',
      ),
    ],
    props: [
      AiChoice(
        'Mannequin',
        'Show the mekhela and sador worn on a full-length plain mannequin, standing in a bright, simple room.',
      ),
      AiChoice(
        'Real model',
        'Show a real woman wearing it in Assamese style: mekhela pleated at the waist, sador over the shoulder, standing.',
        withModel: true,
      ),
      AiChoice(
        'Wooden hanger',
        'Hang the mekhela and sador on two wooden hangers against a plain wall.',
      ),
      AiChoice(
        'Chair',
        'Drape the sador over the back of a wooden chair, with the folded mekhela on the seat.',
      ),
      AiChoice(
        'Festive setting',
        'Place the mekhela and sador, neatly folded, on a wooden table with a brass lamp and a few flowers beside them.',
      ),
    ],
  ),
  'Stole': _Scenes(
    displays: [
      AiChoice(
        'Draped',
        'Show this stole draped around the neck of a plain mannequin, with both ends falling in front.',
      ),
      AiChoice(
        'Hanging',
        'Show this stole hanging straight from a wooden rod against a plain wall, with the whole piece in frame.',
      ),
      AiChoice(
        'Folded',
        'Show this stole neatly folded on a wooden table, with the border along the top edge.',
      ),
    ],
    props: [
      AiChoice(
        'Wooden hanger',
        'Hang this stole on a wooden hanger against a plain wall, with both ends falling straight.',
      ),
    ],
  ),
  'Gamusa': _Scenes(
    displays: [
      AiChoice(
        'Draped',
        'Show this gamusa draped around the neck of a plain mannequin, with both ends falling in front.',
      ),
      AiChoice(
        'Hanging',
        'Show this gamusa hanging straight from a wooden rod against a plain wall, with the whole piece in frame.',
      ),
      AiChoice(
        'Folded',
        'Show this gamusa neatly folded on a wooden table, with the border along the top edge.',
      ),
    ],
    props: [
      AiChoice(
        'Wooden hanger',
        'Hang this gamusa on a wooden hanger against a plain wall, with both ends falling straight.',
      ),
    ],
  ),
  'Shawl': _Scenes(
    displays: [
      AiChoice(
        'Draped',
        'Show this shawl draped over the shoulders of a plain mannequin, with the border visible.',
      ),
      AiChoice(
        'Hanging',
        'Show this shawl hanging straight from a wooden rod against a plain wall, with the whole piece in frame.',
      ),
      AiChoice(
        'Folded',
        'Show this shawl neatly folded on a wooden table, with the border along the top edge.',
      ),
    ],
    props: [
      AiChoice(
        'Wooden hanger',
        'Hang this shawl on a wooden hanger against a plain wall, with both ends falling straight.',
      ),
    ],
  ),
  'Jod kappur': _Scenes(
    displays: [
      AiChoice(
        'Hanging',
        'Show both pieces of this jod kappur hanging side by side from a wooden rod against a plain wall, with the tassels visible.',
      ),
      AiChoice(
        'Folded',
        'Show both pieces of this jod kappur neatly folded and stacked on a wooden table, with the borders along the edge.',
      ),
    ],
    props: [
      AiChoice(
        'Cane stool',
        'Place both pieces of this jod kappur, neatly folded, on a cane stool.',
      ),
      AiChoice(
        'Festive setting',
        'Place both pieces of this jod kappur, neatly folded, on a wooden table with a brass lamp and a few flowers beside them.',
      ),
      AiChoice(
        'Outdoor courtyard',
        'Hang both pieces of this jod kappur side by side from a bamboo pole in a bright outdoor courtyard.',
      ),
    ],
  ),
  'Yardages': _Scenes(
    displays: [
      AiChoice(
        'Hanging',
        'Show this fabric hanging straight from a wooden rod against a plain wall, in one long clean length.',
      ),
      AiChoice(
        'Folded',
        'Show this fabric neatly folded on a wooden table, with the pattern visible on top.',
      ),
      AiChoice(
        'Fabric roll',
        'Show this fabric as a neat roll on a wooden table, with a length unrolled in front.',
      ),
    ],
    props: [
      AiChoice(
        'Measuring tape',
        'Place this fabric, neatly folded, on a wooden table with a measuring tape and scissors beside it.',
      ),
      AiChoice(
        'Basket',
        'Place this fabric, neatly folded, in a cane basket on a wooden table.',
      ),
      AiChoice(
        'Outdoor courtyard',
        'Hang this fabric from a bamboo pole in a bright outdoor courtyard, with the whole piece in frame.',
      ),
    ],
    clothes: [
      AiChoice(
        'Kurti',
        'Sew this fabric into a knee-length kurti worn by a real woman, keeping the pattern at its true size. Plain background.',
        withModel: true,
      ),
      AiChoice(
        'Kurta',
        'Sew this fabric into a long kurta worn by a real man, keeping the pattern at its true size. Plain background.',
        withModel: true,
      ),
      AiChoice(
        'Shirt',
        'Sew this fabric into a collared shirt worn by a real man, keeping the pattern at its true size. Plain background.',
        withModel: true,
      ),
    ],
  ),
  'Cushion covers': _Scenes(
    displays: [
      AiChoice(
        'Sofa-Seated',
        'Show this cushion on a neutral sofa in a bright room, with all four corners visible.',
      ),
      AiChoice(
        'Flat-Lay',
        'Show this cushion flat on a plain surface from directly above, with all four corners visible.',
      ),
    ],
    props: [
      AiChoice(
        'Sofa',
        'Show this cushion leaning against the arm of a neutral sofa, with all four corners visible.',
      ),
    ],
  ),
};

List<AiChoice> aiDisplaysFor(String? product) =>
    _scenes[product]?.displays ?? const [];

List<AiChoice> aiPropsFor(String? product) =>
    _scenes[product]?.props ?? const [];

List<AiChoice> aiClothesFor(String? product) =>
    _scenes[product]?.clothes ?? const [];

/// The finished prompt. [scene] is the display or prop tapped, for the goals
/// that need one.
String buildAiPrompt({
  required String product,
  required AiGoal goal,
  String? scene,
}) {
  final word = _productWords[product] ?? product.toLowerCase();
  final short = word.split(' (').first;
  String editOnePhoto(String wish) =>
      'Edit my photo. $wish\n\n'
      'Do not change the $short: keep the same motifs, border, colours and weave. No text.';
  String makeFromTwoPhotos(List<AiChoice> choices) {
    final choice = choices.firstWhere((item) => item.label == scene);
    // A real model wears the product, so this one must not say "no people".
    final ending = choice.withModel
        ? 'It must be this exact $short, not a similar one. Do not redesign anything. Realistic photo, soft natural light, no text.'
        : 'Do not redesign anything. Realistic photo, soft natural light, no people, no text.';
    return 'Photo 1 shows my handwoven $word in full. '
        'Photo 2 shows its motif up close.\n\n'
        '${choice.line}\n\n'
        'Copy the motifs, border, colours and weave exactly from my photos. $ending';
  }

  return switch (goal) {
    AiGoal.cleanBackground => editOnePhoto(
      'Replace only the background with a plain off-white wall.',
    ),
    AiGoal.betterLight => editOnePhoto(
      'Make the light soft and even, and remove harsh shadows. Keep the true colours.',
    ),
    AiGoal.newDisplay => makeFromTwoPhotos(aiDisplaysFor(product)),
    AiGoal.addProps => makeFromTwoPhotos(aiPropsFor(product)),
    AiGoal.makeClothes => makeFromTwoPhotos(aiClothesFor(product)),
  };
}
