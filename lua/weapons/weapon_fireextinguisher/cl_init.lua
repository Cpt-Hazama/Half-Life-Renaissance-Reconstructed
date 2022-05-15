include('shared.lua')

language.Add("weapon_fireextinguisher", "Fire Extinguisher")

SWEP.PrintName = "Fire Extinguisher"
SWEP.Slot = 4
SWEP.SlotPos = 4
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false

SWEP.WepSelectIcon = surface.GetTextureID("HUD/weapons/weapon_fireextinguisher") 
SWEP.BounceWeaponIcon = false 

usermessage.Hook("fireextinguisher_effectstart", function(um)
	local self = um:ReadEntity()
	if !IsValid(self) then return end
	local owner = self.Owner
	local vm = self
	local ViewModel = self.Owner == LocalPlayer() && GetViewEntity() == LocalPlayer()
	if ViewModel then
		vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
	end
	local att = vm:LookupAttachment("muzzle")
	local iIndex = owner:EntIndex()
	hook.Add("Think", "Fireextinguisher_ParticleThink" .. iIndex, function()
		if IsValid(self) && IsValid(owner) && IsValid(vm) then
			local att = self:LookupAttachment("muzzle")
			local vmCur = owner == LocalPlayer() && GetViewEntity() == LocalPlayer() && self.Owner:GetViewModel() || self
			if vmCur != vm then
				vm = vmCur
				att = vm:LookupAttachment("muzzle")
			end
			local effect = EffectData()
			effect:SetStart(self:GetAttachment(att).Pos)
			effect:SetNormal(owner:GetAimVector())
			effect:SetEntity(self)
			effect:SetAttachment(att)
			util.Effect("effect_fireextinguisher",effect)
		else hook.Remove("Think", "Flamer_ParticleThink" .. iIndex) end
	end)
end)

usermessage.Hook("fireextinguisher_effectstop", function(um)
	local self = um:ReadEntity()
	if !IsValid(self) then return end
	hook.Remove("Think", "Fireextinguisher_ParticleThink" .. self:EntIndex())
end)
