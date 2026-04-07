# sd-server API Reference

The sd-server exposes two API families: an **OpenAI-compatible** API and a **Stable Diffusion WebUI-compatible** API (`/sdapi`). All image data is returned as base64-encoded strings. CORS is supported on all endpoints.

---

## OpenAI-compatible API

### GET `/v1/models`

List available models.

**Response:**

```json
{
  "data": [
    {
      "id": "sd-cpp-local",
      "object": "model",
      "owned_by": "local"
    }
  ]
}
```

---

### POST `/v1/images/generations`

Generate images from a text prompt.

**Content-Type:** `application/json`

**Request body:**

| Field                | Type    | Required | Default | Description                                      |
|----------------------|---------|----------|---------|--------------------------------------------------|
| `prompt`             | string  | yes      |         | Text description of the image to generate        |
| `n`                  | integer | no       | 1       | Number of images (1-8)                           |
| `size`               | string  | no       | 512x512 | Image dimensions, e.g. `"512x512"`              |
| `output_format`      | string  | no       | png     | `png`, `jpeg`, or `webp`                         |
| `output_compression` | integer | no       | 100     | Compression level (0-100)                        |

Additional sd-cpp parameters can be passed via `sd_cpp_extra_args` JSON embedded in the prompt.

**Response:**

```json
{
  "created": 1700000000,
  "data": [
    { "b64_json": "<base64>" }
  ],
  "output_format": "png"
}
```

---

### POST `/v1/images/edits`

Edit or inpaint images.

**Content-Type:** `multipart/form-data`

**Request fields:**

| Field                | Type     | Required | Default | Description                                      |
|----------------------|----------|----------|---------|--------------------------------------------------|
| `prompt`             | string   | yes      |         | Text description for image editing               |
| `image[]`            | file[]   | yes*     |         | Image files to edit                              |
| `image`              | file     | yes*     |         | Single image (fallback if `image[]` not provided)|
| `mask`               | file     | no       |         | Mask image for inpainting                        |
| `n`                  | string   | no       | 1       | Number of results (1-8)                          |
| `size`               | string   | no       | 512x512 | Output dimensions, e.g. `"512x512"`             |
| `output_format`      | string   | no       | png     | `png` or `jpeg`                                  |
| `output_compression` | integer  | no       | 100     | Compression level (0-100)                        |

\* At least one of `image[]` or `image` is required.

**Response:** Same structure as `/v1/images/generations`.

---

## Stable Diffusion WebUI-compatible API

### POST `/sdapi/v1/txt2img`

Text-to-image generation with advanced options.

**Content-Type:** `application/json`

**Request body:**

| Field            | Type    | Required | Default | Description                                   |
|------------------|---------|----------|---------|-----------------------------------------------|
| `prompt`         | string  | yes      |         | Text description                              |
| `negative_prompt`| string  | no       |         | Text to exclude from generation               |
| `width`          | integer | no       | 512     | Image width (must be > 0)                     |
| `height`         | integer | no       | 512     | Image height (must be > 0)                    |
| `steps`          | integer | no       |         | Sampling steps (1-150)                        |
| `cfg_scale`      | float   | no       |         | Classifier-free guidance scale (>= 0)         |
| `seed`           | integer | no       | -1      | Random seed (-1 for random)                   |
| `batch_size`     | integer | no       | 1       | Number of images (1-8)                        |
| `clip_skip`      | integer | no       | -1      | CLIP skip level                               |
| `sampler_name`   | string  | no       |         | Sampler method (see `/sdapi/v1/samplers`)      |
| `scheduler`      | string  | no       |         | Scheduler (see `/sdapi/v1/schedulers`)         |
| `flow_shift`     | float   | no       | auto    | Flow shift for Flow models (SD3.x, WAN, FLUX) |
| `lora`           | array   | no       |         | LoRA configurations (see below)               |
| `extra_images`   | array   | no       |         | Base64-encoded reference images               |

**LoRA item:**

| Field          | Type    | Required | Default | Description           |
|----------------|---------|----------|---------|-----------------------|
| `path`         | string  | yes      |         | LoRA file path        |
| `multiplier`   | float   | no       | 1.0     | Strength multiplier   |
| `is_high_noise`| boolean | no       | false   | High noise flag       |

**Response:**

```json
{
  "images": ["<base64>", ...],
  "parameters": { /* original request */ },
  "info": ""
}
```

---

### POST `/sdapi/v1/img2img`

Image-to-image generation with optional inpainting.

Accepts all parameters from `/sdapi/v1/txt2img` plus:

| Field                    | Type    | Required | Default | Description                          |
|--------------------------|---------|----------|---------|--------------------------------------|
| `init_images`            | array   | yes      |         | Array with base64-encoded input image|
| `mask`                   | string  | no       |         | Base64-encoded mask for inpainting   |
| `inpainting_mask_invert` | boolean | no       | false   | Invert mask logic                    |
| `denoising_strength`     | float   | no       |         | Denoising strength (0.0-1.0)        |

**Response:** Same structure as `/sdapi/v1/txt2img`.

---

### GET `/sdapi/v1/loras`

List available LoRA models.

**Response:**

```json
[
  { "name": "lora_name", "path": "/path/to/lora" }
]
```

---

### GET `/sdapi/v1/samplers`

List available sampling methods.

**Response:**

```json
[
  { "name": "euler a", "aliases": ["euler a"], "options": {} }
]
```

---

### GET `/sdapi/v1/schedulers`

List available noise schedulers.

**Response:**

```json
[
  { "name": "default", "label": "default" }
]
```

---

### GET `/sdapi/v1/sd-models`

List loaded Stable Diffusion models.

**Response:**

```json
[
  {
    "title": "model_name",
    "model_name": "model_name",
    "filename": "model.safetensors",
    "hash": "8888888888",
    "sha256": "8888888888888888888888888888888888888888888888888888888888888888",
    "config": null
  }
]
```

---

### GET `/sdapi/v1/options`

Get current server configuration.

**Response:**

```json
{
  "samples_format": "png",
  "sd_model_checkpoint": "model_name"
}
```

---

## Frontend

### GET `/`

Serves the web frontend UI (HTML).

---

## Error Responses

All endpoints return JSON errors:

```json
{ "error": "error message" }
```

| Status | Meaning                    |
|--------|----------------------------|
| 400    | Bad request / invalid input|
| 500    | Server error               |
