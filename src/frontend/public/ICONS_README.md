# Icon Files

This directory should contain the following icon files:

## Required Icons

- `favicon.ico` - Browser tab icon (16x16, 32x32, 48x48)
- `logo192.png` - PWA icon 192x192px
- `logo512.png` - PWA icon 512x512px

## Current State

SVG versions are provided as templates:
- `favicon.svg` - Vector version of favicon

## Generating PNG Icons

To generate the required PNG icons from the SVG:

### Using ImageMagick:
```bash
convert favicon.svg -resize 192x192 logo192.png
convert favicon.svg -resize 512x512 logo512.png
convert favicon.svg -resize 48x48 favicon.ico
```

### Using Inkscape:
```bash
inkscape favicon.svg -w 192 -h 192 -o logo192.png
inkscape favicon.svg -w 512 -h 512 -o logo512.png
```

### Online Tools:
- https://realfavicongenerator.net/
- https://favicon.io/

## Notes

The manifest.json references these files. Ensure they exist before deployment.
