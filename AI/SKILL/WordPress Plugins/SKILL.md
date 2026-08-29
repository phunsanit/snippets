---
name: create-wordpress-plugin
description: Creates a new WordPress plugin project with a standardized professional folder structure, automated build scripts, deployment scripts, TypeScript support, security controls, and Playwright E2E testing setup.
version: 1.3.0
---

# Create WordPress Plugin Skill

This skill guides the AI to create a new WordPress Plugin project with a standardized professional structure designed for robust development, E2E testing with Playwright, and seamless deployment to WordPress.org via SVN.

## Initial Requirements Questionnaire
Before running this skill, ensure the following configuration variables are collected from the user:

1. **Plugin Name:** The formal display name of the plugin (e.g., `PlusMagi Site Search`).
2. **Plugin Slug:** The unique URL-friendly identifier in lowercase, dash-separated (e.g., `plusmagi-markdown`).
3. **Description:** A brief explanation of the plugin's core utility and purpose.
4. **WordPress.org Contributor Username:** The official username on WordPress.org for profile tagging in readme.txt credits (e.g., `plusmagi`).
5. **TypeScript Integration:** Determine if the project ecosystem requires compilation architecture for custom TypeScript assets (`Yes` or `No`).
6. **Author Name:** The name of the developer or organization (e.g., `Pitt Phunsanit`).
7. **Author URI:** The primary website URL or code repository destination for the author profile header links.
8. **Minimum WordPress Version:** The baseline WordPress core framework version required to run the module safely (e.g., `6.0`).
9. **Tested Up To:** The target WordPress stable core build milestone that has been fully validated (e.g., `6.8`).

---

# Create WordPress Plugin Skill

This skill guides the AI to create a new WordPress Plugin project with a standardized professional structure designed for robust development, E2E testing with Playwright, and seamless deployment to WordPress.org via SVN.

## 0. Workflow and Initial Requirement Gathering

Before generating any files or directories, the AI must verify the workspace state and establish the plugin naming convention.

### Step 0.1: Check Workspace and Folder Name
- Check if you are already inside a workspace folder.
- If the repository or folder name starts with wp-, keep that as the project/repository prefix, but use plusmagi-markdown as the Plugin Slug without the wp- prefix.
- Create the main entry file as wp-plusmagi-markdown.php while keeping the plugin slug as plusmagi-markdown.
- Verify if there are any existing .php files or structures to avoid overwriting existing work.

### Step 0.2: Prompt the User for Plugin Information
You must prompt the user directly to confirm or provide these critical values:
1. Plugin Name: (e.g., PlusMagi Site Search)
2. Plugin Slug: (e.g., plusmagi-markdown - lowercase, dash-separated, without the wp- prefix; the project folder/repo may still be named wp-plusmagi-markdown)
3. Description: A short sentence explaining what the plugin does.
4. WordPress.org Contributor Username: (e.g., plusmagi for readme.txt credits)
5. TypeScript Integration: Ask if the project requires TypeScript compiling (Yes/No).
6. Author Name and Author URI: (Developer details for the plugin header)
7. Minimum WordPress Version (Requires at least): The oldest WP version the plugin supports (e.g., 6.0). Confirm or let the AI suggest the current stable minus one.
8. Tested Up To: The latest WP version the plugin has been verified against (e.g., 6.8). The AI should check the current latest WordPress release and suggest it as the default.

---

## 1. Project Initialization

Execute the following commands to initialize Git and scaffold the standard directory structure:
Command 1: git init
Command 2: mkdir -p SVN/trunk SVN/assets SVN/tags wp-assets Website Playwright/tests

Directory breakdown:
- SVN/trunk/ : Contains the active plugin source code (PHP, JS, CSS). This is the active development directory.
- SVN/tags/ and SVN/assets/ : Used for WordPress.org SVN deployment (version tags, banners, icons, and screenshots).
- wp-assets/ : Stores the built production zip files for distribution.
- Website/ : Contains documentation and website-related build files.
- Playwright/ : Contains end-to-end (E2E) automated tests.

### 1.1 Dependency Installation (Base Setup)
- If TypeScript integration is enabled, initialize package.json in the project root and install typescript as a devDependency so npx tsc is executable by running: npm init -y followed by npm install -D typescript
- For the Playwright directory, navigate into the Playwright folder, initialize package.json, install Playwright dependencies, and download the headless browsers by running: cd Playwright followed by npm init -y then npm install -D @playwright/test and finally npx playwright install

---

## 2. Core Plugin Files (Inside SVN/trunk)

### 2.1 Main Plugin File (Location: SVN/trunk/wp-[plugin-slug].php)
Create the core file using the resolved plugin slug and fill out the standard WordPress headers including Plugin Name, Plugin URI pointing to wordpress.org, Description, Version set to 1.0.0, Author, Author URI, License set to GPL v2, and Text Domain matched to the plugin slug. The repository/folder name may start with wp-, but the plugin slug itself must remain plusmagi-markdown without the wp- prefix. The main entry file must be named wp-plusmagi-markdown.php. For all other files created inside the plugin, use the slug name directly, for example plusmagi-markdown.php, plusmagi-markdown.css, or plusmagi-markdown.js, without the wp- prefix. Secure it by adding the PHP line: if ( ! defined( 'ABSPATH' ) ) { exit; }
All user-visible strings in the plugin must be wrapped with WordPress internationalization functions __() or _e() using the plugin slug as the text domain (e.g., __( 'Settings saved.', 'plusmagi-markdown' )). This is a WordPress.org submission requirement.

### 2.2 WordPress.org Readme File (Location: SVN/trunk/readme.txt)
WordPress.org strictly requires a readme.txt file formatted in stable tag standards. The file must start with three equal signs surrounding the Plugin Name, followed by Contributors, Tags, Requires at least (use value from Step 0.2 item 7), Tested up to (use value from Step 0.2 item 8), Stable tag: 1.0.0 (ensuring this strictly matches the version string in the main PHP plugin header), Requires PHP: 7.4, and License: GPLv2 or later. It must also include the Description, Installation steps, and a Changelog section for version 1.0.0.

### 2.3 WordPress Playground Blueprint File (Location: SVN/trunk/blueprint.json)
Required for launching live previews on WordPress Playground and used for build validation by deploy.sh. Define the schema pointing to playground.wordpress.net, set preferredVersions for PHP to 8.2 and WP to latest, enable networking features as true, and outline steps to automatically login and installTheme using the twentytwentyfour theme with activate set to true.

### 2.4 TypeScript Configuration (Optional)
If TypeScript is requested, run the directory creation command: mkdir -p SVN/trunk/assets/ts. Then create a default tsconfig.json file. Inside it, define compilerOptions setting target to ES6, module to commonjs, outDir to ../js, rootDir to ./, strict to true, esModuleInterop to true, skipLibCheck to true, forceConsistentCasingInFileNames to true, and set include to an array containing all .ts wildcards to target script assets.

### 2.5 Uninstall Cleanup File (Location: SVN/trunk/uninstall.php)
Create an uninstall.php file to handle clean data removal when the user deletes the plugin from WordPress. The file must first check if the WP_UNINSTALL_PLUGIN constant is defined, and exit immediately if it is not. Then delete any plugin-specific options using delete_option(), remove any custom database tables using $wpdb->query with DROP TABLE IF EXISTS, and clear any transients using delete_transient(). This is required by WordPress.org review guidelines for plugins that store persistent data.

---

## 3. Automation Scripts (Root Directory)

### 3.1 Build Script (build.sh)
Create a build.sh script in the root directory to package the plugin into a clean zip file. Set it up with set -euo pipefail for safe execution. Define variables for ROOT_DIR, SOURCE_DIR, PM_ASSETS_DIR, WEBSITE_BUILD_DIR, and TEMP_DIR. Add logic to dynamically detect the plugin slug from the workspace. It should automatically check if a tsconfig.json file exists and safely compile TypeScript within a subshell using ( cd "$SOURCE_DIR/assets/ts" && npx tsc -p tsconfig.json ) to prevent directory shifts. It must cleanly copy trunk assets into a temporary environment using rsync -a --exclude="*.ts" --exclude="*.DS_Store" "$SOURCE_DIR/" "$TEMP_DIR/$plugin_slug/" to cleanly preserve hidden files, zip the build package excluding raw .ts assets and .DS_Store system files, and relocate the artifacts into wp-assets using the version number while copying the latest package to Website/build. After extracting the version string, the script must verify it is not empty; if the version is empty or cannot be parsed, print an error message and exit with a non-zero status code to prevent building a package with no version identifier. Make it executable using chmod +x build.sh.

### 3.2 Deployment Script (deploy.sh)
Create a deploy.sh script in the root directory to manage distribution pipelines. It must check for the active version header and ensure blueprint.json is present. Use rsync -av --delete to sync directory graphics like banners and icons from wp-assets to SVN/assets while excluding .svn and zip files. It must read the local subversion configuration; if a .svn tree exists, it should automatically run svn add and svn rm for missing items. It should copy the trunk files into a local SVN/tags folder named after the plugin version and automatically run git tag -a to log an annotated Git release tag matching the version. Make it executable using chmod +x deploy.sh.

---

## 4. E2E Testing Setup (Playwright)

### 4.1 Create Playwright/package.json
Set the project name to plugin-tests, define shortcut scripts for test running using playwright test, and a UI runner using playwright test --ui. Include @playwright/test inside the devDependencies array.

### 4.2 Playwright Configuration (Playwright/playwright.config.js)
Write a standard configuration file importing defineConfig and devices. Set the test directory testDir to ./tests, enable fullyParallel as true, set reporter to html, and configure the use property setting baseURL to process.env.WP_BASE_URL or defaulting to http://localhost:8888. Enable automated traces on a chromium project mapped to the Desktop Chrome device profile. Register the authentication setup project dependency so it runs before the main tests.

### 4.3 Sample Test Suite (Playwright/tests/plugin.spec.js)
Write a base automated test script importing test and expect. Use page.goto('/wp-login.php') to direct the browser to the WordPress login screen (keeping path navigations trailing-slash safe for reliable path matching across custom local proxy loops), and check the assertion using await expect(page).toHaveTitle(/Log In/) to ensure the setup environment is loading correctly.

### 4.4 Admin Authentication Setup (Playwright/tests/auth/admin.setup.js)
Create an authentication setup file that logs in as the WordPress admin user before running tests that require dashboard access. The setup should read WP_ADMIN_USER and WP_ADMIN_PASSWORD from process.env (falling back to the defaults in .env.example), navigate to /wp-login.php, fill in the username and password fields using page.locator('#user_login') and page.locator('#user_pass'), click the submit button, wait for the dashboard to load, then save the authenticated browser state to a storageState JSON file so subsequent tests can reuse the session without re-logging in.

---

## 5. Standard Configuration Files

### 5.1 Git Ignore Rules (.gitignore)
Create a .gitignore file in the root directory listing elements to ignore from git tracking: node_modules/, temp_build/, wp-assets/*.zip, Website/build/, .env, and .DS_Store.

### 5.2 Environment Values Template (.env.example)
Provide basic keys for managing environmental secrets inside E2E testing systems: WP_BASE_URL=http://localhost:8888, WP_ADMIN_USER=admin, and WP_ADMIN_PASSWORD=password.

### 5.3 Editor Configuration (.editorconfig)
Enforce code formatting constraints across all project paths. Set root = true. For markdown (.md) assets, apply an indent_size of 2 and turn trim_trailing_whitespace to false. For general code files, map charset to utf-8, end_of_line to lf, indent_size to 4, tab_width to 4, and set indent_style to tab while enforcing trim_trailing_whitespace as true.

### 5.4 Automatic AI Agent Execution Rights (.vscode/settings.json)
Create this file to populate the chat.tools.terminal.autoApprove configuration block. Set the values to true to allow the AI agent to execute terminal pipeline commands seamlessly without triggering safety approval prompt windows. Grant autoApprove permissions to: ./build.sh, ./deploy.sh, git add, git commit, git push, svn, cp, and git check-ignore.

### 5.5 License File (LICENSE)
Create a LICENSE file in the project root containing the full text of the GNU General Public License v2 or later. This is required for WordPress.org plugin submissions and must match the license declared in the main PHP plugin header and readme.txt.

---

## 6. Secure Coding Guidelines for WordPress (Core PHP)
Strictly enforce that all PHP files created follow these 5 vital security conventions:
1. Capability Checks: Always validate user permissions before committing actions using current_user_can( 'manage_options' ) and abort unauthorized routines using the wp_die function.
2. CSRF Protection (Nonces): Stop unauthorized cross-site form submissions by validating transaction token nonces during form or AJAX handlers via wp_verify_nonce.
3. Sanitization and Escaping: Always wash input values and escape output parameters before processing. Use sanitize_text_field(), sanitize_email(), or absint() on incoming fields. Wrap output blocks immediately before printing using esc_html() for standard strings, esc_attr() for HTML element attributes, and esc_url() for hyperlinks.
4. Database Safety: Guard database queries against SQL Injection vulnerabilities by wrapping database statement formatting logic within the $wpdb->prepare function before calling $wpdb methods.
5. AJAX and REST API Security: For wp_ajax_ action hooks, always verify the nonce using check_ajax_referer() and validate capabilities before processing. For REST API endpoints registered via register_rest_route(), always define a permission_callback that checks current_user_can() with the appropriate capability. Never set permission_callback to __return_true for endpoints that modify data. Use sanitize_callback on all registered REST arguments.

---

## Workflow Execution Order

Direct the AI agent to follow these setup instructions sequentially:
1. Interactive Check: Scan current folders for existing plugin identifiers and confirm the details listed under Step 0.2 directly with the user.
2. Structure Initialization: Build the complete folder tree and trigger a git init execution setup.
3. Scripts and Config Generation: Write the .gitignore, .editorconfig, .env.example, .vscode/settings.json, build.sh, and deploy.sh configurations, then apply execution privileges via chmod +x.
4. Core Files Generation: Construct core .php hooks, readme.txt, blueprint.json, uninstall.php, and the typescript tsconfig environments (plus npm devDependencies) if TypeScript integration is enabled. Use the plugin slug for ordinary internal filenames such as plusmagi-markdown.php or plusmagi-markdown.js, and reserve wp-plusmagi-markdown.php only for the main plugin entry file. Ensure both the main PHP plugin header string and the Stable tag field inside SVN/trunk/readme.txt cleanly match the same version string.
5. Playwright Testing Setup: Scaffold testing files in the Playwright/ folder, write the admin.setup.js framework, run npm install, and download automated browser frameworks via npx playwright install.
6. Functional Feature Coding: Program application code safely matching WordPress secure coding parameters, write localized text markers using internationalization bindings, test code stability via E2E test suites, compile production zips using ./build.sh, and present completion notes to the user.
7. Security Audit: Run npm audit for security vulnerabilities and provide a summary of any issues found, along with recommended fixes or updates to dependencies.
8. Make .npmrc file: Create a .npmrc file to configure npm settings for both production and development environments, ensuring security and performance optimizations are applied.
9. check slug and name: Validate that the plugin slug and name are unique and do not conflict with existing plugins on WordPress.org. If a conflict is detected, prompt the user to choose a different slug or name.
10. copy readme from  README.md  to SVN/trunk/README.md

Create WordPress Plugin Skill (v1.3.0)Description: Creates a new WordPress plugin project with a standardized professional folder structure, automated build scripts, deployment scripts, TypeScript support, security controls, and Playwright E2E testing setup.0. Workflow & Initialization ProcessThe AI Agent must execute these development steps in strict sequential order. Do not skip or parallelize these steps.1Workspace Verification & Info Gathering:Step 1Scan the active folder for existing assets. If existing .php structures are detected, alert the user. Prompt and confirm all 9 required configuration variables.2Directory Scaffolding & Git Init:Step 2Generate the standard repository directory tree layout and execute git init within the root directory.3Base Configuration & Environment Files:Step 3Create base environmental governance configurations: .gitignore, .editorconfig, .env.example, .npmrc, and .vscode/settings.json.4Core Plugin & WordPress.org Files:Step 4Generate the plugin source files inside SVN/trunk/ including plugin-slug.php, readme.txt, blueprint.json, uninstall.php, and TypeScript setups (if enabled).5Automation Scripts Deployment:Step 5Create executable terminal automation modules build.sh and deploy.sh, then apply execution permissions using chmod +x.6Playwright E2E Testing Environment:Step 6Initialize the Playwright/ sub-system, package dependency parameters, localized session authentication steps, and run browser binary installations.7Security Audit & Conflict Check:Step 7Verify that the selected plugin slug does not conflict on WordPress.org, evaluate dependency safety by executing npm audit, and deliver a project initialization report.1. Project Requirements & Context1.1 Initial Requirements QuestionnaireBefore scaffolding any filesystem structures, ensure that the following variables are collected or verified:Plugin Name: The formal display identity of the module (e.g., PlusMagi Site Search).Plugin Slug: The unique lowercased, dash-separated identifier used across systems (e.g., plusmagi-site-search).Description: A concise baseline statement explaining the primary objective of the codebase.WordPress.org Contributor Username: The target author profile moniker for credit tracing within readme.txt logs (e.g., plusmagi).TypeScript Integration: Flag to determine if compilation tasks are required for frontend asset pipelines (Yes / No).Author Name: The registered legal individual or company name maintaining the package (e.g., Pitt Phunsanit).Author URI: The website or portfolio endpoint linked to the developer credentials.Minimum WordPress Version: The oldest stable WordPress core installation required for safe module loading (e.g., 6.0).Tested Up To: The maximum stable WordPress core release milestone validated as fully functional (e.g., 6.8).1.2 Repository Directory StructurePlaintext├── .vscode/
│   └── settings.json
├── Playwright/
│   ├── tests/
│   │   ├── auth/
│   │   │   └── admin.setup.js
│   │   └── plugin.spec.js
│   ├── package.json
│   └── playwright.config.js
├── SVN/
│   ├── assets/          # WP.org store elements (banners, icons)
│   ├── tags/            # Rigidly labeled historical release versions
│   └── trunk/           # Active staging development files
│       ├── assets/
│       │   ├── js/
│       │   └── ts/      # Optional TypeScript files
│       ├── blueprint.json
│       ├── plugin-slug.php
│       ├── readme.txt
│       └── uninstall.php
├── Website/             # Supplemental documentation pages
├── wp-assets/           # Distribution zip outputs
├── .editorconfig
├── .env.example
├── .gitignore
├── .npmrc
├── build.sh
├── deploy.sh
└── LICENSE
2. Standard Configuration Files2.1 Git Target Exclusion (.gitignore)Plaintextnode_modules/
temp_build/
wp-assets/*.zip
Website/build/
.env
.DS_Store
2.2 Environment Variables Sample (.env.example)PlaintextWP_BASE_URL=http://localhost:8888
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=password
2.3 Editor Enforcement Rules (.editorconfig)Ini, TOMLroot = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 4
tab_width = 4
indent_style = tab
trim_trailing_whitespace = true

[*.md]
indent_size = 2
trim_trailing_whitespace = false
2.4 Node Package Runtime Instructions (.npmrc)Ini, TOMLengine-strict=true
audit=true
fund=false
2.5 VS Code Agent Command Permissions (.vscode/settings.json)JSON{
  "chat.tools.terminal.autoApprove": [
    "./build.sh",
    "./deploy.sh",
    "git add",
    "git commit",
    "git push",
    "svn",
    "cp",
    "git check-ignore"
  ]
}
3. Core Plugin Architecture (SVN/trunk/)3.1 Main Class Entry Point Header (SVN/trunk/plugin-slug.php)Every executable PHP file must be protected by directory execution blocks and support localization contexts:PHP<?php
/**
 * Plugin Name:       [Plugin Name]
 * Plugin URI:        https://wordpress.org/plugins/[plugin-slug]/
 * Description:       [Description]
 * Version:           1.0.0
 * Author:            [Author Name]
 * Author URI:        [Author URI]
 * License:           GPL v2 or later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       [plugin-slug]
 * Domain Path:       /languages
 */

// Security Gate: Terminate execution if loaded directly outside WordPress
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// All user-facing strings must utilize translation layers
// Example: __( 'Settings saved.', 'plugin-slug' )
3.2 WordPress.org Readme Architecture (SVN/trunk/readme.txt)Plaintext=== [Plugin Name] ===
Contributors: [Contributor Username]
Tags: wordpress, plugin
Requires at least: [Min WP Version]
Tested up to: [Tested Up To]
Stable tag: 1.0.0
Requires PHP: 7.4
License: GPLv2 or later

== Description ==
[Description]

== Installation ==
1. Upload the plugin folder to the `/wp-content/plugins/` directory.
2. Activate the plugin through the 'Plugins' menu in WordPress.

== Changelog ==
= 1.0.0 =
* Initial release.
3.3 Complete Data Erasure Strategy (SVN/trunk/uninstall.php)PHP<?php
// Terminate immediately if execution is triggered outside of WordPress core operations
if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

// TODO: Explicitly clear system options, transient caches, and custom database structures here
// delete_option( 'plugin_options_name' );
// delete_transient( 'plugin_transient_name' );
3.4 WordPress Playground Integration Blueprint (SVN/trunk/blueprint.json)JSON{
  "$schema": "https://playground.wordpress.net/blueprint-schema.json",
  "preferredVersions": {
    "php": "8.2",
    "wp": "latest"
  },
  "networking": true,
  "steps": [
    {
      "step": "login",
      "username": "admin",
      "password": "password"
    },
    {
      "step": "installTheme",
      "themeZipUrl": "https://downloads.wordpress.org/theme/twentytwentyfour.latest.zip",
      "options": {
        "activate": true
      }
    }
  ]
}
4. Automation & Bundling Framework4.1 Production Packager (build.sh)Bash#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/SVN/trunk"
WP_ASSETS_DIR="$ROOT_DIR/wp-assets"
WEBSITE_BUILD_DIR="$ROOT_DIR/Website/build"
TEMP_DIR="$ROOT_DIR/temp_build"

PLUGIN_SLUG="[plugin-slug]"

echo "Building production package for $PLUGIN_SLUG..."

# Execute TypeScript build if configuration framework exists
if [ -f "$SOURCE_DIR/assets/ts/tsconfig.json" ]; then
    echo "Compiling TypeScript assets..."
    ( cd "$SOURCE_DIR/assets/ts" && npx tsc -p tsconfig.json )
fi

# Reset staging workspaces
rm -rf "$TEMP_DIR" && mkdir -p "$TEMP_DIR/$PLUGIN_SLUG"
mkdir -p "$WP_ASSETS_DIR" "$WEBSITE_BUILD_DIR"

# Validate version presence
VERSION=$(grep "Version:" "$SOURCE_DIR/$PLUGIN_SLUG.php" | awk '{print $NF}')
if [ -z "$VERSION" ]; then
    echo "Error: Version token could not be resolved from main package metadata." >&2
    exit 1
fi

# Synchronize assets excluding tracking or raw uncompiled resources
rsync -a --exclude="*.ts" --exclude="*.DS_Store" "$SOURCE_DIR/" "$TEMP_DIR/$PLUGIN_SLUG/"

# Compile artifacts into structured targets
( cd "$TEMP_DIR" && zip -r "$WP_ASSETS_DIR/$PLUGIN_SLUG-$VERSION.zip" "$PLUGIN_SLUG" )
cp "$WP_ASSETS_DIR/$PLUGIN_SLUG-$VERSION.zip" "$WEBSITE_BUILD_DIR/$PLUGIN_SLUG-latest.zip"

rm -rf "$TEMP_DIR"
echo "Build complete: $WP_ASSETS_DIR/$PLUGIN_SLUG-$VERSION.zip"
4.2 SVN Pipeline Synchronizer (deploy.sh)Bash#!/bin/bash
set -euo pipefail

if [ ! -f "SVN/trunk/blueprint.json" ]; then
    echo "Error: blueprint.json must exist in staging paths before release deployment." >&2
    exit 1
fi

PLUGIN_SLUG="[plugin-slug]"
VERSION=$(grep "Version:" "SVN/trunk/$PLUGIN_SLUG.php" | awk '{print $NF}')

echo "Syncing production tag release $VERSION with WordPress.org servers..."

# Sync catalog listing presentation images
rsync -av --delete --exclude=".svn" --exclude="*.zip" wp-assets/ SVN/assets/

# Deploy historical staging snapshot
mkdir -p "SVN/tags/$VERSION"
rsync -av --delete --exclude=".svn" SVN/trunk/ "SVN/tags/$VERSION/"

# Automated SVN lifecycle resolution
if [ -d "SVN/.svn" ]; then
    cd SVN
    svn add --force .
    svn status | grep '!' | awk '{print $2}' | xargs -r svn rm
    cd ..
fi

# Coordinate standard Git trace tags
git tag -a "v$VERSION" -m "Release version $VERSION"
echo "Deployment pipelines successfully finalized."
5. End-to-End Testing Infrastructure (Playwright/)5.1 Test Framework Configuration (Playwright/playwright.config.js)JavaScriptimport { defineConfig, devices } from '@playwright/test';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  reporter: 'html',
  use: {
    baseURL: process.env.WP_BASE_URL || 'http://localhost:8888',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'setup',
      testMatch: /.*\.setup\.js/,
    },
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], storageState: 'Playwright/.auth/user.json' },
      dependencies: ['setup'],
    },
  ],
});
5.2 Session Retention Sequence (Playwright/tests/auth/admin.setup.js)JavaScriptimport { test as setup, expect } from '@playwright/test';

setup('authenticate as admin', async ({ page }) => {
  await page.goto('/wp-login.php');
  await page.locator('#user_login').fill(process.env.WP_ADMIN_USER || 'admin');
  await page.locator('#user_pass').fill(process.env.WP_ADMIN_PASSWORD || 'password');
  await page.click('#wp-submit');

  await page.waitForURL('**/wp-admin/index.php');
  await page.context().storageState({ path: 'Playwright/.auth/user.json' });
});
5.3 Baseline Integration Route Test (Playwright/tests/plugin.spec.js)JavaScriptimport { test, expect } from '@playwright/test';

test('verify login entry point availability', async ({ page }) => {
  await page.goto('/wp-login.php');
  await expect(page).toHaveTitle(/Log In/);
});
6. Secure Coding Guidelines for WordPress (Core PHP)All functional domain features implemented inside the plugin structure must fully conform to these 5 distinct security controls:Capability Checks: Wrap all sensitive or structural logic in permission checks using current_user_can( 'manage_options' ) (or the contextual operational capability required). Terminate unauthorized interactions using wp_die().CSRF Prevention (Nonces): Defend transactional pathways against cross-site script request forgeries. Generate verification vectors using wp_create_nonce(), and process validation rules within incoming handlers using wp_verify_nonce() or check_ajax_referer().Data Sanitization & Output Escaping:Sanitize all inbound data using targeted sanitization wrappers such as sanitize_text_field(), sanitize_email(), or absint().Neutralize output injection vectors at the direct printing execution point using targeted escape wrappers: esc_html() for content structures, esc_attr() for structural tag values, and esc_url() for hyperlinked addresses.SQL Injection Countermeasures: Prevent raw database processing attacks. Never interpolate variables directly into SQL statements. Always combine query processing operations using the $wpdb->prepare() parameter masking layout.REST API Endpoint Authorization: Explicitly provide a valid permission_callback configuration property inside every custom register_rest_route() structure. Do not map __return_true values to routes that allow mutations or data changes, and secure all endpoint parameters via sanitize_callback.7. Documentation Sync RuleReadMe Mirroring: Upon completing the execution of the project generation pipeline, the AI Agent must extract the project overview and operational descriptions from the root README.md and save an identical mirror file at SVN/trunk/README.md. This ensures consistent documentation compliance for standard package structures.

Create WordPress Plugin Skill (v1.3.0)Description:
Creates a new WordPress plugin project with a standardized professional folder structure, automated build scripts, deployment scripts, TypeScript support, security controls, and Playwright E2E testing setup.0. Workflow & Initialization ProcessThe AI Agent must execute these development steps in strict sequential order. Do not skip or parallelize these steps.1Workspace Verification & Info Gathering:Step 1Scan the active folder for existing assets. If existing .php structures are detected, alert the user. Prompt and confirm all 9 required configuration variables.2Directory Scaffolding & Git Init:Step 2Generate the standard repository directory tree layout and execute git init within the root directory.3Base Configuration & Environment Files:Step 3Create base environmental governance configurations: .gitignore, .editorconfig, .env.example, .npmrc, and .vscode/settings.json.4Core Plugin & WordPress.org Files:Step 4Generate the plugin source files inside SVN/trunk/ including plugin-slug.php, readme.txt, blueprint.json, uninstall.php, and TypeScript setups (if enabled).5Automation Scripts Deployment:Step 5Create executable terminal automation modules build.sh and deploy.sh, then apply execution permissions using chmod +x.6Playwright E2E Testing Environment:Step 6Initialize the Playwright/ sub-system, package dependency parameters, localized session authentication steps, and run browser binary installations.7Security Audit & Conflict Check:Step 7Verify that the selected plugin slug does not conflict on WordPress.org, evaluate dependency safety by executing npm audit, and deliver a project initialization report.1. Project Requirements & Context1.1 Initial Requirements QuestionnaireBefore scaffolding any filesystem structures, ensure that the following variables are collected or verified:Plugin Name: The formal display identity of the module (e.g., PlusMagi Site Search).Plugin Slug: The unique lowercased, dash-separated identifier used across systems (e.g., plusmagi-site-search).Description: A concise baseline statement explaining the primary objective of the codebase.WordPress.org Contributor Username: The target author profile moniker for credit tracing within readme.txt logs (e.g., plusmagi).TypeScript Integration: Flag to determine if compilation tasks are required for frontend asset pipelines (Yes / No).Author Name: The registered legal individual or company name maintaining the package (e.g., Pitt Phunsanit).Author URI: The website or portfolio endpoint linked to the developer credentials.Minimum WordPress Version: The oldest stable WordPress core installation required for safe module loading (e.g., 6.0).Tested Up To: The maximum stable WordPress core release milestone validated as fully functional (e.g., 6.8).1.2 Repository Directory StructurePlaintext├── .vscode/
│   └── settings.json
├── Playwright/
│   ├── tests/
│   │   ├── auth/
│   │   │   └── admin.setup.js
│   │   └── plugin.spec.js
│   ├── package.json
│   └── playwright.config.js
├── SVN/
│   ├── assets/          # WP.org store elements (banners, icons)
│   ├── tags/            # Rigidly labeled historical release versions
│   └── trunk/           # Active staging development files
│       ├── assets/
│       │   ├── js/
│       │   └── ts/      # Optional TypeScript files
│       ├── blueprint.json
│       ├── plugin-slug.php
│       ├── readme.txt
│       └── uninstall.php
├── Website/             # Supplemental documentation pages
├── wp-assets/           # Distribution zip outputs
├── .editorconfig
├── .env.example
├── .gitignore
├── .npmrc
├── build.sh
├── deploy.sh
└── LICENSE
2. Standard Configuration Files2.1 Git Target Exclusion (.gitignore)Plaintextnode_modules/
temp_build/
wp-assets/*.zip
Website/build/
.env
.DS_Store
2.2 Environment Variables Sample (.env.example)PlaintextWP_BASE_URL=http://localhost:8888
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=password
2.3 Editor Enforcement Rules (.editorconfig)Ini, TOMLroot = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 4
tab_width = 4
indent_style = tab
trim_trailing_whitespace = true

[*.md]
indent_size = 2
trim_trailing_whitespace = false
2.4 Node Package Runtime Instructions (.npmrc)Ini, TOMLengine-strict=true
audit=true
2.5 VS Code Agent Command Permissions (.vscode/settings.json)JSON{
  "chat.tools.terminal.autoApprove": [
    "./build.sh",
    "./deploy.sh",
    "git add",
    "git commit",
    "git push",
    "svn",
    "cp",
    "git check-ignore"
  ]
}
3. Core Plugin Architecture (SVN/trunk/)3.1 Main Class Entry Point Header (SVN/trunk/plugin-slug.php)Every executable PHP file must be protected by directory execution blocks and support localization contexts:PHP<?php
/**
 * Plugin Name:       [Plugin Name]
 * Plugin URI:        https://wordpress.org/plugins/[plugin-slug]/
 * Description:       [Description]
 * Version:           1.0.0
 * Author:            [Author Name]
 * Author URI:        [Author URI]
 * License:           GPL v2 or later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       [plugin-slug]
 * Domain Path:       /languages
 */

// Security Gate: Terminate execution if loaded directly outside WordPress
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// All user-facing strings must utilize translation layers
// Example: __( 'Settings saved.', 'plugin-slug' )
3.2 WordPress.org Readme Architecture (SVN/trunk/readme.txt)Plaintext=== [Plugin Name] ===
Contributors: [Contributor Username]
Tags: wordpress, plugin
Requires at least: [Min WP Version]
Tested up to: [Tested Up To]
Stable tag: 1.0.0
Requires PHP: 7.4
License: GPLv2 or later

== Description ==
[Description]

== Installation ==
1. Upload the plugin folder to the `/wp-content/plugins/` directory.
2. Activate the plugin through the 'Plugins' menu in WordPress.

== Changelog ==
= 1.0.0 =
* Initial release.
3.3 Complete Data Erasure Strategy (SVN/trunk/uninstall.php)PHP<?php
// Terminate immediately if execution is triggered outside of WordPress core operations
if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

// TODO: Explicitly clear system options, transient caches, and custom database structures here
// delete_option( 'plugin_options_name' );
// delete_transient( 'plugin_transient_name' );
3.4 WordPress Playground Integration Blueprint (SVN/trunk/blueprint.json)JSON{
  "$schema": "https://playground.wordpress.net/blueprint-schema.json",
  "preferredVersions": {
    "php": "8.2",
    "wp": "latest"
  },
  "networking": true,
  "steps": [
    {
      "step": "login",
      "username": "admin",
      "password": "password"
    },
    {
      "step": "installTheme",
      "themeZipUrl": "https://downloads.wordpress.org/theme/twentytwentyfour.latest.zip",
      "options": {
        "activate": true
      }
    }
  ]
}
4. Automation & Bundling Framework4.1 Production Packager (build.sh)Bash#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/SVN/trunk"
WP_ASSETS_DIR="$ROOT_DIR/wp-assets"
WEBSITE_BUILD_DIR="$ROOT_DIR/Website/build"
TEMP_DIR="$ROOT_DIR/temp_build"

PLUGIN_SLUG="[plugin-slug]"

echo "Building production package for $PLUGIN_SLUG..."

# Execute TypeScript build if configuration framework exists
if [ -f "$SOURCE_DIR/assets/ts/tsconfig.json" ]; then
    echo "Compiling TypeScript assets..."
    ( cd "$SOURCE_DIR/assets/ts" && npx tsc -p tsconfig.json )
fi

# Reset staging workspaces
rm -rf "$TEMP_DIR" && mkdir -p "$TEMP_DIR/$PLUGIN_SLUG"
mkdir -p "$WP_ASSETS_DIR" "$WEBSITE_BUILD_DIR"

# Validate version presence
VERSION=$(grep "Version:" "$SOURCE_DIR/$PLUGIN_SLUG.php" | awk '{print $NF}')
if [ -z "$VERSION" ]; then
    echo "Error: Version token could not be resolved from main package metadata." >&2
    exit 1
fi

# Synchronize assets excluding tracking or raw uncompiled resources
rsync -a --exclude="*.ts" --exclude="*.DS_Store" "$SOURCE_DIR/" "$TEMP_DIR/$PLUGIN_SLUG/"

# Compile artifacts into structured targets
( cd "$TEMP_DIR" && zip -r "$WP_ASSETS_DIR/$PLUGIN_SLUG-$VERSION.zip" "$PLUGIN_SLUG" )
cp "$WP_ASSETS_DIR/$PLUGIN_SLUG-$VERSION.zip" "$WEBSITE_BUILD_DIR/$PLUGIN_SLUG-latest.zip"

rm -rf "$TEMP_DIR"
echo "Build complete: $WP_ASSETS_DIR/$PLUGIN_SLUG-$VERSION.zip"
4.2 SVN Pipeline Synchronizer (deploy.sh)Bash#!/bin/bash
set -euo pipefail

if [ ! -f "SVN/trunk/blueprint.json" ]; then
    echo "Error: blueprint.json must exist in staging paths before release deployment." >&2
    exit 1
fi

PLUGIN_SLUG="[plugin-slug]"
VERSION=$(grep "Version:" "SVN/trunk/$PLUGIN_SLUG.php" | awk '{print $NF}')

echo "Syncing production tag release $VERSION with WordPress.org servers..."

# Sync catalog listing presentation images
rsync -av --delete --exclude=".svn" --exclude="*.zip" wp-assets/ SVN/assets/

# Deploy historical staging snapshot
mkdir -p "SVN/tags/$VERSION"
rsync -av --delete --exclude=".svn" SVN/trunk/ "SVN/tags/$VERSION/"

# Automated SVN lifecycle resolution
if [ -d "SVN/.svn" ]; then
    cd SVN
    svn add --force .
    svn status | grep '!' | awk '{print $2}' | xargs -r svn rm
    cd ..
fi

# Coordinate standard Git trace tags
git tag -a "v$VERSION" -m "Release version $VERSION"
echo "Deployment pipelines successfully finalized."
5. End-to-End Testing Infrastructure (Playwright/)5.1 Test Framework Configuration (Playwright/playwright.config.js)JavaScriptimport { defineConfig, devices } from '@playwright/test';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  reporter: 'html',
  use: {
    baseURL: process.env.WP_BASE_URL || 'http://localhost:8888',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'setup',
      testMatch: /.*\.setup\.js/,
    },
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], storageState: 'Playwright/.auth/user.json' },
      dependencies: ['setup'],
    },
  ],
});
5.2 Session Retention Sequence (Playwright/tests/auth/admin.setup.js)JavaScriptimport { test as setup, expect } from '@playwright/test';

setup('authenticate as admin', async ({ page }) => {
  await page.goto('/wp-login.php');
  await page.locator('#user_login').fill(process.env.WP_ADMIN_USER || 'admin');
  await page.locator('#user_pass').fill(process.env.WP_ADMIN_PASSWORD || 'password');
  await page.click('#wp-submit');

  await page.waitForURL('**/wp-admin/index.php');
  await page.context().storageState({ path: 'Playwright/.auth/user.json' });
});
5.3 Baseline Integration Route Test (Playwright/tests/plugin.spec.js)JavaScriptimport { test, expect } from '@playwright/test';

test('verify login entry point availability', async ({ page }) => {
  await page.goto('/wp-login.php');
  await expect(page).toHaveTitle(/Log In/);
});
6. Secure Coding Guidelines for WordPress (Core PHP)All functional domain features implemented inside the plugin structure must fully conform to these 5 distinct security controls:Capability Checks: Wrap all sensitive or structural logic in permission checks using current_user_can( 'manage_options' ) (or the contextual operational capability required). Terminate unauthorized interactions using wp_die().CSRF Prevention (Nonces): Defend transactional pathways against cross-site script request forgeries. Generate verification vectors using wp_create_nonce(), and process validation rules within incoming handlers using wp_verify_nonce() or check_ajax_referer().Data Sanitization & Output Escaping:Sanitize all inbound data using targeted sanitization wrappers such as sanitize_text_field(), sanitize_email(), or absint().Neutralize output injection vectors at the direct printing execution point using targeted escape wrappers: esc_html() for content structures, esc_attr() for structural tag values, and esc_url() for hyperlinked addresses.SQL Injection Countermeasures: Prevent raw database processing attacks. Never interpolate variables directly into SQL statements. Always combine query processing operations using the $wpdb->prepare() parameter masking layout.REST API Endpoint Authorization: Explicitly provide a valid permission_callback configuration property inside every custom register_rest_route() structure. Do not map __return_true values to routes that allow mutations or data changes, and secure all endpoint parameters via sanitize_callback.7. Documentation Sync RuleReadMe Mirroring: Upon completing the execution of the project generation pipeline, the AI Agent must extract the project overview and operational descriptions from the root README.md and save an identical mirror file at SVN/trunk/README.md. This ensures consistent documentation compliance for standard package structures.