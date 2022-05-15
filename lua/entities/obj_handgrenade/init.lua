
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/weapons/half-life/w_grenade.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInitSphere(5)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
	end
	
	self.delayExplode = self.delayExplode || 3
end

function ENT:SetExplodeDelay(flDelay)
	self.delayExplode = CurTime() +flDelay
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:PhysicsCollide(data, physobj)
	local velLast = math.max(data.OurOldVelocity:Length(), data.Speed)
	local velNew = physobj:GetVelocity()
	velNew:Normalize()
	velLast = math.max(velNew:Length(), velLast)
	
	local vel = velNew *velLast *0.1
	physobj:SetVelocity(vel)
	self:EmitSound("weapons/grenade/grenade_hit" .. math.random(1,3) .. ".wav")
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SLVSetAngleVelocity(phys:GetAngleVelocity() *0.06)
	end
end

function ENT:OnRemove()
end

function ENT:Think()
	if !self.delayExplode || CurTime() < self.delayExplode then return end
	self.delayExplode = nil
	self:DoExplode(85, 260, IsValid(self.entOwner) && self.entOwner)
end

