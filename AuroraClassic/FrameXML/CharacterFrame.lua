local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinPortraitFrame(CharacterFrame)
	F.SetBD(CharacterFrame)
	CharacterFrameInset:Hide()
	CharacterFrameInsetRight.Bg:Hide()
	F.RemoveSlice(CharacterFrameInsetRight)

	for i = 1, 3 do
		F.ReskinTab(_G["CharacterFrameTab"..i])
	end
end)