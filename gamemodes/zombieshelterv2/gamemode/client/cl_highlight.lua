--[[
	EN :
	Zombie Shelter v2.0 by Meiryi / Meika / Shiro / Shigure
	You SHOULD NOT edit / modify / reupload the codes, it includes editing gamemode's name
	If you have any problems, feel free to contact me on steam, thank you for reading this

	ZH-TW :
	夜襲生存戰 v2.0 by Meiryi  / Meika / Shiro / Shigure
	任何的修改是不被允許的 (包括模式的名稱)，有問題請在Steam上聯絡我, 謝謝!
	
	ZH-CN :
	昼夜求生 v2.0 by Meiryi  / Meika / Shiro / Shigure
	任何形式的编辑是不被允许的 (包括模式的名称), 若有问题请在Steam上联络我
]]

local hlents = {}

net.Receive("ZShelter-HighlightEntity", function()
	local len = net.ReadUInt(32)
	local data = net.ReadData(len)
	local list = util.JSONToTable(util.Decompress(data))
	for k,v in pairs(list) do
		local entity = Entity(v.index)
		table.insert(hlents, {
			entity = entity,
			clr = v.color,
			endtime = CurTime() + 10,
		})
	end
end)

hook.Add("PreDrawHalos", "ZShelter-HighlightingEntity", function()
	if(#hlents < 1) then return end
	for k,v in pairs(hlents) do
		if(!IsValid(v.entity) || v.endtime < CurTime()) then
			table.remove(hlents, k)
			continue
		end
		halo.Add({v.entity}, v.clr, 1, 1, 5, true, true)
	end
end)