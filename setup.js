#!/usr/bin/env node

// HQ Design Marketing System - Setup Script
const { ask } = require('Input');

const REPO = 'Egggy1998/hq-design-mkt-tool';

async function main() {
    print('╔══════════════════════════════════════════╗');
    print('║   HQ Design Marketing System Setup     ║');
    print('╚══════════════════════════════════════════╝');
    print('');

    // Input
    const N8N_URL = await ask('1. n8n Instance URL: ');
    const N8N_WEBHOOK_ID = await ask('2. n8n Webhook ID: ');
    const FB_PAGE_ID = await ask('3. Facebook Page ID: ');
    const FB_PAGE_TOKEN = await ask('4. Facebook Page Token: ');
    const BUSINESS_NAME = await ask('5. Tên Business: ');

    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Kiểm tra thông tin:');
    print(`   n8n URL: ${N8N_URL}`);
    print(`   Webhook ID: ${N8N_WEBHOOK_ID}`);
    print(`   Page ID: ${FB_PAGE_ID}`);
    print(`   Business: ${BUSINESS_NAME}`);
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');

    // Clone repo
    log('📥 Clone repo...', 'step');
    run('git clone https://github.com/${REPO}.git setup-tool-temp', { continue: true });
    run('mv setup-tool-temp/setup-tool ~/.openclaw/workspace/', { continue: true });
    run('rm -rf setup-tool-temp');
    log('Clone OK', 'success');

    // Copy skills
    log('📂 Copy skills...', 'step');
    const skillsDir = '~/.openclaw/workspace/skills';
    for (const skill of ['content-writer', 'marketing-planner', 'facebook-page-manager', 'baserow-integration', 'image-designer', 'social-media-manager', 'n8n-workflow-engineering']) {
        run('cp -r setup-tool/' + skill + ' ' + skillsDir + '/', { continue: true });
        log(skill + ' OK', 'success');
    }

    // Create tokens.json (local only)
    log('🔑 Tạo tokens.json...', 'step');
    const tokensDir = skillsDir + '/facebook-page-manager';
    writeFileSync(tokensDir + '/tokens.json', JSON.stringify({
        pages: {
            [FB_PAGE_ID]: { name: BUSINESS_NAME, token: FB_PAGE_TOKEN }
        }
    }, null, 2));
    log('tokens.json OK (local only)', 'success');

    print('');
    print('✅ Setup hoàn tất!');
    print('');
    print('📁 Files tạo local (KHÔNG push lên git):');
    print('   - ~/.openclaw/workspace/skills/');
    print('   - ~/.openclaw/workspace/facebook-page-manager/tokens.json');
}

main();
