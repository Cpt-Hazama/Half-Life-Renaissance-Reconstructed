SWEP.HoldType = "pistol"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 2
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.3
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/pl_gun3.wav"
	SWEP.tblSounds["ReloadA"] = "items/9mmclip2.wav"
	SWEP.tblSounds["ReloadB"] = "items/9mmclip1.wav"
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"
SWEP.InWater = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_9mmhandgun.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_9mmhandgun.mdl"

SWEP.Primary.Recoil = -2.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.014
SWEP.Primary.Delay = 0.3

SWEP.Primary.Damage = "sk_plr_dmg_9mm"
SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9mm"
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

function SWEP:DoReload(bInformClient)
	if !self:CanReload() then return false end
	local act
	if self:Clip1() > 0 then act = ACT_VM_RELOAD
	else act = ACT_GLOCK_SHOOT_RELOAD end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
	self:PlayThirdPersonAnim(PLAYER_RELOAD)
	if SERVER then
		self:slvPlaySound("ReloadA")
		if bInformClient then
			umsg.Start("HLR_SWEPDoReload", rp)
			umsg.Entity(self)
			umsg.End()
		end
	end
	if self.Weapon.SingleReload then
		self.Weapon.nextReload = CurTime() +self:SequenceDuration()
		return
	end
	self.Weapon:SetNextSecondaryFire(self.Weapon.nextIdle)
	self.Weapon:SetNextPrimaryFire(self.Weapon.nextIdle)
	
	if self.Owner:IsPlayer() then self:ReloadTime(self.Weapon.ReloadDelay)
	else
		self:SetClip1(self.Primary.DefaultClip)
	end
	if self.Weapon.OnReload then self.Weapon:OnReload() end
	return true
end

function SWEP:ShootEffects(bSecondary)
	self.Owner:MuzzleFlash()
	local act
	if self:Clip1() > 0 then act = ACT_VM_PRIMARYATTACK
	else act = ACT_GLOCK_SHOOTEMPTY end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
	self:PlayThirdPersonAnim()
end