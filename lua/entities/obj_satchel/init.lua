
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/weapons/half-life/w_satchel.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_NONE)
	self:PhysicsInitSphere(4, "metal_bouncy")
	self:SetCollisionBounds(Vector(4, 4, 4), Vector(-4, -4, -4))
	
	self:slvSetHealth(1)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(0.5)
		phys:SetBuoyancyRatio(0.12)
	end
end

function ENT:SetEntityOwner(ent)
	self.entOwner = ent
end

function ENT:PhysicsCollide(data, phys)
	if self.bHit then return end
	self.bHit = true
	self:EmitSound("weapons/satchel/g_bounce" .. math.random(1,5) .. ".wav", 75, 100)
	local vel = phys:GetVelocity() *0.95
	vel.z = 0
	phys:SetVelocity(vel)
	phys:SLVSetAngleVelocity(phys:GetAngleVelocity() *0.96)
	return true
end

function ENT:OnTakeDamage(dmg)
	if self.bDead then return end
	self:slvSetHealth(self:Health() -dmg:GetDamage())
	
	if self:Health() <= 0 then
		self.bDead = true
		self:DoExplode(120, 120, dmg:GetAttacker())
	end
end

function ENT:OnRemove()
end

function ENT:Think()
	if self.bHit then
		local tr = util.QuickTrace(self:GetPos(), Vector(0,0,-10), self)
		if !tr.Hit then self.bHit = false; return end
		local phys = self:GetPhysicsObject()
		local vel = phys:GetVelocity() *0.95
		vel.z = 0
		phys:SetVelocity(vel)
		phys:SLVSetAngleVelocity(phys:GetAngleVelocity() *0.96)
	end
	self:NextThink(CurTime())
	return true
end

