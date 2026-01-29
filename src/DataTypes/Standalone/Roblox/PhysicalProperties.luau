local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

-- lsp doesn't seem to like acoustic absorption, but it does exist!

local newPhysicalProps = PhysicalProperties.new :: (...number) -> PhysicalProperties

return DataTypeDefinition.new("PhysicalProperties", {
	read = function(stream)
		return newPhysicalProps(
			stream:readf32(),
			stream:readf32(),
			stream:readf32(),
			stream:readf32(),
			stream:readf32(),
			stream:readf32()
		)
	end,
	write = function(stream, phys)
		stream:writef32(phys.Density)
		stream:writef32(phys.Friction)
		stream:writef32(phys.Elasticity)
		stream:writef32(phys.FrictionWeight)
		stream:writef32(phys.ElasticityWeight)
		stream:writef32((phys :: any).AcousticAbsorption :: number)
	end,
})
