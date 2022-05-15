
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/flechette_grenade.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
	end
	
	local entLight = ents.Create( "light_dynamic" )
	entLight:SetKeyValue("_light", "2 110 182 100")
	entLight:SetKeyValue("brightness", "2")
	entLight:SetKeyValue("distance", "60")
	entLight:SetKeyValue("_cone", "0")
	entLight:SetPos(self:GetPos())
	entLight:SetParent(self)
	entLight:Spawn()
	entLight:Activate()
	entLight:Fire("TurnOff", "", 0)
	self.entLight = entLight
	self:DeleteOnRemove(self.entLight)
	
	hook.Add("GravGunPunt", "GravGunPunt_Spore" .. self:EntIndex(), function(ply, ent)
		if !IsValid(ent) || ent != self then return end
		self.entPhysicsAttacker = ply
	end)
	self.splashDelay = CurTime() +2.5
	self.nextFlash = CurTime() +1
	self:EmitSound("weapons/flechette_grenade_blip1.wav", 100, 100)
	
	self.bGlow = true
	self:SetSkin(1)
	ParticleEffectAttach("hunter_flechette_glow_striderbuster", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	self.entLight:Fire("TurnOn", "", 0)
end

function ENT:Splash(dmg, radius, owner, bDontRemove)
	local owner = self.entOwner
	if !IsValid(owner) then owner = self end
	for i = 1, 30 do
		local ent = ents.Create("hunter_flechette")
		local vec = Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1)):GetNormal()
		ent:SetPos(self.Entity:GetPos() + vec * 15)
		ent:SetAngles(vec:Angle())
		ent:Spawn()
		ent:SetOwner(owner)
		ent:SetVelocity(vec *700)
	end
	ParticleEffect("hunter_projectile_explosion_1", self:GetPos(), self:GetAngles(), self)
	util.BlastDamage(self, owner, self:GetPos(), 120, 85)
	self:Remove()
end

function ENT:SetEntityOwner(ent)
	if ent:IsPlayer() then self:SetOwner(ent) end
	self.entOwner = ent
end

function ENT:PhysicsCollide(data, physobj)
	local velLast = math.max(data.OurOldVelocity:Length(), data.Speed)
	local velOld = physobj:GetVelocity()
	local velNew = velOld:GetNormal()
	velLast = math.max(velNew:Length(), velLast)
	
	local vel
	if data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() then vel = Vector(0,0,0)
	else vel = velNew *velLast *0.7 end
	
	physobj:SetVelocity(vel)
end

function ENT:OnRemove()
	hook.Remove("GravGunPunt", "GravGunPunt_Spore" .. self:EntIndex())
end

function ENT:Think()
	if CurTime() >= self.nextFlash then
		if !self.bFlashStarted then self.bFlashStarted = true; self:EmitSound("weapons/strider_buster/Strider_Buster_stick1.wav", 100, 100) end
		self.nextFlash = CurTime() +0.1
		self:EmitSound("weapons/flechette_grenade_blip1.wav", 100, 100)
		if self.bGlow then
			self.bGlow = false
			self:SetSkin(1)
			ParticleEffectAttach("hunter_flechette_glow_striderbuster", PATTACH_ABSORIGIN_FOLLOW, self, 0)
			self.entLight:Fire("TurnOn", "", 0)
		else
			self:StopParticles()
			self.bGlow = true
			self.entLight:Fire("TurnOff", "", 0)
		end
	end
	if !self.splashDelay || CurTime() < self.splashDelay then return end
	self:Splash(85, nil, self.entOwner)
	self.splashDelay = nil
end

