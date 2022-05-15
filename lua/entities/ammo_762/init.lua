
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.AmmoType = "308"
ENT.AmmoPickup = 5
ENT.MaxAmmo = 10
ENT.model = "models/weapons/opfor/w_m40a1clip.mdl"

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_762")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	return ent
end