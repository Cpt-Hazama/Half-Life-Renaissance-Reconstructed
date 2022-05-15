SWEP.HoldType = "ar2"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 3
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 1.8

	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/m40a1/sniper_fire.wav"
	SWEP.tblSounds["ReloadA"] = "weapons/m40a1/sniper_reload_first_seq.wav"
	SWEP.tblSounds["ReloadC"] = "weapons/m40a1/sniper_reload3.wav"
	SWEP.tblSounds["ReloadD"] = "weapons/m40a1/sniper_reload_second_seq.wav"
	SWEP.tblSounds["Scope"] = "weapons/m40a1/sniper_zoom.wav"
	
	function SWEP:PrimaryAttack(ShootPos, ShootDir)
		self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
		self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
		
		if (!self.Weapon.InWater && self.Owner:WaterLevel() == 3) then return end
		local iClip = self:Clip1()
		self.Weapon:Attack(self.Primary.Cone, ShootPos, ShootDir)
		if iClip == 0 then self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay); return end
		self:slvPlaySound("ReloadC", 0.9, true)
		self:slvPlaySound("ReloadD", 1.217, true)
		if !self.Owner:IsPlayer() then return end
		self.Owner:ViewPunch(Angle(-2,0,0))
	end
	
	function SWEP:Scope(bNoSound)
		if self.Weapon:GetNetworkedBool("scoped") then return end
		if !bNoSound then self:slvPlaySound("Scope", nil, true) end
		self.m_iFOV = self.Owner:GetFOV()
		self.Owner:SetFOV(20,0)
		self.Weapon:SetNetworkedBool("scoped", true)
		self.Owner:DrawViewModel(false)
	end

	function SWEP:UnScope(bNoSound)
		if !self.Weapon:GetNetworkedBool("scoped") then return end
		if !bNoSound then self:slvPlaySound("Scope", nil, true) end
		self.Owner:SetFOV(self.m_iFOV,0)
		self.Weapon:SetNetworkedBool("scoped", false)
		self.Owner:DrawViewModel(true)
	end
	
	function SWEP:ToggleScope()
		if self.Weapon:GetNetworkedBool("scoped") then
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

SWEP.ViewModel = "models/weapons/opfor/v_m40a1.mdl"
SWEP.WorldModel = "models/weapons/opfor/w_m40a1.mdl"

SWEP.Primary.Recoil = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 1.76

SWEP.Primary.Damage = "sk_plr_dmg_308"
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "308"
SWEP.Primary.AmmoSize = 10
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 20

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 0.5

SWEP.ReloadDelay = 1.41

function SWEP:OnReload()
	local dur = self:SequenceDuration()
	self:NextIdle(dur +1.7777)
	if SERVER then
		self:UnScope(true)
		self:slvPlaySound("ReloadD", dur +0.7, true)
	end
	local flReloadEnd = CurTime() +dur
	self.delayReloadDeployed = flReloadEnd
	flReloadEnd = flReloadEnd +1.7777
	self.Weapon:SetNextSecondaryFire(flReloadEnd)
	self.Weapon:SetNextPrimaryFire(flReloadEnd)
end

function SWEP:OnThink()
	if self.delayReloadDeployed && CurTime() >= self.delayReloadDeployed then
		self.delayReloadDeployed = nil
		self:SendWeaponAnim(ACT_VM_RELOAD_DEPLOYED)
	end
end

function SWEP:OnHolster()
	self.delayReloadDeployed = nil
	self.Weapon:SetNetworkedBool("scoped", false)
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +0.1)
	if CLIENT then return end
	self:ToggleScope()
end
