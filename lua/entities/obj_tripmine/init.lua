
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/weapons/half-life/w_tripmine.mdl")
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:slvSetHealth(1)
	
	self.cspCharge = CreateSound(self, "weapons/tripmine/mine_charge.wav")
	self.cspCharge:Play()
	
	self.delayCharged = CurTime() +3.2
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(entOwner)
	self.entOwner = ent
end

function ENT:Think()
	if self.bActive then
		if !IsValid(self.entBeam) then self:Remove(); return end
		local pos = self:GetPos()
		local tr = util.QuickTrace(self:GetPos(), self:GetForward() *32768, self)
		self.entBeam:SetEnd(tr.HitPos)
		if IsValid(tr.Entity) then self:DoExplode(100, 110, self.entOwner) end
		self:NextThink(CurTime())
		return true
	end
	if CurTime() < self.delayCharged then return end
	self:EmitSound("weapons/tripmine/mine_activate.wav", 75, 100)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(Vector(2, -8, 3), Vector(-8, 12, -5))	
	
	local pos = self:GetPos()
	local tr = util.QuickTrace(pos, self:GetForward() *32768, self)
	if IsValid(tr.Entity) then self:DoExplode(); return end
	local entBeam = ents.Create("obj_beam")
	entBeam:SetWidth(2.5)
	entBeam:SetPos(pos)
	entBeam:SetParent(self)
	entBeam:SetStart(entBeam)
	entBeam:SetEnd(tr.HitPos)
	entBeam:SetTexture("sprites/bluelaser1.vmt")
	entBeam:Spawn()
	entBeam:Activate()
	entBeam:TurnOn()
	self.entBeam = entBeam
	self:DeleteOnRemove(entBeam)
	self.bActive = true
	self.delayCharged = nil
end

function ENT:OnTakeDamage(dmg)
	if self.bDead then return end
	self:slvSetHealth(self:Health() -dmg:GetDamage())

	if self:Health() <= 0 then
		self.bDead = true
		self:DoExplode(100, 110, self.entOwner)
	end
end

function ENT:PhysicsCollide(data, physobj)
	return true
end

function ENT:OnRemove()
	self.cspCharge:Stop()
end

