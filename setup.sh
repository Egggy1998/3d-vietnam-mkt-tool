#!/bin/bash
# 3D Vietnam Marketing System - Quick Setup
# Run: bash setup.sh
# 
# Setup n8n + Facebook credentials
# Skills are copied from existing workspace skills folder

set -e

echo "
╔═══════════════════════════════════════════════════════════════╗
║     3D VIETNAM MARKETING SYSTEM - SETUP TOOL                    ║
║     Setup n8n + Facebook + Skills                              ║
╚═══════════════════════════════════════════════════════════════╝
"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Read input
echo ""
echo "📝 NHẬP THÔNG TIN CẦN THIẾT"
echo "============================================"
read -p "1. n8n Instance URL (VD: https://jqqpar.ezn8n.com): " N8N_URL
read -p "2. n8n Webhook ID: " N8N_WEBHOOK_ID
read -p "3. Facebook Page ID: " FB_PAGE_ID
read -p "4. Facebook Page Token: " FB_PAGE_TOKEN
read -p "5. Tên Business (VD: 3D Vietnam): " BUSINESS_NAME

WORKSPACE="$HOME/.openclaw/workspace"
SKILLS_DIR="$WORKSPACE/skills"
SOURCE_SKILLS="$HOME/.openclaw/workspace/skills"  # Source is same workspace

# Create directories
echo ""
warn "Tạo thư mục..."
mkdir -p "$WORKSPACE/memory"
mkdir -p "$SKILLS_DIR"
log "Thư mục OK"

# Clone fullstack-mkt repo
echo ""
warn "Clone fullstack-mkt repo..."
if [ ! -d "$SKILLS_DIR/fullstack-mkt" ]; then
    git clone https://github.com/minhnv0807/fullstack-mkt-skills.git "$SKILLS_DIR/fullstack-mkt" 2>/dev/null || warn "Clone failed (skip)"
else
    warn "fullstack-mkt repo đã tồn tại"
fi
log "fullstack-mkt repo OK"

# Copy essential skills from workspace
echo ""
warn "Copy skills vào workspace..."

SKILLS_TO_COPY="content-writer marketing-planner facebook-page-manager baserow-integration social-media-manager image-designer n8n-workflow-engineering"

for skill in $SKILLS_TO_COPY; do
    if [ -d "$SOURCE_SKILLS/$skill" ]; then
        if [ ! -d "$SKILLS_DIR/$skill" ]; then
            cp -r "$SOURCE_SKILLS/$skill" "$SKILLS_DIR/"
            log "Copied: $skill"
        else
            warn "Skill đã tồn tại: $skill"
        fi
    else
        warn "Skill không tìm thấy: $skill"
    fi
done

# Create TOOLS.md
echo ""
warn "Tạo TOOLS.md..."
cat > "$WORKSPACE/TOOLS.md" << EOF
# TOOLS.md - ${BUSINESS_NAME}

## n8n
- **Instance**: ${N8N_URL}
- **Webhook ID**: ${N8N_WEBHOOK_ID}
- **Webhook URL**: ${N8N_URL}/webhook/${N8N_WEBHOOK_ID}

## Facebook
- **Page ID**: ${FB_PAGE_ID}
- **Token**: ${FB_PAGE_TOKEN}
EOF
log "TOOLS.md OK"

# Create tokens.json
echo ""
warn "Tạo tokens.json..."
mkdir -p "$SKILLS_DIR/facebook-page-manager"
cat > "$SKILLS_DIR/facebook-page-manager/tokens.json" << EOF
{
  "pages": {
    "${FB_PAGE_ID}": {
      "name": "${BUSINESS_NAME}",
      "token": "${FB_PAGE_TOKEN}"
    }
  }
}
EOF
log "tokens.json OK"

# Create PLAYBOOK.md
echo ""
warn "Tạo PLAYBOOK.md..."
cat > "$WORKSPACE/PLAYBOOK.md" << EOF
# CLAW MARKETING SYSTEM - Playbook

## ${BUSINESS_NAME}

## n8n Webhook
- URL: ${N8N_URL}/webhook/${N8N_WEBHOOK_ID}

## Facebook
- Page ID: ${FB_PAGE_ID}

## Skills
- skills/content-writer/ - SA3: Viết content Facebook
- skills/marketing-planner/ - SA2: Lên kế hoạch content
- skills/facebook-page-manager/ - SA4: Đăng bài Facebook
- skills/baserow-integration/ - Kết nối Baserow
- skills/image-designer/ - SA1: Design ảnh
- skills/n8n-workflow-engineering/ - n8n workflows
- skills/fullstack-mkt/ - 16 MKT skills (bonus)

## Baserow Tables (CREATED MANUALLY)
### Content Calendar
| Field | Type |
|-------|------|
| Ngày đăng | date |
| Kênh đăng | single_select |
| Tiêu đề ngắn | text |
| Content bài đăng | long_text |
| Link ảnh đã thiết kế | text |
| Trạng thái | single_select |
| Ghi chú | text |

### Product Database
| Field | Type |
|-------|------|
| Tên thiết bị | text |
| Link ảnh | url |
| Link sản phẩm | url |

## Workflow
1. Content (SA3) → Import Baserow
2. Design (n8n) → Webhook → Update Baserow
3. Post (SA4) → Facebook Schedule
EOF
log "PLAYBOOK.md OK"

# Test Facebook
echo ""
warn "Test Facebook..."
echo -n "  Facebook: "
if curl -s "https://graph.facebook.com/v19.0/$FB_PAGE_ID?access_token=$FB_PAGE_TOKEN" | grep -q "name"; then
    log "OK"
else
    error "FAILED"
fi

# Summary
echo ""
echo "============================================"
echo "SKILLS ĐÃ COPY:"
for skill in $SKILLS_TO_COPY; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        echo "  ✅ $skill"
    fi
done

echo "
╔═══════════════════════════════════════════════════════════════╗
║                 ✅ SETUP HOÀN THÀNH                          ║
╠═══════════════════════════════════════════════════════════════╣
║  SKILLS:                                                     ║
$(for skill in $SKILLS_TO_COPY; do echo "║    - $skill"; done)
║    - fullstack-mkt                                           ║
╠═══════════════════════════════════════════════════════════════╣
║  FILES:                                                      ║
║    - ~/.openclaw/workspace/TOOLS.md                         ║
║    - ~/.openclaw/workspace/PLAYBOOK.md                      ║
║    - ~/.openclaw/workspace/skills/facebook-page-manager/    ║
║      tokens.json                                            ║
╠═══════════════════════════════════════════════════════════════╣
║  NEXT STEPS:                                                 ║
║    1. Create Baserow tables MANUALLY on Baserow UI         ║
║    2. Import n8n workflow (SA Designer Fixed)               ║
║    3. Test full workflow                                    ║
╚═══════════════════════════════════════════════════════════════╝
"
