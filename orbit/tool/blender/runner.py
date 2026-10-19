import math
import os
import sys

import bpy
from mathutils import Vector

args = sys.argv[sys.argv.index('--') + 1:]
out = args[0]
mode = args[1] if len(args) > 1 else 'still'
size = int(args[2]) if len(args) > 2 else 512

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE_NEXT'
scene.eevee.taa_render_samples = 32
scene.render.resolution_x = size
scene.render.resolution_y = size
scene.render.film_transparent = True
scene.render.image_settings.file_format = 'PNG'
scene.render.image_settings.color_mode = 'RGBA'
scene.view_settings.view_transform = 'Standard'
scene.render.use_freestyle = mode != 'glb'
scene.render.line_thickness_mode = 'ABSOLUTE'
scene.render.line_thickness = 1.6
lineset = bpy.context.view_layer.freestyle_settings.linesets[0] if bpy.context.view_layer.freestyle_settings.linesets else bpy.context.view_layer.freestyle_settings.linesets.new('lines')
lineset.select_by_visibility = True
lineset.select_crease = False
lineset.select_border = False
if lineset.linestyle is None:
    lineset.linestyle = bpy.data.linestyles.new('ink')
lineset.linestyle.color = (0.16, 0.08, 0.22)
lineset.linestyle.alpha = 0.85


def mat(name, color, rough=0.5, emit=0.0, sss=0.0):
    m = bpy.data.materials.get(name)
    if m:
        return m
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes['Principled BSDF']
    b.inputs['Base Color'].default_value = (*color, 1)
    b.inputs['Roughness'].default_value = rough
    b.inputs['Coat Weight'].default_value = 0.25
    if sss:
        b.inputs['Subsurface Weight'].default_value = sss
    if emit:
        b.inputs['Emission Color'].default_value = (*color, 1)
        b.inputs['Emission Strength'].default_value = emit
    return m


SKIN = mat('skin', (0.98, 0.66, 0.48), 0.55, sss=0.2)
CAP = mat('cap', (1.0, 0.76, 0.18), 0.45)
BAND = mat('band', (0.42, 0.42, 0.95), 0.35)
SHIRT = mat('shirt', (0.62, 0.42, 0.92), 0.6)
PACK = mat('pack', (0.98, 0.62, 0.72), 0.55)
SHORTS = mat('shorts', (0.2, 0.17, 0.38), 0.6)
SOCK = mat('sock', (0.95, 0.94, 1.0), 0.6)
SHOE = mat('shoe', (0.38, 0.52, 0.95), 0.4)
SOLE = mat('sole', (1.0, 0.78, 0.35), 0.3, emit=2.0)
GLOVE = mat('glove', (0.24, 0.2, 0.42), 0.5)


def smooth(o):
    for p in o.data.polygons:
        p.use_smooth = True
    m = o.modifiers.new('sub', 'SUBSURF')
    m.levels = 2
    m.render_levels = 2
    return o


def blob(name, size, loc, material, parent=None, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=1, location=(0, 0, 0))
    o = bpy.context.object
    o.name = name
    o.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for p in o.data.polygons:
        p.use_smooth = True
    o.data.materials.append(material)
    if parent:
        o.parent = parent
    o.location = loc
    o.rotation_euler = rot
    return o


def box(name, size, loc, material, parent=None, bevel=0.06):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    o = bpy.context.object
    o.name = name
    o.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    b = o.modifiers.new('bevel', 'BEVEL')
    b.width = bevel
    b.segments = 4
    for p in o.data.polygons:
        p.use_smooth = True
    o.data.materials.append(material)
    if parent:
        o.parent = parent
    o.location = loc
    return o


def pivot(name, loc, parent=None):
    bpy.ops.object.empty_add(type='PLAIN_AXES', location=(0, 0, 0))
    e = bpy.context.object
    e.name = name
    if parent:
        e.parent = parent
    e.location = loc
    return e


root = pivot('root', (0, 0, 0))
hips = pivot('hips', (0, 0, 0.95), root)
torso = blob('torso', (0.36, 0.26, 0.42), (0, 0, 0.42), SHIRT, hips)
blob('shorts', (0.34, 0.25, 0.2), (0, 0, 0.02), SHORTS, hips)
pack = box('pack', (0.46, 0.2, 0.46), (0, 0.27, 0.48), PACK, hips, bevel=0.1)
box('flap', (0.4, 0.06, 0.18), (0, 0.38, 0.62), mat('flap', (0.9, 0.45, 0.6), 0.5), hips, bevel=0.05)
box('pocket', (0.26, 0.05, 0.12), (0, 0.375, 0.36), mat('pocket', (0.55, 0.62, 0.98), 0.4), hips, bevel=0.04)

neck = pivot('neck', (0, 0, 0.86), hips)
head = blob('head', (0.44, 0.42, 0.42), (0, 0, 0.36), SKIN, neck)
blob('cap', (0.47, 0.45, 0.33), (0, 0.03, 0.52), CAP, neck)
blob('pom', (0.11, 0.11, 0.11), (0, 0.03, 0.86), CAP, neck)
bpy.ops.mesh.primitive_torus_add(major_radius=0.45, minor_radius=0.085, location=(0, 0, 0))
band = bpy.context.object
for p in band.data.polygons:
    p.use_smooth = True
band.data.materials.append(BAND)
band.parent = neck
band.location = (0, 0.01, 0.36)
band.scale = (1, 1, 1.25)
for side in (-1, 1):
    blob(f'ear{side}', (0.09, 0.15, 0.17), (side * 0.45, 0.02, 0.35), BAND, neck)

legs = {}
for side, name in ((-1, 'L'), (1, 'R')):
    hip = pivot(f'thigh{name}', (side * 0.15, 0, -0.05), hips)
    blob(f'thighM{name}', (0.12, 0.12, 0.22), (0, 0, -0.16), SHORTS, hip)
    knee = pivot(f'knee{name}', (0, 0, -0.36), hip)
    blob(f'shin{name}', (0.085, 0.085, 0.2), (0, 0, -0.18), SKIN, knee)
    blob(f'sock{name}', (0.095, 0.095, 0.09), (0, 0, -0.33), SOCK, knee)
    foot = pivot(f'foot{name}', (0, 0, -0.42), knee)
    box(f'shoe{name}', (0.2, 0.34, 0.15), (0, -0.04, -0.03), SHOE, foot, bevel=0.07)
    box(f'sole{name}', (0.21, 0.35, 0.05), (0, -0.04, -0.11), SOLE, foot, bevel=0.025)
    legs[name] = (hip, knee, foot)

arms = {}
for side, name in ((-1, 'L'), (1, 'R')):
    sh = pivot(f'shoulder{name}', (side * 0.36, 0, 0.62), hips)
    blob(f'upper{name}', (0.1, 0.1, 0.19), (0, 0, -0.15), SHIRT, sh)
    el = pivot(f'elbow{name}', (0, 0, -0.3), sh)
    blob(f'fore{name}', (0.08, 0.08, 0.15), (0, 0, -0.13), SKIN, el)
    blob(f'hand{name}', (0.1, 0.1, 0.1), (0, 0, -0.29), GLOVE, el)
    sh.rotation_euler = (0, side * -0.25, 0)
    arms[name] = (sh, el)


def pose(phase, jump=0.0):
    s = math.sin(phase)
    c = math.cos(phase)
    swing = 0.75 * (1 - jump * 0.6)
    for name, sign in (('L', 1), ('R', -1)):
        hip, knee, foot = legs[name]
        a = sign * s
        hip.rotation_euler = (a * swing + jump * 0.9, 0, 0)
        bend = max(0.0, -sign * c) * 1.3 + 0.25 + jump * 1.2
        knee.rotation_euler = (-bend, 0, 0)
        foot.rotation_euler = (bend * 0.35 - a * 0.25, 0, 0)
        sh, el = arms[name]
        sh.rotation_euler = (-a * 0.9 * (1 - jump * 0.5) - jump * 1.8, sh.rotation_euler[1], 0)
        el.rotation_euler = (0.9 + jump * 0.4, 0, 0)
    hips.location = (0, 0, 0.95 + 0.07 * abs(c) - 0.04 + jump * 0.25)
    hips.rotation_euler = (0.18 - jump * 0.1, 0, 0.12 * s * (1 - jump))
    neck.rotation_euler = (-0.1, 0, -0.08 * s * (1 - jump))


bpy.ops.object.light_add(type='SUN', location=(0, 0, 0))
key = bpy.context.object
key.data.energy = 3.6
key.data.color = (1.0, 0.9, 0.78)
key.rotation_euler = (math.radians(40), math.radians(-25), math.radians(160))
bpy.ops.object.light_add(type='AREA', location=(0, -2.5, 2.0))
rim = bpy.context.object
rim.data.energy = 260
rim.data.color = (1.0, 0.7, 0.4)
rim.data.size = 3
rim.rotation_euler = (Vector((0, 0, 1)) - rim.location).to_track_quat('-Z', 'Y').to_euler()
world = bpy.data.worlds.new('w')
scene.world = world
world.use_nodes = True
world.node_tree.nodes['Background'].inputs['Color'].default_value = (0.7, 0.62, 0.95, 1)
world.node_tree.nodes['Background'].inputs['Strength'].default_value = 0.9

bpy.ops.object.camera_add(location=(0, 4.2, 2.3))
cam = bpy.context.object
cam.data.type = 'ORTHO'
cam.data.ortho_scale = 3.7
cam.rotation_euler = (Vector((0, 0, 1.25)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
scene.camera = cam

if mode == 'glb':
    outline = bpy.data.materials.new('outline')
    outline.use_nodes = True
    ob = outline.node_tree.nodes['Principled BSDF']
    ob.inputs['Base Color'].default_value = (0.09, 0.05, 0.14, 1)
    ob.inputs['Roughness'].default_value = 1.0
    outline.use_backface_culling = True
    for o in list(bpy.data.objects):
        if o.type != 'MESH':
            continue
        o.data.materials.append(outline)
        sol = o.modifiers.new('outline', 'SOLIDIFY')
        sol.thickness = 0.022
        sol.offset = 1.0
        sol.use_flip_normals = True
        sol.material_offset = len(o.data.materials) - 1
        sol.use_rim = False
    for m in bpy.data.materials:
        if m.name != 'outline':
            m.use_backface_culling = True

    rig = [o for o in bpy.data.objects if o.type == 'EMPTY']
    clips = {
        'Run': (24, lambda u: pose(u * math.pi * 2)),
        'Jump': (30, lambda u: pose(0.4, math.sin(min(1.0, u * 1.25) * math.pi * 0.5) * (1 - max(0.0, u - 0.8) / 0.2))),
        'Idle': (48, lambda u: (pose(0.0, 0.0), hips.location.__setitem__(2, 0.95 + 0.02 * math.sin(u * math.pi * 2)), [arms[k][0].rotation_euler.__setitem__(0, 0.12 * math.sin(u * math.pi * 2)) for k in arms], [legs[k][0].rotation_euler.__setitem__(0, 0.0) for k in legs], [legs[k][1].rotation_euler.__setitem__(0, -0.12) for k in legs], [legs[k][2].rotation_euler.__setitem__(0, 0.04) for k in legs], hips.rotation_euler.__setitem__(0, 0.04), hips.rotation_euler.__setitem__(2, 0.0))),
    }
    for clip, (length, fn) in clips.items():
        for o in rig:
            o.animation_data_create()
            o.animation_data.action = bpy.data.actions.new(f'{clip}_{o.name}')
        steps = 12 if clip == 'Run' else (15 if clip == 'Jump' else 12)
        for k in range(steps + 1):
            u = k / steps
            fn(u if clip != 'Run' else (u % 1.0))
            frame = 1 + u * length
            for o in rig:
                o.keyframe_insert('rotation_euler', frame=frame)
                o.keyframe_insert('location', frame=frame)
        for o in rig:
            act = o.animation_data.action
            track = o.animation_data.nla_tracks.new()
            track.name = clip
            track.strips.new(clip, 1, act)
            o.animation_data.action = None
    pose(0.0)
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(
        filepath=out,
        export_format='GLB',
        export_apply=True,
        export_yup=True,
        export_animations=True,
        export_animation_mode='NLA_TRACKS',
        export_force_sampling=True,
        export_lights=False,
        export_cameras=False,
        export_draco_mesh_compression_enable=True,
    )
    print('exported', out, os.path.getsize(out))
    sys.exit(0)

if mode == 'still':
    pose(0.6)
    scene.render.filepath = out
    bpy.ops.render.render(write_still=True)
else:
    os.makedirs(out, exist_ok=True)
    frames = 12
    for i in range(frames):
        pose(i / frames * math.pi * 2)
        scene.render.filepath = os.path.join(out, f'run_{i:02d}.png')
        bpy.ops.render.render(write_still=True)
    for i, j in enumerate((0.35, 1.0, 0.7)):
        pose(0.4, j)
        scene.render.filepath = os.path.join(out, f'jump_{i:02d}.png')
        bpy.ops.render.render(write_still=True)
