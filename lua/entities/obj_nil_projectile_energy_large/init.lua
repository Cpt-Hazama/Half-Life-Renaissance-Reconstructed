
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

AccessorFunc(ENT,"fSpeed","Speed",FORCE_NUMBER)
AccessorFunc(ENT,"entEnemy","Enemy")

function ENT:Initialize()
	timer.Simple(8,function() if IsValid(self) then self:Remove() end end)
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetMoveCollide(3)
	self:PhysicsInitSphere(55)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:slvSetHealth(1)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
	end
	
	local entSprite = ents.Create("env_sprite")
	entSprite:SetKeyValue("rendermode","5")
	entSprite:SetKeyValue("renderamt","200")
	entSprite:SetKeyValue("model","sprites/exit1_anim.vmt")
	entSprite:SetKeyValue("scale","3")
	entSprite:SetKeyValue("spawnflags","1")
	entSprite:SetPos(self:GetPos())
	entSprite:SetParent(self)
	entSprite:Spawn()
	entSprite:Activate()
	self:DeleteOnRemove(entSprite)

	self.fSpeed = self.fSpeed || 1000
	
	self.tblEntBeams = {}
	
	self.cspSound = CreateSound(self, "npc/nihilanth/nil_teleattack1.wav")
	self.cspSound:Play()
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
	self.cspSound:Stop()
end

function ENT:CreateBeam(ent)	
	local entBeam = ents.Create("obj_beam")
	entBeam:SetStart(entBeam)
	entBeam:SetEnd(ent)
	entBeam:SetAmplitude(2)
	entBeam:SetBeamColor(0, 183, 239, 255)
	entBeam:SetWidth(6)
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
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1024)) do
		if IsValid(v) && !self.tblEntBeams[v] && (v:IsNPC() || v:IsPlayer()) && self:Visible(v) && (!IsValid(self.entOwner) || self.entOwner:IsEnemy(v)) then
			self:CreateBeam(v)
		end
	end
	for k, v in pairs(self.tblEntBeams) do
		if !IsValid(k) || k:Health() <= 0 || k:GetPos():Distance(self:GetPos()) > 1024 || !self:Visible(k) then
			self:RemoveBeam(k)
		else
			k:TakeDamage(8, self.entOwner || self, self)
			local tblZaps = {1,2,3,5,6,7,8,9}
			k:EmitSound("ambient/energy/zap" .. tblZaps[math.random(1,#tblZaps)] .. ".wav", 75, 100)
		end
	end
	if !IsValid(self.entEnemy) then return end
	self:GetPhysicsObject():SetVelocity((self.entEnemy:GetPos() -self:GetPos() -self.entEnemy:GetVelocity() *0.4):GetNormal() *self.fSpeed)
end

function ENT:PhysicsCollide( data, physobj )
	if !data.HitEntity then return true end
	local ent = data.HitEntity
	if IsValid(ent) && (ent:IsPlayer() || ent:IsNPC()) then
		if !IsValid(self.entOwner) || self.entOwner:Disposition(ent) <= 2 then
			if ent:GetClass() != "npc_turret_floor" then
				local dmg = DamageInfo()
				dmg:SetDamage(GetConVarNumber("sk_nihilanth_dmg_projectile_large"))
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
	elseif IsValid(self.entOwner) then
		local npcs = {"monster_alien_slv", "monster_agrunt", "monster_controller"}
		self.entOwner:SummonAlly(data.HitPos -data.HitNormal *45,npcs[math.random(1,3)])
	end
	self:EmitSound("npc/controller/electro4.wav", 75, 100)
	self:Remove()
	return true
end

