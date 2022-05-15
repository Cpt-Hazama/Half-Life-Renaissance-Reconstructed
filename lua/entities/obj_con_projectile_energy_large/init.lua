
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

AccessorFunc(ENT, "bHoming", "Homing", FORCE_BOOL)
AccessorFunc(ENT, "fSpeed", "Speed", FORCE_NUMBER)
AccessorFunc(ENT, "entEnemy", "Enemy")

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetMaterial("invis")
	self:SetMoveCollide(3)
	self:DrawShadow(false)
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
	
	self.fSpeed = self.fSpeed || 200
	self.delayRemove = CurTime() +6
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
end

function ENT:Think()
	if CurTime() >= self.delayRemove then
		self:Remove()
		return
	end
	if !self.bHoming || !IsValid(self.entEnemy) then return end
	self:GetPhysicsObject():ApplyForceCenter((self.entEnemy:GetCenter() -self:GetPos()):GetNormal() *self.fSpeed)
end

function ENT:PhysicsCollide(data, physobj)
	local ent = data.HitEntity
	if !IsValid(ent) || (!ent:IsPlayer() && !ent:IsNPC()) then return true end
	if !IsValid(self.entOwner) || self.entOwner:Disposition(ent) <= 2 then
		if ent:GetClass() != "npc_turret_floor" then
			local dmg = DamageInfo()
			dmg:SetDamage(GetConVarNumber("sk_controller_dmg_projectile_large"))
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
	self:EmitSound("npc/controller/electro4.wav", 75, 100)
	self:Remove()
	return true
end

