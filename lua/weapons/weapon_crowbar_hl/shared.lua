SWEP.HoldType = "melee"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 1
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = true
	SWEP.tblSounds = {}
	SWEP.tblSounds["Hit"] = {"weapons/crowbar/cbar_hit1.wav", "weapons/crowbar/cbar_hit2.wav"}
	SWEP.tblSounds["HitBod"] = {"weapons/crowbar/cbar_hitbod1.wav", "weapons/crowbar/cbar_hitbod2.wav", "weapons/crowbar/cbar_hitbod3.wav"}
	SWEP.tblSounds["Miss"] = "weapons/crowbar/cbar_miss1.wav"
end

SWEP.Base = "weapon_slv_base"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_crowbar.mdl"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.6

SWEP.Secondary.Ammo = "none"

function SWEP:PrimaryAttack()
	local iDelay
	local iDmg = 25
	local iDist = 75
	local iHit, tr = self:DoMeleeDamage(iDist, iDmg)
	local act
	if iHit == 0 then
		act = ACT_VM_MISSCENTER
		if SERVER then self:slvPlaySound("Miss") end
		iDelay = 0.5
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
		iDelay = 0.26
	end
	self.Weapon:SendWeaponAnim(act)
	self.Weapon:SetNextSecondaryFire(CurTime() +iDelay)
	self.Weapon:SetNextPrimaryFire(CurTime() +iDelay)
	self:NextIdle(self.Primary.Delay)
	self:PlayThirdPersonAnim()
end

function SWEP:SecondaryAttack()
end

function SWEP:OnThink()
end	
