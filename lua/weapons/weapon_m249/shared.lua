SWEP.HoldType = "smg"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false 
	SWEP.NPCFireRate = 0.01

	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = {"weapons/m249/saw_fire1.wav", "weapons/m249/saw_fire2.wav", "weapons/m249/saw_fire3.wav"}
	SWEP.tblSounds["ReloadA"] = "weapons/m249/saw_reload.wav"
	SWEP.tblSounds["ReloadC"] = "weapons/m249/saw_reload2.wav"
	SWEP.Primary.Count = 0
	SWEP.Primary.Last = 0
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/opfor/v_saw.mdl"
SWEP.WorldModel = "models/weapons/opfor/w_saw.mdl"

SWEP.Primary.Recoil = 8
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.09
SWEP.Primary.Delay = 0.08

SWEP.Primary.Damage = "sk_plr_dmg_45mm"
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "45mm"
SWEP.Primary.AmmoSize = 200
SWEP.Primary.AmmoPickup	= 200
SWEP.Primary.Force = 10

SWEP.Secondary.Recoil = 2.5
SWEP.Secondary.Cone	= 0.065
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 0.5

SWEP.ReloadDelay = 1.75

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	if self.Owner:WaterLevel() == 3 then return end
	if !self:CanPrimaryAttack() then self:Reload(); return end
	if SERVER then self:slvPlaySound("Primary") end
	local iDmg = self.Weapon.Primary.Damage
	if type(iDmg) == "string" then iDmg = GetConVarNumber(iDmg) end
	self:ShootBullet(iDmg, 1, self.Weapon.Primary.Cone, self.Weapon.Primary.Tracer, self.Weapon.Primary.Force, ShootPos, ShootDir)
	self:SetNetworkedFloat("LastShootTime", CurTime())
	if game.SinglePlayer() || CLIENT then
		self:SetNetworkedFloat("LastShootTime", CurTime())
		if CLIENT then return end
	end
	self:AddClip1(-1)
	if !self.Owner:IsPlayer() then return end
	local ang = self.Owner:GetAimVector()
	ang = ang +Vector(math.Rand(-0.02,0.02), math.Rand(-0.02,0.02), math.Rand(-0.02,0.02))
	self.Owner:SetEyeAngles(ang:Angle())
	
	if CurTime() -self.Primary.Last > 0.12 then
		self.Primary.Count = 0
	end
	self.Primary.Last = CurTime()
	self.Primary.Count = math.Clamp(self.Primary.Count +1, 0, 10)
	local iVel = (self.Primary.Count *0.1) *40
	local vel = self.Owner:GetVelocity()
	local velZ = vel.z
	vel = vel +self.Owner:GetForward() *-iVel
	vel.z = velZ
	self.Owner:SetLocalVelocity(vel)
	local ammo = self:Clip1()
	if ammo < 8 then
		self.Owner:GetViewModel():SetBodygroup(2, 8 -ammo)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	if !self:CanReload() || self.reloadStart then return false end
	self:SendWeaponAnim(ACT_VM_RELOAD)
	local dur = self:SequenceDuration()
	self.reloadStart = CurTime() +dur
	self.Weapon:SetNextPrimaryFire(self.reloadStart +1)
	self:NextIdle(-1)
	self:ReloadTime(self.Weapon.ReloadDelay)
	self:PlayThirdPersonAnim(PLAYER_RELOAD)
	if CLIENT then return true end
	self:slvPlaySound("ReloadA")
	return true
end 

function SWEP:OnDeploy()
	local ammo = self:Clip1()
	if ammo < 8 then
		self.Owner:GetViewModel():SetBodygroup(2, 8 -ammo)
	else
		self.Owner:GetViewModel():SetBodygroup(2, 0)
	end
end

function SWEP:OnHolster()
	self.reloadStart = nil
end

function SWEP:OnThink()
	if self.reloadStart && CurTime() >= self.reloadStart then
		self.reloadStart = nil
		self:SendWeaponAnim(ACT_VM_RELOAD_DEPLOYED)
		local dur = self:SequenceDuration()
		self.Weapon:SetNextPrimaryFire(CurTime() +dur)
		self:NextIdle(dur)
		self:ReloadTime(self.Weapon.ReloadDelay)
		if CLIENT then return end
		self.Owner:GetViewModel():SetBodygroup(2, 0)
		self:slvPlaySound("ReloadC")
	end
end