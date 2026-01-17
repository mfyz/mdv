# Publishing Guide

## Local Development (Editable Install)

Link the package globally so the `mdv` command uses your local working copy:

```bash
pipx install -e .
```

Changes to the code are immediately available - no reinstall needed.

### Uninstall

```bash
pipx uninstall mdv-live
```

### Reinstall (if you change pyproject.toml or package structure)

```bash
pipx uninstall mdv-live && pipx install -e .
```

## Publish to PyPI

### One-time setup

1. Create account at https://pypi.org/account/register/
2. Create API token at https://pypi.org/manage/account/token/
3. Install build tools:
   ```bash
   pipx install build
   pipx install twine
   ```

### Publish

```bash
# Build
python3 -m build

# Upload (username: __token__, password: your pypi-xxx token)
twine upload dist/*
```

### Publish updates

1. Update version in `src/mdv/__init__.py` and `pyproject.toml`
2. Rebuild and upload:
   ```bash
   rm -rf dist/
   python3 -m build
   twine upload dist/*
   ```

## Install from PyPI

```bash
pipx install mdv-live
```
