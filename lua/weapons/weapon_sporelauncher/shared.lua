SWEP.HoldType = "ar2"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false 
	SWEP.NPCFireRate = 0.75
	SWEP.AutomaticFrameAdvance = true

	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/spore_launcher/splauncher_fire.wav"
	SWEP.tblSounds["Secondary"] = "weapons/spore_launcher/splauncher_altfire.wav"
	SWEP.tblSounds["ReloadB"] = "weapons/spore_launcher/splauncher_reload.wav"
	
	function SWEP:OnInitialize()
		local mdl = ents.Create("prop_dynamic_override")
		mdl:SetModel("models/weapons/opfor/w_spore_launcher.mdl")
		mdl:SetKeyValue("DefaultAnim", "stayput")
		mdl:SetPos(self:GetPos())
		mdl:SetAngles(self:GetAngles())
		mdl:Spawn()
		mdl:Activate()
		mdl:SetParent(self)
		self.mdl = mdl
		self:SetColor(255,255,255,0)
		self:DeleteOnRemove(mdl)
	end
	
	function SWEP:OnEquip()
		if IsValid(self.mdl) then self.mdl:Remove() end
		self.mdl = nil
		self:SetColor(255,255,255,255)
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.SingleReload = true
SWEP.EmptySound = false

SWEP.ViewModel = "models/weapons/opfor/v_spore_launcher.mdl"
SWEP.WorldModel = "models/weapons/opfor/w_spore_launcher.mdl"

SWEP.Primary.Delay = 0.5

SWEP.Primary.Recoil = 2.5
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "spore"
SWEP.Primary.AmmoSize = 20
SWEP.Primary.AmmoPickup	= 20

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.ReloadDelay = 0.36

function SWEP:OnIdle()
	if !CLIENT && !game.SinglePlayer() || self:GetSequence() !=  self:LookupSequence("fidget") then return end
	self.cspPet = CreateSound(self.Owner, "weapons/spore_launcher/splauncher_pet.wav")
	self.cspPet:Play()
end

function SWEP:OnHolster()
	self.Weapon.nextReload = nil
	if !self.cspPet then return end
	self.cspPet:Stop()
end

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	
	if !self:CanPrimaryAttack() then self:Reload(); return end
	if SERVER then self:slvPlaySound("Primary") end
	self:Attack(false,ShootPos, ShootDir)
end

function SWEP:Attack(bGrenade,ShootPos, ShootDir)
	if self.cspPet then self.cspPet:Stop() end
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self.Weapon.nextReload = nil
	self:PlayThirdPersonAnim()
	if game.SinglePlayer() || CLIENT then
		self:SetNetworkedFloat("LastShootTime", CurTime())
		if CLIENT then return end
	end
	
	local entSpore = ents.Create("obj_spore")
	entSpore:SetEntityOwner(self.Owner)
	local ang = self.Owner:GetAimVector():Angle()
	local pos = ShootPos || self.Owner:GetShootPos() +ang:Right() *5 +ang:Up() *-4
	entSpore:SetPos(pos)
	entSpore:SetGrenade(bGrenade)
	entSpore:Spawn()
	entSpore:Activate()
	
	local phys = entSpore:GetPhysicsObject()
	if IsValid(phys) then
		local ang = self.Owner:EyeAngles()
		phys:ApplyForceCenter((ShootDir || ang:Forward()) *1200)
	end
	if !self.Owner:IsPlayer() then return end
	self:AddClip1(-1)
	self.Owner:ViewPunch(Angle(-3,0,0))
end

function SWEP:SecondaryAttack(ShootPos, ShootDir)
	self:EmitSound("weapons/spore_launcher/splauncher_altfire.wav", 75, 100)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	
	if !self:CanPrimaryAttack() then self:Reload(); return end
	if SERVER then self:slvPlaySound("Primary") end
	self:Attack(true,ShootPos, ShootDir)
end
