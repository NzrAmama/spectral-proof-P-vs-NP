name: Release

on:
  push:
    tags:
      - 'v*' # Example: v2.0.0

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install build twine

    - name: Build package
      run: python -m build

    # ✅ استخراج ملاحظات الإصدار من CHANGELOG.md تلقائيًا
    - name: Extract Release Notes
      id: extract_notes
      run: |
        VERSION=${GITHUB_REF#refs/tags/}
        awk "/## \\[$VERSION\\]/,/^## /" CHANGELOG.md | sed '1d;$d' > RELEASE_NOTES.md
        echo "notes<<EOF" >> $GITHUB_OUTPUT
        cat RELEASE_NOTES.md >> $GITHUB_OUTPUT
        echo "EOF" >> $GITHUB_OUTPUT

    - name: Create GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        tag_name: ${{ github.ref }}
        name: Release ${{ github.ref }}
        body: ${{ steps.extract_notes.outputs.notes }}
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

    - name: Upload to PyPI
      env:
        TWINE_USERNAME: __token__
        TWINE_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
      run: twine upload dist/*
