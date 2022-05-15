SWEP.HoldType = "shotgun"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 2
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.24
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = {"weapons/freezinggun/hks1.wav", "weapons/freezinggun/hks2.wav", "weapons/freezinggun/hks3.wav"}
	SWEP.tblSounds["Secondary"] = {"weapons/freezinggun/glauncher.wav", "weapons/freezinggun/glauncher2.wav"}
	SWEP.tblSounds["ReloadA"] = "weapons/freezinggun/reload.wav"
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase"
SWEP.InWater = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_freezinggun.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_freezinggun.mdl"

SWEP.Primary.Recoil = -2.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.014
SWEP.Primary.Delay = 0.3

SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "freeze_plts"
SWEP.Primary.AmmoSize = 250
SWEP.Primary.AmmoPickup	= 18

SWEP.Secondary.Recoil = -2.5
SWEP.Secondary.Cone	= 0.08
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 1

SWEP.ReloadDelay = 1

function SWEP:DoReload(bInformClient)
	if !self:CanReload() then return false end
	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
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
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self:PlayThirdPersonAnim()
end

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	
	if (!self.Weapon.InWater && self.Owner:WaterLevel() == 3) then return end
	if !self:CanPrimaryAttack() then if self.Weapon.AutoReload then self:Reload() end; return end
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self:PlayThirdPersonAnim()
	if game.SinglePlayer() || CLIENT then
		self:SetNetworkedFloat("LastShootTime", CurTime())
		if CLIENT then return end
	end
	if CLIENT then return end
	self:slvPlaySound("Primary")
	self:AddClip1(-1)
	if self.Owner:IsPlayer() then self.Owner:ViewPunch(Angle(self.Primary.Recoil,0,0)) end
	local tr = util.TraceLine(util.GetPlayerTrace(self.Owner))
	if IsValid(tr.Entity) && (tr.Entity:IsNPC() || tr.Entity:IsPlayer()) then
		tr.Entity:SetFrozen(5)
	end
	if self.Weapon.OnPrimaryAttack then self.Weapon:OnPrimaryAttack() end
end

function SWEP:SecondaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Secondary.Delay)
	
	if (!self.Weapon.InWater && self.Owner:WaterLevel() == 3) then return end
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	self:slvPlaySound("Secondary")
	local ang = self.Owner:GetAimVector():Angle()
	for i = 0, 1 do
		local icesphere = ents.Create("obj_icesphere")
		local pos
		if i == 0 then pos = self.Owner:GetShootPos() +ang:Forward() *30 +ang:Right() *10 +ang:Up() *-4; icesphere:SetSize(3)
		else pos = self.Owner:GetShootPos() +ang:Forward() *30 +ang:Right() *10 +ang:Up() *-14; icesphere:SetSize(2) end
		icesphere:SetPos(pos)
		icesphere:SetEntityOwner(self.Owner)
		icesphere:Spawn()
		local phys = icesphere:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter(ang:Forward() *1000 +ang:Up() *100)
		end
	end
	if self.Weapon.OnSecondaryAttack then self.Weapon:OnSecondaryAttack() end
end