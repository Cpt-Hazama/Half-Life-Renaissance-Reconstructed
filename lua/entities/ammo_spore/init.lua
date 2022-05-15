
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_spore")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	return ent
end

ENT.AutomaticFrameAdvance = true

function ENT:Initialize()
	self:SetModel("models/spore_ammo.mdl")
	self:DrawShadow(false)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(Vector(-16,-16,0), Vector(16,16,14))
	
	local mdl = ents.Create("prop_dynamic_override")
	mdl:SetModel("models/spore_ammo.mdl")
	mdl:SetPos(self:GetPos())
	mdl:SetAngles(self:GetAngles())
	mdl:SetParent(self)
	mdl:Spawn()
	mdl:Activate()
	mdl:SetBodygroup(1,1)
	self.sporeMdl = mdl
	self:DeleteOnRemove(mdl)
	
	mdl:Fire("SetAnimation", "idle1", 0)
	mdl:Fire("SetDefaultAnimation", "idle1", 0)
end

function ENT:Think()
	if self.nextRecharge && CurTime() >= self.nextRecharge then
		self.nextRecharge = nil
		self.sporeMdl:Fire("SetAnimation", "spawndn", 0)
		self.bOpen = true
		self.nextIdle = CurTime() +3.8
		self.sporeMdl:SetBodygroup(1,1)
	end
	if !self.nextIdle || CurTime() < self.nextIdle then return end
	local anim
	if !self.bOpen then anim = "idle" else anim = "idle1"; self.bDepleted = false end
	self.sporeMdl:Fire("SetDefaultAnimation", anim, 0)
	self.sporeMdl:Fire("SetAnimation", anim, 0)
	self.nextIdle = nil
	self.bOpen = false
end

function ENT:Touch(ent)
	if self.bDepleted || !ent:IsPlayer() || !ent:Alive() then return end
	if ent:GetAmmunition("spore") == 20 then return end
	self:Deplete()
	ent:EmitSound("items/ammo_pickup.wav", 75, 100)
	local ammo = util.GetAmmoName("spore")
	umsg.Start("HLR_HUDItemPickedUp", ent)
		umsg.String(ammo .. "," .. 1)
	umsg.End()
	ent:AddAmmunition("spore", 1)
end

function ENT:Deplete()
	self.sporeMdl:Fire("SetAnimation", "snatchdn", 0)
	self.nextIdle = CurTime() +0.3
	self.nextRecharge = CurTime() +22
	self.bDepleted = true
	self.sporeMdl:SetBodygroup(1,0)
	self:EmitSound("weapons/spore_launcher/spore_ammo.wav", 75, 100)
end

function ENT:OnTakeDamage(dmg)
	if self.bDepleted then return end
	local entSpore = ents.Create("obj_spore")
	entSpore:SetEntityOwner(entSpore)
	entSpore:SetPos(self:GetPos() +self:GetUp() *10)
	entSpore:SetGrenade(true)
	entSpore:Spawn()
	entSpore:Activate()
	
	local phys = entSpore:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceCenter(self:GetUp() *600)
	end
	self:Deplete()
end