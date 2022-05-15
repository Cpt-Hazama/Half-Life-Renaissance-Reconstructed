
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

AccessorFunc(ENT, "bDepleted", "Depleted", FORCE_BOOL)
AccessorFunc(ENT, "bTeleport", "Teleport", FORCE_BOOL)

function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
	
	local entSprite = ents.Create("env_sprite")
	entSprite:SetKeyValue("rendermode","5")
	entSprite:SetKeyValue("renderamt","255")
	entSprite:SetKeyValue("model","sprites/exit1_anim.vmt")
	entSprite:SetKeyValue("scale","1")
	entSprite:SetKeyValue("spawnflags","1")
	entSprite:SetPos(self:GetPos())
	entSprite:SetParent(self)
	entSprite:Spawn()
	entSprite:Activate()
	self:DeleteOnRemove(entSprite)
	
	self.tblEntsBeams = {}
	for i = 1, 10 do
		local entBeam = ents.Create("obj_beam")
		entBeam:SetPos(self:GetPos())
		entBeam:SetParent(self)
		entBeam:Spawn()
		entBeam:Activate()
		entBeam:SetAmplitude(5)
		entBeam:SetWidth(10)
		entBeam:SetUpdateRate(0.02)
		entBeam:SetTexture("sprites/portal_greenbeam")
		entBeam:SetBeamColor(200,255,100,255)
		entBeam:SetStart(self)
		entBeam:SetEnd(self:GetPos() +VectorRand() *100)
		entBeam:SetRandom(true)
		entBeam:SetDistance(400)
		entBeam:SetDelay(0.05)
		entBeam:TurnOn()
		table.insert(self.tblEntsBeams, entBeam)
		self:DeleteOnRemove(entBeam)
	end
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:HitObject()
	self:SetDepleted(true)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
	for k, v in pairs(self.tblEntsBeams) do
		v:SetDelay(999)
	end
	
	local entShock = ents.Create("obj_shockwave")
	entShock:SetPos(self:GetPos())
	entShock:SetDelay(0.2)
	entShock:SetRadius(400)
	entShock:SetTexture("sprites/disp_ring")
	entShock:Spawn()
	entShock:Activate()

	self.blastDelay = CurTime() +0.6
end

function ENT:PhysicsCollide(data, physobj)
	if self:GetDepleted() then return end
	self:HitObject()
end

function ENT:OnRemove()
end

function ENT:Think()
	if self.blastDelay && CurTime() >= self.blastDelay then
		local owner = IsValid(self.entOwner) && self.entOwner || self
		util.BlastDamage(self, owner, self:GetPos(), 200, 100)
		if self:GetTeleport() then
			local ent
			local flDist = 81
			for k, v in pairs(ents.FindInSphere(self:GetPos(), 80)) do
				if v != self && ((v:IsPhysicsEntity() && v:GetPhysicsObject():GetMass() <= 3500) || v:IsNPC() || v:IsPlayer()) then
					local flDistOBB = self:OBBDistance(v)
					if flDistOBB < flDist && (!v:IsNPC() || (v:GetHullType() <= 6 || v:GetHullType() == 9))  then
						ent = v
						flDist = flDistOBB
					end
				end
			end
			if IsValid(ent) then
				local pos, normal = util.GetRandomWorldPos()
				if pos then
					ent:SetPos(pos +normal *(ent:OBBMaxs().z +4))
				end
			end
		end
		self:EmitSound("weapons/displacer/displacer_teleport.wav", 75, 100)
		self:Remove()
	end
end

