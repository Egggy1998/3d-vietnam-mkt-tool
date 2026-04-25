---
name: n8n-workflow-engineering
description: Kết nối và điều phối n8n workflows qua Cloudflare Worker webhook cho hệ thống marketing. Worker đảm bảo 100% uptime. Dùng khi cần trigger design, kiểm tra status, hoặc debug workflow.
---

# n8n Workflow Engineering Agent

## Vai trò trong hệ thống

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION FLOW                            │
│                                                                 │
│  SA2 Marketing Planner                                          │
│       ↓ Brief                                                   │
│  SA3 Content Writer                                             │
│       ↓ Content hoàn chỉnh                                      │
│       ↓ Gọi Cloudflare Worker ─────────────────────────┐       │
│       ↓ (100% uptime)                                  ↓       │
│  Cloudflare Worker                                         │
│       ↓ Forwards to n8n                                   │
│  n8n SA Designer ────────────────────────────────────┘       │
│       ↓ Design xong                                         │
│       ↓ Update Baserow                                       │
│  SA4 Facebook Poster                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🌐 Cloudflare Worker Webhook

### Endpoint

```
POST https://YOUR_SUBDOMAIN.workers.dev
Content-Type: application/json
```

### Request Body Format

```json
{
  "row_id": 297,
  "baserow_row_id": 297,
  "content": "Nội dung bài viết đầy đủ...",
  "product_image_url": "https://example.com/image.jpg",
  "product_name": "Diode Laser 808nm",
  "scheduled_date": "2026-04-25"
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `row_id` | number | ✅ | Row ID trên Baserow |
| `baserow_row_id` | number | ✅ | Baserow row ID |
| `content` | string | ✅ | Nội dung bài viết |
| `product_image_url` | string | ✅ | URL ảnh sản phẩm |
| `product_name` | string | ❌ | Tên sản phẩm |
| `scheduled_date` | string | ❌ | Ngày đăng (YYYY-MM-DD) |

### Response Format

```json
{
  "success": true,
  "message": "Webhook received and forwarded",
  "row_id": 297,
  "n8n_status": "sent"
}
```

---

## 🚀 Cách Tự Set Up Cloudflare Worker

### Bước 1: Clone Worker Repo

```bash
git clone https://github.com/Egggy1998/hq-design-worker.git
cd hq-design-worker
```

### Bước 2: Deploy

**Cách 1: GitHub Integration (khuyến nghị)**
1. Cloudflare Dashboard → Workers & Pages
2. "Create a Worker" → "Deploy from GitHub"
3. Connect repo `Egggy1998/hq-design-worker`
4. Done!

**Cách 2: Wrangler CLI**
```bash
npm install -g wrangler
wrangler login
wrangler deploy
```

### Bước 3: Set Environment Variables

Trên Cloudflare Dashboard → Workers & Pages → `hq-design-worker` → Settings → Variables:

| Variable | Value |
|----------|-------|
| `N8N_WEBHOOK_URL` | URL n8n instance của bạn |
| `N8N_WEBHOOK_ID` | Webhook ID từ n8n workflow |
| `BASEROW_TABLE_ID` | Table ID từ Baserow |

### Bước 4: Set Secrets

```bash
wrangler secret put BASEROW_TOKEN
# Nhập Baserow API token của bạn
```

---

## Pipeline gọi Cloudflare Worker (SA3)

### Bước 1 — Chuẩn bị payload

```javascript
const payload = {
  "row_id": baserow_row_id,
  "baserow_row_id": baserow_row_id,
  "content": content_text,
  "product_image_url": product_image_from_baserow,
  "product_name": product_name,
  "scheduled_date": scheduled_date
};
```

### Bước 2 — Gọi Cloudflare Worker

```bash
curl -X POST "https://YOUR_SUBDOMAIN.workers.dev" \
  -H "Content-Type: application/json" \
  -d '{
    "row_id": 297,
    "baserow_row_id": 297,
    "content": "Bài viết content...",
    "product_image_url": "https://baserow.example.com/files/image.jpg",
    "product_name": "Diode Laser 808nm",
    "scheduled_date": "2026-04-25"
  }'
```

---

## n8n Workflow (SA Designer)

### Trigger: n8n Webhook
```
n8n receives forwarded request
    ↓
Get Baserow row data
    ↓
RunningHub API → Image generation
    ↓
Upload → Get public URL
    ↓
Update Baserow field "Link ảnh đã thiết kế"
    ↓
Done!
```

---

## Error Handling

| Error | Xử lý |
|-------|--------|
| Invalid JSON | Log payload, return 400 |
| Missing fields | Return 400 with field names |
| n8n timeout | Worker auto-retry |
| n8n not responding | Log and continue |

---

## 📚 Tham Khảo

- Cloudflare Workers Docs: https://developers.cloudflare.com/workers/
- Worker Repo: https://github.com/Egggy1998/hq-design-worker
