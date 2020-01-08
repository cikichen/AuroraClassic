-- [[ Core ]]
local addonName, ns = ...

ns[1] = {} -- F, functions
ns[2] = {} -- C, constants/config
_G[addonName] = ns

AuroraConfig = {}

local F, C = unpack(ns)

-- [[ Constants and settings ]]

local mediaPath = "Interface\\AddOns\\AuroraClassic\\media\\"

C.media = {
	["arrowUp"] = mediaPath.."arrow-up-active",
	["arrowDown"] = mediaPath.."arrow-down-active",
	["arrowLeft"] = mediaPath.."arrow-left-active",
	["arrowRight"] = mediaPath.."arrow-right-active",
	["backdrop"] = "Interface\\ChatFrame\\ChatFrameBackground",
	["checked"] = mediaPath.."CheckButtonHilight",
	["font"] = STANDARD_TEXT_FONT,
	["gradient"] = mediaPath.."gradient",
	["roleIcons"] = mediaPath.."UI-LFG-ICON-ROLES",
	["bgTex"] = mediaPath.."bgTex",
	["glowTex"] = mediaPath.."glowTex",
}

C.defaults = {
	["alpha"] = 0.5,
	["bags"] = false,
	["buttonGradientColour"] = {.3, .3, .3, .3},
	["buttonSolidColour"] = {.2, .2, .2, .6},
	["useButtonGradientColour"] = true,
	["chatBubbles"] = true,
	["bubbleColor"] = false,
	["reskinFont"] = true,
	["loot"] = true,
	["useCustomColour"] = false,
	["customColour"] = {r = 1, g = 1, b = 1},
	["tooltips"] = false,
	["shadow"] = true,
	["fontScale"] = 1,
	["objectiveTracker"] = true,
	["uiScale"] = 0,
}

C.frames = {}
C.isNewPatch = GetBuildInfo() == "8.3.0"

-- [[ Functions ]]

local useButtonGradientColour
local _, class = UnitClass("player")
C.classcolours = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local r, g, b = C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b

local function SetupPixelFix()
	local screenHeight = select(2, GetPhysicalScreenSize())
	local bestScale = max(.4, min(1.15, 768 / screenHeight))
	local pixelScale = 768 / screenHeight
	local scale = UIParent:GetScale()
	local uiScale = AuroraConfig.uiScale
	if uiScale and uiScale > 0 then scale = uiScale end
	C.mult = (bestScale / scale) - ((bestScale - pixelScale) / scale)
end

function F:dummy()
end

local function CreateTex(f)
	if f.Tex then return end
	f.Tex = f:CreateTexture(nil, "BACKGROUND", nil, 1)
	f.Tex:SetAllPoints()
	f.Tex:SetTexture(C.media.bgTex, true, true)
	f.Tex:SetHorizTile(true)
	f.Tex:SetVertTile(true)
	f.Tex:SetBlendMode("ADD")
end

function F:CreateSD()
	CreateTex(self)

	if not AuroraConfig.shadow then return end
	if self.Shadow then return end
	self.Shadow = CreateFrame("Frame", nil, self)
	self.Shadow:SetPoint("TOPLEFT", -2, 2)
	self.Shadow:SetPoint("BOTTOMRIGHT", 2, -2)
	self.Shadow:SetBackdrop({edgeFile = C.media.glowTex, edgeSize = 3})
	self.Shadow:SetBackdropBorderColor(0, 0, 0)
	return self.Shadow
end

-- ls, Azil, and Simpy made this to replace Blizzard's SetBackdrop API while the textures can't snap
local PIXEL_BORDERS = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}

function F:SetBackdrop(frame, a)
	local borders = frame.pixelBorders
	if not borders then return end

	local size = C.mult

	borders.CENTER:SetPoint("TOPLEFT", frame)
	borders.CENTER:SetPoint("BOTTOMRIGHT", frame)

	borders.TOPLEFT:SetSize(size, size)
	borders.TOPRIGHT:SetSize(size, size)
	borders.BOTTOMLEFT:SetSize(size, size)
	borders.BOTTOMRIGHT:SetSize(size, size)

	borders.TOP:SetHeight(size)
	borders.BOTTOM:SetHeight(size)
	borders.LEFT:SetWidth(size)
	borders.RIGHT:SetWidth(size)

	F:SetBackdropColor(frame, 0, 0, 0, a)
	F:SetBackdropBorderColor(frame, 0, 0, 0)
end

function F:SetBackdropColor(frame, r, g, b, a)
	if frame.pixelBorders then
		frame.pixelBorders.CENTER:SetVertexColor(r, g, b, a)
	end
end

function F:SetBackdropBorderColor(frame, r, g, b, a)
	if frame.pixelBorders then
		for _, v in pairs(PIXEL_BORDERS) do
			frame.pixelBorders[v]:SetVertexColor(r or 0, g or 0, b or 0, a or 1)
		end
	end
end

function F:SetBackdropColor_Hook(r, g, b, a)
	F:SetBackdropColor(self, r, g, b, a)
end

function F:SetBackdropBorderColor_Hook(r, g, b, a)
	F:SetBackdropBorderColor(self, r, g, b, a)
end

function F:PixelBorders(frame)
	if frame and not frame.pixelBorders then
		local borders = {}
		for _, v in pairs(PIXEL_BORDERS) do
			borders[v] = frame:CreateTexture(nil, "BORDER", nil, 1)
			borders[v]:SetTexture(C.media.backdrop)
		end

		borders.CENTER = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
		borders.CENTER:SetTexture(C.media.backdrop)

		borders.TOPLEFT:SetPoint("BOTTOMRIGHT", borders.CENTER, "TOPLEFT", 1, -1)
		borders.TOPRIGHT:SetPoint("BOTTOMLEFT", borders.CENTER, "TOPRIGHT", -1, -1)
		borders.BOTTOMLEFT:SetPoint("TOPRIGHT", borders.CENTER, "BOTTOMLEFT", 1, 1)
		borders.BOTTOMRIGHT:SetPoint("TOPLEFT", borders.CENTER, "BOTTOMRIGHT", -1, 1)

		borders.TOP:SetPoint("TOPLEFT", borders.TOPLEFT, "TOPRIGHT", 0, 0)
		borders.TOP:SetPoint("TOPRIGHT", borders.TOPRIGHT, "TOPLEFT", 0, 0)

		borders.BOTTOM:SetPoint("BOTTOMLEFT", borders.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
		borders.BOTTOM:SetPoint("BOTTOMRIGHT", borders.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

		borders.LEFT:SetPoint("TOPLEFT", borders.TOPLEFT, "BOTTOMLEFT", 0, 0)
		borders.LEFT:SetPoint("BOTTOMLEFT", borders.BOTTOMLEFT, "TOPLEFT", 0, 0)

		borders.RIGHT:SetPoint("TOPRIGHT", borders.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
		borders.RIGHT:SetPoint("BOTTOMRIGHT", borders.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

		hooksecurefunc(frame, "SetBackdropColor", F.SetBackdropColor_Hook)
		hooksecurefunc(frame, "SetBackdropBorderColor", F.SetBackdropBorderColor_Hook)

		frame.pixelBorders = borders
	end
end
-- Custom SetBackdrop END

function F:CreateBD(a)
	self:SetBackdrop(nil)
	F:PixelBorders(self)
	F:SetBackdrop(self, a or AuroraConfig.alpha)
	if not a then tinsert(C.frames, self) end
end

function F:CreateBG()
	local f = self
	if self:GetObjectType() == "Texture" then f = self:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", self, -C.mult, C.mult)
	bg:SetPoint("BOTTOMRIGHT", self, C.mult, -C.mult)
	bg:SetTexture(C.media.backdrop)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

-- we assign these after loading variables for caching
-- otherwise we call an extra unpack() every time
local buttonR, buttonG, buttonB, buttonA

function F:CreateGradient()
	local tex = self:CreateTexture(nil, "BORDER")
	tex:SetPoint("TOPLEFT", self, C.mult, -C.mult)
	tex:SetPoint("BOTTOMRIGHT", self, -C.mult, C.mult)
	tex:SetTexture(useButtonGradientColour and C.media.gradient or C.media.backdrop)
	tex:SetVertexColor(buttonR, buttonG, buttonB, buttonA)

	return tex
end

local function colourButton(self)
	if not self:IsEnabled() then return end

	if useButtonGradientColour then
		self:SetBackdropColor(r, g, b, .25)
	else
		self.bgTex:SetVertexColor(r / 4, g / 4, b / 4)
	end

	self:SetBackdropBorderColor(r, g, b)
end

local function clearButton(self)
	if useButtonGradientColour then
		self:SetBackdropColor(0, 0, 0, 0)
	else
		self.bgTex:SetVertexColor(buttonR, buttonG, buttonB, buttonA)
	end

	self:SetBackdropBorderColor(0, 0, 0)
end

local blizzRegions = {
	"Left",
	"Middle",
	"Right",
	"Mid",
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"TopLeft",
	"TopRight",
	"BottomLeft",
	"BottomRight",
	"TopMiddle",
	"MiddleLeft",
	"MiddleRight",
	"BottomMiddle",
	"MiddleMiddle",
	"TabSpacer",
	"TabSpacer1",
	"TabSpacer2",
	"_RightSeparator",
	"_LeftSeparator",
	"Cover",
	"Border",
	"Background",
	"TopTex",
	"TopLeftTex",
	"TopRightTex",
	"LeftTex",
	"BottomTex",
	"BottomLeftTex",
	"BottomRightTex",
	"RightTex",
	"MiddleTex",
}
function F:Reskin(noHighlight)
	if self.SetNormalTexture then self:SetNormalTexture("") end
	if self.SetHighlightTexture then self:SetHighlightTexture("") end
	if self.SetPushedTexture then self:SetPushedTexture("") end
	if self.SetDisabledTexture then self:SetDisabledTexture("") end

	local buttonName = self.GetName and self:GetName()
	for _, region in pairs(blizzRegions) do
		region = buttonName and _G[buttonName..region] or self[region]
		if region then
			region:SetAlpha(0)
		end
	end

	F.CreateBD(self, 0)

	self.bgTex = F.CreateGradient(self)

	if not noHighlight then
		self:HookScript("OnEnter", colourButton)
 		self:HookScript("OnLeave", clearButton)
	end
end

function F:ReskinTab()
	self:DisableDrawLayer("BACKGROUND")

	local bg = F.CreateBDFrame(self)
	bg:SetPoint("TOPLEFT", 8, -3)
	bg:SetPoint("BOTTOMRIGHT", -8, 0)

	self:SetHighlightTexture(C.media.backdrop)
	local hl = self:GetHighlightTexture()
	hl:ClearAllPoints()
	hl:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
	hl:SetPoint("BOTTOMRIGHT", bg, -C.mult, C.mult)
	hl:SetVertexColor(r, g, b, .25)
end

local function textureOnEnter(self)
	if self:IsEnabled() then
		if self.pixels then
			for _, pixel in pairs(self.pixels) do
				pixel:SetVertexColor(r, g, b)
			end
		else
			self.bgTex:SetVertexColor(r, g, b)
		end
	end
end
F.colourArrow = textureOnEnter

local function textureOnLeave(self)
	if self.pixels then
		for _, pixel in pairs(self.pixels) do
			pixel:SetVertexColor(1, 1, 1)
		end
	else
		self.bgTex:SetVertexColor(1, 1, 1)
	end
end
F.clearArrow = textureOnLeave

local function scrollOnEnter(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(r, g, b, .25)
	thumb.bg:SetBackdropBorderColor(r, g, b)
end

local function scrollOnLeave(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(0, 0, 0, 0)
	thumb.bg:SetBackdropBorderColor(0, 0, 0)
end

function F:ReskinScroll()
	F.StripTextures(self:GetParent())
	F.StripTextures(self)

	local frameName = self.GetName and self:GetName()
	local thumb = frameName and (_G[frameName.."ThumbTexture"] or _G[frameName.."thumbTexture"]) or self.GetThumbTexture and self:GetThumbTexture()
	if thumb then
		thumb:SetAlpha(0)
		thumb:SetWidth(17)
		self.thumb = thumb

		local bg = F.CreateBDFrame(self, 0)
		bg:SetPoint("TOPLEFT", thumb, 0, -2)
		bg:SetPoint("BOTTOMRIGHT", thumb, 0, 4)
		F.CreateGradient(bg)
		thumb.bg = bg
	end

	local up, down = self:GetChildren()
	F.ReskinArrow(up, "up")
	F.ReskinArrow(down, "down")

	self:HookScript("OnEnter", scrollOnEnter)
	self:HookScript("OnLeave", scrollOnLeave)
end

function F:ReskinDropDown()
	F.StripTextures(self)

	local frameName = self.GetName and self:GetName()
	local down = self.Button or frameName and (_G[frameName.."Button"] or _G[frameName.."_Button"])

	down:ClearAllPoints()
	down:SetPoint("RIGHT", -18, 2)
	F.ReskinArrow(down, "down")
	down:SetSize(20, 20)

	local bg = F.CreateBDFrame(self, 0)
	bg:SetPoint("TOPLEFT", 16, -4)
	bg:SetPoint("BOTTOMRIGHT", -18, 8)
	F.CreateGradient(bg)
end

function F:ReskinClose(a1, p, a2, x, y)
	self:SetSize(17, 17)

	if not a1 then
		self:SetPoint("TOPRIGHT", -6, -6)
	else
		self:ClearAllPoints()
		self:SetPoint(a1, p, a2, x, y)
	end

	F.StripTextures(self)
	F.CreateBD(self, 0)
	F.CreateGradient(self)

	self:SetDisabledTexture(C.media.backdrop)
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	self.pixels = {}
	for i = 1, 2 do
		local tex = self:CreateTexture()
		tex:SetColorTexture(1, 1, 1)
		tex:SetSize(11, 2)
		tex:SetPoint("CENTER")
		tex:SetRotation(math.rad((i-1/2)*90))
		tinsert(self.pixels, tex)
	end

	self:HookScript("OnEnter", textureOnEnter)
 	self:HookScript("OnLeave", textureOnLeave)
end

function F:ReskinInput(height, width)
	local frameName = self.GetName and self:GetName()
	for _, region in pairs(blizzRegions) do
		region = frameName and _G[frameName..region] or self[region]
		if region then
			region:SetAlpha(0)
		end
	end

	local bd = F.CreateBDFrame(self, 0)
	bd:SetPoint("TOPLEFT", -2, 0)
	bd:SetPoint("BOTTOMRIGHT")
	F.CreateGradient(bd)

	if height then self:SetHeight(height) end
	if width then self:SetWidth(width) end
end

function F:ReskinArrow(direction)
	self:SetSize(17, 17)
	F.Reskin(self, true)

	self:SetDisabledTexture(C.media.backdrop)
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(mediaPath.."arrow-"..direction.."-active")
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	self.bgTex = tex

	self:HookScript("OnEnter", textureOnEnter)
	self:HookScript("OnLeave", textureOnLeave)
end

function F:ReskinCheck()
	self:SetNormalTexture("")
	self:SetPushedTexture("")
	self:SetHighlightTexture(C.media.backdrop)
	local hl = self:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(r, g, b, .25)

	local bd = F.CreateBDFrame(self, 0)
	bd:SetPoint("TOPLEFT", 4, -4)
	bd:SetPoint("BOTTOMRIGHT", -4, 4)
	F.CreateGradient(bd)

	local ch = self:GetCheckedTexture()
	ch:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	ch:SetTexCoord(0, 1, 0, 1)
	ch:SetDesaturated(true)
	ch:SetVertexColor(r, g, b)
end

local function colourRadio(self)
	self.bd:SetBackdropBorderColor(r, g, b)
end

local function clearRadio(self)
	self.bd:SetBackdropBorderColor(0, 0, 0)
end

function F:ReskinRadio()
	self:SetNormalTexture("")
	self:SetHighlightTexture("")
	self:SetCheckedTexture(C.media.backdrop)

	local ch = self:GetCheckedTexture()
	ch:SetPoint("TOPLEFT", 4, -4)
	ch:SetPoint("BOTTOMRIGHT", -4, 4)
	ch:SetVertexColor(r, g, b, .6)

	local bd = F.CreateBDFrame(self, 0)
	bd:SetPoint("TOPLEFT", 3, -3)
	bd:SetPoint("BOTTOMRIGHT", -3, 3)
	F.CreateGradient(bd)
	self.bd = bd

	self:HookScript("OnEnter", colourRadio)
	self:HookScript("OnLeave", clearRadio)
end

function F:ReskinSlider(verticle)
	self:SetBackdrop(nil)
	F.StripTextures(self)

	local bd = F.CreateBDFrame(self, 0)
	bd:SetPoint("TOPLEFT", 14, -2)
	bd:SetPoint("BOTTOMRIGHT", -15, 3)
	bd:SetFrameStrata("BACKGROUND")
	F.CreateGradient(bd)

	local thumb = self:GetThumbTexture()
	thumb:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	thumb:SetBlendMode("ADD")
	if verticle then thumb:SetRotation(math.rad(90)) end
end

local function expandOnEnter(self)
	if self:IsEnabled() then
		self.bg:SetBackdropColor(r, g, b, .25)
	end
end

local function expandOnLeave(self)
	self.bg:SetBackdropColor(0, 0, 0, .25)
end

local function SetupTexture(self, texture)
	if self.settingTexture then return end
	self.settingTexture = true
	self:SetNormalTexture("")

	if texture and texture ~= "" then
		if texture:find("Plus") then
			self.expTex:SetTexCoord(0, .4375, 0, .4375)
		elseif texture:find("Minus") then
			self.expTex:SetTexCoord(.5625, 1, 0, .4375)
		end
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

function F:ReskinExpandOrCollapse()
	self:SetHighlightTexture("")
	self:SetPushedTexture("")

	local bg = F.CreateBDFrame(self, .25)
	bg:ClearAllPoints()
	bg:SetSize(13, 13)
	bg:SetPoint("TOPLEFT", self:GetNormalTexture())
	F.CreateGradient(bg)
	self.bg = bg

	self.expTex = bg:CreateTexture(nil, "OVERLAY")
	self.expTex:SetSize(7, 7)
	self.expTex:SetPoint("CENTER")
	self.expTex:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")

	self:HookScript("OnEnter", expandOnEnter)
	self:HookScript("OnLeave", expandOnLeave)
	hooksecurefunc(self, "SetNormalTexture", SetupTexture)
end

function F:SetBD(x, y, x2, y2)
	local bg = F.CreateBDFrame(self)
	if x then
		bg:SetPoint("TOPLEFT", x, y)
		bg:SetPoint("BOTTOMRIGHT", x2, y2)
	end
	F.CreateSD(bg)

	return bg
end

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

function F:HideObject()
	if self.UnregisterAllEvents then
		self:UnregisterAllEvents()
		self:SetParent(hiddenFrame)
	else
		self.Show = self.Hide
	end
	self:Hide()
end

local BlizzTextures = {
	"Inset",
	"inset",
	"InsetFrame",
	"LeftInset",
	"RightInset",
	"NineSlice",
	"BG",
	"border",
	"Border",
	"BorderFrame",
	"bottomInset",
	"BottomInset",
	"bgLeft",
	"bgRight",
	"FilligreeOverlay",
	"PortraitOverlay",
	"ArtOverlayFrame",
	"Portrait",
	"portrait",
	"ScrollFrameBorder",
}

function F:StripTextures(kill)
	local frameName = self.GetName and self:GetName()
	for _, texture in pairs(BlizzTextures) do
		local blizzFrame = self[texture] or (frameName and _G[frameName..texture])
		if blizzFrame then
			F.StripTextures(blizzFrame, kill)
		end
	end

	if self.GetNumRegions then
		for i = 1, self:GetNumRegions() do
			local region = select(i, self:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				if kill and type(kill) == "boolean" then
					F.HideObject(region)
				elseif tonumber(kill) then
					if kill == 0 then
						region:SetAlpha(0)
					elseif i ~= kill then
						region:SetTexture("")
					end
				else
					region:SetTexture("")
				end
			end
		end
	end
end

function F:ReskinPortraitFrame()
	F.StripTextures(self)
	local bg = F.SetBD(self)
	local frameName = self.GetName and self:GetName()
	local portrait = self.portrait or _G[frameName.."Portrait"]
	portrait:SetAlpha(0)
	local closeButton = self.CloseButton or _G[frameName.."CloseButton"]
	if closeButton then F.ReskinClose(closeButton) end
	return bg
end

function F:CreateBDFrame(a)
	local frame = self
	if self:GetObjectType() == "Texture" then frame = self:GetParent() end

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetFrameLevel(max(frame:GetFrameLevel()-1, 0))
	bg:SetPoint("TOPLEFT", self, -C.mult, C.mult)
	bg:SetPoint("BOTTOMRIGHT", self, C.mult, -C.mult)
	F.CreateBD(bg, a)

	return bg
end

function F:ReskinColourSwatch()
	local frameName = self.GetName and self:GetName()

	self:SetNormalTexture(C.media.backdrop)
	local nt = self:GetNormalTexture()
	nt:SetPoint("TOPLEFT", 3, -3)
	nt:SetPoint("BOTTOMRIGHT", -3, 3)

	local bg = _G[frameName.."SwatchBg"]
	bg:SetColorTexture(0, 0, 0)
	bg:SetPoint("TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
end

function F:ReskinFilterButton()
	F.StripTextures(self)
	F.Reskin(self)
	self.Text:SetPoint("CENTER")
	self.Icon:SetTexture(C.media.arrowRight)
	self.Icon:SetPoint("RIGHT", self, "RIGHT", -5, 0)
	self.Icon:SetSize(8, 8)
end

function F:ReskinNavBar()
	if self.navBarStyled then return end

	local homeButton = self.homeButton
	local overflowButton = self.overflowButton

	self:GetRegions():Hide()
	self:DisableDrawLayer("BORDER")
	self.overlay:Hide()
	homeButton:GetRegions():Hide()
	F.Reskin(homeButton)
	F.Reskin(overflowButton, true)

	local tex = overflowButton:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(C.media.arrowLeft)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	overflowButton.bgTex = tex

	overflowButton:HookScript("OnEnter", textureOnEnter)
	overflowButton:HookScript("OnLeave", textureOnLeave)

	self.navBarStyled = true
end

function F:ReskinGarrisonPortrait()
	self.Portrait:ClearAllPoints()
	self.Portrait:SetPoint("TOPLEFT", 4, -4)
	self.Portrait:SetMask("Interface\\Buttons\\WHITE8X8")
	self.PortraitRing:Hide()
	self.PortraitRingQuality:SetTexture("")
	if self.Highlight then self.Highlight:Hide() end

	self.LevelBorder:SetScale(.0001)
	self.Level:ClearAllPoints()
	self.Level:SetPoint("BOTTOM", self, 0, 12)

	self.squareBG = F.CreateBDFrame(self.Portrait, 1)

	if self.PortraitRingCover then
		self.PortraitRingCover:SetColorTexture(0, 0, 0)
		self.PortraitRingCover:SetAllPoints(self.squareBG)
	end

	if self.Empty then
		self.Empty:SetColorTexture(0, 0, 0)
		self.Empty:SetAllPoints(self.Portrait)
	end
end

function F:ReskinIcon()
	self:SetTexCoord(.08, .92, .08, .92)
	return F.CreateBG(self)
end

function F:ReskinMinMax()
	for _, name in next, {"MaximizeButton", "MinimizeButton"} do
		local button = self[name]
		if button then
			button:SetSize(17, 17)
			button:ClearAllPoints()
			button:SetPoint("CENTER", -3, 0)
			F.Reskin(button)

			button.pixels = {}

			local tex = button:CreateTexture()
			tex:SetColorTexture(1, 1, 1)
			tex:SetSize(11, 2)
			tex:SetPoint("CENTER")
			tex:SetRotation(math.rad(45))
			tinsert(button.pixels, tex)

			local hline = button:CreateTexture()
			hline:SetColorTexture(1, 1, 1)
			hline:SetSize(7, 2)
			tinsert(button.pixels, hline)

			local vline = button:CreateTexture()
			vline:SetColorTexture(1, 1, 1)
			vline:SetSize(2, 7)
			tinsert(button.pixels, vline)

			if name == "MaximizeButton" then
				hline:SetPoint("TOPRIGHT", -4, -4)
				vline:SetPoint("TOPRIGHT", -4, -4)
			else
				hline:SetPoint("BOTTOMLEFT", 4, 4)
				vline:SetPoint("BOTTOMLEFT", 4, 4)
			end

			button:SetScript("OnEnter", textureOnEnter)
			button:SetScript("OnLeave", textureOnLeave)
		end
	end
end

function F:AffixesSetup()
	for _, frame in ipairs(self.Affixes) do
		frame.Border:SetTexture(nil)
		frame.Portrait:SetTexture(nil)
		if not frame.bg then
			frame.bg = F.ReskinIcon(frame.Portrait)
		end

		if frame.info then
			frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
		elseif frame.affixID then
			local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
			frame.Portrait:SetTexture(filedataid)
		end
	end
end

function F:StyleSearchButton()
	F.StripTextures(self)
	if self.icon then
		F.ReskinIcon(self.icon)
	end
	F.CreateBD(self, .25)

	self:SetHighlightTexture(C.media.backdrop)
	local hl = self:GetHighlightTexture()
	hl:SetVertexColor(r, g, b, .25)
	hl:SetPoint("TOPLEFT", C.mult, -C.mult)
	hl:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
end

function F:GetRoleTexCoord()
	if self == "TANK" then
		return .32/9.03, 2.04/9.03, 2.65/9.03, 4.3/9.03
	elseif self == "DPS" or self == "DAMAGER" then
		return 2.68/9.03, 4.4/9.03, 2.65/9.03, 4.34/9.03
	elseif self == "HEALER" then
		return 2.68/9.03, 4.4/9.03, .28/9.03, 1.98/9.03
	elseif self == "LEADER" then
		return .32/9.03, 2.04/9.03, .28/9.03, 1.98/9.03
	elseif self == "READY" then
		return 5.1/9.03, 6.76/9.03, .28/9.03, 1.98/9.03
	elseif self == "PENDING" then
		return 5.1/9.03, 6.76/9.03, 2.65/9.03, 4.34/9.03
	elseif self == "REFUSE" then
		return 2.68/9.03, 4.4/9.03, 5.02/9.03, 6.7/9.03
	end
end

function F:ReskinRole(role)
	if self.background then self.background:SetTexture("") end
	local cover = self.cover or self.Cover
	if cover then cover:SetTexture("") end
	local texture = self.GetNormalTexture and self:GetNormalTexture() or self.texture or self.Texture or (self.SetTexture and self) or self.Icon
	if texture then
		texture:SetTexture(C.media.roleIcons)
		texture:SetTexCoord(F.GetRoleTexCoord(role))
	end
	self.bg = F.CreateBDFrame(self)

	local checkButton = self.checkButton or self.CheckButton or self.CheckBox
	if checkButton then
		checkButton:SetFrameLevel(self:GetFrameLevel() + 2)
		checkButton:SetPoint("BOTTOMLEFT", -2, -2)
		F.ReskinCheck(checkButton)
	end

	local shortageBorder = self.shortageBorder
	if shortageBorder then
		shortageBorder:SetTexture("")
		local icon = self.incentiveIcon
		icon:SetPoint("BOTTOMRIGHT")
		icon:SetSize(14, 14)
		icon.texture:SetSize(14, 14)
		F.ReskinIcon(icon.texture)
		icon.border:SetTexture("")
	end
end

-- [[ Variable and module handling ]]

C.themes = {}
C.themes["AuroraClassic"] = {}

-- [[ Initialize addon ]]

local Skin = CreateFrame("Frame")
Skin:RegisterEvent("ADDON_LOADED")
Skin:RegisterEvent("PLAYER_LOGOUT")
Skin:SetScript("OnEvent", function(_, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "AuroraClassic" then
			SetupPixelFix()

			-- [[ Load Variables ]]

			-- remove deprecated or corrupt variables
			for key in pairs(AuroraConfig) do
				if C.defaults[key] == nil then
					AuroraConfig[key] = nil
				end
			end

			-- load or init variables
			for key, value in pairs(C.defaults) do
				if AuroraConfig[key] == nil then
					if type(value) == "table" then
						AuroraConfig[key] = {}
						for k in pairs(value) do
							AuroraConfig[key][k] = value[k]
						end
					else
						AuroraConfig[key] = value
					end
				end
			end

			useButtonGradientColour = AuroraConfig.useButtonGradientColour

			if useButtonGradientColour then
				buttonR, buttonG, buttonB, buttonA = unpack(C.defaults.buttonGradientColour)
			else
				buttonR, buttonG, buttonB, buttonA = unpack(C.defaults.buttonSolidColour)
			end

			if AuroraConfig.useCustomColour then
				r, g, b = AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b
			end

			-- for modules
			C.r, C.g, C.b = r, g, b
		end

		-- [[ Load modules ]]

		-- check if the addon loaded is supported by Aurora, and if it is, execute its module
		local addonModule = C.themes[addon]
		if addonModule then
			if type(addonModule) == "function" then
				addonModule()
			else
				for _, moduleFunc in pairs(addonModule) do
					moduleFunc()
				end
			end
		end
	else
		AuroraConfig.uiScale = UIParent:GetScale()
	end
end)

-- Add APIs
local function WatchPixelSnap(frame, snap)
	if (frame and not frame:IsForbidden()) and frame.PixelSnapDisabled and snap then
		frame.PixelSnapDisabled = nil
	end
end

local function DisablePixelSnap(frame)
	if (frame and not frame:IsForbidden()) and not frame.PixelSnapDisabled then
		if frame.SetSnapToPixelGrid then
			frame:SetSnapToPixelGrid(false)
			frame:SetTexelSnappingBias(0)
		elseif frame.GetStatusBarTexture then
			local texture = frame:GetStatusBarTexture()
			if texture and texture.SetSnapToPixelGrid then
				texture:SetSnapToPixelGrid(false)
				texture:SetTexelSnappingBias(0)
			end
		end

		frame.PixelSnapDisabled = true
	end
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.DisabledPixelSnap then
		if mt.SetSnapToPixelGrid then hooksecurefunc(mt, "SetSnapToPixelGrid", WatchPixelSnap) end
		if mt.SetStatusBarTexture then hooksecurefunc(mt, "SetStatusBarTexture", DisablePixelSnap) end
		if mt.SetColorTexture then hooksecurefunc(mt, "SetColorTexture", DisablePixelSnap) end
		if mt.SetVertexColor then hooksecurefunc(mt, "SetVertexColor", DisablePixelSnap) end
		if mt.CreateTexture then hooksecurefunc(mt, "CreateTexture", DisablePixelSnap) end
		if mt.SetTexCoord then hooksecurefunc(mt, "SetTexCoord", DisablePixelSnap) end
		if mt.SetTexture then hooksecurefunc(mt, "SetTexture", DisablePixelSnap) end
		mt.DisabledPixelSnap = true
	end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateMaskTexture())

object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end