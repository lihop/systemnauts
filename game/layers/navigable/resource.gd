class_name NavigableWorldspawnLayer
extends QodotWorldspawnLayer

enum AreaType {
	GROUND,
	ROAD,
	CARPET,
	GRASS,
}

const AREA_TYPE_GROUND = AreaType.GROUND
const AREA_TYPE_ROAD = AreaType.ROAD
const AREA_TYPE_CARPET = AreaType.CARPET
const AREA_TYPE_GRASS = AreaType.GRASS

export (AreaType) var area_type := AREA_TYPE_GROUND
export (Resource) var audio_material
