SWEP.HoldType = "crossbow"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 2
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/displacer/displacer_spin.wav"
	SWEP.tblSounds["Secondary"] = "weapons/displacer/displacer_spin2.wav"
	SWEP.tblSounds["TeleportPlayer"] = "weapons/displacer/displacer_teleport_player.wav"
	SWEP.tblSounds["Error"] = "weapons/displacer/displacer_error.wav"
	
	function SWEP:NPCShoot_Primary(ShootPos, ShootDir)
		self:slvPlaySound("weapons/displacer/displacer_fire.wav")
		local entPortal = ents.Create("obj_portal")
		entPortal:SetPos(ShootPos)
		entPortal:SetEntityOwner(self.Owner)
		entPortal:SetTeleport(true)
		entPortal:Spawn()
		entPortal:Activate()
		local phys = entPortal:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter(ShootDir *1000)
		end
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/opfor/v_displacer.mdl"
SWEP.WorldModel = "models/weapons/opfor/w_displacer.mdl"

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "uranium"
SWEP.Primary.AmmoSize = 100
SWEP.Primary.AmmoPickup	= 100
SWEP.Primary.Delay = 1

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 1

function SWEP:OnThink()
	if self.attackStart && CurTime() >= self.attackStart then
		self.attackStart = nil
		local ammo = self:GetAmmoPrimary()
		if (!self.Weapon.bTeleportSelf && ammo < 20) || (self.Weapon.bTeleportSelf && ammo < 60) then
			if SERVER then self:slvPlaySound("Error",nil,true) end
			return
		end
		self:PlayThirdPersonAnim()
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		if CLIENT then return end
		self.Owner:ViewPunch(Angle(-6,0,0))
		self:slvPlaySound("weapons/displacer/displacer_fire.wav")
		self:slvPlaySound("TeleportPlayer")
		if self.bTeleportSelf then
			local pos, normal = util.GetRandomWorldPos()
			if !pos then
				self:slvPlaySound("Error",nil,true)
				return
			end
			local entPortal = ents.Create("obj_portal")
			entPortal:SetPos(self.Owner:GetPos())
			entPortal:SetEntityOwner(self.Owner)
			entPortal:Spawn()
			entPortal:Activate()
			self.Weapon:AddAmmoPrimary(-60)
			self.Owner:SetPos(pos)
			self:slvPlaySound("weapons/displacer/displacer_self.wav")
			entPortal:HitObject()
		else
			self.Weapon:AddAmmoPrimary(-20)
			local ang = self.Owner:GetAimVector():Angle()
			local entPortal = ents.Create("obj_portal")
			entPortal:SetPos(self.Owner:GetShootPos())
			entPortal:SetEntityOwner(self.Owner)
			entPortal:SetTeleport(true)
			entPortal:Spawn()
			entPortal:Activate()
			local phys = entPortal:GetPhysicsObject()
			if IsValid(phys) then
				phys:ApplyForceCenter(self.Owner:GetForward() *1000)
			end
		end
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay +1)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay +1)
	if self:GetAmmoPrimary() <= 0 then if SERVER then self:slvPlaySound("Error", nil, true) end; return end
	self.attackStart = CurTime() +self.Primary.Delay
	self.bTeleportSelf = false
	self:NextIdle(self.Primary.Delay)
	if SERVER then
		self:slvPlaySound("Primary")
	end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_2)
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay +1)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Secondary.Delay +1)
	if self:GetAmmoPrimary() <= 0 then if SERVER then self:slvPlaySound("Error", nil, true) end; return end
	self.attackStart = CurTime() +self.Secondary.Delay
	self.bTeleportSelf = true
	self:NextIdle(self.Secondary.Delay)
	if SERVER then
		self:slvPlaySound("Secondary")
	end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_2)
end

function SWEP:OnHolster()
	self.attackStart = nil
	self.bTeleportSelf = nil
end

