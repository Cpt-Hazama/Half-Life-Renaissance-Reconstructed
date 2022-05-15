
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local posSpawn = tr.HitPos
	local angSpawn = tr.HitNormal:Angle()
	angSpawn.p = angSpawn.p +90
	
	local ent = ents.Create("xen_tree")
	ent:SetPos(posSpawn)
	ent:SetAngles(angSpawn)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetColor(255, 255, 255, 0)
	self:DrawShadow(false)
	
	self.mdl = ents.Create("prop_dynamic_override")
	self.mdl:SetModel("models/half-life/tree.mdl")
	self.mdl:SetKeyValue("DefaultAnim", "idle1")
	self.mdl:SetPos(self:GetPos())
	self.mdl:SetAngles(self:GetAngles() +Angle(0,-90,0))
	self.mdl:SetParent(self)
	self.mdl:Spawn()
	self.mdl:Activate()
	self:DeleteOnRemove(self.mdl)
end

function ENT:GetEntsInRange()
	local tblEnts = {}
	for k, ent in pairs(ents.FindInSphere(self:GetPos() +self:OBBCenter(), 120)) do
		if IsValid(ent) && (ent:IsNPC() && ent:GetClass() != "npc_chumtoad" || ent:IsPlayer()) && ent:Health() > 0 && self:EntInViewCone(ent, 45) then
			table.insert(tblEnts, ent)
		end
	end
	return tblEnts
end

function ENT:Think()
	local cboundMin = self:GetRight() *24 +self:GetForward() *24 +self:GetUp() *190
	local cboundMax = self:GetRight() *-24 +self:GetForward() *-24
	self:SetCollisionBounds(cboundMin, cboundMax)
	
	if self.bInAttack then
		if self.tAttackDmg && CurTime() >= self.tAttackDmg then
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage(23)
			dmgInfo:SetAttacker(self)
			dmgInfo:SetInflictor(self)
			dmgInfo:SetDamageType(DMG_SLASH)
			local bHit
			for k, ent in pairs(self:GetEntsInRange()) do
				if !bHit then
					bHit = true
					self:EmitSound("npc/zombie/claw_strike" ..math.random(1,3).. ".wav", 75, 100)
				end
				dmgInfo:SetDamagePosition(ent:NearestPoint(self:GetPos() +self:OBBCenter()))
				ent:TakeDamageInfo(dmgInfo)
				if ent:IsPlayer() then
					ent:ViewPunch(Angle(12, 0, 0))
				end
			end
			self.tAttackDmg = nil
		elseif CurTime() >= self.tAttackEnd then
			self.tAttackEnd = nil
			self.bInAttack = false
			self.mdl:Fire("SetAnimation", "idle1", 0)
			self.mdl:Fire("SetDefaultAnimation", "idle1", 0)
		end
		return
	end
	if #self:GetEntsInRange() > 0 then
		self.mdl:Fire("SetAnimation", "attack", 0)
		self.bInAttack = true
		self.tAttackDmg = CurTime() +0.35
		self.tAttackEnd = CurTime() +1.165
	end
end

function ENT:OnRemove()
end
