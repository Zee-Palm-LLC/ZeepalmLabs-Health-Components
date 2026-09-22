import sys
from PIL import Image
snaps, out = sys.argv[1], sys.argv[2]
pairs = [('welcome', 1), ('home', 2), ('mix', 3), ('sleep', 4)]
for name, k in pairs:
    a = Image.open(f'reference/screen{k}_2x.png').convert('RGB').resize((393, 852))
    b = Image.open(f'{snaps}/{name}.png').convert('RGB').resize((393, 852))
    sheet = Image.new('RGB', (393 * 2 + 10, 852), (255, 255, 255))
    sheet.paste(a, (0, 0))
    sheet.paste(b, (403, 0))
    sheet.save(f'{out}/cmp_{name}.png')
