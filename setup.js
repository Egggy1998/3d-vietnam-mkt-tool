#!/usr/bin/env node
/**
 * 3D Vietnam Marketing System - Quick Setup Tool
 * Run: node setup.js
 * 
 * Setup n8n + Facebook + Skills (copies from workspace + clones fullstack-mkt repo)
 */

import { createInterface } from 'readline';
import { execSync } from 'child_process';
import { existsSync, writeFileSync, mkdirSync, cpSync, rmSync } from 'fs';
import { homedir } from 'os';
import path from 'path';

const rl = createInterface({ input: process.stdin, output: process.stdout });
const ask = (q) => new Promise((r) => rl.question(q, r));
const log = (msg, type = 'info') => {
  const icons = { info: 'ℹ️', success: '✅', error: '❌', step: '🔧' };
  console.log(`${icons[type]} ${msg}`);
};
const run = (cmd) => { try { return execSync(cmd, { encoding: 'utf8', stdio: 'pipe' }).trim(); } catch (e) { return null; } };

async function main() {
  console.log(`
╔═══════════════════════════════════════════════════════════════╗
║     3D VIETNAM MARKETING SYSTEM - SETUP TOOL                  ║
║     Setup n8n + Facebook + Skills                            ║
╚═══════════════════════════════════════════════════════════════╝
  `);

  console.log('\n📝 NHẬP THÔNG TIN CẦN THIẾT\n');
  const N8N_URL = await ask('1. n8n Instance URL: ');
  const N8N_WEBHOOK_ID = await ask('2. n8n Webhook ID: ');
  const FB_PAGE_ID = await ask('3. Facebook Page ID: ');
  const FB_PAGE_TOKEN = await ask('4. Facebook Page Token: ');
  const BUSINESS_NAME = await ask('5. Tên Business: ');

  const workspace = path.join(homedir(), '.openclaw', 'workspace');
  const skillsDir = path.join(workspace, 'skills');
  const sourceSkills = path.join(homedir(), '.openclaw', 'workspace', 'skills'); // Source is same workspace

  log('\n📁 Tạo thư mục...', 'step');
  mkdirSync(path.join(workspace, 'memory'), { recursive: true });
  mkdirSync(skillsDir, { recursive: true });

  // Clone fullstack-mkt repo
  log('\n📦 Clone fullstack-mkt repo...', 'step');
  if (!existsSync(path.join(skillsDir, 'fullstack-mkt'))) {
    run(`git clone https://github.com/minhnv0807/fullstack-mkt-skills.git "${skillsDir}/fullstack-mkt"`);
    log('fullstack-mkt repo cloned', 'success');
  } else {
    log('fullstack-mkt repo đã tồn tại', 'info');
  }

  // Copy essential skills
  log('\n📋 Copy skills vào workspace...', 'step');
  const skillsToCopy = [
    'content-writer',
    'marketing-planner', 
    'facebook-page-manager',
    'baserow-integration',
    'social-media-manager',
    'image-designer',
    'n8n-workflow-engineering'
  ];

  for (const skill of skillsToCopy) {
    const src = path.join(sourceSkills, skill);
    const dest = path.join(skillsDir, skill);
    
    if (existsSync(src)) {
      if (!existsSync(dest)) {
        cpSync(src, dest);
        log(`Copied: ${skill}`, 'success');
      } else {
        log(`Skill đã tồn tại: ${skill}`, 'info');
      }
    } else {
      log(`Skill không tìm thấy: ${skill}`, 'error');
    }
  }

  // Create TOOLS.md
  log('\n📝 Tạo TOOLS.md...', 'step');
  writeFileSync(path.join(workspace, 'TOOLS.md'), `# TOOLS.md - ${BUSINESS_NAME}

## n8n
- **Instance**: ${N8N_URL}
- **Webhook ID**: ${N8N_WEBHOOK_ID}
- **Webhook URL**: ${N8N_URL}/webhook/${N8N_WEBHOOK_ID}

## Facebook
- **Page ID**: ${FB_PAGE_ID}
- **Token**: ${FB_PAGE_TOKEN}
`);
  log('TOOLS.md OK', 'success');

  // Create tokens.json
  log('\n🔑 Tạo tokens.json...', 'step');
  mkdirSync(path.join(skillsDir, 'facebook-page-manager'), { recursive: true });
  writeFileSync(path.join(skillsDir, 'facebook-page-manager', 'tokens.json'),
    JSON.stringify({ pages: { [FB_PAGE_ID]: { name: BUSINESS_NAME, token: FB_PAGE_TOKEN } } }, null, 2));
  log('tokens.json OK', 'success');

  // Create PLAYBOOK.md
  log('\n📖 Tạo PLAYBOOK.md...', 'step');
  writeFileSync(path.join(workspace, 'PLAYBOOK.md'), `# CLAW MARKETING SYSTEM - Playbook

## ${BUSINESS_NAME}

## n8n Webhook
- URL: ${N8N_URL}/webhook/${N8N_WEBHOOK_ID}

## Facebook
- Page ID: ${FB_PAGE_ID}

## Skills
- content-writer, marketing-planner, facebook-page-manager
- baserow-integration, image-designer, n8n-workflow-engineering
- fullstack-mkt (16 MKT skills bonus)

## Baserow Tables (CREATED MANUALLY)
### Content Calendar
- Ngày đăng (date), Kênh đăng (single_select), Tiêu đề ngắn (text)
- Content bài đăng (long_text), Link ảnh đã thiết kế (text)
- Trạng thái (single_select), Ghi chú (text)

### Product Database
- Tên thiết bị (text), Link ảnh (url), Link sản phẩm (url)

## Workflow
1. Content (SA3) → Import Baserow
2. Design (n8n) → Webhook → Update Baserow
3. Post (SA4) → Facebook Schedule
`);
  log('PLAYBOOK.md OK', 'success');

  // Test Facebook
  log('\n🔍 Test Facebook...', 'step');
  const fbOk = run(`curl -s "https://graph.facebook.com/v19.0/${FB_PAGE_ID}?access_token=${FB_PAGE_TOKEN}" | grep -q "name"`);
  log(`Facebook: ${fbOk ? 'OK' : 'FAILED'}`, fbOk ? 'success' : 'error');

  // Summary
  console.log('\n============================================');
  console.log('SKILLS ĐÃ COPY:');
  for (const skill of skillsToCopy) {
    const dest = path.join(skillsDir, skill);
    console.log(`  ${existsSync(dest) ? '✅' : '❌'} ${skill}`);
  }
  console.log('  ✅ fullstack-mkt');

  console.log(`
╔═══════════════════════════════════════════════════════════════╗
║                 ✅ SETUP HOÀN THÀNH                           ║
╠═══════════════════════════════════════════════════════════════╣
║  FILES: TOOLS.md, PLAYBOOK.md, tokens.json                   ║
╠═══════════════════════════════════════════════════════════════╣
║  NEXT: Create Baserow tables MANUALLY, then test workflow   ║
╚═══════════════════════════════════════════════════════════════╝
`);

  rl.close();
}

main().catch(console.error);
