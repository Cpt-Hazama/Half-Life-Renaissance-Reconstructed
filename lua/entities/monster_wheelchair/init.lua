AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.NPCFaction = NPC_FACTION_PLAYER
ENT.sModel = "models/decay/wheelchair_sci.mdl"
ENT.bGuard = false
ENT.bHeal = false
ENT.skHealth = "sk_scientist_health"
ENT.sSoundDir = "npc/keller/"
ENT.fFollowDistance = 110
ENT.bFlinchOnDamage = false

ENT.tblDeathActivities = {
	[HITBOX_GENERIC] = ACT_DIESIMPLE,
	[HITBOX_HEAD] = ACT_DIE_HEADSHOT
}

ENT.m_tbSounds = {
	["Wheelchair_Walk"] = "wheelchair_walk.wav",
	["Wheelchair_Jog"] = "wheelchair_jog.wav",
	["Pain"] = "dk_pain[1-7].wav",
	["Death"] = "dk_die[1-7].wav"
}

ENT.sentences = {
	["Follow"] = "!DK_OK[0-2]",
	["Wait"] = "!DK_WAIT[0-3]",
	["Idle"] = "!DK_IDLE[0-2]",
	["AnswerChatter"] = "!DK_IDLE[3-4]",
	["AnswerAllyShot"] = "!DK_SCARED[0-2]",
	["Hello"] = "!DK_HELLO[0-2]",
	["Shot"] = { "!DK_STOP[0-2]", "!DK_STOP[3-4]" },
	["Scream"] = "!DK_PLFEAR[0-3]",
	["Fear"] = "!DK_FEAR[0-6]"
}

local schdHide = ai_schedule_slv.New("Hide") 
schdHide:EngTask("TASK_FIND_COVER_FROM_ENEMY", 0)
schdHide:AddTask("TASK_CUSTOM_MOVE_PATH", ACT_RUN_SCARED)
schdHide:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)
schdHide:EngTask("TASK_PLAY_SEQUENCE", ACT_CROUCHIDLE)

function ENT:_Init()
	self:SetNPCFaction(NPC_FACTION_PLAYER,CLASS_PLAYER_ALLY)
end

function ENT:SelectScheduleHandle(enemy,dist,distPred,disp)
	if self:GetBehavior() == 1 then return end
	if disp == D_HT || disp == D_FR then
		if !self:CanSee(enemy) then return end
		self.delayHide = CurTime() +math.Rand(8,20)
		self:StartSchedule(schdHide)
		self.bInSchedule = true
	end
end

function ENT:EventHandle(...)
	local event = select(1,...)
	if event == "crouchidle" then
		if CurTime() >= self.delayHide || self:GetBehavior() > 0 || (IsValid(self.entEnemy) && self:CanSee(self.entEnemy)) then
			self.bInSchedule = false
			self.delayHide = nil
			self:SLVPlayActivity(ACT_IDLE,false,function()
				self.bInSchedule = false
				self:TaskComplete()
			end)
			return true
		end
		self:SLVPlayActivity(ACT_CROUCHIDLE,false)
		return true
	end
end