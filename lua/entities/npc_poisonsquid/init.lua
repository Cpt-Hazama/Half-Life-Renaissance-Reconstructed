AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.NPCFaction = NPC_FACTION_XENIAN
ENT.sModel = "models/poisonsquid.mdl"
ENT.fMeleeDistance	= 44
ENT.m_fMaxYawSpeed 	= 28
ENT.FlameParticle = "flame_gargantua"

ENT.bIgnitable = false
ENT.bFreezable = false
ENT.CanUseFlame = true
ENT.DamageScales = {
	[DMG_BURN] = 0.1,
	[DMG_DIRECT] = 0.1
}

ENT.iBloodType = BLOOD_COLOR_BLUE
ENT.sSoundDir = "npc/bullsquid/"
ENT.skName = "poisonsquid"
ENT.CollisionBounds = Vector(35,35,46)

function ENT:SubInit()
	self:SetSoundPitch(30)
	self:SetNPCFaction(NPC_FACTION_XENIAN,CLASS_XENIAN)
	self.IsSparying = false
end

function ENT:EventHandle(...)
	local event = select(1,...)
	if(event == "mattack") then
		local atk = select(2,...)
		local dist = self.fMeleeDistance
		local bWhip = atk == "whip"
		local bBite = !bWhip
		if(bWhip) then
			local dmg = GetConVarNumber("sk_" .. self.skName .. "_dmg_whip")
			local angViewPunch = Angle(-7,-36,4)
			self:DealMeleeDamage(dist,dmg,angViewPunch,vector_origin,nil,nil,nil,true)
			return true
		end
		local dmg = GetConVarNumber("sk_" .. self.skName .. "_dmg_bite")
		local angViewPunch = Angle(-14,0,0)
		self:DealMeleeDamage(dist,dmg,angViewPunch,Vector(280,0,0),nil,nil,nil,nil,function(ent)
			ent:SetVelocity((self:GetForward() *100) +Vector(0,0,300))
		end)
		if(!self.bPossessed) then self.iSpitCount = math.random(2,4) end
		return true
	end
	if(event == "rattack") then
		local atk = select(2,...)
		if(string.Left(atk,5) == "flame") then
			local dist
			local bValid = IsValid(self.entEnemy)
			if bValid then dist = self:OBBDistance(self.entEnemy) end
			if(!self.bPossessed && (!bValid || !self:ShouldUseFlame() || dist > self.fRangeDistanceFlame || dist <= self.fMeleeDistance || self.entEnemy:Health() <= 0 || self.bDead || self.entEnemy:GetPos().z -self:GetPos().z > 65)) then
				self:SLVPlayActivity(ACT_SPECIAL_ATTACK2, true)
				self.bInSchedule = false
				self:StopParticles()
				if(self.cspFlame) then self.cspFlame:Stop() end
			elseif(atk == "flamerun") then
				self:FlameAttack()
				local att = self:GetAttachment(1)
				local effect = EffectData()
				effect:SetStart(att.Pos)
				effect:SetNormal(att.Ang:Forward())
				effect:SetEntity(self)
				effect:SetAttachment(1)
				-- effect:SetSize(0.4)
				util.Effect("effect_poisonsquid_poison",effect)
			else
				self:SLVPlayActivity(ACT_RANGE_ATTACK2, !self.bPossessed)
				if(atk == "flamestart") then
					if(self.cspFlame) then self.cspFlame:Play() end
					self.IsSpraying = true
				else self:FlameAttack() end
			end
			return true
		end
		self:AttackSpit()
		return true
	end
end

function ENT:DealPoisonDamage(dist,dmg,attacker)
	local dist = dist || self.fRangeDistance
	local dmg = dmg || GetConVarNumber("sk_" .. self.skName .. "_dmg_flame")
	local posDmg = self:GetPos() +(self:GetForward() *self:OBBMaxs().y)
	for _, ent in pairs(ents.FindInSphere(posDmg,dist)) do
		if(ent:IsValid() && (self:IsEnemy(ent) || ent:IsPhysicsEntity()) && self:Visible(ent)) then
			local posEnt = ent:GetPos()
			local yaw = self:GetAngleToPos(posEnt,self:GetAimAngles()).y
			if((yaw <= 70 && yaw >= 0) || (yaw <= 360 && yaw >= 290)) then
				-- ent:slvIgnite(6,0)
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType(DMG_POISON)
				dmginfo:SetDamage(dmg)
				dmginfo:SetAttacker(attacker || self)
				dmginfo:SetInflictor(self)
				ent:TakeDamageInfo(dmginfo)
			end
		end
	end
end

function ENT:FlameAttack() self:DealPoisonDamage(self.fRangeDistanceFlame) end

function ENT:OnThink()
	if CurTime() >= self.nextBlink then
		self.nextBlink = CurTime() +math.Rand(2,8)
		self:SetSkin(1)
		local iDelay = 0.1
		for i = 1, 0, -1 do
			timer.Simple(iDelay, function()
				if IsValid(self) then
					self:SetSkin(i)
				end
			end)
			iDelay = iDelay +0.1
		end
	end
	if self.IsSparying == true && CurTime() > self.NextSprayT then
		-- local att = self:GetAttachment(1)
		-- local effect = EffectData()
		-- effect:SetStart(att.Pos)
		-- effect:SetNormal(att.Ang:Forward())
		-- effect:SetEntity(self)
		-- effect:SetAttachment(1)
		-- effect:SetSize(0.4)
		-- util.Effect("effect_geneworm_poison",effect)
		self.NextSprayT = CurTime() +0.1
	end
end

function ENT:AttackSpit()
	self:slvPlaySound("AttackRange")
	local pos = self:GetSpitVelocity()
	for i = 0, 5 do
		local entSpit = ents.Create("obj_bullsquid_spit")
		entSpit:NoCollide(self)
		entSpit:SetPos(self:GetPos() +self:GetForward() *20 +self:GetUp() *20)
		entSpit:SetEntityOwner(self)
		entSpit:Spawn()
		entSpit:Activate()
		local phys = entSpit:GetPhysicsObject()
		if(phys:IsValid()) then
			phys:SetVelocity(pos +VectorRand() *60)
		end
	end
	if(!self.bPossessed) then
		self.iSpitCount = self.iSpitCount -1
		if self.iSpitCount <= 0 then
			self.nextSpit = CurTime() +math.Rand(4,12)
		end
	end
end