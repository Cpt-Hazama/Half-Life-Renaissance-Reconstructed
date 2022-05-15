SWEP.HoldType = "pistol"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 4
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false
	SWEP.NPCFireRate = 0.24
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = {"weapons/357/357_shot1.wav", "weapons/357/357_shot2.wav"}
	SWEP.tblSounds["ReloadB"] = "weapons/357/357_reload2.wav"
	
	function SWEP:OnReload()
		self:UnScope()
	end
	
	function SWEP:OnHolster()
		self:UnScope()
	end
		
	function SWEP:Scope()
		if self.bScoped then return end
		self.iFOV = self.Owner:GetFOV()
		self.Owner:SetFOV(40,0)
		self.bScoped = true
		self.Owner:DrawViewModel(false)
	end

	function SWEP:UnScope()
		if !self.bScoped then return end
		self.Owner:SetFOV(self.iFOV || 75,0)
		self.bScoped = false
		self.Owner:DrawViewModel(true)
	end
		
	function SWEP:ToggleScope()
		if self.bScoped then
			self:UnScope()
		else
			self:Scope()
		end
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"
SWEP.InWater = false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_357.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_357.mdl"

SWEP.Primary.Recoil = -10
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.8

SWEP.Primary.Damage = "sk_plr_dmg_357"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.AmmoSize = 36
SWEP.Primary.AmmoPickup	= 6

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 0.5

SWEP.ReloadDelay = 2.2

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +0.1)
	if CLIENT then return end
	self:ToggleScope()
end
