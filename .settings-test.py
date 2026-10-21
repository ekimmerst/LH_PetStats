from pathlib import Path
import sys

addon = Path(__file__).resolve().parent
core = addon.parent / 'LH_Tweaks'
sys.path.insert(0, str(core / '.test-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime()
lua.execute('''
frames={};SlashCmdList={};loyalty='Dependable';class='HUNTER';exists=true;reads=0;secret={}
function print() end
function GetLocale() return 'enUS' end
function issecretvalue(value) return value==secret end
function UnitClass() return 'Class',class end
function UnitExists() return exists end
C_PetInfo={GetPetLoyalty=function() reads=reads+1;return loyalty end}
local M={}
function M:SetScript(k,v) self.scripts[k]=v end
function M:RegisterEvent() end
function M:SetSize(w,h) self.width=w;self.height=h end
function M:SetWidth(w) self.width=w end
function M:GetWidth() return self.width or 100 end
function M:GetEffectiveScale() return self.scale or 1 end
function M:GetBottom() return self.bottom or 200 end
function M:SetPoint(...) self.point={...} end
function M:ClearAllPoints() self.point=nil end
function M:SetValue(v) self.value=v end
function M:SetText(v) self.text=v end
function M:SetFont(file,size,flags) self.font={file,size,flags} end
function M:SetFontObject(style) self.fontObject=style;self.shadow=style.shadow;self.offset=style.offset end
function M:SetShadowColor(...) self.shadow={...} end
function M:SetShadowOffset(...) self.offset={...} end
function M:Show() self.shown=true end
function M:Hide() local was=self.shown;self.shown=false;if was and self.scripts.OnHide then self.scripts.OnHide(self) end end
function M:SetShown(v) if v then self:Show() else self:Hide() end end
function M:CreateFontString() local f=CreateFrame('Font',nil,self);self.label=f;return f end
function M:CreateTexture() return CreateFrame('Texture',nil,self) end
setmetatable(M,{__index=function(_,key) if key:match('^%u') then return function() end end end})
function CreateFrame(kind,name,parent)
 local f=setmetatable({kind=kind,scripts={},parent=parent,shown=true},{__index=M});frames[#frames+1]=f
 if name then _G[name]=f end;return f
end
PetFrame=CreateFrame('Frame');PetFrameManaBar=CreateFrame('StatusBar',nil,PetFrame)
PetFrameManaBar.width=71;PetFrameManaBar.bottom=210
GameFontHighlightSmall={GetFont=function() return 'Fallback.ttf',12,'' end,shadow={0,0,0,1},offset={1,-1}}
GameTooltip={}
function GameTooltip:IsOwned(owner) return self.owner==owner end
function GameTooltip:SetOwner(owner) self.owner=owner end
function GameTooltip:SetText(text) self.text=text;self.lines={} end
function GameTooltip:AddLine(text) table.insert(self.lines,text) end
function GameTooltip:Show() self.shown=true end
function GameTooltip:Hide() self.shown=false;self.owner=nil end
registry={};notices={};Settings={}
function Settings.RegisterVerticalLayoutSubcategory(parent,title)
 local c={parent=parent,title=title};function c:GetID() return self.title end
 local l={rows={}};function l:AddInitializer(row) table.insert(self.rows,row) end;c.layout=l;return c,l
end
function Settings.RegisterAddOnCategory(c) registered=c end
function Settings.RegisterProxySetting(c,v,kind,label,default,get,set)
 local s={category=c,default=default,get=get,set=set};registry[v]=s;return s
end
function Settings.CreateCheckbox(c,s,t)
 local row={setting=s,tooltip=t};function row:SetParentInitializer(parent,predicate) self.parent=parent;self.canModify=predicate end
 c.layout:AddInitializer(row);return row
end
function Settings.NotifyUpdate(v) notices[v]=(notices[v] or 0)+1 end
function Settings.OpenToCategory(id) opened=id end
function CreateSettingsListSectionHeaderInitializer(t) return {header=t} end
LH_Tweaks={modules={}}
''')
source = (core / 'LH_Tweaks.lua').read_text()
registration = source.split('function Hub:RegisterModule(id, title, build)')[1].split('\nfunction Hub:RestoreDefaults')[0]
lua.execute('local Hub=LH_Tweaks\nfunction Hub:RegisterModule(id, title, build)' + registration)
source = (core / 'Settings.lua').read_text()
registration = source.split('function Hub:RegisterModulePage(id)')[1].split('\nlocal function RegisterSettings')[0]
lua.execute('local Hub=LH_Tweaks\nfunction Hub:RegisterModulePage(id)' + registration)
lua.execute((addon / 'LH_PetStats.lua').read_text(), 'LH_PetStats')
lua.execute('driver=frames[#frames]')
lua.execute((addon / 'Settings.lua').read_text(), 'LH_PetStats')
lua.execute('''
local function fire(event,name) driver.scripts.OnEvent(driver,event,name) end
fire('ADDON_LOADED','LH_PetStats')
local root,bar=LH_PetStatsFrame,LH_PetStatsLoyaltyBar
local label=root.label
assert(root.shown and label.text=='4 / 6' and not label.text:find('%%'))
assert(bar.width==71 and bar.height==10 and bar.point[5]==-2)
assert(label.font[2]==10 and label.font[3]=='' and label.fontObject==GameFontHighlightSmall)
-- Late tracker loading adopts its exact font flags/shadow at the original pet-text size.
ObjectiveTrackerLineFont={GetFont=function() return 'Tracker.ttf',13,'' end,shadow={0,0,0,.8},offset={.5,-.5}}
fire('ADDON_LOADED','Blizzard_ObjectiveTracker')
assert(label.font[1]=='Tracker.ttf' and label.font[2]==10 and label.font[3]=='')
assert(label.shadow==ObjectiveTrackerLineFont.shadow and label.offset==ObjectiveTrackerLineFont.offset)
LH_Tweaks.category={};LH_Tweaks:RegisterModulePage('LH_PetStats')
local c=registered;assert(c.parent==LH_Tweaks.category and c.title=='LH PetStats')
local enabled,bars,rank=registry.LH_PetStats_enabled,registry.LH_PetStats_showBar,registry.LH_PetStats_showRank
assert(enabled.get() and bars.get() and rank.get() and #c.layout.rows==4)
rank.set(false);assert(bar.shown and not label.shown)
rank.set(true);bar.scripts.OnEnter(bar);assert(GameTooltip.shown)
bars.set(false);assert(not bar.shown and label.shown and not GameTooltip.shown)
enabled.set(false);assert(not root.shown and rank.get() and not bars.get())
local before=reads;driver.scripts.OnUpdate(driver,1);fire('PET_UI_UPDATE');assert(reads==before)
SlashCmdList.LH_PETSTATS(' ON ');assert(root.shown and label.shown and not bar.shown)
assert(notices.LH_PetStats_enabled>0 and c.layout.rows[3].parent==c.layout.rows[2])
bars.set(true);assert(bar.shown)
loyalty='Unknown';fire('PET_UI_UPDATE');assert(label.text=='? / 6' and root.shown)
loyalty='(Loyalty Level 6) Best Friend';fire('PET_UI_UPDATE');assert(label.text=='6 / 6')
loyalty=secret;fire('PET_UI_UPDATE');assert(not root.shown)
loyalty='Dependable';exists=false;fire('UNIT_PET');assert(not root.shown)
exists=true;class='WARLOCK';fire('UNIT_PET');assert(not root.shown)
class='HUNTER';fire('UNIT_PET');assert(root.shown)
GameTooltip:SetOwner({});GameTooltip:Show();bar.scripts.OnLeave();assert(GameTooltip.shown)
SlashCmdList.LH_PETSTATS();assert(opened==c:GetID())
-- Native defaults restore all three settings, while other modules remain intact.
LH_MP5DB={enabled=false};enabled.set(false);bars.set(false);rank.set(false)
for _,s in pairs(registry) do if s.category==c then assert(s.default==true);s.set(s.default) end end
assert(root.shown and bar.shown and label.shown and not LH_MP5DB.enabled)
SlashCmdList.LH_PETSTATS('off');SlashCmdList.LH_PETSTATS('on extra');assert(not enabled.get())
fire('ADDON_LOADED','LH_PetStats');fire('PLAYER_LOGIN');assert(not enabled.get() and not root.shown)
''')
for ext in ('png', 'tga'):
    assert (addon / f'Media/Icon.{ext}').read_bytes() == (core / f'Icon.{ext}').read_bytes()
toc = (addon / 'LH_PetStats.toc').read_text()
assert '## Group: LH_Tweaks' in toc and '## SavedVariablesPerCharacter: LH_PetStatsDB' in toc and 'Settings.lua' in toc
print('PASS: host controls/defaults, saved options, independent bar/rank, removed percentage, tracker font/shadow, tooltips, loyalty/class/pet rules and shared icons')
LuaRuntime().execute((addon / '.verify.lua').read_text())
