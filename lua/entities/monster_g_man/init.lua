AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.NPCFaction = NPC_FACTION_PLAYER
ENT.iClass = CLASS_PLAYER_ALLY
util.AddNPCClassAlly(CLASS_PLAYER_ALLY,"monster_g_man")
ENT.sModel = "models/half-life/gman.mdl"

ENT.bWander = true
ENT.bFadeOnDeath = true
ENT.bPlayDeathSequence = true

ENT.skName = "gman"
ENT.CollisionBounds = Vector(13,13,70)

ENT.iBloodType = BLOOD_COLOR_RED

ENT.tblDeathActivities = {
	[HITBOX_GENERIC] = {ACT_NO, ACT_BIGNO, ACT_DIESIMPLE}
}

function ENT:OnInit()
	self:SetNPCFaction(NPC_FACTION_PLAYER,CLASS_PLAYER_ALLY)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetCollisionBounds(self.CollisionBounds,Vector(self.CollisionBounds.x *-1,self.CollisionBounds.y *-1,0))
	
	self:CapabilitiesAdd(CAP_MOVE_GROUND)
	self:SetHealth(1200)
	self.nextSpeech = 0
	self:SetMaxYawSpeed(20)
end

function ENT:_PossPrimaryAttack(entPossessor, fcDone)
	if CurTime() < self.nextSpeech then fcDone(true); return end
	local tblSentences = {"!GM_SUIT", "!GM_NASTY", "!GM_POTENTIAL", "!GM_STEPIN", "!GM_OTHERWISE", "!GM_1CHOOSE", "!GM_2CHOOSE", "!GM_WISE", "!GM_REGRET", "!GM_WONTWORK"}
	local sSentence = tblSentences[math.random(1,10)]
	self:SpeakSentence(sSentence, entActivator)
	
	self.nextSpeech = CurTime() +self:GetSentenceLength(sSentence)
	fcDone(true)
end

function ENT:OnUse(activator,caller,type,value)
	if CurTime() < self.nextSpeech then return end
	local tblSentences = {"!GM_SUIT", "!GM_NASTY", "!GM_POTENTIAL", "!GM_STEPIN", "!GM_OTHERWISE", "!GM_1CHOOSE", "!GM_2CHOOSE", "!GM_WISE", "!GM_REGRET", "!GM_WONTWORK"}
	local sSentence = tblSentences[math.random(1,10)]
	self:SpeakSentence(sSentence, activator)
	
	self.nextSpeech = CurTime() +self:GetSentenceLength(sSentence)
end

function ENT:OnThink()
end

function ENT:SelectSchedule()
end

function ENT:OnCondition( iCondition )
end

function ENT:OnTakeDamage(dmginfo)
	self:BloodSplash(dmginfo:GetDamagePosition())
	self:BloodDecal(dmginfo)
end