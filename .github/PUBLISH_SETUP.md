# GitHub Actions Pub.dev Publishing Setup

This repository includes a GitHub Actions workflow that automatically publishes the package to pub.dev when code is pushed to the `main` branch.

## Setup Instructions

### 1. Generate pub.dev Credentials

First, you need to generate credentials for pub.dev publishing:

```bash
# On your local machine, run:
flutter pub token add https://pub.dev

# This will open your browser to authenticate with pub.dev
# After authentication, credentials will be stored locally
```

### 2. Get Credentials JSON

Extract the credentials from your local machine:

```bash
# The credentials are stored in:
# - macOS/Linux: ~/.pub-cache/credentials.json
# - Windows: %APPDATA%\Pub\Cache\credentials.json

# Copy the content of this file
cat ~/.pub-cache/credentials.json
```

### 3. Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `PUB_CREDENTIALS`
5. Value: Paste the entire contents of your `credentials.json` file
6. Click **Add secret**

### 4. How the Workflow Works

The workflow will trigger on:
- Push to `main` branch
- Manual trigger via GitHub UI

The workflow:
1. ✅ Checks out the code
2. ✅ Sets up Flutter environment
3. ✅ Installs dependencies
4. ✅ Verifies code formatting
5. ✅ Runs static analysis
6. ✅ Executes tests
7. ✅ Checks if the current version already exists on pub.dev
8. ✅ Only publishes if it's a new version
9. ✅ Skips publishing if version already exists

### 5. Version Management

- The workflow automatically detects the version from `pubspec.yaml`
- It checks if this version already exists on pub.dev
- Only new versions are published
- If the version exists, the workflow skips publishing

### 6. Manual Publishing

You can also trigger the workflow manually:
1. Go to **Actions** tab in your GitHub repository
2. Select **Publish to pub.dev** workflow
3. Click **Run workflow**
4. Select the branch and click **Run workflow**

## Security Notes

- ⚠️ Never commit `credentials.json` to your repository
- ✅ Always use GitHub Secrets for sensitive data
- ✅ The workflow uses `--force` flag to avoid interactive prompts
- ✅ Dry run is performed before actual publishing

## Troubleshooting

**Issue**: Workflow fails with authentication error
**Solution**: Regenerate pub.dev credentials and update the GitHub secret

**Issue**: Version already exists error
**Solution**: Update version in `pubspec.yaml` and `CHANGELOG.md`

**Issue**: Tests fail
**Solution**: Fix tests before pushing to main branch