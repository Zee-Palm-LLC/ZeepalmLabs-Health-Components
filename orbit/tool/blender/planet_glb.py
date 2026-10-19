import math
import os
import random
import sys

import bmesh
import bpy
from mathutils import Vector, noise

args = sys.argv[sys.argv.index('--') + 1:]
out_glb = args[0]
preview = args[1] if len(args) > 1 else ''

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
rnd = random.Random(21)

UP = Vector((-0.5, -0.35, 0.8)).normalized()
CITY = Vector((0.82, -0.5, 0.28)).normalized()
VOLCANO = Vector((0.28, -0.42, 0.86)).normalized()
FALLS = Vector((-0.45, -0.86, 0.02)).normalized()
WHALE = Vector((0.3, -0.8, -0.45)).normalized()

MATS = {}


def mat(name, color, rough=0.6, emit=None, strength=0.0, alpha=1.0, metal=0.0):
    if name in MATS:
        return MATS[name]
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes['Principled BSDF']
    b.inputs['Base Color'].default_value = (*color, 1)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Metallic'].default_value = metal
    if emit is not None:
        b.inputs['Emission Color'].default_value = (*emit, 1)
        b.inputs['Emission Strength'].default_value = strength
    if alpha < 1:
        b.inputs['Alpha'].default_value = alpha
        m.surface_render_method = 'BLENDED'
    MATS[name] = m
    return m


def srgb(h):
    h = h.lstrip('#')
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(((v + 0.055) / 1.055) ** 2.4 if v > 0.04045 else v / 12.92 for v in c)


GRASS = [mat('grass_a', srgb('6cbf3f'), 0.85), mat('grass_b', srgb('86d24c'), 0.85), mat('grass_c', srgb('4fa236'), 0.85)]
DIRT = mat('dirt', srgb('b9875a'), 0.9)
SAND = mat('sand', srgb('f2dfa2'), 0.9)
OCEAN = mat('ocean', srgb('1f8fe8'), 0.12)
SHALLOW = mat('shallow', srgb('49d3f2'), 0.1)
PURPLE = mat('city_ground', srgb('6b44c8'), 0.6)
ROCK = mat('rock', srgb('7a4a3c'), 0.9)
ROCK2 = mat('rock2', srgb('94604c'), 0.9)
LAVA = mat('lava', srgb('ff7a1a'), 0.4, emit=srgb('ff6a10'), strength=6)
BARK = mat('bark', srgb('7a4e2c'), 0.8)
LEAF = [mat('leaf_a', srgb('3f9a3a'), 0.7), mat('leaf_b', srgb('5cb847'), 0.7), mat('leaf_c', srgb('2f7f3a'), 0.7)]
PINE = mat('pine', srgb('2f8a5a'), 0.7)
WALL = [mat('wall_a', srgb('7b55e0'), 0.5), mat('wall_b', srgb('5d3fc0'), 0.5)]
WINDOW = mat('window', srgb('ffd27a'), 0.3, emit=srgb('ffc04a'), strength=5)
FALLS_M = mat('falls', srgb('bff2ff'), 0.05, emit=srgb('8fe6ff'), strength=1.2)
FOAM = mat('foam', srgb('ffffff'), 0.4)
WHALE_M = mat('whale', srgb('8f7ef0'), 0.4)
BELLY = mat('belly', srgb('e6e0ff'), 0.5)
FOX = mat('fox', srgb('f08a3a'), 0.6)
CREAM = mat('cream', srgb('fff1dc'), 0.6)
INK = mat('ink', srgb('1e1420'), 0.3)
SMOKE = mat('smoke', srgb('8a7a8e'), 1.0, alpha=0.75)
FLOWERS = [mat('fl_pink', srgb('ff8fc0'), 0.5), mat('fl_lilac', srgb('c79bff'), 0.5), mat('fl_yellow', srgb('ffe066'), 0.5), mat('fl_red', srgb('ff5a4a'), 0.5)]


def land_value(n):
    f = n.dot(UP) * 1.0 - 0.2 + 0.2 * noise.noise(n * 2.2) + 0.06 * noise.noise(n * 5.0)
    f += 0.6 * max(0.0, n.dot(CITY) - 0.72) * 4
    return f


def surface(n):
    n = n.normalized()
    v = land_value(n)
    return n * (1.075 + 0.02 * noise.noise(n * 8) if v > 0.12 else 1.0)


def link(bm, name, materials):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(o)
    for m in materials:
        o.data.materials.append(m)
    for p in o.data.polygons:
        p.use_smooth = True
    return o


def build_land():
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=6, radius=1.0)
    for v in bm.verts:
        n = v.co.normalized()
        f = land_value(n)
        if f > 0.12:
            h = 1.075 + 0.02 * noise.noise(n * 8)
        elif f > 0.07:
            h = 1.0 + (f - 0.07) / 0.05 * 0.075
        else:
            h = 0.97
        v.co = n * h
    mats = GRASS + [DIRT, SAND, PURPLE]
    for face in bm.faces:
        c = face.calc_center_median()
        n = c.normalized()
        f = land_value(n)
        if f > 0.12:
            if n.dot(CITY) > 0.78:
                idx = 5
            else:
                k = noise.noise(n * 1.8)
                idx = 0 if k < -0.25 else (1 if k < 0.25 else 2)
        elif f > 0.085:
            idx = 3
        else:
            idx = 4
        face.material_index = idx
    return link(bm, 'land', mats)


def build_ocean():
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=5, radius=1.012)
    for face in bm.faces:
        n = face.calc_center_median().normalized()
        face.material_index = 1 if land_value(n) > -0.05 else 0
    return link(bm, 'ocean', [OCEAN, SHALLOW])


PARTS = []


def place(obj, normal, at, spin=0.0):
    q = Vector((0, 0, 1)).rotation_difference(normal.normalized())
    obj.rotation_mode = 'QUATERNION'
    from mathutils import Euler
    obj.rotation_quaternion = q @ Euler((0, 0, spin)).to_quaternion()
    obj.location = at
    PARTS.append(obj)
    return obj


def mesh_from(fn, name):
    bm = bmesh.new()
    fn(bm)
    return link(bm, name, [])


def prim_ico(r, sub=2, loc=(0, 0, 0), scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=r, location=loc)
    o = bpy.context.object
    o.scale = scale
    for p in o.data.polygons:
        p.use_smooth = True
    return o


def prim_cyl(r, depth, loc=(0, 0, 0), verts=12, r2=None):
    if r2 is None:
        bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    else:
        bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object
    for p in o.data.polygons:
        p.use_smooth = True
    return o


def prim_box(size, loc=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object
    o.scale = size
    return o


def group(objs, name):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    bpy.ops.object.join()
    o = bpy.context.object
    o.name = name
    return o


def with_mat(o, m):
    o.data.materials.clear()
    o.data.materials.append(m)
    return o


def tree(n, scale, kind):
    parts = []
    h = 0.2 * scale
    parts.append(with_mat(prim_cyl(0.022 * scale, h, (0, 0, h / 2), 8, r2=0.014 * scale), BARK))
    if kind == 'pine':
        for i in range(3):
            parts.append(with_mat(prim_cyl(0.1 * scale * (1 - i * 0.24), 0.15 * scale, (0, 0, h * 0.75 + i * 0.085 * scale), 10, r2=0.0), PINE))
    else:
        for i in range(rnd.randint(3, 5)):
            m = LEAF[rnd.randrange(3)]
            parts.append(with_mat(prim_ico(0.075 * scale * rnd.uniform(0.85, 1.25), 2, (rnd.uniform(-0.06, 0.06) * scale, rnd.uniform(-0.06, 0.06) * scale, h + rnd.uniform(-0.01, 0.07) * scale)), m))
    o = group(parts, 'tree')
    return place(o, n, surface(n) * 0.995, rnd.uniform(0, 6.28))


def fox(n, spin):
    s = 1.5
    parts = [
        with_mat(prim_ico(0.05 * s, 2, (0, 0, 0.06 * s), (1.4, 0.9, 0.9)), FOX),
        with_mat(prim_ico(0.042 * s, 2, (0.06 * s, 0, 0.11 * s)), FOX),
        with_mat(prim_ico(0.018 * s, 2, (0.098 * s, 0, 0.1 * s)), CREAM),
        with_mat(prim_ico(0.03 * s, 2, (-0.08 * s, 0, 0.1 * s), (1.8, 0.8, 0.8)), FOX),
    ]
    for side in (-1, 1):
        parts.append(with_mat(prim_cyl(0.014 * s, 0.035 * s, (0.055 * s, side * 0.022 * s, 0.155 * s), 8, r2=0.0), FOX))
        parts.append(with_mat(prim_ico(0.007 * s, 1, (0.094 * s, side * 0.018 * s, 0.12 * s)), INK))
        for front in (-1, 1):
            parts.append(with_mat(prim_cyl(0.01 * s, 0.05 * s, (front * 0.035 * s, side * 0.022 * s, 0.025 * s), 8), FOX))
    o = group(parts, 'fox')
    return place(o, n, surface(n), spin)


def building(n, w, d, h):
    parts = [with_mat(prim_box((w, d, h), (0, 0, h / 2)), WALL[rnd.randrange(2)])]
    rows = max(2, int(h / 0.05))
    for r in range(rows):
        for c in (-1, 1):
            for face in (1, -1):
                if rnd.random() < 0.7:
                    parts.append(with_mat(prim_box((0.004, w * 0.22, 0.022), (face * (w / 2 + 0.002), c * w * 0.22, 0.035 + r * (h - 0.05) / rows)), WINDOW))
    parts.append(with_mat(prim_box((w * 1.06, d * 1.06, 0.012), (0, 0, h + 0.006)), WALL[1]))
    o = group(parts, 'building')
    return place(o, n, surface(n) * 0.995, rnd.uniform(0, 6.28))


def volcano():
    parts = [
        with_mat(prim_cyl(0.32, 0.4, (0, 0, 0.17), 28, r2=0.09), ROCK),
        with_mat(prim_cyl(0.22, 0.2, (0.05, 0.04, 0.25), 20, r2=0.1), ROCK2),
        with_mat(prim_cyl(0.085, 0.025, (0, 0, 0.37), 20), LAVA),
    ]
    for k in range(6):
        a = k * math.tau / 6 + 0.3
        b = prim_box((0.025, 0.04, 0.22), (math.cos(a) * 0.15, math.sin(a) * 0.15, 0.24))
        b.rotation_euler = (-math.sin(a) * 0.6, math.cos(a) * 0.6, 0)
        parts.append(with_mat(b, LAVA))
    o = group(parts, 'volcano')
    place(o, VOLCANO, surface(VOLCANO) * 0.99)
    smoke = []
    for k in range(4):
        smoke.append(with_mat(prim_ico(0.045 + k * 0.02, 2, (k * 0.02, -k * 0.012, 0.44 + k * 0.075)), SMOKE))
    s = group(smoke, 'smoke')
    place(s, VOLCANO, surface(VOLCANO) * 0.99)


def falls():
    bm = bmesh.new()
    rows = 14
    verts = []
    for i in range(rows + 1):
        u = i / rows
        ang = -0.15 + u * 0.55
        r = 1.08 - 0.075 * min(1, u * 3)
        for j, w in enumerate((-0.07, 0.07)):
            verts.append(bm.verts.new((w, math.sin(ang) * 0 + 0, 0)))
    bm.free()
    parts = []
    n = FALLS
    side = n.cross(Vector((0, 0, 1))).normalized()
    down = side.cross(n).normalized()
    bmf = bmesh.new()
    prev = None
    for i in range(16):
        u = i / 15
        p = (n + down * (u * 0.45)).normalized() * (1.09 - 0.075 * min(1.0, u * 2.2))
        a = bmf.verts.new(p - side * 0.09)
        b = bmf.verts.new(p + side * 0.09)
        if prev:
            bmf.faces.new((prev[0], prev[1], b, a))
        prev = (a, b)
    o = link(bmf, 'falls', [FALLS_M])
    PARTS.append(o)
    foam = with_mat(prim_ico(0.06, 2, tuple((n + down * 0.5).normalized() * 1.0), (1.6, 1.6, 0.5)), FOAM)
    PARTS.append(foam)


def whale():
    parts = [
        with_mat(prim_ico(0.12, 3, (0, 0, 0.02), (2.2, 1.0, 0.8)), WHALE_M),
        with_mat(prim_ico(0.1, 3, (0.02, 0, -0.01), (2.0, 0.8, 0.5)), BELLY),
        with_mat(prim_box((0.08, 0.2, 0.016), (-0.26, 0, 0.07)), WHALE_M),
        with_mat(prim_ico(0.012, 1, (0.2, 0.06, 0.06)), INK),
        with_mat(prim_ico(0.012, 1, (0.2, -0.06, 0.06)), INK),
    ]
    o = group(parts, 'whale')
    place(o, WHALE, WHALE * 0.995, 2.4)


land = build_land()
ocean = build_ocean()
PARTS += [land, ocean]

for i in range(11):
    n = (CITY + Vector((rnd.uniform(-0.22, 0.22), rnd.uniform(-0.22, 0.22), rnd.uniform(-0.22, 0.22)))).normalized()
    if land_value(n) < 0.14:
        continue
    building(n, rnd.uniform(0.07, 0.1), rnd.uniform(0.07, 0.1), rnd.uniform(0.16, 0.36))

volcano()

placed = 0
tries = 0
while placed < 62 and tries < 4000:
    tries += 1
    n = Vector((rnd.uniform(-1, 1), rnd.uniform(-1, 1), rnd.uniform(-1, 1)))
    if n.length < 0.1:
        continue
    n.normalize()
    if land_value(n) < 0.18 or n.dot(CITY) > 0.76 or n.dot(VOLCANO) > 0.9 or n.dot(FALLS) > 0.93:
        continue
    tree(n, rnd.uniform(0.65, 1.05), 'pine' if rnd.random() < 0.15 else 'round')
    placed += 1

for i, (n, spin) in enumerate([(Vector((-0.5, -0.65, 0.58)), 0.6), (Vector((-0.2, -0.85, 0.48)), -0.8), (Vector((-0.75, -0.25, 0.6)), 2.4)]):
    if land_value(n.normalized()) > 0.12:
        fox(n.normalized(), spin)

fl = []
for i in range(160):
    n = Vector((rnd.uniform(-1, 1), rnd.uniform(-1, 1), rnd.uniform(-1, 1))).normalized()
    if land_value(n) < 0.18 or n.dot(CITY) > 0.76:
        continue
    fl.append(with_mat(prim_ico(0.011, 1, tuple(surface(n) * 1.004)), FLOWERS[i % 4]))
if fl:
    flowers = group(fl, 'flowers')
    PARTS.append(flowers)

falls()
whale()

root = bpy.data.objects.new('Planet', None)
bpy.context.collection.objects.link(root)
for o in PARTS:
    if o.parent is None:
        o.parent = root

if preview:
    scene.render.engine = 'BLENDER_EEVEE_NEXT'
    scene.render.resolution_x = 768
    scene.render.resolution_y = 768
    scene.render.film_transparent = True
    scene.view_settings.view_transform = 'Standard'
    bpy.ops.object.light_add(type='SUN')
    key = bpy.context.object
    key.data.energy = 3.5
    key.rotation_euler = (math.radians(50), math.radians(-25), math.radians(-35))
    w = bpy.data.worlds.new('w')
    scene.world = w
    w.use_nodes = True
    w.node_tree.nodes['Background'].inputs['Color'].default_value = (0.75, 0.75, 1.0, 1)
    w.node_tree.nodes['Background'].inputs['Strength'].default_value = 1.0
    bpy.ops.object.camera_add(location=(0, -4.4, 1.25))
    cam = bpy.context.object
    cam.rotation_euler = (Vector((0, 0, 0.02)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
    scene.camera = cam
    scene.render.filepath = preview
    bpy.ops.render.render(write_still=True)

bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(
    filepath=out_glb,
    export_format='GLB',
    export_apply=True,
    export_yup=True,
    export_draco_mesh_compression_enable=True,
    export_draco_mesh_compression_level=7,
    export_lights=False,
    export_cameras=False,
)
print('exported', out_glb, os.path.getsize(out_glb))
