SWEP.HoldType = "grenade"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 4
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.tblSounds = {}
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_grenade.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_grenade.mdl"

SWEP.Primary.Automatic = false
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "hgrenade"
SWEP.Primary.Delay = 0.8
SWEP.Primary.AmmoSize = 10
SWEP.Primary.AmmoPickup	= 10
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1

function SWEP:CustomIdle()
	local act
	if self:GetAmmoPrimary() == 0 then act = ACT_VM_IDLE_EMPTY
	elseif self.bThrown then act = ACT_VM_DRAW; self.bThrown = nil
	else act = ACT_VM_IDLE end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:Deploy()
	if self:GetAmmoPrimary() == 0 then self.Weapon:SendWeaponAnim(ACT_VM_IDLE_EMPTY); self:NextIdle(0); return true end
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:NextIdle(self:SequenceDuration())
	self.Weapon:SetNextSecondaryFire(self.Weapon.nextIdle)
	self.Weapon:SetNextPrimaryFire(self.Weapon.nextIdle)
	if self.Weapon.OnDeploy then self.Weapon:OnDeploy() end
	return true
end

function SWEP:PrimaryAttack()
	if self:GetAmmoPrimary() <= 0 then return end
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:NextIdle(-1)
	self.bInAttack = true
	self.attackStart = CurTime() +0.6
end

function SWEP:SecondaryAttack()
end

function SWEP:OnHolster()
	self.bThrown = nil
	self.bInAttack = nil
	self.attackStart = nil
end

function SWEP:OnThink()
	if !self.bInAttack || self.Owner:KeyDown(IN_ATTACK) || CurTime() < self.attackStart then return end
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	local rand = math.random(1,3)
	local act = (rand == 1 && ACT_HANDGRENADE_THROW1) || (rand == 2 && ACT_HANDGRENADE_THROW2) || ACT_HANDGRENADE_THROW3
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())--self.Primary.Delay)
	self.bThrown = true
	self.bInAttack = false
	
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	local ang = self.Owner:GetAimVector():Angle()
	local entGrenade = ents.Create("obj_handgrenade")
	entGrenade:SetPos(self.Owner:GetShootPos() +ang:Forward() *30 +ang:Right() *10 +ang:Up() *-2)
	entGrenade:SetEntityOwner(self.Owner)
	entGrenade:SetExplodeDelay(3 -(CurTime() -(self.attackStart -0.6)))
	entGrenade:Spawn()
	entGrenade:Activate()
	
	local phys = entGrenade:GetPhysicsObject()
	if IsValid(phys) then
		local vel = ang:Forward() *1000 +ang:Up() *100
		phys:ApplyForceCenter(vel)
	end
	self.Weapon:AddAmmoPrimary(-1)
end	
