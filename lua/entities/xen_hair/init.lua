
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.AutomaticFrameAdvance = true
function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local posSpawn = tr.HitPos
	local angSpawn = tr.HitNormal:Angle()
	angSpawn.p = angSpawn.p +90
	
	local ent = ents.Create("xen_hair")
	ent:SetPos(posSpawn)
	ent:SetAngles(angSpawn)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetModel("models/half-life/hair.mdl")
end

function ENT:Think()
	self:ResetSequence(self:LookupSequence("spin"))
	self:SetPlaybackRate(1)
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
end
