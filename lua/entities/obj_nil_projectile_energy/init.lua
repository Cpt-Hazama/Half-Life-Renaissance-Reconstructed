
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

AccessorFunc(ENT, "fSpeed", "Speed", FORCE_NUMBER)
AccessorFunc(ENT, "entEnemy", "Enemy")
AccessorFunc(ENT, "bHoming", "Homing", FORCE_BOOL)

function ENT:Initialize()
	timer.Simple(8,function() if IsValid(self) then self:Remove() end end)
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
	entSprite:SetKeyValue("model","sprites/nhth1.vmt")
	entSprite:SetKeyValue("scale","1.5")
	entSprite:SetKeyValue("spawnflags","1")
	entSprite:SetPos(self:GetPos())
	entSprite:SetParent(self)
	entSprite:Spawn()
	entSprite:Activate()
	self:DeleteOnRemove(entSprite)

	self.fSpeed = self.fSpeed || 115
	if self.bHoming == nil then self.bHoming = true end
	
	self.tblEntBeams = {}
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
end

function ENT:CreateBeam(ent)	
	local entBeam = ents.Create("obj_beam")
	entBeam:SetStart(entBeam)
	entBeam:SetEnd(ent)
	entBeam:SetAmplitude(4)
	entBeam:SetBeamColor(0, 183, 239, 255)
	entBeam:SetWidth(2)
	entBeam:SetTexture("sprites/laserbeam2.vmt")
	entBeam:SetPos(self:GetPos())
	entBeam:SetParent(self)
	entBeam:Spawn()
	entBeam:Activate()
	entBeam:TurnOn()
	self:DeleteOnRemove(entBeam)

	self.tblEntBeams[ent] = entBeam
end

function ENT:RemoveBeam(ent)
	if !IsValid(self.tblEntBeams[ent]) then return end
	self.tblEntBeams[ent]:Remove()
	self.tblEntBeams[ent] = nil
end

function ENT:Think()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 256)) do
		if IsValid(v) && !self.tblEntBeams[v] && (v:IsNPC() || (v:IsPlayer() && !v:SLVIsPossessing())) && self:Visible(v) && (!IsValid(self.entOwner) || self.entOwner:IsEnemy(v)) then
			self:CreateBeam(v)
		end
	end
	for k, v in pairs(self.tblEntBeams) do
		if !IsValid(k) || k:Health() <= 0 || k:GetPos():Distance(self:GetPos()) > 256 || !self:Visible(k) then
			self:RemoveBeam(k)
		else
			k:TakeDamage(math.random(3,4), self.entOwner || self, self)
		end
	end
	if !self.bHoming then return end
	if IsValid(self.entEnemy) then
		local pos = self.entEnemy:GetCenter()
		self:GetPhysicsObject():ApplyForceCenter((pos - self:GetPos()):GetNormal() * self.fSpeed)
	end
end

function ENT:PhysicsCollide(data, physobj)
	if !data.HitEntity then return true end
	local ent = data.HitEntity
	if IsValid(ent) && (ent:IsPlayer() || ent:IsNPC()) then
		if !IsValid(self.entOwner) || self.entOwner:Disposition(ent) <= 2 then
			if ent:GetClass() != "npc_turret_floor" then
				local dmg = DamageInfo()
				dmg:SetDamage(GetConVarNumber("sk_nihilanth_dmg_projectile"))
				dmg:SetDamageType(DMG_GENERIC)
				dmg:SetAttacker(IsValid(self.entOwner) && self.entOwner || self)
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(data.HitPos)
				ent:TakeDamageInfo(dmg)
			elseif !ent.bSelfDestruct then
				ent:GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormal() *10000)
				ent:Fire("selfdestruct", "", 0)
				ent.bSelfDestruct = true
			end
		end
	end
	self:EmitSound("npc/controller/electro4.wav", 75, 100)
	self:Remove()
	return true
end

