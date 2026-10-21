local frames = {}
local methods = {}
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:SetSize(w,h) self.width=w self.height=h end
function methods:SetWidth(w) self.width=w end
function methods:GetWidth() return self.width or 100 end
function methods:GetEffectiveScale() return 1 end
function methods:GetBottom() return self.bottom or 200 end
function methods:SetPoint(...) self.point={...} end
function methods:SetValue(v) self.value=v end
function methods:SetText(v) self.text=v end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
local function frame(name)
 local f=setmetatable({scripts={}}, {__index=function(_, k) return methods[k] or function() end end})
 frames[#frames+1]=f
 if name then _G[name]=f end
 return f
end
function CreateFrame(_,name) return frame(name) end
function methods:CreateFontString() local f=frame(); self.label=f; return f end
function GetLocale() return 'deDE' end
function UnitClass() return 'Hunter','HUNTER' end
local exists=true
function UnitExists() return exists end
PetFrame=frame('PetFrame')
PetFrameManaBar=frame('PetFrameManaBar'); PetFrameManaBar.width=71; PetFrameManaBar.bottom=210
local loyalty='Dependable'
C_PetInfo={GetPetLoyalty=function() return loyalty end}
assert(loadfile('LH_PetStats/LH_PetStats.lua'))()
local events=frames[#frames]
events.scripts.OnEvent()
local fill
for _,f in ipairs(frames) do if f.value ~= nil then fill=f end end
assert(LH_PetStatsLoyaltyBar.height==10)
assert(LH_PetStatsLoyaltyBar.width==71)
assert(LH_PetStatsLoyaltyBar.point[5]==-2)
assert(LH_PetStatsFrame.label.text=='4 / 6\n67 %')
assert(math.abs(fill.value-100*4/6)<0.00001)
loyalty='(Loyalty Level 6) Best Friend'; events.scripts.OnEvent()
assert(fill.value==100)
PET_LOYALTY2='Ungebärdig'; loyalty=PET_LOYALTY2; events.scripts.OnEvent()
assert(LH_PetStatsFrame.label.text=='2 / 6\n33 %')
loyalty='Unknown'; events.scripts.OnEvent()
assert(LH_PetStatsFrame.label.text=='? / 6\n-- %')
C_PetInfo.GetPetLoyalty=function() error('unavailable') end; events.scripts.OnEvent()
assert(not LH_PetStatsFrame.shown)
exists=false; events.scripts.OnEvent()
assert(not LH_PetStatsFrame.shown)
print('PASS: ranks, percentages, unknown/error data, pet absence, width, height, alignment')
