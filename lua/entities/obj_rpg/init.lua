
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

AccessorFunc( ENT, "bGuided", "Guided", FORCE_BOOL )

function ENT:Initialize()
	self:SetModel("models/half-life/rpgrocket.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
	
	self.deployDelay = CurTime() +0.4
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:PhysicsCollide(data, physobj)
	self:DoExplode(85, 160, IsValid(self.entOwner) && self.entOwner)
	return true
end

function ENT:OnRemove()
	if self.cspSound then self.cspSound:Stop() end
	if IsValid(self.entOwner) then
		local wep = self.entOwner:GetActiveWeapon()
		if IsValid(wep) && wep:GetClass() == "weapon_rpg_hl" then
			wep:OnRPGExploded(self)
		end
	end
end

function ENT:Think()
	if self.deployDelay then
		if CurTime() < self.deployDelay then return end
		self.deployDelay = nil
		self.cspSound = CreateSound(self, "weapons/rpg/rocket1.wav")
		self.cspSound:Play()
		
		ParticleEffectAttach("rpg_firetrail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
		ParticleEffectAttach("rocket_smoke_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	end
	if !self:GetGuided() then
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then phys:SetVelocity(self:GetAngles():Forward() *1200) return end
		return end
	local entOwner = self.entOwner
	if !IsValid(entOwner) || entOwner:Health() <= 0 then self:SetGuided(false); return end
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		local pos = util.TraceLine(util.GetPlayerTrace(self.entOwner)).HitPos
		local ang = (pos -self:GetPos()):Angle()
		self:TurnDegree(6,ang, true)
		phys:SetVelocity(self:GetAngles():Forward() *1200)
		
		self:NextThink(CurTime())
		return true
	end
	
end

