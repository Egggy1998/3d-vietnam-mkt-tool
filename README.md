# 3D Vietnam Marketing System - Setup Tool

## Cách dùng

```bash
# Bash script (nhanh nhất)
bash ~/.openclaw/workspace/setup-tool/setup.sh

# Node.js
node ~/.openclaw/workspace/setup-tool/setup.js
```

---

## Input (CHỈ 5 FIELDS)

| # | Field | Ví dụ |
|---|-------|-------|
| 1 | n8n Instance URL | `https://jqqpar.ezn8n.com` |
| 2 | n8n Webhook ID | `c662501d-1d03-48c3-9bc2-4ad0e8e2b2a2` |
| 3 | Facebook Page ID | `1016972191499562` |
| 4 | Facebook Page Token | `EAAL1qA4ZC...` |
| 5 | Tên Business | `3D Vietnam` |

---

## ⚠️ Baserow Tables - TẠO TAY

Baserow **KHÔNG cho phép tạo table qua API**.

### Tạo trên Baserow UI:

**Content Calendar Table:**
| Field | Type |
|-------|------|
| Ngày đăng | date |
| Kênh đăng | single_select |
| Tiêu đề ngắn | text |
| Content bài đăng | long_text |
| Link ảnh đã thiết kế | text |
| Trạng thái | single_select |
| Ghi chú | text |

**Product Database Table:**
| Field | Type |
|-------|------|
| Tên thiết bị | text |
| Link ảnh | url |
| Link sản phẩm | url |

---

## Output

```
~/.openclaw/workspace/
├── TOOLS.md
├── PLAYBOOK.md
├── memory/
└── skills/
    ├── fullstack-mkt-skills/
    └── facebook-page-manager/tokens.json
```

---

## Setup cho khách mới

```bash
# 1. Chạy setup script
bash setup.sh

# 2. Hướng dẫn khách tạo Baserow tables TAY

# 3. Xong!
```

---

**Version:** 2026-04-24
