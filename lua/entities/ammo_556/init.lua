AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.AmmoType = "45mm"
ENT.AmmoPickup = 20
ENT.MaxAmmo = 200
ENT.model = "models/weapons/opfor/w_saw_clip.mdl"

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_556")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	return ent
end