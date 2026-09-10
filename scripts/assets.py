#!/usr/bin/env python3
"""
assets.py - search and fetch free game assets from the shell, and record credits.

    python assets.py search <source> <query...> [options]
    python assets.py get    <source> <id> [options] --into <dir>
    python assets.py sources

Sources (search / get):
    polyhaven   models | textures | hdris        CC0, no key
    ambientcg   materials (also HDRI, 3DModel)   CC0, no key
    kenney      packs by category / by slug      CC0, no key (page scrape)
    kaykit      GitHub repos                     CC0, no key
    fonts       Google Fonts by family name      OFL, no key
    icons       lucide | tabler by icon name     ISC / MIT, no key
    sfxr        procedural SFX presets           generated, needs node
    freesound   sounds (CC0 filter by default)   per sound, FREESOUND_KEY
    polypizza   low-poly models                  per model, POLYPIZZA_KEY
    itch        free packs by <user>/<slug>      per pack, ITCH_KEY
    opengameart  art by type and licence         per asset, no key
    addon       GitHub <owner>/<repo> <tag>      per repo, no key
    sonniss     GDC audio bundle part            royalty-free, no key

Keys are read from C:\\dev\\.env (KEY=value lines) or the environment.
Every `get` appends a row to assets/CREDITS.md in the nearest project root.
Every claim about a URL pattern here was verified on 2026-09-10; when a source changes,
fix it here and record the lesson.
"""
from __future__ import annotations

import argparse
import base64
import datetime as _dt
import io
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
import zipfile
from pathlib import Path

UA = "gideon-game-studio/1.0 (asset fetcher; contact via github.com/gideon6222)"
ENV_FILE = Path(os.environ.get("GAMEDEV_ENV", r"C:\dev\.env"))
TOOLS_DIR = Path(os.environ.get("GAMEDEV_TOOLS", r"C:\dev\toolchain\node-tools"))
TODAY = _dt.date.today().isoformat()


# ── helpers ──────────────────────────────────────────────────────────────────

def load_env() -> dict[str, str]:
    env: dict[str, str] = {}
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text(encoding="utf-8", errors="replace").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    for k in ("FREESOUND_KEY", "ITCH_KEY", "POLYPIZZA_KEY", "GOOGLE_FONTS_KEY"):
        if os.environ.get(k):
            env[k] = os.environ[k]
    return env


ENV = load_env()


def key(name: str) -> str:
    v = ENV.get(name)
    if not v:
        sys.exit(f"{name} is not set. Add `{name}=...` to {ENV_FILE} (never commit it).")
    return v


def http(url: str, headers: dict | None = None, data: bytes | None = None, timeout: int = 60) -> bytes:
    h = {"User-Agent": UA, "Accept": "*/*"}
    if headers:
        h.update(headers)
    req = urllib.request.Request(url, headers=h, data=data)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.read()
    except urllib.error.HTTPError as e:
        body = e.read()[:300].decode("utf-8", "replace")
        sys.exit(f"HTTP {e.code} for {url}\n{body}")
    except urllib.error.URLError as e:
        sys.exit(f"network error for {url}: {e.reason}")


def get_json(url: str, headers: dict | None = None):
    raw = http(url, headers)
    text = raw.decode("utf-8", "replace")
    if text.startswith(")]}'"):  # Google Fonts download list prefix
        text = text.split("\n", 1)[1]
    return json.loads(text)


def download(url: str, dest: Path, headers: dict | None = None) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    data = http(url, headers, timeout=600)
    dest.write_bytes(data)
    print(f"   {dest}  ({len(data) / 1024:.0f} KB)")
    return dest


def unzip(data_or_path, into: Path, strip_top: bool = False, ignore: tuple[str, ...] = ()) -> list[str]:
    into.mkdir(parents=True, exist_ok=True)
    zf = zipfile.ZipFile(data_or_path if isinstance(data_or_path, Path) else io.BytesIO(data_or_path))
    names = zf.namelist()
    top = None
    if strip_top:
        firsts = {n.split("/", 1)[0] for n in names if "/" in n}
        if len(firsts) == 1:
            top = firsts.pop() + "/"
    written = []
    for n in names:
        if n.endswith("/"):
            continue
        rel = n[len(top):] if top and n.startswith(top) else n
        if any(part in ignore for part in rel.split("/")):
            continue
        target = into / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        with zf.open(n) as src, open(target, "wb") as dst:
            shutil.copyfileobj(src, dst)
        written.append(rel)
    return written


def project_root(start: Path | None = None) -> Path:
    p = (start or Path.cwd()).resolve()
    for cand in [p, *p.parents]:
        if (cand / "project.godot").exists() or (cand / "package.json").exists():
            return cand
    return p


def credit(source: str, asset: str, licence: str, url: str, into: Path):
    root = project_root(into)
    f = root / "assets" / "CREDITS.md"
    f.parent.mkdir(parents=True, exist_ok=True)
    if not f.exists():
        f.write_text(
            "# Credits\n\nEvery asset that was not made here. Appended by scripts/assets.py.\n\n"
            "| Date | Source | Asset | Licence | URL |\n|---|---|---|---|---|\n",
            encoding="utf-8",
        )
    with f.open("a", encoding="utf-8") as fh:
        fh.write(f"| {TODAY} | {source} | {asset} | {licence} | {url} |\n")
    print(f"   credited in {f.relative_to(root)}")


KNOWN_LICENCES = {"CC0", "CC0-1.0", "CC-BY-4.0", "CC-BY-3.0", "OFL", "MIT", "ISC", "Apache-2.0",
                  "Sonniss-royalty-free", "QAL-1.0", "Pixabay", "Mixed-see-URL"}


def check_licence(lic: str, allow_by: bool = True):
    norm = lic.replace(" ", "-")
    if norm in KNOWN_LICENCES:
        return norm
    if "Creative Commons 0" in lic or lic.lower().startswith("cc0"):
        return "CC0"
    if "Attribution" in lic and "NonCommercial" not in lic and "ShareAlike" not in lic and allow_by:
        return "CC-BY-4.0"
    sys.exit(f"Refusing licence '{lic}'. Only CC0, CC-BY, OFL, MIT, ISC, Apache and Sonniss are accepted. "
             f"NonCommercial and ShareAlike are never shipped.")


def table(rows: list[list[str]], head: list[str]):
    widths = [max(len(str(c)) for c in col) for col in zip(head, *rows)] if rows else [len(h) for h in head]
    fmt = "  ".join("{:<%d}" % w for w in widths)
    print(fmt.format(*head))
    for r in rows:
        print(fmt.format(*[str(c) for c in r]))


# ── Poly Haven ───────────────────────────────────────────────────────────────

PH_TYPES = {"models": "models", "textures": "textures", "hdris": "hdris", "hdri": "hdris", "model": "models", "texture": "textures"}


def search_polyhaven(a):
    t = PH_TYPES.get(a.query[0].lower()) if a.query else None
    terms = [q.lower() for q in (a.query[1:] if t else a.query)]
    types = [t] if t else ["models", "textures", "hdris"]
    rows = []
    for ty in types:
        url = f"https://api.polyhaven.com/assets?t={ty}"
        if a.category:
            url += f"&c={urllib.parse.quote(a.category)}"
        data = get_json(url)
        for aid, info in data.items():
            hay = (aid + " " + info.get("name", "") + " " + " ".join(info.get("tags", [])) + " " + " ".join(info.get("categories", []))).lower()
            if all(term in hay for term in terms):
                rows.append([ty, aid, info.get("name", ""), ",".join(info.get("categories", [])[:3]), info.get("download_count", "")])
    rows.sort(key=lambda r: -int(r[4] or 0))
    table(rows[: a.limit], ["type", "id", "name", "categories", "downloads"])
    if not rows:
        print("no matches. Record the miss in NOTES.md; the hit rate is per subject.")


def get_polyhaven(a):
    aid = a.id
    files = get_json(f"https://api.polyhaven.com/files/{aid}")
    info = get_json(f"https://api.polyhaven.com/info/{aid}")
    ty = {0: "hdris", 1: "textures", 2: "models"}.get(info.get("type"), "models")
    res = a.res or "1k"
    into = Path(a.into) / aid
    src_url = f"https://polyhaven.com/a/{aid}"
    if ty == "hdris":
        entry = files["hdri"][res]["hdr"]
        download(entry["url"], into / f"{aid}_{res}.hdr")
        # Godot imports .hdr uncompressed by default; write the .import so it does not.
        (into / f"{aid}_{res}.hdr.import").write_text(
            "[remap]\n\nimporter=\"texture\"\ntype=\"CompressedTexture2D\"\n\n[params]\n\n"
            "compress/mode=2\ncompress/high_quality=true\ncompress/hdr_compression=1\n"
            "mipmaps/generate=true\nprocess/size_limit=1024\n", encoding="utf-8")
    elif ty == "textures":
        maps = [m.strip() for m in (a.maps or "Diffuse,nor_gl,Rough,AO").split(",")]
        fmt = a.format or "jpg"
        for m in maps:
            entry = files.get(m, {}).get(res, {}).get(fmt)
            if not entry:
                print(f"   no {m} at {res} {fmt}; available: {list(files.keys())}")
                continue
            download(entry["url"], into / Path(entry["url"]).name)
    else:
        g = files["gltf"][res]["gltf"]
        download(g["url"], into / Path(g["url"]).name)
        for rel, inc in g.get("include", {}).items():
            download(inc["url"], into / rel)
        print("   layout preserved: textures/ and .bin sit where the .gltf expects them")
    credit("Poly Haven", f"{aid} ({ty}, {res})", "CC0", src_url, into)


# ── ambientCG ────────────────────────────────────────────────────────────────

def search_ambientcg(a):
    q = " ".join(a.query)
    ty = a.type or "Material"
    url = ("https://ambientcg.com/api/v2/full_json?type=" + urllib.parse.quote(ty)
           + "&q=" + urllib.parse.quote(q) + f"&limit={a.limit}&include=tagData,downloadData&sort=Popular")
    data = get_json(url)
    rows = []
    for item in data.get("foundAssets", []):
        sizes = sorted({d["attribute"].split("-")[0] for d in item.get("downloadFolders", {}).get("default", {}).get("downloadFiletypeCategories", {}).get("zip", {}).get("downloads", [])}) if item.get("downloadFolders") else []
        rows.append([item["assetId"], item.get("displayName", ""), ",".join(item.get("tags", [])[:4]), " ".join(sizes[:4])])
    table(rows, ["id", "name", "tags", "sizes"])
    if not rows:
        print("no results (ambientCG has no water, liquid or ripple materials, for example)")


def get_ambientcg(a):
    aid = a.id
    res = (a.res or "1K").upper()
    fmt = "JPG" if not a.format or a.format.lower() == "jpg" else "PNG"
    zip_name = f"{aid}_{res}-{fmt}.zip"
    data = http(f"https://ambientcg.com/get?file={zip_name}", timeout=600)
    wanted = [m.strip().lower() for m in a.maps.split(",")] if a.maps else None
    into = Path(a.into) / aid
    into.mkdir(parents=True, exist_ok=True)
    zf = zipfile.ZipFile(io.BytesIO(data))
    kept = []
    for n in zf.namelist():
        base = Path(n).name
        if not base or n.endswith("/"):
            continue
        if wanted and not any(w in base.lower() for w in wanted):
            continue
        (into / base).write_bytes(zf.read(n))
        kept.append(base)
        if "normal" in base.lower():
            (into / (base + ".import")).write_text(
                "[remap]\n\nimporter=\"texture\"\ntype=\"CompressedTexture2D\"\n\n[params]\n\n"
                "compress/mode=2\ncompress/high_quality=true\ncompress/normal_map=1\nmipmaps/generate=true\n"
                f"process/size_limit={1024 if res == '1K' else 2048}\n", encoding="utf-8")
    print("   kept: " + ", ".join(kept))
    if wanted and any("color" in k.lower() for k in kept):
        print("   note: you took the colour map. For a stylised game the rule is normal only, unless the pattern is pigment.")
    credit("ambientCG", f"{aid} {res} {fmt} [{', '.join(kept)}]", "CC0", f"https://ambientcg.com/view?id={aid}", into)


# ── Kenney ───────────────────────────────────────────────────────────────────

KENNEY_ZIP_RE = re.compile(r'https://kenney\.nl/media/pages/assets/[^"\'\s]+\.zip')


def search_kenney(a):
    # THE FOUR CATEGORIES ARE 3D, 2D, Audio AND TEXTURES. "UI" is not one of them:
    # kenney.nl/assets/category:UI is a real page that lists no packs at all, so the UI
    # quarter of every default search returned nothing and read as "Kenney has no UI".
    # Interface packs are a TAG - pass `tag:interface`, which is handled below.
    cats = a.query or ["3D", "2D", "Audio", "Textures"]
    rows = []
    seen = 0                      # slugs the scraper actually saw, before any filtering
    for cat in cats:
        # A selector that already names its kind (`tag:interface`) is used as-is; a bare
        # word is a category.
        sel = cat if ":" in cat else f"category:{cat}"
        cat_url = f"https://kenney.nl/assets/{urllib.parse.quote(sel, safe=':')}"
        page = 1
        while page <= 6:
            html = http(f"{cat_url}?page={page}").decode("utf-8", "replace")
            # Either quote: Kenney's listing pages emit href='...' and the double-quoted
            # form matched 6 links on category:3D against 55 single-quoted ones, so this
            # searched about a tenth of the library and reported the rest as absent.
            slugs = re.findall(r'''href=["']https://kenney\.nl/assets/([a-z0-9-]+)["']''', html)
            slugs = [s for s in dict.fromkeys(slugs) if not s.startswith("category")]
            if not slugs:
                break
            seen += len(slugs)
            for s in slugs:
                if not a.filter or a.filter.lower() in s:
                    rows.append([cat, s, f"https://kenney.nl/assets/{s}"])
            if 'page=' + str(page + 1) not in html:
                break
            page += 1
    # THE SEARCH MUST PROVE IT RAN. Zero rows because the filter matched nothing is a real
    # answer; zero rows because the scraper saw no packs at all is a broken tool, and the
    # two are indistinguishable from the outside. That is how a property of a regex got
    # written into two plans as a property of the library. Fail loudly on the second.
    if seen == 0:
        sys.exit(f"kenney: no packs found on any of {cats} - the scraper is broken or the "
            f"selector is not real (categories are 3D, 2D, Audio, Textures; try tag:interface). "
            f"Do NOT record this as 'Kenney has nothing for this'.")
    table(rows[: a.limit if a.limit != 20 else 400], ["category", "slug", "page"])


def get_kenney(a):
    slug = a.id
    html = http(f"https://kenney.nl/assets/{slug}").decode("utf-8", "replace")
    m = KENNEY_ZIP_RE.search(html)
    if not m:
        sys.exit("no zip link found on the page; Kenney may have changed the layout. Fix KENNEY_ZIP_RE.")
    data = http(m.group(0), timeout=600)
    into = Path(a.into) / slug
    written = unzip(data, into, ignore=("Previews", "Isometric", "Preview", "Sample", "Samples"))
    for folder in ("Previews", "Isometric", "Source", "Samples"):
        d = into / folder
        if d.exists():
            (d / ".gdignore").write_text("", encoding="utf-8")
    print(f"   {len(written)} files into {into}")
    credit("Kenney", slug, "CC0", f"https://kenney.nl/assets/{slug}", into)


# ── KayKit ───────────────────────────────────────────────────────────────────

def search_kaykit(a):
    repos = get_json("https://api.github.com/orgs/KayKit-Game-Assets/repos?per_page=100")
    rows = [[r["name"], (r.get("description") or "")[:70], r["html_url"]] for r in repos]
    table(rows, ["repo", "description", "url"])
    print("Packs not on GitHub (Platformer, Forest Nature, Character Animations...) are free on kaylousberg.itch.io: use `get itch kaylousberg/<slug>`.")


def get_kaykit(a):
    repo = a.id
    data = http(f"https://codeload.github.com/KayKit-Game-Assets/{repo}/zip/refs/heads/main", timeout=900)
    into = Path(a.into)
    written = unzip(data, into, strip_top=True, ignore=("Samples", "Previews"))
    print(f"   {len(written)} files into {into} (repo already uses an addons/ layout)")
    lfs = [w for w in written if w.lower().endswith((".gltf", ".fbx", ".glb")) and (into / w).stat().st_size < 200]
    if lfs:
        print("   WARNING: some model files are tiny; they may be git-lfs pointers. Clone with git and run `git lfs pull` instead.")
    credit("KayKit", repo, "CC0", f"https://github.com/KayKit-Game-Assets/{repo}", into)


# ── Google Fonts ─────────────────────────────────────────────────────────────

def search_fonts(a):
    q = " ".join(a.query).lower().replace(" ", "-")
    data = get_json("https://api.fontsource.org/v1/fonts")
    rows = [[f["id"], f.get("family", ""), f.get("category", ""), ",".join(str(w) for w in f.get("weights", [])[:6]), f.get("license", "")]
            for f in data if q in f["id"] or q in f.get("family", "").lower().replace(" ", "-")]
    table(rows[: a.limit], ["id", "family", "category", "weights", "licence"])


def get_font(a):
    family = a.id
    weights = [w.strip() for w in (a.weights or "400,700").split(",")]
    data = get_json("https://fonts.google.com/download/list?family=" + urllib.parse.quote(family))
    refs = data.get("manifest", {}).get("fileRefs", [])
    into = Path(a.into) / family.replace(" ", "")
    got = []
    for ref in refs:
        name = ref["filename"]
        if name.lower().endswith((".ttf", ".otf")):
            if "[wght]" in name or any(w in name for w in ("Regular", "Bold", "Medium", "SemiBold", "Light", "Black")) or True:
                download(ref["url"], into / Path(name).name)
                got.append(Path(name).name)
        elif name.upper().startswith("OFL") or name.upper().startswith("LICENSE"):
            download(ref["url"], into / Path(name).name)
    if not got:
        sys.exit("no font files in the manifest; check the family name at fonts.google.com")
    print("   variable fonts ([wght]) cover every weight through a FontVariation resource; weights requested: " + ", ".join(weights))
    credit("Google Fonts", family, "OFL", "https://fonts.google.com/specimen/" + urllib.parse.quote(family), into)


# ── Icons ────────────────────────────────────────────────────────────────────

ICON_SETS = {
    "lucide": ("https://cdn.jsdelivr.net/npm/lucide-static@latest/icons/{name}.svg", "ISC", "https://lucide.dev"),
    "tabler": ("https://cdn.jsdelivr.net/npm/@tabler/icons@latest/icons/outline/{name}.svg", "MIT", "https://tabler.io/icons"),
}


def get_icons(a):
    set_name = a.id
    if set_name == "game-icons":
        data = http("https://codeload.github.com/game-icons/icons/zip/refs/heads/master", timeout=900)
        into = Path(a.into) / "game-icons"
        names = [n.strip() for n in (a.names or "").split(",") if n.strip()]
        zf = zipfile.ZipFile(io.BytesIO(data))
        count = 0
        for n in zf.namelist():
            if n.endswith(".svg") and (not names or Path(n).stem in names):
                (into / Path(n).name).parent.mkdir(parents=True, exist_ok=True)
                (into / Path(n).name).write_bytes(zf.read(n))
                count += 1
        print(f"   {count} SVGs")
        credit("game-icons.net", ",".join(names) or "full set", "CC-BY-3.0", "https://game-icons.net (attribution: 'Icons made by the authors at game-icons.net')", into)
        return
    if set_name not in ICON_SETS:
        sys.exit("icon sets: lucide, tabler, game-icons")
    pattern, lic, home = ICON_SETS[set_name]
    names = [n.strip() for n in (a.names or "").split(",") if n.strip()]
    if not names:
        sys.exit("--names a,b,c is required (icon names as on the set's site)")
    into = Path(a.into) / set_name
    for n in names:
        download(pattern.format(name=n), into / f"{n}.svg")
    print("   SVGs use stroke=currentColor and render black in Godot; tint with modulate. Set svg/scale 2-4 in the import for crisp HiDPI.")
    credit(set_name, ",".join(names), lic, home, into)


# ── sfxr (procedural SFX through node + jsfxr) ───────────────────────────────

SFXR_PRESETS = ["pickupCoin", "laserShoot", "explosion", "powerUp", "hitHurt", "jump", "blipSelect", "synth", "tone", "click", "random"]


def ensure_jsfxr() -> Path:
    TOOLS_DIR.mkdir(parents=True, exist_ok=True)
    if not (TOOLS_DIR / "node_modules" / "jsfxr").exists():
        print("   installing jsfxr into " + str(TOOLS_DIR))
        subprocess.run(["npm", "init", "-y"], cwd=TOOLS_DIR, check=True, capture_output=True, shell=(os.name == "nt"))
        subprocess.run(["npm", "i", "jsfxr@1.4.1"], cwd=TOOLS_DIR, check=True, shell=(os.name == "nt"))
    return TOOLS_DIR


def get_sfxr(a):
    preset = a.id
    if preset not in SFXR_PRESETS and not a.b58:
        sys.exit("presets: " + ", ".join(SFXR_PRESETS) + " (or pass --b58 <code> from sfxr.me)")
    tools = ensure_jsfxr()
    into = Path(a.into)
    into.mkdir(parents=True, exist_ok=True)
    count = a.count or 1
    seed = a.seed or 1
    name = a.name or preset
    script = r"""
const fs = require('fs'); const { sfxr } = require('jsfxr');
const [preset, b58, seed, count, into, name] = process.argv.slice(2);
// deterministic: seed Math.random so the same seed gives the same sound
let s = parseInt(seed) >>> 0; Math.random = () => { s = (s * 1664525 + 1013904223) >>> 0; return s / 4294967296; };
for (let i = 0; i < parseInt(count); i++) {
  let p = b58 ? sfxr.b58decode(b58) : sfxr.generate(preset);
  if (i > 0) { p = sfxr.mutate ? sfxr.mutate(p) : p; }
  p.sample_size = 16; p.sample_rate = 44100;
  const wav = sfxr.toWave(p);
  const buf = Buffer.from(wav.dataURI.split(',')[1], 'base64');
  const f = `${into}/${name}${count > 1 ? '_' + (i + 1) : ''}.wav`;
  fs.writeFileSync(f, buf); console.log('   ' + f + ' (' + buf.length + ' bytes) b58=' + sfxr.b58encode(p));
}
"""
    js = tools / "_sfxr_gen.js"
    js.write_text(script, encoding="utf-8")
    subprocess.run(["node", str(js), preset, a.b58 or "", str(seed), str(count), str(into).replace("\\", "/"), name],
                   cwd=tools, check=True, shell=(os.name == "nt"))
    credit("jsfxr (generated)", f"{name} from preset {preset} seed {seed}", "CC0", "https://sfxr.me", into)


# ── Freesound ────────────────────────────────────────────────────────────────

def search_freesound(a):
    tok = key("FREESOUND_KEY")
    q = " ".join(a.query)
    lic = a.license or "cc0"
    filt = {"cc0": 'license:"Creative Commons 0"', "by": 'license:"Attribution"', "any": ""}.get(lic, lic)
    url = ("https://freesound.org/apiv2/search/text/?query=" + urllib.parse.quote(q)
           + (f"&filter={urllib.parse.quote(filt)}" if filt else "")
           + f"&fields=id,name,duration,license,username,avg_rating&page_size={a.limit}&sort=rating_desc&token={tok}")
    data = get_json(url)
    rows = [[r["id"], r["name"][:48], f"{r['duration']:.1f}s", r["license"].split("/")[-2] if "/" in r["license"] else r["license"], r["username"], round(r.get("avg_rating", 0), 1)] for r in data.get("results", [])]
    table(rows, ["id", "name", "len", "licence", "by", "rating"])


def get_freesound(a):
    tok = key("FREESOUND_KEY")
    sid = a.id
    info = get_json(f"https://freesound.org/apiv2/sounds/{sid}/?fields=id,name,license,username,previews,url&token={tok}")
    lic = info["license"]
    lic_name = "CC0" if "zero" in lic or "publicdomain" in lic else ("CC-BY-4.0" if "/by/" in lic else lic)
    check_licence(lic_name)
    prev = info["previews"].get("preview-hq-ogg") or info["previews"].get("preview-hq-mp3")
    safe = re.sub(r"[^a-z0-9]+", "-", info["name"].lower()).strip("-")[:40]
    into = Path(a.into)
    ext = ".ogg" if prev.endswith(".ogg") else ".mp3"
    download(prev, into / f"fs{sid}-{safe}{ext}")
    print("   this is the HQ preview (the original needs OAuth); it is fine for a phone")
    credit("Freesound", f"{info['name']} by {info['username']} (#{sid})", lic_name, info["url"], into)


# ── Poly Pizza ───────────────────────────────────────────────────────────────

def search_polypizza(a):
    tok = key("POLYPIZZA_KEY")
    q = urllib.parse.quote(" ".join(a.query))
    url = f"https://api.poly.pizza/v1.1/search/{q}?limit={a.limit}"
    if a.license:
        url += "&license=" + urllib.parse.quote(a.license)
    data = get_json(url, {"x-auth-token": tok})
    rows = []
    for r in data.get("results", []):
        rows.append([r.get("ID"), (r.get("Title") or "")[:40], r.get("Licence") or r.get("License"), r.get("Tri Count") or r.get("TriCount"), (r.get("Creator") or {}).get("Username")])
    table(rows, ["id", "title", "licence", "tris", "creator"])


def get_polypizza(a):
    tok = key("POLYPIZZA_KEY")
    r = get_json(f"https://api.poly.pizza/v1.1/model/{a.id}", {"x-auth-token": tok})
    lic = r.get("Licence") or r.get("License") or "unknown"
    lic_name = check_licence("CC0" if "0" in str(lic) and "BY" not in str(lic).upper() else "CC-BY-4.0")
    into = Path(a.into)
    title = re.sub(r"[^a-z0-9]+", "-", (r.get("Title") or a.id).lower()).strip("-")
    download(r["Download"], into / f"{title}.glb", {"x-auth-token": tok})
    credit("Poly Pizza", f"{r.get('Title')} by {(r.get('Creator') or {}).get('Username')} ({a.id})", lic_name,
           f"https://poly.pizza/m/{a.id}" + (f"  attribution: {r.get('Attribution')}" if r.get("Attribution") else ""), into)


# ── itch.io free packs ───────────────────────────────────────────────────────

def get_itch(a):
    tok = key("ITCH_KEY")
    user, slug = a.id.split("/", 1)
    meta = get_json(f"https://{user}.itch.io/{slug}/data.json")
    gid = meta.get("id") or meta.get("game_id")
    if not gid:
        sys.exit("could not read the game id from data.json")
    ups = get_json(f"https://itch.io/api/1/{tok}/game/{gid}/uploads").get("uploads", [])
    if not ups:
        sys.exit("no uploads listed; the pack may not be free, or the key is wrong")
    into = Path(a.into) / slug
    for up in ups:
        if a.filter and a.filter.lower() not in up["filename"].lower():
            continue
        dl = get_json(f"https://itch.io/api/1/{tok}/upload/{up['id']}/download")
        url = dl.get("url")
        dest = download(url, into / up["filename"])
        if dest.suffix.lower() == ".zip" and not a.keep_zip:
            unzip(dest, into, strip_top=True)
            dest.unlink()
    print("   licence is per pack: read the pack page and set --license, or the credit says Mixed")
    credit("itch.io", f"{user}/{slug}", a.license or "Mixed-see-URL", f"https://{user}.itch.io/{slug}", into)


# ── OpenGameArt ──────────────────────────────────────────────────────────────

OGA_TYPES = {"2d": 9, "3d": 10, "texture": 14, "music": 12, "sfx": 13, "concept": 7273}


def search_opengameart(a):
    q = urllib.parse.quote(" ".join(a.query))
    ty = OGA_TYPES.get((a.type or "2d").lower(), 9)
    url = f"https://opengameart.org/art-search-advanced?keys={q}&field_art_type_tid[]={ty}&sort_by=count&sort_order=DESC"
    if a.license != "any":
        url += "&field_art_licenses_tid[]=4"  # CC0
    html = http(url).decode("utf-8", "replace")
    items = re.findall(r'href="(/content/[a-z0-9-]+)"[^>]*>([^<]{3,80})<', html)
    seen = set()
    rows = []
    for href, title in items:
        if href in seen:
            continue
        seen.add(href)
        rows.append([title.strip(), "https://opengameart.org" + href])
    table(rows[: a.limit], ["title", "url"])


def get_opengameart(a):
    url = a.id if a.id.startswith("http") else "https://opengameart.org/content/" + a.id
    html = http(url).decode("utf-8", "replace")
    files = re.findall(r'href="(https://opengameart\.org/sites/default/files/[^"]+)"', html)
    lic_m = re.search(r'field-name-field-art-licenses.*?<a[^>]*>([^<]+)</a>', html, re.S)
    lic = lic_m.group(1).strip() if lic_m else "unknown"
    lic_name = "CC0" if "CC0" in lic else check_licence(lic)
    into = Path(a.into) / Path(url).name
    for f in dict.fromkeys(files):
        dest = download(f, into / Path(urllib.parse.unquote(f)).name)
        if dest.suffix.lower() == ".zip":
            unzip(dest, into)
            dest.unlink()
    credit("OpenGameArt", Path(url).name, lic_name, url, into)


# ── Godot addons from GitHub ─────────────────────────────────────────────────

def get_addon(a):
    repo = a.id
    tag = a.tag
    if not tag:
        rel = get_json(f"https://api.github.com/repos/{repo}/releases/latest")
        tag = rel["tag_name"]
        print(f"   latest release: {tag}")
    data = http(f"https://codeload.github.com/{repo}/zip/refs/tags/{tag}", timeout=900)
    zf = zipfile.ZipFile(io.BytesIO(data))
    into = Path(a.into)  # usually the project's addons/ dir
    count = 0
    lic_text = ""
    for n in zf.namelist():
        if n.endswith("/"):
            continue
        parts = n.split("/")
        if "addons" in parts:
            i = parts.index("addons")
            rel = "/".join(parts[i + 1:])
            if not rel:
                continue
            target = into / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(zf.read(n))
            count += 1
        elif Path(n).name.upper().startswith("LICENSE") and not lic_text:
            lic_text = zf.read(n).decode("utf-8", "replace")[:400]
    if count == 0:
        sys.exit("no addons/ folder in that release; check the repo layout")
    lic = "MIT" if "MIT" in lic_text else ("Apache-2.0" if "Apache" in lic_text else "Mixed-see-URL")
    print(f"   {count} files into {into}. Enable the plugin in project.godot [editor_plugins] and re-import.")
    credit("GitHub addon", f"{repo} {tag}", lic, f"https://github.com/{repo}/releases/tag/{tag}", into)


# ── Sonniss GDC bundles ──────────────────────────────────────────────────────

SONNISS = {"2024": ("Sonniss.com-GDC2024-GameAudioBundle{part}of9.zip", 9), "2023": ("Sonniss.com-GDC2023-GameAudioBundle{part}of14.zip", 14)}


def get_sonniss(a):
    year = a.id
    if year not in SONNISS:
        sys.exit("years with verified direct links: 2024 (9 parts), 2023 (14 parts)")
    pat, n = SONNISS[year]
    part = a.part or 1
    if not 1 <= part <= n:
        sys.exit(f"part must be 1..{n}")
    url = "https://downloads.sonniss.com/" + pat.format(part=part)
    into = Path(a.into) / f"sonniss-gdc{year}-{part}"
    print(f"   this is a multi-GB download: {url}")
    dest = download(url, into / Path(url).name)
    if not a.keep_zip:
        unzip(dest, into)
        dest.unlink()
    credit("Sonniss GDC bundle", f"{year} part {part}", "Sonniss-royalty-free", "https://sonniss.com/gameaudiogdc", into)


# ── CLI ──────────────────────────────────────────────────────────────────────

SEARCH = {"polyhaven": search_polyhaven, "ambientcg": search_ambientcg, "kenney": search_kenney, "kaykit": search_kaykit,
          "fonts": search_fonts, "freesound": search_freesound, "polypizza": search_polypizza, "opengameart": search_opengameart}
GET = {"polyhaven": get_polyhaven, "hdri": get_polyhaven, "ambientcg": get_ambientcg, "kenney": get_kenney, "kaykit": get_kaykit,
       "font": get_font, "icons": get_icons, "sfxr": get_sfxr, "freesound": get_freesound, "polypizza": get_polypizza,
       "itch": get_itch, "opengameart": get_opengameart, "addon": get_addon, "sonniss": get_sonniss}


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("search")
    s.add_argument("source", choices=sorted(SEARCH))
    s.add_argument("query", nargs="*")
    s.add_argument("--limit", type=int, default=20)
    s.add_argument("--category")
    s.add_argument("--type")
    s.add_argument("--license")
    s.add_argument("--filter")

    g = sub.add_parser("get")
    g.add_argument("source", choices=sorted(GET))
    g.add_argument("id")
    g.add_argument("tag", nargs="?")
    g.add_argument("--into", required=True)
    g.add_argument("--res")
    g.add_argument("--maps")
    g.add_argument("--format")
    g.add_argument("--weights")
    g.add_argument("--names")
    g.add_argument("--seed", type=int)
    g.add_argument("--count", type=int)
    g.add_argument("--name")
    g.add_argument("--b58")
    g.add_argument("--license")
    g.add_argument("--filter")
    g.add_argument("--part", type=int)
    g.add_argument("--keep-zip", action="store_true")

    sub.add_parser("sources")

    a = p.parse_args(argv)
    if a.cmd == "sources":
        print(__doc__)
        return
    if a.cmd == "search":
        print(f"searching {a.source} for: {' '.join(a.query) or '(all)'}")
        SEARCH[a.source](a)
    else:
        print(f"fetching {a.source} {a.id}")
        GET[a.source](a)


if __name__ == "__main__":
    main()
