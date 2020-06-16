import os
import bpy


# Export each collection to a seperate .glb file.
for collection in bpy.data.collections:
    export_filepath = os.path.join(os.path.dirname(bpy.data.filepath), 'exports', collection.name + '.glb')
    
    # Deselect all.
    bpy.ops.object.select_all(action='DESELECT')
    
    # Select the root object in the collection.
    root_objects = [object for object in collection.objects if object.parent == None]
    
    # If we have more than root object, there are going to be problems when we try moving
    # things to world origin.
    if len(root_objects) != 1:
        raise Exception(f'Unexpected number root objects in collection \'{collection.name}\'')
    
    root_object = root_objects[0]
    
    # Move the root object to world origin in preparation for export.
    # Record the original translation so we can move it back after export.
    original_translation = root_object.matrix_world.translation.copy()
    root_object.matrix_world.translation = (0, 0, 0)
    
    # Select all objects in the collection.
    for object in collection.objects:
        object.select_set(True)

    # Export glTF 2.0.
    bpy.ops.export_scene.gltf(export_copyright="Copyright (c) 2020 Leroy Hopson",
            export_selected=True, filepath=export_filepath, check_existing=False)

    # Deselect all
    bpy.ops.object.select_all(action='DESELECT')

    # Move selection back to its original location.
    root_object.matrix_world.translation = original_translation