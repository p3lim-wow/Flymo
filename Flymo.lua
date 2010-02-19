local FONT = [=[Interface\AddOns\Flymo\media\semplice.ttf]=]

local levelString = string.gsub(TOOLTIP_UNIT_LEVEL, '%%s', '.+')

local classification = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

local function Hex(color)
	return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end

local function GetColor(unit)
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		return Hex(color), color
	else
		local color = FACTION_BAR_COLORS[UnitReaction(unit, 'player')]
		return Hex(color), color
	end
end

GameTooltip:SetScript('OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if(not unit) then return end

	local hexed, pure = GetColor(unit)
	local raidicon = GetRaidTargetIndex(unit)
	local guild = GetGuildInfo(unit)

	_G['GameTooltipTextLeft1']:SetFormattedText('%s%s%s|r', raidicon and ICON_LIST[raidicon]..'22|t' or '', GetColor(unit), GetUnitName(unit))

	for index = 2, self:NumLines() do
		local text = _G['GameTooltipTextLeft'..index]
		if(guild and string.find(text:GetText(), guild)) then
			text:SetFormattedText('|cff%s<%s>|r', UnitIsInMyGuild(unit) and '0090ff' or '00ff10', guild)
		end

		if(string.find(text:GetText(), levelString)) then
			local level = UnitLevel(unit)
			local color = Hex(GetQuestDifficultyColor(UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 99))

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
		GameTooltipStatusBar:SetStatusBarColor(pure.r, pure.g, pure.b)
	end

	GameTooltip:Show()
end)

GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:SetStatusBarTexture([=[Interface\AddOns\Flymo\media\minimalist]=])

GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil, 'BACKGROUND')
GameTooltipStatusBar.bg:SetAllPoints(GameTooltipStatusBar)
GameTooltipStatusBar.bg:SetTexture(0.4, 0.4, 0.4)

for _, tooltip in pairs({
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3
}) do
	tooltip:SetBackdrop({bgFile = [=[Interface\Tooltips\UI-Tooltip-Background]=]})
	tooltip:HookScript('OnShow', function(self)
		self:SetBackdropColor(0, 0, 0)

		for index = 1, self:NumLines() do
			_G[self:GetName()..'TextLeft'..index]:SetFont(FONT, 8, 'OUTLINE')
			_G[self:GetName()..'TextRight'..index]:SetFont(FONT, 8, 'OUTLINE')
		end
	end)
end
