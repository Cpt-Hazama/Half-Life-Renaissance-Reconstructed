
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.AmmoType = "uranium"
ENT.AmmoPickup = 20
ENT.MaxAmmo = 100
ENT.model = "models/weapons/half-life/w_gaussammo.mdl"

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_gaussclip")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	return ent
end