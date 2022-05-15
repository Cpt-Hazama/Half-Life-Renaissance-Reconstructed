
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction(ply, tr)
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos -tr.HitNormal *14
	local SpawnAngles = tr.HitNormal:Angle()
	SpawnAngles.pitch = SpawnAngles.pitch +90
	
	local ent = ents.Create("obj_crystal")
	ent:SetPos(SpawnPos)
	ent:SetAngles(SpawnAngles)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	self:SetModel("models/half-life/crystal.mdl")
	self:SetSolid(SOLID_BBOX)
	self:slvSetHealth(225)

	local cboundMin = self:GetRight() *22 +self:GetForward() *22 +self:GetUp() *14
	local cboundMax = self:GetRight() *-22 +self:GetForward() *-22 +self:GetUp() *95
	self:SetCollisionBounds(cboundMin, cboundMax)
	
	local entLight = ents.Create("light_dynamic")
	entLight:SetKeyValue("_light", "255 130 4 750")
	entLight:SetKeyValue("brightness", "6")
	entLight:SetKeyValue("distance", "75")
	entLight:SetKeyValue("_cone", "0")
	entLight:SetPos(self:GetPos() +self:GetUp() *55)
	entLight:SetParent(self)
	entLight:Spawn()
	entLight:Activate()
	entLight:Fire("TurnOn", "", 0)
	
	self:DeleteOnRemove(entLight)
	
	self.cspCycle = CreateSound(self, "ambience/alien_cycletone.wav") 
	self.cspCycle:Play()
end

function ENT:OnRemove()
	self.cspCycle:Stop()
end

function ENT:Break()
	local entSprite = ents.Create("env_sprite")
	entSprite:SetKeyValue("spawnflags","2")
	entSprite:SetKeyValue("scale","15")
	entSprite:SetKeyValue("framerate","10")
	entSprite:SetKeyValue("model","sprites/Fexplo1.spr")
	entSprite:SetKeyValue("rendercolor","255 128 0")
	entSprite:SetKeyValue("rendermode","5")
	entSprite:SetKeyValue("renderfx","14")
	entSprite:SetPos(self:GetPos() +self:GetUp() *55)
	entSprite:Spawn()
	entSprite:Fire("kill", "", 2)
	entSprite:Fire("ShowSprite", "", 0)
	
	self:EmitSound("debris/bustglass" .. math.random(1,3) .. ".wav",75,100)
	self:EmitSound("weapons/mortarhit.wav",75,100)
	self:EmitSound("ambience/xtal_down1.wav",75,100)
	self:Remove()
end

function ENT:OnTakeDamage(dmg)
	self:slvSetHealth(self:Health() -dmg:GetDamage())
	if self:Health() <= 0 then
		self:Break()
	end
end

function ENT:Think()
	local cboundMin = self:GetRight() *22 +self:GetForward() *22 +self:GetUp() *14
	local cboundMax = self:GetRight() *-22 +self:GetForward() *-22 +self:GetUp() *95
	self:SetCollisionBounds(cboundMin, cboundMax)
end
