SWEP.HoldType = "rpg"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 6
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 2
	SWEP.tblSounds = {}
	
	function SWEP:OnPrimaryAttack()
		if !self:GetNetworkedBool("laser") && !self.nextLaserEnable then return end
		self.nextLaserEnable = CurTime() +self.Weapon.Primary.Delay
		self:SetNetworkedBool("laser", false)
	end

	function SWEP:OnHolster()
		self.nextLaserEnable = nil
		local entRpg = self.entRpg
		if IsValid(entRpg) then
			entRpg:SetGuided(false)
			self:SetDeployed(false, true, true)
		end
	end

	function SWEP:OnReload()
		if !self:GetNetworkedBool("laser") && !self.nextLaserEnable then return end
		self.nextLaserEnable = CurTime() +self:SequenceDuration()
		self:SetNetworkedBool("laser", false)
	end
	
	function SWEP:OnRPGExploded(entRpg)
		if IsValid(entRpg) && IsValid(self.entRpg) && entRpg == self.entRpg then
			self:SetDeployed(false, true)
			if !self.bReloadOnNextIdle then self:Reload() end
		end
	end
	
	function SWEP:OnDeploy()
		local rp = RecipientFilter()
		rp:AddAllPlayers()
		
		umsg.Start("HLR_rpg_laserdot_draw", rp)
			umsg.Long(self:EntIndex())
		umsg.End()
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"
SWEP.InWater = true
SWEP.EmptySound = false
SWEP.AutoReload = false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_rpg.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_rpg.mdl"

SWEP.Primary.Recoil = 15
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.065
SWEP.Primary.Delay = 0.24

SWEP.Primary.Damage = "sk_plr_dmg_357"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "RPG_Round"
SWEP.Primary.AmmoSize = 5

SWEP.Secondary.Recoil = 2.5
SWEP.Secondary.Cone	= 0.065
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 0.5

SWEP.ReloadDelay = 1.2

SWEP.bDeployed = false

if CLIENT then
	usermessage.Hook("hlr_rpg_deployed", function(um)
		local self = um:ReadEntity()
		if !IsValid(self) then return end
		self.Weapon.bDeployed = um:ReadBool()
		if !self.Weapon.bDeployed then
			self.nextRPGReload = CurTime() +3
		end
	end)

	usermessage.Hook("hlr_rpg_deploy", function(um)
		local self = um:ReadEntity()
		if !IsValid(self) || !self.Deploy then return end
		self:Deploy()
	end)

	usermessage.Hook("hlr_rpg_onprimary", function(um)
		local self = um:ReadEntity()
		if !IsValid(self) then return end
		self.nextRPGReload = CurTime() +3
	end)
end

function SWEP:OnThink()
	if self:Clip1() == 0 && self:GetAmmoPrimary() > 0 && !self:GetDeployed() && (!self.nextRPGReload || CurTime() >= self.nextRPGReload) then
		self:Reload()
		self.nextRPGReload = CurTime() +self:SequenceDuration() +1
	end
	
	if CLIENT then return end
	if self.nextLaserEnable && CurTime() >= self.nextLaserEnable then
		self.nextLaserEnable = nil
		self:SetNetworkedBool("laser", true)
	end
end

function SWEP:Deploy()
	local act
	if self:Clip1() > 0 then act = ACT_VM_DRAW
	else act = ACT_RPG_DRAW_UNLOADED end
	self.nextRPGReload = nil
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
	self.Weapon:SetNextSecondaryFire(self.Weapon.nextIdle)
	self.Weapon:SetNextPrimaryFire(self.Weapon.nextIdle)
	if self.Weapon.OnDeploy then self.Weapon:OnDeploy() end
	if self:Clip1() == 0 && self:GetAmmoPrimary() > 0 then self.nextRPGReload = CurTime() +self:SequenceDuration() end
	if CLIENT then return end
	umsg.Start("hlr_rpg_deploy", self.Owner)
		umsg.Entity(self)
	umsg.End()
	return true
end

function SWEP:CustomIdle()
	local act
	if self:Clip1() > 0 then act = ACT_IDLE
	else act = ACT_RPG_IDLE_UNLOADED end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	if self:GetDeployed() || !self:CanPrimaryAttack() then return end
	local bGuided = self:GetNetworkedBool("laser")
	if SERVER then
		self:slvPlaySound("weapons/rpg/rocketfire2.wav")
		self:AddClip1(-1)
		if self.Owner:IsPlayer() then self.Owner:ViewPunch(Angle(-4,0,0)) end
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle()
		pos = pos +ang:Forward() *20 +ang:Right() *5 +ang:Up() *-3
		local entRpg = ents.Create("obj_rpg")
		entRpg:SetAngles(ang)
		entRpg:SetPos(pos)
		entRpg:SetEntityOwner(self.Owner)
		entRpg:SetGuided(bGuided)
		entRpg:Spawn()
		entRpg:Activate()
		local phys = entRpg:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Up() *40 +ang:Forward() *400)
		end
		self.entRpg = entRpg
		
		if self.Owner:IsPlayer() then
			umsg.Start("hlr_rpg_onprimary", self.Owner)
				umsg.Entity(self)
			umsg.End()
		end
	end
	self.nextRPGReload = CurTime() +3
	if bGuided then self:SetDeployed(true, true) end
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self:PlayThirdPersonAnim()
	if game.SinglePlayer() || CLIENT then
		self:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

function SWEP:SetDeployed(bDeployed, bInformClient, bDontReload)
	self.bDeployed = bDeployed
	if CLIENT || !bInformClient || !self.Owner:IsPlayer() then return end
	umsg.Start("hlr_rpg_deployed", self.Owner)
		umsg.Entity(self)
		umsg.Bool(bDeployed)
	umsg.End()
end

function SWEP:CanReload()
	if !self.Primary.SingleClip && self:GetAmmoPrimary() > 0 && self:Clip1() < self.Primary.DefaultClip && !self:GetDeployed() && !self.Weapon.delayReloaded && !self.Weapon.nextReload then return true end
	return false
end

function SWEP:GetDeployed()
	return self.Weapon.bDeployed
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +0.1)
	
	local bLaser = self:GetNetworkedBool("laser")
	if !bLaser then
		bLaser = true
		self.Weapon.Primary.Cone = 0.01
		self.Weapon.Primary.Delay = 0.5
		if IsValid(self.entRpg) && self:Clip1() == 0 then
			self.entRpg:SetGuided(true)
			self:SetDeployed(true, true)
			self.nextRPGReload = nil
		end
	else
		bLaser = false
		self.Weapon.Primary.Cone = 0.065
		self.Weapon.Primary.Delay = 0.24
		if IsValid(self.entRpg) then
			self.entRpg:SetGuided(false)
			self:SetDeployed(false, true)
			self.nextRPGReload = CurTime() +3
		end
	end
	self:SetNetworkedBool("laser", bLaser)
	if CLIENT then return end
	self.nextLaserEnable = nil
end
