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

// Renamed from "cs-lang" when English became the default: Assamese used to be
// preselected, so an old saved value may not be a real choice.
const LANG_KEY = "cs-language";

const state = {
  lang: localStorage.getItem(LANG_KEY) || "en-US",
  langBefore: null,
  stack: [],
  tab: "learn",
  progress: JSON.parse(localStorage.getItem("cs-progress") || "{}"),
  photos: localStorage.getItem("cs-photos") === "1",
  work: null,
  workCopied: null,
  captionDraft: "",
  email: "",
  password: "",
  hidePassword: true,
  resetEmail: "",
  resetSent: false,
  choice: null,
  product: null,
  tryName: "",
  tryHandle: "divya.weaves",
  tryCustom: "",
  tryOwn: false,
  tryDisplayName: "Divya Warule",
  tryUsername: "",
  tryBio: null,
  tryPhoto: "",
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
  guideIndex: 0,
  photoUrl: "",
  photoAspect: 0.75,
  cameraProblem: "",
  editTool: "bright",
  editTurns: 0,
  editBright: 0,
  editWhite: 0,
  editCrop: [0, 0, 1, 1],
};

let splashTimer = 0;
let toastTimer = 0;

function toast(message) {
  state.toast = message;
  render({ keepScroll: true });
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    state.toast = "";
    render({ keepScroll: true });
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
    [/^Next part · (.+)$/, "Next part · {part}", (m) => ({ part: t(m[1]) })],
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

function img(path, size) {
  const local = IMG + path;
  if (!path || !/\.jpe?g$/i.test(String(path))) return local;
  const host = location.hostname || "";
  const onNetlify = /\.netlify\.app$/i.test(host);
  if (!onNetlify) return local;
  const width = Math.min(1600, Math.max(240, Number(size) || 900));
  const abs = "/assets/images/" + String(path).replace(/^\/+/, "");
  return `/.netlify/images?url=${encodeURIComponent(abs)}&w=${width}&q=90&fm=webp`;
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

function captureFields() {
  const email = document.getElementById("email");
  const password = document.getElementById("password");
  const reset = document.getElementById("reset-email");
  const tryName = document.getElementById("try-name");
  const tryDisplay = document.getElementById("try-display");
  const tryUser = document.getElementById("try-user");
  const tryBio = document.getElementById("try-bio");
  if (email) state.email = email.value;
  if (password) state.password = password.value;
  if (reset) state.resetEmail = reset.value;
  if (tryName) state.tryName = tryName.value;
  if (tryDisplay) state.tryDisplayName = tryDisplay.value;
  if (tryUser) state.tryUsername = tryUser.value.replace(/^@/, "");
  if (tryBio) state.tryBio = tryBio.value;
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
  close: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 6l12 12M18 6L6 18"/></svg>',
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

function nav(tab) {
  const item = (id, inner, label) =>
    `<button class="${tab === id ? "on" : ""}" data-act="tab" data-tab="${id}">${inner}<span>${esc(t(label))}</span></button>`;
  // The files have their own colours, so they are used as shapes filled with
  // the tab's colour.
  const icon = (file) => {
    const source = img(file);
    return `<span class="nav-icon" style="-webkit-mask-image:url('${source}');mask-image:url('${source}')"></span>`;
  };
  return `<nav class="nav">
    ${item("learn", icon("icons/book.png"), "Learn")}
    ${item("photo", svg.camera, "Photo")}
    ${item("me", icon("icons/user.png"), "Me")}
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
    label: "TASK 1 OF 6",
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
          lessonTitle: "Cotton: soft light from the front",
          line: "Cotton and eri soak up light. Soft light from the front shows them evenly.",
          image: photo("cotton_front_light_straight.jpg"),
          wrong: { image: photo("cotton_side_light.jpg"), label: "Hard light from the side" },
          right: { image: photo("cotton_soft_front.jpg"), label: "Soft light from the front" },
          rightReason: "Soft front light shows the weave evenly",
          wrongReason: "Side light leaves dark shadows",
        },
      ),
      lesson(
        { id: "6", title: "Light for silk", label: "PART 6 · LIGHT FOR SILK" },
        {
          lessonTitle: "Silk: soft light from the side",
          line: "Mulberry and muga throw light back. Soft light lets them glow.",
          image: photo("silk_light_art.jpg"),
          wrong: { image: photo("silk_glare.jpg"), label: "Direct sun" },
          right: { image: photo("silk_soft_light.jpg"), label: "Soft light" },
          rightReason: "Soft light makes silk glow",
          wrongReason: "Sun makes white glare spots",
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
    label: "TASK 2 OF 6",
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
    label: "TASK 3 OF 6",
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
    label: "TASK 4 OF 6",
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
          lessonTitle: "Cloth and work",
          image: plan("mix_posts_cloth_work.jpg"),
          wrong: { image: plan("posts_same.jpg"), contain: true, label: "Same photo" },
          right: { image: plan("posts_mixed_cloth_work.jpg"), contain: true, label: "Mixed" },
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
    label: "TASK 5 OF 6",
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
  // Opens its own screen, so it has one part and no lesson pages.
  {
    id: "ai_photos",
    number: "06",
    title: "AI photos",
    detail: "Copy a prompt",
    image: photo("ai_photos_card.jpg"),
    parts: [{ id: "1", title: "AI photos" }],
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
    body = `<span class="shot face"><img src="${img(option.image, 480)}" alt="" decoding="async"><small>${esc(t(option.caption))}</small></span>`;
  } else if (option.image && option.caption) {
    body = `<span class="shot captioned"><img src="${img(option.image, 560)}" alt="" decoding="async"><small>${esc(t(option.caption))}</small></span>`;
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
    body = `<span class="shot post"><img src="${img(option.image, 560)}" alt="" decoding="async">${lines}</span>`;
  } else if (option.chat) {
    const chat = option.chat;
    const photo = chat.image ? `<img src="${img(chat.image)}" alt="">` : "";
    body = `<span class="shot chat-shot"><span class="chat-col">
      <span class="ask">${photo}<span>${esc(t(chat.question))}</span></span>
      <span class="when"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="7.2" stroke="currentColor" stroke-width="1.7"/><path d="M12 8.5V12l2.4 1.6" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>${esc(t(chat.time))}</span>
      <span class="reply">${esc(chat.reply)}</span>
    </span></span>`;
  } else if (option.image) {
    body = `<span class="shot ${option.contain ? "fit" : ""}"><img class="${option.contain ? "contain" : ""}" src="${img(option.image, 700)}" alt="" decoding="async"></span>`;
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
  // Each letter rises in after the one before it.
  const title = t("Click & Social");
  const letters = [...title].map((letter, index) =>
    `<span style="animation-delay:${index * 55}ms">${letter === " " ? "&nbsp;" : esc(letter)}</span>`,
  ).join("");
  return screen(
    `<div class="splash">
      <h1 aria-label="${esc(title)}"><span class="splash-letters" aria-hidden="true">${letters}</span></h1>
      <i class="splash-line"></i>
      <p class="splash-line-text">${esc(t("Show your craft to the world"))}</p>
    </div>`,
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
      <span class="art"><img src="${img(task.image, 420)}" alt="" loading="lazy" decoding="async">${on ? `<span class="play">${svg.play}</span>` : ""}</span>
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
    const inner = `<div class="medal">${on ? svg.medal : svg.lockBadge}</div><p>${esc(t(task.title))}</p>`;
    return on
      ? `<button type="button" class="badge on" data-act="open-work" data-id="${task.id}">${inner}</button>`
      : `<div class="badge">${inner}</div>`;
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
  showBadge("create_post");
}

function openShot(productName, id) {
  const product = PRODUCTS.find((item) => item[0] === productName);
  const [name, key] = DISPLAYS[id];
  state.guideIndex = 0;
  push("guide", {
    product: productName,
    display: name,
    displayId: id,
    key,
    file: displayImage(productName, product[1], key),
    whole: WHOLE_PHOTOS.has(productName),
  });
}

const guideSetup = (title, subtitle, art, picture) => ({ title, subtitle, art, picture, example: false, caption: null });
const guideSample = (title, subtitle, caption) => ({ title, subtitle, art: null, example: true, caption: caption || null });

const GUIDE_STEPS = {
  full_display: [
    guideSetup("Lay the whole piece flat", "Floor or table · plain sheet under it", "spread"),
    guideSetup("Straighten every edge", "Borders even · no folds", "grid"),
    guideSample("Good example", "The whole piece in frame, laid flat", "Show every edge. Keep it flat, not hanging."),
  ],
  mekhala_full: [
    guideSetup("Lay both pieces flat", "Mekhela and sador side by side · plain sheet under them", "mekhalaSpread"),
    guideSample("Good example", "Both pieces in frame, laid flat", "Show every edge. Keep both pieces flat, not hanging."),
  ],
  "close-up_texture": [
    guideSetup("One hand-span away", "Hold the phone 15–30 cm above the fabric — close enough to count threads", "distance"),
    guideSetup("Frame the detail", "Fill the centre box · edges parallel", "close"),
    guideSample("Good example", "So close you can count the threads"),
  ],
  draped_look: [guideSample("Good example", "Over a chair — pleats in front, pallu down the side")],
  embroidery_and_border: [
    guideSetup("Find the border", "Close on the extra-weft buta of the pallu — that is the handwork", "border"),
    guideSetup("Motif on a crossing point", "Use the grid — motif where lines cross", "grid"),
    guideSample("Good example", "Border filling the frame, folds giving it depth", "The border is where the weaver’s hours show."),
  ],
  shawl_full: [
    guideSetup("Hang the shawl straight", "On a rod · border down the side · tassels along the bottom", "shawlFull"),
    guideSample("Good example", "Whole shawl in frame, hanging straight", "Show the border and the tassels. Keep it straight, not draped."),
  ],
  shawl_folded: [
    guideSetup("One folded shawl", "Shot from above · border on the side · tassels along the front", "shawlFolded"),
    guideSample("Good example", "One fold in frame — tassels along the bottom"),
  ],
  stole_full: [
    guideSetup("Hang the stole straight", "On a rod · borders down the sides · tassels along the bottom", "stoleFull"),
    guideSample("Good example", "Whole stole in frame, hanging straight", "Show the borders and the tassels. Keep it straight, not draped."),
  ],
  stole_folded: [
    guideSetup("One folded stole", "Shot from above · border and tassels along the front edge", "stoleFolded"),
    guideSample("Good example", "One fold in frame — tassels along the bottom"),
  ],
  mekhala_folded: [
    guideSetup("Stack the two pieces", "Mekhela on top · sador underneath, border and tassels along the bottom", "mekhalaFolded"),
    guideSample("Good example", "Both pieces folded — sador border and tassels showing", "The mekhela sits on top. The sador border runs along the bottom."),
  ],
  folded_stack: [
    guideSetup("One folded sari in the box", "Shot from above — not a pile, a single stack", "folded"),
    guideSample("Good example", "One stack in frame — border strip visible on the side", "Layers tell the buyer how heavy the cloth is."),
  ],
  mekhala_hanging: [
    guideSetup("Hang both pieces", "Mekhela on the left, shorter · sador on the right, with tassels", "mekhalaHanging"),
    guideSample("Good example", "Both pieces on hangers — sador longer, tassels at the bottom", "Hang them straight. The sador is the long piece with tassels."),
  ],
  hanging_display: [
    guideSetup("Hang it dead centre", "Rod or hanger · piece on the center vertical axis", "hanging"),
    guideSample("Good example", "Hung straight — whole piece in frame, not draped", "Hang it straight so the whole piece shows. Do not drape it."),
  ],
  sofa_seated_display: [guideSample("Good example", "Cover against the back, only part of the sofa in frame", "Show the whole cover. Do not crop the corners.")],
  flat_lay_display: [guideSample("Good example", "Laid flat so the whole cover is in frame", "Keep it flat and show every corner.")],
  gamusa_full: [
    guideSetup("Hang the gamusa straight", "On a rod · borders on both sides · tassels along the bottom", "gamusaFull"),
    guideSample("Good example", "Whole gamusa in frame, hanging straight", "Show the end border and the tassels. Keep it straight."),
  ],
  gamusa_folded: [
    guideSetup("One folded gamusa", "Shot from above · end border across · tassels along the front", "gamusaFolded"),
    guideSample("Good example", "One fold in frame — tassels along the bottom"),
  ],
  jod_hanging: [
    guideSetup("Hang both pieces", "One rod · wide cloth on the left · narrow piece with tassels", "jodHanging"),
    guideSample("Good example", "Both pieces in frame, hanging straight", "Show the wide border and the tassels. Keep both pieces straight."),
  ],
  yardage_hanging: [
    guideSetup("Hang the yardage straight", "On a rod · motifs scattered across", null, "lessons/photography/yardage_hanging_guide.png"),
    guideSample("Good example", "Whole cloth in frame, hanging from the rod", "Show the scattered motifs. Keep the cloth straight."),
  ],
  yardage_close: [
    guideSetup("Fill the frame with the weave", "Close on the cloth · a few motifs in the shot", "yardageClose"),
    guideSample("Good example", "So close the weave and motifs fill the frame", "Count the threads. Keep a few motifs in the shot."),
  ],
  jod_folded: [guideSample("Good example", "Both folds in frame — tassels along the small piece", "Keep them side by side so the border and the tassels show.")],
};

function guideFor(displayKey, product) {
  if (displayKey === "full_display" && product === "Mekhala sador") return GUIDE_STEPS.mekhala_full;
  if (displayKey === "hanging_display" && product === "Mekhala sador") return GUIDE_STEPS.mekhala_hanging;
  if (displayKey === "folded_stack" && product === "Mekhala sador") return GUIDE_STEPS.mekhala_folded;
  if (displayKey === "full_display" && product === "Stole") return GUIDE_STEPS.stole_full;
  if (displayKey === "folded_stack" && product === "Stole") return GUIDE_STEPS.stole_folded;
  if (displayKey === "full_display" && product === "Shawl") return GUIDE_STEPS.shawl_full;
  if (displayKey === "folded_stack" && product === "Shawl") return GUIDE_STEPS.shawl_folded;
  if (displayKey === "full_display" && product === "Gamusa") return GUIDE_STEPS.gamusa_full;
  if (displayKey === "folded_stack" && product === "Gamusa") return GUIDE_STEPS.gamusa_folded;
  if (displayKey === "hanging_display" && product === "Jod kappur") return GUIDE_STEPS.jod_hanging;
  if (displayKey === "folded_stack" && product === "Jod kappur") return GUIDE_STEPS.jod_folded;
  if (displayKey === "hanging_display" && product === "Yardages") return GUIDE_STEPS.yardage_hanging;
  if (displayKey === "close-up_texture" && product === "Yardages") return GUIDE_STEPS.yardage_close;
  return GUIDE_STEPS[displayKey] || GUIDE_STEPS.full_display;
}

function guideSvg(art) {
  const ink = "#152322";
  const teal = "#1B7574";
  const faint = "rgba(27,117,116,0.45)";
  const fill = "rgba(27,117,116,0.08)";
  const shade = "rgba(27,117,116,0.13)";
  const shadeStrong = "rgba(27,117,116,0.2)";
  const motif = "rgba(27,117,116,0.8)";
  const n = (value) => Math.round(value * 100) / 100;
  const line = (x1, y1, x2, y2, color, width) =>
    `<line x1="${n(x1)}" y1="${n(y1)}" x2="${n(x2)}" y2="${n(y2)}" stroke="${color}" stroke-width="${width || 2.2}" stroke-linecap="round"/>`;
  const frame = (l, t, r, b) =>
    `<rect x="${n(l)}" y="${n(t)}" width="${n(r - l)}" height="${n(b - t)}" rx="3" fill="none" stroke="${faint}" stroke-width="1.6"/>`;
  const block = (l, t, r, b, paint) =>
    `<rect x="${n(l)}" y="${n(t)}" width="${n(r - l)}" height="${n(b - t)}" fill="${paint || fill}" stroke="${teal}" stroke-width="2.2"/>`;
  const wash = (l, t, r, b, paint) =>
    `<rect x="${n(l)}" y="${n(t)}" width="${n(r - l)}" height="${n(b - t)}" fill="${paint}"/>`;
  const diamond = (x, y, rx, ry) =>
    `<path d="M${n(x)} ${n(y - ry)} L${n(x + rx)} ${n(y)} L${n(x)} ${n(y + ry)} L${n(x - rx)} ${n(y)} Z" fill="${motif}"/>`;
  const motifs = (l, t, r, b) => {
    const spots = [[0.22, 0.28], [0.48, 0.22], [0.72, 0.34], [0.3, 0.55], [0.58, 0.62], [0.78, 0.72], [0.18, 0.78]];
    return spots.map(([sx, sy]) => diamond(l + (r - l) * sx, t + (b - t) * sy, 1.3, 1.6)).join("");
  };
  const star = (x, y, radius, paint) => {
    const arm = radius * 0.32;
    return `<path d="M${n(x)} ${n(y - radius)} L${n(x + arm)} ${n(y - arm)} L${n(x + radius)} ${n(y)} L${n(x + arm)} ${n(y + arm)} L${n(x)} ${n(y + radius)} L${n(x - arm)} ${n(y + arm)} L${n(x - radius)} ${n(y)} L${n(x - arm)} ${n(y - arm)} Z" fill="${paint}"/>`;
  };
  const peaks = (left, right, top, drop) => {
    const count = 6;
    const step = (right - left) / count;
    let d = `M${n(left)} ${n(top + drop)}`;
    for (let i = 0; i < count; i += 1) {
      const x = left + step * i;
      d += ` L${n(x + step / 2)} ${n(top)} L${n(x + step)} ${n(top + drop)}`;
    }
    return `<path d="${d}" fill="none" stroke="${teal}" stroke-width="2.2" stroke-linejoin="round" stroke-linecap="round"/>`;
  };
  const tassels = (xs, y1, y2) => xs.map((x) => line(x, y1, x, y2, teal)).join("");
  const hanger = (cx, left, right) =>
    line(cx, 16, cx, 19.2, teal, 1.6) + line(left, 24, cx, 18.4, teal, 1.6) + line(right, 24, cx, 18.4, teal, 1.6) + line(left, 24, right, 24, teal, 1.6);
  let body = "";
  if (art === "spread") {
    body = frame(18, 8, 82, 92) + block(22, 12, 78, 88) + line(33, 12, 33, 88, faint, 1.6) + line(67, 12, 67, 88, faint, 1.6) + line(22, 75, 78, 75, faint, 1.6);
  } else if (art === "mekhalaSpread") {
    body = frame(14, 10, 86, 90) + block(17, 13, 47, 81) + block(51, 13, 83, 81) + line(17, 66, 47, 66, teal) + line(51, 59, 83, 59, teal) + tassels([58, 65, 72, 79], 81, 87);
  } else if (art === "grid") {
    body = [33.3, 66.6].map((v) => line(v, 8, v, 92, faint, 1.6) + line(8, v, 92, v, faint, 1.6)).join("") + block(33.3, 25, 66.6, 80);
  } else if (art === "distance") {
    body = `<rect x="38" y="10" width="24" height="24" rx="4" fill="none" stroke="${ink}" stroke-width="2.2"/>` + line(12, 82, 88, 82, ink) + line(50, 38, 50, 78, teal) + line(50, 78, 46, 70, teal) + line(50, 78, 54, 70, teal);
  } else if (art === "close") {
    body = frame(16, 12, 84, 88) + block(22, 20, 78, 80) + [36, 50, 64].map((x) => line(x, 20, x, 80, faint, 1.6)).join("") + [35, 50, 65].map((y) => line(22, y, 78, y, faint, 1.6)).join("") + motifs(22, 20, 78, 80);
  } else if (art === "border") {
    const fl = 18;
    const ft = 11;
    const fw = 64;
    const fh = 78;
    const inside = (l, t, r, b) => [fl + fw * l, ft + fh * t, fl + fw * r, ft + fh * b];
    const strip = inside(0.74, 0.05, 0.93, 0.95);
    const window = inside(0.07, 0.05, 0.67, 0.95);
    let ticks = "";
    for (let y = strip[1] + 6; y < strip[3] - 3; y += 6) ticks += line(strip[0] + 1.5, y, strip[2] - 1.5, y, faint, 1.6);
    const motifLabel = t("Motif");
    const borderLabel = t("Border");
    body = frame(18, 11, 82, 89).replace('stroke-width="1.6"', 'stroke-width="2.2"').replace(`stroke="${faint}"`, `stroke="${ink}"`)
      + wash(strip[0], strip[1], strip[2], strip[3], fill)
      + `<rect x="${n(strip[0])}" y="${n(strip[1])}" width="${n(strip[2] - strip[0])}" height="${n(strip[3] - strip[1])}" fill="none" stroke="${teal}" stroke-width="2.2"/>`
      + ticks
      + `<rect x="${n(window[0])}" y="${n(window[1])}" width="${n(window[2] - window[0])}" height="${n(window[3] - window[1])}" rx="2.5" fill="none" stroke="${teal}" stroke-width="2.2"/>`
      + `<text x="${n((window[0] + window[2]) / 2)}" y="${n((window[1] + window[3]) / 2)}" text-anchor="middle" dominant-baseline="middle" font-size="5.5" font-weight="800" fill="${ink}">${esc(motifLabel)}</text>`
      + `<g transform="translate(${n((strip[0] + strip[2]) / 2)} ${n((strip[1] + strip[3]) / 2)}) rotate(-90)"><rect x="-12" y="-4.2" width="24" height="8.4" rx="1.2" fill="#fff"/><text text-anchor="middle" dominant-baseline="middle" font-size="5.5" font-weight="800" fill="${ink}">${esc(borderLabel)}</text></g>`;
  } else if (art === "folded") {
    const saree = { l: 22.48, t: 25.64, r: 77.52, b: 74.36 };
    const borderLeft = saree.l + (saree.r - saree.l) * 0.74;
    const inner = borderLeft + (saree.r - borderLeft) * 0.28;
    const outer = borderLeft + (saree.r - borderLeft) * 0.72;
    body = frame(18, 8, 82, 92) + block(saree.l, saree.t, saree.r, saree.b) + motifs(saree.l, saree.t, borderLeft, saree.b) + wash(borderLeft, saree.t, saree.r, saree.b, shadeStrong) + line(borderLeft, saree.t, borderLeft, saree.b, teal) + line(inner, saree.t + 2, inner, saree.b - 2, "rgba(27,117,116,0.75)", 1.3) + line(outer, saree.t + 2, outer, saree.b - 2, "rgba(27,117,116,0.75)", 1.3);
  } else if (art === "hanging") {
    const borderRight = 34 + 32 * 0.22;
    const palluTop = 20 + 66 * 0.74;
    body = frame(18, 8, 82, 92) + block(34, 20, 66, 86) + line(30, 18, 70, 18, teal) + `<circle cx="50" cy="18" r="1.8" fill="${teal}"/>` + wash(34, 20, borderRight, 86, shadeStrong) + line(borderRight, 20, borderRight, 86, teal) + line(34 + (borderRight - 34) * 0.35, 21, 34 + (borderRight - 34) * 0.35, 85, "rgba(27,117,116,0.7)", 1.2) + line(34 + (borderRight - 34) * 0.7, 21, 34 + (borderRight - 34) * 0.7, 85, "rgba(27,117,116,0.7)", 1.2) + motifs(borderRight, 20, 66, 70) + wash(34, palluTop, 66, 86, shade) + line(34, palluTop + (86 - palluTop) / 3, 66, palluTop + (86 - palluTop) / 3, faint, 1.6) + line(34, palluTop + (86 - palluTop) * 2 / 3, 66, palluTop + (86 - palluTop) * 2 / 3, faint, 1.6) + line(50, 20, 50, 86, faint, 1.6);
  } else if (art === "mekhalaHanging") {
    body = frame(10, 8, 90, 92) + line(14, 16, 86, 16, teal) + hanger(32, 22, 44) + hanger(66, 50, 82) + block(24, 24, 42, 68) + [52, 56, 60, 64].map((y) => line(24, y, 42, y, faint, 1.6)).join("") + block(50, 24, 80, 80) + line(56, 24, 56, 80, faint, 1.6) + line(74, 24, 74, 80, faint, 1.6) + motifs(56, 28, 74, 66) + line(50, 68, 80, 68, teal) + line(50, 74, 80, 74, faint, 1.6) + tassels([56, 62, 68, 74], 80, 86);
  } else if (art === "mekhalaFolded") {
    body = frame(12, 10, 88, 90) + block(14, 34, 84, 78) + motifs(18, 63, 72, 69) + line(14, 70, 84, 70, teal) + line(14, 74, 84, 74, faint, 1.6) + tassels([66, 70, 74, 78], 78, 84) + wash(18, 16, 80, 62, "#fff") + block(18, 16, 80, 62) + motifs(20, 18, 62, 60) + line(64, 16, 64, 62, teal) + line(70, 16, 70, 62, faint, 1.6) + line(75, 16, 75, 62, faint, 1.6);
  } else if (art === "stoleFull") {
    body = frame(14, 8, 86, 92) + line(24, 16, 76, 16, teal) + block(34, 18, 66, 78) + line(40, 18, 40, 78, faint, 1.6) + line(60, 18, 60, 78, faint, 1.6) + motifs(42, 24, 58, 58) + line(34, 62, 66, 62, teal) + line(34, 68, 66, 68, faint, 1.6) + tassels([38, 44, 50, 56, 62], 78, 84);
  } else if (art === "stoleFolded") {
    body = frame(12, 10, 88, 90) + block(16, 26, 84, 70) + line(24, 26, 24, 70, faint, 1.6) + line(76, 26, 76, 70, faint, 1.6) + motifs(28, 30, 72, 52) + line(16, 54, 84, 54, teal) + line(16, 60, 84, 60, faint, 1.6) + tassels([24, 34, 44, 54, 64, 74], 70, 78);
  } else if (art === "shawlFull") {
    body = frame(12, 8, 88, 92) + line(18, 16, 82, 16, teal) + block(24, 18, 76, 78) + line(30, 18, 30, 78, faint, 1.6) + wash(64, 18, 76, 78, shade) + line(64, 18, 64, 78, teal) + line(70, 18, 70, 78, faint, 1.6) + motifs(32, 22, 62, 58) + line(24, 60, 76, 60, teal) + line(24, 68, 76, 68, faint, 1.6) + tassels([30, 38, 46, 54, 62, 70], 78, 84);
  } else if (art === "shawlFolded") {
    body = frame(12, 10, 88, 90) + block(14, 24, 86, 70) + line(22, 24, 22, 70, faint, 1.6) + wash(70, 24, 86, 70, shade) + line(70, 24, 70, 70, teal) + line(78, 24, 78, 70, faint, 1.6) + motifs(24, 28, 68, 50) + line(14, 54, 86, 54, teal) + line(14, 62, 86, 62, faint, 1.6) + tassels([22, 32, 42, 52, 62, 72, 80], 70, 78);
  } else if (art === "gamusaFull") {
    const gems = [46, 54].map((x) => diamond(x, 62, 2.2, 2.6)).join("");
    body = frame(14, 8, 86, 92) + line(22, 18, 78, 18, teal) + block(32, 18, 68, 76) + line(36, 18, 36, 76, faint, 1.6) + line(40, 18, 40, 76, teal) + line(60, 18, 60, 76, teal) + line(64, 18, 64, 76, faint, 1.6) + wash(32, 54, 68, 70, shade) + line(32, 54, 68, 54, teal) + line(32, 58, 68, 58, faint, 1.6) + line(32, 66, 68, 66, faint, 1.6) + line(32, 70, 68, 70, teal) + gems + tassels([36, 42, 48, 54, 60, 66], 76, 86);
  } else if (art === "gamusaFolded") {
    const gems = [26, 38, 50, 62].map((x) => diamond(x, 50, 2.1, 2.4)).join("");
    body = frame(10, 12, 90, 88) + block(14, 28, 86, 68) + wash(14, 42, 68, 58, shade) + line(14, 42, 68, 42, teal) + line(14, 46, 68, 46, faint, 1.6) + line(14, 54, 68, 54, faint, 1.6) + line(14, 58, 68, 58, teal) + gems + wash(68, 28, 86, 68, shade) + line(68, 28, 68, 68, teal) + line(74, 28, 74, 68, faint, 1.6) + line(80, 28, 80, 68, faint, 1.6) + tassels([22, 32, 42, 52, 62, 72, 80], 68, 78);
  } else if (art === "jodHanging") {
    body = frame(8, 8, 92, 92) + line(14, 16, 86, 16, teal) + block(14, 18, 60, 78) + line(24, 18, 24, 58, faint, 1.6) + line(32, 18, 32, 58, teal) + peaks(14, 60, 58, 7) + wash(14, 66, 60, 78, shade) + line(14, 66, 60, 66, teal) + line(14, 72, 60, 72, faint, 1.6) + block(68, 18, 84, 60) + line(74, 18, 74, 46, faint, 1.6) + line(68, 46, 84, 46, teal) + line(68, 52, 84, 52, faint, 1.6) + tassels([70, 74, 78, 82], 60, 70);
  } else if (art === "yardageClose") {
    const spots = [[0.2, 0.18], [0.78, 0.16], [0.48, 0.34], [0.14, 0.48], [0.84, 0.52], [0.36, 0.62], [0.66, 0.74], [0.22, 0.84]];
    body = frame(10, 10, 90, 90) + block(14, 14, 86, 86) + [28, 42, 56, 70].map((v) => line(v, 14, v, 86, faint, 1.6) + line(14, v, 86, v, faint, 1.6)).join("") + spots.map(([sx, sy], index) => star(14 + 72 * sx, 14 + 72 * sy, index % 2 ? 2.4 : 3.2, index % 2 ? faint : "rgba(27,117,116,0.9)")).join("");
  }
  return `<svg viewBox="0 0 100 100" width="100%" height="100%" aria-hidden="true">${body}</svg>`;
}

function guideKicker(name) {
  const label = t(name);
  if (code() === "en") return label.toUpperCase().replace(" AND ", " & ");
  return label;
}

function renderShootGuide(view) {
  const steps = guideFor(view.key, view.product);
  const step = steps[state.guideIndex] || steps[0];
  const bars = steps
    .map((_, index) => `<i class="${index <= state.guideIndex ? "on" : ""}"></i>`)
    .join("");
  const spoken = [step.title, step.subtitle, step.caption].filter(Boolean).map((line) => t(line)).join(". ");
  const picture = step.example
    ? `<div class="guide-example"><img src="${img(view.file, 900)}" alt="" decoding="async" fetchpriority="high"></div>`
    : step.picture
    ? `<div class="guide-example"><img src="${img(step.picture, 900)}" alt="" decoding="async"></div>`
    : guideSvg(step.art);
  const caption = step.caption ? `<p class="guide-caption">${esc(t(step.caption))}</p>` : "";
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      <button class="icon-btn" type="button" data-act="guide-back" aria-label="${esc(t("Back"))}">${svg.back}</button>
      <p class="lesson-kicker guide-kicker">${esc(guideKicker(view.display))}</p>
      <span></span>
    </div>
    <div class="guide-bars">${bars}</div>
    <h1 class="guide-title">${esc(t(step.title))}</h1>
    <p class="guide-sub">${esc(t(step.subtitle))}</p>
    <div class="guide-card">${picture}</div>
    ${caption}
    <div class="foot"><button class="btn" type="button" data-act="guide-next">${esc(t(state.guideIndex === steps.length - 1 ? "Take the shot" : "Next"))}<svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></button></div>
  </div>`);
}

function shotArt(product, key) {
  const dir = "lessons/photography/";
  const pair = product === "Saree" || product === "Mekhala sador";
  const tassel = 1000 / 641;
  if (key === "draped_look" && pair) return { file: dir + "draped_outline_v2.png", fit: "draped" };
  if (key === "full_display" && product === "Saree") return { file: dir + "full_display_outline_v3.png", fit: "tall", aspect: 900 / 1286 };
  if (key === "full_display" && product === "Mekhala sador") return { file: dir + "mekhala_full_outline_v2.png", fit: "aspect", aspect: 1000 / 1095 };
  if (key === "full_display" && (product === "Stole" || product === "Shawl" || product === "Gamusa")) return { file: dir + "stole_hanging_outline_v2.png", fit: "tall", aspect: 900 / 1313 };
  if (key === "embroidery_and_border" && product === "Mekhala sador") return { file: dir + "mekhala_border_outline.png", fit: "aspect", aspect: 900 / 1220 };
  if (key === "embroidery_and_border") return { file: dir + "embroidery_outline_v2.png", fit: "inset" };
  if (key === "hanging_display" && product === "Mekhala sador") return { file: dir + "mekhala_hanging_outline_v3.png", fit: "aspect", aspect: 1000 / 1142 };
  if (key === "hanging_display" && product === "Saree") return { file: dir + "hanging_outline_v2.png", fit: "hanging" };
  if (key === "folded_stack" && product === "Mekhala sador") return { file: dir + "mekhala_folded_outline_v2.png", fit: "folded", aspect: 1000 / 727 };
  if (key === "folded_stack" && (product === "Stole" || product === "Shawl" || product === "Gamusa")) return { file: dir + "stole_folded_outline.png", fit: "aspect", aspect: tassel };
  if (key === "folded_stack" && product === "Saree") return { file: dir + "folded_outline_v2.png", fit: "folded", aspect: 1.25 };
  if (key === "sofa_seated_display") return { file: dir + "cushion_sofa_outline.png", fit: "aspect", aspect: 1000 / 914 };
  if (key === "flat_lay_display") return { file: dir + "cushion_flat_outline.png", fit: "aspect", aspect: 1000 / 892 };
  if (key === "close-up_texture" && (pair || product === "Yardages")) return { file: dir + "closeup_outline.png", fit: "inset", box: true };
  if (key === "hanging_display" && product === "Jod kappur") return { file: dir + "jod_hanging_outline_v3.png", fit: "jod-hanging", aspect: 1000 / 991 };
  if (key === "folded_stack" && product === "Jod kappur") return { file: dir + "jod_folded_outline_v2.png", fit: "aspect", aspect: 1000 / 897 };
  if (key === "hanging_display" && product === "Yardages") return { file: dir + "yardage_hanging_outline_v2.png", fit: "tall", aspect: 900 / 1161 };
  return null;
}

function artStyle(art) {
  if (art.fit === "inset") return "left:8px;top:8px;width:calc(100% - 16px);height:calc(100% - 16px)";
  if (art.fit === "draped") return "left:4px;top:10%;width:calc(100% - 8px);height:80%";
  if (art.fit === "jod-hanging") return `left:8px;top:8cqh;width:calc(100cqw - 16px);height:calc((100cqw - 16px) / ${art.aspect})`;
  if (art.fit === "tall") return `height:88cqh;width:calc(88cqh * ${art.aspect});left:50%;top:50%;transform:translate(-50%,-50%)`;
  if (art.fit === "hanging") return "height:94cqh;width:calc(94cqh * 0.58);left:50%;top:50%;transform:translate(-50%,-50%)";
  if (art.fit === "folded") return `width:calc(100cqw - 8px);height:calc((100cqw - 8px) / ${art.aspect});left:50%;top:50%;transform:translate(-50%,-50%)`;
  if (art.aspect >= 0.75) return `width:calc(100% - 16px);height:calc((100cqw - 16px) / ${art.aspect});left:50%;top:50%;transform:translate(-50%,-50%)`;
  return `height:calc(100% - 16px);width:calc((100cqh - 16px) * ${art.aspect});left:50%;top:50%;transform:translate(-50%,-50%)`;
}

function renderCamera(view) {
  const art = shotArt(view.product, view.key);
  const problem = state.cameraProblem;
  const face = problem
    ? `<div class="cam-fallback"><svg width="34" height="34" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 8h3l2-2h6l2 2h3v10H4V8z" stroke="currentColor" stroke-width="1.6"/><path d="M4 4l16 16" stroke="currentColor" stroke-width="1.6"/></svg><p>${esc(t(problem))}</p><button class="btn slim" type="button" data-act="cam-pick">${esc(t("Choose a photo"))}</button></div>`
    : `<video class="cam-video" autoplay playsinline muted></video>`;
  let overlay = `<div class="cam-outline"></div>`;
  if (art) {
    overlay = `<img class="cam-art" style="${artStyle(art)}" src="${img(art.file)}" alt="">${art.box ? `<div class="cam-outline inset"></div>` : ""}`;
  }
  return screen(`<div class="cam">
    <div class="cam-top"><button class="icon-btn light" type="button" data-act="back" aria-label="${esc(t("Back"))}">${svg.back}</button><p class="cam-light wait" aria-live="polite">${lightIcon("wait")}<span>${esc(t("Checking the light"))}</span></p></div>
    <div class="cam-slot"><div class="cam-frame">${face}${overlay}</div></div>
    <div class="cam-bottom"><button class="shutter" type="button" data-act="shutter" aria-label="${esc(t("Take photo"))}"></button></div>
    <input id="cam-file" type="file" accept="image/*" hidden>
  </div>`, "cam");
}

function resetEdit() {
  state.editTool = "bright";
  state.editTurns = 0;
  state.editBright = 0;
  state.editWhite = 0;
  state.editCrop = [0, 0, 1, 1];
}

function shownAspect() {
  const aspect = state.photoAspect || 0.75;
  return state.editTurns % 2 ? 1 / aspect : aspect;
}

// The frame takes the exact shape of what is kept, as large as the card allows,
// so the photo is never trimmed to fit it.
function stageStyle() {
  let aspect = shownAspect();
  if (state.editTool !== "cut") {
    const [l, t, r, b] = state.editCrop;
    aspect = (aspect * (r - l)) / (b - t);
  }
  return `aspect-ratio:${aspect};width:min(100cqw, calc(100cqh * ${aspect}));`;
}

// Where the whole photo sits so that only the kept part shows in the frame.
function photoBoxStyle() {
  const [l, t, r, b] = state.editTool === "cut" ? [0, 0, 1, 1] : state.editCrop;
  return `width:${100 / (r - l)}%;height:${100 / (b - t)}%;left:${(-l / (r - l)) * 100}%;top:${(-t / (b - t)) * 100}%;`;
}

// Turned a quarter, the picture's sides swap, so its box swaps to match.
function photoStyle() {
  const turned = state.editTurns % 2 === 1;
  const aspect = shownAspect();
  const width = turned ? 100 / aspect : 100;
  const height = turned ? 100 * aspect : 100;
  return `width:${width}%;height:${height}%;filter:${editFilter()};transform:translate(-50%, -50%) rotate(${state.editTurns * 90}deg);`;
}

function editFilter() {
  const bright = 1 + state.editBright;
  const warm = Math.max(0, state.editWhite);
  const cool = Math.max(0, -state.editWhite);
  return `brightness(${bright}) sepia(${warm * 0.45}) hue-rotate(${cool * 18}deg) saturate(${1 + warm * 0.15})`;
}

function editHint() {
  if (state.editTool === "cut") return "Cut — drag the corners or edges to crop";
  if (state.editTool === "turn") return "Turn — slide, or tap Turn again";
  if (state.editTool === "white") return "White — slide from cool to warm";
  return "Bright — slide to lighten or darken";
}

function editSlideValue() {
  if (state.editTool === "turn") return (state.editTurns % 4) / 3;
  if (state.editTool === "white") return (state.editWhite + 1) / 2;
  if (state.editTool === "bright") return (state.editBright + 0.35) / 0.8;
  return 0;
}

function renderEdit() {
  const cropped = state.editTool !== "cut";
  const [left, top, right, bottom] = state.editCrop;
  const tools = [
    ["cut", "Cut", '<path d="M6 4h4v4H6zM14 4h4v4h-4zM6 16h4v4H6zM14 16h4v4h-4z" fill="currentColor"/>'],
    ["turn", "Turn", '<path d="M16 7a6 6 0 1 0 1.2 6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M16 4v3.5H12.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>'],
    ["bright", "Bright", '<circle cx="12" cy="12" r="3.2" fill="currentColor"/><path d="M12 4v2M12 18v2M4 12h2M18 12h2M6.4 6.4l1.4 1.4M16.2 16.2l1.4 1.4M17.6 6.4l-1.4 1.4M7.8 16.2l-1.4 1.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>'],
    ["white", "White", '<path d="M8 16l7-8 2 2-7 8H8v-2z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/>'],
  ]
    .map(([id, label, icon]) => `<button type="button" class="edit-tool ${state.editTool === id ? "on" : ""}" data-act="edit-tool" data-tool="${id}"><span><svg viewBox="0 0 24 24" width="24" height="24" aria-hidden="true">${icon}</svg></span>${esc(t(label))}</button>`)
    .join("");
  const slider = state.editTool === "cut"
    ? `<div class="edit-gap"></div>`
    : `<input class="edit-slide" data-act="edit-slide" type="range" min="0" max="1" step="${state.editTool === "turn" ? "0.3333" : "0.01"}" value="${editSlideValue()}">`;
  const handles = cropped
    ? ""
    : `<div class="crop-box" style="left:${left * 100}%;top:${top * 100}%;width:${(right - left) * 100}%;height:${(bottom - top) * 100}%"><i data-handle="nw"></i><i data-handle="ne"></i><i data-handle="sw"></i><i data-handle="se"></i></div>`;
  return screen(`<div class="edit">
    <div class="edit-head">
      <button class="icon-btn light" type="button" data-act="edit-close" aria-label="${esc(t("Back"))}">${svg.close}</button>
      <b>${esc(t("Edit"))}</b>
      <button class="edit-save" type="button" data-act="edit-save">${esc(t("Save"))}</button>
    </div>
    <div class="edit-card"><div class="edit-stage" style="${stageStyle()}"><div class="edit-photo-box" style="${photoBoxStyle()}"><img class="edit-photo" src="${state.photoUrl}" alt="" style="${photoStyle()}"></div>${handles}</div></div>
    ${slider}
    <p class="edit-hint">${esc(t(editHint()))}</p>
    <div class="edit-tools">${tools}<button type="button" class="edit-tool" data-act="edit-reset"><span><svg viewBox="0 0 24 24" width="24" height="24" aria-hidden="true"><path d="M8 7a6 6 0 1 1-1.2 6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M8 4v3.5h3.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg></span>${esc(t("Reset"))}</button></div>
  </div>`, "edit");
}

function displayImage(productName, material, key) {
  if (productName === "Saree" && key === "full_display") return "lessons/displays/saree_full_display_v2.jpg";
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
  const source = img(options.file, options.tall ? 560 : 420);
  const photo = `<img src="${source}" alt="" loading="lazy" decoding="async" fetchpriority="low">`;
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
      <span></span>
    </div>
    <h1 class="pick-title">${esc(t("What are you photographing?"))}</h1>
    <p class="pick-sub">${esc(t("Tap one"))}</p>
    <div class="pick-grid" data-scroll>${cards}</div>
    <div class="foot">${readyBtn("Continue", "products-continue", !!state.product)}</div>
  </div>`);
}

// AI photos: writes the prompt an artisan copies into their own AI tool. The
// wording matches lib/features/learn/data/ai_prompts.dart, and prompts stay in
// English whatever language the page is in.
const AI_NEEDED_PHOTOS = [
  ["Full photo", "The whole product in one photo"],
  ["Close-up of the motif", "Close enough to see the threads"],
];
const AI_PRODUCT_WORDS = {
  "Saree": "saree",
  "Mekhala sador": "mekhela sador set",
  "Stole": "stole",
  "Gamusa": "gamusa",
  "Shawl": "shawl",
  "Jod kappur": "jod kappur set (wide cloth and smaller tasseled piece)",
  "Yardages": "fabric",
  "Cushion covers": "cushion cover"
};

// Close-ups are left out on purpose: a close-up has to be a real photo, because
// it is the proof of the handwork.
const AI_SCENES = {
  "Saree": {
    "displays": [
      ["Draped", "Show this saree draped on a plain mannequin, with neat front pleats and the pallu over the shoulder."],
      ["Hanging", "Show this saree hanging straight from a wooden rod against a plain wall, with the whole piece in frame."],
      ["Folded", "Show this saree neatly folded on a wooden table, with the pallu on top and the border along the edge."]
    ],
    "props": [
      ["Mannequin", "Show this saree worn on a full-length plain mannequin, standing in a bright, simple room."],
      ["Wooden hanger", "Hang this saree on a wooden hanger against a plain wall, with the pallu falling in front."],
      ["Chair", "Drape this saree over the back of a wooden chair, with the pallu hanging down."],
      ["Festive setting", "Place this saree, neatly folded, on a wooden table with a brass lamp and a few flowers beside it."]
    ]
  },
  "Mekhala sador": {
    "displays": [
      ["Draped", "Show this mekhela and sador worn on a plain mannequin, with the sador over the shoulder and both borders visible."],
      ["Hanging", "Show the mekhela and sador hanging side by side from a wooden rod against a plain wall, with both pieces in frame."],
      ["Folded", "Show the mekhela and sador neatly folded and stacked on a wooden table, with both borders along the edge."]
    ],
    "props": [
      ["Mannequin", "Show the mekhela and sador worn on a full-length plain mannequin, standing in a bright, simple room."],
      ["Wooden hanger", "Hang the mekhela and sador on two wooden hangers against a plain wall."],
      ["Chair", "Drape the sador over the back of a wooden chair, with the folded mekhela on the seat."],
      ["Festive setting", "Place the mekhela and sador, neatly folded, on a wooden table with a brass lamp and a few flowers beside them."]
    ]
  },
  "Stole": {
    "displays": [
      ["Draped", "Show this stole draped around the neck of a plain mannequin, with both ends falling in front."],
      ["Hanging", "Show this stole hanging straight from a wooden rod against a plain wall, with the whole piece in frame."],
      ["Folded", "Show this stole neatly folded on a wooden table, with the border along the top edge."]
    ],
    "props": [
      ["Wooden hanger", "Hang this stole on a wooden hanger against a plain wall, with both ends falling straight."]
    ]
  },
  "Gamusa": {
    "displays": [
      ["Draped", "Show this gamusa draped around the neck of a plain mannequin, with both ends falling in front."],
      ["Hanging", "Show this gamusa hanging straight from a wooden rod against a plain wall, with the whole piece in frame."],
      ["Folded", "Show this gamusa neatly folded on a wooden table, with the border along the top edge."]
    ],
    "props": [
      ["Wooden hanger", "Hang this gamusa on a wooden hanger against a plain wall, with both ends falling straight."]
    ]
  },
  "Shawl": {
    "displays": [
      ["Draped", "Show this shawl draped over the shoulders of a plain mannequin, with the border visible."],
      ["Hanging", "Show this shawl hanging straight from a wooden rod against a plain wall, with the whole piece in frame."],
      ["Folded", "Show this shawl neatly folded on a wooden table, with the border along the top edge."]
    ],
    "props": [
      ["Wooden hanger", "Hang this shawl on a wooden hanger against a plain wall, with both ends falling straight."]
    ]
  },
  "Jod kappur": {
    "displays": [
      ["Hanging", "Show both pieces of this jod kappur hanging side by side from a wooden rod against a plain wall, with the tassels visible."],
      ["Folded", "Show both pieces of this jod kappur neatly folded and stacked on a wooden table, with the borders along the edge."]
    ],
    "props": [
      ["Cane stool", "Place both pieces of this jod kappur, neatly folded, on a cane stool."],
      ["Festive setting", "Place both pieces of this jod kappur, neatly folded, on a wooden table with a brass lamp and a few flowers beside them."],
      ["Outdoor courtyard", "Hang both pieces of this jod kappur side by side from a bamboo pole in a bright outdoor courtyard."]
    ]
  },
  "Yardages": {
    "displays": [
      ["Hanging", "Show this fabric hanging straight from a wooden rod against a plain wall, in one long clean length."],
      ["Folded", "Show this fabric neatly folded on a wooden table, with the pattern visible on top."],
      ["Fabric roll", "Show this fabric as a neat roll on a wooden table, with a length unrolled in front."]
    ],
    "props": [
      ["Measuring tape", "Place this fabric, neatly folded, on a wooden table with a measuring tape and scissors beside it."],
      ["Basket", "Place this fabric, neatly folded, in a cane basket on a wooden table."],
      ["Outdoor courtyard", "Hang this fabric from a bamboo pole in a bright outdoor courtyard, with the whole piece in frame."]
    ]
  },
  "Cushion covers": {
    "displays": [
      ["Sofa-Seated", "Show this cushion on a neutral sofa in a bright room, with all four corners visible."],
      ["Flat-Lay", "Show this cushion flat on a plain surface from directly above, with all four corners visible."]
    ],
    "props": [
      ["Sofa", "Show this cushion leaning against the arm of a neutral sofa, with all four corners visible."]
    ]
  }
};

function aiNeedsBothPhotos(goal) {
  return goal === "display" || goal === "props";
}

function aiChoicesFor(product, goal) {
  const scenes = AI_SCENES[product] || { displays: [], props: [] };
  return goal === "display" ? scenes.displays : scenes.props;
}

function buildAiPrompt({ product, goal, scene }) {
  const word = AI_PRODUCT_WORDS[product] || product.toLowerCase();
  const short = word.split(" (")[0];
  if (goal === "clean" || goal === "light") {
    const wish = goal === "clean" ? "Replace only the background with a plain off-white wall." : "Make the light soft and even, and remove harsh shadows. Keep the true colours.";
    return `Edit my photo. ${wish}\n\nDo not change the ${short}: keep the same motifs, border, colours and weave. No text.`;
  }
  const line = aiChoicesFor(product, goal).find(([label]) => label === scene)[1];
  return `Photo 1 shows my handwoven ${word} in full. Photo 2 shows its motif up close.\n\n${line}\n\nCopy the motifs, border, colours and weave exactly from my photos. Do not redesign anything. Realistic photo, soft natural light, no people, no text.`;
}

const AI_GOALS = [
  ["clean", "Clean background", "A plain wall behind your product", '<rect x="4" y="4" width="16" height="16" rx="2"/><path d="M4 16l5-5 4 4 3-3 4 4"/>'],
  ["light", "Better light", "Soft, even light and true colours", '<circle cx="12" cy="12" r="4"/><path d="M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6L7 7M17 17l1.4 1.4M5.6 18.4L7 17M17 7l1.4-1.4"/>'],
  ["display", "New display", null, '<path d="M12 7a2 2 0 1 0-2-2"/><path d="M12 7v2L3 16a1.5 1.5 0 0 0 1 3h16a1.5 1.5 0 0 0 1-3l-9-7"/>'],
  ["props", "Add props", null, '<path d="M6 11V6a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v5"/><path d="M4 11a2 2 0 0 1 2 2v2h12v-2a2 2 0 1 1 2 2v3H4v-3a2 2 0 0 1 0-4z"/><path d="M7 18v2M17 18v2"/>'],
];
const AI_PHOTO_ICON = '<rect x="4" y="5" width="16" height="14" rx="2"/><circle cx="9" cy="10" r="1.5"/><path d="M5 17l5-4 3 2.5 2.5-2L19 16"/>';

function aiSkipsPhotos() {
  return !!state.ai.goal && !aiNeedsBothPhotos(state.ai.goal);
}

function aiCanContinue() {
  const ai = state.ai;
  if (ai.step === 0) return !!ai.product;
  return !!ai.goal && (aiSkipsPhotos() || !!ai.scene);
}

function aiRow({ title, detail, icon, on, act, attrs }) {
  return `<button type="button" class="ai-row ${on ? "on" : ""}" data-act="${act}" ${attrs}>
    <svg class="ai-icon" viewBox="0 0 24 24" aria-hidden="true">${icon}</svg>
    <span class="ai-row-text"><b>${esc(t(title))}</b>${detail ? `<small>${esc(t(detail))}</small>` : ""}</span>
    <span class="ai-mark" aria-hidden="true"></span>
  </button>`;
}

function aiChips(labels, isOn, act) {
  return `<div class="ai-chips">${labels.map((label) =>
    `<button type="button" class="ai-chip ${isOn(label) ? "on" : ""}" data-act="${act}" data-name="${esc(label)}">${esc(t(label))}</button>`,
  ).join("")}</div>`;
}

// New displays and props are made from these two photos, so this stands out
// from everything else on the prompt page.
function aiPhotosNeeded() {
  const rows = AI_NEEDED_PHOTOS.map(([label, detail]) =>
    `<div class="ai-need-row"><svg class="ai-icon" viewBox="0 0 24 24" aria-hidden="true">${AI_PHOTO_ICON}</svg><span><b>${esc(t(label))}</b><small>${esc(t(detail))}</small></span></div>`,
  ).join("");
  return `<div class="ai-need">
    <b class="ai-need-title">${esc(t("You need these 2 photos"))}</b>
    ${rows}
    <p>${esc(t("Without these, the AI has to guess your product."))}</p>
  </div>`;
}

function aiPromptText() {
  return buildAiPrompt(state.ai);
}

function renderAi() {
  const ai = state.ai;
  const head = `<div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t("AI photos").toUpperCase())}</p>
      <span></span>
    </div>`;
  const heading = (title, sub) => `<h1 class="pick-title">${esc(t(title))}</h1><p class="pick-sub">${esc(t(sub))}</p>`;
  const continueFoot = `<div class="foot">${readyBtn("Continue", "ai-next", aiCanContinue())}</div>`;

  if (ai.step === 0) {
    const cards = PRODUCTS.map(([name, , file]) =>
      pickCard({ file, label: name, on: ai.product === name, act: "ai-product", attrs: `data-name="${esc(name)}"` }),
    ).join("");
    return screen(`<div class="pad-20 stack">${head}
      ${heading("Which product is it?", "We write the words for your AI tool")}
      <div class="pick-grid" data-scroll>${cards}</div>
      ${continueFoot}
    </div>`);
  }

  if (ai.step === 1) {
    // What this product can really have, so the card promises nothing else.
    const sample = (goal) => aiChoicesFor(ai.product, goal).slice(0, 3).map((item) => t(item[0])).join(", ");
    const rows = AI_GOALS.map(([key, title, detail, icon]) =>
      aiRow({ title, detail: detail || sample(key), icon, on: ai.goal === key, act: "ai-goal", attrs: `data-name="${key}"` }),
    ).join("");
    const choices = ai.goal && aiNeedsBothPhotos(ai.goal)
      ? `<p class="ai-label">${esc(t(ai.goal === "display" ? "Which display?" : "Which prop?"))}</p>${aiChips(aiChoicesFor(ai.product, ai.goal).map((item) => item[0]), (label) => label === ai.scene, "ai-scene")}`
      : "";
    return screen(`<div class="pad-20 stack">${head}
      ${heading("What do you want?", "Tap one")}
      <div class="ai-body" data-scroll>${rows}${choices}</div>
      ${continueFoot}
    </div>`);
  }

  const steps = ["Open your AI tool", aiSkipsPhotos() ? "Attach your photo" : "Attach the full photo, then the close-up", "Paste the prompt and send"].map((line, index) =>
    `<div class="ai-step"><i>${index + 1}</i><span>${esc(t(line))}</span></div>`,
  ).join("");
  const checks = ["Are the motifs the same?", "Is the colour the same?", "Is the border the same?"].map((line) =>
    `<div class="ai-step"><svg class="ai-icon" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M8 12l3 3 5-6"/></svg><span>${esc(t(line))}</span></div>`,
  ).join("");
  return screen(`<div class="pad-20 stack">${head}
    ${heading("Your prompt", "Copy it and paste it into your AI tool")}
    <div class="ai-body" data-scroll>
      ${aiSkipsPhotos() ? "" : aiPhotosNeeded()}
      <div class="ai-prompt">${esc(aiPromptText())}</div>
      <p class="ai-label">${esc(t("How to use it"))}</p>
      ${steps}
      <p class="ai-label">${esc(t("Check before you post"))}</p>
      ${checks}
      <p class="ai-note strong">${esc(t("If not, do not post it. Try again."))}</p>
      <p class="ai-note">${esc(t("Use your real photo for close-ups. They show your handwork."))}</p>
    </div>
    <div class="foot">
      ${ai.copyFailed ? `<p class="ai-note strong ai-copy-failed">${esc(t("Could not copy. Select the words and copy them."))}</p>` : ""}
      <button class="btn" type="button" data-act="ai-copy">${ai.copied ? "&#10003; " : ""}${esc(t(ai.copied ? "Prompt copied" : "Copy prompt"))}</button>
      <button class="ai-done" type="button" data-act="finish-ai">${esc(t("Done"))}</button>
    </div>
  </div>`);
}

function openAi() {
  state.ai = { step: 0, product: null, goal: null, scene: null };
  push("ai");
}

// Copies while the click is still being handled, which works on any address.
// The newer clipboard call is only the second try: it can fail on some
// addresses, and it could also leave the button doing nothing while it waits.
function aiCopyNow(text) {
  const box = document.createElement("textarea");
  box.value = text;
  box.setAttribute("readonly", "");
  box.style.cssText = "position:fixed;top:0;left:0;opacity:0;font-size:16px;-webkit-user-select:text;user-select:text";
  document.body.appendChild(box);
  box.focus();
  box.select();
  box.setSelectionRange(0, text.length);
  let copied = false;
  try {
    copied = document.execCommand("copy");
  } catch (error) {
    copied = false;
  }
  box.remove();
  return copied;
}

function aiCopyAnswer(ai, worked) {
  if (worked) saveWork({ aiPrompt: buildAiPrompt(ai) });
  ai.copied = worked;
  ai.copyFailed = !worked;
  render({ keepScroll: true });
  if (!worked) {
    // Ready for the artisan to copy by hand.
    const words = document.querySelector(".ai-prompt");
    const range = document.createRange();
    range.selectNodeContents(words);
    const selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    return;
  }
  clearTimeout(aiCopiedTimer);
  aiCopiedTimer = setTimeout(() => {
    ai.copied = false;
    if (state.ai === ai && current().name === "ai") render({ keepScroll: true });
  }, 2500);
}

let aiCopiedTimer;

function aiCopy() {
  const ai = state.ai;
  const text = aiPromptText();
  if (aiCopyNow(text)) return aiCopyAnswer(ai, true);
  if (navigator.clipboard && navigator.clipboard.writeText) {
    const giveUp = new Promise((resolve) => setTimeout(() => resolve(false), 3000));
    Promise.race([navigator.clipboard.writeText(text).then(() => true, () => false), giveUp]).then((worked) => aiCopyAnswer(ai, worked));
    return;
  }
  aiCopyAnswer(ai, false);
}

// Saved work: what the artisan wrote while practising, shown under an earned
// badge along with good bios and captions to copy. Same words as
// lib/features/learn/data/saved_work.dart.
const BIO_IDEAS = [
  "Handwoven in Sualkuchi, Assam · Sarees and mekhela sador · Order on WhatsApp",
  "Weaving by hand since 2010 · Sualkuchi, Assam · Message me to order",
  "Every piece made by hand on my own loom · Assam · Message me to order",
  "Handloom from Assam, woven by me · New pieces every week · Order on WhatsApp",
];
const CAPTION_IDEAS = [
  "Woven by hand in Sualkuchi, Assam. Every motif takes hours on the loom. Message me to order. #handloom #assam",
  "New on my loom. Soft, handwoven and ready to wear. Message me for the price. #handwoven #assam",
  "Made for your special day. Woven by hand, one thread at a time. Order on WhatsApp. #handloom #sualkuchi",
  "Save this post for your next festival. Handwoven in Assam, made by me. #handloom #madeinassam",
];
const WORK_KEY = "cs-work";

function loadWork() {
  try {
    return JSON.parse(localStorage.getItem(WORK_KEY) || "{}") || {};
  } catch (error) {
    return {};
  }
}

function saveWork(fields) {
  state.work = { ...(state.work || {}), ...fields };
  try {
    localStorage.setItem(WORK_KEY, JSON.stringify(state.work));
  } catch (error) {
    // Still shown for this visit, just not kept.
  }
}

function workCard(text, label) {
  const copied = state.workCopied === text;
  return `<div class="work-card">
    ${label ? `<small>${esc(t(label))}</small>` : ""}
    <p class="work-text">${esc(text)}</p>
    <button type="button" class="work-copy ${copied ? "on" : ""}" data-act="work-copy" data-text="${esc(text)}">${copied ? "&#10003; " : ""}${esc(t(copied ? "Copied" : "Copy"))}</button>
  </div>`;
}

function workRow(label, value) {
  return value ? `<small>${esc(t(label))}</small><p class="work-text strong">${esc(value)}</p>` : "";
}

function renderWork(view) {
  const task = taskById(view.id);
  const work = state.work || {};
  const lines = {
    photography: "Sharp photos sell better",
    set_up_page: "You practiced your name, bio, category, and pro page on Instagram.",
    create_post: "You practiced Post, Story, and Reel on Instagram.",
    posting_plan: "People remember you",
    read_numbers: "You can read views, likes, saves and messages.",
    ai_photos: "You can use AI and keep your product the same.",
  };
  const heading = (text) => `<p class="ai-label">${esc(t(text))}</p>`;
  const nothing = `<p class="ai-note">${esc(t("Nothing saved yet."))}</p>`;
  let body = "";
  if (task.id === "set_up_page") {
    const details = workRow("Name", work.name) + workRow("Username", work.username) + workRow("Category", work.category && t(work.category));
    body = heading("Your work")
      + (details ? `<div class="work-card details">${details}</div>` : "")
      + (work.bio ? workCard(work.bio, "Bio") : "")
      + (details || work.bio ? "" : nothing)
      + heading("Bio ideas")
      + BIO_IDEAS.map((idea) => workCard(t(idea))).join("");
  }
  if (task.id === "create_post") {
    body = heading("Your caption")
      + (work.caption ? workCard(work.caption) : nothing)
      + heading("Caption ideas")
      + CAPTION_IDEAS.map((idea) => workCard(t(idea))).join("");
  }
  if (task.id === "ai_photos") {
    body = heading("Your last prompt") + (work.aiPrompt ? workCard(work.aiPrompt) : nothing);
  }
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">${backBtn()}<span></span><span></span></div>
    <div class="scroll work" data-scroll>
      <div class="work-top">
        <div class="medal">${svg.medal}</div>
        <h1>${esc(t(task.title))}</h1>
        <p>${esc(t(lines[task.id] || "Done"))}</p>
      </div>
      ${body}
    </div>
  </div>`);
}

function workCopy(text) {
  const answer = (worked) => {
    if (!worked) return toast(t("Could not copy. Select the words and copy them."));
    state.workCopied = text;
    render({ keepScroll: true });
    clearTimeout(workCopiedTimer);
    workCopiedTimer = setTimeout(() => {
      state.workCopied = null;
      if (current().name === "work") render({ keepScroll: true });
    }, 2500);
  };
  if (aiCopyNow(text)) return answer(true);
  if (navigator.clipboard && navigator.clipboard.writeText) {
    const giveUp = new Promise((resolve) => setTimeout(() => resolve(false), 3000));
    Promise.race([navigator.clipboard.writeText(text).then(() => true, () => false), giveUp]).then(answer);
    return;
  }
  answer(false);
}

let workCopiedTimer;

function renderCaption() {
  const draft = state.captionDraft || "";
  const ideas = CAPTION_IDEAS.map((idea, index) =>
    `<button type="button" class="caption-idea" data-act="caption-idea" data-index="${index}">${esc(t(idea))}</button>`,
  ).join("");
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">${backBtn()}<span></span><span></span></div>
    <h1 class="pick-title">${esc(t("Write your caption"))}</h1>
    <p class="pick-sub">${esc(t("Say what it is and how to order"))}</p>
    <div class="ai-body" data-scroll>
      <textarea id="caption-text" class="caption-box" rows="4">${esc(draft)}</textarea>
      <p class="ai-label">${esc(t("Tap one to use it"))}</p>
      ${ideas}
    </div>
    <div class="foot">${readyBtn("Continue", "caption-next", !!draft.trim())}</div>
  </div>`);
}

state.work = loadWork();

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
      ${task.id === "photography" ? `<div class="task-gap"></div>` : `<div class="task-bars">${bars}</div>`}
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
      <p class="lesson-kicker">${esc(t("TASK 3 OF 6"))}</p>
      <span></span>
    </div>
    <div class="scroll access-scroll">
      <div class="access-frame"><img src="${img(postArt("photo_access_art.jpg"), 900)}" alt="" decoding="async" fetchpriority="high"></div>
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
    ? `<div class="ig-user"><i></i><em></em></div><img class="ig-fabric" src="${img("lessons/read_numbers/post_many_saves.jpg", compact ? 240 : 700)}" alt="" decoding="async"><div class="ig-tabs"><i></i><i></i><i></i><i></i><i></i></div>`
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

function typeThumb(kind) {
  const heart = `<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 18.6s-6.2-3.8-7.8-7.1C2.8 8.8 3.9 6.2 6.5 5.8c1.4-.2 2.7.4 3.5 1.6.8-1.2 2.1-1.8 3.5-1.6 2.6.4 3.7 3 2.3 5.7-1.6 3.3-7.8 7.1-7.8 7.1z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>`;
  const chat = `<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M7 16.2l-1.4 3 3.2-1.4A7.2 7.2 0 1 0 7 16.2z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>`;
  const top = `<div class="mini-top"><span class="mini-plus"></span><i></i><span class="mini-icos">${kind === "post" ? heart + chat : heart}</span></div>`;
  const stories = `<div class="mini-stories"><b></b><i></i><i></i><i></i></div>`;
  const body = kind === "post"
    ? `<div class="mini-user"><i></i><em></em></div><img src="${img("lessons/read_numbers/post_many_saves.jpg")}" alt=""><div class="mini-tabs"><i></i><i></i><i></i><i></i><i></i></div>`
    : `<div class="mini-sheet">${["post", "story", "reel"].map((id) => {
        const on = id === kind;
        return `<div class="mini-row ${on ? "on" : ""}">${typeIcon(id)}<b>${esc(t(CREATE_GUIDE[id].title))}</b>${on ? "<em>1</em>" : ""}</div>`;
      }).join("")}</div>`;
  return `<div class="type-thumb" aria-hidden="true"><div class="mini ${kind}">${top}${stories}${body}</div></div>`;
}

function renderCreateTypes() {
  if (createAllDone()) {
    CREATE_KINDS.forEach((id) => {
      delete state.progress[partKey("create_post", id)];
    });
    saveProgress();
  }
  const next = nextCreateKind() || "post";
  const cards = CREATE_KINDS.map((id) => {
    const guide = CREATE_GUIDE[id];
    const done = isPartDone("create_post", id);
    const selected = id === next;
    const enabled = selected;
    return `<button type="button" class="type-card ${done ? "done" : ""} ${selected ? "on" : ""}" data-act="pick-kind" data-kind="${id}" ${enabled ? "" : "disabled"}>
      ${typeThumb(id)}
      <span class="type-copy">${typeIcon(id)}<b>${esc(t(guide.title))}</b><small>${esc(t(guide.detail))}</small></span>
      ${done ? `<svg class="type-mark" width="26" height="26" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="10" fill="#1B7574"/><path d="M7.2 12.3l3.1 3.1 6.5-6.8" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round"/></svg>` : selected ? `<span class="radio on"></span>` : ""}
    </button>`;
  }).join("");
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t("TASK 3 OF 6"))}</p>
      <span></span>
    </div>
    <div class="scroll">
      <h1 class="access-title left">${esc(t("What do you want to make?"))}</h1>
      <p class="access-body left">${esc(t("Do Post first, then Story, then Reel. Tap Continue for each one."))}</p>
      <div class="type-list">${cards}</div>
    </div>
    <div class="foot">${readyBtn("Continue", "types-continue", true)}</div>
  </div>`);
}

function renderIgPost(view) {
  const guide = CREATE_GUIDE[view.kind];
  const steps = guide.steps
    .map((step, index) => {
      const current = index === state.createStep;
      return `<div class="ig-step ${current ? "on" : ""}" ${current ? 'data-act="ig-step" data-index="' + index + '"' : ""}><span>${index + 1}</span><b>${esc(t(step))}</b></div>`;
    })
    .join("");
  const doodle = state.createStep === 0 ? `<img class="doodle" src="${img(postArt("click_here_doodle.png"))}" alt="">` : "";
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t(guide.header))}</p>
      <span></span>
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
    return `<button type="button" class="gal-cell ${on ? "on" : ""}" data-act="pick-photo" data-index="${index}"><img src="${img(file, 320)}" alt="" loading="lazy" decoding="async" fetchpriority="low">${mini}</button>`;
  }).join("");
  return screen(`<div class="gal">
    <div class="gal-head">
      <button class="icon-btn" type="button" data-act="back" aria-label="${esc(t("Back"))}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 6l12 12M18 6L6 18"/></svg></button>
      <b>${esc(t(guide.pickHeader))}</b>
      <button type="button" class="gal-next ${picked == null ? "wait" : ""}" data-act="pick-next" ${picked == null ? "disabled" : ""}>${esc(t("Next"))}</button>
    </div>
    <div class="gal-preview"><img src="${img(preview, 900)}" alt="" decoding="async" fetchpriority="high">${play}</div>
    <div class="gal-grid">${cells}</div>
    <article class="gal-card">
      <div class="gal-card-top">
        <span class="gem"></span>
        <span class="copy"><small>${esc(t(guide.pickStep))}</small><b>${esc(t(guide.pickTitle))}</b></span>
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
      <div class="did-photo"><img src="${img(file, 900)}" alt="" decoding="async" fetchpriority="high">${play}</div>
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
      <span></span>
    </div>
    <div class="lesson-bars"><i></i><i class="off"></i></div>
    <div class="lesson-stage">
      <div class="lesson-frame"><img src="${img(part.image, 900)}" alt="" decoding="async" fetchpriority="high"></div>
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
      <span></span>
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
      <img class="lesson-art" src="${img(part.image, 900)}" alt="" decoding="async" fetchpriority="high">
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
      <span></span>
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
  const earnedNext = nextTask(taskById(current().task));
  const earned = state.earned
    ? `<div class="earn">
        <article class="earn-card">
          <div class="earn-medal">${svg.medal}</div>
          <p>${esc(t("Badge earned"))}</p>
          <h2>${esc(t("Read the numbers"))}</h2>
          <small>${esc(t("You can read views, likes, saves and messages."))}</small>
          ${earnedNext
            ? `<button class="btn" data-act="next-task" data-id="${earnedNext.id}">${esc(t("Next task: " + earnedNext.title))}</button>
          <button class="ai-done" type="button" data-act="home">${esc(t("Go to home"))}</button>`
            : `<button class="btn" data-act="leave-find">${esc(t("Continue"))}</button>`}
        </article>
      </div>`
    : "";
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t("TASK 5 · 2 OF 2"))}</p>
      <span></span>
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
  const nextLabel = checkNextLabel(task, part);
  const next = revealed
    ? btn(nextLabel, "after-check")
    : `<button class="btn wait" type="button" disabled>${esc(t(nextLabel))}</button>`;
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t(part.label))}</p>
      <span></span>
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
    head = `<p class="try-kicker">${esc(t("Set up your page"))}</p>
      <h1 class="try-title">${esc(t("Pick your name"))}</h1>
      <p class="try-sub">${esc(t("Short. Easy to say."))}</p>`;
    body = namePicker();
  } else if (step === 1) {
    head = `<span class="practice-pill">${esc(t("PRACTICE · LIKE INSTAGRAM"))}</span>
      <h1 class="try-title">${esc(t("Set up your page"))}</h1>`;
    body = profileStep();
  } else if (step === 2) {
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
    const handle = (state.tryUsername || state.tryName || "divya.weaves").replace(/^@/, "");
    const person = state.tryDisplayName || "Divya Warule";
    const bio = state.tryBio == null ? t("Handwoven cloth · Sualkuchi, Assam") : state.tryBio;
    const photo = state.tryPhoto || img(setup("profile_clear.jpg"));
    head = `<p class="try-lead">${esc(t("Set up your page"))}</p>
      <h1 class="try-title">${esc(t("Your Pro page"))}</h1>`;
    body = `<article class="pro-card">
      <div class="pro-top">
        <img src="${photo}" alt="">
        <div class="ig-stats pro-stats">
          <span><b>0</b><small>${esc(t("posts"))}</small></span>
          <span><b>12</b><small>${esc(t("followers"))}</small></span>
          <span><b>30</b><small>${esc(t("following"))}</small></span>
        </div>
      </div>
      <p class="pro-name">${esc(person)} <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.6 12.2l2.8 2.8 6-6.2" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></p>
      <p class="pro-cat">${esc(t(state.tryCategory))}</p>
      <p class="pro-bio">${esc(bio)}</p>
      <div class="pro-actions"><i>${esc(t("Edit page"))}</i><i>${esc(t("Share page"))}</i><i>${esc(t("Contact"))}</i></div>
    </article>
    <article class="done-card">
      <p>${esc(t("ALL DONE"))}</p>
      <div><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.6 12.2l2.8 2.8 6-6.2" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg><span>${esc(t("Name @" + handle))}</span></div>
      <div><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.6 12.2l2.8 2.8 6-6.2" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg><span>${esc(t(state.tryCategory))}</span></div>
      <div><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.6 12.2l2.8 2.8 6-6.2" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg><span>${esc(t("Contact button"))}</span></div>
    </article>`;
  }
  const appStep = [0, 1, 3, 4][step] || 0;
  const bars = Array.from({ length: 5 }, (_, index) => `<i class="${index <= appStep ? "on" : ""}"></i>`).join("");
  const next = step < 3 ? nextChevron("Next", "try-next") : btn("Done", "try-next");
  const label = "TASK 2 · " + (appStep + 1) + " OF 5";
  return screen(`<div class="pad-20 stack">
    <div class="lesson-head">
      ${backBtn()}
      <p class="lesson-kicker">${esc(t(label))}</p>
      <span></span>
    </div>
    <div class="task-bars">${bars}</div>
    ${head}
    <div class="scroll try-scroll">${body}</div>
    <div class="foot">${next}</div>
  </div>${ownDialog()}`);
}

function nextChevron(label, act) {
  return `<button class="btn" data-act="${act}"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M9 6.5l6 5.5-6 5.5" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>${esc(t(label))}</button>`;
}

function profileBio() {
  return state.tryBio == null ? t("Handwoven cloth · Sualkuchi, Assam") : state.tryBio;
}

function profileStep() {
  const photo = state.tryPhoto || img(setup("profile_clear.jpg"));
  const name = state.tryDisplayName || "Divya Warule";
  const user = state.tryUsername || state.tryCustom || state.tryHandle || "divya.weaves";
  const chips = ["Muga silk", "Order on WhatsApp", "Since 2010"]
    .map(
      (tag) =>
        `<button class="bio-chip" type="button" data-act="bio-tag" data-tag="${esc(tag)}">+ ${esc(t(tag))}</button>`,
    )
    .join("");
  return `<div class="photo-row">
      <img src="${photo}" alt="">
      <div>
        <b>${esc(t("Your photo"))}</b>
        <button type="button" data-act="change-photo">${esc(t("Change photo"))}</button>
      </div>
    </div>
    <input id="try-photo" type="file" accept="image/*" hidden>
    <div class="field plain"><label>${esc(t("Name"))}</label><div class="box"><input id="try-display" value="${esc(name)}"></div></div>
    <div class="field plain"><label>${esc(t("Username"))}</label><div class="box"><input id="try-user" value="${esc(user)}"></div></div>
    <div class="field plain"><label>${esc(t("Bio"))}</label><div class="box"><textarea id="try-bio" rows="3">${esc(profileBio())}</textarea></div></div>
    <p class="bio-hint">${esc(t("Tap to add to bio"))}</p>
    <div class="bio-chips">${chips}</div>`;
}

function nameMark(on) {
  return on
    ? `<svg width="26" height="26" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="9" fill="#1B7574"/><path d="M7.5 12.2l3 3 6-6.2" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>`
    : `<svg width="26" height="26" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="8.2" stroke="#B8C5C2" stroke-width="1.8"/></svg>`;
}

function nameCard(handle, best, selected, keep) {
  const pick = keep ? "" : `data-act="try-handle" data-handle="${esc(handle)}"`;
  return `<button class="name-card ${selected ? "on" : ""}" type="button" ${pick}>
    <span>@${esc(handle)}</span>
    ${best ? `<i>${esc(t("Best"))}</i>` : ""}
    <b>${nameMark(selected)}</b>
  </button>`;
}

function namePicker() {
  const names = [
    ["divya.weaves", true],
    ["divya_mekhela", false],
    ["sualkuchi.divya", false],
    ["divya.handloom", false],
    ["weaves.by.divya", false],
  ];
  const custom = state.tryCustom;
  const chosen = custom || state.tryHandle;
  const extra = custom ? nameCard(custom, false, true, true) : "";
  const cards = names
    .map(([handle, best]) => nameCard(handle, best, !custom && chosen === handle))
    .join("");
  return `<div class="name-list">${extra}${cards}</div>
    <button class="name-own" type="button" data-act="try-own"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 16.8V20h3.2L18.4 8.8l-3.2-3.2L4 16.8z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><path d="M13.8 7l3.2 3.2" stroke="currentColor" stroke-width="1.7"/></svg>${esc(t("Type my own"))}</button>`;
}

function ownDialog() {
  if (!state.tryOwn) return "";
  const value = state.tryCustom || state.tryHandle || "";
  return `<div class="own-shade">
    <form class="own-card">
      <h2>${esc(t("Your handle"))}</h2>
      <label class="own-field"><span>@</span><input id="try-own" value="${esc(value)}" placeholder="divya.weaves"></label>
      <div class="own-actions">
        <button type="button" data-act="own-cancel">${esc(t("Cancel"))}</button>
        <button type="button" data-act="own-save">${esc(t("Save"))}</button>
      </div>
    </form>
  </div>`;
}

function renderDisplays(view) {
  const product = PRODUCTS.find((item) => item[0] === view.product);
  const whole = WHOLE_PHOTOS.has(view.product);
  const ids = displaysFor(view.product);
  const cards = ids
    .map((id) => {
      const [name, key] = DISPLAYS[id];
      // Hanging masters are taller (often 2:3) than the 3:4 card; cover crops the cloth.
      // Show them whole so the full piece stays in frame.
      return pickCard({
        file: displayImage(view.product, product[1], key),
        label: name,
        tall: true,
        whole: whole || id === "hanging",
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
      <span></span>
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
    <img src="${img(file, 240)}" alt="" loading="lazy" decoding="async">
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
      <img class="lesson-art" src="${img(view.file, 900)}" alt="" decoding="async" fetchpriority="high">
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
    ai_photos: "You can use AI and keep your product the same.",
  };
  const action = upcoming
    ? `<button class="btn" data-act="next-task" data-id="${upcoming.id}">${esc(t("Next task: " + upcoming.title))}</button>
       <button class="ai-done" type="button" data-act="home">${esc(t("Go to home"))}</button>`
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
  const langCode = code();
  document.body.dataset.lang = langCode;
  const locale = (LANGS.find((item) => item.id === langCode) || LANGS[0]).locale;
  document.documentElement.lang = locale.split("-")[0];
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
    ai: renderAi,
    work: () => renderWork(view),
    caption: renderCaption,
    "create-types": renderCreateTypes,
    "ig-post": () => renderIgPost(view),
    "pick-media": () => renderPickMedia(view),
    "did-post": () => renderDidPost(view),
    displays: () => renderDisplays(view),
    shots: () => renderShots(view),
    guide: () => renderShootGuide(view),
    camera: () => renderCamera(view),
    edit: () => renderEdit(view),
    shot: () => renderShot(view),
    badge: () => renderBadge(view),
  }[view.name];
  stopCamera();
  const keep = options && options.keepScroll;
  const previous = keep ? document.querySelector("[data-scroll]") : null;
  const top = previous ? previous.scrollTop : 0;
  document.getElementById("app").innerHTML = html();
  const scroller = document.querySelector("[data-scroll]") || document.querySelector(".scroll");
  if (scroller) scroller.scrollTop = keep ? top : 0;
  tuneImages();
  bindScrollCue();
  mountCamera();
  bindEdit();
  fitGuidePhoto();
}

function tuneImages() {
  const root = document.getElementById("app");
  if (!root) return;
  const imgs = [...root.querySelectorAll("img")];
  imgs.forEach((el, index) => {
    if (!el.getAttribute("decoding")) el.decoding = "async";
    const hero =
      el.classList.contains("hero-art") ||
      el.classList.contains("lesson-art") ||
      el.classList.contains("edit-photo") ||
      el.classList.contains("cam-art") ||
      el.closest(".guide-example") ||
      el.closest(".lesson-frame") ||
      el.closest(".access-frame") ||
      el.closest(".gal-preview") ||
      el.closest(".did-photo");
    if (hero || index < 2) {
      el.loading = "eager";
      el.fetchPriority = "high";
    } else if (!el.getAttribute("loading")) {
      el.loading = "lazy";
      el.fetchPriority = "low";
    }
    if (!el.dataset.fallbackBound) {
      el.dataset.fallbackBound = "1";
      el.addEventListener("error", () => {
        const src = el.currentSrc || el.src || "";
        if (!src.includes("/.netlify/images")) return;
        try {
          const url = new URL(src, location.href).searchParams.get("url");
          if (url) el.src = url;
        } catch (_) {}
      });
    }
  });
}

function fitGuidePhoto() {
  const box = document.querySelector(".guide-example");
  const photo = box && (box.querySelector("img.sharp") || box.querySelector("img"));
  if (!photo) return;
  const apply = () => {
    if (!photo.naturalWidth || !photo.naturalHeight) return;
    box.style.setProperty("--photo", String(photo.naturalWidth / photo.naturalHeight));
  };
  if (photo.complete) apply();
  else photo.addEventListener("load", apply, { once: true });
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

let cameraStream = null;
let lightTimer = null;
const lightSample = document.createElement("canvas");
lightSample.width = 24;
lightSample.height = 24;
const lightGrainSample = document.createElement("canvas");
lightGrainSample.width = 64;
lightGrainSample.height = 64;
const LIGHT_WINDOW = 6; // Readings judged together: 3 seconds.
const LIGHT_FIRST_READINGS = 2; // First label after about 1 second.
const LIGHT_HOLD = 3; // A new level must last this long to show: 1.5 seconds.
let lightHistory = [];
let lightLastPixels = null;
let lightPending = null;
let lightPendingCount = 0;
let lightFrames = 0;
let lightFrameStart = 0;
let lightLastFrameShare = 0;
let lightCanCountFrames = false;

const LIGHT_COPY = {
  as: { "Checking the light": "পোহৰ চালি আছে", "Too dark": "বৰ আন্ধাৰ", Medium: "মজলীয়া", Perfect: "একেবাৰে ঠিক" },
  or: { "Checking the light": "ଆଲୋକ ଦେଖୁଛି", "Too dark": "ବହୁତ ଅନ୍ଧାର", Medium: "ମଧ୍ୟମ", Perfect: "ଠିକ୍ ଅଛି" },
  te: { "Checking the light": "వెలుగు చూస్తోంది", "Too dark": "చాలా చీకటి", Medium: "మధ్యస్థం", Perfect: "బాగుంది" },
};
if (window.I18N) {
  Object.keys(LIGHT_COPY).forEach((lang) => {
    window.I18N[lang] = Object.assign({}, window.I18N[lang], LIGHT_COPY[lang]);
  });
}

function stopCamera() {
  clearInterval(lightTimer);
  lightTimer = null;
  if (!cameraStream) return;
  cameraStream.getTracks().forEach((track) => track.stop());
  cameraStream = null;
}

// Judge the cloth in the middle of the frame. A phone preview is auto-exposed,
// so a truly dark room still looks dark after it has been lifted a little.
function clothTone(p50, p95, prev) {
  if (prev === "dark") {
    if (p50 < 52 && p95 < 118) return "dark";
  } else if (p50 < 38 && p95 < 92) return "dark";
  if (prev === "good") {
    if (p50 >= 78 && p95 >= 148) return "good";
  } else if (p50 >= 92 && p95 >= 168) return "good";
  return "medium";
}

// Browsers report exposure in seconds, milliseconds, Android 100µs steps, or
// nanoseconds. Fold those into seconds.
function exposureSeconds(value) {
  if (!(value > 0)) return 0;
  if (value > 1e5) return value / 1e9;
  if (value > 30) return value / 1e4;
  if (value > 1) return value / 1e3;
  return value;
}

// Extra signs that the camera is struggling. These may lower Perfect to
// Medium, or Medium to Too dark, but only when the signal is clearly dim.
function lightStrain({ exposure, iso, fps, grain }) {
  const seconds = exposureSeconds(exposure);
  const effort = seconds > 0 && iso > 0 ? seconds * iso : 0;
  const dark = (effort >= 40) || (fps > 0 && fps < 8) || grain >= 10;
  const medium = (effort >= 14) || (fps > 0 && fps < 16) || grain >= 5;
  if (dark) return "dark";
  if (medium) return "medium";
  return null;
}

function worseLight(a, b) {
  if (!a) return b;
  if (!b) return a;
  const order = ["dark", "medium", "good"];
  return order[Math.min(order.indexOf(a), order.indexOf(b))];
}

function lightIcon(kind) {
  const box = `width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true"`;
  if (kind === "dark") return `<svg ${box}><path d="M15.4 3.4a7.6 7.6 0 1 0 5.2 12.4A6.3 6.3 0 0 1 15.4 3.4z" fill="currentColor"/></svg>`;
  const rays = kind === "medium"
    ? `M12 3.2v2.2M12 18.6V20.8M3.2 12h2.2M18.6 12h2.2`
    : `M12 2.4v2.3M12 19.3v2.3M2.4 12h2.3M19.3 12h2.3M5 5l1.7 1.7M17.3 17.3 19 19M19 5l-1.7 1.7M6.7 17.3 5 19`;
  const face = kind === "wait"
    ? `<circle cx="12" cy="12" r="3.6" stroke="currentColor" stroke-width="1.8"/>`
    : `<circle cx="12" cy="12" r="3.6" fill="currentColor"/>`;
  return `<svg ${box}>${face}<path d="${rays}" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>`;
}

// Single readings jump about, so the label goes by the last few seconds, and
// only changes once the new level has lasted a few seconds too.
function paintLight(reading, facts) {
  const pill = document.querySelector(".cam-light");
  if (!pill || !Number.isFinite(reading.p50)) return;
  lightHistory.push({ p50: reading.p50, p95: reading.p95, grain: facts.grain });
  if (lightHistory.length > LIGHT_WINDOW) lightHistory.shift();
  if (lightHistory.length < LIGHT_FIRST_READINGS) return;

  const p50 = lightHistory.reduce((sum, item) => sum + item.p50, 0) / lightHistory.length;
  const p95 = lightHistory.reduce((sum, item) => sum + item.p95, 0) / lightHistory.length;
  const grains = lightHistory.map((item) => item.grain).filter((grain) => grain >= 0).sort((a, b) => a - b);
  const grain = grains.length ? grains[Math.floor(grains.length / 2)] : -1;
  const shown = pill.dataset.level;
  const wanted = worseLight(clothTone(p50, p95, shown), lightStrain({ ...facts, grain }));

  if (shown) {
    if (wanted === shown) {
      lightPending = null;
      lightPendingCount = 0;
      return;
    }
    lightPendingCount = wanted === lightPending ? lightPendingCount + 1 : 1;
    lightPending = wanted;
    if (lightPendingCount < LIGHT_HOLD) return;
    lightPending = null;
    lightPendingCount = 0;
  }
  pill.dataset.level = wanted;
  pill.className = "cam-light " + wanted;
  const label = wanted === "dark" ? "Too dark" : wanted === "medium" ? "Medium" : "Perfect";
  pill.innerHTML = `${lightIcon(wanted)}<span>${esc(t(label))}</span>`;
}

// The middle of the picture at full detail: squeezing it down would smooth the
// grain away. The middle value is used, so someone moving does not count.
function readGrain(video) {
  const size = 64;
  const ctx = lightGrainSample.getContext("2d", { willReadFrequently: true });
  ctx.drawImage(video, (video.videoWidth - size) / 2, (video.videoHeight - size) / 2, size, size, 0, 0, size, size);
  const data = ctx.getImageData(0, 0, size, size).data;
  const now = new Float32Array(size * size);
  for (let i = 0; i < now.length; i += 1) {
    now[i] = data[i * 4] * 0.2126 + data[i * 4 + 1] * 0.7152 + data[i * 4 + 2] * 0.0722;
  }
  const before = lightLastPixels;
  lightLastPixels = now;
  if (!before) return -1;
  const changes = new Float32Array(now.length);
  for (let i = 0; i < now.length; i += 1) changes[i] = Math.abs(now[i] - before[i]);
  changes.sort();
  return changes[Math.floor(changes.length / 2)];
}

// Frames actually delivered per second. A dark room slows the preview well
// below 30 even when the camera reports its usual rate.
function readFrameRate(settings) {
  const now = performance.now();
  const seconds = (now - lightFrameStart) / 1000;
  let counted = 0;
  if (lightCanCountFrames && seconds >= 2 && !document.hidden) {
    counted = lightFrames / seconds;
    lightFrames = 0;
    lightFrameStart = now;
  }
  const reported = Number(settings.frameRate) || 0;
  if (counted > 0) return counted;
  if (reported > 0 && reported < 24) return reported;
  return 0;
}

function readSceneLight(video) {
  if (!video.videoWidth || video.readyState < 2) return;
  try {
    const ctx = lightSample.getContext("2d", { willReadFrequently: true });
    // Native pixels from the middle of the cloth. Scaling the frame down
    // would hide noise and make a dim scene look evenly bright.
    const size = Math.min(96, video.videoWidth, video.videoHeight);
    lightSample.width = size;
    lightSample.height = size;
    ctx.drawImage(video, (video.videoWidth - size) / 2, (video.videoHeight - size) / 2, size, size, 0, 0, size, size);
    const data = ctx.getImageData(0, 0, size, size).data;
    const pixels = data.length / 4;
    const lumas = new Float32Array(pixels);
    for (let i = 0; i < pixels; i += 1) {
      const o = i * 4;
      lumas[i] = data[o] * 0.2126 + data[o + 1] * 0.7152 + data[o + 2] * 0.0722;
    }
    const sorted = Array.from(lumas).sort((a, b) => a - b);
    const p50 = sorted[Math.floor((sorted.length - 1) * 0.5)];
    const p95 = sorted[Math.floor((sorted.length - 1) * 0.95)];
    const track = cameraStream && cameraStream.getVideoTracks()[0];
    const settings = (track && track.getSettings && track.getSettings()) || {};
    refreshLightSensor(track);
    const fps = readFrameRate(settings);
    if (fps > 0) lightLastFrameShare = fps;
    paintLight({ p50, p95 }, {
      exposure: settings.exposureTime || lightSensor.exposure || 0,
      iso: settings.iso || lightSensor.iso || 0,
      fps: lightLastFrameShare,
      grain: readGrain(video),
    });
  } catch (_) {}
}

const lightSensor = { exposure: 0, iso: 0, track: null, capture: null, pending: false };

function refreshLightSensor(track) {
  if (!track || !window.ImageCapture || lightSensor.pending) return;
  lightSensor.pending = true;
  try {
    if (lightSensor.track !== track) {
      lightSensor.capture = new ImageCapture(track);
      lightSensor.track = track;
    }
    lightSensor.capture.getPhotoSettings().then((photo) => {
      if (photo) {
        if (photo.exposureTime > 0) lightSensor.exposure = photo.exposureTime;
        if (photo.iso > 0) lightSensor.iso = photo.iso;
      }
    }).catch(() => {}).finally(() => {
      lightSensor.pending = false;
    });
  } catch (_) {
    lightSensor.pending = false;
  }
}

function startLightMeter(video) {
  clearInterval(lightTimer);
  lightHistory = [];
  lightLastPixels = null;
  lightPending = null;
  lightPendingCount = 0;
  lightFrames = 0;
  lightFrameStart = performance.now();
  lightLastFrameShare = 0;
  lightSensor.exposure = 0;
  lightSensor.iso = 0;
  lightSensor.track = null;
  lightSensor.capture = null;
  lightCanCountFrames = typeof video.requestVideoFrameCallback === "function";
  if (lightCanCountFrames) {
    const countFrame = () => {
      if (!document.body.contains(video)) return;
      lightFrames += 1;
      video.requestVideoFrameCallback(countFrame);
    };
    video.requestVideoFrameCallback(countFrame);
  }
  lightTimer = setInterval(() => {
    if (!document.body.contains(video)) {
      clearInterval(lightTimer);
      lightTimer = null;
      return;
    }
    readSceneLight(video);
  }, 500);
}

function mountCamera() {
  const video = document.querySelector(".cam-video");
  if (!video || cameraStream) return;
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    state.cameraProblem = "No camera found on this device.";
    render();
    return;
  }
  navigator.mediaDevices
    .getUserMedia({ audio: false, video: { facingMode: { ideal: "environment" } } })
    .then((stream) => {
      if (!document.body.contains(video)) {
        stream.getTracks().forEach((track) => track.stop());
        return;
      }
      cameraStream = stream;
      video.srcObject = stream;
      startLightMeter(video);
      return video.play();
    })
    .catch(() => {
      if (current().name !== "camera") return;
      state.cameraProblem = "The camera could not be opened. Allow camera access, then try again.";
      render();
    });
}

function openEditor(url) {
  state.photoUrl = url;
  resetEdit();
  const probe = new Image();
  probe.onload = () => {
    state.photoAspect = probe.naturalWidth / probe.naturalHeight || 0.75;
    if (current().name === "edit") paintEdit();
  };
  probe.src = url;
  push("edit");
}

function captureFrame() {
  const video = document.querySelector(".cam-video");
  if (!video || !video.videoWidth) {
    const input = document.getElementById("cam-file");
    if (input) input.click();
    return;
  }
  const vw = video.videoWidth;
  const vh = video.videoHeight;
  const target = 3 / 4;
  let sx = 0;
  let sy = 0;
  let sw = vw;
  let sh = vh;
  if (vw / vh > target) {
    sw = vh * target;
    sx = (vw - sw) / 2;
  } else {
    sh = vw / target;
    sy = (vh - sh) / 2;
  }
  const canvas = document.createElement("canvas");
  canvas.width = Math.max(1, Math.round(sw));
  canvas.height = Math.max(1, Math.round(sh));
  canvas.getContext("2d").drawImage(video, sx, sy, sw, sh, 0, 0, canvas.width, canvas.height);
  openEditor(canvas.toDataURL("image/jpeg", 0.92));
}

function applyEditSlide(value) {
  if (state.editTool === "turn") {
    const turns = Math.round(value * 3) % 4;
    if (turns !== state.editTurns) state.editCrop = [0, 0, 1, 1];
    state.editTurns = turns;
    return;
  }
  if (state.editTool === "white") {
    state.editWhite = value * 2 - 1;
    return;
  }
  if (state.editTool === "bright") state.editBright = value * 0.8 - 0.35;
}

function paintEdit() {
  const photo = document.querySelector(".edit-photo");
  const photoBox = document.querySelector(".edit-photo-box");
  const stage = document.querySelector(".edit-stage");
  if (stage) stage.style.cssText = stageStyle();
  if (!photo || !photoBox) return;
  const [l, t, r, b] = state.editCrop;
  photoBox.style.cssText = photoBoxStyle();
  photo.style.cssText = photoStyle();
  const box = document.querySelector(".crop-box");
  if (box) {
    box.style.left = `${l * 100}%`;
    box.style.top = `${t * 100}%`;
    box.style.width = `${(r - l) * 100}%`;
    box.style.height = `${(b - t) * 100}%`;
  }
}

function bindEdit() {
  const box = document.querySelector(".crop-box");
  if (!box || box.dataset.bound) return;
  box.dataset.bound = "1";
  let drag = null;
  box.addEventListener("pointerdown", (event) => {
    drag = {
      mode: event.target.dataset.handle || "move",
      x: event.clientX,
      y: event.clientY,
      crop: state.editCrop.slice(),
    };
    box.setPointerCapture(event.pointerId);
  });
  box.addEventListener("pointermove", (event) => {
    if (!drag) return;
    const rect = box.parentElement.getBoundingClientRect();
    const dx = (event.clientX - drag.x) / rect.width;
    const dy = (event.clientY - drag.y) / rect.height;
    let [l, t, r, b] = drag.crop;
    const min = 0.25;
    if (drag.mode === "move") {
      const w = r - l;
      const h = b - t;
      l = Math.max(0, Math.min(1 - w, l + dx));
      t = Math.max(0, Math.min(1 - h, t + dy));
      state.editCrop = [l, t, l + w, t + h];
    } else {
      if (drag.mode.indexOf("w") >= 0) l = Math.min(r - min, Math.max(0, l + dx));
      if (drag.mode.indexOf("e") >= 0) r = Math.max(l + min, Math.min(1, r + dx));
      if (drag.mode.indexOf("n") >= 0) t = Math.min(b - min, Math.max(0, t + dy));
      if (drag.mode.indexOf("s") >= 0) b = Math.max(t + min, Math.min(1, b + dy));
      state.editCrop = [l, t, r, b];
    }
    paintEdit();
  });
  box.addEventListener("pointerup", () => {
    drag = null;
  });
}

function finishKeptShot(message) {
  const keep = [];
  for (const view of state.stack) {
    if (view.name === "guide" || view.name === "camera" || view.name === "edit") break;
    keep.push(view);
  }
  state.stack = keep.length ? keep : [{ name: "main" }];
  if (state.shotQueue.length > 1 && state.shotChosen) {
    if (state.shotDone.indexOf(state.shotChosen) < 0) state.shotDone.push(state.shotChosen);
    const left = state.shotQueue.filter((id) => state.shotDone.indexOf(id) < 0);
    state.shotChosen = left[0] || null;
  }
  state.photoUrl = "";
  toast(t(message || "Photo downloaded"));
}

function downloadPhotoBlob(blob, name) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = name;
  link.rel = "noopener";
  document.body.appendChild(link);
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 2500);
}

async function savePhotoBlob(blob) {
  const name = "click-social-photo-" + Date.now() + ".jpg";
  const file = new File([blob], name, { type: "image/jpeg" });
  const phone = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent || "");
  if (phone && navigator.canShare && navigator.canShare({ files: [file] })) {
    try {
      await navigator.share({ files: [file], title: "Click & Social" });
      return "Saved to your gallery";
    } catch (err) {
      if (err && err.name === "AbortError") return null;
    }
  }
  downloadPhotoBlob(blob, name);
  return phone ? "Saved to your gallery" : "Photo downloaded";
}

function saveEdit() {
  const photo = new Image();
  photo.onload = () => {
    const [shownL, shownT, shownR, shownB] = state.editCrop;
    const turns = state.editTurns % 4;
    // The cut is marked on the picture as shown; find it on the original.
    const [l, topCrop, r, b] = [
      [shownL, shownT, shownR, shownB],
      [shownT, 1 - shownR, shownB, 1 - shownL],
      [1 - shownR, 1 - shownB, 1 - shownL, 1 - shownT],
      [1 - shownB, shownL, 1 - shownT, shownR],
    ][turns];
    const sw = photo.naturalWidth * (r - l);
    const sh = photo.naturalHeight * (b - topCrop);
    const canvas = document.createElement("canvas");
    canvas.width = Math.max(1, Math.round(turns % 2 ? sh : sw));
    canvas.height = Math.max(1, Math.round(turns % 2 ? sw : sh));
    const ctx = canvas.getContext("2d");
    ctx.filter = editFilter();
    ctx.translate(canvas.width / 2, canvas.height / 2);
    ctx.rotate((turns * Math.PI) / 2);
    ctx.drawImage(
      photo,
      l * photo.naturalWidth,
      topCrop * photo.naturalHeight,
      sw,
      sh,
      -sw / 2,
      -sh / 2,
      sw,
      sh,
    );
    canvas.toBlob(async (blob) => {
      if (!blob) return;
      const message = await savePhotoBlob(blob);
      if (message == null) return;
      finishKeptShot(message);
    }, "image/jpeg", 0.92);
  };
  photo.src = state.photoUrl;
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

function checkNextLabel(task, part) {
  if (part.then === "tryit") return "Next";
  const visible = listedParts(task);
  const index = visible.findIndex((item) => item.id === part.id);
  const following = index >= 0 ? visible[index + 1] : null;
  if (following) return "Next part · " + following.title;
  // The badge page that follows offers the next task and the way home.
  return "Finish";
}

function afterCheck() {
  const view = current();
  const task = taskById(view.task);
  const part = partById(task, view.part);
  markPart(task.id, part.id);
  if (part.then === "tryit") {
    state.tryStep = 0;
    state.tryHandle = "divya.weaves";
    state.tryCustom = "";
    state.tryOwn = false;
    state.tryDisplayName = "Divya Warule";
    state.tryUsername = "";
    state.tryBio = null;
    state.tryPhoto = "";
    push("tryit", { task: task.id, part: "4" });
    return;
  }
  const visible = listedParts(task);
  const index = visible.findIndex((item) => item.id === part.id);
  const following = index >= 0 ? visible[index + 1] : null;
  if (following) {
    state.stack = [
      { name: "main" },
      { name: "task", id: task.id },
      { name: "lesson", task: task.id, part: following.id },
    ];
    render();
    return;
  }
  task.parts.forEach((item) => markPart(task.id, item.id));
  showBadge(task.id);
}

document.getElementById("phone").addEventListener("input", (event) => {
  if (event.target.dataset.act !== "edit-slide") return;
  applyEditSlide(Number(event.target.value));
  paintEdit();
  const hint = document.querySelector(".edit-hint");
  if (hint) hint.textContent = t(editHint());
});

document.getElementById("phone").addEventListener("change", (event) => {
  const input = event.target;
  if (input.id === "try-photo" && input.files && input.files[0]) {
    if (state.tryPhoto.indexOf("blob:") === 0) URL.revokeObjectURL(state.tryPhoto);
    state.tryPhoto = URL.createObjectURL(input.files[0]);
    render();
    return;
  }
  if (input.id !== "cam-file" || !input.files || !input.files[0]) return;
  const reader = new FileReader();
  reader.onload = () => openEditor(String(reader.result));
  reader.readAsDataURL(input.files[0]);
});

document.getElementById("phone").addEventListener("click", (event) => {
  const node = event.target.closest("[data-act]");
  if (!node) return;
  const act = node.dataset.act;
  if (act === "back") {
    if (current().name === "ai" && state.ai.step > 0) {
      state.ai.step -= 1;
      render();
      return;
    }
    if (current().name === "tryit" && state.tryStep > 0) {
      captureFields();
      state.tryStep -= 1;
      render();
      return;
    }
    return back();
  }
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
    localStorage.setItem(LANG_KEY, state.lang);
    push("welcome", { page: "shoot" });
    return;
  }
  if (act === "confirm-lang") {
    localStorage.setItem(LANG_KEY, state.lang);
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
  if (act === "open-task") {
    if (node.dataset.id === "ai_photos") return openAi();
    return push("task", { id: node.dataset.id });
  }
  if (act.startsWith("ai-") && act !== "ai-next" && act !== "ai-copy") {
    const ai = state.ai;
    const name = node.dataset.name;
    if (act === "ai-product") {
      // Displays and props differ by product.
      if (name !== ai.product) ai.scene = null;
      ai.product = name;
    }
    if (act === "ai-goal") {
      if (name !== ai.goal) ai.scene = null;
      ai.goal = name;
    }
    if (act === "ai-scene") ai.scene = name;
    render({ keepScroll: true });
    return;
  }
  if (act === "ai-next") {
    state.ai.step += 1;
    render();
    return;
  }
  if (act === "ai-copy") return aiCopy();
  if (act === "finish-ai") {
    // The first finish earns the badge. After that this stays a tool to come
    // back to, so Done simply closes it.
    const task = taskById("ai_photos");
    if (isTaskDone(task)) return back();
    markPart(task.id, "1");
    return showBadge(task.id);
  }
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
    push("create-types");
    return;
  }
  if (act === "types-continue") {
    openIg(nextCreateKind() || "post");
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
    if (view.kind === "post") {
      state.captionDraft = (state.work && state.work.caption) || "";
      push("caption", { kind: view.kind, photo: state.createPhoto });
      return;
    }
    push("did-post", { kind: view.kind, photo: state.createPhoto });
    return;
  }
  if (act === "caption-idea") {
    state.captionDraft = t(CAPTION_IDEAS[Number(node.dataset.index)]);
    render({ keepScroll: true });
    return;
  }
  if (act === "caption-next") {
    saveWork({ caption: state.captionDraft.trim() });
    // Swaps this page only, so Back from the next page returns to the photos.
    const view = state.stack.pop();
    push("did-post", { kind: view.kind, photo: view.photo });
    return;
  }
  if (act === "open-work") return push("work", { id: node.dataset.id });
  if (act === "work-copy") return workCopy(node.dataset.text);
  if (act === "posted-yes") {
    finishCreateKind(current().kind);
    return;
  }
  if (act === "posted-again") {
    back();
    return;
  }
  if (act === "try-handle") {
    state.tryCustom = "";
    state.tryHandle = node.dataset.handle;
    render();
    return;
  }
  if (act === "try-own") {
    state.tryOwn = true;
    render();
    const field = document.getElementById("try-own");
    if (field) field.focus();
    return;
  }
  if (act === "own-cancel") {
    state.tryOwn = false;
    render();
    return;
  }
  if (act === "own-save") {
    const field = document.getElementById("try-own");
    const handle = (field ? field.value : "").trim().replace(/^@/, "");
    if (!handle) return;
    const known = ["divya.weaves", "divya_mekhela", "sualkuchi.divya", "divya.handloom", "weaves.by.divya"];
    if (known.indexOf(handle) >= 0) {
      state.tryHandle = handle;
      state.tryCustom = "";
    } else {
      state.tryCustom = handle;
    }
    state.tryOwn = false;
    render();
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
  if (act === "bio-tag") {
    captureFields();
    const tag = t(node.dataset.tag);
    const bio = profileBio();
    if (bio.indexOf(tag) >= 0) return;
    state.tryBio = bio ? bio + " · " + tag : tag;
    render();
    return;
  }
  if (act === "change-photo") {
    const input = document.getElementById("try-photo");
    if (input) input.click();
    return;
  }
  if (act === "try-next") {
    captureFields();
    if (state.tryStep === 0) {
      state.tryName = state.tryCustom || state.tryHandle || "divya.weaves";
      state.tryUsername = state.tryName;
    }
    if (state.tryStep === 1 && state.tryUsername) state.tryName = state.tryUsername.replace(/^@/, "");
    if (state.tryStep < 3) {
      state.tryStep += 1;
      render();
      return;
    }
    saveWork({
      name: state.tryDisplayName || "",
      username: (state.tryUsername || state.tryCustom || state.tryHandle || "").replace(/^@/, ""),
      category: state.tryCategory || "",
      bio: profileBio(),
    });
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
  if (act === "guide-back") {
    if (state.guideIndex > 0) {
      state.guideIndex -= 1;
      render();
      return;
    }
    back();
    return;
  }
  if (act === "guide-next") {
    const view = current();
    const steps = guideFor(view.key, view.product);
    if (state.guideIndex < steps.length - 1) {
      state.guideIndex += 1;
      render();
      return;
    }
    state.cameraProblem = "";
    push("camera", {
      product: view.product,
      display: view.display,
      key: view.key,
      file: view.file,
      whole: view.whole,
    });
    return;
  }
  if (act === "shutter") {
    captureFrame();
    return;
  }
  if (act === "cam-pick") {
    const input = document.getElementById("cam-file");
    if (input) input.click();
    return;
  }
  if (act === "edit-close") {
    back();
    return;
  }
  if (act === "edit-reset") {
    // Undoes every change; the tool in use stays selected.
    const tool = state.editTool;
    resetEdit();
    state.editTool = tool;
    render();
    return;
  }
  if (act === "edit-tool") {
    const tool = node.dataset.tool;
    if (tool === "turn" && state.editTool === "turn") {
      state.editTurns = (state.editTurns + 1) % 4;
      state.editCrop = [0, 0, 1, 1];
    }
    state.editTool = tool;
    render();
    return;
  }
  if (act === "edit-save") {
    saveEdit();
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
    state.earned = false;
    state.tab = "learn";
    if (node.dataset.id === "ai_photos") {
      state.stack = [{ name: "main" }];
      return openAi();
    }
    state.stack = [{ name: "main" }, { name: "task", id: node.dataset.id }];
    render();
    return;
  }
  if (act === "home") {
    state.earned = false;
    state.tab = "learn";
    replace("main");
  }
});

// Typing must not rebuild the page, or the cursor would be lost.
document.getElementById("phone").addEventListener("input", (event) => {
  if (event.target.id !== "caption-text") return;
  state.captionDraft = event.target.value;
  const next = document.querySelector('[data-act="caption-next"]');
  if (!next) return;
  const ready = !!state.captionDraft.trim();
  next.disabled = !ready;
  next.classList.toggle("wait", !ready);
  next.classList.toggle("shadowed", !ready);
});

document.getElementById("phone").addEventListener("submit", (event) => {
  event.preventDefault();
});

replace("splash");
splashTimer = setTimeout(() => replace("login"), 3000);
