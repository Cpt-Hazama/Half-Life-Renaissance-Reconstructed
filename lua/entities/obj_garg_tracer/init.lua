
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

AccessorFunc(ENT, "entEnemy", "Enemy")
function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetMaterial("invis")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	
	self:EmitSound("weapons/tripmine/mine_charge.wav", 75, 100)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0.1)
	end
	
	self.delayTraceStart = CurTime() +1
	self.delayTraceEnd = CurTime() +6
	self.multiplier = 0
	self.delayRemove = CurTime() +12
end

function ENT:Damage(ent)
	local entOwner = IsValid(self.entOwner) && self.entOwner || self
	local iDmg = GetConVarNumber("sk_gargantua_dmg_stomp")
	if ent:GetClass() == "npc_turret_floor" then
		if !ent.bSelfDestruct then
			ent:GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormal() *10000)
			ent:Fire("selfdestruct", "", 0)
			ent.bSelfDestruct = true
		end
	elseif ent:IsNPC() || ent:IsPlayer() then
		if ent:Health() -iDmg > 0 then
			local dmg = DamageInfo()
			dmg:SetDamage(iDmg)
			dmg:SetDamageType(DMG_DISSOLVE)
			dmg:SetAttacker(entOwner)
			dmg:SetInflictor(self)
			ent:TakeDamageInfo(dmg)
		else ent:slvDissolve(entOwner, self) end
		return
	end
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
end

function ENT:Think()
	self:NextThink(CurTime())
	if CurTime() >= self.delayRemove then self:Remove(); return end
	local posSelf = self:GetPos()
	for k, v in pairs(ents.FindInSphere(posSelf, 16)) do
		if IsValid(v) && (v:IsNPC() || v:IsPlayer()) && (!IsValid(self.entOwner) || self.entOwner:IsEnemy(v)) then
			self:Damage(v)
			self:Remove()
			return
		end
	end
	local tr = util.TraceLine({start = posSelf, endpos = posSelf +self:GetForward() *4, filter = {self, self.entOwner}})
	if tr.HitWorld then 
		self:Remove()
		return
	end
	
	local tr = util.TraceLine({start = posSelf, endpos = posSelf +self:GetUp() *-75, filter = {self, self.entOwner}})
	if tr.HitWorld then 
		if self.multiplier < 7 then self.multiplier = self.multiplier +0.3 end
		self:SetPos(tr.HitPos +Vector(0, 0, 12) +self:GetForward() *self.multiplier)
		if !IsValid(self.entEnemy) || self.entEnemy:Health() <= 0 || CurTime() >= self.delayTraceEnd then return true end
		self:TurnDegree(1.5, (self.entEnemy:GetPos() -self:GetPos()):Angle())
	end
	return true
end

function ENT:PhysicsCollide(data, physobj)
	return true
end

