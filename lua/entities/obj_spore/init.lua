
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

AccessorFunc(ENT, "bGrenade", "Grenade", FORCE_BOOL)
function ENT:Initialize()
	self:SetModel("models/opfor/spore.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:slvSetHealth(1)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		if !self.bGrenade then
			phys:EnableGravity(false)
		end
		phys:SetBuoyancyRatio(0)
	end
	ParticleEffectAttach("spore_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	if self.bGrenade then
		self:PhysicsInitSphere(4, "metal_bouncy")
		self:SetCollisionBounds(Vector(4, 4, 4), Vector(-4, -4, -4))
		self.splashDelay = CurTime() +2.5
	end
	
	hook.Add("GravGunPunt", "GravGunPunt_Spore" .. self:EntIndex(), function(ply, ent)
		if IsValid(ent) && ent == self then self.entPhysicsAttacker = ply end
	end)
end

function ENT:OnTakeDamage(dmg)
	if self.bDead then return end
	self:Splash(85, nil, self.entOwner)
end

function ENT:Splash(dmg, radius, owner, bDontRemove)
	self.bDead = true
	radius = radius || 60
	dmg = dmg || 65
	if IsValid(self.entPhysicsAttacker) then owner = self.entPhysicsAttacker
	elseif !IsValid(owner) then owner = self end
	local effectdata = EffectData()
	effectdata:SetStart(self:GetPos())
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetScale(1)
	ParticleEffect("spore_splash", self:GetPos(), self:GetAngles(), self.entOwner)
	self:EmitSound("weapons/spore_launcher/splauncher_impact.wav", 100, 100)
	util.BlastDamage(self, owner, self:GetPos(), radius, dmg)
	
	local iDistMin = 26
	local tr
	for i = 1, 6 do
		local posEnd = self:GetPos()
		if i == 1 then posEnd = posEnd +Vector(0,0,25)
		elseif i == 2 then posEnd = posEnd -Vector(0,0,25)
		elseif i == 3 then posEnd = posEnd +Vector(0,25,0)
		elseif i == 4 then posEnd = posEnd -Vector(0,25,0)
		elseif i == 5 then posEnd = posEnd +Vector(25,0,0)
		elseif i == 6 then posEnd = posEnd -Vector(25,0,0) end
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = posEnd
		tracedata.filter = self
		local trace = util.TraceLine(tracedata)
		local iDist = self:GetPos():Distance(trace.HitPos)
		if trace.HitWorld && iDist < iDistMin then
			iDistMin = iDist
			tr = trace
		end
	end
	if tr then
		util.Decal("YellowBlood",tr.HitPos +tr.HitNormal,tr.HitPos -tr.HitNormal)  
	end
	if !bDontRemove then self:Remove() end
end

function ENT:SetEntityOwner(ent)
	if ent:IsPlayer() then self:SetOwner(ent) end
	self.entOwner = ent
end

function ENT:PhysicsCollide(data, physobj)
	if !self.bGrenade || data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() then
		self:Splash(85, nil, self.entOwner)
		return true
	end
	local velLast = math.max(data.OurOldVelocity:Length(), data.Speed)
	local velOld = physobj:GetVelocity()
	local velNew = velOld:GetNormal()
	velLast = math.max(velNew:Length(), velLast)
	
	local vel = velNew *velLast *0.9
	physobj:SetVelocity(vel)
	if velOld:Length() < 120 then return end
	self:EmitSound("weapons/spore_launcher/spore_hit" .. math.random(1,3) .. ".wav")
end

function ENT:OnRemove()
	hook.Remove("GravGunPunt", "GravGunPunt_Spore" .. self:EntIndex())
end

function ENT:Think()
	if !self.splashDelay || CurTime() < self.splashDelay then return end
	self:Splash(85, nil, self.entOwner)
	self.splashDelay = nil
end

