# 3D Vietnam Marketing System - Setup Tool

## Cách dùng

```bash
# Bash script (nhanh nhất)
bash ~/.openclaw/workspace/setup-tool/setup.sh

# Node.js
node ~/.openclaw/workspace/setup-tool/setup.js
```

---

## Input (5 fields)

| # | Field | Ví dụ |
|---|-------|-------|
| 1 | n8n Instance URL | `https://jqqpar.ezn8n.com` |
| 2 | n8n Webhook ID | `c662501d-1d03-48c3-9bc2-4ad0e8e2b2a2` |
| 3 | Facebook Page ID | `1016972191499562` |
| 4 | Facebook Page Token | `EAAL1qA4ZC...` |
| 5 | Tên Business | `3D Vietnam` |

---

## Cấu trúc sau Setup

```
~/.openclaw/workspace/
├── setup-tool/                    # Tool này
├── skills/                        # Skills từ workspace hiện tại
│   ├── content-writer/            # ✅ OpenClaw skill (SKILL.md)
│   ├── marketing-planner/          # ✅ OpenClaw skill (SKILL.md)
│   ├── facebook-page-manager/      # ✅ OpenClaw skill (SKILL.md)
│   ├── baserow-integration/       # ✅ OpenClaw skill (SKILL.md)
│   ├── social-media-manager/       # ✅ OpenClaw skill (SKILL.md)
│   ├── image-designer/             # ✅ OpenClaw skill (SKILL.md)
│   ├── n8n-workflow-engineering/   # ✅ OpenClaw skill (SKILL.md)
│   └── fullstack-mkt/             # 📚 MKT knowledge files (bonus)
│       ├── 00-ke-hoach-mkt.md
│       ├── 01-lich-noi-dung.md
│       ├── 02-brief-chien-dich.md
│       ├── ...
│       ├── 15-social-listening.md
│       ├── agents/
│       ├── references/
│       └── workflows/
├── memory/                        # Ghi chú hàng ngày
├── TOOLS.md                       # Credentials
└── PLAYBOOK.md                   # System documentation
```

---

## ⚠️ QUAN TRỌNG: Skills vs MKT Knowledge

### OpenClaw Skills (trong `skills/` folder)
ĐÂY LÀ SKILLS THẬT SỰ - OpenClaw dùng trực tiếp:
- `skills/content-writer/SKILL.md` - Viết content
- `skills/marketing-planner/SKILL.md` - Lên kế hoạch
- `skills/facebook-page-manager/SKILL.md` - Đăng Facebook
- `skills/baserow-integration/SKILL.md` - Kết nối Baserow
- `skills/image-designer/SKILL.md` - Design ảnh
- `skills/n8n-workflow-engineering/SKILL.md` - n8n workflows

### MKT Knowledge Files (trong `skills/fullstack-mkt/`)
ĐÂY LÀ TÀI LIỆU THAM KHẢO - không phải OpenClaw skills:
- 16 file `.md` - Kiến thức marketing
- `agents/` - Sub-agent prompts
- `references/` - Tài liệu tham khảo
- `workflows/` - Workflow examples

---

## Setup cho khách mới

```bash
# 1. Chạy setup script
bash setup.sh

# 2. Script sẽ:
#    - Copy 7 OpenClaw skills từ workspace vào ~/.openclaw/workspace/skills/
#    - Clone fullstack-mkt repo (MKT knowledge) vào skills/fullstack-mkt/

# 3. Hướng dẫn khách tạo Baserow tables TAY

# 4. Xong!
```

---

## ⚠️ Baserow Tables - TẠO TAY

Baserow **KHÔNG cho phép tạo table qua API**.

### Content Calendar Table
| Field | Type |
|-------|------|
| Ngày đăng | date |
| Kênh đăng | single_select |
| Tiêu đề ngắn | text |
| Content bài đăng | long_text |
| Link ảnh đã thiết kế | text |
| Trạng thái | single_select |
| Ghi chú | text |

### Product Database Table
| Field | Type |
|-------|------|
| Tên thiết bị | text |
| Link ảnh | url |
| Link sản phẩm | url |

---

## Baserow API Endpoints

```
GET    https://api.baserow.io/api/database/rows/table/{table_id}/?user_field_names=true
POST   https://api.baserow.io/api/database/rows/table/{table_id}/
PATCH  https://api.baserow.io/api/database/rows/table/{table_id}/{row_id}/
```

---

## n8n Workflow

**Webhook URL:** `{N8N_URL}/webhook/{WEBHOOK_ID}`

**Payload format:**
```json
{
  "row_id": 297,
  "baserow_row_id": 297,
  "content": "Nội dung bài viết...",
  "product_image_url": "https://..."
}
```

---

## Workflow hàng ngày

```
1. Spawn SA3 (content-writer)
   → Viết N bài content
   → Import vào Baserow

2. Gọi n8n webhook (SA Designer)
   → Design ảnh
   → Update "Link ảnh đã thiết kế" vào Baserow

3. Spawn SA4 (facebook-page-manager)
   → Schedule post (09:00 VN)
   → Update "Trạng thái" = Done
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| FB token expired | Get new from Graph API Explorer |
| Baserow 404 | Use api.baserow.io (no /v1/) |
| Skills not found | Chạy lại setup script |
| n8n webhook timeout | Dùng production URL |

---

**Version:** 2026-04-24
