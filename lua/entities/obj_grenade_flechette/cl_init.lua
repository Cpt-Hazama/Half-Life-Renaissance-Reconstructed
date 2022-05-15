include('shared.lua')

language.Add("obj_grenade_flechette", "Flechette Grenade")

function ENT:Draw()   
	self:DrawModel()
end
 
function ENT:OnRemove()
end
 
function ENT:Think()
end