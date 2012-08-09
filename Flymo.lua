local FONT = [=[Interface\AddOns\Flymo\semplice.ttf]=]
local TEXTURE = [=[Interface\Tooltips\UI-Tooltip-Background]=]

local levelString = string.gsub(TOOLTIP_UNIT_LEVEL, '%%s', '.+')

local classification = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

GameTooltip:SetScript('OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if(not unit) then return end

	local guild = GetGuildInfo(unit)

	local color
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		color = RAID_CLASS_COLORS[class]
	else
		color = FACTION_BAR_COLORS[UnitReaction(unit, 'player')]
	end

	GameTooltipTextLeft1:SetFormattedText('%s%s', ConvertRGBtoColorString(color), GetUnitName(unit))

	for index = 2, self:NumLines() do
		local text = _G['GameTooltipTextLeft'..index]

		if(guild and string.find(text:GetText(), guild)) then
			text:SetFormattedText('|cff%s<%s>|r', UnitIsInMyGuild(unit) and '0090ff' or '00ff10', guild)
		end

		if(string.find(text:GetText(), levelString)) then
			local level = UnitLevel(unit)
			local color = ConvertRGBtoColorString(GetQuestDifficultyColor(UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 99))

			if(UnitIsPlayer(unit)) then
				text:SetFormattedText('%s%s|r %s %s', color, level, UnitRace(unit),
					UnitIsAFK(unit) and CHAT_FLAG_AFK or
					UnitIsDND(unit) and CHAT_FLAG_DND or
					not UnitIsConnected(unit) and '<DC>' or '')
			else
				text:SetFormattedText('%s%s%s|r %s', color, level > 0 and level or '??', classification[UnitClassification(unit)] or '', UnitCreatureFamily(unit) or UnitCreatureType(unit) or '')
			end
		end

		if(string.find(text:GetText(), PVP)) then
			text:Hide()
		end
	end

	if(not UnitIsDeadOrGhost(unit)) then
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 1, 1)
		GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -1, 1)
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

GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil, 'BACKGROUND')
GameTooltipStatusBar.bg:SetAllPoints(GameTooltipStatusBar)
GameTooltipStatusBar.bg:SetTexture(0.4, 0.4, 0.4)

local function Update(self)
	self:SetBackdropColor(0, 0, 0)

	local name = self:GetName()
	for index = 1, self:NumLines() do
		_G[name .. 'TextLeft' .. index]:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
		_G[name .. 'TextRight' .. index]:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	end
end

for _, tooltip in pairs({
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3
}) do
	tooltip:SetBackdrop({bgFile = TEXTURE})
	tooltip:HookScript('OnSizeChanged', Update)
end
