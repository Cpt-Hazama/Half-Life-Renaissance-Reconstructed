
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.AmmoType = "357"
ENT.AmmoPickup = 6
ENT.MaxAmmo = -1
ENT.model = "models/weapons/half-life/w_357ammo.mdl"

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_357")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	return ent
end