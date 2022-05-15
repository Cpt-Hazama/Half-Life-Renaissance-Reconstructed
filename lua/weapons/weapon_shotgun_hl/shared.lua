SWEP.HoldType = "shotgun"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 4
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.8
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/shotgun/sbarrel1.wav"
	SWEP.tblSounds["Secondary"] = "weapons/shotgun/dbarrel1.wav"
	SWEP.tblSounds["ReloadB"] = {"weapons/shotgun/reload1.wav", "weapons/shotgun/reload3.wav"}
	SWEP.tblSounds["Cock"] = "weapons/shotgun/scock1.wav"
	
	function SWEP:OnReloadEnded()
		self:slvPlaySound("Cock", 0.46)
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"
SWEP.SingleReload = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_shotgun.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_shotgun.mdl"

SWEP.Primary.Recoil = -4
SWEP.Primary.NumShots = 8
SWEP.Primary.Cone = 0.08
SWEP.Primary.Delay = 0.8

SWEP.Primary.Damage = "sk_plr_dmg_buckshot"
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.AmmoSize = 125
SWEP.Primary.AmmoPickup	= 12

SWEP.Secondary.Recoil = -8
SWEP.Secondary.Cone	= 0.065
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1.5

SWEP.ReloadDelay = 0.2

function SWEP:OnHolster()
	self.Weapon.nextReload = nil
end

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	
	if self.Owner:WaterLevel() == 3 then return end
	if !self:CanPrimaryAttack() then self:Reload() return end
	self.Weapon.nextReload = nil
	if SERVER then
		self:slvPlaySound("Primary")
		self:slvPlaySound("Cock", 0.46)
		self:AddClip1(-1)
		if self.Owner:IsPlayer() then self.Owner:ViewPunch(Angle(self.Primary.Recoil,0,0)) end
	end
	local iDmg = self.Weapon.Primary.Damage
	if type(iDmg) == "string" then iDmg = GetConVarNumber(iDmg) end
	self.Weapon:ShootBullet(iDmg, self.Weapon.Primary.NumShots, self.Primary.Cone, self.Weapon.Primary.Tracer, self.Weapon.Primary.Force, ShootPos, ShootDir)
	if game.SinglePlayer() || CLIENT then
		self:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

function SWEP:SecondaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Secondary.Delay)
	
	if self.Owner:WaterLevel() == 3 then return end
	if self:Clip1() < 2 then self:PrimaryAttack(ShootPos, ShootDir); return end
	if !self:CanPrimaryAttack() then self:Reload() return end
	self.Weapon.nextReload = nil
	if SERVER then
		self:slvPlaySound("Secondary")
		self:slvPlaySound("Cock", 1)
		self:AddClip1(-2)
		if self.Owner:IsPlayer() then self.Owner:ViewPunch(Angle(self.Secondary.Recoil,0,0)) end
	end
	local iDmg = self.Weapon.Primary.Damage
	if type(iDmg) == "string" then iDmg = GetConVarNumber(iDmg) end
	self.Weapon:ShootBullet(iDmg, self.Weapon.Primary.NumShots *2, self.Primary.Cone, self.Weapon.Primary.Tracer, self.Weapon.Primary.Force, ShootPos, ShootDir, true)
	if game.SinglePlayer() || CLIENT then
		self:SetNetworkedFloat("LastShootTime", CurTime())
	end
end
