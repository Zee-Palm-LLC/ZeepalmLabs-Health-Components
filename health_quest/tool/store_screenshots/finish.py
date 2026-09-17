import glob
import os

from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "store", "app_store")
LARGE = os.path.join(ROOT, "iphone_6_9")
SMALL = os.path.join(ROOT, "iphone_6_5")


def fit_6_5(image):
    width, height = 1242, 2688
    scaled = image.resize((width, round(image.height * width / image.width)), Image.LANCZOS)
    top = (scaled.height - height) // 2
    return scaled.crop((0, top, width, top + height))


def main():
    os.makedirs(SMALL, exist_ok=True)
    shots = sorted(glob.glob(os.path.join(LARGE, "*.png")))
    for path in shots:
        image = Image.open(path).convert("RGB")
        image.save(path, optimize=True)
        fit_6_5(image).save(os.path.join(SMALL, os.path.basename(path)), optimize=True)
        print(os.path.basename(path), image.size)

    columns = 4
    thumb = (430, 932)
    rows = (len(shots) + columns - 1) // columns
    sheet = Image.new("RGB", (columns * 440 + 10, rows * 942 + 10), (5, 6, 12))
    for index, path in enumerate(shots):
        preview = Image.open(path).resize(thumb, Image.LANCZOS)
        sheet.paste(preview, (10 + (index % columns) * 440, 10 + (index // columns) * 942))
    sheet.save(os.path.join(ROOT, "preview.jpg"), quality=90)


if __name__ == "__main__":
    main()
