include('shared.lua')

function ENT:Initialize()
end

function ENT:Draw()
	local entOwner = self:GetNetworkedEntity("owner")
	if !IsValid(entOwner) || (LocalPlayer() == entOwner && GetViewEntity() == LocalPlayer()) then return end
	self:DrawModel()
end