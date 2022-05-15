
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.AmmoType = "9mm"
ENT.AmmoPickup = 18
ENT.MaxAmmo = 250
ENT.model = "models/weapons/half-life/w_9mmARclip.mdl"

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_9mmAR")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	return ent
end