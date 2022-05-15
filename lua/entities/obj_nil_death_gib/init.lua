
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl")
	self:DrawShadow(false)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:slvSetHealth(1)

	local phys = self.Entity:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
		phys:ApplyForceCenter(Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(0.5,1)) *150)
	end
	
	local entSprite = ents.Create("env_sprite")
	entSprite:SetKeyValue("rendermode", "5")
	entSprite:SetKeyValue("model", "sprites/exit1_anim.vmt")
	entSprite:SetKeyValue("scale", "1")
	entSprite:SetKeyValue("spawnflags", "1")
	entSprite:SetPos(self:GetPos())
	entSprite:SetParent(self)
	entSprite:Spawn()
	entSprite:Activate()
	self:DeleteOnRemove(entSprite)
end

function ENT:Think()
end

function ENT:PhysicsCollide(data, physobj)
	return true
end

