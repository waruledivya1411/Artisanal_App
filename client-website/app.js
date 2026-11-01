const IMG = "../assets/images/";

const LANGS = [
  { id: "as", locale: "as-IN", native: "অসমীয়া", english: "Assamese" },
  { id: "en", locale: "en-US", native: "English", english: "English", single: true },
  { id: "or", locale: "or-IN", native: "ଓଡ଼ିଆ", english: "Odia" },
  { id: "te", locale: "te-IN", native: "తెలుగు", english: "Telugu" },
];

const PRODUCTS = [
  ["Saree", "Cotton", "lessons/products/product_saree.jpg"],
  ["Mekhala sador", "Mulberry", "lessons/products/product_mekhala_sador.jpg"],
  ["Stole", "Eri", "lessons/products/product_stole.jpg"],
  ["Gamusa", "Cotton", "lessons/products/product_gamusa.jpg"],
  ["Shawl", "Eri", "lessons/products/product_shawl.jpg"],
  ["Jod kappur", "Cotton", "lessons/products/product_jod_kappur.jpg"],
  ["Yardages", "Cotton", "lessons/products/product_yardages.jpg"],
  ["Cushion covers", "Mulberry", "lessons/products/product_cushion_covers.jpg"],
];

const DISPLAYS = {
  full: ["Full display", "full_display"],
  close: ["Close-up texture", "close-up_texture"],
  draped: ["Draped", "draped_look"],
  border: ["Embroidery and border", "embroidery_and_border"],
  folded: ["Folded", "folded_stack"],
  hanging: ["Hanging", "hanging_display"],
  sofa: ["Sofa-Seated", "sofa_seated_display"],
  flat: ["Flat-Lay", "flat_lay_display"],
};

const WHOLE_PHOTOS = new Set(["Jod kappur", "Cushion covers"]);

const OWN_PHOTOS = new Set([
  "Mekhala sador",
  "Gamusa",
  "Shawl",
  "Stole",
  "Cushion covers",
  "Jod kappur",
  "Yardages",
]);

const state = {
  lang: localStorage.getItem("cs-lang") || "as-IN",
  langBefore: null,
  stack: [],
  tab: "learn",
  progress: JSON.parse(localStorage.getItem("cs-progress") || "{}"),
  photos: localStorage.getItem("cs-photos") === "1",
  email: "",
  password: "",
  hidePassword: true,
  resetEmail: "",
  resetSent: false,
  choice: null,
  product: null,
  tryName: "",
  tryCategory: "Clothing (Brand)",
  tryShow: true,
  tryStep: 0,
  toast: "",
  earned: false,
  pickedDisplays: [],
  shotQueue: [],
  shotDone: [],
  shotChosen: null,
  createStep: 0,
  createPhoto: null,
};

let splashTimer = 0;
let toastTimer = 0;

function toast(message) {
  state.toast = message;
  render();
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    state.toast = "";
    render();
  }, 2200);
}

function code() {
  return state.lang.toLowerCase().split("-")[0];
}

function applyTemplate(table, key, values) {
  const pattern = table[key];
  if (!pattern) return null;
  return Object.keys(values).reduce(
    (out, name) => out.replace("{" + name + "}", values[name]),
    pattern,
  );
}

function t(text) {
  if (!text || code() === "en") return text;
  const table = (window.I18N && window.I18N[code()]) || {};
  if (table[text]) return table[text];
  const source = String(text);
  const rules = [
    [/^(\d+) OF (\d+) TASKS DONE$/, "{done} OF {total} TASKS DONE", (m) => ({ done: m[1], total: m[2] })],
    [/^(\d+) of (\d+) done$/, "{done} of {total} done", (m) => ({ done: m[1], total: m[2] })],
    [/^Next task: (.+)$/, "Next task: {task}", (m) => ({ task: t(m[1]) })],
    [/^Fit the (.+) inside the dotted line$/, "Fit the {product} inside the dotted line", (m) => ({ product: t(m[1]) })],
    [/^Move the (.+) into the frame$/, "Move the {product} into the frame", (m) => ({ product: t(m[1]) })],
    [/^Set up your page\. Step (\d+) of (\d+)\.$/, "Set up your page. Step {n} of {total}.", (m) => ({ n: m[1], total: m[2] })],
    [/^Finish (.+) first$/, "Finish {part} first", (m) => ({ part: t(m[1]) })],
    [/^TASK (\d+) · (\d+) OF (\d+)$/, "TASK {task} · {step} OF {total}", (m) => ({ task: m[1], step: m[2], total: m[3] })],
    [/^Name @(.+)$/, "Name @{handle}", (m) => ({ handle: m[1] })],
  ];
  for (const [pattern, key, values] of rules) {
    const match = source.match(pattern);
    if (!match) continue;
    const filled = applyTemplate(table, key, values(match));
    if (filled) return filled;
  }
  return text;
}

function esc(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function img(path) {
  return IMG + path;
}

function saveProgress() {
  localStorage.setItem("cs-progress", JSON.stringify(state.progress));
}

function partKey(task, part) {
  return task + ":" + part;
}

function isPartDone(task, part) {
  return !!state.progress[partKey(task, part)];
}

function markPart(task, part) {
  state.progress[partKey(task, part)] = true;
  saveProgress();
}

function isTaskDone(task) {
  return task.parts.every((part) => isPartDone(task.id, part.id));
}

function completedCount() {
  return TASKS.filter(isTaskDone).length;
}

function nativeName() {
  const id = code();
  return (LANGS.find((item) => item.id === id) || LANGS[1]).native;
}

function speak(text) {
  if (!window.speechSynthesis) return;
  window.speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(t(text));
  utterance.lang = state.lang === "en" ? "en-US" : state.lang;
  window.speechSynthesis.speak(utterance);
}

function captureFields() {
  const email = document.getElementById("email");
  const password = document.getElementById("password");
  const reset = document.getElementById("reset-email");
  const tryName = document.getElementById("try-name");
  if (email) state.email = email.value;
  if (password) state.password = password.value;
  if (reset) state.resetEmail = reset.value;
  if (tryName) state.tryName = tryName.value;
}

function push(name, params) {
  clearTimeout(splashTimer);
  captureFields();
  state.stack.push(Object.assign({ name }, params));
  if (name === "check") state.choice = null;
  render();
}

function replace(name, params) {
  clearTimeout(splashTimer);
  captureFields();
  state.stack = [Object.assign({ name }, params)];
  render();
}

function back() {
  captureFields();
  if (state.stack.length <= 1) return;
  const leaving = state.stack[state.stack.length - 1];
  state.stack.pop();
  if (leaving.name === "language" && leaving.changing && state.langBefore) {
    state.lang = state.langBefore;
  }
  render();
}

function current() {
  return state.stack[state.stack.length - 1];
}

const svg = {
  back: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 6l-6 6 6 6"/></svg>',
  chev: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 6l6 6-6 6"/></svg>',
  check: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5.2 12.4l4.2 4.2L18.8 7.4" stroke="#fff" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/></svg>',
  mail: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 7 9-7"/></svg>',
  lock: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 018 0v3"/></svg>',
  eye: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>',
  eyeOff: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 3l18 18"/><path d="M10.6 6.2A10 10 0 0112 6c6 0 10 6 10 6a18 18 0 01-4.2 4.4M6.1 6.7C3.6 8.3 2 12 2 12s4 7 10 7a10 10 0 004.2-.9"/></svg>',
  translate: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 5h8M8 5c0 6-3 8-5 9M8 5c1 4 4 7 8 8"/><path d="M14 14l2 6 2-6M13 17h6"/></svg>',
  down: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>',
  play: '<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M9 7l10 5-10 5V7z"/></svg>',
  camera: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M4 8h3l2-2h6l2 2h3v11H4V8z"/><circle cx="12" cy="13" r="3.2"/></svg>',
  medal: '<svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l2.2 4.6L19 8l-3.5 3.4.8 4.8L12 14.8 7.7 16.2l.8-4.8L5 8l4.8-1.4L12 2z"/></svg>',
  lockBadge: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 018 0v3"/></svg>',
};

function btn(label, act, extra) {
  return `<button class="btn" data-act="${act}" ${extra || ""}>${esc(t(label))}</button>`;
}

function backBtn() {
  return `<button class="icon-btn" data-act="back" aria-label="${esc(t("Back"))}">${svg.back}</button>`;
}

function speakBtn(text) {
  return `<button class="speak" data-act="speak" data-text="${esc(text)}" aria-label="Listen"><img src="${img("icons/speaker.png")}" alt=""></button>`;
}

function nav(tab) {
  const item = (id, inner, label) =>
    `<button class="${tab === id ? "on" : ""}" data-act="tab" data-tab="${id}">${inner}<span>${esc(t(label))}</span></button>`;
  return `<nav class="nav">
    ${item("learn", `<img src="${img("icons/book.png")}" alt="">`, "Learn")}
    ${item("photo", svg.camera, "Photo")}
    ${item("me", `<img src="${img("icons/user.png")}" alt="">`, "Me")}
  </nav>`;
}

function screen(inner, extra) {
  const note = state.toast ? `<div class="toast">${esc(state.toast)}</div>` : "";
  return `<section class="screen ${extra || ""}">${inner}${note}</section>`;
}

function checkPair(part) {
  return {
    wrong: part.wrong,
    right: part.right,
    rightReason: part.rightReason,
    wrongReason: part.wrongReason,
    label: part.label,
  };
}

function lesson(part, fields) {
  return Object.assign({}, part, fields);
}

const photo = (file) => "lessons/photography/" + file;
const setup = (file) => "lessons/set_up_page/" + file;
const plan = (file) => "lessons/posting_plan/" + file;
const numbers = (file) => "lessons/read_numbers/" + file;
const postArt = (file) => "lessons/create_post/" + file;

const CREATE_KINDS = ["post", "story", "reel"];

const CREATE_GUIDE = {
  post: {
    title: "Post",
    detail: "Photo on your page",
    header: "Post in Instagram",
    spoken: "Post in Instagram. Tap plus at the top left. Pick your photo, paste your words, then tap Share.",
    first: "Tap the plus sign to start a new post.",
    steps: ["Tap +", "Pick your photo", "Paste your words", "Tap Share"],
    instructionTitle: "Make a feed post",
    instructionBody: "A post stays on your page. Use a clear photo of your cloth.",
    pickHeader: "New post",
    pickStep: "STEP 2 OF 4",
    pickTitle: "Pick your photo",
    pickSpoken: "Pick your photo. Tap the cloth picture, then tap Next.",
  },
  story: {
    title: "Story",
    detail: "Shows for one day",
    header: "Share a story",
    spoken: "To share a story, tap plus, then tap Story. Pick your photo and tap Your story.",
    first: "Tap plus, then choose Story.",
    steps: ["Tap +", "Tap Story", "Pick your photo", "Tap Your story"],
    instructionTitle: "Make a story",
    instructionBody: "Stories disappear after one day. Show your weave up close.",
    pickHeader: "New story",
    pickStep: "STEP 3 OF 4",
    pickTitle: "Pick your photo",
    pickSpoken: "Pick your photo for your story. Tap the cloth picture, then tap Next.",
  },
  reel: {
    title: "Reel",
    detail: "Short video clip",
    header: "Make a reel",
    spoken: "To make a reel, tap plus, then tap Reel. Pick a short clip of your work and tap Share.",
    first: "Tap plus, then choose Reel.",
    steps: ["Tap +", "Tap Reel", "Pick your clip", "Tap Share"],
    instructionTitle: "Make a reel",
    instructionBody: "Reels are short videos. Show your hands at the loom.",
    pickHeader: "New reel",
    pickStep: "STEP 3 OF 4",
    pickTitle: "Pick your clip",
    pickSpoken: "Pick your video. Tap a clip of your weaving, then tap Next.",
  },
};

const GALLERY = [
  "lessons/photography/fabric_straight.jpg",
  "lessons/read_numbers/post_many_saves.jpg",
  "lessons/read_numbers/reply_cloth_post.jpg",
  "lessons/photography/fabric_steady.jpg",
  "lessons/read_numbers/post_only_likes.jpg",
  "lessons/photography/fabric_window.jpg",
];

function createDone(kind) {
  const index = CREATE_KINDS.indexOf(kind);
  return CREATE_KINDS.slice(0, index + 1).every((id) => isPartDone("create_post", id));
}

function nextCreateKind() {
  return CREATE_KINDS.find((id) => !isPartDone("create_post", id)) || null;
}

function createAllDone() {
  return CREATE_KINDS.every((id) => isPartDone("create_post", id));
}

const TASKS = [
  {
    id: "photography",
    number: "01",
    title: "Photography",
    detail: "Continue · Hold steady",
    image: photo("try_it_art.jpg"),
    label: "TASK 1 OF 5",
    parts: [
      lesson(
        { id: "1", title: "Hold steady", label: "PART 1 · HOLD STEADY" },
        {
          lessonTitle: "Hold with two hands",
          image: photo("hold_steady_art.jpg"),
          wrong: { image: photo("fabric_shaky.jpg"), label: "Shaky" },
          right: { image: photo("fabric_steady.jpg"), label: "Steady" },
          rightReason: "Sharp photos sell better",
          wrongReason: "Shaky photos look blurry",
        },
      ),
      lesson(
        { id: "2", title: "Plain sheet", label: "PART 2 · PLAIN SHEET" },
        {
          lessonTitle: "Put a plain sheet behind",
          image: photo("plain_sheet_art.jpg"),
          wrong: { image: photo("fabric_messy.jpg"), label: "Messy" },
          right: { image: photo("fabric_steady.jpg"), label: "Plain" },
          rightReason: "The cloth stands out",
          wrongReason: "A messy background hides the cloth",
        },
      ),
      lesson(
        { id: "3", title: "Window light", label: "PART 3 · WINDOW LIGHT" },
        {
          lessonTitle: "Stand near a window",
          image: photo("window_light_art.jpg"),
          wrong: { image: photo("fabric_dark.jpg"), label: "Dark corner" },
          right: { image: photo("fabric_window.jpg"), label: "Near window" },
          rightReason: "True colours by the window",
          wrongReason: "A dark corner makes colours dull",
        },
      ),
      lesson(
        { id: "4", title: "Straight angle", label: "PART 4 · STRAIGHT ANGLE" },
        {
          lessonTitle: "Hold the phone straight",
          image: photo("straight_angle_art.jpg"),
          wrong: { image: photo("fabric_tilted.jpg"), label: "Tilted" },
          right: { image: photo("fabric_straight.jpg"), label: "Straight" },
          rightReason: "Shows the full cloth",
          wrongReason: "A tilted photo cuts off the cloth",
        },
      ),
      lesson(
        { id: "5", title: "Light for cotton", label: "PART 5 · LIGHT FOR COTTON" },
        {
          lessonTitle: "Cotton: light from the side",
          line: "Cotton and eri soak up light. Side light shows the weave.",
          image: photo("cotton_light_art.jpg"),
          wrong: { image: photo("cotton_flat_light.jpg"), label: "Light from the front" },
          right: { image: photo("cotton_side_light.jpg"), label: "Light from the side" },
          rightReason: "Side light shows the weave",
          wrongReason: "Front light hides the weave",
        },
      ),
      lesson(
        { id: "6", title: "Light for silk", label: "PART 6 · LIGHT FOR SILK" },
        {
          lessonTitle: "Silk: soft light, no sun",
          line: "Mulberry and muga throw light back. Soft light lets them glow.",
          image: photo("silk_light_art.jpg"),
          wrong: { image: photo("silk_glare.jpg"), label: "Direct sun" },
          right: { image: photo("silk_soft_light.jpg"), label: "Soft light" },
          rightReason: "Soft light makes silk glow",
          wrongReason: "Sun makes white glare spots",
        },
      ),
      lesson(
        { id: "7", title: "Shade the silk", label: "PART 7 · SHADE THE SILK" },
        {
          lessonTitle: "Hang a white sheet",
          line: "A white sheet on the window keeps the sun off the silk.",
          image: photo("silk_light_art.jpg"),
          wrong: { image: photo("silk_glare.jpg"), label: "Bare sun" },
          right: { image: photo("silk_soft_light.jpg"), label: "White sheet" },
          rightReason: "Soft light lets the silk glow",
          wrongReason: "Bare sun makes white spots",
        },
      ),
      lesson(
        { id: "8", title: "Turn the silk", label: "PART 8 · TURN THE SILK" },
        {
          lessonTitle: "Turn away from the glare",
          line: "Turn the cloth until the shine stays on the silk, not in the camera.",
          image: photo("silk_light_art.jpg"),
          wrong: { image: photo("silk_glare.jpg"), label: "Glare on the motif" },
          right: { image: photo("silk_soft_light.jpg"), label: "Shine on the cloth" },
          rightReason: "The motif stays clear",
          wrongReason: "A white spot hides the motif",
        },
      ),
    ],
  },
  {
    id: "set_up_page",
    number: "02",
    title: "Set up your page",
    detail: "On Instagram",
    image: setup("good_name_art.jpg"),
    label: "TASK 2 OF 5",
    showChevron: true,
    parts: [
      lesson(
        { id: "1", title: "Good name", label: "TASK 2 · PART 1 · GOOD NAME" },
        {
          lessonTitle: "Short name with your craft",
          image: setup("good_name_art.jpg"),
          wrong: { text: "@divya_w_\n1987_xyz", label: "Long" },
          right: { text: "@divya\n.weaves", label: "Short" },
          rightReason: "Easy to say and find",
          wrongReason: "Long names are hard to remember",
        },
      ),
      lesson(
        { id: "2", title: "Clear photo", label: "TASK 2 · PART 2 · CLEAR PHOTO" },
        {
          lessonTitle: "Use your face or your loom",
          image: setup("clear_photo_art.jpg"),
          wrong: { image: setup("profile_blurry.jpg"), caption: "divya.weaves", label: "Blurry" },
          right: { image: setup("profile_clear.jpg"), caption: "divya.weaves", label: "Clear" },
          rightReason: "Buyers trust a clear face",
          wrongReason: "A blurry photo hides who you are",
        },
      ),
      lesson(
        { id: "3", title: "Professional", label: "TASK 2 · PART 3 · PROFESSIONAL" },
        {
          lessonTitle: "Use a professional page",
          line: "A professional page shows Professional dashboard. Tap it to learn more.",
          image: setup("clear_photo_art.jpg"),
          wrong: { profile: "personal", label: "Personal" },
          right: { profile: "business", label: "Professional" },
          rightReason: "Buyers can message you",
          wrongReason: "Personal pages miss business tools",
          then: "tryit",
        },
      ),
      lesson({ id: "4", title: "Try it", label: "TRY IT", hidden: true }, { kind: "tryit" }),
    ],
  },
  {
    id: "create_post",
    number: "03",
    title: "Create a post",
    detail: "Post and story",
    image: postArt("create_post_art.jpg"),
    label: "TASK 3 OF 5",
    gate: "photos",
    parts: [
      {
        id: "post",
        title: "Post",
        kind: "guide",
        image: postArt("ig_tap_plus_art.jpg"),
        header: "Post in Instagram",
        instructionTitle: "Make a feed post",
        instructionBody: "A post stays on your page. Use a clear photo of your cloth.",
        steps: ["Tap +", "Pick your photo", "Paste your words", "Tap Share"],
      },
      {
        id: "story",
        title: "Story",
        kind: "guide",
        image: postArt("ig_choose_story_art.jpg"),
        header: "Share a story",
        instructionTitle: "Make a story",
        instructionBody: "Stories disappear after one day. Show your weave up close.",
        steps: ["Tap +", "Tap Story", "Pick your photo", "Tap Your story"],
      },
      {
        id: "reel",
        title: "Reel",
        kind: "guide",
        image: postArt("ig_choose_reel_art.jpg"),
        header: "Make a reel",
        instructionTitle: "Make a reel",
        instructionBody: "Reels are short videos. Show your hands at the loom.",
        steps: ["Tap +", "Tap Reel", "Pick your clip", "Tap Share"],
      },
    ],
  },
  {
    id: "posting_plan",
    number: "04",
    title: "Posting plan",
    detail: "What and when",
    image: plan("post_often_art.jpg"),
    label: "TASK 4 OF 5",
    showChevron: true,
    parts: [
      lesson(
        { id: "1", title: "Post often", label: "TASK 4 · PART 1 · POST OFTEN" },
        {
          lessonTitle: "Post 3 times a week",
          image: plan("post_often_art.jpg"),
          wrong: { image: plan("calendar_rarely.jpg"), caption: "1 a month", contain: true, label: "Rarely" },
          right: { image: plan("calendar_often.jpg"), caption: "3 a week", contain: true, label: "Often" },
          rightReason: "People remember you",
          wrongReason: "People forget pages that post rarely",
        },
      ),
      lesson(
        { id: "2", title: "Good time", label: "TASK 4 · PART 2 · GOOD TIME" },
        {
          lessonTitle: "Post in the evening",
          image: plan("good_time_art.jpg"),
          wrong: {
            tile: {
              title: "2 am",
              subtitle: "All asleep",
              bg: "#16231F",
              fg: "#fff",
              sub: "#AAB5B2",
              icon: "moon",
              iconColor: "#C9D2CF",
            },
            label: "2 am",
          },
          right: {
            tile: {
              title: "7 pm",
              subtitle: "Buyers online",
              bg: "#FBF1E3",
              fg: "#152322",
              sub: "#4F5F5D",
              icon: "sun",
              iconColor: "#B07A1F",
            },
            label: "7 pm",
          },
          rightReason: "More people see it",
          wrongReason: "At 2 am most people are asleep",
        },
      ),
      lesson(
        { id: "3", title: "Mix posts", label: "TASK 4 · PART 3 · MIX POSTS" },
        {
          lessonTitle: "Cloth, work, then price",
          image: plan("mix_posts_art.jpg"),
          wrong: { image: plan("posts_same.jpg"), contain: true, label: "Same photo" },
          right: { image: plan("posts_mixed.jpg"), contain: true, label: "Mixed" },
          rightReason: "Every post shows something new",
          wrongReason: "The same photo again gets boring",
        },
      ),
    ],
  },
  {
    id: "read_numbers",
    number: "05",
    title: "Read the numbers",
    detail: "Views, likes, saves",
    image: numbers("read_numbers_art.jpg"),
    label: "TASK 5 OF 5",
    showChevron: true,
    parts: [
      lesson(
        { id: "1", title: "Saves matter", label: "TASK 5 · PART 1 · SAVES MATTER" },
        {
          lessonTitle: "Saves mean buyers",
          image: numbers("saves_matter_art.jpg"),
          wrong: {
            image: numbers("post_only_likes.jpg"),
            stats: [
              { icon: "heart", text: "120 likes" },
              { icon: "save", text: "0 saves" },
            ],
            label: "Only likes",
          },
          right: {
            image: numbers("post_many_saves.jpg"),
            stats: [
              { icon: "heart", text: "60 likes" },
              { icon: "save", text: "18 saves" },
            ],
            label: "Many saves",
          },
          rightReason: "Saves show they want to buy",
          wrongReason: "Likes alone do not bring buyers",
        },
      ),
      lesson(
        { id: "2", title: "Reply fast", label: "TASK 5 · PART 2 · REPLY FAST" },
        {
          lessonTitle: "Reply the same day",
          image: numbers("reply_fast_art.jpg"),
          wrong: {
            chat: {
              image: numbers("reply_cloth_post.jpg"),
              question: "Price please?",
              time: "After 3 days",
              reply: "₹4,500",
            },
            label: "Late",
          },
          right: {
            chat: {
              image: numbers("reply_cloth_post.jpg"),
              question: "Price please?",
              time: "In 1 hour",
              reply: "₹4,500",
            },
            label: "Fast",
          },
          rightReason: "Fast replies make sales",
          wrongReason: "Buyers leave when you reply late",
        },
      ),
      lesson(
        { id: "3", title: "What they mean", label: "TASK 5 · PART 3" },
        { kind: "numbers" },
      ),
    ],
  },
];

function taskById(id) {
  return TASKS.find((task) => task.id === id);
}

function partById(task, id) {
  return task.parts.find((part) => part.id === id);
}

function nextTask(task) {
  const index = TASKS.findIndex((item) => item.id === task.id);
  return TASKS[index + 1] || null;
}

function taskStatus(task) {
  if (isTaskDone(task)) return t("Done");
  const next = task.parts.find((part) => !part.hidden && !isPartDone(task.id, part.id));
  if (next && next !== task.parts.find((part) => !part.hidden)) return t(next.title);
  return t(task.detail);
}

function activeTaskId() {
  const open = TASKS.find((task) => !isTaskDone(task));
  return (open || TASKS[0]).id;
}

function isPhotoChoice(option) {
  return Boolean(option.image) && !option.text && !option.tile && !option.chat && !option.profile && !option.stats && !option.caption;
}

function igStats(compact) {
  const rows = [
    ["12", "posts"],
    ["86", "followers"],
    ["4", "following"],
  ];
  return `<div class="ig-stats ${compact ? "compact" : ""}">${rows
    .map(([value, label]) => `<span><b>${value}</b><small>${esc(t(label))}</small></span>`)
    .join("")}</div>`;
}

function igPreview(business, compact, options) {
  const highlight = !options || options.highlight !== false;
  const tappable = !compact && (!options || options.tappable !== false);
  const actions = business
    ? ["Edit profile", "Share profile", "Contact"]
    : ["Edit profile", "Share profile"];
  const quizActions = business ? ["Edit", "Share", "Contact"] : ["Edit", "Share"];
  const labels = compact ? quizActions : actions;
  const posts = compact
    ? ""
    : `<div class="ig-posts">
        <img src="${img(numbers("post_many_saves.jpg"))}" alt="">
        <img src="${img(numbers("reply_cloth_post.jpg"))}" alt="">
        <img src="${img(photo("fabric_straight.jpg"))}" alt="">
      </div>`;
  const dashboard = business
    ? `<div class="ig-dash ${highlight ? "hot" : ""}" ${tappable ? 'data-act="open-check"' : ""}>
        <b>${esc(t("Professional dashboard"))}</b>
        <small>${esc(t(compact ? "Tools for businesses." : "Tools and resources just for businesses."))}</small>
      </div>`
    : "";
  return `<div class="ig ${compact ? "quiz" : "page"}">
    <div class="ig-top">
      <img src="${img(setup("profile_clear.jpg"))}" alt="">
      <div>
        <strong>divya.weaves</strong>
        ${compact ? "" : igStats(false)}
      </div>
    </div>
    ${compact ? igStats(true) : ""}
    <p>${esc(t("Divya Warule"))}<br>${esc(t("Handwoven cloth · Sualkuchi, Assam"))}</p>
    ${dashboard}
    <div class="ig-actions">${labels.map((label) => `<i>${esc(t(label))}</i>`).join("")}</div>
    ${posts}
  </div>`;
}

function choiceCard(option, letter, revealed, picked) {
  const classes = ["choice", "photo"];
  if (revealed) classes.push("revealed");
  if (picked) classes.push("picked");
  if (revealed && letter === "B") classes.push("right");
  if (revealed && picked && letter === "A") classes.push("wrong");
  const badge = revealed && letter === "B"
    ? svg.check
    : revealed && picked && letter === "A"
      ? '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M7 7l10 10M17 7L7 17" stroke="#fff" stroke-width="2.6" stroke-linecap="round"/></svg>'
      : esc(letter);
  let body = "";
  if (option.profile) {
    body = igPreview(option.profile === "business", true);
  } else if (option.text) {
    body = `<span class="shot text">${esc(t(option.text))}</span>`;
  } else if (option.image && option.caption && !option.contain) {
    body = `<span class="shot face"><img src="${img(option.image)}" alt=""><small>${esc(t(option.caption))}</small></span>`;
  } else if (option.image && option.caption) {
    body = `<span class="shot captioned"><img src="${img(option.image)}" alt=""><small>${esc(t(option.caption))}</small></span>`;
  } else if (option.tile) {
    const tile = option.tile;
    const icon = tile.icon === "sun"
      ? `<svg width="44" height="44" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 17h16M6.5 20h11" stroke="${tile.iconColor}" stroke-width="1.6" stroke-linecap="round"/><path d="M12 4.2v1.8M6.2 7.4l1.3 1.3M17.8 7.4l-1.3 1.3" stroke="${tile.iconColor}" stroke-width="1.6" stroke-linecap="round"/><path d="M7.2 17a4.8 4.8 0 0 1 9.6 0" stroke="${tile.iconColor}" stroke-width="1.6"/></svg>`
      : `<svg width="44" height="44" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M14.6 3.4A7.6 7.6 0 1 0 20.6 14 6.2 6.2 0 0 1 14.6 3.4z" stroke="${tile.iconColor}" stroke-width="1.6" stroke-linejoin="round"/></svg>`;
    body = `<span class="shot tile" style="background:${tile.bg}"><span class="ico">${icon}</span><b style="color:${tile.fg}">${esc(t(tile.title))}</b><span class="sub" style="color:${tile.sub}">${esc(t(tile.subtitle))}</span></span>`;
  } else if (option.image && option.stats) {
    const lines = option.stats
      .map((stat, index) => {
        const last = index === option.stats.length - 1;
        const icon = stat.icon === "save"
          ? '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M7 4.5h10a1 1 0 0 1 1 1V20l-6-3.2L6 20V5.5a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>'
          : '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 19s-6.2-3.7-8.2-7.2C2.4 9.6 3.4 6.8 6.2 6.2 7.8 5.8 9.3 6.4 12 8.4c2.7-2 4.2-2.6 5.8-2.2 2.8.6 3.8 3.4 2.4 5.6C18.2 15.3 12 19 12 19z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>';
        return `<span class="stat-line ${last ? "save" : ""}">${icon}${esc(t(stat.text))}</span>`;
      })
      .join("");
    body = `<span class="shot post"><img src="${img(option.image)}" alt="">${lines}</span>`;
  } else if (option.chat) {
    const chat = option.chat;
    const photo = chat.image ? `<img src="${img(chat.image)}" alt="">` : "";
    body = `<span class="shot chat-shot"><span class="chat-col">
      <span class="ask">${photo}<span>${esc(t(chat.question))}</span></span>
      <span class="when"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="7.2" stroke="currentColor" stroke-width="1.7"/><path d="M12 8.5V12l2.4 1.6" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>${esc(t(chat.time))}</span>
      <span class="reply">${esc(chat.reply)}</span>
    </span></span>`;
  } else if (option.image) {
    body = `<span class="shot ${option.contain ? "fit" : ""}"><img class="${option.contain ? "contain" : ""}" src="${img(option.image)}" alt=""></span>`;
  }
  const labelIcon = letter === "B"
    ? svg.check.replace("#fff", "#1e7b45")
    : '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="8" stroke="#4f5f5d" stroke-width="1.8"/><path d="M9 9l6 6M15 9l-6 6" stroke="#4f5f5d" stroke-width="1.8" stroke-linecap="round"/></svg>';
  return `<button class="${classes.join(" ")}" data-act="pick" data-letter="${letter}">
    <span class="letter">${badge}</span>
    ${body}
    <span class="cap">${labelIcon}${esc(t(option.label))}</span>
  </button>`;
}

function header() {
  return `<div class="between">
    <div class="brand">${esc(t("Click & Social"))}</div>
    <button class="lang-pill" data-act="language">${svg.translate}<span>${esc(nativeName())}</span>${svg.down}</button>
  </div>`;
}

function renderSplash() {
  return screen(
    `<div class="splash"><h1>${esc(t("Click & Social"))}</h1></div>`,
    "teal",
  );
}

function renderLogin() {
  return screen(`<div class="login-wrap">
    <div class="login-title"><h1>${esc(t("Click & Social"))}</h1><i></i></div>
    <div>
      <h1 class="display">${esc(t("Log in"))}</h1>
      <p class="lede">${esc(t("Use your email and password to open your lessons."))}</p>
    </div>
    <div class="card">
      <div class="field">
        <label>${esc(t("Email"))}</label>
        <div class="box">${svg.mail}<input id="email" type="email" autocomplete="username" placeholder="${esc(t("you@example.com"))}" value="${esc(state.email)}"></div>
      </div>
      <div class="field">
        <label>${esc(t("Password"))}</label>
        <div class="box">${svg.lock}<input id="password" type="${state.hidePassword ? "password" : "text"}" autocomplete="current-password" placeholder="${esc(t("Your password"))}" value="${esc(state.password)}">
          <button class="eye" data-act="toggle-pass" aria-label="${esc(t(state.hidePassword ? "Show password" : "Hide password"))}">${state.hidePassword ? svg.eye : svg.eyeOff}</button>
        </div>
      </div>
      <button class="link" data-act="forgot">${esc(t("Forgot password?"))}</button>
    </div>
    ${btn("Log in", "login")}
  </div>`);
}

function renderForgot() {
  return screen(`<div class="pad-20 stack">
    ${backBtn()}
    <h1 class="display" style="margin-top:12px">${esc(t("Forgot password?"))}</h1>
    <p class="lede">${esc(t("Enter your email. We will send you a link to choose a new password."))}</p>
    <div class="card" style="margin-top:16px">
      <div class="field">
        <label>${esc(t("Email"))}</label>
        <div class="box">${svg.mail}<input id="reset-email" type="email" value="${esc(state.resetEmail)}" placeholder="${esc(t("you@example.com"))}"></div>
      </div>
    </div>
    ${state.resetSent ? `<p class="note" style="margin-top:16px">${esc(t("If this email is registered, we will send a reset link."))}</p>` : ""}
    <div class="grow"></div>
    ${btn("Send reset link", "send-reset")}
    <button class="btn ghost" data-act="back">${esc(t("Back to log in"))}</button>
  </div>`);
}

function renderLanguage(view) {
  const cards = LANGS.map((language) => {
    const on = code() === language.id;
    return `<div class="lang-card ${on ? "on" : ""}" role="button" tabindex="0" data-act="choose-lang" data-locale="${language.locale}">
      <span class="lang-copy">
        <strong>${esc(language.native)}</strong>
        ${language.single ? "" : `<em>${esc(t(language.english))}</em>`}
      </span>
      ${on ? `<span class="check">${svg.check}</span>` : ""}
      <button type="button" class="speak" data-act="speak-native" data-locale="${language.locale}" data-say="${esc(language.native)}" aria-label="Listen"><img src="${img("icons/speaker.png")}" alt=""></button>
    </div>`;
  }).join("");
  return screen(`<div class="pad stack">
    ${backBtn()}
    <h1 class="display" style="margin-top:12px">${esc(t("Choose your language"))}</h1>
    <p class="lede">${esc(t("Tap your language."))}</p>
    <div class="scroll"><div class="langs">${cards}</div></div>
    <div class="foot">${btn("Continue", view.changing ? "confirm-lang" : "start-welcome")}</div>
  </div>`);
}

function renderWelcome(view) {
  const share = view.page === "share";
  return screen(`<div class="pad stack">
    ${backBtn()}
    <div class="welcome-fit">
      <img class="hero-art" src="${img(share ? "onboarding/share_art.png" : "onboarding/shoot_art.png")}" alt="">
      <div class="dots">${share ? "<i></i><b></b>" : "<b></b><i></i>"}</div>
      <h1 class="display" style="margin-top:14px">${esc(t(share ? "Share and sell" : "Take beautiful photos"))}</h1>
      <p class="lede">${esc(t(share ? "Send your photos to Instagram and\nWhatsApp in a few taps." : "The camera helps you keep the photo\nstraight and bright."))}</p>
    </div>
    <div class="foot">${share ? btn("Get started", "enter-app") : btn("Next", "welcome-share")}</div>
  </div>`);
}

function renderLearn() {
  const done = completedCount();
  const pct = Math.round((done / TASKS.length) * 100);
  const active = activeTaskId();
  const cards = TASKS.map((task) => {
    const on = task.id === active && !isTaskDone(task);
    return `<button class="task ${on ? "active" : ""}" data-act="open-task" data-id="${task.id}">
      <span class="art"><img src="${img(task.image)}" alt="">${on ? `<span class="play">${svg.play}</span>` : ""}</span>
      <span class="task-meta"><span class="num">${task.number}</span><span><h2>${esc(t(task.title))}</h2></span></span>
      <p>${esc(taskStatus(task))}</p>
    </button>`;
  }).join("");
  return screen(`<div class="stack">
    <div class="scroll pad">
      ${header()}
      <h1 class="hello">${esc(t("Hello, Divya Warule"))}</h1>
      <div class="progress-row"><span>${esc(t(done + " OF " + TASKS.length + " TASKS DONE"))}</span><b>${pct}%</b></div>
      <div class="bar"><i style="width:${pct}%"></i></div>
      <div class="grid-2">${cards}</div>
    </div>
    ${nav("learn")}
  </div>`);
}

function renderMe() {
  const tiles = TASKS.map((task) => {
    const on = isTaskDone(task);
    return `<div class="badge ${on ? "on" : ""}"><div class="medal">${on ? svg.medal : svg.lockBadge}</div><p>${esc(t(task.title))}</p></div>`;
  }).join("");
  return screen(`<div class="stack">
    <div class="scroll pad-20">
      <h1 class="hello" style="margin-top:8px">${esc(t("Me"))}</h1>
      <p class="lede">${esc(t("Finish Learn tasks to unlock your badges."))}</p>
      <p class="kicker" style="margin-top:22px">${esc(t("YOUR BADGES"))}</p>
      <div class="badges">${tiles}</div>
    </div>
    ${nav("me")}
  </div>`);
}

function displaysFor(name) {
  if (name === "Saree" || name === "Mekhala sador") {
    return ["full", "close", "draped", "border", "folded", "hanging"];
  }
  if (name === "Jod kappur") return ["folded", "hanging"];
  if (name === "Cushion covers") return ["sofa", "flat"];
  if (name === "Yardages") return ["hanging", "close"];
  return ["full", "folded"];
}

function openIg(kind) {
  state.createStep = 0;
  state.createPhoto = null;
  push("ig-post", { kind });
}

function finishCreateKind(kind) {
  markPart("create_post", kind);
  state.createStep = 0;
  state.createPhoto = null;
  const keep = [];
  for (const view of state.stack) {
    if (view.name === "ig-post" || view.name === "pick-media" || view.name === "did-post") break;
    keep.push(view);
  }
  state.stack = keep.length ? keep : [{ name: "main" }];
  if (createAllDone()) {
    showBadge("create_post");
    return;
  }
  openIg(nextCreateKind());
}

function openShot(productName, id) {
  const product = PRODUCTS.find((item) => item[0] === productName);
  const [name, key] = DISPLAYS[id];
  push("shot", {
    product: productName,
    display: name,
    file: displayImage(productName, product[1], key),
  });
}

function displayImage(productName, material, key) {
  const slug = productName.toLowerCase().replace(/ /g, "_");
  const file = OWN_PHOTOS.has(productName)
    ? `${slug}_${material.toLowerCase()}_${key}.jpg`
    : `${material.toLowerCase()}_${key}.jpg`;
  return "lessons/displays/" + file;
}

function pickTick() {
  return `<span class="tick"><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="10" fill="#1B7574"/><path d="M7.2 12.3l3.1 3.1 6.5-6.8" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg></span>`;
}

function pickCard(options) {
  const source = img(options.file);
  const photo = options.whole
    ? `<img class="blur" src="${source}" alt=""><img class="sharp" src="${source}" alt="">`
    : `<img src="${source}" alt="">`;
  return `<button type="button" class="pick-card ${options.tall ? "tall" : ""} ${options.whole ? "whole" : ""} ${options.on ? "on" : ""}" data-act="${options.act}" ${options.attrs || ""}>
    <span class="pic">${photo}${options.on ? pickTick() : ""}</span>
    <b>${esc(t(options.label))}</b>
  </button>`;
}

function readyBtn(label, act, ready) {
  return `<button class="btn ${ready ? "" : "wait shadowed"}" type="button" data-act="${act}" ${ready ? "" : "disabled"}>${esc(t(label))}</button>`;
}

function renderProducts() {
  const cards = PRODUCTS.map(([name, , file]) =>
    pickCard({
      file,
      label: name,
      on: state.product === name,
      act: "pick-product",
      attrs: `data-name="${esc(name)}"`,
    }),
  ).join("");
  const spoken = t("What are you photographing?") + " " + PRODUCTS.map((item) => t(item[0])).join(". ") + ".";
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <span></span>
      ${speakBtn(spoken)}
    </div>
    <h1 class="pick-title">${esc(t("What are you photographing?"))}</h1>
    <p class="pick-sub">${esc(t("Tap one"))}</p>
    <div class="pick-grid" data-scroll>${cards}</div>
    <div class="foot">${readyBtn("Continue", "products-continue", !!state.product)}</div>
  </div>`);
}

function renderPhoto() {
  return renderProducts();
}

function renderMain() {
  if (state.tab === "me") return renderMe();
  if (state.tab === "photo") return renderPhoto();
  return renderLearn();
}

function listedParts(task) {
  return task.parts.filter((part) => !part.hidden);
}

function doneListedCount(task) {
  let count = 0;
  for (const part of listedParts(task)) {
    if (!isPartDone(task.id, part.id)) break;
    count += 1;
  }
  return count;
}

function renderTask(view) {
  const task = taskById(view.id);
  if (task.id === "create_post") return renderPhotoAccess();
  const listed = listedParts(task);
  const doneCount = doneListedCount(task);
  const check = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5.2 12.4l4.2 4.2L18.8 7.4" stroke="#1E7B45" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  const play = '<svg width="26" height="26" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M9 7.2v9.6L17.2 12 9 7.2z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg>';
  const rows = listed
    .map((part, index) => {
      const status = index < doneCount ? "done" : index === doneCount ? "current" : "pending";
      const openable = task.id === "set_up_page" || status !== "pending";
      const chevron = task.showChevron && openable && status === "pending";
      const need = listed[doneCount] ? listed[doneCount].title : part.title;
      const side = status === "done"
        ? `<span class="done-label">${esc(t("Done"))}</span>`
        : status === "current"
          ? `<span class="play-circle">${play}</span>`
          : chevron
            ? `<span class="chev">${svg.chev}</span>`
            : "";
      return `<button class="part ${status}" data-act="open-part" data-task="${task.id}" data-part="${part.id}" data-locked="${openable ? "0" : "1"}" data-need="${esc(need)}">
        <span class="n">${status === "done" ? check : esc(part.id)}</span>
        <h3>${esc(t(part.title))}</h3>
        ${side}
      </button>`;
    })
    .join("");
  const bars = listed
    .map((_, index) => `<i class="${index < doneCount ? "on" : ""}"></i>`)
    .join("");
  return screen(`<div class="stack">
    <div class="scroll pad-20">
      <div class="lesson-head">
        ${backBtn()}
        <p class="lesson-kicker">${esc(t(task.label))}</p>
        <span></span>
      </div>
      <h1 class="task-title">${esc(t(task.title))}</h1>
      <div class="task-bars">${bars}</div>
      ${rows}
    </div>
    ${nav("learn")}
  </div>`);
}

function renderPhotoAccess() {
  const choice = (label, selected) => `<div class="perm-choice ${selected ? "on" : ""}"><span>${esc(t(label))}</span>${selected ? `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5.5 12.2l4.2 4.2L18.5 7.6" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/></svg>` : ""}</div>`;
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t("TASK 3 OF 5"))}</p>
      ${speakBtn("Allow photo access. The first time you tap plus to make a post, your phone asks for permission. Tap Allow all or Select photos.")}
    </div>
    <div class="scroll access-scroll">
      <div class="access-frame"><img src="${img(postArt("photo_access_art.jpg"))}" alt=""></div>
      <h1 class="access-title">${esc(t("Allow photo access"))}</h1>
      <p class="access-body">${esc(t("Your phone will ask the first time you post.\nTap Allow all or Select photos."))}</p>
      <article class="perm">
        <div class="perm-head"><span class="perm-ico"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><rect x="3.5" y="5" width="17" height="14" rx="2" stroke="currentColor" stroke-width="1.7"/><circle cx="9" cy="10" r="1.4" fill="currentColor"/><path d="M4.5 16.5l4.2-3.4 2.6 2.2 3.2-2.8 5 4" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg></span><b>${esc(t("Photos and videos"))}</b></div>
        ${choice("Don't allow", false)}
        ${choice("Select photos", false)}
        ${choice("Allow all", true)}
      </article>
    </div>
    <div class="foot">${`<button class="btn plain" type="button" data-act="access-continue">${esc(t("Continue"))}</button>`}</div>
  </div>`);
}

function typeIcon(kind) {
  if (kind === "story") {
    return '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12a8 8 0 1 0 2.2-5.5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/><path d="M4 4.5V8h3.5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  }
  if (kind === "reel") {
    return '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><rect x="3.5" y="6" width="17" height="12" rx="2" stroke="currentColor" stroke-width="1.7"/><path d="M10 9.5v5l4.5-2.5L10 9.5z" fill="currentColor"/></svg>';
  }
  return '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><rect x="4" y="4" width="6.5" height="6.5" rx="1.2" stroke="currentColor" stroke-width="1.7"/><rect x="13.5" y="4" width="6.5" height="6.5" rx="1.2" stroke="currentColor" stroke-width="1.7"/><rect x="4" y="13.5" width="6.5" height="6.5" rx="1.2" stroke="currentColor" stroke-width="1.7"/><rect x="13.5" y="13.5" width="6.5" height="6.5" rx="1.2" stroke="currentColor" stroke-width="1.7"/></svg>';
}

function igPlus(tappable) {
  const tag = tappable ? "button" : "span";
  const act = tappable ? ' type="button" data-act="ig-plus"' : "";
  return `<${tag} class="ig-plus"${act}><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 6.5v11M6.5 12h11" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg><i>1</i></${tag}>`;
}

function igPhone(kind, options) {
  const compact = options && options.compact;
  const step = state.createStep;
  const menuOpen = kind !== "post" && step >= 1;
  const rows = ["post", "story", "reel"]
    .map((id) => {
      const on = id === kind;
      const act = !compact && menuOpen && on ? ' data-act="ig-menu"' : "";
      return `<div class="ig-menu-row ${on ? "on" : ""}"${act}><span>${typeIcon(id)}</span><b>${esc(t(CREATE_GUIDE[id].title))}</b>${on ? "<i>1</i>" : ""}</div>`;
    })
    .join("");
  const body = kind === "post"
    ? `<div class="ig-user"><i></i><em></em></div><img class="ig-fabric" src="${img("lessons/read_numbers/post_many_saves.jpg")}" alt=""><div class="ig-tabs"><i></i><i></i><i></i><i></i><i></i></div>`
    : `<div class="ig-menu">${rows}</div>`;
  const heart = '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 18.6s-6.2-3.8-7.8-7.1C2.8 8.8 3.9 6.2 6.5 5.8c1.4-.2 2.7.4 3.5 1.6.8-1.2 2.1-1.8 3.5-1.6 2.6.4 3.7 3 2.3 5.7-1.6 3.3-7.8 7.1-7.8 7.1z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>';
  const chat = '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M7 16.2l-1.4 3 3.2-1.4A7.2 7.2 0 1 0 7 16.2z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>';
  const icons = kind === "post" ? `${heart}${chat}` : heart;
  const phone = `<div class="ig-phone">
    <div class="ig-topbar">${igPlus(!compact)}<em></em><span class="ig-icos">${icons}</span></div>
    <div class="ig-stories"><i class="add"></i><i></i><i></i><i></i></div>
    ${body}
  </div>`;
  return `<div class="ig-stage ${compact ? "compact" : ""}">${compact ? phone : `<div class="ig-cream">${phone}</div>`}</div>`;
}

function renderCreateTypes() {
  const next = nextCreateKind();
  const cards = CREATE_KINDS.map((id) => {
    const guide = CREATE_GUIDE[id];
    const done = createDone(id);
    const selected = id === next;
    const enabled = selected;
    return `<button type="button" class="type-card ${done ? "done" : ""} ${selected ? "on" : ""}" data-act="pick-kind" data-kind="${id}" ${enabled ? "" : "disabled"}>
      ${igPhone(id, { compact: true })}
      <span class="type-copy">${typeIcon(id)}<b>${esc(t(guide.title))}</b><small>${esc(t(guide.detail))}</small></span>
      ${done ? `<svg class="type-mark" width="26" height="26" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="10" fill="#1B7574"/><path d="M7.2 12.3l3.1 3.1 6.5-6.8" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round"/></svg>` : selected ? `<span class="radio on"></span>` : ""}
    </button>`;
  }).join("");
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t("TASK 3 OF 5"))}</p>
      ${speakBtn("What do you want to make? Choose Post, Story, or Reel. Then tap Continue.")}
    </div>
    <div class="scroll">
      <h1 class="access-title left">${esc(t("What do you want to make?"))}</h1>
      <p class="access-body left">${esc(t("Do Post first, then Story, then Reel. Tap Continue for each one."))}</p>
      <div class="type-list">${cards}</div>
    </div>
    <div class="foot">${readyBtn("Continue", "types-continue", !!next)}</div>
  </div>`);
}

function renderIgPost(view) {
  const guide = CREATE_GUIDE[view.kind];
  const steps = guide.steps
    .map((step, index) => {
      const current = index === state.createStep;
      return `<div class="ig-step ${current ? "on" : ""}" ${current ? 'data-act="ig-step" data-index="' + index + '"' : ""}><span>${index + 1}</span><b>${esc(t(step))}</b>${current && index === 0 ? speakBtn(guide.first) : ""}</div>`;
    })
    .join("");
  const doodle = state.createStep === 0 ? `<img class="doodle" src="${img(postArt("click_here_doodle.png"))}" alt="">` : "";
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t(guide.header))}</p>
      ${speakBtn(guide.spoken)}
    </div>
    <div class="scroll">
      ${igPhone(view.kind)}
      <h2 class="ig-lead">${esc(t(guide.instructionTitle))}</h2>
      <p class="ig-note">${esc(t(guide.instructionBody))}</p>
      <p class="scroll-cue"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 5v14M6 13l6 6 6-6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>${esc(t("Scroll down"))}</p>
      ${doodle}
      <div class="ig-steps">${steps}</div>
    </div>
  </div>`);
}

function renderPickMedia(view) {
  const guide = CREATE_GUIDE[view.kind];
  const picked = state.createPhoto;
  const preview = GALLERY[picked == null ? 0 : picked];
  const play = view.kind === "reel" ? `<span class="play-badge"><svg width="64" height="64" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="10" fill="#fff"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill="#152322"/></svg></span>` : "";
  const cells = GALLERY.map((file, index) => {
    const on = picked === index;
    const mini = view.kind === "reel" ? `<span class="mini-play"></span>` : "";
    return `<button type="button" class="gal-cell ${on ? "on" : ""}" data-act="pick-photo" data-index="${index}"><img src="${img(file)}" alt="">${mini}</button>`;
  }).join("");
  return screen(`<div class="gal">
    <div class="gal-head">
      <button class="icon-btn" type="button" data-act="back" aria-label="${esc(t("Back"))}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 6l12 12M18 6L6 18"/></svg></button>
      <b>${esc(t(guide.pickHeader))}</b>
      <button type="button" class="gal-next ${picked == null ? "wait" : ""}" data-act="pick-next" ${picked == null ? "disabled" : ""}>${esc(t("Next"))}</button>
    </div>
    <div class="gal-preview"><img src="${img(preview)}" alt="">${play}</div>
    <div class="gal-grid">${cells}</div>
    <article class="gal-card">
      <div class="gal-card-top">
        <span class="gem"></span>
        <span class="copy"><small>${esc(t(guide.pickStep))}</small><b>${esc(t(guide.pickTitle))}</b></span>
        ${speakBtn(guide.pickSpoken)}
      </div>
      <div class="gal-card-row">
        <span class="dots"><i class="on"></i><i class="on"></i><em></em><i></i><i></i></span>
        <button type="button" class="pill ${picked == null ? "wait" : ""}" data-act="pick-next" ${picked == null ? "disabled" : ""}>${esc(t("Next"))}${svg.chev}</button>
      </div>
    </article>
  </div>`, "white");
}

function renderDidPost(view) {
  const file = GALLERY[view.photo] || GALLERY[0];
  const play = view.kind === "reel" ? `<span class="play-badge small"><svg width="48" height="48" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="10" fill="#fff"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill="#152322"/></svg></span>` : "";
  return screen(`<div class="did">
    <article class="did-sheet">
      <div class="did-photo"><img src="${img(file)}" alt="">${play}</div>
      <h1>${esc(t("Did you post it?"))}</h1>
      <p>${esc(t("Look at your Instagram page"))}</p>
      <button class="btn" type="button" data-act="posted-yes"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5.5 12.2l4.2 4.2L18.5 7.6" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/></svg>${esc(t("Yes, I posted"))}</button>
      <button class="btn again" type="button" data-act="posted-again"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4.5 12a7.5 7.5 0 1 0 2-5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M4.5 4.5V8H8" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>${esc(t("Show me again"))}</button>
    </article>
  </div>`, "sheet");
}

function renderLesson(view) {
  const task = taskById(view.task);
  const part = partById(task, view.part);
  if (part.kind === "numbers") return renderNumbers(task, part);
  if (part.kind === "guide") return renderGuide(task, part);
  if (task.id === "set_up_page" && part.id === "3") return renderProfessional(part);
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t(part.label))}</p>
      ${speakBtn(part.line || part.lessonTitle)}
    </div>
    <div class="lesson-bars"><i></i><i class="off"></i></div>
    <div class="lesson-stage">
      <div class="lesson-frame"><img src="${img(part.image)}" alt=""></div>
      <h1 class="lesson-title">${esc(t(part.lessonTitle))}</h1>
      ${part.line ? `<p class="lesson-line">${esc(t(part.line))}</p>` : ""}
    </div>
    <div class="foot">${btn("Next", "open-check")}</div>
  </div>`);
}

function renderProfessional(part) {
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t(part.label))}</p>
      ${speakBtn("A professional page shows Professional dashboard. Tap it to learn more.")}
    </div>
    <h1 class="pro-title">${esc(t("Use a professional page"))}</h1>
    <p class="pro-sub">${esc(t("Tap Professional dashboard on your page."))}</p>
    <div class="pro-stage">${igPreview(true, false)}</div>
    <div class="foot">${btn("Next", "open-check")}</div>
  </div>`);
}

function renderGuide(task, part) {
  const steps = part.steps
    .map((step, index) => `<li><span>${index + 1}</span>${esc(t(step))}</li>`)
    .join("");
  return screen(`<div class="pad-20 stack">
    ${backBtn()}
    <div class="scroll">
      <p class="kicker">${esc(t(task.label))}</p>
      <img class="lesson-art" src="${img(part.image)}" alt="">
      <h1 class="display">${esc(t(part.header))}</h1>
      <p class="lede">${esc(t(part.instructionTitle))}</p>
      <p class="lede">${esc(t(part.instructionBody))}</p>
      <ol class="steps">${steps}</ol>
    </div>
    <div class="foot">${btn("Done", "finish-part")}</div>
  </div>`);
}

function numberIcon(kind) {
  if (kind === "heart") {
    return '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 18.5s-6-3.6-7.8-7C2.8 9.2 3.8 6.6 6.4 6.1c1.5-.3 2.9.2 5.6 2.2 2.7-2 4.1-2.5 5.6-2.2 2.6.5 3.6 3.1 2.2 5.4-1.8 3.4-7.8 7-7.8 7z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>';
  }
  if (kind === "save") {
    return '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M7 4.8h10a1 1 0 0 1 1 1V19.5l-6-3.1-6 3.1V5.8a1 1 0 0 1 1-1z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>';
  }
  if (kind === "chat") {
    return '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M6 16.5l-1.6 3.2L8.8 18A8 8 0 1 0 6 16.5z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>';
  }
  return '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="11" cy="11" r="5.2" stroke="currentColor" stroke-width="1.7"/><path d="M15.2 15.2L19 19" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>';
}

function renderNumbers() {
  const tiles = [
    ["search", "120", "Views", "People who saw it", false],
    ["heart", "24", "Likes", "People who liked it", false],
    ["save", "18", "Saves", "Want to buy later", true],
    ["chat", "5", "Messages", "Buyers asking", true],
  ]
    .map(
      ([icon, value, name, detail, best]) => `<article class="num-tile ${best ? "best" : ""}">
        <div class="top"><span class="ico">${numberIcon(icon)}</span>${best ? `<span class="best-tag">${esc(t("BEST"))}</span>` : ""}</div>
        <div class="fig"><strong>${value}</strong><b>${esc(t(name))}</b><small>${esc(t(detail))}</small></div>
      </article>`,
    )
    .join("");
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t("TASK 5 · 1 OF 2"))}</p>
      ${speakBtn(["What they mean. Four numbers to watch.", "Views are people who saw it. Likes are people who liked it.", "Saves mean they want to buy later. Messages are buyers asking."].map((line) => t(line)).join(" "))}
    </div>
    <p class="num-kicker">${esc(t("Read the numbers"))}</p>
    <div class="step-bars"><i class="on"></i><i></i></div>
    <h1 class="task-title num-title">${esc(t("What they mean"))}</h1>
    <p class="num-sub">${esc(t("4 numbers to watch"))}</p>
    <div class="numbers">${tiles}</div>
    <div class="foot">${`<button class="btn" data-act="open-find">${svg.chev}${esc(t("Next"))}</button>`}</div>
  </div>`);
}

function renderFind() {
  const steps = [
    ["1", "Open your page", false],
    ["2", "Tap Professional dashboard", true],
    ["3", "Tap a post · View insights", false],
  ]
    .map(
      ([number, text, current]) => `<div class="find-step ${current ? "on" : ""}"><span>${number}</span>${esc(t(text))}</div>`,
    )
    .join("");
  const earned = state.earned
    ? `<div class="earn">
        <article class="earn-card">
          <div class="earn-medal">${svg.medal}</div>
          <p>${esc(t("Badge earned"))}</p>
          <h2>${esc(t("Read the numbers"))}</h2>
          <small>${esc(t("You can read views, likes, saves and messages."))}</small>
          <button class="btn" data-act="leave-find">${esc(t("Continue"))}</button>
        </article>
      </div>`
    : "";
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t("TASK 5 · 2 OF 2"))}</p>
      ${speakBtn(["Find your numbers. Open your page.", "Tap Professional dashboard. Tap a post, then View insights."].map((line) => t(line)).join(" "))}
    </div>
    <p class="num-kicker find">${esc(t("Read the numbers"))}</p>
    <div class="step-bars"><i class="on"></i><i class="on"></i></div>
    <h1 class="find-title">${esc(t("Find your numbers"))}</h1>
    <div class="scroll find-scroll">
      ${igPreview(true, false, { highlight: false, tappable: false })}
      <div class="find-steps">${steps}</div>
    </div>
    <div class="foot find-foot">
      <a class="btn" href="https://www.instagram.com/" target="_blank" rel="noopener"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M14 5h5v5M19 5l-8 8" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M17 13.5V18a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1h4.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>${esc(t("Open Instagram"))}</a>
      <button class="btn plain" type="button" data-act="earn-find"><svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 2.8l1.7 1.2 2.1-.3.8 1.9 1.9.8-.3 2.1 1.2 1.7-1.2 1.7.3 2.1-1.9.8-.8 1.9-2.1-.3L12 21.2l-1.7-1.2-2.1.3-.8-1.9-1.9-.8.3-2.1L4.6 14l1.2-1.7-.3-2.1 1.9-.8.8-1.9 2.1.3L12 2.8zm-1.1 12.1l5-5-1.2-1.2-3.8 3.8-1.6-1.6-1.2 1.2 2.8 2.8z"/></svg>${esc(t("Complete"))}</button>
    </div>
    ${earned}
  </div>`);
}

function renderCheck(view) {
  const task = taskById(view.task);
  const part = partById(task, view.part);
  const revealed = state.choice != null;
  const correct = state.choice === "b";
  const spoken = !revealed
    ? "Which is better? Tap one."
    : correct
      ? `Yes! B is better. ${part.rightReason}.`
      : `Not quite. B is better. ${part.wrongReason}.`;
  const reason = !revealed
    ? ""
    : correct
      ? `${t("Yes! B is better")}. ${t(part.rightReason)}.`
      : `${t("Not quite. B is better")}. ${t(part.wrongReason)}.`;
  const profiles = part.wrong.profile && part.right.profile;
  const next = revealed
    ? btn("Next", "after-check")
    : `<button class="btn wait" type="button" disabled>${esc(t("Next"))}</button>`;
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t(part.label))}</p>
      ${speakBtn(spoken)}
    </div>
    <div class="lesson-bars"><i></i><i></i></div>
    <h1 class="check-title">${esc(t("Which is better?"))}</h1>
    <p class="lede" style="margin-top:4px">${esc(t("Tap one"))}</p>
    <div class="check-body">
      <div class="choices ${profiles ? "profiles" : "photos"}">
        ${choiceCard(part.wrong, "A", revealed, state.choice === "a")}
        ${choiceCard(part.right, "B", revealed, state.choice === "b")}
      </div>
      ${revealed ? `<p class="reason ${correct ? "good" : "bad"}">${esc(reason)}</p>` : `<div class="reason-slot"></div>`}
    </div>
    <div class="foot">${next}</div>
  </div>`);
}

function sellIcon(kind, color) {
  if (kind === "brush") {
    return `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M14 5l5 5-9.5 9.5a2.2 2.2 0 0 1-3.1 0l-1.9-1.9a2.2 2.2 0 0 1 0-3.1L14 5z" stroke="${color}" stroke-width="1.7" stroke-linejoin="round"/><path d="M13 6l5 5" stroke="${color}" stroke-width="1.7"/></svg>`;
  }
  if (kind === "store") {
    return `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 10l1.2-4h13.6L20 10M4 10h16v9H4v-9z" stroke="${color}" stroke-width="1.7" stroke-linejoin="round"/><path d="M9 19v-5h6v5" stroke="${color}" stroke-width="1.7"/></svg>`;
  }
  if (kind === "people") {
    return `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="9" cy="9" r="2.4" stroke="${color}" stroke-width="1.7"/><circle cx="16" cy="10" r="2" stroke="${color}" stroke-width="1.7"/><path d="M4.8 18c.6-2.2 2.2-3.4 4.2-3.4s3.6 1.2 4.2 3.4M13.2 14.8c1.6 0 3 .9 3.6 2.7" stroke="${color}" stroke-width="1.7" stroke-linecap="round"/></svg>`;
  }
  return `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12.5l7.2 7.2a1.6 1.6 0 0 0 2.2 0L20 13.1V6.4h-6.7L4 12.5z" stroke="${color}" stroke-width="1.7" stroke-linejoin="round"/><circle cx="16.2" cy="9.2" r="1" fill="${color}"/></svg>`;
}

function renderTry() {
  const step = state.tryStep;
  const categories = [
    { name: "Clothing (Brand)", detail: "Mekhela, saree, stole", icon: "tag", best: true },
    { name: "Artist", icon: "brush" },
    { name: "Shop", icon: "store" },
    { name: "Community", icon: "people" },
  ];
  let head = "";
  let body = "";
  if (step === 0) {
    head = `<h1 class="pro-title">${esc(t("Good name"))}</h1>
      <p class="lede">${esc(t("Short name with your craft"))}</p>`;
    body = `<div class="field"><label>${esc(t("Name"))}</label>
      <div class="box"><input id="try-name" value="${esc(state.tryName)}" placeholder="@divya.weaves"></div>
    </div>`;
  } else if (step === 1) {
    head = `<p class="try-lead">${esc(t("Set up your page"))}</p>
      <h1 class="try-title">${esc(t("What do you sell?"))}</h1>`;
    const cards = categories
      .map((item) => {
        const on = state.tryCategory === item.name;
        const color = on ? "#1B7574" : "#4F5F5D";
        return `<button class="sell ${on ? "on" : ""}" data-act="try-cat" data-name="${esc(item.name)}">
          ${sellIcon(item.icon, color)}
          <span class="sell-copy">
            <span class="sell-name">${esc(t(item.name))}${item.best ? `<i>${esc(t("Best"))}</i>` : ""}</span>
            ${item.detail ? `<small>${esc(t(item.detail))}</small>` : ""}
          </span>
          <span class="sell-mark">${on ? `<svg width="26" height="26" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.5 12.2l3 3 6-6.2" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>` : `<svg width="26" height="26" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="8.2" stroke="#B8C5C2" stroke-width="1.8"/></svg>`}</span>
        </button>`;
      })
      .join("");
    body = `<div class="try-tip"><svg width="22" height="22" viewBox="0 0 24 24" fill="#C5922E" aria-hidden="true"><path d="M12 3.2l2.1 4.7 5.1.6-3.8 3.5.9 5.1L12 14.8 7.7 17.1l.9-5.1L4.8 8.5l5.1-.6L12 3.2z"/></svg><span>${esc(t("Weavers: pick Clothing (Brand)"))}</span></div>
      <div class="sell-list">${cards}</div>
      <div class="show-row">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="8" r="3" stroke="#4F5F5D" stroke-width="1.7"/><path d="M6 19c.8-2.6 2.8-4 6-4s5.2 1.4 6 4" stroke="#4F5F5D" stroke-width="1.7" stroke-linecap="round"/></svg>
        <span>${esc(t("Show on my page"))}</span>
        <button class="switch ${state.tryShow ? "on" : ""}" type="button" data-act="try-show" aria-pressed="${state.tryShow ? "true" : "false"}"></button>
      </div>`;
  } else {
    const handle = (state.tryName || "divya.weaves").replace(/^@/, "");
    head = `<p class="try-lead">${esc(t("Set up your page"))}</p>
      <h1 class="try-title">${esc(t("Your Pro page"))}</h1>`;
    body = `<article class="pro-card">
      <div class="pro-top">
        <img src="${img(setup("profile_clear.jpg"))}" alt="">
        <div class="ig-stats pro-stats">
          <span><b>0</b><small>${esc(t("posts"))}</small></span>
          <span><b>12</b><small>${esc(t("followers"))}</small></span>
          <span><b>30</b><small>${esc(t("following"))}</small></span>
        </div>
      </div>
      <p class="pro-name">Divya Warule <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.6 12.2l2.8 2.8 6-6.2" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></p>
      <p class="pro-cat">${esc(t(state.tryCategory))}</p>
      <p class="pro-bio">${esc(t("Handwoven cloth · Sualkuchi, Assam"))}</p>
      <div class="pro-actions"><i>${esc(t("Edit page"))}</i><i>${esc(t("Share page"))}</i><i>${esc(t("Contact"))}</i></div>
    </article>
    <article class="done-card">
      <p>${esc(t("ALL DONE"))}</p>
      <div><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.6 12.2l2.8 2.8 6-6.2" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg><span>${esc(t("Name @" + handle))}</span></div>
      <div><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.6 12.2l2.8 2.8 6-6.2" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg><span>${esc(t(state.tryCategory))}</span></div>
      <div><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.6 12.2l2.8 2.8 6-6.2" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg><span>${esc(t("Contact button"))}</span></div>
    </article>`;
  }
  const bars = [0, 1, 2].map((index) => `<i class="${index <= step ? "on" : ""}"></i>`).join("");
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t("TASK 2 · " + (step + 1) + " OF 3"))}</p>
      <span></span>
    </div>
    <div class="task-bars">${bars}</div>
    ${head}
    <div class="scroll try-scroll">${body}</div>
    <div class="foot">${btn(step === 2 ? "Done" : "Next", "try-next")}</div>
  </div>`);
}

function renderDisplays(view) {
  const product = PRODUCTS.find((item) => item[0] === view.product);
  const whole = WHOLE_PHOTOS.has(view.product);
  const ids = displaysFor(view.product);
  const cards = ids
    .map((id) => {
      const [name, key] = DISPLAYS[id];
      return pickCard({
        file: displayImage(view.product, product[1], key),
        label: name,
        tall: true,
        whole,
        on: state.pickedDisplays.indexOf(id) >= 0,
        act: "toggle-display",
        attrs: `data-id="${id}"`,
      });
    })
    .join("");
  const spoken = t("How will you show it?") + " " + ids.map((id) => t(DISPLAYS[id][0])).join(". ") + ".";
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <span></span>
      ${speakBtn(spoken)}
    </div>
    <h1 class="pick-title">${esc(t("How will you show it?"))}</h1>
    <p class="pick-sub">${esc(t("Tap one or more"))}</p>
    <div class="pick-grid" data-scroll>${cards}</div>
    <div class="foot">${readyBtn("Continue", "displays-continue", state.pickedDisplays.length > 0)}</div>
  </div>`);
}

function shotRow(id, product, number) {
  const [name, key] = DISPLAYS[id];
  const file = displayImage(product[0], product[1], key);
  const done = state.shotDone.indexOf(id) >= 0;
  const chosen = state.shotChosen === id;
  const mark = done
    ? `<span class="shot-done">${esc(t("Done"))}<svg width="22" height="22" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="10" fill="#1B7574"/><path d="M7.2 12.3l3.1 3.1 6.5-6.8" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round"/></svg></span>`
    : `<span class="radio ${chosen ? "on" : ""}"></span>`;
  return `<button type="button" class="shot-row ${done || chosen ? "on" : ""}" data-act="choose-shot" data-id="${id}" ${done ? "disabled" : ""}>
    <img src="${img(file)}" alt="">
    <span class="copy"><small>${number}</small><b>${esc(t(name))}</b></span>
    ${mark}
  </button>`;
}

function renderShots(view) {
  const product = PRODUCTS.find((item) => item[0] === view.product);
  const remaining = state.shotQueue.filter((id) => state.shotDone.indexOf(id) < 0);
  const finished = state.shotQueue.filter((id) => state.shotDone.indexOf(id) >= 0);
  const group = (title, ids) => {
    if (!ids.length) return "";
    const label = finished.length ? `<p class="shot-label">${esc(t(title).toUpperCase())}</p>` : "";
    return label + ids.map((id) => shotRow(id, product, state.shotQueue.indexOf(id) + 1)).join("");
  };
  const allDone = remaining.length === 0;
  const ready = allDone || !!state.shotChosen;
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">${backBtn()}<span></span><span></span></div>
    <h1 class="pick-title">${esc(t("Your shots"))}</h1>
    <p class="pick-sub">${esc(t("Choose one, then tap Next"))}</p>
    <p class="shot-count">${esc(t(state.shotDone.length + " of " + state.shotQueue.length + " done"))}</p>
    <div class="scroll shot-list" data-scroll>${group("Remaining", remaining)}${group("Done", finished)}</div>
    <div class="foot">${readyBtn(allDone ? "Finish" : "Next", "shots-next", ready)}</div>
  </div>`);
}

function renderShot(view) {
  return screen(`<div class="pad-20 stack">
    ${backBtn()}
    <div class="scroll">
      <p class="kicker">${esc(t(view.display))}</p>
      <img class="lesson-art" src="${img(view.file)}" alt="">
      <h1 class="display">${esc(t("Fit the " + view.product + " inside the dotted line"))}</h1>
      <p class="lede">${esc(t("The camera helps you keep the photo\nstraight and bright."))}</p>
    </div>
    <div class="foot">${btn("Done", "shot-done")}</div>
  </div>`);
}

function confetti() {
  const colors = ["#1B7574", "#C5922E", "#7A1F2B", "#F4EBDD", "#1E7B45"];
  let bits = "";
  for (let i = 0; i < 28; i += 1) {
    const color = colors[i % colors.length];
    const left = Math.round(Math.random() * 100);
    const delay = (Math.random() * 0.8).toFixed(2);
    const duration = (2.4 + Math.random() * 1.6).toFixed(2);
    bits += `<i style="left:${left}%;background:${color};animation-duration:${duration}s;animation-delay:${delay}s"></i>`;
  }
  return `<div class="confetti">${bits}</div>`;
}

function renderBadge(view) {
  const task = taskById(view.task);
  const upcoming = nextTask(task);
  const lines = {
    photography: "Sharp photos sell better",
    set_up_page: "You practiced your name, bio, category, and pro page on Instagram.",
    create_post: "You practiced Post, Story, and Reel on Instagram.",
    posting_plan: "People remember you",
    read_numbers: "You can read views, likes, saves and messages.",
  };
  const action = upcoming
    ? `<button class="btn" data-act="next-task" data-id="${upcoming.id}">${esc(t("Next task: " + upcoming.title))}</button>`
    : btn("Done", "home");
  return screen(`<div class="pad-20 stack" style="position:relative">
    ${confetti()}
    <div class="scroll center-copy">
      <div class="badge-hero">${svg.medal}</div>
      <p class="kicker" style="margin-top:18px">${esc(t("Badge earned"))}</p>
      <h1>${esc(t(task.title))}</h1>
      <p class="lede">${esc(t(lines[task.id] || "Done"))}</p>
    </div>
    <div class="foot">${action}</div>
  </div>`);
}

function render(options) {
  document.body.dataset.lang = code();
  const view = current();
  const html = {
    splash: renderSplash,
    login: renderLogin,
    forgot: renderForgot,
    language: () => renderLanguage(view),
    welcome: () => renderWelcome(view),
    main: renderMain,
    task: () => renderTask(view),
    lesson: () => renderLesson(view),
    check: () => renderCheck(view),
    find: () => renderFind(view),
    tryit: () => renderTry(view),
    products: renderProducts,
    "create-types": renderCreateTypes,
    "ig-post": () => renderIgPost(view),
    "pick-media": () => renderPickMedia(view),
    "did-post": () => renderDidPost(view),
    displays: () => renderDisplays(view),
    shots: () => renderShots(view),
    shot: () => renderShot(view),
    badge: () => renderBadge(view),
  }[view.name];
  const keep = options && options.keepScroll;
  const previous = keep ? document.querySelector("[data-scroll]") : null;
  const top = previous ? previous.scrollTop : 0;
  document.getElementById("app").innerHTML = html();
  const scroller = document.querySelector("[data-scroll]") || document.querySelector(".scroll");
  if (scroller) scroller.scrollTop = keep ? top : 0;
  bindScrollCue();
}

function bindScrollCue() {
  const scroller = document.querySelector(".scroll");
  const cue = scroller && scroller.querySelector(".scroll-cue");
  if (!scroller || !cue) return;
  const update = () => {
    const extra = scroller.scrollHeight - scroller.clientHeight;
    const nearBottom = scroller.scrollTop >= extra - 28;
    cue.hidden = extra <= 12 || nearBottom;
  };
  update();
  scroller.addEventListener("scroll", update, { passive: true });
}

function showBadge(taskId) {
  state.tab = "learn";
  state.stack = [{ name: "main" }, { name: "badge", task: taskId }];
  render();
}

function finishCurrentPart() {
  const view = current();
  const taskId = view.task || view.id;
  const partId = view.part;
  if (taskId && partId) markPart(taskId, partId);
  const task = taskById(taskId);
  if (task && isTaskDone(task)) {
    showBadge(task.id);
    return;
  }
  back();
}

function afterCheck() {
  const view = current();
  const task = taskById(view.task);
  const part = partById(task, view.part);
  markPart(task.id, part.id);
  if (part.then === "tryit") {
    state.tryStep = 0;
    push("tryit", { task: task.id, part: "4" });
    return;
  }
  if (isTaskDone(task)) {
    showBadge(task.id);
    return;
  }
  const visible = task.parts.filter((item) => !item.hidden);
  const index = visible.findIndex((item) => item.id === part.id);
  const following = visible[index + 1];
  if (following) {
    state.stack = [
      { name: "main" },
      { name: "task", id: task.id },
      { name: "lesson", task: task.id, part: following.id },
    ];
    render();
    return;
  }
  state.stack = [{ name: "main" }];
  render();
}

document.getElementById("phone").addEventListener("click", (event) => {
  const node = event.target.closest("[data-act]");
  if (!node) return;
  const act = node.dataset.act;
  if (act === "speak" || act === "speak-native") {
    event.stopPropagation();
    if (act === "speak-native") {
      const previous = state.lang;
      state.lang = node.dataset.locale;
      speak(node.dataset.say);
      state.lang = previous;
      const card = node.closest("[data-act='choose-lang']");
      if (card) card.click();
    } else {
      speak(node.dataset.text);
    }
    return;
  }
  if (act === "back") return back();
  if (act === "toggle-pass") {
    captureFields();
    state.hidePassword = !state.hidePassword;
    render();
    return;
  }
  if (act === "login") {
    state.langBefore = state.lang;
    push("language", { changing: false });
    return;
  }
  if (act === "forgot") {
    state.resetSent = false;
    push("forgot");
    return;
  }
  if (act === "send-reset") {
    captureFields();
    state.resetSent = true;
    render();
    return;
  }
  if (act === "choose-lang") {
    state.lang = node.dataset.locale;
    render();
    return;
  }
  if (act === "start-welcome") {
    localStorage.setItem("cs-lang", state.lang);
    push("welcome", { page: "shoot" });
    return;
  }
  if (act === "confirm-lang") {
    localStorage.setItem("cs-lang", state.lang);
    state.langBefore = null;
    back();
    return;
  }
  if (act === "welcome-share") return push("welcome", { page: "share" });
  if (act === "enter-app") {
    state.tab = "learn";
    replace("main");
    return;
  }
  if (act === "language") {
    state.langBefore = state.lang;
    push("language", { changing: true });
    return;
  }
  if (act === "tab") {
    if (node.dataset.tab === "photo") {
      state.pickedDisplays = [];
      if (current().name === "main") push("products");
      else {
        state.stack = [{ name: "main" }, { name: "products" }];
        render();
      }
      return;
    }
    state.tab = node.dataset.tab;
    if (current().name !== "main") state.stack = [{ name: "main" }];
    render();
    return;
  }
  if (act === "open-task") return push("task", { id: node.dataset.id });
  if (act === "open-part") {
    if (node.disabled) return;
    if (node.dataset.locked === "1") {
      toast(t("Finish " + node.dataset.need + " first"));
      return;
    }
    const task = taskById(node.dataset.task);
    const part = partById(task, node.dataset.part);
    if (part.kind === "numbers" || part.kind === "guide" || part.lessonTitle) {
      push("lesson", { task: task.id, part: part.id });
    }
    return;
  }
  if (act === "open-check") {
    const view = current();
    push("check", { task: view.task, part: view.part });
    return;
  }
  if (act === "pick") {
    if (state.choice) return;
    state.choice = node.dataset.letter.toLowerCase();
    render();
    return;
  }
  if (act === "after-check") return afterCheck();
  if (act === "finish-part") return finishCurrentPart();
  if (act === "open-find") {
    const view = current();
    state.earned = false;
    push("find", { task: view.task, part: view.part });
    return;
  }
  if (act === "earn-find") {
    const view = current();
    const task = taskById(view.task);
    if (task) task.parts.forEach((part) => markPart(task.id, part.id));
    state.earned = true;
    render();
    return;
  }
  if (act === "leave-find") {
    const view = current();
    state.earned = false;
    state.tab = "learn";
    state.stack = [{ name: "main" }, { name: "task", id: view.task }];
    render();
    return;
  }
  if (act === "access-continue" || act === "allow-photos") {
    state.photos = true;
    localStorage.setItem("cs-photos", "1");
    if (createAllDone()) {
      showBadge("create_post");
      return;
    }
    push("create-types");
    return;
  }
  if (act === "types-continue") {
    const kind = nextCreateKind();
    if (!kind) return;
    openIg(kind);
    return;
  }
  if (act === "ig-plus" || act === "ig-step" || act === "ig-menu") {
    const view = current();
    const index = node.dataset.index == null ? 0 : Number(node.dataset.index);
    const openPicker = () => {
      state.createPhoto = null;
      push("pick-media", { kind: view.kind });
    };
    if (act === "ig-menu") {
      openPicker();
      return;
    }
    if (view.kind === "post" || (act === "ig-step" && index >= 1)) {
      openPicker();
      return;
    }
    if (state.createStep < 1) {
      state.createStep = 1;
      render();
    }
    return;
  }
  if (act === "pick-photo") {
    state.createPhoto = Number(node.dataset.index);
    render();
    return;
  }
  if (act === "pick-next") {
    if (state.createPhoto == null) return;
    const view = current();
    push("did-post", { kind: view.kind, photo: state.createPhoto });
    return;
  }
  if (act === "posted-yes") {
    finishCreateKind(current().kind);
    return;
  }
  if (act === "posted-again") {
    back();
    return;
  }
  if (act === "try-cat") {
    state.tryCategory = node.dataset.name;
    render();
    return;
  }
  if (act === "try-show") {
    state.tryShow = !state.tryShow;
    render();
    return;
  }
  if (act === "try-next") {
    captureFields();
    if (state.tryStep < 2) {
      state.tryStep += 1;
      render();
      return;
    }
    const view = current();
    markPart(view.task, view.part);
    const task = taskById(view.task);
    if (isTaskDone(task)) {
      showBadge(task.id);
      return;
    }
    state.stack = [{ name: "main" }];
    render();
    return;
  }
  if (act === "pick-product") {
    state.product = node.dataset.name;
    render({ keepScroll: true });
    return;
  }
  if (act === "products-continue") {
    if (!state.product) return;
    state.pickedDisplays = [];
    push("displays", { product: state.product });
    return;
  }
  if (act === "toggle-display") {
    const id = node.dataset.id;
    const index = state.pickedDisplays.indexOf(id);
    if (index >= 0) state.pickedDisplays.splice(index, 1);
    else state.pickedDisplays.push(id);
    render({ keepScroll: true });
    return;
  }
  if (act === "displays-continue") {
    const view = current();
    const chosen = displaysFor(view.product).filter((id) => state.pickedDisplays.indexOf(id) >= 0);
    if (!chosen.length) return;
    if (chosen.length === 1) {
      state.shotQueue = [];
      state.shotChosen = null;
      openShot(view.product, chosen[0]);
      return;
    }
    state.shotQueue = chosen;
    state.shotDone = [];
    state.shotChosen = null;
    push("shots", { product: view.product });
    return;
  }
  if (act === "choose-shot") {
    if (node.disabled) return;
    state.shotChosen = node.dataset.id;
    render({ keepScroll: true });
    return;
  }
  if (act === "shots-next") {
    const view = current();
    const left = state.shotQueue.filter((id) => state.shotDone.indexOf(id) < 0);
    if (!left.length) {
      state.tab = "learn";
      state.stack = [{ name: "main" }];
      render();
      return;
    }
    if (!state.shotChosen) return;
    openShot(view.product, state.shotChosen);
    return;
  }
  if (act === "open-shot") {
    openShot(node.dataset.product, node.dataset.id);
    return;
  }
  if (act === "shot-done") {
    if (state.shotQueue.length > 1 && state.shotChosen) {
      if (state.shotDone.indexOf(state.shotChosen) < 0) state.shotDone.push(state.shotChosen);
      const left = state.shotQueue.filter((id) => state.shotDone.indexOf(id) < 0);
      state.shotChosen = left[0] || null;
      back();
      return;
    }
    state.tab = "learn";
    state.stack = [{ name: "main" }];
    render();
    return;
  }
  if (act === "next-task") {
    state.tab = "learn";
    state.stack = [{ name: "main" }, { name: "task", id: node.dataset.id }];
    render();
    return;
  }
  if (act === "home") {
    state.tab = "learn";
    replace("main");
  }
});

document.getElementById("phone").addEventListener("submit", (event) => {
  event.preventDefault();
});

replace("splash");
splashTimer = setTimeout(() => replace("login"), 1800);
