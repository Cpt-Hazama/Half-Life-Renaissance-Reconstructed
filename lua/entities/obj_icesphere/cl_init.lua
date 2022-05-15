include('shared.lua')

language.Add("obj_icesphere", "Ice Sphere")
function ENT:Draw()
	self:DrawModel()
end