local FONT = [=[Interface\AddOns\Flymo\semplice.ttf]=]
local TEXTURE = [=[Interface\Tooltips\UI-Tooltip-Background]=]
local BACKDROP = {
	bgFile = TEXTURE, insets = {top = 1, bottom = 1, left = 1, right = 1}
}

local levelString = string.gsub(TOOLTIP_UNIT_LEVEL, '%%s', '.+')

local classifications = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

GameTooltip:HookScript('OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if(not unit) then return end

	local color
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		color = RAID_CLASS_COLORS[class]
	else
		color = FACTION_BAR_COLORS[UnitReaction(unit, 'player') or 5]
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
			local levelColor = ConvertRGBtoColorString(GetQuestDifficultyColor(UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 99))

			if(UnitIsPlayer(unit)) then
				local factionColor
				if(UnitFactionGroup(unit) ~= UnitFactionGroup('player')) then
					factionColor = 'ff3300'
				else
					factionColor = 'ffffff'
				end

				line:SetFormattedText('%s%s|r |cff%s%s|r %s', levelColor, level, factionColor, UnitRace(unit), UnitIsAFK(unit) and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or '')
			else
				local creature
				if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
					level = UnitBattlePetLevel(unit)
					levelColor = '|cffffff00'

					creature = _G['BATTLE_PET_NAME_' .. UnitBattlePetType(unit)]
				else
					creature = UnitCreatureFamily(unit) or UnitCreatureType(unit) or ''
				end

				line:SetFormattedText('%s%s%s|r %s', levelColor, level > 0 and level or '??', classifications[UnitClassification(unit)] or '', creature)
			end
		end

		if(string.find(text, PVP) or string.find(text, FACTION_ALLIANCE) or string.find(text, FACTION_HORDE)) then
			line:Hide()
		end
	end

	if(not UnitIsDeadOrGhost(unit)) then
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 2, 2)
		GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -2, 2)
		GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		GameTooltipStatusBar:Hide()
	end

	self:Show()
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

local function UpdateMoney(self, money)
	self:AddDoubleLine(SELL_PRICE, GetCoinTextureString(money), nil, nil, nil, 1, 1, 1)
end

local function Update(self)
	local name = self:GetName()
	for index = 1, self:NumLines() do
		local left = _G[name .. 'TextLeft' .. index]
		left:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
		left:SetShadowOffset(0, 0)

		local right = _G[name .. 'TextRight' .. index]
		right:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
		right:SetShadowOffset(0, 0)
	end
end

local function Backdrop(self)
	self:SetBackdropColor(0, 0, 0)
end

for _, name in pairs({
	'GameTooltip',
	'ItemRefTooltip',
	'ItemRefShoppingTooltip1',
	'ItemRefShoppingTooltip2',
	'ItemRefShoppingTooltip3',
	'ShoppingTooltip1',
	'ShoppingTooltip2',
	'ShoppingTooltip3',
	'WorldMapTooltip',
}) do
	local tooltip = _G[name]
	tooltip:SetBackdrop(BACKDROP)
	tooltip:SetScript('OnTooltipAddMoney', UpdateMoney)
	tooltip:HookScript('OnSizeChanged', Update)
	tooltip:HookScript('OnUpdate', Backdrop)
	tooltip:HookScript('OnShow', Backdrop)
end
