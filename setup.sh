#!/usr/bin/env bash

# HQ Design Marketing System - Setup Script
# Clone skills từ GitHub và cấu hình

set -e

REPO="Egggy1998/hq-design-mkt-tool"
SKILLS_DIR="$HOME/.openclaw/workspace/skills"
SETUP_DIR="$HOME/.openclaw/workspace/setup-tool"

echo "╔══════════════════════════════════════════╗"
echo "║   HQ Design Marketing System Setup      ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Input fields
read -p "1. n8n Instance URL: " N8N_URL
read -p "2. n8n Webhook ID: " N8N_WEBHOOK_ID
read -p "3. Facebook Page ID: " FB_PAGE_ID
read -p "4. Facebook Page Token: " FB_PAGE_TOKEN
read -p "5. Tên Business: " BUSINESS_NAME

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Kiểm tra thông tin:"
echo "   n8n URL: $N8N_URL"
echo "   Webhook ID: $N8N_WEBHOOK_ID"
echo "   Page ID: $FB_PAGE_ID"
echo "   Business: $BUSINESS_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Clone repo
warn "📥 Clone repo..."
cd "$HOME/.openclaw/workspace"
git clone "https://github.com/$REPO.git" setup-tool-temp 2>/dev/null || (cd setup-tool-temp && git pull)
mv setup-tool-temp/setup-tool "$SETUP_DIR" 2>/dev/null || true
rm -rf setup-tool-temp
log "Clone OK"

# Copy skills
warn "📂 Copy skills..."
mkdir -p "$SKILLS_DIR"
for skill in content-writer marketing-planner facebook-page-manager baserow-integration image-designer social-media-manager n8n-workflow-engineering; do
    if [ -d "$SETUP_DIR/skills/$skill" ]; then
        cp -r "$SETUP_DIR/skills/$skill" "$SKILLS_DIR/"
        log "$skill OK"
    fi
done

# Create tokens.json (local only - NOT pushed to git)
warn "🔑 Tạo tokens.json..."
mkdir -p "$SKILLS_DIR/facebook-page-manager"
cat > "$SKILLS_DIR/facebook-page-manager/tokens.json" << TOKEOF
{
  "pages": {
    "$FB_PAGE_ID": {
      "name": "$BUSINESS_NAME",
      "token": "$FB_PAGE_TOKEN"
    }
  }
}
TOKEOF
log "tokens.json OK (local only)"

echo ""
echo "✅ Setup hoàn tất!"
echo ""
echo "📁 Files tạo local (KHÔNG push lên git):"
echo "   - ~/.openclaw/workspace/skills/"
echo "   - ~/.openclaw/workspace/facebook-page-manager/tokens.json"
echo ""
echo "🔗 Repo: https://github.com/$REPO"
