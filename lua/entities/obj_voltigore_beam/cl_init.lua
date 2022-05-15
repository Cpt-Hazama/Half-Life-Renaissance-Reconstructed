include('shared.lua')

language.Add("obj_voltigore_beam", "Voltigore")
ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:Initialize()
end

function ENT:Draw()
	render.SetMaterial(Material("sprites/volt_glow01"))
	render.DrawSprite(self:GetPos(), 16, 16, Color(255, 255, 255, 255))
end