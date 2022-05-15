AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.NPCFaction = NPC_FACTION_ZOMBIE
ENT.iClass = CLASS_ZOMBIE
util.AddNPCClassAlly(CLASS_ZOMBIE,"monster_zombie_soldier")
ENT.sModel = "models/opfor/zombie_soldier.mdl"

function ENT:_Init()
	self:SetNPCFaction(NPC_FACTION_ZOMBIE,CLASS_ZOMBIE)
end