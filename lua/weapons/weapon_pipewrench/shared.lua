SWEP.HoldType = "melee2"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 2
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.tblSounds = {}
	SWEP.tblSounds["Hit"] = {"weapons/pipe_wrench/pwrench_hit1.wav", "weapons/pipe_wrench/pwrench_hit2.wav"}
	SWEP.tblSounds["HitBod"] = {"weapons/pipe_wrench/pwrench_hitbod1.wav", "weapons/pipe_wrench/pwrench_hitbod2.wav", "weapons/pipe_wrench/pwrench_hitbod3.wav"}
	SWEP.tblSounds["BigHit"] = {"weapons/pipe_wrench/pwrench_big_hit1.wav", "weapons/pipe_wrench/pwrench_big_hit2.wav"}
	SWEP.tblSounds["BigHitBod"] = {"weapons/pipe_wrench/pwrench_big_hitbod1.wav", "weapons/pipe_wrench/pwrench_big_hitbod2.wav"}
	SWEP.tblSounds["BigMiss"] = "weapons/pipe_wrench/pwrench_big_miss.wav"
	SWEP.tblSounds["Miss"] = {"weapons/pipe_wrench/pwrench_miss1.wav", "weapons/pipe_wrench/pwrench_miss2.wav"}
end

SWEP.Base = "weapon_slv_base"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/opfor/v_pipe_wrench.mdl"
SWEP.WorldModel = "models/weapons/opfor/w_pipe_wrench.mdl"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.6

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1

function SWEP:PrimaryAttack()
	if self.attackStart then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Weapon.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Weapon.Primary.Delay)
	
	local iDmg = 32
	local iDist = 70
	local iHit, tr = self:DoMeleeDamage(iDist, iDmg)
	local act
	if iHit == 0 then
		act = ACT_VM_MISSCENTER
		if SERVER then self:slvPlaySound("Miss") end
	else
		if SERVER then
			if iHit == 1 then
				self:slvPlaySound("HitBod")
			else
				self:CreateDecal(tr)
				self:slvPlaySound("Hit")
			end
		end
		act = ACT_VM_HITCENTER
	end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self.Primary.Delay)
	
	self:PlayThirdPersonAnim()
end

function SWEP:OnInitialize()
	self.Weapon._InternalHoldType = self.HoldType
end

function SWEP:OnHolster()
	self.attackStart = nil
	self.attackStartTime = nil
end

function SWEP:SecondaryAttack()
	if self.attackStart then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Weapon.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Weapon.Secondary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.attackStart = CurTime() +self:SequenceDuration()
	self.attackStartTime = CurTime()
	self:NextIdle(-1)
end

function SWEP:OnThink()
	if self.attackStart && CurTime() >= self.attackStart then
		if self.Owner:KeyDown(IN_ATTACK2) then
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_DEPLOYED)
		else
			self.attackStart = nil
			self:PlayThirdPersonAnim()
			
			local iDmg = math.Clamp(((CurTime() -self.attackStartTime) *0.5) *170, 0, 170)
			local iDist = 70
			local iHit, tr = self:DoMeleeDamage(iDist, iDmg)
			local act
			if iHit == 0 then
				act = ACT_VM_MISSLEFT
				if SERVER then self:slvPlaySound("BigMiss") end
			else
				if SERVER then
					if iHit == 1 then
						self:slvPlaySound("BigHitBod")
					else
						self:CreateDecal(tr)
						self:slvPlaySound("BigHit")
					end
				end
				act = ACT_VM_HITLEFT
			end
			self.Weapon:SendWeaponAnim(act)
			self.Weapon:SetNextSecondaryFire(CurTime() +self.Weapon.Secondary.Delay)
			self.Weapon:SetNextPrimaryFire(CurTime() +self.Weapon.Secondary.Delay)
			self:NextIdle(self.Secondary.Delay)
			if CLIENT then return end
			self.Owner:ViewPunch(Angle(2,0,0))
		end
	end
end	
