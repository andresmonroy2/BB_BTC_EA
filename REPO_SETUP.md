Repository setup and push instructions

This document explains how to initialize the local repository, create branches, and push to GitHub. Use these steps on your primary development machine (Windows or Linux).

1) Basic initialization (if repository not yet a git repo)

```bash
# from project root
git init
git add .
git commit -m "Initial commit: BB_BTC_EA v1.0"
# Create main branch if needed
git branch -M main
# Add remote and push (replace <url> with your GitHub repo URL)
git remote add origin <url>
git push -u origin main
```

2) Recommended branch model

- `main`: release-ready code
- `develop`: integration branch
- feature branches: `feature/<name>`

3) Releases and tagging

```bash
git tag -a v1.0 -m "Release v1.0"
git push origin v1.0
```

4) Large files and build artifacts

Binary files (e.g., `.ex5`, `.pdf`) should use Git LFS or be stored in `releases/`. To enable Git LFS:

```bash
# install Git LFS
git lfs install
# track ex5 and pdf
git lfs track "*.ex5"
git lfs track "*.pdf"
git add .gitattributes
```

5) Windows / MetaEditor compilation notes (for CI)

- MetaEditor is available only on Windows. For CI we recommend a `windows-latest` runner or a self-hosted Windows runner with MT5 installed.
- CI step example (high-level): run `MetaEditor.exe /compile:"path\\to\\src\\BB_BTC_EA_v8_1.mq5"` and capture the compile output.

6) Security & credentials

- Use an SSH key or a personal access token (PAT) with minimal scopes for CI pushes.
- Do not commit secrets. Store credentials in GitHub Secrets if CI needs them.

7) Next steps

- Add a GitHub Actions workflow to compile on Windows (`.github/workflows/compile.yml`).
- Add `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md` for team collaboration.
