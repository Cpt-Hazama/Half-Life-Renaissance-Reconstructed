
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/weapons/half-life/p_satchel_radio.mdl")
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
end

function ENT:SetEntityOwner(ent)
	self:SetNetworkedEntity("owner", ent)
end

function ENT:Think()
end


