pfUI:RegisterModule("cooldown", function ()

  -- cache values
  local lowcolor    = {strsplit(",", C.appearance.cd.lowcolor)}
  local normalcolor = {strsplit(",", C.appearance.cd.normalcolor)}
  local minutecolor = {strsplit(",", C.appearance.cd.minutecolor)}
  local hourcolor   = {strsplit(",", C.appearance.cd.hourcolor)}
  local daycolor    = {strsplit(",", C.appearance.cd.daycolor)}

  local function pfCooldownOnUpdate()
    if not this:GetParent() then this:Hide()  end

    -- avoid to set cooldowns on invalid frames
    if this:GetParent() and this:GetParent():GetName() and _G[this:GetParent():GetName() .. "Cooldown"] then
      if not _G[this:GetParent():GetName() .. "Cooldown"]:IsShown() then
        this:Hide()
      end
    end

    if not this.next then this.next = GetTime() + .1 end
    if this.next > GetTime() then return end
    this.next = GetTime() + .1

    -- fix own alpha value (should be inherited, but somehow isn't always)
    this:SetAlpha(this:GetParent():GetAlpha())

    local remaining = this.duration - (GetTime() - this.start)
    if remaining >= 0 then
      this.text:SetText(GetColoredTimeString(remaining))
    else
      this:Hide()
    end
  end

  local function pfCreateCoolDown(cooldown, start, duration)
    cooldown.cd = CreateFrame("Frame", "pfCooldownFrame", cooldown:GetParent())
    cooldown.cd:SetAllPoints(cooldown:GetParent())
    cooldown.cd:SetFrameLevel(cooldown.cd:GetFrameLevel() + 1)

    cooldown.cd.text = cooldown.cd:CreateFontString("pfCooldownFrameText", "OVERLAY")
    cooldown.cd.text:SetFont(pfUI.font_unit, C.appearance.cd.font_size, "OUTLINE")
    cooldown.cd.text:SetPoint("CENTER", cooldown.cd, "CENTER", 0, 0)

    cooldown.cd:SetScript("OnUpdate", pfCooldownOnUpdate)
  end

  -- hook
  hooksecurefunc("CooldownFrame_SetTimer", function(this, start, duration, enable)
    -- abort on unknown frames
    if C.appearance.cd.foreign == "0" and not this.pfCooldownType then
      return
    end

    -- realign cooldown frames
    local parent = this.GetParent and this:GetParent()
    if parent and parent:GetWidth() / 36 > 0 then
      this:SetScale(parent:GetWidth() / 36)
      this:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 1)
      this:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 1, -1)
    end

    -- don't draw global cooldowns
    if this.pfCooldownType == "NOGCD" and duration < tonumber(C.appearance.cd.threshold) then
      return
    end

    -- print time as text on cooldown frames
    if start > 0 and duration > 0 and enable > 0 then
      if( not this.cd ) then
        pfCreateCoolDown(this, start, duration)
      end
      this.cd.start = start
      this.cd.duration = duration
      this.cd:Show()
    elseif(this.cd) then
      this.cd:Hide();
    end
  end)
end)
