include('shared.lua')

language.Add("weapon_barnacle", "Barnacle")

SWEP.PrintName = "Barnacle Grapple"
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false

SWEP.WepSelectIcon = surface.GetTextureID("HUD/weapons/weapon_barnacle") 
SWEP.BounceWeaponIcon = false 

local tblEnts = {}
local mat = Material("bgrap_tongue_01")
usermessage.Hook("HLR_barnaclegun_tonguestart", function(um)
	local self = um:ReadEntity()
	local posDest = um:ReadVector()
	if !IsValid(self) || !posDest then return end
	local startTime = CurTime()
	local bHit
	local iIndex = self:EntIndex()
	hook.Add("RenderScreenspaceEffects", "HLR_bgrap_tongue_draw" .. iIndex, function()
		if !IsValid(self) then
			hook.Remove("RenderScreenspaceEffects", "HLR_bgrap_tongue_draw" .. iIndex)
			tblEnts[iIndex] = nil
			return
		end
		local width
		local posStart
		local ent
		local posDestLocal
		if tblEnts[iIndex] then
			local ent = tblEnts[iIndex].ent
			if IsValid(ent) then
				local posDestLocal = tblEnts[iIndex].posDest
				posDest = ent:LocalToWorld(posDestLocal)
			end
		end
		if LocalPlayer() == self.Owner && GetViewEntity() == LocalPlayer() then posStart = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("0")	).Pos; width = 4
		else posStart = self:GetAttachment(self:LookupAttachment("tip")).Pos; width = 2 end
		local posEnd
		if !bHit then
			local normal = (posDest -posStart):GetNormal()
			posEnd = posStart +normal *((CurTime() -startTime) *1000)
			local tr = util.TraceLine({start = posEnd, endpos = posEnd +normal *12, filter = {self, self.Owner}})
			if tr.Hit then bHit = true end
		else posEnd = posDest end
		cam.Start3D(EyePos(), EyeAngles())
			render.SetMaterial(mat)
			render.DrawBeam(posStart, posEnd, width, -0.4, -0.0015625, Color(255,255,255,255))
		cam.End3D()
	end)
end)

usermessage.Hook("HLR_barnaclegun_tonguestop", function(um)
	local iIndex = um:ReadLong()
	if !iIndex then return end
	hook.Remove("RenderScreenspaceEffects", "HLR_bgrap_tongue_draw" .. iIndex)
	tblEnts[iIndex] = nil
end)

usermessage.Hook("HLR_barnaclegun_tongue_setent", function(um)
	local self = um:ReadEntity()
	local ent = um:ReadEntity()
	local posDestLocal = um:ReadVector()
	if !IsValid(self) || !IsValid(ent) || !posDestLocal then return end
	tblEnts[self:EntIndex()] = {ent = ent, posDest = posDestLocal}
end)