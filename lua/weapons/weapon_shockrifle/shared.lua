SWEP.HoldType = "ar2"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 4
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false
	SWEP.NPCFireRate = 0.3
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/shock_roach/shock_fire.wav"
	SWEP.tblSounds["Recharge"] = "weapons/shock_roach/shock_recharge.wav"
	SWEP.nextRecharge = 0
	
	function SWEP:OnThink()
		if self:GetAmmoPrimary() < 10 && CurTime() >= self.nextRecharge then
			self.nextRecharge = CurTime() +0.5
			self:AddAmmoPrimary(1)
			self:slvPlaySound("Recharge", nil, true)
		end
	end
	
	function SWEP:OnDeploy()
		self:slvPlaySound("weapons/shock_roach/shock_draw.wav", nil, true)
		self.nextRecharge = CurTime() +1
	end
	
	function SWEP:OnDrop()
		self:Drop()
		local ent = ents.Create("monster_shockroach")
		ent:SetPos(self:GetPos())
		ent:SetAngles(Angle(0,self:GetAngles().y,0))
		ent:Spawn()
		ent:Activate()
		self:Remove()
	end
	
	function SWEP:PostInit()
		if IsValid(self.Owner) then return end
		self:OnDrop()
	end
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/opfor/v_shock.mdl"
SWEP.WorldModel = "models/weapons/opfor/w_shock.mdl"

SWEP.Primary.Recoil = 2.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.08
SWEP.Primary.Delay = 0.25

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = true
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "plasma"
SWEP.Primary.AmmoSize = 10
SWEP.Primary.AmmoPickup	= 10

SWEP.Secondary.Ammo = "none"
function SWEP:Attack(ShootPos, ShootDir)
	local ang = self.Owner:GetAimVector():Angle()
	local entPlasma = ents.Create("obj_shockroach_plasma")
	entPlasma:SetPos(ShootPos || self.Owner:GetShootPos() +ang:Right() *4 +ang:Up() *-4)
	entPlasma:SetEntityOwner(self.Owner)
	entPlasma:Spawn()
	entPlasma:Activate()
	
	local phys = entPlasma:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceCenter((ShootDir || ang:Forward()) *2000)
	end
end

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	if self:GetAmmoPrimary() <= 0 then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	if self.Owner:IsPlayer() then
		self:NextIdle(self.Primary.Delay)
	end
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	self:AddAmmoPrimary(-1)
	self:slvPlaySound("Primary")
	
	if self.Owner:WaterLevel() == 3 then
		local rand = {1,2,3,5,6,7,8,9}
		rand = rand[math.random(1,8)]
		self.Owner:EmitSound("ambient/energy/zap" .. rand .. ".wav", 75, 100)
		self.Owner:Kill()
		return
	end
	
	if game.SinglePlayer() then self:Attack(ShootPos, ShootDir)
	else timer.Simple(0, function() if IsValid(self) then self:Attack(ShootPos, ShootDir) end end) end
	if !self.Owner:IsPlayer() then return end
	self.nextRecharge = CurTime() +1
end

function SWEP:SecondaryAttack()
end

