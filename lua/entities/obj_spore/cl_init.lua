include('shared.lua')

language.Add("obj_spore", "Spore")

function ENT:Draw()   
	self:DrawModel()
end
 
function ENT:OnRemove()
end
 
function ENT:Think()
end