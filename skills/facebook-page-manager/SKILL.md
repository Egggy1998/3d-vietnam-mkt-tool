---
name: facebook-page
description: Manage Facebook Pages via Meta Graph API. Post content (text, photos, links), schedule posts, list posts, manage comments (list/reply/hide/delete). Use when user wants to publish to Facebook Page, schedule posts, check Page posts, or handle comments.
---

# Facebook Page Manager

## ⚠️ Security - Token Management

**QUAN TRỌNG: KHÔNG push tokens thật lên GitHub!**

- User Access Token → Nhập bởi user khi setup
- Page Token Map → Lưu local, KHÔNG commit lên git
- tokens.json → Luôn trong .gitignore

---

## 🔄 Token Architecture (NEW)

```
┌─────────────────────────────────────────────────┐
│  User Access Token (YOUR_USER_TOKEN)            │
│  ├── permissions: pages_show_list               │
│  ├── permissions: pages_manage_posts             │
│  └── expires: ~60 days (refresh được)          │
│         ↓ /me/accounts                          │
│  Page Token Map                                │
│  {                                             │
│    "PAGE_ID_1": "PAGE_TOKEN_1",                │
│    "PAGE_ID_2": "PAGE_TOKEN_2"                  │
│  }                                             │
│         ↓                                       │
│  Dùng Page Token đăng bài                       │
└─────────────────────────────────────────────────┘
```

### Tại sao phải refresh?

| Token Type | Hết hạn | Refresh được? |
|------------|---------|----------------|
| User Access Token | ~60 ngày | ✅ Có |
| Page Token | ~2 tháng | ❌ Không - phải lấy lại từ user token |

**→ User token là "chìa khóa master" để lấy page tokens mới**

---

## 🚀 Setup (lần đầu)

### Bước 1: Lấy User Access Token

1. Vào [Meta Graph API Explorer](https://developers.facebook.com/tools/explorer/)
2. Đăng nhập Facebook
3. Chọn App đã tạo
4. Cấp quyền: `pages_show_list`, `pages_manage_posts`, `pages_read_engagement`
5. Click "Generate Token"
6. **Lưu User Token** (sẽ dùng để refresh page tokens)

### Bước 2: Setup script

```bash
# Clone repo
git clone https://github.com/Egggy1998/hq-design-mkt-tool.git
cd hq-design-mkt-tool

# Tạo .env
cat > .env << 'EOF'
USER_TOKEN=YOUR_USER_ACCESS_TOKEN_HERE
APP_ID=YOUR_APP_ID
APP_SECRET=YOUR_APP_SECRET
EOF

# Chạy refresh tokens
node scripts/refresh-tokens.js
```

### Bước 3: Kiểm tra Page Tokens

```bash
node scripts/list-pages.js
```

Output:
```json
{
  "pages": {
    "1016972191499562": {
      "name": "3D Laser Beauty",
      "token": "EAAW..." // Auto-refresh khi hết hạn
    }
  }
}
```

---

## 📤 Schedule Post Flow

### Bước 1: Refresh Page Tokens (trước khi đăng)

```bash
node scripts/refresh-tokens.js
```

Script sẽ:
1. Dùng User Token gọi `GET /me/accounts`
2. Lấy page tokens mới nhất
3. Lưu vào `tokens.json`

### Bước 2: Schedule Post

```bash
PAGE_ID="1016972191499562"
TIMESTAMP=$(date -d "2026-04-25T02:00:00Z" +%s)

curl -X POST "https://graph.facebook.com/v19.0/${PAGE_ID}/feed" \
  -F "message=Nội dung bài viết..." \
  -F "link=https://example.com/image.jpg" \
  -F "published=false" \
  -F "scheduled_publish_time=${TIMESTAMP}" \
  -F "access_token=$(node -e "console.log(require('./tokens.json').pages['${PAGE_ID}'].token)")"
```

---

## 📋 tokens.json Format (NEW)

```json
{
  "user_token": "YOUR_USER_TOKEN",
  "app_id": "YOUR_APP_ID",
  "app_secret": "YOUR_APP_SECRET",
  "pages": {
    "PAGE_ID_1": {
      "name": "Page Name 1",
      "token": "EAAW...PAGE_TOKEN_1"
    },
    "PAGE_ID_2": {
      "name": "Page Name 2",
      "token": "EAAW...PAGE_TOKEN_2"
    }
  },
  "last_refresh": "2026-04-25T08:00:00Z"
}
```

**⚠️ File này KHÔNG push lên git!**

---

## 🔧 Scripts

### refresh-tokens.js

```javascript
/**
 * Refresh Page Tokens từ User Token
 * Chạy định kỳ hoặc khi page token hết hạn
 */

const axios = require('axios');
const fs = require('fs');
const path = require('path');

// Load .env
require('dotenv').config();

const USER_TOKEN = process.env.USER_TOKEN;
const APP_ID = process.env.APP_ID;
const APP_SECRET = process.env.APP_SECRET;

async function refreshPageTokens() {
  console.log('🔄 Refreshing page tokens...');
  
  try {
    // 1. Lấy danh sách pages từ user token
    const response = await axios.get('https://graph.facebook.com/v19.0/me/accounts', {
      params: { access_token: USER_TOKEN }
    });
    
    const pages = {};
    for (const page of response.data.data) {
      pages[page.id] = {
        name: page.name,
        token: page.access_token
      };
      console.log(`✅ Page: ${page.name} (${page.id})`);
    }
    
    // 2. Lưu vào tokens.json
    const tokensFile = path.join(__dirname, '..', 'tokens.json');
    const tokensData = {
      user_token: USER_TOKEN,
      app_id: APP_ID,
      app_secret: APP_SECRET,
      pages: pages,
      last_refresh: new Date().toISOString()
    };
    
    fs.writeFileSync(tokensFile, JSON.stringify(tokensData, null, 2));
    console.log('💾 Tokens saved to tokens.json');
    
    return pages;
    
  } catch (error) {
    console.error('❌ Error refreshing tokens:', error.response?.data || error.message);
    throw error;
  }
}

// Chạy nếu được gọi trực tiếp
if (require.main === module) {
  refreshPageTokens()
    .then(() => console.log('✅ Done!'))
    .catch(err => { console.error(err); process.exit(1); });
}

module.exports = { refreshPageTokens };
```

### list-pages.js

```javascript
/**
 * List các pages từ tokens.json
 */

const fs = require('fs');
const path = require('path');

const tokensFile = path.join(__dirname, '..', 'tokens.json');

if (!fs.existsSync(tokensFile)) {
  console.error('❌ tokens.json not found. Run refresh-tokens.js first!');
  process.exit(1);
}

const tokens = JSON.parse(fs.readFileSync(tokensFile, 'utf8'));

console.log('📋 Managed Pages:');
console.log(JSON.stringify(tokens.pages, null, 2));
console.log(`\nLast refresh: ${tokens.last_refresh}`);
```

---

## ⏰ Timestamp Công thức

```bash
# 09:00 VN = 02:00 UTC
date -d "YYYY-MM-DDT02:00:00Z" +%s

# Ví dụ: 25/04/2026 09:00 VN
date -d "2026-04-25T02:00:00Z" +%s
# Kết quả: 1777082400
```

### Timestamps thường dùng (09:00 VN)

| Ngày | Timestamp |
|------|----------|
| 2026-04-26 | 1777168800 |
| 2026-04-27 | 1777255200 |
| 2026-04-28 | 1777341600 |
| 2026-04-29 | 1777428000 |
| 2026-04-30 | 1777514400 |

---

## 📤 Đăng bài Scheduled

```bash
PAGE_ID="YOUR_PAGE_ID"
TIMESTAMP="1777082400"

curl -X POST "https://graph.facebook.com/v19.0/${PAGE_ID}/feed" \
  -F "message=Nội dung bài viết..." \
  -F "link=https://example.com/image.jpg" \
  -F "published=false" \
  -F "scheduled_publish_time=${TIMESTAMP}" \
  -F "access_token=PAGE_TOKEN_FROM_tokens.json"
```

### Response thành công

```json
{
  "id": "PAGE_ID_POST_ID",
  "success": true
}
```

---

## 🔐 Permissions cần thiết (User Token)

- `pages_show_list` - Xem danh sách pages
- `pages_manage_posts` - Quản lý bài đăng
- `pages_read_engagement` - Đọc engagement

---

## ⚠️ Troubleshooting

| Lỗi | Nguyên nhân | Giải pháp |
|------|-------------|-----------|
| `(#100) Invalid parameter` | Page token hết hạn | Chạy `refresh-tokens.js` |
| `(#200) does not have publish_actions` | Thiếu permission | Cấp lại user token với đủ quyền |
| `Invalid user access token` | User token hết hạn | Lấy user token mới từ Graph Explorer |

---

## 📁 Files

| File | Mô tả | Push git? |
|------|--------|----------|
| `SKILL.md` | Document này | ✅ |
| `scripts/refresh-tokens.js` | Script refresh tokens | ✅ |
| `scripts/list-pages.js` | Script list pages | ✅ |
| `.env` | Credentials (user nhập) | ❌ |
| `tokens.json` | Page token map | ❌ |
| `.gitignore` | Ignores .env, tokens.json | ✅ |

---

## 📚 Tham khảo

- [Meta Graph API - Pages](https://developers.facebook.com/docs/graph-api/reference/page/)
- [Access Token Debugger](https://developers.facebook.com/tools/debug/accesstoken/)
- [Token Exchange Flow](https://developers.facebook.com/docs/facebook-login/guides/access-token/get-long-lived/)
