
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.AmmoType = "RPG_Round"
ENT.AmmoPickup = 1
ENT.MaxAmmo = -1
ENT.model = "models/weapons/half-life/w_rpgammo.mdl"

function ENT:SpawnFunction(pl, tr)
	if !tr.Hit then return end
	local pos = tr.HitPos
	local ang = tr.HitNormal:Angle() +Angle(90,0,0)
	local ent = ents.Create("ammo_rpgclip")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	return ent
end