
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.AutomaticFrameAdvance = true
function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local posSpawn = tr.HitPos
	local angSpawn = tr.HitNormal:Angle()
	angSpawn.p = angSpawn.p +90
	
	local ent = ents.Create("xen_spore_medium")
	ent:SetPos(posSpawn)
	ent:SetAngles(angSpawn)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	
	self:SetModel("models/half-life/fungus.mdl")
end

function ENT:Think()
	local cboundMin = self:GetRight() *55 +self:GetForward() *55 +self:GetUp() *130
	local cboundMax = self:GetRight() *-55 +self:GetForward() *-55
	self:SetCollisionBounds(cboundMin, cboundMax)
	
	self:ResetSequence(self:LookupSequence("idle1"))
	self:SetPlaybackRate(1)
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
end
