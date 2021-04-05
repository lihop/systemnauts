# Originally based on Mitch Makes Things's blender script,
# available at https://www.youtube.com/watch?v=2cGr9EMR1yk.

import argparse, bpy, os, sys
from mathutils import Vector

parser = argparse.ArgumentParser(description='Update some assets.')
parser.add_argument('import_directory', type=str, nargs=1)
parser.add_argument('export_directory', type=str, nargs=1)

argv = sys.argv
argv = argv[argv.index("--") + 1:]  # get all args after "--"
args = parser.parse_args(argv)

importFolder = args.import_directory[0]
exportFolder = args.export_directory[0]

# Validation
if not os.path.exists(importFolder):
    print("You need to set the import folder in the script!")

if not os.path.exists(exportFolder):
    os.mkdir(exportFolder)
  
def clear_objects():
    # Delete the objects
    for obj in bpy.data.objects:
        bpy.data.objects.remove(obj)

# Grab all files in the import directory.
files = os.listdir(importFolder)

for f in files:
    if not f.endswith(".obj"):
        continue

    # Ensure the scene we're using doesn't have any meshes.
    # We definitely don't want to accidentally export weird stuff.
    clear_objects()
    
    # Import the obj scene.
    bpy.ops.import_scene.obj(filepath = os.path.join(importFolder, f))
    
    for obj in bpy.data.objects:
        obj.select_set(True)

        # Set origin to geometry and remove translation.
        bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')
        obj.location = (0, 0, 0)

        # Objects are too small compared with Godot/NPC dimensions. 
        obj.scale = (2.1, 2.1, 2.1)

        # Ensure Godot imports the object as a RigidBody.
        if not obj.data.name.endswith("-rigid"):
            obj.data.name += "-rigid"

        # START: Remove duplicate materials.
        # Ensures models share the same set of materials rather than creating new versions for every model.
        # Code snippet by Dimitar Pouchnikov (dimitarsp), copied from: https://developer.blender.org/T30380#468539

        #check for objects that have one material
        if len(obj.material_slots)==1:
            dupmat = obj.material_slots[0].name
            print(dupmat)
            #check for duplicate names
            if ".0" in dupmat:
                matName = dupmat[:-4]
                if matName in [obj.name for obj in bpy.data.materials]:
                    mat = bpy.data.materials[dupmat[:-4]]
                    obj.material_slots[0].material = mat
        #check for objects that have more than one material
        elif len(obj.material_slots)>1:
            for x,y in enumerate(obj.material_slots):
                dupmat = obj.material_slots[x].name
                print(dupmat)
                if ".0" in dupmat:
                    matName = dupmat[:-4]
                    if matName in [i.name for i in bpy.data.materials]:
                        mat = bpy.data.materials[dupmat[:-4]]
                        obj.material_slots[x].material = mat

        # END: Remove duplicate materials.
    
    # Save to output directory.
    bpy.ops.export_scene.obj(filepath = os.path.join(exportFolder, f), check_existing = False)

# START: Bake all materials to png file for use by TrenchBroom.
# Modified version of code by Noob Cat from https://blender.stackexchange.com/a/191841,
# released under CC BY-SA 4.0. (https://creativecommons.org/licenses/by-sa/4.0/).

# You can choose your texture size (This will be the the bake image)
image_name = mat.name 
img = bpy.data.images.new(image_name,1,1)


#Due to the presence of any multiple materials, it seems necessary to iterate on all the materials, and assign them a node + the image to bake.
#for mat in bpy.data.materials:
#    if not mat.users:
#        bpy.data.materials.remove(mat)

for mat in bpy.data.materials:

    # Ignore duplicate materials.
    if ".0" in mat.name:
        continue

    print(mat.name)
    img = bpy.data.images.new(mat.name, 500, 500)

    mat.use_nodes = True #Here it is assumed that the materials have been created with nodes, otherwise it would not be possible to assign a node for the Bake, so this step is a bit useless
    nodes = mat.node_tree.nodes
    texture_node =nodes.new('ShaderNodeTexImage')
    texture_node.name = 'Bake_node'
    texture_node.select = True
    nodes.active = texture_node
    texture_node.image = img #Assign the image to the node

    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.bake_image()

    img.save_render(filepath='/tmp/test.png')
#
##In the last step, we are going to delete the nodes we created earlier
#for mat in obj.data.materials:
#    for n in mat.node_tree.nodes:
#        if n.name == 'Bake_node':
#            mat.node_tree.nodes.remove(n)

# END: Bake all materials to png file for use by TrenchBroom.
