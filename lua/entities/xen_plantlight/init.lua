
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local posSpawn = tr.HitPos
	local angSpawn = tr.HitNormal:Angle()
	angSpawn.p = angSpawn.p +90
	
	local ent = ents.Create("xen_plantlight")
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
	self.mdl:SetModel("models/half-life/light.mdl")
	self.mdl:SetKeyValue("DefaultAnim", "idle1")
	self.mdl:SetPos(self:GetPos())
	self.mdl:SetAngles(self:GetAngles())
	self.mdl:SetParent(self)
	self.mdl:Spawn()
	self.mdl:Activate()
	self:DeleteOnRemove(self.mdl)
	
	local entLight = ents.Create("light_dynamic")
	entLight:SetKeyValue("_light", "255 194 53 100")
	entLight:SetKeyValue("brightness", "8")
	entLight:SetKeyValue("distance", "80")
	entLight:SetKeyValue("_cone", "0")
	entLight:SetParent(self.mdl)
	entLight:Spawn()
	entLight:Activate()
	entLight:Fire("SetParentAttachment", "0", 0)
	entLight:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(entLight)
	self.entLight = entLight
	
	local entSprite = ents.Create("env_sprite")
	entSprite:SetKeyValue("spawnflags", "1")
	entSprite:SetKeyValue("rendercolor", "255 235 155")
	entSprite:SetKeyValue("renderamt", "240")
	entSprite:SetKeyValue("model", "sprites/glow08.spr")
	entSprite:SetKeyValue("rendermode", "9")
	entSprite:SetKeyValue("scale", "0.2")
	entSprite:SetParent(self.mdl)
	entSprite:Spawn()
	entSprite:Activate()
	entSprite:Fire("SetParentAttachment", "0", 0)
	self:DeleteOnRemove(entSprite)
	self.entSprite = entSprite
	
	self.tNextHide = 0
end

function ENT:GetEntsInRange()
	local tblEnts = {}
	for k, ent in pairs(ents.FindInSphere(self:GetPos() +self:OBBCenter(), 120)) do
		if IsValid(ent) && (ent:IsNPC() && ent:GetClass() != "npc_chumtoad" || ent:IsPlayer()) && ent:Health() > 0 then
			table.insert(tblEnts, ent)
		end
	end
	return tblEnts
end

function ENT:Think()
	local cboundMin = self:GetRight() *5 +self:GetForward() *5 +self:GetUp() *63
	local cboundMax = self:GetRight() *-5 +self:GetForward() *-5
	self:SetCollisionBounds(cboundMin, cboundMax)
	
	local tblEnts = self:GetEntsInRange()
	if self.bHiding then
		if CurTime() >= self.tDeploy then
			self.tDeploy = nil
			self.bHiding = false
			self.mdl:Fire("SetAnimation", "delpoy", 0)
			self.mdl:Fire("SetDefaultAnimation", "idle1", 0)
			self.mdl:Fire("Skin", "0", 0.8)
			self.entLight:Fire("TurnOn", "", 0.8)
			self.entSprite:Fire("ShowSprite", "", 0.8)
			self.tNextHide = CurTime() +1.865
		elseif #tblEnts > 0 then
			self.tDeploy = CurTime() +6
		end
		return
	end
	if #tblEnts > 0 then
		self.mdl:Fire("SetAnimation", "retract", 0)
		self.mdl:Fire("SetDefaultAnimation", "hide", 0)
		self.mdl:Fire("Skin", "1", 0.1)
		self.entLight:Fire("TurnOff", "", 0.1)
		self.entSprite:Fire("HideSprite", "", 0.1)
		self.bHiding = true
		self.tDeploy = CurTime() +6
	end
end

function ENT:OnRemove()
end
