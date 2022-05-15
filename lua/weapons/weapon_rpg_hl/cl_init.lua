include('shared.lua')

language.Add("weapon_rpg_hl", "RPG")

SWEP.PrintName = "RPG"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false

SWEP.WepSelectIcon = surface.GetTextureID("HUD/weapons/weapon_rpg_hl") 
SWEP.BounceWeaponIcon = false 

local mat = Material("sprites/redglow1")
usermessage.Hook("HLR_rpg_laserdot_draw", function(um)
	local iIndex = um:ReadLong()
	local ent = ents.GetByIndex(iIndex)
	local bValid
	if IsValid(ent) then bValid = true end
	local plyLocal = LocalPlayer()
	local nextInvalidAdd = 0
	local iInvalidInc = 0
	hook.Add("HUDPaint", "HLR_rpg_laserdot_draw" .. iIndex, function()
		if !bValid then
			ent = ents.GetByIndex(iIndex)
			if IsValid(ent) then bValid = true
			else
				if CurTime() >= nextInvalidAdd then
					nextInvalidAdd = CurTime() +0.1
					iInvalidInc = iInvalidInc +1
				end
				if iInvalidInc >= 10 then
					hook.Remove("HUDPaint", "HLR_rpg_laserdot_draw" .. iIndex)
				end
				return
			end
		end
		if !IsValid(ent) || !IsValid(ent.Owner) || !ent.Owner:Alive() || ent.Owner:GetActiveWeapon() != ent then
			hook.Remove("HUDPaint", "HLR_rpg_laserdot_draw" .. iIndex)
			return
		end
		if !ent:GetNetworkedBool("laser") then return end
		local owner = ent.Owner
		local trOwner = util.TraceLine(util.GetPlayerTrace(owner))
		local pos = trOwner.HitPos
		local fDist = owner:slvDistance(pos)
		local size = math.Clamp((50 /fDist) *800, 0, 50)
		local tr = {}
		if owner != plyLocal then
			local posStart = plyLocal:GetShootPos()
			local posEnd = pos +trOwner.HitNormal *4
			local tracedata = {}
			tracedata.start = posStart
			tracedata.endpos = posEnd
			tracedata.filter = plyLocal
			tr = util.TraceLine(tracedata)
		end
		if !tr.Hit then
			cam.Start3D(EyePos(), EyeAngles())
				render.SetMaterial(mat)
				render.DrawSprite(pos, size, size, Color(255, 0, 0, 255))
			cam.End3D()
		end
	end)
end)