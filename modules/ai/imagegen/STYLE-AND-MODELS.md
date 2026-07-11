# Models, LoRAs & Finding Your Own Style

A curated, current (mid-2026) guide for this setup — WAI-Illustrious + SwarmUI on an RX 9070 XT
(16 GB, gfx1201). Written against *your* observations: ~6–7 s at 1024², +10 s for a 1.5× Lanczos
refine, and **VRAM staying under 50%** during generation. That headroom is the theme below: you can
afford heavier models, bigger refines, ControlNet, stacked LoRAs, and even **local LoRA training**.

The landscape shifts fast — treat model versions as "check CivitAI for the current one," but the
*techniques* here are stable. CivitAI filter: Base Model = Illustrious / NoobAI.

---

## 1. Models — what to keep on the NVMe

Everything here is SDXL-architecture (~6.5 GB), runs with full headroom on 16 GB (no `--lowvram`).
The **LoRA family-lock rule** governs everything: a LoRA only works on checkpoints of its own base
family. Illustrious and NoobAI are cross-compatible (NoobAI is an Illustrious fine-tune); Pony is a
separate family. Sort LoRAs into `loras/{illustrious,noobai,pony,sdxl}/` accordingly.

| Model | Role | Notes |
|---|---|---|
| **WAI-Illustrious-SDXL** (you have v17) | Daily driver | Style-neutral, "just works," best LoRA compatibility. Its neutrality is *why* output looks "default" — see §3. |
| **NoobAI-XL V-Pred** | Your anti-generic pick | Community's top tag-comprehension + anatomy, and a **distinctly less generic** default look. Costs config: needs v-prediction sampling. In SwarmUI set sampler **Euler**, and enable the model's v-pred/ZSNR handling (SwarmUI usually auto-detects v-pred from the model metadata; if colors look fried, that's the tell). Worth it for breaking the sameness. |
| **NoobAI-XL Epsilon** (1.1) | Precision tool | Normal (epsilon) sampling, deep Danbooru artist-tag knowledge — the best base for **artist-tag blending** (§3). |
| **Nova Anime XL**, **Hassaku XL** | Alt default aesthetics | Different "house styles" to compare once the pipeline is habit. |
| **Animagine XL 4.0** | The "rarely misses" baseline | Good control comparison. |

**Do you need something bigger than SDXL?** With your headroom you *could* run **Flux** (≈12 GB, e.g.
a Flux anime fine-tune) or **NoobAI/Illustrious v2/v3** as they mature — Flux especially has a less
"anime-generic" feel and stronger prompt adherence. Trade-off: Flux is several times slower per image
and its LoRA/ControlNet ecosystem is smaller than SDXL-anime's. **Recommendation:** stay on
SDXL-anime (your speed + ecosystem are the win); reach for Flux only if a specific look demands it.
The generic-look problem is far better solved by §3 than by swapping architectures.

**Upscalers** → `upscale_models/`. Lanczos (what you use) is a plain math resize — fine and free.
For *detail-adding* upscales, drop an ESRGAN model in and pick it as the refiner upscaler:
- **4x-UltraSharp** — crisp general upscaler.
- **4x-AnimeSharp** / **RealESRGAN-x4plus-anime6B** — tuned for line art, fewer painterly artifacts.
Use these as the "Refiner Upscale Method" in SwarmUI instead of Lanczos when you want the upscale pass
to *add* detail, not just enlarge. With your VRAM/time budget, a 1.5–2× refine at denoise 0.3–0.45 is
cheap.

---

## 2. LoRAs — types and how to stack them

Think in four buckets:

1. **Quality / detail boosters** (style-neutral): sharpen detail, fix hands/eyes. Run at low weight
   (0.3–0.6). Examples: a *Detail Tweaker / Detail Enhancer* (Illustrious), *Smooth Detailer Booster*.
2. **Style LoRAs**: impose an aesthetic (this is your §3 lever). Weight 0.6–1.0.
3. **Character LoRAs**: lock a specific character's design.
4. **Concept LoRAs**: poses, clothing, effects.

**Stacking in SwarmUI:** add multiple LoRAs in the Generate tab; each has its own weight. Stacking is
where a personal look emerges — e.g. `detail-tweaker:0.4` + `styleA:0.6` + `styleB:0.4`. Watch total
weight: too much (sum ≫ ~1.5 of style LoRAs) fries coherence. Your VRAM easily holds several at once.

Always check the **Base Model** tag before downloading, and keep families in their subfolders.

---

## 3. The real goal — a consistent, distinctive style (not "default AI anime")

Your images look generic because **WAI-Illustrious is deliberately style-neutral** — it's a blank
canvas. A recognizable, "that's-clearly-their-work" look comes from *imposing* a style the base
doesn't have on its own. Two paths, and the pros do **both**: use A to design the look, then B to lock
it in.

### A. Artist-tag blending (immediate, no training)

Illustrious/NoobAI were trained on Danbooru and **know thousands of artist tags and style tags**. This
is the single biggest lever and it's free:

- Put **artist tags** in your prompt, usually as `artist:name` or `by name` (syntax varies by model —
  check the model card; NoobAI-Epsilon has the deepest artist knowledge).
- **Blend several at weights** so the result is *no single artist* → distinctive and not a copy:
  `(artist:aaa:0.7), (artist:bbb:0.5), (artist:ccc:0.3)`. This is exactly how the "consistent-style"
  creators work — pick 2–4 artists whose blend you like and lock the ratio.
- Add **style/quality tags** the model recognizes (e.g. `oil painting`, `flat color`, `impasto`,
  `1990s (style)`, `retro artstyle`) — there's a community reference list of Illustrious-recognized
  style tags (linked below). Your vaporwave GTA-cover experiments are already this in spirit.
- Keep a **style block** — a fixed chunk of tags you paste into every prompt. That alone buys a lot of
  consistency.

Iterate here (fixed seed, vary one tag at a time) until you have a blend you love. That blend *is* your
style recipe. The limitation: it's ~5–15 tags you must carry, and it can drift. Which is why →

### B. Train a style LoRA (lock it in — the pro move)

The technique your patreon examples use (confirmed by current guides): **blend artists → mass-generate
a consistent set → train a LoRA on your own output.** The LoRA distills the blend into a single trigger,
gives rock-solid consistency, and — because it's trained on a *mix* — doesn't read as any one artist.

The recipe:
1. **Design the look** via §A until a blend/settings combo is consistently what you want.
2. **Generate a dataset**: 60–150 images in that exact look — varied subjects/poses/compositions but
   *same coloring, same rendering, same atmosphere* (for a **style** LoRA you align aesthetics, not a
   character). Cull hard: only keep on-style, clean images.
3. **Caption** them: describe *content* (subject, pose, background) but **omit the style descriptors** —
   you want the LoRA to absorb the style as the "default," triggered by one rare token you add.
4. **Train** (settings in §4). Result: `myStyle` at weight ~0.8 → your look, one tag, every time.
5. Optionally re-train later on your *best* generated images (a feedback loop that tightens the style).

You can also train on **hand-picked existing art** (yours or a curated set), but the blend-your-own-mix
route is what produces a look that's *distinctive* rather than a clone.

---

## 4. Training on YOUR hardware (16 GB RX 9070 XT)

Good news: **16 GB is comfortable for SDXL/Illustrious LoRA training** (community-considered so;
12 GB is the aggressive-optimization floor). The tool is **kohya_ss** (`sd-scripts`). Baseline settings
for an SDXL/Illustrious **style** LoRA on 16 GB:

| Setting | Value | Why |
|---|---|---|
| Resolution | `1024` | Illustrious/SDXL were trained at 1 MP |
| Network rank (dim) | `32–64` | style needs less than you'd think; 32 is plenty |
| Network alpha | `= rank` (or rank/2 for punchier) | stability |
| Learning rate | `1e-4` (UNet); TE `~5e-5` or off | see TE note |
| Optimizer | **`AdamW8bit`** | −25–30% VRAM, negligible quality loss — essential ≤16 GB |
| Batch size | `2` (drop to 1 if OOM) | headroom-dependent |
| Gradient checkpointing | **on** | big VRAM saver |
| Epochs / repeats | tune to ~1500–3000 total steps | style over-bakes if too long |
| Text encoders | train both at same LR, **or disable CLIP-G** for style | SDXL's dual-TE quirk |

**The AMD/ROCm rough edge (be realistic):** kohya works on AMD via ROCm, but it's the finickiest part
of this whole stack — some users hit "training silently falls back to CPU." RDNA4 is new enough that
there aren't many public reports yet. Two viable routes, in order of preference:

1. **Containerized kohya on ROCm 7.2** — mirror exactly what made the ComfyUI engine work: a
   `rocm/pytorch:rocm7.2.4…` container with `sd-scripts`, `/dev/kfd`+`/dev/dri` passthrough,
   `group_add [26,303]`, and **crucially leave `HSA_OVERRIDE_GFX_VERSION` unset** (the empty-string
   trap we already hit — gfx1201 is native). Since 7.2 gave us clean inference, training has a good
   shot. Verify it's actually on-GPU by watching `amdgpu_top`/VRAM during a test run (this is the
   step where CPU-fallback shows itself). *I can build this container as a follow-up if you want to
   pursue local training.*
2. **Cloud GPU fallback** — a few dollars renting an NVIDIA A100/4090 hour (RunPod/Vast) trains an
   SDXL style LoRA in well under an hour with zero AMD friction. Pragmatic when you just want the LoRA,
   not a training rig. The LoRA runs locally afterward regardless of where it was trained.

Either way, training is decoupled from generation — the `.safetensors` LoRA drops into
`loras/illustrious/` and loads in SwarmUI like any other.

---

## 5. A concrete plan to find + lock your style

1. **Pick a base**: WAI for easy iteration, or **NoobAI-Epsilon** for the richest artist-tag response.
2. **Blend**: fixed seed + subject, try 2–4 artist tags + a few style tags, vary weights one at a time.
   Save the prompts of the results you love (SwarmUI stores generation metadata in the image).
3. **Settle a recipe**: a style block + sampler/steps/CFG you'll reuse. Test it across different
   subjects/poses — does the *look* hold? If yes, you have your style.
4. **(Optional but recommended) Lock it**: mass-generate 60–150 on-style images → caption (content
   only) → train a style LoRA (§4) → now it's one trigger token.
5. **Maintain consistency**: fixed template + the LoRA + fixed settings. Keep a `my-style.md` note with
   the recipe (SwarmUI presets can hold this too).

Realistically: §A + §5 steps 1–3 will already get you 80% of the way to a distinctive, consistent look
this week, with no training. The LoRA is the polish that makes it effortless and reproducible.

---

## 6. SwarmUI feature notes (things you already have)

- **Refiner / upscale**: swap Lanczos → an ESRGAN-anime model (§1) when you want the upscale to add
  detail. Denoise 0.3–0.45 on the refine pass.
- **img2img**: your GTA-cover trick — strength ~0.4–0.7 controls how much of the source survives.
- **ReVision** (you asked): it is **not** sketch-to-image. ReVision embeds a *reference image* through
  CLIP-Vision and conditions generation on that image's overall **content/composition/style** — "make
  something with this image's vibe," optionally blending multiple references, with or without a text
  prompt. Great for **style transfer from a mood-board image**. It does *not* trace a pose.
- **For pose-from-a-sketch**, that's **ControlNet** (OpenPose / Scribble / Lineart) — a separate
  feature. Drop Illustrious ControlNet models in `controlnet/`; SwarmUI exposes them in the Generate
  tab. Your VRAM easily runs ControlNet alongside a checkpoint.
- **FaceDetailer-equivalent**: SwarmUI's segment/refine features (backed by the Swarm nodes we
  installed) auto-fix faces/hands on upscale — enable them for portraits.

---

## Sources
- [Illustrious-recognized style tags (reference list)](https://civitai.com/articles/25464/common-style-tags-recognized-by-illustrious-and-other-danbooru-based-models)
- [LoRA training params for SDXL/Illustrious](https://civitai.com/articles/21257/lora-training-parameters-guide-for-sdxl-illustrious-civitai-on-site-trainer) ·
  [Kohya SDXL on 8/12/16 GB](https://civitai.com/articles/10872/training-sdxl-lora-in-kohyass-with-8gb-12gb-or-higher-vram) ·
  [LoRA training 2026 guide](https://sanj.dev/post/lora-training-2025-ultimate-guide/)
- [kohya_ss ROCm Docker (AMD)](https://github.com/hqnicolas/bmaltaisKohya_ssROCm) ·
  [kohya on AMD works (issue #1484)](https://github.com/bmaltais/kohya_ss/issues/1484)
- [Illustrious XL fine-tunes compared](https://techtactician.com/best-illustrious-xl-sdxl-anime-model-fine-tunes-comparison/) ·
  [Best SD models 2026](https://www.aiphotogenerator.net/blog/2026/02/best-stable-diffusion-models-2026)
- [Porting an art style into a LoRA (80 illustrations)](https://note.com/rockey2799m/n/n05159f2fcc96?hl=en)
