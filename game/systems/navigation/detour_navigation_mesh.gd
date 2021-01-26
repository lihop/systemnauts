class_name DetourNavigationMesh, "icon_navigation_mesh.svg"
extends Resource

export (Vector2) var cellSize := Vector2(0.1, 0.1)
export (int) var maxNumAgents := 256
export (float) var maxAgentSlope := 45.0
export (float) var maxAgentHeight := 2.0
export (float) var maxAgentClimb := 0.5
export (float) var maxAgentRadius := 0.6
export (float) var maxEdgeLength := 12.0
export (float) var maxSimplificationError := 1.3
export (int) var minNumCellsPerIsland := 8
export (int) var minCellSpanCount := 20
export (int) var maxVertsPerPoly := 6
export (int) var tileSize := 42
export (int) var layersPerTile := 4
export (float) var detailSampleDistance := 6.0
export (float) var detailSampleMaxError := 1.0


func _init(
	p_cellSize := Vector2(0.1, 0.1),
	p_maxNumAgents := 256,
	p_maxAgentSlope := 45.0,
	p_maxAgentHeight := 2.0,
	p_maxAgentClimb := 0.5,
	p_maxAgentRadius := 0.6,
	p_maxEdgeLength := 12.0,
	p_maxSimplificationError := 1.3,
	p_minNumCellsPerIsland := 8,
	p_minCellSpanCount := 20,
	p_maxVertsPerPoly := 6,
	p_tileSize := 42,
	p_layersPerTile := 4,
	p_detailSampleDistance := 6.0,
	p_detailSampleMaxError := 1.0
):
	cellSize = p_cellSize
	maxNumAgents = p_maxNumAgents
	maxAgentSlope = p_maxAgentSlope
	maxAgentHeight = p_maxAgentHeight
	maxAgentClimb = p_maxAgentClimb
	maxAgentRadius = p_maxAgentRadius
	maxEdgeLength = p_maxEdgeLength
	maxSimplificationError = p_maxSimplificationError
	minNumCellsPerIsland = p_minNumCellsPerIsland
	minCellSpanCount = p_minCellSpanCount
	maxVertsPerPoly = p_maxVertsPerPoly
	tileSize = p_tileSize
	layersPerTile = p_layersPerTile
	detailSampleDistance = p_detailSampleDistance
	detailSampleMaxError = p_detailSampleMaxError
