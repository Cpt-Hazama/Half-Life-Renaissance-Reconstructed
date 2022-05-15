
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

AccessorFunc(ENT, "fSpeed", "Speed", FORCE_NUMBER)
AccessorFunc(ENT, "fHeight", "Height", FORCE_NUMBER)
AccessorFunc(ENT, "fRadius", "Radius", FORCE_NUMBER)
AccessorFunc(ENT, "iDir", "Direction", FORCE_NUMBER)
AccessorFunc(ENT, "fDelay", "Delay", FORCE_NUMBER)

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetMoveCollide(3)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:slvSetHealth(1)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
	end
	
	local entSprite = ents.Create("env_sprite")
	entSprite:SetKeyValue("rendermode","5")
	entSprite:SetKeyValue("renderamt","255")
	entSprite:SetKeyValue("model","sprites/muz2.spr")
	entSprite:SetKeyValue("scale","1")
	entSprite:SetKeyValue("spawnflags","1")
	entSprite:SetPos(self:GetPos())
	entSprite:SetParent(self)
	entSprite:Spawn()
	entSprite:Activate()
	self:DeleteOnRemove(entSprite)
	
	self.fSpeed = self.fSpeed || 500
	self.fHeight = self.fHeight || 200
	self.fRadius = self.fRadius || 300
	self.iDir = self.iDir || 1
	self.fDelay = self.fDelay || 3
end

function ENT:Absorb()
	self.fRadius = 0
	self.fSpeed = self.fSpeed *2
	local entBeam = ents.Create("obj_beam")
	entBeam:SetStart(entBeam)
	entBeam:SetEnd(self.entOwner, 1)
	entBeam:SetAmplitude(0)
	entBeam:SetBeamColor(255, 149, 43, 255)
	entBeam:SetWidth(5)
	entBeam:SetTexture("sprites/laserbeam2.vmt")
	entBeam:SetPos(self:GetPos())
	entBeam:SetParent(self)
	entBeam:Spawn()
	entBeam:Activate()
	entBeam:TurnOn()
	self:DeleteOnRemove(entBeam)
	
	self.bDepleted = true
	timer.Simple(8, function() if IsValid(self) then self:Remove() end end)
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
end

function ENT:Think()
	if !IsValid(self.entOwner) then self:Remove(); return end
	local pos = self.entOwner:GetPos() +self.entOwner:GetForward() *100
	local trace = util.QuickTrace(pos, Vector(0, 0, 70), {self, self.entOwner})
	
	pos.z = pos.z +trace.Fraction *self.fHeight
	
	local AimVec = self.entOwner:GetForward()
	AimVec.z = AimVec.z /-3
	pos = pos +AimVec *-80
	
	local Offset = 6.2832
	local mSin = math.sin(CurTime() +self.fDelay +Offset) *self.fRadius
	local mCos = math.cos(CurTime() +self.fDelay +Offset) *self.fRadius
	if self.iDir == 1 then
		pos.x = pos.x +mCos
		pos.y = pos.y +mSin
	else
		pos.x = pos.x +mSin
		pos.y = pos.y +mCos
	end
	
	pos.z = pos.z +math.sin(CurTime()) * 10
	
	local ang = pos -self:GetPos()
	local dist = ang:Length()
	local physobj = self:GetPhysicsObject()
	local vel = physobj:GetVelocity()

	physobj:ApplyForceCenter(ang *dist /self.fSpeed +vel /3 *-1)
	if self.bDepleted && dist <= 50 then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, physobj)
	return true
end

