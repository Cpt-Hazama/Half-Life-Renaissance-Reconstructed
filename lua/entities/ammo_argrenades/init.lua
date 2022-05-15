
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.AmmoType = "m4grenade"
ENT.AmmoPickup = 2
ENT.MaxAmmo = 10
ENT.model = "models/weapons/half-life/w_ARgrenade.mdl"

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_argrenades")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	return ent
end