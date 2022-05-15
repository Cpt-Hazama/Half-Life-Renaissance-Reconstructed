SWEP.HoldType = "slam"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 3
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = true
	SWEP.tblSounds = {}
	
	local function CreateWorldModel(self)
		local entModel = ents.Create("prop_dynamic_override")
		entModel:SetModel("models/weapons/half-life/w_tripmine.mdl")
		entModel:SetPos(self:GetPos())
		entModel:SetAngles(self:GetAngles())
		entModel:SetParent(self)
		entModel:Spawn()
		entModel:Activate()
		self.entModel = entModel
	end
	
	function SWEP:PostInit()
		if IsValid(self.Owner) then return end
		CreateWorldModel(self)
		self:SetColor(255,255,255,0)
		self:DrawShadow(false)
	end
	
	function SWEP:OnRemove()
		if IsValid(self.entModel) then
			self.entModel:Remove()
		end
	end
	
	function SWEP:OnEquip()
		if IsValid(self.entModel) then
			self.entModel:Remove()
			self:SetColor(255,255,255,255)
			self:DrawShadow(true)
		end
	end
	
	function SWEP:OnDrop()
		self:Drop()
		CreateWorldModel(self)
	end
end

SWEP.Base = "weapon_slv_base"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_tripmine.mdl"
SWEP.WorldModel = "models/weapons/half-life/p_tripmine.mdl"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Primary.Automatic = false
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "tripmine"
SWEP.Primary.Delay = 1.8
SWEP.Primary.AmmoSize = 10
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.AmmoPickup = 10

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1

function SWEP:CustomIdle()
	local act
	if self:GetAmmoPrimary() == 0 then act = ACT_VM_IDLE_EMPTY
	elseif self.bThrown then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self:NextIdle(self:SequenceDuration())
		self.Weapon:SetNextSecondaryFire(self.Weapon.nextIdle)
		self.Weapon:SetNextPrimaryFire(self.Weapon.nextIdle)
		self.bThrown = nil
		return
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
	local tr = util.TraceLine(util.GetPlayerTrace(self.Owner))
	if !tr.HitWorld || self.Owner:GetShootPos():Distance(tr.HitPos) > 80 then return end
	self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.bThrown = true
	self:NextIdle(self.Primary.Delay)
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	self.Weapon:AddAmmoPrimary(-1)
	local entTripmine = ents.Create("obj_tripmine")
	entTripmine:SetPos(tr.HitPos +tr.HitNormal *8)
	entTripmine:SetAngles(tr.HitNormal:Angle())
	entTripmine:SetEntityOwner(self.Owner)
	entTripmine:Spawn()
	entTripmine:Activate()
	entTripmine:EmitSound("weapons/tripmine/mine_deploy.wav", 75, 100)
end

function SWEP:OnHolster()
	self.bThrown = nil
end

function SWEP:SecondaryAttack()
end