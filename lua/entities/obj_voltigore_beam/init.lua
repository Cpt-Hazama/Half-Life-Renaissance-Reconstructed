
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:DrawShadow(false)
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
	end
	self.tblEntsBeams = {}
	self.delayRemove = CurTime() +8
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
end

function ENT:Think()
	if CurTime() < self.delayRemove then return end
	self:Remove()
end

function ENT:Wake()
	for i = 1, 5 do
		local entBeam = ents.Create("obj_beam")
		entBeam:SetPos(self:GetPos())
		entBeam:SetParent(self)
		entBeam:Spawn()
		entBeam:Activate()
		entBeam:SetAmplitude(6)
		entBeam:SetWidth(6)
		entBeam:SetUpdateRate(0.02)
		entBeam:SetTexture("sprites/volt_beam01")
		entBeam:SetBeamColor(252,0,246,255)
		entBeam:SetStart(self)
		entBeam:SetEnd(self:GetPos() +VectorRand() *100)
		entBeam:SetRandom(true)
		entBeam:SetDistance(700)
		entBeam:SetDelay(0.05)
		entBeam:TurnOn()
		table.insert(self.tblEntsBeams,entBeam)
		self:DeleteOnRemove(entBeam)
	end
end

function ENT:PhysicsCollide(data, physobj)
	if self.bHit then return end
	local ent = data.HitEntity
	if IsValid(ent) && (ent:IsPlayer() || ent:IsNPC()) then
		if !IsValid(self.entOwner) || self.entOwner:Disposition(ent) <= 2 then
			if ent:GetClass() != "npc_turret_floor" then
				local dmg = DamageInfo()
				dmg:SetDamage(GetConVarNumber("sk_voltigore_dmg_shock"))
				dmg:SetDamageType(DMG_SHOCK)
				dmg:SetAttacker(IsValid(self.entOwner) && self.entOwner || self)
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(data.HitPos)
				ent:TakeDamageInfo(dmg)
			elseif !ent.bSelfDestruct then
				ent:GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormal() *10000)
				ent:Fire("selfdestruct", "", 0)
				ent.bSelfDestruct = true
			end
			self:Remove()
			return
		end
	end
	self.bHit = true
	self.delayRemove = CurTime() +1
	physobj:EnableMotion(false)
	for k, v in pairs(self.tblEntsBeams) do
		if IsValid(v) then
			v:SetDelay(999)
		end
	end
	return true
end
