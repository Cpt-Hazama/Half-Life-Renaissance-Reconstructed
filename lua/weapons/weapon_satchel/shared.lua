SWEP.HoldType = "slam"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 3
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.24
	SWEP.tblSounds = {}
	
	function SWEP:ThrowSatchel()
		if self:GetAmmoPrimary() <= 0 then return end
		self:AddAmmoPrimary(-1)
		self:PlayThirdPersonAnim()
		
		local ang = self.Owner:GetAimVector():Angle()
		local entSatchel = ents.Create("obj_satchel")
		entSatchel:SetPos(self.Owner:GetShootPos() +ang:Forward() *10 +ang:Up() *-22)
		entSatchel:SetEntityOwner(self.Owner)
		entSatchel:Spawn()
		entSatchel:Activate()
		entSatchel:SetAngles(Angle(90,0,0))
		local phys = entSatchel:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter(ang:Forward() *200 +ang:Up() *10)
			phys:AddAngleVelocity(Vector(360,0,0))
		end
		table.insert(self.tblEntsSatchels,entSatchel)
		
		self:SelectRadio()
	end
	
	function SWEP:SelectRadio()
		if(self.Owner:IsPlayer()) then self.Owner:GetViewModel():SetModel("models/weapons/half-life/v_satchel_radio.mdl") end
		self:SetWeaponHoldType("fist")
		if IsValid(self.mdlRadio) then self.mdlRadio:Remove(); self.mdlRadio = nil end
		local mdlRadio = ents.Create("obj_satchel_radio_world")
		mdlRadio:SetParent(self.Owner)
		mdlRadio:SetEntityOwner(self.Owner)
		mdlRadio:Spawn()
		mdlRadio:Activate()
		mdlRadio:Fire("SetParentAttachment", "anim_attachment_RH", 0)
		self.mdlRadio = mdlRadio
		self:SetColor(255,255,255,0)
		self:DeleteOnRemove(mdlRadio)
		
		self.Weapon.bRadioSelected = true
		self.Weapon:SendWeaponAnim(ACT_VM_FIDGET)
		self:NextIdle(0.6)
	end

	function SWEP:SelectSatchel()
		if(self.Owner:IsPlayer()) then self.Owner:GetViewModel():SetModel(self.ViewModel) end
		self:SetWeaponHoldType("slam")
		if IsValid(self.mdlRadio) then self.mdlRadio:Remove(); self.mdlRadio = nil end
		self:SetColor(255,255,255,255)
		
		self.Weapon.bRadioSelected = false
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self:NextIdle(self:SequenceDuration())
	end
	
	function SWEP:DetonateSatchels()
		for k, v in pairs(self.tblEntsSatchels) do
			if IsValid(v) then
				v:DoExplode()
			end
		end
	end
	
	function SWEP:OnHolster()
		if IsValid(self.mdlRadio) then self.mdlRadio:Remove(); self.mdlRadio = nil end
	end
	
	function SWEP:OnRemove()
		self:DetonateSatchels()
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"
SWEP.InWater = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_satchel.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_satchel.mdl"

SWEP.Primary.Recoil = 2.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.065
SWEP.Primary.Delay = 1.1
SWEP.Primary.SingleClip = true

SWEP.Primary.Damage = "sk_plr_dmg_satchel"
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "satchel"
SWEP.Primary.AmmoSize = 10
SWEP.Primary.AmmoPickup	= 10

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1.1

function SWEP:OnInitialize()
	self.tblEntsSatchels = {}
end

function SWEP:CustomIdle()
	local act
	if !self.Weapon.bRadioSelected && self:GetAmmoPrimary() == 0 then act = ACT_VM_IDLE_EMPTY; self.lastEmpty = true
	elseif self.lastEmpty then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self:NextIdle(self:SequenceDuration())
		self.Weapon:SetNextSecondaryFire(self.Weapon.nextIdle)
		self.Weapon:SetNextPrimaryFire(self.Weapon.nextIdle)
		self.lastEmpty = false
		return
	else act = ACT_VM_IDLE end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:Deploy()
	self.Weapon:OnDeploy()
	return true
end

function SWEP:OnThink()
	if self.holsterSwap && CurTime() >= self.holsterSwap then
		self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
		self:NextIdle(0.5)
		self.swapSatchel = CurTime() +self:SequenceDuration()
		self.holsterSwap = nil
	end
	if !self.swapSatchel || CurTime() < self.swapSatchel then return end
	self.swapSatchel = nil
	if SERVER then self:SelectSatchel() end
	if self:GetAmmoPrimary() == 0 then self.Weapon:SendWeaponAnim(ACT_VM_IDLE_EMPTY); self:NextIdle(0); return end
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:OnDeploy()
	self.lastEmpty = false
	self.holsterSwap = nil
	if !self.swapSatchel then
		if self.Weapon.bRadioSelected then self:SelectRadio()
		else
			if self:GetAmmoPrimary() == 0 then self.Weapon:SendWeaponAnim(ACT_VM_IDLE_EMPTY); self:NextIdle(0); return end
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			self:NextIdle(self:SequenceDuration())
			self.Weapon:SetNextSecondaryFire(self.Weapon.nextIdle)
			self.Weapon:SetNextPrimaryFire(self.Weapon.nextIdle)
		end
		return
	end
	self.swapSatchel = nil
	self:SelectSatchel()
end

function SWEP:DetonateSatchels()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:NextIdle(-1)
	self.holsterSwap = CurTime() +0.6
	local dur = self:SequenceDuration()
	self.Weapon:SetNextSecondaryFire(CurTime() +dur +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +dur +self.Primary.Delay)
	if CLIENT then return end
	self.delayHolster = CurTime() +dur
	if !self.tblEntsSatchels then return end
	for k, v in pairs(self.tblEntsSatchels) do
		if IsValid(v) then
			v:DoExplode(120, 120, self.Owner)
		end
	end
	self.tblEntsSatchels = {}
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	if CLIENT then
		if !self.Weapon.bRadioSelected && self:GetAmmoPrimary() > 0 then self:PlayThirdPersonAnim() end
		return
	end
	if !self.Weapon.bRadioSelected then self:ThrowSatchel() return end
	self:DetonateSatchels()
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Secondary.Delay)
	if CLIENT then
		if self:GetAmmoPrimary() > 0 then self:PlayThirdPersonAnim() end
		return
	end
	self:ThrowSatchel()
end