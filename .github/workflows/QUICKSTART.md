# GitHub Workflows Quick Reference

## 🚀 Quick Start

### For Contributors

```bash
# Before creating a PR
make lint                 # Lint proto files
make format              # Format proto files
make generate            # Generate clients
make test                # Run tests

# Check for breaking changes
buf breaking --against .git#branch=main,subdir=proto
```

### For Maintainers

```bash
# Create a release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Create a pre-release
git tag -a v1.0.0-beta.1 -m "Beta Release 1"
git push origin v1.0.0-beta.1
```

## 📊 Workflow Status Badges

Add these to your README:

```markdown
[![CI/CD](https://github.com/geniustechspace/api-contracts/actions/workflows/ci.yml/badge.svg)](https://github.com/geniustechspace/api-contracts/actions/workflows/ci.yml)
[![Security](https://github.com/geniustechspace/api-contracts/actions/workflows/security.yml/badge.svg)](https://github.com/geniustechspace/api-contracts/actions/workflows/security.yml)
[![Docs](https://github.com/geniustechspace/api-contracts/actions/workflows/docs.yml/badge.svg)](https://github.com/geniustechspace/api-contracts/actions/workflows/docs.yml)
```

## 🔧 Workflow Triggers

| Workflow      | Auto Trigger     | Manual | Schedule  |
| ------------- | ---------------- | ------ | --------- |
| CI/CD         | ✅ Push, PR      | ✅     | ❌        |
| Contracts     | ✅ Proto changes | ✅     | ❌        |
| Publish       | ✅ Tags          | ✅     | ❌        |
| Release       | ✅ Tags          | ✅     | ❌        |
| Documentation | ✅ Main push     | ✅     | ✅ Weekly |
| Security      | ✅ Push          | ✅     | ✅ Daily  |
| Dependencies  | ❌               | ✅     | ✅ Weekly |

## 🔐 Required Secrets

### Essential (for publishing)

```
CARGO_REGISTRY_TOKEN      # Rust/crates.io
PYPI_API_TOKEN           # Python/PyPI
NPM_TOKEN                # TypeScript/NPM
```

### Maven (Java publishing)

```
OSSRH_USERNAME           # Maven Central username
OSSRH_TOKEN              # Maven Central token
MAVEN_GPG_PRIVATE_KEY    # GPG signing key
MAVEN_GPG_PASSPHRASE     # GPG passphrase
```

### Optional

```
CODECOV_TOKEN            # Code coverage (optional)
```

## ⚡ Common Tasks

### Manual Workflow Dispatch

1. Go to **Actions** tab
2. Select desired workflow
3. Click **Run workflow**
4. Select branch and fill inputs
5. Click **Run workflow**

### Skip CI for a Commit

```bash
git commit -m "docs: update readme [skip ci]"
```

### Skip Breaking Change Check

```bash
git commit -m "feat: add new field [buf skip breaking]"
# ⚠️ Use with caution!
```

### Trigger Specific Workflow

```bash
# Trigger documentation build
git commit --allow-empty -m "docs: rebuild documentation"
git push

# Trigger security scan
gh workflow run security.yml
```

## 📦 Release Process

### Standard Release

```bash
# 1. Ensure main is up to date
git checkout main
git pull origin main

# 2. Create and push tag
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3

# 3. Workflows automatically:
#    - Run full CI
#    - Generate changelog
#    - Publish packages
#    - Create GitHub release
#    - Update documentation
```

### Pre-release

```bash
# Alpha
git tag -a v1.2.3-alpha.1 -m "Alpha 1"
git push origin v1.2.3-alpha.1

# Beta
git tag -a v1.2.3-beta.1 -m "Beta 1"
git push origin v1.2.3-beta.1

# Release Candidate
git tag -a v1.2.3-rc.1 -m "RC 1"
git push origin v1.2.3-rc.1
```

### Hotfix Release

```bash
# 1. Create hotfix branch from release
git checkout -b hotfix/1.2.4 release/1.2
git cherry-pick <commit-sha>

# 2. Tag and push
git tag -a v1.2.4 -m "Hotfix v1.2.4"
git push origin v1.2.4

# 3. Merge back to main
git checkout main
git merge hotfix/1.2.4
git push origin main
```

## 🐛 Troubleshooting

### Workflow Fails on Proto Validation

```bash
# Format proto files
buf format -w

# Check for errors
buf lint

# Check breaking changes
buf breaking --against .git#branch=main,subdir=proto
```

### Client Generation Fails

```bash
# Install/update buf
brew install buf  # macOS
# OR
curl -sSL https://github.com/bufbuild/buf/releases/latest/download/buf-$(uname -s)-$(uname -m) -o /usr/local/bin/buf

# Regenerate locally
buf generate
```

### Package Publishing Fails

```bash
# Verify secrets are set in GitHub repo settings
# Check package version doesn't already exist

# Test locally:
# Rust
cargo publish --dry-run

# Python
python -m build
twine check dist/*

# TypeScript
npm publish --dry-run
```

### Security Vulnerabilities Detected

```bash
# Check Security tab in GitHub repo

# For Rust
cargo audit

# For Python
pip install safety
safety check

# For Go
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...

# For Node
npm audit
```

## 📈 Monitoring

### Check Workflow Status

```bash
# Using GitHub CLI
gh run list
gh run view <run-id>
gh run watch
```

### View Workflow Logs

```bash
gh run view <run-id> --log
gh run view <run-id> --log-failed
```

### Cancel Running Workflow

```bash
gh run cancel <run-id>
```

## 🔄 Workflow Dependencies

```
Push/PR → contracts.yaml → ci.yml → security.yml
                ↓
            Validation

Tag Push → release.yml → ci.yml + publish.yaml → GitHub Release
              ↓
          Full Pipeline

Main Push → docs.yml → GitHub Pages
             ↓
        Documentation

Schedule → security.yml (daily)
        → dependencies.yml (weekly)
        → docs.yml (weekly)
```

## 🎯 Best Practices

### ✅ DO

- Run local validation before pushing
- Write clear commit messages (conventional commits)
- Test client generation locally
- Review breaking changes carefully
- Keep dependencies up to date
- Monitor security scans
- Document breaking changes in PR description

### ❌ DON'T

- Skip CI without good reason
- Force push to protected branches
- Ignore breaking change warnings
- Commit generated code
- Push without testing locally
- Ignore security vulnerabilities
- Create releases without changelog

## 📚 Additional Resources

- [Full Documentation](./README.md)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Buf Documentation](https://buf.build/docs)
- [Conventional Commits](https://www.conventionalcommits.org/)

## 🆘 Getting Help

1. Check workflow logs in Actions tab
2. Review PR comments from workflows
3. Check Security tab for vulnerability details
4. Create an issue if problem persists
5. Contact DevOps team

---

**Quick Links**:

- [Actions](../../actions)
- [Security](../../security)
- [Releases](../../releases)
- [Issues](../../issues)
