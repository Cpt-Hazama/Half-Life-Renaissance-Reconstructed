SWEP.HoldType = "smg"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 2
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.3
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/bgrapple/bgrapple_fire.wav"
	SWEP.tblSounds["Release"] = "weapons/bgrapple/bgrapple_release.wav"
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"
SWEP.InWater = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/opfor/v_bgrap.mdl"
SWEP.WorldModel = "models/weapons/opfor/p_bgrap.mdl"

SWEP.Primary.Recoil = -2.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.014
SWEP.Primary.Delay = 1

SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.AmmoSize = 250
SWEP.Primary.AmmoPickup	= 18

SWEP.Secondary.Recoil = -2.5
SWEP.Secondary.Cone	= 0.08
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 0.2

SWEP.ReloadDelay = 1

function SWEP:OnIdle()
	if !CLIENT && !game.SinglePlayer() || self:GetSequence() !=  self:LookupSequence("cough") then return end
	self.cspCough = CreateSound(self.Owner, "weapons/bgrapple/bgrapple_cough.wav")
	self.cspCough:Play()
end

function SWEP:CustomIdle()
	local act
	if self.bInAttack then
		if !self.bHit then act = ACT_VM_PRIMARYATTACK_DEPLOYED
		else act = ACT_VM_PRIMARYATTACK_DEPLOYED_1 end
	else act = ACT_VM_IDLE end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:StopAttack()
	self.bInAttack = false
	self.attackStart = nil
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_DEPLOYED_2)
	self:NextIdle(self:SequenceDuration())
	if CLIENT then return end
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	umsg.Start("HLR_barnaclegun_tonguestop", rp)
		umsg.Long(self:EntIndex())
	umsg.End()
	if self.cspWait then self.cspWait:Stop() end
	if self.cspPull then self.cspPull:Stop() end
	self:slvPlaySound("Release")
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
end

function SWEP:OnThink()
	if self.bInAttack then
		if !self.Owner:KeyDown(IN_ATTACK) || (self.entDest && (!self.entDest:IsValid() || (self.entDest:IsPlayer() || self.entDest:IsNPC()) && self.entDest:Health() <= 0)) then
			self:StopAttack()
			return
		end
		local posDest
		if IsValid(self.entDest) then
			posDest = self.entDest:LocalToWorld(self.posDestLocal)
			if !CLIENT && self.Owner:OBBDistance(self.entDest) <= 60 then
				if !self.nextDmg then self.nextDmg = CurTime() +0.5
				elseif CurTime() >= self.nextDmg then
					self.nextDmg = CurTime() +0.5
					self.entDest:TakeDamage(60, self, self.Owner)
				end
			end
		else posDest = self.posDest end
		if self.bHit then
			if CLIENT then return end
			self.Owner:SetLocalVelocity((posDest -self.Owner:GetCenter()):GetNormal() *500)
		else
			local len = (CurTime() -self.attackStart) *1000
			local ang = self.Owner:GetAimVector():Angle()
			local posStart = self.Owner:GetShootPos() +ang:Forward() *-8 +ang:Right() *3 +ang:Up() *-5
			local normal = (posDest -posStart):GetNormal()
			posEnd = posStart +normal *len
			local tr = util.TraceLine({start = posEnd, endpos = posEnd +normal *12, filter = {self, self.Owner}})
			if tr.Hit then
				local normal = (self.posDest -self:GetAttachment(self:LookupAttachment("0")).Pos):GetNormal()
				local posStart = tr.HitPos -tr.Normal *12
				local posEnd = posStart +tr.Normal *16
				local trB = util.TraceLine({start = posStart, endpos = posEnd, filter = {self, self.Owner}})
				if IsValid(trB.Entity) && (trB.Entity:IsPlayer() || trB.Entity:IsNPC() || trB.MatType == MAT_ALIENFLESH) then
					if (trB.Entity:IsPlayer() || trB.Entity:IsNPC()) && trB.Entity:Health() <= 0 then
						self:StopAttack()
						return
					end
					self.entDest = trB.Entity
					self.posDestLocal = trB.Entity:WorldToLocal(trB.HitPos)
					if SERVER then
						local rp = RecipientFilter()
						rp:AddAllPlayers()
						umsg.Start("HLR_barnaclegun_tongue_setent", rp)
							umsg.Entity(self)
							umsg.Entity(self.entDest)
							umsg.Vector(self.posDestLocal)
						umsg.End()
					end
				elseif trB.MatType == MAT_ALIENFLESH then self.posDest = trB.HitPos
				else
					self:StopAttack()
					return
				end
				self.bHit = true
				self:NextIdle(0)
				if CLIENT then return end
				sound.Play("weapons/bgrapple/bgrapple_impact.wav", tr.HitPos, 75, 100)
				self.cspPull = CreateSound(self.Owner, "weapons/bgrapple/bgrapple_pull.wav")
				self.cspPull:Play()
				self.cspWait:Stop()
			end
		end
	elseif self.attackStart && CurTime() >= self.attackStart then
		if !self.Owner:KeyDown(IN_ATTACK) then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_DEPLOYED_2)
			self:NextIdle(self:SequenceDuration())
			self.attackStart = nil
			return
		end
		self.attackStart = CurTime()
		self.bInAttack = true
		self:NextIdle(0)
		local tr = util.TraceLine(util.GetPlayerTrace(self.Owner))
		self.posDest = tr.HitPos
		if CLIENT then return end
		self.cspWait = CreateSound(self.Owner, "weapons/bgrapple/bgrapple_wait.wav")
		self.cspWait:Play()
		local rp = RecipientFilter()
		rp:AddAllPlayers()
		umsg.Start("HLR_barnaclegun_tonguestart", rp)
			umsg.Entity(self)
			umsg.Vector(tr.HitPos)
			if IsValid(self.entDest) then umsg.Entity(self.entDest); umsg.Vector(self.posDestLocal) end
		umsg.End()
	end
end

function SWEP:OnHolster()
	if self.cspCough then self.cspCough:Stop() end
	self.attackStart = nil
	if self.bInAttack then
		self.bInAttack = false
		if CLIENT then return end
		local rp = RecipientFilter()
		rp:AddAllPlayers()
		umsg.Start("HLR_barnaclegun_tonguestop", rp)
			umsg.Long(self:EntIndex())
		umsg.End()
		if self.cspWait then self.cspWait:Stop() end
		if self.cspPull then self.cspPull:Stop() end
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	if self.bInAttack then return end
	if self.cspCough then self.cspCough:Stop() end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.attackStart = CurTime() +self:SequenceDuration()
	if self.Owner:IsPlayer() then
		self:NextIdle(self:SequenceDuration() +0.1)
	end
	self.nextDmg = nil
	self.posDestLocal = nil
	self.entDest = nil
	self.bHit = false
	if CLIENT then return end
	self:slvPlaySound("Primary")
end

function SWEP:SecondaryAttack()
end