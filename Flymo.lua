local FONT = [=[Interface\AddOns\Flymo\semplice.ttf]=]
local TEXTURE = [=[Interface\Tooltips\UI-Tooltip-Background]=]
local BACKDROP = {
	bgFile = TEXTURE,
}

local levelString = string.gsub(TOOLTIP_UNIT_LEVEL, '%%s', '.+')

local classifications = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

GameTooltip:SetScript('OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if(not unit) then return end

	local color
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		color = RAID_CLASS_COLORS[class]
	else
		color = FACTION_BAR_COLORS[UnitReaction(unit, 'player')]
	end

	GameTooltipTextLeft1:SetFormattedText('%s%s', ConvertRGBtoColorString(color), GetUnitName(unit))

	local guild = GetGuildInfo(unit)
	for index = 2, self:NumLines() do
		local line = _G['GameTooltipTextLeft' .. index]
		local text = line:GetText()

		if(guild and string.find(text, guild)) then
			line:SetFormattedText('|cff%s<%s>|r', UnitIsInMyGuild(unit) and '0090ff' or '00ff10', guild)
		end

		if(string.find(text, levelString)) then
			local level = UnitLevel(unit)
			local color = ConvertRGBtoColorString(GetQuestDifficultyColor(UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 99))

			if(UnitIsPlayer(unit)) then
				line:SetFormattedText('%s%s|r %s %s', color, level, UnitRace(unit), UnitIsAFK(unit) and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or '')
			else
				line:SetFormattedText('%s%s%s|r %s', color, level > 0 and level or '??', classifications[UnitClassification(unit)] or '', UnitCreatureFamily(unit) or UnitCreatureType(unit) or '')
			end
		end

		if(string.find(text, PVP)) then
			line:Hide()
		end
	end

	if(not UnitIsDeadOrGhost(unit)) then
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 1, 1)
		GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -1, 1)
	else
		GameTooltipStatusBar:Hide()
	end

	GameTooltip:Show()
end)

GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:SetStatusBarTexture(TEXTURE)
GameTooltipStatusBar:HookScript('OnValueChanged', function(self)
	if(not UnitExists('mouseover')) then return end

	local color
	if(UnitIsPlayer('mouseover') and not UnitHasVehicleUI('mouseover')) then
		local _, class = UnitClass('mouseover')
		color = RAID_CLASS_COLORS[class]
	else
		color = FACTION_BAR_COLORS[UnitReaction('mouseover', 'player')]
	end

	GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
end)

local background = GameTooltipStatusBar:CreateTexture(nil, 'BACKGROUND')
background:SetAllPoints()
background:SetTexture(1/3, 1/3, 1/3)

local function Update(self)
	local name = self:GetName()
	for index = 1, self:NumLines() do
		_G[name .. 'TextLeft' .. index]:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
		_G[name .. 'TextRight' .. index]:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	end
end

local function Backdrop(self)
	self:SetBackdropColor(0, 0, 0)
end

for _, tooltip in pairs({
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	WorldMapTooltip,
}) do
	tooltip:SetBackdrop(BACKDROP)
	tooltip:HookScript('OnSizeChanged', Update)
	tooltip:HookScript('OnUpdate', Backdrop)
end
