AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.NPCFaction = NPC_FACTION_MILITARY
ENT.iClass = CLASS_MILITARY
util.AddNPCClassAlly(CLASS_MILITARY,"monster_sentry_decay")
ENT.sModel = "models/decay/sentry.mdl"
ENT.fViewAngle = 360
ENT.fViewDistance = 1200
ENT.fHearDistance = 0
ENT.AIType = 1

ENT.bWander = false
ENT.bPlayIdle = false
ENT.bPlayDeathSequence = true
ENT.bFlinchOnDamage = false
ENT.tblIgnoreDamageTypes = {DMG_DISSOLVE, DMG_POISON}

ENT.iBloodType = false
ENT.sSoundDir = "npc/turret/"

ENT.m_tbSounds = {
	["Death"] = "tu_die[1-3].wav",
	["Deploy"] = "tu_deploy.wav",
	["Retire"] = "tu_retract.wav",
	["Ping"] = "tu_ping.wav"
}

ENT.tblAlertAct = {}
ENT.tblDeathActivities = {
	[HITBOX_GENERIC] = ACT_DIESIMPLE
}

function ENT:OnInit()
	self:SetNPCFaction(NPC_FACTION_MILITARY,CLASS_MILITARY)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetMoveType(MOVETYPE_NONE)
	
	self:SetCollisionBounds(Vector(13, 13, 58), Vector(-13, -13, 0))

	self:slvCapabilitiesAdd(CAP_SKIP_NAV_GROUND_CHECK)

	self:slvSetHealth(GetConVarNumber("sk_sentry_health"))
	
	self.bActive = false
	self.nextPing = 0
	self.nextSearch = CurTime() +0.2
	self.nextEnemyUpdate = 0
	self.nextRetirement = 0
	self:SetDefaultState(NPC_STATE_COMBAT)
end

function ENT:_PossAttackThink(entPossessor, iInAttack)
end

function ENT:_PossPrimaryAttack(entPossessor, fcDone)
	if !self.bActive then fcDone(true); return end
	self.bInSchedule = true
	self:SLVPlayActivity(ACT_RANGE_ATTACK1,false,fcDone,true)
end

function ENT:_PossSecondaryAttack(entPossessor, fcDone)
	if self.bActive then self:TurnOff(fcDone)
	else self:TurnOn(fcDone) end
end

function ENT:_PossStart(entPossessor, fcDone)
	self:TurnOn()
end

function ENT:_PossEnd(entPossessor, fcDone)
	self.nextRetirement = CurTime() +1
end

function ENT:_PossFaceForward(entPossessor, fcDone)
	if fcDone then fcDone(true) end
end

function ENT:_PossMovement(entPossessor, bInSchedule)
end

function ENT:OnAreaCleared()
	self.nextRetirement = CurTime() +16
end

function ENT:OnFoundEnemy(iEnemies)
	self.nextRetirement = CurTime() +16
	self:TurnOn()
end

function ENT:TurnOn(fcDone)
	if self.bActive || self.bDeploying then return end
	self:EmitSound(self.sSoundDir .. "tu_alert.wav", 75, 100)
	self:SLVPlayActivity(ACT_ARM, false, fcDone, true)
	self.bDeploying = true
	self.bRetire = nil
end

function ENT:TurnOff(fcDone)
	if !self.bActive || self.bRetire then return end
	self.bInSchedule = true
	self:SLVPlayActivity(ACT_DISARM, false, fcDone, true)
	self.bInSchedule = false
	self.bRetire = true
	self.bDeploying = nil
end

function ENT:UpdateMemory()
	local mem = self:GetMemory()
	for ent, data in pairs(mem) do
		local bValid = IsValid(ent)
		local iDisposition = bValid && self:Disposition(ent)
		if !bValid || ent:Health() <= 0 || !self:Visible(ent) || self:OBBDistance(ent) > self.fViewDistance || ent:GetNoTarget() || (ent:IsPlayer() && (!ent:Alive() || tobool(GetConVarNumber("ai_ignoreplayers")))) || (iDisposition != 1 && iDisposition != 2) || (self:GetAIType() == 5 && ent:WaterLevel() < 2) || ent.bSelfDestruct then
			self:RemoveFromMemory(ent)
		end
	end
end

function ENT:OnThink()
	if self.bDead || tobool(GetConVarNumber("ai_disabled")) then return end
	if !IsValid(self.entEnemy) && !self.bPossessed then
		if CurTime() >= self.nextSearch then
			self:UpdateEnemies()
			self.nextSearch = CurTime() +0.4
			if !self.bActive && IsValid(self.entEnemy) then self:OnFoundEnemy(1) end
		end
		if !self.bActive then return end
		if !IsValid(self.entEnemy) then
			if CurTime() >= self.nextRetirement then
				self:TurnOff()
				return
			end
			local pp_yaw = self:GetPoseParameter("aim_yaw")
			self:SetPoseParameter("aim_yaw", pp_yaw -1)
			self:NextThink(CurTime() +0.03)
			if CurTime() >= self.nextPing then
				self:slvPlaySound("Ping")
				self.nextPing = CurTime() +1
			end
			return true
		end
	end
	if !self.bActive then return end
	if !self.bPossessed && (!self:Visible(self.entEnemy) || self.entEnemy:GetPos():Distance(self:GetPos()) > self.fViewDistance) then
		self.entEnemy = NULL
		return
	end
	local pp_yaw = self:GetPoseParameter("aim_yaw")
	local pp_pitch = self:GetPoseParameter("aim_pitch")
	
	local posEnemy
	local posEnemyHead
	if !self.bPossessed then posEnemy = self.entEnemy:GetPos(); posEnemyHead = self.entEnemy:GetHeadPos()
	else
		local pos = self:GetPossessor():GetPossessionEyeTrace().HitPos
		posEnemyHead = pos
		posEnemy = pos
	end
	local fDist = self:GetPos():Distance(posEnemy)
	local bPos = self:LocalToWorld(Vector(0.2688, -0.0289, 47.4655)  +Vector(0,0,fDist /self.fViewDistance *30)) //self:GetBonePosition(self:LookupBone("Dummy04"))
	local ang = (bPos -posEnemyHead):Angle()
	local pitch = ang.p
	
	if pitch > 270 then pitch = pitch -360 end
	local pp_pitch_add
	pitch = math.Round(pitch)
	pp_pitch = math.Round(pp_pitch)
	
	if pitch < pp_pitch +3 && pitch > pp_pitch -3 then pp_pitch_add = pitch -pp_pitch
	elseif pitch > pp_pitch +3 then pp_pitch_add = 3
	elseif pitch < pp_pitch -3 then pp_pitch_add = -3
	else pp_pitch_add = 0 end
	
	local yaw = (self:GetAngles().y -pp_yaw) -ang.y +180
	local pp_yaw_add
	yaw = math.Round(yaw)
	pp_yaw = math.Round(pp_yaw)
	
	while yaw < 0 do yaw = yaw +360 end
	while yaw > 360 do yaw = yaw -360 end
	
	local _yaw = yaw +pp_yaw
	while _yaw > 360 do _yaw = _yaw -360 end
	
	local yaw_diff = _yaw -pp_yaw
	if yaw_diff > -3 && yaw_diff < 3 then pp_yaw_add = yaw_diff
	elseif _yaw > pp_yaw -3 && _yaw < pp_yaw +3 then pp_yaw_add = 0
	elseif yaw <= 180 && yaw > 0 then pp_yaw_add = 3
	else pp_yaw_add = -3 end
	self:SetPoseParameter("aim_pitch", pp_pitch +pp_pitch_add)
	self:SetPoseParameter("aim_yaw", pp_yaw +pp_yaw_add)
	
	if CurTime() >= self.nextEnemyUpdate then
		self.nextEnemyUpdate = CurTime() +1
		self:UpdateEnemies()
	end
	
	self:NextThink(CurTime() +0.01)
	return true
end

function ENT:EventHandle(...)
	local event = select(1,...)
	if (event == "rattack") then
		local bEnemyValid = IsValid(self.entEnemy) && self.entEnemy:Health() > 0 && self:Visible(self.entEnemy) && self:GetPos():Distance(self.entEnemy:GetPos()) <= self.fViewDistance
		if (!self.bPossessed && !bEnemyValid) || (self.bPossessed && !self:GetPossessor():KeyDown(IN_ATTACK)) then
			self.bInSchedule = true
			self:SLVPlayActivity(ACT_IDLE_RELAXED, false, nil, true)
			self.bInSchedule = false
			self:SelectSchedule()
			if self.bPossessed then
				self:_PossScheduleDone()
			end
			return true
		end
		local attPosAng = self:GetAttachment(1)
		--attPosAng.Pos = attPosAng.Pos

		self:EmitSound(self.sSoundDir .. "tu_fire1.wav", 100, 100 )
		local effectdata = EffectData()
		effectdata:SetStart(attPosAng.Pos)
		effectdata:SetOrigin(attPosAng.Pos)
		effectdata:SetScale(1)
		effectdata:SetAngles(attPosAng.Ang)
		util.Effect("MuzzleEffect", effectdata)
		
		local tblBullet = {}
		tblBullet.Num = 1
		tblBullet.Src = attPosAng.Pos
		tblBullet.Attacker = self
		tblBullet.Dir = attPosAng.Ang:Forward()
		tblBullet.Spread = Vector(0.022,0.022,0.022)
		tblBullet.Tracer = 1
		tblBullet.Force = 6
		tblBullet.Damage = math.random(8,14)
		self:FireBullets(tblBullet)
		return true
	end
	if (event == "deployed") then
		self.bActive = true
		self.bDeploying = nil
		return true
	end
	if (event == "retired") then
		self.bActive = false
		self.bRetire = nil
		return true
	end
end

function ENT:SelectScheduleHandle(enemy,fDist,fDistPredicted,iDisposition)
	if !self.bActive then return end
	local angSelf = self:GetAngles()
	angSelf.y = angSelf.y -self:GetPoseParameter("aim_yaw")
	angSelf.p = angSelf.p -self:GetPoseParameter("aim_pitch")
	local ang = self:GetAngleToPos(self.entEnemy:GetPos(), angSelf)
	ang:slvClamp()
	local bRange = fDist <= self.fViewDistance && (ang.y <= 45 || ang.y >= 315)
	if bRange then
		self.bInSchedule = true
		self:SLVPlayActivity(ACT_RANGE_ATTACK1, false, nil, true)
		return
	end
end
