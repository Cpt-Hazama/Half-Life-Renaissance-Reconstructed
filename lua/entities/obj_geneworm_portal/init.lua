
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
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
	entSprite:SetKeyValue("model","sprites/e-tele1_anim.vmt")
	entSprite:SetKeyValue("scale","1")
	entSprite:SetKeyValue("spawnflags","1")
	entSprite:SetPos(self:GetPos())
	entSprite:SetParent(self)
	entSprite:Spawn()
	entSprite:Activate()
	self.entSprite = entSprite
	self:DeleteOnRemove(entSprite)
	
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
		self:DeleteOnRemove(entBeam)
	end
	
	self.iScale = 1
	self.lifeTime = CurTime() +2
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:PhysicsCollide(data, physobj)
end

function ENT:OnRemove()
end

function ENT:SpawnStrooper()
	local entStrooper = ents.Create("monster_shocktrooper")
	entStrooper:SetPos(self:GetPos() -Vector(0,0,42.5))
	entStrooper:SetAngles(self:GetAngles())
	entStrooper:Spawn()
	entStrooper:Activate()
	if IsValid(self.entOwner) then entStrooper:SetSquad(self.entOwner:GetSquad()) end
end

function ENT:Think()
	if self.lifeTime then
		if CurTime() < self.lifeTime then
			self.iScale = self.iScale +0.1
			self.entSprite:Fire("SetScale", self.iScale, 0)
			return
		else
			self.lifeTime = nil
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
			self.delayVanish = CurTime() +1
			self:EmitSound("debris/beamstart2.wav", 100, 100)
		end
	end
	if CurTime() < self.delayVanish then return end
	self.iScale = self.iScale -0.02
	self.entSprite:Fire("SetScale", self.iScale, 0)
	if self.iScale <= 0.1 then self:SpawnStrooper(); self:Remove() end
	self:NextThink(CurTime())
	return true
end

