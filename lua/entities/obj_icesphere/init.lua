
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	timer.Simple(8,function() if IsValid(self) then self:Remove() end end)
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
	end
	
	ParticleEffectAttach("icesphere_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

function ENT:SetSize(iSize)
	local mdl
	if iSize == 1 then mdl = "models/icesphere_small.mdl"
	elseif iSize == 2 then mdl = "models/icesphere_medium.mdl"
	else mdl = "models/icesphere_large.mdl" end
	self:SetModel(mdl)
	self.iSize = iSize
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
end

function ENT:Think()
	if IsValid(self.entOwner) && self:GetPos():Distance(self.entOwner:GetPos()) >= 2000 then self:Remove() end
end

function ENT:Splash()
	self.bCollided = true
	local pos = self:GetPos()
	ParticleEffect("icesphere_splash", pos, Angle(0,0,0), self)
	self:EmitSound("npc/bullsquid/bc_spithit" .. math.random(1,3) .. ".wav", 75, 100)
	local iFreeze
	if self.iSize == 1 then iFreeze = 20
	elseif self.iSize == 2 then iFreeze = 35
	else iFreeze = 50 end
	for k, v in pairs(ents.FindInSphere(pos, 250)) do
		if (v:IsNPC() || v:IsPlayer()) && v != self.entOwner then
			local posDmg = v:NearestPoint(pos)
			local iFreeze = math.Clamp((250 -pos:Distance(posDmg)) /250 *iFreeze, 1, iFreeze)
			v:SetFrozen(iFreeze)
		end
	end
	timer.Simple(0.1, function() if IsValid(self) then self:Remove() end end)
end

function ENT:PhysicsCollide(data, physobj)
	if !data.HitEntity || self.bCollided then return true end
	self:Splash()
	return true
end

