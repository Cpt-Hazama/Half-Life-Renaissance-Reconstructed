SWEP.HoldType = "pistol"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 2
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.8
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/deagle/desert_eagle_fire.wav"
	SWEP.tblSounds["ReloadA"] = "weapons/deagle/desert_eagle_reload.wav"
	SWEP.tblSounds["SightOn"] = "weapons/deagle/desert_eagle_sight.wav"
	SWEP.tblSounds["SightOff"] = "weapons/deagle/desert_eagle_sight2.wav"
	
	function SWEP:OnPrimaryAttack()
		if !self:GetNetworkedBool("laser") && !self.nextLaserEnable then return end
		self.nextLaserEnable = CurTime() +self.Weapon.Primary.Delay
		self:SetNetworkedBool("laser", false)
	end

	function SWEP:OnHolster()
		self.nextLaserEnable = nil
	end

	function SWEP:OnThink()
		if !self.nextLaserEnable then return end
		if CurTime() >= self.nextLaserEnable then
			self.nextLaserEnable = nil
			self:SetNetworkedBool("laser", true)
		end
	end

	function SWEP:OnReload()
		if !self:GetNetworkedBool("laser") && !self.nextLaserEnable then return end
		self.nextLaserEnable = CurTime() +self:SequenceDuration()
		self:SetNetworkedBool("laser", false)
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

SWEP.ViewModel = "models/weapons/opfor/v_desert_eagle.mdl"
SWEP.WorldModel = "models/weapons/opfor/w_desert_eagle.mdl"

SWEP.Primary.Recoil = -6
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.065
SWEP.Primary.Delay = 0.24

SWEP.Primary.Damage = "sk_plr_dmg_357"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.AmmoSize = 36

SWEP.Secondary.Recoil = 2.5
SWEP.Secondary.Cone	= 0.065
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 0.5

SWEP.ReloadDelay = 1.2

function SWEP:OnDeploy()
	if CLIENT then return end
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	
	umsg.Start("HLR_deagle_laserdot_draw", rp)
		umsg.Long(self:EntIndex())
	umsg.End()
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +0.1)
	
	local bLaser = self:GetNetworkedBool("laser")
	if !bLaser then
		bLaser = true
		if SERVER then self.Weapon:slvPlaySound("SightOn") end
		self.Weapon.Primary.Cone = 0.01
		self.Weapon.Primary.Delay = 0.5
	else
		bLaser = false
		if SERVER then self.Weapon:slvPlaySound("SightOff") end
		self.Weapon.Primary.Cone = 0.065
		self.Weapon.Primary.Delay = 0.24
	end
	self:SetNetworkedBool("laser", bLaser)
	if CLIENT then return end
	self.nextLaserEnable = nil
end
