
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

AccessorFunc(ENT, "bExplosive", "Explosive", FORCE_BOOL)

function ENT:Initialize()
	self:SetModel("models/half-life/crossbow_bolt.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInitBox(Vector(1,1,1), Vector(-1,-1,0))
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
	self.startTime = CurTime()
end

function ENT:SetParentEntity(ent)
	self.entParent = ent
	self:SetParent(ent)
end

function ENT:SetRemoveDelay(flDelay)
	self.flDelayRemove = CurTime() +flDelay
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:PhysicsCollide(data, physobj)
	if self.bHit then return end
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
	self.bHit = true
	local pos = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(pos)
	effectdata:SetOrigin(pos)
	effectdata:SetScale(1)
	util.Effect("cball_explode", effectdata)
	if self:GetExplosive() then
		self.explodeDelay = CurTime() +0.2
		local sSound
		if data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() then sSound = "weapons/crossbow/xbow_hitbod" .. math.random(1,2) .. ".wav"
		else sSound = "weapons/crossbow/xbow_hit1.wav" end
		self:EmitSound(sSound, 100, 100)
	end
end

function ENT:OnRemove()
end

function ENT:Think()
	if self.bDead then return end
	if self.flDelayRemove && CurTime() >= self.flDelayRemove then
		self:slvFadeOut()
		self.bDead = true
	end
	if self.entParent && !IsValid(self.entParent) then
		self:Remove()
		return
	end
	if self.bHit then
		if !self:GetExplosive() then return end
		if CurTime() >= self.explodeDelay then
			self:DoExplode(100, 200, self.entOwner)
		end
		return
	end
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		local flyTime = math.Clamp(CurTime() -self.startTime,0,3.5)
		phys:SetVelocity(self:GetForward() *5800 +self:GetUp() *-(flyTime *50))
		phys:AddAngleVelocity(phys:GetAngleVelocity() *-1)
	end
	self:NextThink(CurTime())
	return true
end

