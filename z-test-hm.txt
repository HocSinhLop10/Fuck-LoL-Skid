local __DARKLUA_BUNDLE_MODULES __DARKLUA_BUNDLE_MODULES={cache={},load=function(
m)if not __DARKLUA_BUNDLE_MODULES.cache[m]then __DARKLUA_BUNDLE_MODULES.cache[m]
={c=__DARKLUA_BUNDLE_MODULES[m]()}end return __DARKLUA_BUNDLE_MODULES.cache[m].c
end}do function __DARKLUA_BUNDLE_MODULES.a()local freeRunnerThread=nil local
acquireRunnerThreadAndCallEventHandler=function(fn,...)local
acquiredRunnerThread=freeRunnerThread freeRunnerThread=nil fn(...)
freeRunnerThread=acquiredRunnerThread end local runEventHandlerInFreeThread=
function()while true do acquireRunnerThreadAndCallEventHandler(coroutine.yield()
)end end local Connection={}Connection.__index=Connection function Connection.
new(signal,fn)return setmetatable({_connected=true,_signal=signal,_fn=fn,_next=
false},Connection)end function Connection:Disconnect()self._connected=false if
self._signal._handlerListHead==self then self._signal._handlerListHead=self.
_next else local prev=self._signal._handlerListHead while prev and prev._next~=
self do prev=prev._next end if prev then prev._next=self._next end end end
setmetatable(Connection,{__index=function(_,key)error((
'Attempt to get Connection::%s (not a valid member)'):format(tostring(key)),2)
end,__newindex=function(_,key)error((
'Attempt to set Connection::%s (not a valid member)'):format(tostring(key)),2)
end})local Signal={}Signal.__index=Signal function Signal.new()return(
setmetatable({_handlerListHead=false},Signal))end function Signal:Connect(fn)
local connection=Connection.new(self,fn)if self._handlerListHead then connection
._next=self._handlerListHead self._handlerListHead=connection else self.
_handlerListHead=connection end return connection end function Signal:
DisconnectAll()self._handlerListHead=false end function Signal:Fire(...)local
item=self._handlerListHead while item do if item._connected then if not
freeRunnerThread then freeRunnerThread=coroutine.create(
runEventHandlerInFreeThread)coroutine.resume(freeRunnerThread)end task.spawn(
freeRunnerThread,item._fn,...)end item=item._next end end function Signal:Wait()
local waitingCoroutine=coroutine.running()local cn cn=self:Connect(function(...)
cn:Disconnect()task.spawn(waitingCoroutine,...)end)return coroutine.yield()end
function Signal:Once(fn)local cn cn=self:Connect(function(...)if cn._connected
then cn:Disconnect()end fn(...)end)return cn end setmetatable(Signal,{__index=
function(_,key)error(('Attempt to get Signal::%s (not a valid member)'):format(
tostring(key)),2)end,__newindex=function(_,key)error((
'Attempt to set Signal::%s (not a valid member)'):format(tostring(key)),2)end})
return Signal end function __DARKLUA_BUNDLE_MODULES.b()return
__DARKLUA_BUNDLE_MODULES.load('a')end function __DARKLUA_BUNDLE_MODULES.c()local
Maid={}Maid.ClassName='Maid'function Maid.new()return(setmetatable({_tasks={}},
Maid))end function Maid.isMaid(value)return type(value)=='table'and value.
ClassName=='Maid'end function Maid.__index(self,index)if Maid[index]then return
Maid[index]else return self._tasks[index]end end function Maid.__newindex(self,
index,newTask)if Maid[index]~=nil then error(string.format(
"Cannot use '%s' as a Maid key",tostring(index)),2)end local tasks=self._tasks
local job=tasks[index]if job==newTask then return end tasks[index]=newTask if
job then if typeof(job)=='function'then(job)()elseif typeof(job)=='table'then
local destructable=job if type(destructable.Destroy)=='function'then
destructable:Destroy()end elseif typeof(job)=='Instance'then job:Destroy()elseif
typeof(job)=='thread'then local cancelled if coroutine.running()~=job then
cancelled=pcall(function()task.cancel(job)end)end if not cancelled then task.
defer(function()task.cancel(job)end)end elseif typeof(job)==
'RBXScriptConnection'then job:Disconnect()end end end function Maid.Add(self,
task)if not task then error('Task cannot be false or nil',2)end self[#((self.
_tasks))+1]=task if type(task)=='table'and not task.Destroy then warn(
'[Maid.Add] - Gave table task without .Destroy\n\n'..debug.traceback())end
return task end function Maid.GiveTask(self,task)if not task then error(
'Task cannot be false or nil',2)end local taskId=#((self._tasks))+1 self[taskId]
=task if type(task)=='table'and not(task).Destroy then warn(
'[Maid.GiveTask] - Gave table task without .Destroy\n\n'..debug.traceback())end
return taskId end function Maid.GivePromise(self,promise)if not promise:
IsPending()then return promise end local newPromise=promise.resolved(promise)
local id=self:GiveTask(newPromise)newPromise:Finally(function()self[id]=nil end)
return newPromise end function Maid.DoCleaning(self)local tasks=self._tasks for
index,job in tasks do if typeof(job)=='RBXScriptConnection'then tasks[index]=nil
job:Disconnect()end end local index,job=next(tasks)while job~=nil do tasks[index
]=nil if typeof(job)=='function'then(job)()elseif typeof(job)=='table'and type((
job).Destroy)=='function'then(job):Destroy()elseif typeof(job)=='Instance'then
job:Destroy()elseif typeof(job)=='thread'then local cancelled if coroutine.
running()~=job then cancelled=pcall(function()task.cancel(job)end)end if not
cancelled then local toCancel=job task.defer(function()task.cancel(toCancel)end)
end elseif typeof(job)=='RBXScriptConnection'then job:Disconnect()end index,job=
next(tasks)end end Maid.Destroy=Maid.DoCleaning return Maid end function
__DARKLUA_BUNDLE_MODULES.d()return __DARKLUA_BUNDLE_MODULES.load('c')end
function __DARKLUA_BUNDLE_MODULES.e()local InputService=game:GetService(
'UserInputService')local TextService=game:GetService('TextService')local CoreGui
=game:GetService('CoreGui')local Teams=game:GetService('Teams')local Players=
game:GetService('Players')local RunService=game:GetService('RunService')local
TweenService=game:GetService('TweenService')local RenderStepped=RunService.
RenderStepped local LocalPlayer=Players.LocalPlayer local Mouse=LocalPlayer:
GetMouse()local ScreenGui=Instance.new('ScreenGui')ScreenGui.ZIndexBehavior=Enum
.ZIndexBehavior.Global ScreenGui.Parent=CoreGui local Library={Toggles={},
Options={},Registry={},RegistryMap={},HudRegistry={},FontColor=Color3.fromRGB(
255,255,255),MainColor=Color3.fromRGB(28,28,28),BackgroundColor=Color3.fromRGB(
20,20,20),AccentColor=Color3.fromRGB(0,85,255),OutlineColor=Color3.fromRGB(50,50
,50),RiskColor=Color3.fromRGB(255,50,50),Black=Color3.new(0,0,0),Font=Enum.Font.
Code,OpenedFrames={},DependencyBoxes={},Signals={},ScreenGui=ScreenGui}local
RainbowStep=0 local Hue=0 table.insert(Library.Signals,RenderStepped:Connect(
function(Delta)RainbowStep=RainbowStep+Delta if RainbowStep>=(
1.6666666666666665E-2)then RainbowStep=0 Hue=Hue+(2.5E-3)if Hue>1 then Hue=0 end
Library.CurrentRainbowHue=Hue Library.CurrentRainbowColor=Color3.fromHSV(Hue,0.8
,1)end end))local GetPlayersString=function()local PlayerList=Players:
GetPlayers()for i=1,#PlayerList do PlayerList[i]=PlayerList[i].Name end table.
sort(PlayerList,function(str1,str2)return str1<str2 end)return PlayerList end
local GetTeamsString=function()local TeamList=Teams:GetTeams()for i=1,#TeamList
do TeamList[i]=TeamList[i].Name end table.sort(TeamList,function(str1,str2)
return str1<str2 end)return TeamList end function Library:SafeCallback(f,...)if(
not f)then return end if not Library.NotifyOnError then return f(...)end local
success,event=pcall(f,...)if not success then local _,i=event:find(':%d+: ')if
not i then return Library:Notify(event)end return Library:Notify(event:sub(i+1),
3)end end function Library:AttemptSave()if Library.SaveManager then Library.
SaveManager:Save()end end function Library:Create(Class,Properties)local
_Instance=Class if type(Class)=='string'then _Instance=Instance.new(Class)end
for Property,Value in next,Properties do _Instance[Property]=Value end return
_Instance end function Library:ApplyTextStroke(Inst)Inst.TextStrokeTransparency=
1 Library:Create('UIStroke',{Color=Color3.new(0,0,0),Thickness=1,LineJoinMode=
Enum.LineJoinMode.Miter,Parent=Inst})end function Library:CreateLabel(Properties
,IsHud)local _Instance=Library:Create('TextLabel',{BackgroundTransparency=1,Font
=Library.Font,TextColor3=Library.FontColor,TextSize=16,TextStrokeTransparency=0}
)Library:ApplyTextStroke(_Instance)Library:AddToRegistry(_Instance,{TextColor3=
'FontColor'},IsHud)return Library:Create(_Instance,Properties)end function
Library:MakeDraggable(Instance,Cutoff)Instance.Active=true Instance.InputBegan:
Connect(function(Input)if Input.UserInputType==Enum.UserInputType.MouseButton1
then local ObjPos=Vector2.new(Mouse.X-Instance.AbsolutePosition.X,Mouse.Y-
Instance.AbsolutePosition.Y)if ObjPos.Y>(Cutoff or 40)then return end while
InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)do Instance.
Position=UDim2.new(0,Mouse.X-ObjPos.X+(Instance.Size.X.Offset*Instance.
AnchorPoint.X),0,Mouse.Y-ObjPos.Y+(Instance.Size.Y.Offset*Instance.AnchorPoint.Y
))RenderStepped:Wait()end elseif Input.UserInputType==Enum.UserInputType.Touch
then local InputPosition=Input.Position local ObjPos=Vector2.new(InputPosition.X
-Instance.AbsolutePosition.X,InputPosition.Y-Instance.AbsolutePosition.Y)if
ObjPos.Y>(Cutoff or 40)then return end local Connection Connection=InputService.
InputChanged:Connect(function(ChangedInput)if ChangedInput.UserInputType==Enum.
UserInputType.Touch and ChangedInput==Input then local CurrentPosition=
ChangedInput.Position Instance.Position=UDim2.new(0,CurrentPosition.X-ObjPos.X+(
Instance.Size.X.Offset*Instance.AnchorPoint.X),0,CurrentPosition.Y-ObjPos.Y+(
Instance.Size.Y.Offset*Instance.AnchorPoint.Y))end end)local EndConnection
EndConnection=InputService.InputEnded:Connect(function(EndedInput)if EndedInput.
UserInputType==Enum.UserInputType.Touch and EndedInput==Input then Connection:
Disconnect()EndConnection:Disconnect()end end)end end)end function Library:
AddToolTip(InfoStr,HoverInstance)local X,Y=Library:GetTextBounds(InfoStr,Library
.Font,14)local Tooltip=Library:Create('Frame',{BackgroundColor3=Library.
MainColor,BorderColor3=Library.OutlineColor,Size=UDim2.fromOffset(X+5,Y+4),
ZIndex=100,Parent=Library.ScreenGui,Visible=false})local Label=Library:
CreateLabel({Position=UDim2.fromOffset(3,1),Size=UDim2.fromOffset(X,Y),TextSize=
14,Text=InfoStr,TextColor3=Library.FontColor,TextXAlignment=Enum.TextXAlignment.
Left,ZIndex=Tooltip.ZIndex+1,Parent=Tooltip})Library:AddToRegistry(Tooltip,{
BackgroundColor3='MainColor',BorderColor3='OutlineColor'})Library:AddToRegistry(
Label,{TextColor3='FontColor'})local IsHovering=false HoverInstance.MouseEnter:
Connect(function()if Library:MouseIsOverOpenedFrame()then return end IsHovering=
true Tooltip.Position=UDim2.fromOffset(Mouse.X+15,Mouse.Y+12)Tooltip.Visible=
true while IsHovering do RunService.Heartbeat:Wait()Tooltip.Position=UDim2.
fromOffset(Mouse.X+15,Mouse.Y+12)end end)HoverInstance.MouseLeave:Connect(
function()IsHovering=false Tooltip.Visible=false end)end function Library:
OnHighlight(HighlightInstance,Instance,Properties,PropertiesDefault)
HighlightInstance.MouseEnter:Connect(function()local Reg=Library.RegistryMap[
Instance]for Property,ColorIdx in next,Properties do Instance[Property]=Library[
ColorIdx]or ColorIdx if Reg and Reg.Properties[Property]then Reg.Properties[
Property]=ColorIdx end end end)HighlightInstance.MouseLeave:Connect(function()
local Reg=Library.RegistryMap[Instance]for Property,ColorIdx in next,
PropertiesDefault do Instance[Property]=Library[ColorIdx]or ColorIdx if Reg and
Reg.Properties[Property]then Reg.Properties[Property]=ColorIdx end end end)end
function Library:MouseIsOverOpenedFrame()for Frame,_ in next,Library.
OpenedFrames do local AbsPos,AbsSize=Frame.AbsolutePosition,Frame.AbsoluteSize
if Mouse.X>=AbsPos.X and Mouse.X<=AbsPos.X+AbsSize.X and Mouse.Y>=AbsPos.Y and
Mouse.Y<=AbsPos.Y+AbsSize.Y then return true end end end function Library:
IsMouseOverFrame(Frame)local AbsPos,AbsSize=Frame.AbsolutePosition,Frame.
AbsoluteSize if Mouse.X>=AbsPos.X and Mouse.X<=AbsPos.X+AbsSize.X and Mouse.Y>=
AbsPos.Y and Mouse.Y<=AbsPos.Y+AbsSize.Y then return true end end function
Library:UpdateDependencyBoxes()for _,Depbox in next,Library.DependencyBoxes do
Depbox:Update()end end function Library:MapValue(Value,MinA,MaxA,MinB,MaxB)
return(1-((Value-MinA)/(MaxA-MinA)))*MinB+((Value-MinA)/(MaxA-MinA))*MaxB end
function Library:GetTextBounds(Text,Font,Size,Resolution)local Bounds=
TextService:GetTextSize(Text,Size,Font,Resolution or Vector2.new(1920,1080))
return Bounds.X,Bounds.Y end function Library:GetDarkerColor(Color)local H,S,V=
Color3.toHSV(Color)return Color3.fromHSV(H,S,V/1.5)end Library.AccentColorDark=
Library:GetDarkerColor(Library.AccentColor)function Library:AddToRegistry(
Instance,Properties,IsHud)local Idx=#Library.Registry+1 local Data={Instance=
Instance,Properties=Properties,Idx=Idx}table.insert(Library.Registry,Data)
Library.RegistryMap[Instance]=Data if IsHud then table.insert(Library.
HudRegistry,Data)end end function Library:RemoveFromRegistry(Instance)local Data
=Library.RegistryMap[Instance]if Data then for Idx=#Library.Registry,1,-1 do if
Library.Registry[Idx]==Data then table.remove(Library.Registry,Idx)end end for
Idx=#Library.HudRegistry,1,-1 do if Library.HudRegistry[Idx]==Data then table.
remove(Library.HudRegistry,Idx)end end Library.RegistryMap[Instance]=nil end end
function Library:UpdateColorsUsingRegistry()for Idx,Object in next,Library.
Registry do for Property,ColorIdx in next,Object.Properties do if type(ColorIdx)
=='string'then Object.Instance[Property]=Library[ColorIdx]elseif type(ColorIdx)
=='function'then Object.Instance[Property]=ColorIdx()end end end end function
Library:GiveSignal(Signal)table.insert(Library.Signals,Signal)end function
Library:Unload()for Idx=#Library.Signals,1,-1 do local Connection=table.remove(
Library.Signals,Idx)Connection:Disconnect()end if Library.OnUnload then Library.
OnUnload()end ScreenGui:Destroy()end function Library:OnUnload(Callback)Library.
OnUnload=Callback end Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(
function(Instance)if Library.RegistryMap[Instance]then Library:
RemoveFromRegistry(Instance)end end))local BaseAddons={}do local Funcs={}
function Funcs:AddColorPicker(Idx,Info)local ToggleLabel=self.TextLabel assert(
Info.Default,'AddColorPicker: Missing default value.')local ColorPicker={Value=
Info.Default,Transparency=Info.Transparency or 0,Type='ColorPicker',Title=type(
Info.Title)=='string'and Info.Title or'Color picker',Callback=Info.Callback or
function(Color)end}function ColorPicker:SetHSVFromRGB(Color)local H,S,V=Color3.
toHSV(Color)ColorPicker.Hue=H ColorPicker.Sat=S ColorPicker.Vib=V end
ColorPicker:SetHSVFromRGB(ColorPicker.Value)local DisplayFrame=Library:Create(
'Frame',{BackgroundColor3=ColorPicker.Value,BorderColor3=Library:GetDarkerColor(
ColorPicker.Value),BorderMode=Enum.BorderMode.Inset,Size=UDim2.new(0,28,0,14),
ZIndex=6,Parent=ToggleLabel})Library:Create('ImageLabel',{BorderSizePixel=0,Size
=UDim2.new(0,27,0,13),ZIndex=5,Image=
'http://www.roblox.com/asset/?id=12977615774',Visible=not not Info.Transparency,
Parent=DisplayFrame})local PickerFrameOuter=Library:Create('Frame',{Name='Color'
,BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),Position=
UDim2.fromOffset(DisplayFrame.AbsolutePosition.X,DisplayFrame.AbsolutePosition.Y
+18),Size=UDim2.fromOffset(230,Info.Transparency and 271 or 253),Visible=false,
ZIndex=15,Parent=ScreenGui})DisplayFrame:GetPropertyChangedSignal(
'AbsolutePosition'):Connect(function()PickerFrameOuter.Position=UDim2.
fromOffset(DisplayFrame.AbsolutePosition.X,DisplayFrame.AbsolutePosition.Y+18)
end)local PickerFrameInner=Library:Create('Frame',{BackgroundColor3=Library.
BackgroundColor,BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.
Inset,Size=UDim2.new(1,0,1,0),ZIndex=16,Parent=PickerFrameOuter})local Highlight
=Library:Create('Frame',{BackgroundColor3=Library.AccentColor,BorderSizePixel=0,
Size=UDim2.new(1,0,0,2),ZIndex=17,Parent=PickerFrameInner})local SatVibMapOuter=
Library:Create('Frame',{BorderColor3=Color3.new(0,0,0),Position=UDim2.new(0,4,0,
25),Size=UDim2.new(0,200,0,200),ZIndex=17,Parent=PickerFrameInner})local
SatVibMapInner=Library:Create('Frame',{BackgroundColor3=Library.BackgroundColor,
BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.
new(1,0,1,0),ZIndex=18,Parent=SatVibMapOuter})local SatVibMap=Library:Create(
'ImageLabel',{BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=18,Image=
'rbxassetid://4155801252',Parent=SatVibMapInner})local CursorOuter=Library:
Create('ImageLabel',{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0,6,0,6),
BackgroundTransparency=1,Image='http://www.roblox.com/asset/?id=9619665977',
ImageColor3=Color3.new(0,0,0),ZIndex=19,Parent=SatVibMap})Library:Create(
'ImageLabel',{Size=UDim2.new(0,CursorOuter.Size.X.Offset-2,0,CursorOuter.Size.Y.
Offset-2),Position=UDim2.new(0,1,0,1),BackgroundTransparency=1,Image=
'http://www.roblox.com/asset/?id=9619665977',ZIndex=20,Parent=CursorOuter})local
HueSelectorOuter=Library:Create('Frame',{BorderColor3=Color3.new(0,0,0),Position
=UDim2.new(0,208,0,25),Size=UDim2.new(0,15,0,200),ZIndex=17,Parent=
PickerFrameInner})local HueSelectorInner=Library:Create('Frame',{
BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Size=UDim2.new(1,0,1,0),
ZIndex=18,Parent=HueSelectorOuter})local HueCursor=Library:Create('Frame',{
BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0,0.5),BorderColor3=
Color3.new(0,0,0),Size=UDim2.new(1,0,0,1),ZIndex=18,Parent=HueSelectorInner})
local HueBoxOuter=Library:Create('Frame',{BorderColor3=Color3.new(0,0,0),
Position=UDim2.fromOffset(4,228),Size=UDim2.new(0.5,-6,0,20),ZIndex=18,Parent=
PickerFrameInner})local HueBoxInner=Library:Create('Frame',{BackgroundColor3=
Library.MainColor,BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.
Inset,Size=UDim2.new(1,0,1,0),ZIndex=18,Parent=HueBoxOuter})Library:Create(
'UIGradient',{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,
1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}),Rotation=90,
Parent=HueBoxInner})local HueBox=Library:Create('TextBox',{
BackgroundTransparency=1,Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-5,1,0),
Font=Library.Font,PlaceholderColor3=Color3.fromRGB(190,190,190),PlaceholderText=
'Hex color',Text='#FFFFFF',TextColor3=Library.FontColor,TextSize=14,
TextStrokeTransparency=0,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=20,
Parent=HueBoxInner})Library:ApplyTextStroke(HueBox)local RgbBoxBase=Library:
Create(HueBoxOuter:Clone(),{Position=UDim2.new(0.5,2,0,228),Size=UDim2.new(0.5,-
6,0,20),Parent=PickerFrameInner})local RgbBox=Library:Create(RgbBoxBase.Frame:
FindFirstChild('TextBox'),{Text='255, 255, 255',PlaceholderText='RGB color',
TextColor3=Library.FontColor})local TransparencyBoxOuter,TransparencyBoxInner,
TransparencyCursor if Info.Transparency then TransparencyBoxOuter=Library:
Create('Frame',{BorderColor3=Color3.new(0,0,0),Position=UDim2.fromOffset(4,251),
Size=UDim2.new(1,-8,0,15),ZIndex=19,Parent=PickerFrameInner})
TransparencyBoxInner=Library:Create('Frame',{BackgroundColor3=ColorPicker.Value,
BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.
new(1,0,1,0),ZIndex=19,Parent=TransparencyBoxOuter})Library:AddToRegistry(
TransparencyBoxInner,{BorderColor3='OutlineColor'})Library:Create('ImageLabel',{
BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Image=
'http://www.roblox.com/asset/?id=12978095818',ZIndex=20,Parent=
TransparencyBoxInner})TransparencyCursor=Library:Create('Frame',{
BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(0.5,0),BorderColor3=
Color3.new(0,0,0),Size=UDim2.new(0,1,1,0),ZIndex=21,Parent=TransparencyBoxInner}
)end Library:CreateLabel({Size=UDim2.new(1,0,0,14),Position=UDim2.fromOffset(5,5
),TextXAlignment=Enum.TextXAlignment.Left,TextSize=14,Text=ColorPicker.Title,
TextWrapped=false,ZIndex=16,Parent=PickerFrameInner})local ContextMenu={}do
ContextMenu.Options={}ContextMenu.Container=Library:Create('Frame',{BorderColor3
=Color3.new(),ZIndex=14,Visible=false,Parent=ScreenGui})ContextMenu.Inner=
Library:Create('Frame',{BackgroundColor3=Library.BackgroundColor,BorderColor3=
Library.OutlineColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.fromScale(1,1),
ZIndex=15,Parent=ContextMenu.Container})Library:Create('UIListLayout',{Name=
'Layout',FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.
LayoutOrder,Parent=ContextMenu.Inner})Library:Create('UIPadding',{Name='Padding'
,PaddingLeft=UDim.new(0,4),Parent=ContextMenu.Inner})local updateMenuPosition=
function()ContextMenu.Container.Position=UDim2.fromOffset((DisplayFrame.
AbsolutePosition.X+DisplayFrame.AbsoluteSize.X)+4,DisplayFrame.AbsolutePosition.
Y+1)end local updateMenuSize=function()local menuWidth=60 for i,label in next,
ContextMenu.Inner:GetChildren()do if label:IsA('TextLabel')then menuWidth=math.
max(menuWidth,label.TextBounds.X)end end ContextMenu.Container.Size=UDim2.
fromOffset(menuWidth+8,ContextMenu.Inner.Layout.AbsoluteContentSize.Y+4)end
DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(
updateMenuPosition)ContextMenu.Inner.Layout:GetPropertyChangedSignal(
'AbsoluteContentSize'):Connect(updateMenuSize)task.spawn(updateMenuPosition)task
.spawn(updateMenuSize)Library:AddToRegistry(ContextMenu.Inner,{BackgroundColor3=
'BackgroundColor',BorderColor3='OutlineColor'})function ContextMenu:Show()self.
Container.Visible=true end function ContextMenu:Hide()self.Container.Visible=
false end function ContextMenu:AddOption(Str,Callback)if type(Callback)~=
'function'then Callback=function()end end local Button=Library:CreateLabel({
Active=false,Size=UDim2.new(1,0,0,15),TextSize=13,Text=Str,ZIndex=16,Parent=self
.Inner,TextXAlignment=Enum.TextXAlignment.Left})Library:OnHighlight(Button,
Button,{TextColor3='AccentColor'},{TextColor3='FontColor'})Button.InputBegan:
Connect(function(Input)if Input.UserInputType~=Enum.UserInputType.MouseButton1
then return end Callback()end)end ContextMenu:AddOption('Copy color',function()
Library.ColorClipboard=ColorPicker.Value Library:Notify('Copied color!',2)end)
ContextMenu:AddOption('Paste color',function()if not Library.ColorClipboard then
return Library:Notify('You have not copied a color!',2)end ColorPicker:
SetValueRGB(Library.ColorClipboard)end)ContextMenu:AddOption('Copy HEX',function
()pcall(setclipboard,ColorPicker.Value:ToHex())Library:Notify(
'Copied hex code to clipboard!',2)end)ContextMenu:AddOption('Copy RGB',function(
)pcall(setclipboard,table.concat({math.floor(ColorPicker.Value.R*255),math.
floor(ColorPicker.Value.G*255),math.floor(ColorPicker.Value.B*255)},', '))
Library:Notify('Copied RGB values to clipboard!',2)end)end Library:
AddToRegistry(PickerFrameInner,{BackgroundColor3='BackgroundColor',BorderColor3=
'OutlineColor'})Library:AddToRegistry(Highlight,{BackgroundColor3='AccentColor'}
)Library:AddToRegistry(SatVibMapInner,{BackgroundColor3='BackgroundColor',
BorderColor3='OutlineColor'})Library:AddToRegistry(HueBoxInner,{BackgroundColor3
='MainColor',BorderColor3='OutlineColor'})Library:AddToRegistry(RgbBoxBase.Frame
,{BackgroundColor3='MainColor',BorderColor3='OutlineColor'})Library:
AddToRegistry(RgbBox,{TextColor3='FontColor'})Library:AddToRegistry(HueBox,{
TextColor3='FontColor'})local SequenceTable={}for Hue=0,1,0.1 do table.insert(
SequenceTable,ColorSequenceKeypoint.new(Hue,Color3.fromHSV(Hue,1,1)))end Library
:Create('UIGradient',{Color=ColorSequence.new(SequenceTable),Rotation=90,Parent=
HueSelectorInner})HueBox.FocusLost:Connect(function(enter)if enter then local
success,result=pcall(Color3.fromHex,HueBox.Text)if success and typeof(result)==
'Color3'then ColorPicker.Hue,ColorPicker.Sat,ColorPicker.Vib=Color3.toHSV(result
)end end ColorPicker:Display()end)RgbBox.FocusLost:Connect(function(enter)if
enter then local r,g,b=RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')if r and g
and b then ColorPicker.Hue,ColorPicker.Sat,ColorPicker.Vib=Color3.toHSV(Color3.
fromRGB(r,g,b))end end ColorPicker:Display()end)function ColorPicker:Display()
ColorPicker.Value=Color3.fromHSV(ColorPicker.Hue,ColorPicker.Sat,ColorPicker.Vib
)SatVibMap.BackgroundColor3=Color3.fromHSV(ColorPicker.Hue,1,1)Library:Create(
DisplayFrame,{BackgroundColor3=ColorPicker.Value,BackgroundTransparency=
ColorPicker.Transparency,BorderColor3=Library:GetDarkerColor(ColorPicker.Value)}
)if TransparencyBoxInner then TransparencyBoxInner.BackgroundColor3=ColorPicker.
Value TransparencyCursor.Position=UDim2.new(1-ColorPicker.Transparency,0,0,0)end
CursorOuter.Position=UDim2.new(ColorPicker.Sat,0,1-ColorPicker.Vib,0)HueCursor.
Position=UDim2.new(0,0,ColorPicker.Hue,0)HueBox.Text='#'..ColorPicker.Value:
ToHex()RgbBox.Text=table.concat({math.floor(ColorPicker.Value.R*255),math.floor(
ColorPicker.Value.G*255),math.floor(ColorPicker.Value.B*255)},', ')Library:
SafeCallback(ColorPicker.Callback,ColorPicker.Value)Library:SafeCallback(
ColorPicker.Changed,ColorPicker.Value)end function ColorPicker:OnChanged(Func)
ColorPicker.Changed=Func Func(ColorPicker.Value)end function ColorPicker:Show()
for Frame,Val in next,Library.OpenedFrames do if Frame.Name=='Color'then Frame.
Visible=false Library.OpenedFrames[Frame]=nil end end PickerFrameOuter.Visible=
true Library.OpenedFrames[PickerFrameOuter]=true end function ColorPicker:Hide()
PickerFrameOuter.Visible=false Library.OpenedFrames[PickerFrameOuter]=nil end
function ColorPicker:SetValue(HSV,Transparency)local Color=Color3.fromHSV(HSV[1]
,HSV[2],HSV[3])ColorPicker.Transparency=Transparency or 0 ColorPicker:
SetHSVFromRGB(Color)ColorPicker:Display()end function ColorPicker:SetValueRGB(
Color,Transparency)ColorPicker.Transparency=Transparency or 0 ColorPicker:
SetHSVFromRGB(Color)ColorPicker:Display()end SatVibMap.InputBegan:Connect(
function(Input)if Input.UserInputType==Enum.UserInputType.MouseButton1 then
while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)do local
MinX=SatVibMap.AbsolutePosition.X local MaxX=MinX+SatVibMap.AbsoluteSize.X local
MouseX=math.clamp(Mouse.X,MinX,MaxX)local MinY=SatVibMap.AbsolutePosition.Y
local MaxY=MinY+SatVibMap.AbsoluteSize.Y local MouseY=math.clamp(Mouse.Y,MinY,
MaxY)ColorPicker.Sat=(MouseX-MinX)/(MaxX-MinX)ColorPicker.Vib=1-((MouseY-MinY)/(
MaxY-MinY))ColorPicker:Display()RenderStepped:Wait()end Library:AttemptSave()end
end)HueSelectorInner.InputBegan:Connect(function(Input)if Input.UserInputType==
Enum.UserInputType.MouseButton1 then while InputService:IsMouseButtonPressed(
Enum.UserInputType.MouseButton1)do local MinY=HueSelectorInner.AbsolutePosition.
Y local MaxY=MinY+HueSelectorInner.AbsoluteSize.Y local MouseY=math.clamp(Mouse.
Y,MinY,MaxY)ColorPicker.Hue=((MouseY-MinY)/(MaxY-MinY))ColorPicker:Display()
RenderStepped:Wait()end Library:AttemptSave()end end)DisplayFrame.InputBegan:
Connect(function(Input)if Input.UserInputType==Enum.UserInputType.MouseButton1
and not Library:MouseIsOverOpenedFrame()then if PickerFrameOuter.Visible then
ColorPicker:Hide()else ContextMenu:Hide()ColorPicker:Show()end elseif Input.
UserInputType==Enum.UserInputType.MouseButton2 and not Library:
MouseIsOverOpenedFrame()then ContextMenu:Show()ColorPicker:Hide()end end)if
TransparencyBoxInner then TransparencyBoxInner.InputBegan:Connect(function(Input
)if Input.UserInputType==Enum.UserInputType.MouseButton1 then while InputService
:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)do local MinX=
TransparencyBoxInner.AbsolutePosition.X local MaxX=MinX+TransparencyBoxInner.
AbsoluteSize.X local MouseX=math.clamp(Mouse.X,MinX,MaxX)ColorPicker.
Transparency=1-((MouseX-MinX)/(MaxX-MinX))ColorPicker:Display()RenderStepped:
Wait()end Library:AttemptSave()end end)end Library:GiveSignal(InputService.
InputBegan:Connect(function(Input)if Input.UserInputType==Enum.UserInputType.
MouseButton1 then local AbsPos,AbsSize=PickerFrameOuter.AbsolutePosition,
PickerFrameOuter.AbsoluteSize if Mouse.X<AbsPos.X or Mouse.X>AbsPos.X+AbsSize.X
or Mouse.Y<(AbsPos.Y-20-1)or Mouse.Y>AbsPos.Y+AbsSize.Y then ColorPicker:Hide()
end if not Library:IsMouseOverFrame(ContextMenu.Container)then ContextMenu:Hide(
)end end if Input.UserInputType==Enum.UserInputType.MouseButton2 and ContextMenu
.Container.Visible then if not Library:IsMouseOverFrame(ContextMenu.Container)
and not Library:IsMouseOverFrame(DisplayFrame)then ContextMenu:Hide()end end end
))ColorPicker:Display()ColorPicker.DisplayFrame=DisplayFrame Library.Options[Idx
]=ColorPicker return self end function Funcs:AddKeyPicker(Idx,Info)local
ParentObj=self local ToggleLabel=self.TextLabel local _=self.Container assert(
Info.Default,'AddKeyPicker: Missing default value.')local KeyPicker={Value=Info.
Default,Toggled=false,Mode=Info.Mode or'Toggle',Type='KeyPicker',Callback=Info.
Callback or function(Value)end,ChangedCallback=Info.ChangedCallback or function(
New)end,SyncToggleState=Info.SyncToggleState or false}if KeyPicker.
SyncToggleState then Info.Modes={'Toggle'}Info.Mode='Toggle'end local PickOuter=
Library:Create('Frame',{BackgroundColor3=Color3.new(0,0,0),BorderColor3=Color3.
new(0,0,0),Size=UDim2.new(0,28,0,15),ZIndex=6,Parent=ToggleLabel})local
PickInner=Library:Create('Frame',{BackgroundColor3=Library.BackgroundColor,
BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.
new(1,0,1,0),ZIndex=7,Parent=PickOuter})Library:AddToRegistry(PickInner,{
BackgroundColor3='BackgroundColor',BorderColor3='OutlineColor'})local
DisplayLabel=Library:CreateLabel({Size=UDim2.new(1,0,1,0),TextSize=13,Text=Info.
Default,TextWrapped=true,ZIndex=8,Parent=PickInner})local ModeSelectOuter=
Library:Create('Frame',{BorderColor3=Color3.new(0,0,0),Position=UDim2.
fromOffset(ToggleLabel.AbsolutePosition.X+ToggleLabel.AbsoluteSize.X+4,
ToggleLabel.AbsolutePosition.Y+1),Size=UDim2.new(0,60,0,47),Visible=false,ZIndex
=14,Parent=ScreenGui})ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):
Connect(function()ModeSelectOuter.Position=UDim2.fromOffset(ToggleLabel.
AbsolutePosition.X+ToggleLabel.AbsoluteSize.X+4,ToggleLabel.AbsolutePosition.Y+1
)end)local ModeSelectInner=Library:Create('Frame',{BackgroundColor3=Library.
BackgroundColor,BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.
Inset,Size=UDim2.new(1,0,1,0),ZIndex=15,Parent=ModeSelectOuter})Library:
AddToRegistry(ModeSelectInner,{BackgroundColor3='BackgroundColor',BorderColor3=
'OutlineColor'})Library:Create('UIListLayout',{FillDirection=Enum.FillDirection.
Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Parent=ModeSelectInner})local
ContainerLabel=Library:CreateLabel({TextXAlignment=Enum.TextXAlignment.Left,Size
=UDim2.new(1,0,0,18),TextSize=13,Visible=false,ZIndex=110,Parent=Library.
KeybindContainer},true)local Modes=Info.Modes or{'Always','Toggle','Hold'}local
ModeButtons={}for Idx,Mode in next,Modes do local ModeButton={}local Label=
Library:CreateLabel({Active=false,Size=UDim2.new(1,0,0,15),TextSize=13,Text=Mode
,ZIndex=16,Parent=ModeSelectInner})function ModeButton:Select()for _,Button in
next,ModeButtons do Button:Deselect()end KeyPicker.Mode=Mode Label.TextColor3=
Library.AccentColor Library.RegistryMap[Label].Properties.TextColor3=
'AccentColor'ModeSelectOuter.Visible=false end function ModeButton:Deselect()
KeyPicker.Mode=nil Label.TextColor3=Library.FontColor Library.RegistryMap[Label]
.Properties.TextColor3='FontColor'end Label.InputBegan:Connect(function(Input)if
Input.UserInputType==Enum.UserInputType.MouseButton1 then ModeButton:Select()
Library:AttemptSave()end end)if Mode==KeyPicker.Mode then ModeButton:Select()end
ModeButtons[Mode]=ModeButton end function KeyPicker:Update()if Info.NoUI then
return end local State=KeyPicker:GetState()ContainerLabel.Text=string.format(
'[%s] %s (%s)',KeyPicker.Value,Info.Text,KeyPicker.Mode)ContainerLabel.Visible=
true ContainerLabel.TextColor3=State and Library.AccentColor or Library.
FontColor Library.RegistryMap[ContainerLabel].Properties.TextColor3=State and
'AccentColor'or'FontColor'local YSize=0 local XSize=0 for _,Label in next,
Library.KeybindContainer:GetChildren()do if Label:IsA('TextLabel')and Label.
Visible then YSize=YSize+18 if(Label.TextBounds.X>XSize)then XSize=Label.
TextBounds.X end end end Library.KeybindFrame.Size=UDim2.new(0,math.max(XSize+10
,210),0,YSize+23)end function KeyPicker:GetState()if KeyPicker.Mode=='Always'
then return true elseif KeyPicker.Mode=='Hold'then if KeyPicker.Value=='None'
then return false end local Key=KeyPicker.Value if Key=='MB1'or Key=='MB2'then
return Key=='MB1'and InputService:IsMouseButtonPressed(Enum.UserInputType.
MouseButton1)or Key=='MB2'and InputService:IsMouseButtonPressed(Enum.
UserInputType.MouseButton2)else return InputService:IsKeyDown(Enum.KeyCode[
KeyPicker.Value])end else return KeyPicker.Toggled end end function KeyPicker:
SetValue(Data)local Key,Mode=Data[1],Data[2]DisplayLabel.Text=Key KeyPicker.
Value=Key ModeButtons[Mode]:Select()KeyPicker:Update()end function KeyPicker:
OnClick(Callback)KeyPicker.Clicked=Callback end function KeyPicker:OnChanged(
Callback)KeyPicker.Changed=Callback Callback(KeyPicker.Value)end if ParentObj.
Addons then table.insert(ParentObj.Addons,KeyPicker)end function KeyPicker:
DoClick()if ParentObj.Type=='Toggle'and KeyPicker.SyncToggleState then ParentObj
:SetValue(not ParentObj.Value)end Library:SafeCallback(KeyPicker.Callback,
KeyPicker.Toggled)Library:SafeCallback(KeyPicker.Clicked,KeyPicker.Toggled)end
local Picking=false PickOuter.InputBegan:Connect(function(Input)if Input.
UserInputType==Enum.UserInputType.MouseButton1 and not Library:
MouseIsOverOpenedFrame()then Picking=true DisplayLabel.Text=''local Break local
Text=''task.spawn(function()while(not Break)do if Text=='...'then Text=''end
Text=Text..'.'DisplayLabel.Text=Text wait(0.4)end end)wait(0.2)local Event Event
=InputService.InputBegan:Connect(function(Input)local Key if Input.UserInputType
==Enum.UserInputType.Keyboard then Key=Input.KeyCode.Name elseif Input.
UserInputType==Enum.UserInputType.MouseButton1 then Key='MB1'elseif Input.
UserInputType==Enum.UserInputType.MouseButton2 then Key='MB2'end Break=true
Picking=false DisplayLabel.Text=Key KeyPicker.Value=Key Library:SafeCallback(
KeyPicker.ChangedCallback,Input.KeyCode or Input.UserInputType)Library:
SafeCallback(KeyPicker.Changed,Input.KeyCode or Input.UserInputType)Library:
AttemptSave()Event:Disconnect()end)elseif Input.UserInputType==Enum.
UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame()then
ModeSelectOuter.Visible=true end end)Library:GiveSignal(InputService.InputBegan:
Connect(function(Input)if(not Picking)then if KeyPicker.Mode=='Toggle'then local
Key=KeyPicker.Value if Key=='MB1'or Key=='MB2'then if Key=='MB1'and Input.
UserInputType==Enum.UserInputType.MouseButton1 or Key=='MB2'and Input.
UserInputType==Enum.UserInputType.MouseButton2 then KeyPicker.Toggled=not
KeyPicker.Toggled KeyPicker:DoClick()end elseif Input.UserInputType==Enum.
UserInputType.Keyboard then if Input.KeyCode.Name==Key then KeyPicker.Toggled=
not KeyPicker.Toggled KeyPicker:DoClick()end end end KeyPicker:Update()end if
Input.UserInputType==Enum.UserInputType.MouseButton1 then local AbsPos,AbsSize=
ModeSelectOuter.AbsolutePosition,ModeSelectOuter.AbsoluteSize if Mouse.X<AbsPos.
X or Mouse.X>AbsPos.X+AbsSize.X or Mouse.Y<(AbsPos.Y-20-1)or Mouse.Y>AbsPos.Y+
AbsSize.Y then ModeSelectOuter.Visible=false end end end))Library:GiveSignal(
InputService.InputEnded:Connect(function(Input)if(not Picking)then KeyPicker:
Update()end end))KeyPicker:Update()Library.Options[Idx]=KeyPicker return self
end BaseAddons.__index=Funcs BaseAddons.__namecall=function(Table,Key,...)return
Funcs[Key](...)end end local BaseGroupbox={}do local Funcs={}function Funcs:
AddBlank(Size)local Groupbox=self local Container=Groupbox.Container Library:
Create('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,Size),ZIndex=1,
Parent=Container})end function Funcs:AddLabel(Text,DoesWrap)local Label={}local
Groupbox=self local Container=Groupbox.Container local TextLabel=Library:
CreateLabel({Size=UDim2.new(1,-4,0,15),TextSize=14,Text=Text,TextWrapped=
DoesWrap or false,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=
Container})if DoesWrap then local Y=select(2,Library:GetTextBounds(Text,Library.
Font,14,Vector2.new(TextLabel.AbsoluteSize.X,math.huge)))TextLabel.Size=UDim2.
new(1,-4,0,Y)else Library:Create('UIListLayout',{Padding=UDim.new(0,4),
FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.
HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder,Parent=TextLabel}
)end Label.TextLabel=TextLabel Label.Container=Container function Label:SetText(
Text)TextLabel.Text=Text if DoesWrap then local Y=select(2,Library:
GetTextBounds(Text,Library.Font,14,Vector2.new(TextLabel.AbsoluteSize.X,math.
huge)))TextLabel.Size=UDim2.new(1,-4,0,Y)end Groupbox:Resize()end if(not
DoesWrap)then setmetatable(Label,BaseAddons)end Groupbox:AddBlank(5)Groupbox:
Resize()return Label end function Funcs:AddButton(...)local Button={}local
ProcessButtonParams=function(Class,Obj,...)local Props=select(1,...)if type(
Props)=='table'then Obj.Text=Props.Text Obj.Func=Props.Func Obj.DoubleClick=
Props.DoubleClick Obj.Tooltip=Props.Tooltip else Obj.Text=select(1,...)Obj.Func=
select(2,...)end assert(type(Obj.Func)=='function',
'AddButton: `Func` callback is missing.')end ProcessButtonParams('Button',Button
,...)local Groupbox=self local Container=Groupbox.Container local
CreateBaseButton=function(Button)local Outer=Library:Create('Frame',{
BackgroundColor3=Color3.new(0,0,0),BorderColor3=Color3.new(0,0,0),Size=UDim2.
new(1,-4,0,20),ZIndex=5})local Inner=Library:Create('Frame',{BackgroundColor3=
Library.MainColor,BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.
Inset,Size=UDim2.new(1,0,1,0),ZIndex=6,Parent=Outer})local Label=Library:
CreateLabel({Size=UDim2.new(1,0,1,0),TextSize=14,Text=Button.Text,ZIndex=6,
Parent=Inner})Library:Create('UIGradient',{Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,
Color3.fromRGB(212,212,212))}),Rotation=90,Parent=Inner})Library:AddToRegistry(
Outer,{BorderColor3='Black'})Library:AddToRegistry(Inner,{BackgroundColor3=
'MainColor',BorderColor3='OutlineColor'})Library:OnHighlight(Outer,Outer,{
BorderColor3='AccentColor'},{BorderColor3='Black'})return Outer,Inner,Label end
local InitEvents=function(Button)local WaitForEvent=function(event,timeout,
validator)local bindable=Instance.new('BindableEvent')local connection=event:
Once(function(...)if type(validator)=='function'and validator(...)then bindable:
Fire(true)else bindable:Fire(false)end end)task.delay(timeout,function()
connection:disconnect()bindable:Fire(false)end)return bindable.Event:Wait()end
local ValidateClick=function(Input)if Library:MouseIsOverOpenedFrame()then
return false end if Input.UserInputType~=Enum.UserInputType.MouseButton1 and
Input.UserInputType~=Enum.UserInputType.Touch then return false end return true
end Button.Outer.InputBegan:Connect(function(Input)if not ValidateClick(Input)
then return end if Button.Locked then return end if Button.DoubleClick then
Library:RemoveFromRegistry(Button.Label)Library:AddToRegistry(Button.Label,{
TextColor3='AccentColor'})Button.Label.TextColor3=Library.AccentColor Button.
Label.Text='Are you sure?'Button.Locked=true local clicked=WaitForEvent(Button.
Outer.InputBegan,0.5,ValidateClick)Library:RemoveFromRegistry(Button.Label)
Library:AddToRegistry(Button.Label,{TextColor3='FontColor'})Button.Label.
TextColor3=Library.FontColor Button.Label.Text=Button.Text task.defer(rawset,
Button,'Locked',false)if clicked then Library:SafeCallback(Button.Func)end
return end Library:SafeCallback(Button.Func)end)end Button.Outer,Button.Inner,
Button.Label=CreateBaseButton(Button)Button.Outer.Parent=Container InitEvents(
Button)function Button:AddTooltip(tooltip)if type(tooltip)=='string'then Library
:AddToolTip(tooltip,self.Outer)end return self end function Button:AddButton(...
)local SubButton={}ProcessButtonParams('SubButton',SubButton,...)self.Outer.Size
=UDim2.new(0.5,-2,0,20)SubButton.Outer,SubButton.Inner,SubButton.Label=
CreateBaseButton(SubButton)SubButton.Outer.Position=UDim2.new(1,3,0,0)SubButton.
Outer.Size=UDim2.fromOffset(self.Outer.AbsoluteSize.X-2,self.Outer.AbsoluteSize.
Y)SubButton.Outer.Parent=self.Outer function SubButton:AddTooltip(tooltip)if
type(tooltip)=='string'then Library:AddToolTip(tooltip,self.Outer)end return
SubButton end if type(SubButton.Tooltip)=='string'then SubButton:AddTooltip(
SubButton.Tooltip)end InitEvents(SubButton)return SubButton end if type(Button.
Tooltip)=='string'then Button:AddTooltip(Button.Tooltip)end Groupbox:AddBlank(5)
Groupbox:Resize()return Button end function Funcs:AddDivider()local Groupbox=
self local Container=self.Container Groupbox:AddBlank(2)local DividerOuter=
Library:Create('Frame',{BackgroundColor3=Color3.new(0,0,0),BorderColor3=Color3.
new(0,0,0),Size=UDim2.new(1,-4,0,5),ZIndex=5,Parent=Container})local
DividerInner=Library:Create('Frame',{BackgroundColor3=Library.MainColor,
BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.
new(1,0,1,0),ZIndex=6,Parent=DividerOuter})Library:AddToRegistry(DividerOuter,{
BorderColor3='Black'})Library:AddToRegistry(DividerInner,{BackgroundColor3=
'MainColor',BorderColor3='OutlineColor'})Groupbox:AddBlank(9)Groupbox:Resize()
end function Funcs:AddInput(Idx,Info)assert(Info.Text,
'AddInput: Missing `Text` string.')local Textbox={Value=Info.Default or'',
Numeric=Info.Numeric or false,Finished=Info.Finished or false,Type='Input',
Callback=Info.Callback or function(Value)end}local Groupbox=self local Container
=Groupbox.Container Library:CreateLabel({Size=UDim2.new(1,0,0,15),TextSize=14,
Text=Info.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=Container
})Groupbox:AddBlank(1)local TextBoxOuter=Library:Create('Frame',{
BackgroundColor3=Color3.new(0,0,0),BorderColor3=Color3.new(0,0,0),Size=UDim2.
new(1,-4,0,20),ZIndex=5,Parent=Container})local TextBoxInner=Library:Create(
'Frame',{BackgroundColor3=Library.MainColor,BorderColor3=Library.OutlineColor,
BorderMode=Enum.BorderMode.Inset,Size=UDim2.new(1,0,1,0),ZIndex=6,Parent=
TextBoxOuter})Library:AddToRegistry(TextBoxInner,{BackgroundColor3='MainColor',
BorderColor3='OutlineColor'})Library:OnHighlight(TextBoxOuter,TextBoxOuter,{
BorderColor3='AccentColor'},{BorderColor3='Black'})if type(Info.Tooltip)==
'string'then Library:AddToolTip(Info.Tooltip,TextBoxOuter)end Library:Create(
'UIGradient',{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,
1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}),Rotation=90,
Parent=TextBoxInner})local Container=Library:Create('Frame',{
BackgroundTransparency=1,ClipsDescendants=true,Position=UDim2.new(0,5,0,0),Size=
UDim2.new(1,-5,1,0),ZIndex=7,Parent=TextBoxInner})local Box=Library:Create(
'TextBox',{BackgroundTransparency=1,Position=UDim2.fromOffset(0,0),Size=UDim2.
fromScale(5,1),Font=Library.Font,PlaceholderColor3=Color3.fromRGB(190,190,190),
PlaceholderText=Info.Placeholder or'',Text=Info.Default or'',TextColor3=Library.
FontColor,TextSize=14,TextStrokeTransparency=0,TextXAlignment=Enum.
TextXAlignment.Left,ZIndex=7,Parent=Container})Library:ApplyTextStroke(Box)
function Textbox:SetValue(Text)if Info.MaxLength and#Text>Info.MaxLength then
Text=Text:sub(1,Info.MaxLength)end if Textbox.Numeric then if(not tonumber(Text)
)and Text:len()>0 then Text=Textbox.Value end end Textbox.Value=Text Box.Text=
Text Library:SafeCallback(Textbox.Callback,Textbox.Value)Library:SafeCallback(
Textbox.Changed,Textbox.Value)end if Textbox.Finished then Box.FocusLost:
Connect(function(enter)if not enter then return end Textbox:SetValue(Box.Text)
Library:AttemptSave()end)else Box:GetPropertyChangedSignal('Text'):Connect(
function()Textbox:SetValue(Box.Text)Library:AttemptSave()end)end local Update=
function()local PADDING=2 local reveal=Container.AbsoluteSize.X if not Box:
IsFocused()or Box.TextBounds.X<=reveal-2*PADDING then Box.Position=UDim2.new(0,
PADDING,0,0)else local cursor=Box.CursorPosition if cursor~=-1 then local
subtext=string.sub(Box.Text,1,cursor-1)local width=TextService:GetTextSize(
subtext,Box.TextSize,Box.Font,Vector2.new(math.huge,math.huge)).X local
currentCursorPos=Box.Position.X.Offset+width if currentCursorPos<PADDING then
Box.Position=UDim2.fromOffset(PADDING-width,0)elseif currentCursorPos>reveal-
PADDING-1 then Box.Position=UDim2.fromOffset(reveal-width-PADDING-1,0)end end
end end task.spawn(Update)Box:GetPropertyChangedSignal('Text'):Connect(Update)
Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)Box.FocusLost:
Connect(Update)Box.Focused:Connect(Update)Library:AddToRegistry(Box,{TextColor3=
'FontColor'})function Textbox:OnChanged(Func)Textbox.Changed=Func Func(Textbox.
Value)end Groupbox:AddBlank(5)Groupbox:Resize()Library.Options[Idx]=Textbox
return Textbox end function Funcs:AddToggle(Idx,Info)assert(Info.Text,
'AddInput: Missing `Text` string.')local Toggle={Value=Info.Default or false,
Type='Toggle',Callback=Info.Callback or function(Value)end,Addons={},Risky=Info.
Risky}local Groupbox=self local Container=Groupbox.Container local ToggleOuter=
Library:Create('Frame',{BackgroundColor3=Color3.new(0,0,0),BorderColor3=Color3.
new(0,0,0),Size=UDim2.new(0,13,0,13),ZIndex=5,Parent=Container})Library:
AddToRegistry(ToggleOuter,{BorderColor3='Black'})local ToggleInner=Library:
Create('Frame',{BackgroundColor3=Library.MainColor,BorderColor3=Library.
OutlineColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.new(1,0,1,0),ZIndex=6,
Parent=ToggleOuter})Library:AddToRegistry(ToggleInner,{BackgroundColor3=
'MainColor',BorderColor3='OutlineColor'})local ToggleLabel=Library:CreateLabel({
Size=UDim2.new(0,216,1,0),Position=UDim2.new(1,6,0,0),TextSize=14,Text=Info.Text
,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,Parent=ToggleInner})Library:
Create('UIListLayout',{Padding=UDim.new(0,4),FillDirection=Enum.FillDirection.
Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.
SortOrder.LayoutOrder,Parent=ToggleLabel})local ToggleRegion=Library:Create(
'Frame',{BackgroundTransparency=1,Size=UDim2.new(0,170,1,0),ZIndex=8,Parent=
ToggleOuter})Library:OnHighlight(ToggleRegion,ToggleOuter,{BorderColor3=
'AccentColor'},{BorderColor3='Black'})function Toggle:UpdateColors()Toggle:
Display()end if type(Info.Tooltip)=='string'then Library:AddToolTip(Info.Tooltip
,ToggleRegion)end function Toggle:Display()ToggleInner.BackgroundColor3=Toggle.
Value and Library.AccentColor or Library.MainColor ToggleInner.BorderColor3=
Toggle.Value and Library.AccentColorDark or Library.OutlineColor Library.
RegistryMap[ToggleInner].Properties.BackgroundColor3=Toggle.Value and
'AccentColor'or'MainColor'Library.RegistryMap[ToggleInner].Properties.
BorderColor3=Toggle.Value and'AccentColorDark'or'OutlineColor'end function
Toggle:OnChanged(Func)Toggle.Changed=Func Func(Toggle.Value)end function Toggle:
SetValue(Bool)Bool=(not not Bool)Toggle.Value=Bool Toggle:Display()for _,Addon
in next,Toggle.Addons do if Addon.Type=='KeyPicker'and Addon.SyncToggleState
then Addon.Toggled=Bool Addon:Update()end end Library:SafeCallback(Toggle.
Callback,Toggle.Value)Library:SafeCallback(Toggle.Changed,Toggle.Value)Library:
UpdateDependencyBoxes()end ToggleRegion.InputBegan:Connect(function(Input)if(
Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==
Enum.UserInputType.Touch)and not Library:MouseIsOverOpenedFrame()then Toggle:
SetValue(not Toggle.Value)Library:AttemptSave()end end)if Toggle.Risky then
Library:RemoveFromRegistry(ToggleLabel)ToggleLabel.TextColor3=Library.RiskColor
Library:AddToRegistry(ToggleLabel,{TextColor3='RiskColor'})end Toggle:Display()
Groupbox:AddBlank(Info.BlankSize or 7)Groupbox:Resize()Toggle.TextLabel=
ToggleLabel Toggle.Container=Container setmetatable(Toggle,BaseAddons)Library.
Toggles[Idx]=Toggle Library:UpdateDependencyBoxes()return Toggle end function
Funcs:AddSlider(Idx,Info)assert(Info.Default,'AddSlider: Missing default value.'
)assert(Info.Text,'AddSlider: Missing slider text.')assert(Info.Min,
'AddSlider: Missing minimum value.')assert(Info.Max,
'AddSlider: Missing maximum value.')assert(Info.Rounding,
'AddSlider: Missing rounding value.')local Slider={Value=Info.Default,Min=Info.
Min,Max=Info.Max,Rounding=Info.Rounding,MaxSize=232,Type='Slider',Callback=Info.
Callback or function(Value)end}local Groupbox=self local Container=Groupbox.
Container if not Info.Compact then Library:CreateLabel({Size=UDim2.new(1,0,0,10)
,TextSize=14,Text=Info.Text,TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Bottom,ZIndex=5,Parent=Container})Groupbox:
AddBlank(3)end local SliderOuter=Library:Create('Frame',{BackgroundColor3=Color3
.new(0,0,0),BorderColor3=Color3.new(0,0,0),Size=UDim2.new(1,-4,0,13),ZIndex=5,
Parent=Container})Library:AddToRegistry(SliderOuter,{BorderColor3='Black'})local
SliderInner=Library:Create('Frame',{BackgroundColor3=Library.MainColor,
BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.
new(1,0,1,0),ZIndex=6,Parent=SliderOuter})Library:AddToRegistry(SliderInner,{
BackgroundColor3='MainColor',BorderColor3='OutlineColor'})local Fill=Library:
Create('Frame',{BackgroundColor3=Library.AccentColor,BorderColor3=Library.
AccentColorDark,Size=UDim2.new(0,0,1,0),ZIndex=7,Parent=SliderInner})Library:
AddToRegistry(Fill,{BackgroundColor3='AccentColor',BorderColor3=
'AccentColorDark'})local HideBorderRight=Library:Create('Frame',{
BackgroundColor3=Library.AccentColor,BorderSizePixel=0,Position=UDim2.new(1,0,0,
0),Size=UDim2.new(0,1,1,0),ZIndex=8,Parent=Fill})Library:AddToRegistry(
HideBorderRight,{BackgroundColor3='AccentColor'})local DisplayLabel=Library:
CreateLabel({Size=UDim2.new(1,0,1,0),TextSize=14,Text='Infinite',ZIndex=9,Parent
=SliderInner})Library:OnHighlight(SliderOuter,SliderOuter,{BorderColor3=
'AccentColor'},{BorderColor3='Black'})if type(Info.Tooltip)=='string'then
Library:AddToolTip(Info.Tooltip,SliderOuter)end function Slider:UpdateColors()
Fill.BackgroundColor3=Library.AccentColor Fill.BorderColor3=Library.
AccentColorDark end function Slider:Display()local Suffix=Info.Suffix or''if
Info.Compact then DisplayLabel.Text=Info.Text..': '..Slider.Value..Suffix elseif
Info.HideMax then DisplayLabel.Text=string.format('%s',Slider.Value..Suffix)else
DisplayLabel.Text=string.format('%s/%s',Slider.Value..Suffix,Slider.Max..Suffix)
end local X=math.ceil(Library:MapValue(Slider.Value,Slider.Min,Slider.Max,0,
Slider.MaxSize))Fill.Size=UDim2.new(0,X,1,0)HideBorderRight.Visible=not(X==
Slider.MaxSize or X==0)end function Slider:OnChanged(Func)Slider.Changed=Func
Func(Slider.Value)end local Round=function(Value)if Slider.Rounding==0 then
return math.floor(Value)end return tonumber(string.format('%.'..Slider.Rounding
..'f',Value))end function Slider:GetValueFromXOffset(X)return Round(Library:
MapValue(X,0,Slider.MaxSize,Slider.Min,Slider.Max))end function Slider:SetValue(
Str)local Num=tonumber(Str)if(not Num)then return end Num=math.clamp(Num,Slider.
Min,Slider.Max)Slider.Value=Num Slider:Display()Library:SafeCallback(Slider.
Callback,Slider.Value)Library:SafeCallback(Slider.Changed,Slider.Value)end
SliderInner.InputBegan:Connect(function(Input)if(Input.UserInputType==Enum.
UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch)and
not Library:MouseIsOverOpenedFrame()then local MousePosition=Mouse.X local
GuiPosition=Fill.Size.X.Offset local Difference=MousePosition-(Fill.
AbsolutePosition.X+GuiPosition)local IsDragging=true local UpdateSlider=function
()local NewMousePosition if Input.UserInputType==Enum.UserInputType.Touch then
NewMousePosition=Input.Position.X else NewMousePosition=Mouse.X end local NewX=
math.clamp(GuiPosition+(NewMousePosition-MousePosition)+Difference,0,Slider.
MaxSize)local NewValue=Slider:GetValueFromXOffset(NewX)local OldValue=Slider.
Value Slider.Value=NewValue Slider:Display()if NewValue~=OldValue then Library:
SafeCallback(Slider.Callback,Slider.Value)Library:SafeCallback(Slider.Changed,
Slider.Value)end end local InputChanged,InputEnded if Input.UserInputType==Enum.
UserInputType.Touch then InputChanged=Input.Changed:Connect(function()if Input.
UserInputState==Enum.UserInputState.Change then UpdateSlider()end end)InputEnded
=Input.Ended:Connect(function()IsDragging=false InputChanged:Disconnect()
InputEnded:Disconnect()Library:AttemptSave()end)else while InputService:
IsMouseButtonPressed(Enum.UserInputType.MouseButton1)and IsDragging do
UpdateSlider()RenderStepped:Wait()end Library:AttemptSave()end end end)Slider:
Display()Groupbox:AddBlank(Info.BlankSize or 6)Groupbox:Resize()Library.Options[
Idx]=Slider return Slider end function Funcs:AddDropdown(Idx,Info)if Info.
SpecialType=='Player'then Info.Values=GetPlayersString()Info.AllowNull=true
elseif Info.SpecialType=='Team'then Info.Values=GetTeamsString()Info.AllowNull=
true end assert(Info.Values,'AddDropdown: Missing dropdown value list.')assert(
Info.AllowNull or Info.Default,
[[AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.]]
)if(not Info.Text)then Info.Compact=true end local Dropdown={Values=Info.Values,
Value=Info.Multi and{},Multi=Info.Multi,Type='Dropdown',SpecialType=Info.
SpecialType,Callback=Info.Callback or function(Value)end}local Groupbox=self
local Container=Groupbox.Container local RelativeOffset=0 if not Info.Compact
then Library:CreateLabel({Size=UDim2.new(1,0,0,10),TextSize=14,Text=Info.Text,
TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.
Bottom,ZIndex=5,Parent=Container})Groupbox:AddBlank(3)end for _,Element in next,
Container:GetChildren()do if not Element:IsA('UIListLayout')then RelativeOffset=
RelativeOffset+Element.Size.Y.Offset end end local DropdownOuter=Library:Create(
'Frame',{BackgroundColor3=Color3.new(0,0,0),BorderColor3=Color3.new(0,0,0),Size=
UDim2.new(1,-4,0,20),ZIndex=5,Parent=Container})Library:AddToRegistry(
DropdownOuter,{BorderColor3='Black'})local DropdownInner=Library:Create('Frame',
{BackgroundColor3=Library.MainColor,BorderColor3=Library.OutlineColor,BorderMode
=Enum.BorderMode.Inset,Size=UDim2.new(1,0,1,0),ZIndex=6,Parent=DropdownOuter})
Library:AddToRegistry(DropdownInner,{BackgroundColor3='MainColor',BorderColor3=
'OutlineColor'})Library:Create('UIGradient',{Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,
Color3.fromRGB(212,212,212))}),Rotation=90,Parent=DropdownInner})local
DropdownArrow=Library:Create('ImageLabel',{AnchorPoint=Vector2.new(0,0.5),
BackgroundTransparency=1,Position=UDim2.new(1,-16,0.5,0),Size=UDim2.new(0,12,0,
12),Image='http://www.roblox.com/asset/?id=6282522798',ZIndex=8,Parent=
DropdownInner})local ItemList=Library:CreateLabel({Position=UDim2.new(0,5,0,0),
Size=UDim2.new(1,-5,1,0),TextSize=14,Text='--',TextXAlignment=Enum.
TextXAlignment.Left,TextWrapped=true,ZIndex=7,Parent=DropdownInner})Library:
OnHighlight(DropdownOuter,DropdownOuter,{BorderColor3='AccentColor'},{
BorderColor3='Black'})if type(Info.Tooltip)=='string'then Library:AddToolTip(
Info.Tooltip,DropdownOuter)end local MAX_DROPDOWN_ITEMS=8 local ListOuter=
Library:Create('Frame',{BackgroundColor3=Color3.new(0,0,0),BorderColor3=Color3.
new(0,0,0),ZIndex=20,Visible=false,Parent=ScreenGui})local
RecalculateListPosition=function()ListOuter.Position=UDim2.fromOffset(
DropdownOuter.AbsolutePosition.X,DropdownOuter.AbsolutePosition.Y+DropdownOuter.
Size.Y.Offset+1)end local RecalculateListSize=function(YSize)ListOuter.Size=
UDim2.fromOffset(DropdownOuter.AbsoluteSize.X,YSize or(MAX_DROPDOWN_ITEMS*20+2))
end RecalculateListPosition()RecalculateListSize()DropdownOuter:
GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition)
local ListInner=Library:Create('Frame',{BackgroundColor3=Library.MainColor,
BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.Inset,
BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=21,Parent=ListOuter})Library:
AddToRegistry(ListInner,{BackgroundColor3='MainColor',BorderColor3=
'OutlineColor'})local Scrolling=Library:Create('ScrollingFrame',{
BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),Size=
UDim2.new(1,0,1,0),ZIndex=21,Parent=ListInner,TopImage=
'rbxasset://textures/ui/Scroll/scroll-middle.png',BottomImage=
'rbxasset://textures/ui/Scroll/scroll-middle.png',ScrollBarThickness=3,
ScrollBarImageColor3=Library.AccentColor})Library:AddToRegistry(Scrolling,{
ScrollBarImageColor3='AccentColor'})Library:Create('UIListLayout',{Padding=UDim.
new(0,0),FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.
LayoutOrder,Parent=Scrolling})function Dropdown:Display()local Values=Dropdown.
Values local Str=''if Info.Multi then for Idx,Value in next,Values do if
Dropdown.Value[Value]then Str=Str..Value..', 'end end Str=Str:sub(1,#Str-2)else
Str=Dropdown.Value or''end ItemList.Text=(Str==''and'--'or Str)end function
Dropdown:GetActiveValues()if Info.Multi then local T={}for Value,Bool in next,
Dropdown.Value do table.insert(T,Value)end return T else return Dropdown.Value
and 1 or 0 end end function Dropdown:BuildDropdownList()local Values=Dropdown.
Values local Buttons={}for _,Element in next,Scrolling:GetChildren()do if not
Element:IsA('UIListLayout')then Element:Destroy()end end local Count=0 for Idx,
Value in next,Values do local Table={}Count=Count+1 local Button=Library:Create(
'Frame',{BackgroundColor3=Library.MainColor,BorderColor3=Library.OutlineColor,
BorderMode=Enum.BorderMode.Middle,Size=UDim2.new(1,-1,0,20),ZIndex=23,Active=
true,Parent=Scrolling})Library:AddToRegistry(Button,{BackgroundColor3=
'MainColor',BorderColor3='OutlineColor'})local ButtonLabel=Library:CreateLabel({
Active=false,Size=UDim2.new(1,-6,1,0),Position=UDim2.new(0,6,0,0),TextSize=14,
Text=Value,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=25,Parent=Button})
Library:OnHighlight(Button,Button,{BorderColor3='AccentColor',ZIndex=24},{
BorderColor3='OutlineColor',ZIndex=23})local Selected if Info.Multi then
Selected=Dropdown.Value[Value]else Selected=Dropdown.Value==Value end function
Table:UpdateButton()if Info.Multi then Selected=Dropdown.Value[Value]else
Selected=Dropdown.Value==Value end ButtonLabel.TextColor3=Selected and Library.
AccentColor or Library.FontColor Library.RegistryMap[ButtonLabel].Properties.
TextColor3=Selected and'AccentColor'or'FontColor'end ButtonLabel.InputBegan:
Connect(function(Input)if Input.UserInputType==Enum.UserInputType.MouseButton1
then local Try=not Selected if Dropdown:GetActiveValues()==1 and(not Try)and(not
Info.AllowNull)then else if Info.Multi then Selected=Try if Selected then
Dropdown.Value[Value]=true else Dropdown.Value[Value]=nil end else Selected=Try
if Selected then Dropdown.Value=Value else Dropdown.Value=nil end for _,
OtherButton in next,Buttons do OtherButton:UpdateButton()end end Table:
UpdateButton()Dropdown:Display()Library:SafeCallback(Dropdown.Callback,Dropdown.
Value)Library:SafeCallback(Dropdown.Changed,Dropdown.Value)Library:AttemptSave()
end end end)Table:UpdateButton()Dropdown:Display()Buttons[Button]=Table end
Scrolling.CanvasSize=UDim2.fromOffset(0,(Count*20)+1)local Y=math.clamp(Count*20
,0,MAX_DROPDOWN_ITEMS*20)+1 RecalculateListSize(Y)end function Dropdown:
SetValues(NewValues)if NewValues then Dropdown.Values=NewValues end Dropdown:
BuildDropdownList()end function Dropdown:OpenDropdown()ListOuter.Visible=true
Library.OpenedFrames[ListOuter]=true DropdownArrow.Rotation=180 end function
Dropdown:CloseDropdown()ListOuter.Visible=false Library.OpenedFrames[ListOuter]=
nil DropdownArrow.Rotation=0 end function Dropdown:OnChanged(Func)Dropdown.
Changed=Func Func(Dropdown.Value)end function Dropdown:SetValue(Val)if Dropdown.
Multi then local nTable={}for Value,Bool in next,Val do if table.find(Dropdown.
Values,Value)then nTable[Value]=true end end Dropdown.Value=nTable else if(not
Val)then Dropdown.Value=nil elseif table.find(Dropdown.Values,Val)then Dropdown.
Value=Val end end Dropdown:BuildDropdownList()Library:SafeCallback(Dropdown.
Callback,Dropdown.Value)Library:SafeCallback(Dropdown.Changed,Dropdown.Value)end
DropdownOuter.InputBegan:Connect(function(Input)if Input.UserInputType==Enum.
UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()then if
ListOuter.Visible then Dropdown:CloseDropdown()else Dropdown:OpenDropdown()end
end end)InputService.InputBegan:Connect(function(Input)if Input.UserInputType==
Enum.UserInputType.MouseButton1 then local AbsPos,AbsSize=ListOuter.
AbsolutePosition,ListOuter.AbsoluteSize if Mouse.X<AbsPos.X or Mouse.X>AbsPos.X+
AbsSize.X or Mouse.Y<(AbsPos.Y-20-1)or Mouse.Y>AbsPos.Y+AbsSize.Y then Dropdown:
CloseDropdown()end end end)Dropdown:BuildDropdownList()Dropdown:Display()local
Defaults={}if type(Info.Default)=='string'then local Idx=table.find(Dropdown.
Values,Info.Default)if Idx then table.insert(Defaults,Idx)end elseif type(Info.
Default)=='table'then for _,Value in next,Info.Default do local Idx=table.find(
Dropdown.Values,Value)if Idx then table.insert(Defaults,Idx)end end elseif type(
Info.Default)=='number'and Dropdown.Values[Info.Default]~=nil then table.insert(
Defaults,Info.Default)end if next(Defaults)then for i=1,#Defaults do local Index
=Defaults[i]if Info.Multi then Dropdown.Value[Dropdown.Values[Index] ]=true else
Dropdown.Value=Dropdown.Values[Index]end if(not Info.Multi)then break end end
Dropdown:BuildDropdownList()Dropdown:Display()end Groupbox:AddBlank(Info.
BlankSize or 5)Groupbox:Resize()Library.Options[Idx]=Dropdown return Dropdown
end function Funcs:AddDependencyBox()local Depbox={Dependencies={}}local
Groupbox=self local Container=Groupbox.Container local Holder=Library:Create(
'Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),Visible=false,Parent=
Container})local Frame=Library:Create('Frame',{BackgroundTransparency=1,Size=
UDim2.new(1,0,1,0),Visible=true,Parent=Holder})local Layout=Library:Create(
'UIListLayout',{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.
SortOrder.LayoutOrder,Parent=Frame})function Depbox:Resize()Holder.Size=UDim2.
new(1,0,0,Layout.AbsoluteContentSize.Y)Groupbox:Resize()end Layout:
GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()Depbox:Resize(
)end)Holder:GetPropertyChangedSignal('Visible'):Connect(function()Depbox:Resize(
)end)function Depbox:Update()for _,Dependency in next,Depbox.Dependencies do
local Elem=Dependency[1]local Value=Dependency[2]if Elem.Type=='Toggle'and Elem.
Value~=Value then Holder.Visible=false Depbox:Resize()return end end Holder.
Visible=true Depbox:Resize()end function Depbox:SetupDependencies(Dependencies)
for _,Dependency in next,Dependencies do assert(type(Dependency)=='table',
'SetupDependencies: Dependency is not of type `table`.')assert(Dependency[1],
'SetupDependencies: Dependency is missing element argument.')assert(Dependency[2
]~=nil,'SetupDependencies: Dependency is missing value argument.')end Depbox.
Dependencies=Dependencies Depbox:Update()end Depbox.Container=Frame
setmetatable(Depbox,BaseGroupbox)table.insert(Library.DependencyBoxes,Depbox)
return Depbox end BaseGroupbox.__index=Funcs BaseGroupbox.__namecall=function(
Table,Key,...)return Funcs[Key](...)end end do Library.NotificationArea=Library:
Create('Frame',{BackgroundTransparency=1,Position=UDim2.new(0,0,0,40),Size=UDim2
.new(0,300,0,200),ZIndex=100,Parent=ScreenGui})Library:Create('UIListLayout',{
Padding=UDim.new(0,4),FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.
SortOrder.LayoutOrder,Parent=Library.NotificationArea})local WatermarkOuter=
Library:Create('Frame',{BorderColor3=Color3.new(0,0,0),Position=UDim2.new(0,100,
0,-25),Size=UDim2.new(0,213,0,20),ZIndex=200,Visible=false,Parent=ScreenGui})
local WatermarkInner=Library:Create('Frame',{BackgroundColor3=Library.MainColor,
BorderColor3=Library.AccentColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.
new(1,0,1,0),ZIndex=201,Parent=WatermarkOuter})Library:AddToRegistry(
WatermarkInner,{BorderColor3='AccentColor'})local InnerFrame=Library:Create(
'Frame',{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.
new(0,1,0,1),Size=UDim2.new(1,-2,1,-2),ZIndex=202,Parent=WatermarkInner})local
Gradient=Library:Create('UIGradient',{Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Library:GetDarkerColor(Library.MainColor)),
ColorSequenceKeypoint.new(1,Library.MainColor)}),Rotation=-90,Parent=InnerFrame}
)Library:AddToRegistry(Gradient,{Color=function()return ColorSequence.new({
ColorSequenceKeypoint.new(0,Library:GetDarkerColor(Library.MainColor)),
ColorSequenceKeypoint.new(1,Library.MainColor)})end})local WatermarkLabel=
Library:CreateLabel({Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-4,1,0),
TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=203,Parent=InnerFrame
})Library.Watermark=WatermarkOuter Library.WatermarkText=WatermarkLabel Library:
MakeDraggable(Library.Watermark)local KeybindOuter=Library:Create('Frame',{
AnchorPoint=Vector2.new(0,0.5),BorderColor3=Color3.new(0,0,0),Position=UDim2.
new(0,10,0.5,0),Size=UDim2.new(0,210,0,20),Visible=false,ZIndex=100,Parent=
ScreenGui})local KeybindInner=Library:Create('Frame',{BackgroundColor3=Library.
MainColor,BorderColor3=Library.OutlineColor,BorderMode=Enum.BorderMode.Inset,
Size=UDim2.new(1,0,1,0),ZIndex=101,Parent=KeybindOuter})Library:AddToRegistry(
KeybindInner,{BackgroundColor3='MainColor',BorderColor3='OutlineColor'},true)
local ColorFrame=Library:Create('Frame',{BackgroundColor3=Library.AccentColor,
BorderSizePixel=0,Size=UDim2.new(1,0,0,2),ZIndex=102,Parent=KeybindInner})
Library:AddToRegistry(ColorFrame,{BackgroundColor3='AccentColor'},true)Library:
CreateLabel({Size=UDim2.new(1,0,0,20),Position=UDim2.fromOffset(5,2),
TextXAlignment=Enum.TextXAlignment.Left,Text='Keybinds',ZIndex=104,Parent=
KeybindInner})local KeybindContainer=Library:Create('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,1,-20),Position=UDim2.new(0,0,0,20),
ZIndex=1,Parent=KeybindInner})Library:Create('UIListLayout',{FillDirection=Enum.
FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Parent=
KeybindContainer})Library:Create('UIPadding',{PaddingLeft=UDim.new(0,5),Parent=
KeybindContainer})Library.KeybindFrame=KeybindOuter Library.KeybindContainer=
KeybindContainer Library:MakeDraggable(KeybindOuter)end function Library:
SetWatermarkVisibility(Bool)Library.Watermark.Visible=Bool end function Library:
SetWatermark(Text)local X,Y=Library:GetTextBounds(Text,Library.Font,14)Library.
Watermark.Size=UDim2.new(0,X+15,0,(Y*1.5)+3)Library:SetWatermarkVisibility(true)
Library.WatermarkText.Text=Text end function Library:Notify(Text,Time)local
XSize,YSize=Library:GetTextBounds(Text,Library.Font,14)YSize=YSize+7 local
NotifyOuter=Library:Create('Frame',{BorderColor3=Color3.new(0,0,0),Position=
UDim2.new(0,100,0,10),Size=UDim2.new(0,0,0,YSize),ClipsDescendants=true,ZIndex=
100,Parent=Library.NotificationArea})local NotifyInner=Library:Create('Frame',{
BackgroundColor3=Library.MainColor,BorderColor3=Library.OutlineColor,BorderMode=
Enum.BorderMode.Inset,Size=UDim2.new(1,0,1,0),ZIndex=101,Parent=NotifyOuter})
Library:AddToRegistry(NotifyInner,{BackgroundColor3='MainColor',BorderColor3=
'OutlineColor'},true)local InnerFrame=Library:Create('Frame',{BackgroundColor3=
Color3.new(1,1,1),BorderSizePixel=0,Position=UDim2.new(0,1,0,1),Size=UDim2.new(1
,-2,1,-2),ZIndex=102,Parent=NotifyInner})local Gradient=Library:Create(
'UIGradient',{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Library:
GetDarkerColor(Library.MainColor)),ColorSequenceKeypoint.new(1,Library.MainColor
)}),Rotation=-90,Parent=InnerFrame})Library:AddToRegistry(Gradient,{Color=
function()return ColorSequence.new({ColorSequenceKeypoint.new(0,Library:
GetDarkerColor(Library.MainColor)),ColorSequenceKeypoint.new(1,Library.MainColor
)})end})Library:CreateLabel({Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-4,1,0
),Text=Text,TextXAlignment=Enum.TextXAlignment.Left,TextSize=14,ZIndex=103,
Parent=InnerFrame})local LeftColor=Library:Create('Frame',{BackgroundColor3=
Library.AccentColor,BorderSizePixel=0,Position=UDim2.new(0,-1,0,-1),Size=UDim2.
new(0,3,1,2),ZIndex=104,Parent=NotifyOuter})Library:AddToRegistry(LeftColor,{
BackgroundColor3='AccentColor'},true)pcall(NotifyOuter.TweenSize,NotifyOuter,
UDim2.new(0,XSize+8+4,0,YSize),'Out','Quad',0.4,true)task.spawn(function()wait(
Time or 5)pcall(NotifyOuter.TweenSize,NotifyOuter,UDim2.new(0,0,0,YSize),'Out',
'Quad',0.4,true)wait(0.4)NotifyOuter:Destroy()end)end function Library:
CreateWindow(...)local Arguments={...}local Config={AnchorPoint=Vector2.zero}if
type(...)=='table'then Config=...else Config.Title=Arguments[1]Config.AutoShow=
Arguments[2]or false end if type(Config.Title)~='string'then Config.Title=
'No title'end if type(Config.TabPadding)~='number'then Config.TabPadding=0 end
if type(Config.MenuFadeTime)~='number'then Config.MenuFadeTime=0.2 end if
typeof(Config.Position)~='UDim2'then Config.Position=UDim2.fromOffset(175,50)end
if typeof(Config.Size)~='UDim2'then Config.Size=UDim2.fromOffset(550,600)end if
Config.Center then Config.AnchorPoint=Vector2.new(0.5,0.5)Config.Position=UDim2.
fromScale(0.5,0.5)end local Window={Tabs={}}local Outer=Library:Create('Frame',{
AnchorPoint=Config.AnchorPoint,BackgroundColor3=Color3.new(0,0,0),
BorderSizePixel=0,Position=Config.Position,Size=Config.Size,Visible=false,ZIndex
=1,Parent=ScreenGui})Library:MakeDraggable(Outer,25)local Inner=Library:Create(
'Frame',{BackgroundColor3=Library.MainColor,BorderColor3=Library.AccentColor,
BorderMode=Enum.BorderMode.Inset,Position=UDim2.new(0,1,0,1),Size=UDim2.new(1,-2
,1,-2),ZIndex=1,Parent=Outer})Library:AddToRegistry(Inner,{BackgroundColor3=
'MainColor',BorderColor3='AccentColor'})local WindowLabel=Library:CreateLabel({
Position=UDim2.new(0,7,0,0),Size=UDim2.new(0,0,0,25),Text=Config.Title or'',
TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1,Parent=Inner})local
MainSectionOuter=Library:Create('Frame',{BackgroundColor3=Library.
BackgroundColor,BorderColor3=Library.OutlineColor,Position=UDim2.new(0,8,0,25),
Size=UDim2.new(1,-16,1,-33),ZIndex=1,Parent=Inner})Library:AddToRegistry(
MainSectionOuter,{BackgroundColor3='BackgroundColor',BorderColor3='OutlineColor'
})local MainSectionInner=Library:Create('Frame',{BackgroundColor3=Library.
BackgroundColor,BorderColor3=Color3.new(0,0,0),BorderMode=Enum.BorderMode.Inset,
Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,1,0),ZIndex=1,Parent=
MainSectionOuter})Library:AddToRegistry(MainSectionInner,{BackgroundColor3=
'BackgroundColor'})local TabArea=Library:Create('Frame',{BackgroundTransparency=
1,Position=UDim2.new(0,8,0,8),Size=UDim2.new(1,-16,0,21),ZIndex=1,Parent=
MainSectionInner})local TabListLayout=Library:Create('UIListLayout',{Padding=
UDim.new(0,Config.TabPadding),FillDirection=Enum.FillDirection.Horizontal,
SortOrder=Enum.SortOrder.LayoutOrder,Parent=TabArea})local TabContainer=Library:
Create('Frame',{BackgroundColor3=Library.MainColor,BorderColor3=Library.
OutlineColor,Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-16,1,-38),ZIndex=2,
Parent=MainSectionInner})Library:AddToRegistry(TabContainer,{BackgroundColor3=
'MainColor',BorderColor3='OutlineColor'})function Window:SetWindowTitle(Title)
WindowLabel.Text=Title end function Window:AddTab(Name)local Tab={Groupboxes={},
Tabboxes={}}local TabButtonWidth=Library:GetTextBounds(Name,Library.Font,16)
local TabButton=Library:Create('Frame',{BackgroundColor3=Library.BackgroundColor
,BorderColor3=Library.OutlineColor,Size=UDim2.new(0,TabButtonWidth+8+4,1,0),
ZIndex=1,Parent=TabArea})Library:AddToRegistry(TabButton,{BackgroundColor3=
'BackgroundColor',BorderColor3='OutlineColor'})Library:CreateLabel({Position=
UDim2.new(0,0,0,0),Size=UDim2.new(1,0,1,-1),Text=Name,ZIndex=1,Parent=TabButton}
)local Blocker=Library:Create('Frame',{BackgroundColor3=Library.MainColor,
BorderSizePixel=0,Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),
BackgroundTransparency=1,ZIndex=3,Parent=TabButton})Library:AddToRegistry(
Blocker,{BackgroundColor3='MainColor'})local TabFrame=Library:Create('Frame',{
Name='TabFrame',BackgroundTransparency=1,Position=UDim2.new(0,0,0,0),Size=UDim2.
new(1,0,1,0),Visible=false,ZIndex=2,Parent=TabContainer})local LeftSide=Library:
Create('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,Position=
UDim2.new(0,7,0,7),Size=UDim2.new(0.5,-10,0,509),CanvasSize=UDim2.new(0,0,0,0),
BottomImage='',TopImage='',ScrollBarThickness=0,ZIndex=2,Parent=TabFrame})local
RightSide=Library:Create('ScrollingFrame',{BackgroundTransparency=1,
BorderSizePixel=0,Position=UDim2.new(0.5,5,0,7),Size=UDim2.new(0.5,-10,0,509),
CanvasSize=UDim2.new(0,0,0,0),BottomImage='',TopImage='',ScrollBarThickness=0,
ZIndex=2,Parent=TabFrame})Library:Create('UIListLayout',{Padding=UDim.new(0,8),
FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,
HorizontalAlignment=Enum.HorizontalAlignment.Center,Parent=LeftSide})Library:
Create('UIListLayout',{Padding=UDim.new(0,8),FillDirection=Enum.FillDirection.
Vertical,SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.
HorizontalAlignment.Center,Parent=RightSide})for _,Side in next,{LeftSide,
RightSide}do Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal(
'AbsoluteContentSize'):Connect(function()Side.CanvasSize=UDim2.fromOffset(0,Side
.UIListLayout.AbsoluteContentSize.Y)end)end function Tab:ShowTab()for _,Tab in
next,Window.Tabs do Tab:HideTab()end Blocker.BackgroundTransparency=0 TabButton.
BackgroundColor3=Library.MainColor Library.RegistryMap[TabButton].Properties.
BackgroundColor3='MainColor'TabFrame.Visible=true end function Tab:HideTab()
Blocker.BackgroundTransparency=1 TabButton.BackgroundColor3=Library.
BackgroundColor Library.RegistryMap[TabButton].Properties.BackgroundColor3=
'BackgroundColor'TabFrame.Visible=false end function Tab:SetLayoutOrder(Position
)TabButton.LayoutOrder=Position TabListLayout:ApplyLayout()end function Tab:
AddGroupbox(Info)local Groupbox={}local BoxOuter=Library:Create('Frame',{
BackgroundColor3=Library.BackgroundColor,BorderColor3=Library.OutlineColor,
BorderMode=Enum.BorderMode.Inset,Size=UDim2.new(1,0,0,509),ZIndex=2,Parent=Info.
Side==1 and LeftSide or RightSide})Library:AddToRegistry(BoxOuter,{
BackgroundColor3='BackgroundColor',BorderColor3='OutlineColor'})local BoxInner=
Library:Create('Frame',{BackgroundColor3=Library.BackgroundColor,BorderColor3=
Color3.new(0,0,0),Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),ZIndex=4
,Parent=BoxOuter})Library:AddToRegistry(BoxInner,{BackgroundColor3=
'BackgroundColor'})local Highlight=Library:Create('Frame',{BackgroundColor3=
Library.AccentColor,BorderSizePixel=0,Size=UDim2.new(1,0,0,2),ZIndex=5,Parent=
BoxInner})Library:AddToRegistry(Highlight,{BackgroundColor3='AccentColor'})
Library:CreateLabel({Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,4,0,2),
TextSize=14,Text=Info.Name,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
Parent=BoxInner})local Container=Library:Create('Frame',{BackgroundTransparency=
1,Position=UDim2.new(0,4,0,20),Size=UDim2.new(1,-4,1,-20),ZIndex=1,Parent=
BoxInner})Library:Create('UIListLayout',{FillDirection=Enum.FillDirection.
Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Parent=Container})function
Groupbox:Resize()local Size=0 for _,Element in next,Groupbox.Container:
GetChildren()do if(not Element:IsA('UIListLayout'))and Element.Visible then Size
=Size+Element.Size.Y.Offset end end BoxOuter.Size=UDim2.new(1,0,0,20+Size+2+2)
end Groupbox.Container=Container setmetatable(Groupbox,BaseGroupbox)Groupbox:
AddBlank(3)Groupbox:Resize()Tab.Groupboxes[Info.Name]=Groupbox return Groupbox
end function Tab:AddLeftGroupbox(Name)return Tab:AddGroupbox({Side=1,Name=Name})
end function Tab:AddRightGroupbox(Name)return Tab:AddGroupbox({Side=2,Name=Name}
)end function Tab:AddTabbox(Info)local Tabbox={Tabs={}}local BoxOuter=Library:
Create('Frame',{BackgroundColor3=Library.BackgroundColor,BorderColor3=Library.
OutlineColor,BorderMode=Enum.BorderMode.Inset,Size=UDim2.new(1,0,0,0),ZIndex=2,
Parent=Info.Side==1 and LeftSide or RightSide})Library:AddToRegistry(BoxOuter,{
BackgroundColor3='BackgroundColor',BorderColor3='OutlineColor'})local BoxInner=
Library:Create('Frame',{BackgroundColor3=Library.BackgroundColor,BorderColor3=
Color3.new(0,0,0),Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),ZIndex=4
,Parent=BoxOuter})Library:AddToRegistry(BoxInner,{BackgroundColor3=
'BackgroundColor'})local Highlight=Library:Create('Frame',{BackgroundColor3=
Library.AccentColor,BorderSizePixel=0,Size=UDim2.new(1,0,0,2),ZIndex=10,Parent=
BoxInner})Library:AddToRegistry(Highlight,{BackgroundColor3='AccentColor'})local
TabboxButtons=Library:Create('Frame',{BackgroundTransparency=1,Position=UDim2.
new(0,0,0,1),Size=UDim2.new(1,0,0,18),ZIndex=5,Parent=BoxInner})Library:Create(
'UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=
Enum.HorizontalAlignment.Left,SortOrder=Enum.SortOrder.LayoutOrder,Parent=
TabboxButtons})function Tabbox:AddTab(Name)local Tab={}local Button=Library:
Create('Frame',{BackgroundColor3=Library.MainColor,BorderColor3=Color3.new(0,0,0
),Size=UDim2.new(0.5,0,1,0),ZIndex=6,Parent=TabboxButtons})Library:
AddToRegistry(Button,{BackgroundColor3='MainColor'})Library:CreateLabel({Size=
UDim2.new(1,0,1,0),TextSize=14,Text=Name,TextXAlignment=Enum.TextXAlignment.
Center,ZIndex=7,Parent=Button})local Block=Library:Create('Frame',{
BackgroundColor3=Library.BackgroundColor,BorderSizePixel=0,Position=UDim2.new(0,
0,1,0),Size=UDim2.new(1,0,0,1),Visible=false,ZIndex=9,Parent=Button})Library:
AddToRegistry(Block,{BackgroundColor3='BackgroundColor'})local Container=Library
:Create('Frame',{BackgroundTransparency=1,Position=UDim2.new(0,4,0,20),Size=
UDim2.new(1,-4,1,-20),ZIndex=1,Visible=false,Parent=BoxInner})Library:Create(
'UIListLayout',{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.
SortOrder.LayoutOrder,Parent=Container})function Tab:Show()for _,Tab in next,
Tabbox.Tabs do Tab:Hide()end Container.Visible=true Block.Visible=true Button.
BackgroundColor3=Library.BackgroundColor Library.RegistryMap[Button].Properties.
BackgroundColor3='BackgroundColor'Tab:Resize()end function Tab:Hide()Container.
Visible=false Block.Visible=false Button.BackgroundColor3=Library.MainColor
Library.RegistryMap[Button].Properties.BackgroundColor3='MainColor'end function
Tab:Resize()local TabCount=0 for _,Tab in next,Tabbox.Tabs do TabCount=TabCount+
1 end for _,Button in next,TabboxButtons:GetChildren()do if not Button:IsA(
'UIListLayout')then Button.Size=UDim2.new(1/TabCount,0,1,0)end end if(not
Container.Visible)then return end local Size=0 for _,Element in next,Tab.
Container:GetChildren()do if(not Element:IsA('UIListLayout'))and Element.Visible
then Size=Size+Element.Size.Y.Offset end end BoxOuter.Size=UDim2.new(1,0,0,20+
Size+2+2)end Button.InputBegan:Connect(function(Input)if(Input.UserInputType==
Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch
)and not Library:MouseIsOverOpenedFrame()then Tab:Show()Tab:Resize()end end)Tab.
Container=Container Tabbox.Tabs[Name]=Tab setmetatable(Tab,BaseGroupbox)Tab:
AddBlank(3)Tab:Resize()if#TabboxButtons:GetChildren()==2 then Tab:Show()end
return Tab end Tab.Tabboxes[Info.Name or'']=Tabbox return Tabbox end function
Tab:AddLeftTabbox(Name)return Tab:AddTabbox({Name=Name,Side=1})end function Tab:
AddRightTabbox(Name)return Tab:AddTabbox({Name=Name,Side=2})end TabButton.
InputBegan:Connect(function(Input)if Input.UserInputType==Enum.UserInputType.
MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then Tab:ShowTab()
end end)if#TabContainer:GetChildren()==1 then Tab:ShowTab()end Window.Tabs[Name]
=Tab return Tab end local ModalElement=Library:Create('TextButton',{
BackgroundTransparency=1,Size=UDim2.new(0,0,0,0),Visible=true,Text='',Modal=
false,Parent=ScreenGui})local TransparencyCache={}local Toggled=false local
Fading=false function Library:Toggle()if Fading then return end local FadeTime=
Config.MenuFadeTime Fading=true Toggled=(not Toggled)ModalElement.Modal=Toggled
if Toggled then Outer.Visible=true task.spawn(function()local State=InputService
.MouseIconEnabled local Cursor=Drawing.new('Triangle')Cursor.Thickness=1 Cursor.
Filled=true Cursor.Visible=true local CursorOutline=Drawing.new('Triangle')
CursorOutline.Thickness=1 CursorOutline.Filled=false CursorOutline.Color=Color3.
new(0,0,0)CursorOutline.Visible=true while Toggled and ScreenGui.Parent do
InputService.MouseIconEnabled=false local mPos=InputService:GetMouseLocation()
Cursor.Color=Library.AccentColor Cursor.PointA=Vector2.new(mPos.X,mPos.Y)Cursor.
PointB=Vector2.new(mPos.X+16,mPos.Y+6)Cursor.PointC=Vector2.new(mPos.X+6,mPos.Y+
16)CursorOutline.PointA=Cursor.PointA CursorOutline.PointB=Cursor.PointB
CursorOutline.PointC=Cursor.PointC RenderStepped:Wait()end InputService.
MouseIconEnabled=State Cursor:Remove()CursorOutline:Remove()end)end for _,Desc
in next,Outer:GetDescendants()do local Properties={}if Desc:IsA('ImageLabel')
then table.insert(Properties,'ImageTransparency')table.insert(Properties,
'BackgroundTransparency')elseif Desc:IsA('TextLabel')or Desc:IsA('TextBox')then
table.insert(Properties,'TextTransparency')elseif Desc:IsA('Frame')or Desc:IsA(
'ScrollingFrame')then table.insert(Properties,'BackgroundTransparency')elseif
Desc:IsA('UIStroke')then table.insert(Properties,'Transparency')end local Cache=
TransparencyCache[Desc]if(not Cache)then Cache={}TransparencyCache[Desc]=Cache
end for _,Prop in next,Properties do if not Cache[Prop]then Cache[Prop]=Desc[
Prop]end if Cache[Prop]==1 then continue end TweenService:Create(Desc,TweenInfo.
new(FadeTime,Enum.EasingStyle.Linear),{[Prop]=Toggled and Cache[Prop]or 1}):
Play()end end task.wait(FadeTime)Outer.Visible=Toggled Fading=false end Library:
GiveSignal(InputService.InputBegan:Connect(function(Input,Processed)if type(
Library.ToggleKeybind)=='table'and Library.ToggleKeybind.Type=='KeyPicker'then
if Input.UserInputType==Enum.UserInputType.Keyboard and Input.KeyCode.Name==
Library.ToggleKeybind.Value then task.spawn(Library.Toggle)end elseif Input.
KeyCode==Enum.KeyCode.RightControl or(Input.KeyCode==Enum.KeyCode.RightShift and
(not Processed))then task.spawn(Library.Toggle)end end))if Config.AutoShow then
task.spawn(Library.Toggle)end Window.Holder=Outer return Window end local
OnPlayerChange=function()local PlayerList=GetPlayersString()for _,Value in next,
Library.Options do if Value.Type=='Dropdown'and Value.SpecialType=='Player'then
Value:SetValues(PlayerList)end end end Players.PlayerAdded:Connect(
OnPlayerChange)Players.PlayerRemoving:Connect(OnPlayerChange)return Library end
function __DARKLUA_BUNDLE_MODULES.f()local httpService=game:GetService(
'HttpService')local ThemeManager={}do ThemeManager.Folder='LinoriaLibSettings'
ThemeManager.Library=nil ThemeManager.BuiltInThemes={['Default']={1,httpService:
JSONDecode(
[[{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}]]
)},['BBot']={2,httpService:JSONDecode(
[[{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}]]
)},['Fatality']={3,httpService:JSONDecode(
[[{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}]]
)},['Jester']={4,httpService:JSONDecode(
[[{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}]]
)},['Mint']={5,httpService:JSONDecode(
[[{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}]]
)},['Tokyo Night']={6,httpService:JSONDecode(
[[{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}]]
)},['Ubuntu']={7,httpService:JSONDecode(
[[{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}]]
)},['Quartz']={8,httpService:JSONDecode(
[[{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}]]
)}}function ThemeManager:ApplyTheme(theme)local customThemeData=self:
GetCustomTheme(theme)local data=customThemeData or self.BuiltInThemes[theme]if
not data then return end local Options=self.Library.Options local scheme=data[2]
for idx,col in next,customThemeData or scheme do self.Library[idx]=Color3.
fromHex(col)if Options[idx]then Options[idx]:SetValueRGB(Color3.fromHex(col))end
end self:ThemeUpdate()end function ThemeManager:ThemeUpdate()local options={
'FontColor','MainColor','AccentColor','BackgroundColor','OutlineColor'}local
Options=self.Library.Options for i,field in next,options do if Options and
Options[field]then self.Library[field]=Options[field].Value end end self.Library
.AccentColorDark=self.Library:GetDarkerColor(self.Library.AccentColor)self.
Library:UpdateColorsUsingRegistry()end function ThemeManager:LoadDefault()local
theme='Default'local content=isfile(self.Folder..'/themes/default.txt')and
readfile(self.Folder..'/themes/default.txt')local isDefault=true if content then
if self.BuiltInThemes[content]then theme=content elseif self:GetCustomTheme(
content)then theme=content isDefault=false end elseif self.BuiltInThemes[self.
DefaultTheme]then theme=self.DefaultTheme end local Options=self.Library.Options
if isDefault then Options.ThemeManager_ThemeList:SetValue(theme)else self:
ApplyTheme(theme)end end function ThemeManager:SaveDefault(theme)writefile(self.
Folder..'/themes/default.txt',theme)end function ThemeManager:CreateThemeManager
(groupbox)groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor'
,{Default=self.Library.BackgroundColor})groupbox:AddLabel('Main color'):
AddColorPicker('MainColor',{Default=self.Library.MainColor})groupbox:AddLabel(
'Accent color'):AddColorPicker('AccentColor',{Default=self.Library.AccentColor})
groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor',{Default=self.
Library.OutlineColor})groupbox:AddLabel('Font color'):AddColorPicker('FontColor'
,{Default=self.Library.FontColor})local ThemesArray={}for Name,Theme in next,
self.BuiltInThemes do table.insert(ThemesArray,Name)end table.sort(ThemesArray,
function(a,b)return self.BuiltInThemes[a][1]<self.BuiltInThemes[b][1]end)
groupbox:AddDivider()groupbox:AddDropdown('ThemeManager_ThemeList',{Text=
'Theme list',Values=ThemesArray,Default=1})local Options=self.Library.Options
groupbox:AddButton('Set as default',function()self:SaveDefault(Options.
ThemeManager_ThemeList.Value)self.Library:Notify(string.format(
'Set default theme to %q',Options.ThemeManager_ThemeList.Value))end)Options.
ThemeManager_ThemeList:OnChanged(function()self:ApplyTheme(Options.
ThemeManager_ThemeList.Value)end)groupbox:AddDivider()groupbox:AddInput(
'ThemeManager_CustomThemeName',{Text='Custom theme name'})groupbox:AddDropdown(
'ThemeManager_CustomThemeList',{Text='Custom themes',Values=self:
ReloadCustomThemes(),AllowNull=true,Default=1})groupbox:AddDivider()groupbox:
AddButton('Save theme',function()self:SaveCustomTheme(Options.
ThemeManager_CustomThemeName.Value)Options.ThemeManager_CustomThemeList:
SetValues(self:ReloadCustomThemes())Options.ThemeManager_CustomThemeList:
SetValue(nil)end):AddButton('Load theme',function()self:ApplyTheme(Options.
ThemeManager_CustomThemeList.Value)end)groupbox:AddButton('Refresh list',
function()Options.ThemeManager_CustomThemeList:SetValues(self:
ReloadCustomThemes())Options.ThemeManager_CustomThemeList:SetValue(nil)end)
groupbox:AddButton('Set as default',function()if Options.
ThemeManager_CustomThemeList.Value~=nil and Options.ThemeManager_CustomThemeList
.Value~=''then self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)self.
Library:Notify(string.format('Set default theme to %q',Options.
ThemeManager_CustomThemeList.Value))end end)ThemeManager:LoadDefault()local
UpdateTheme=function()self:ThemeUpdate()end Options.BackgroundColor:OnChanged(
UpdateTheme)Options.MainColor:OnChanged(UpdateTheme)Options.AccentColor:
OnChanged(UpdateTheme)Options.OutlineColor:OnChanged(UpdateTheme)Options.
FontColor:OnChanged(UpdateTheme)end function ThemeManager:GetCustomTheme(file)
local path=self.Folder..'/themes/'..file if not isfile(path)then return nil end
local data=readfile(path)local success,decoded=pcall(httpService.JSONDecode,
httpService,data)if not success then return nil end return decoded end function
ThemeManager:SaveCustomTheme(file)if file:gsub(' ','')==''then return self.
Library:Notify('Invalid file name for theme (empty)',3)end local theme={}local
fields={'FontColor','MainColor','AccentColor','BackgroundColor','OutlineColor'}
local Options=self.Library.Options for _,field in next,fields do theme[field]=
Options[field].Value:ToHex()end writefile(self.Folder..'/themes/'..file..'.json'
,httpService:JSONEncode(theme))return nil end function ThemeManager:
ReloadCustomThemes()local list=listfiles(self.Folder..'/themes')local out={}for
i=1,#list do local file=list[i]if file:sub(-5)=='.json'then local pos=file:find(
'.json',1,true)local char=file:sub(pos,pos)while char~='/'and char~='\\'and char
~=''do pos=pos-1 char=file:sub(pos,pos)end if char=='/'or char=='\\'then table.
insert(out,file:sub(pos+1))end end end return out end function ThemeManager:
SetLibrary(lib)self.Library=lib end function ThemeManager:BuildFolderTree()local
paths={}local parts=self.Folder:split('/')for idx=1,#parts do paths[#paths+1]=
table.concat(parts,'/',1,idx)end table.insert(paths,self.Folder..'/themes')table
.insert(paths,self.Folder..'/settings')for i=1,#paths do local str=paths[i]if
not isfolder(str)then makefolder(str)end end end function ThemeManager:SetFolder
(folder)self.Folder=folder self:BuildFolderTree()end function ThemeManager:
CreateGroupBox(tab)assert(self.Library,'Must set ThemeManager.Library first!')
return tab:AddLeftGroupbox('Themes')end function ThemeManager:ApplyToTab(tab)
assert(self.Library,'Must set ThemeManager.Library first!')local groupbox=self:
CreateGroupBox(tab)self:CreateThemeManager(groupbox)end function ThemeManager:
ApplyToGroupbox(groupbox)assert(self.Library,
'Must set ThemeManager.Library first!')self:CreateThemeManager(groupbox)end
ThemeManager:BuildFolderTree()end return ThemeManager end function
__DARKLUA_BUNDLE_MODULES.g()local RunService=game:GetService('RunService')local
Players=game:GetService('Players')local Maid=__DARKLUA_BUNDLE_MODULES.load('d')
local UIManager={}UIManager.__index=UIManager function UIManager.new()local self
=setmetatable({},UIManager)self._Library=__DARKLUA_BUNDLE_MODULES.load('e')self.
_ThemeManager=__DARKLUA_BUNDLE_MODULES.load('f')self._ThemeManager:SetLibrary(
self._Library)self._Maid=Maid.new()self._Window=self._Library:CreateWindow({
Title=[[Ink Game Cheats | Script Author: Jorsan | UI Library: Linoria]],Center=
true,AutoShow=true,TabPadding=8,MenuFadeTime=0.2,Size=UDim2.new(0,525,0,400)})
self._Tabs={}self.IsDestroyed=false self.Toggles=self._Library.Toggles self.
Options=self._Library.Options self:_SetupTabs()self._Maid:GiveTask(function()
self.IsDestroyed=true shared._InkGameScriptState.Cleanup()self._Library:Unload()
end)self._ThemeManager:ApplyTheme('Tokyo Night')return self end function
UIManager._SetupTabs(self)self._Tabs={Main=self._Window:AddTab('Main'),Player=
self._Window:AddTab('Player'),Settings=self._Window:AddTab('Settings')}self:
_SetupMainCheatsTab()self:_SetupPlayerTab()self:_SetupSettingsTab()end function
UIManager._SetupMainCheatsTab(self)local RoundCheatsGroup=self._Tabs.Main:
AddLeftGroupbox('Round Cheats')RoundCheatsGroup:AddToggle('RedLightGodMode',{
Text='Red Light God Mode',Default=false,Tooltip=
[[Prevents you from being eliminated during Red Light Green Light]]})
RoundCheatsGroup:AddToggle('TugOfWarAuto',{Text='Tug of War Auto Pull',Default=
false,Tooltip='Automatically pulls during Tug of War game'})RoundCheatsGroup:
AddToggle('DalgonaAuto',{Text='Dalgona Auto Complete',Default=false,Tooltip=
'Automatically completes the Dalgona cookie challenge'})RoundCheatsGroup:
AddToggle('MinglePowerHoldAuto',{Text='Mingle Auto Minigame Solver',Default=
false,Tooltip='Automatically completes the Mingle power hold minigame/QTE'})
local VisualsGroup=self._Tabs.Main:AddRightGroupbox('Visuals')VisualsGroup:
AddLabel('Hide And Seek')VisualsGroup:AddToggle('HiderESP',{Text='Hider ESP',
Default=false,Tooltip=
[[Visually shows where the hiders are located and their status]]})VisualsGroup:
AddToggle('HunterESP',{Text='Hunter ESP',Default=false,Tooltip=
[[Visually shows where the hunters are located and their status]]})VisualsGroup:
AddDivider()VisualsGroup:AddLabel('Glass Bridge')VisualsGroup:AddToggle(
'GlassBridgeESP',{Text='Glass Bridge ESP',Default=false,Tooltip=
'Visually shows which glass panels are safe to step on'})end function UIManager.
_SetupPlayerTab(self)local PlayerSettings=self._Tabs.Player:AddLeftGroupbox(
'Player Modifications')PlayerSettings:AddToggle('EnableWalkSpeed',{Text=
'Enable WalkSpeed',Default=false})PlayerSettings:AddSlider('WalkSpeed',{Text=
'Walk Speed',Default=16,Min=1,Max=100,Rounding=0,Compact=false,Suffix=' studs/s'
})PlayerSettings:AddDivider()PlayerSettings:AddToggle('Noclip',{Text='Noclip',
Default=false,Tooltip='Walk through walls'})local Client=Players.LocalPlayer
local CharacterMaid=Maid.new()self._Maid:GiveTask(CharacterMaid)local
OnCharacterAdded=function(Character)CharacterMaid:DoCleaning()local Humanoid=(
Character:WaitForChild('Humanoid'))local CachedBaseParts={}for _,Object in
ipairs(Character:GetDescendants())do if Object:IsA('BasePart')then table.insert(
CachedBaseParts,Object)end end CharacterMaid:GiveTask(Character.DescendantAdded:
Connect(function(Descendant)if Descendant:IsA('BasePart')then table.insert(
CachedBaseParts,Descendant)end end))local ChangeWalkSpeed=function()if not self:
GetToggleValue('EnableWalkSpeed')then return end local NewWalkSpeed=self:
GetOptionValue('WalkSpeed')if not NewWalkSpeed then return end Humanoid.
WalkSpeed=NewWalkSpeed end CharacterMaid:GiveTask(Humanoid:
GetPropertyChangedSignal('WalkSpeed'):Connect(ChangeWalkSpeed))local
NoclippedBaseParts={}CharacterMaid:GiveTask(RunService.Stepped:Connect(function(
)if not self:GetToggleValue('Noclip')then for BasePart,_ in NoclippedBaseParts
do NoclippedBaseParts[BasePart]=nil BasePart.CanCollide=true end return end for
_,BasePart in ipairs(CachedBaseParts)do if BasePart.CanCollide then
NoclippedBaseParts[BasePart]=true BasePart.CanCollide=false end end end))
CharacterMaid:GiveTask(function()table.clear(CachedBaseParts)for BasePart,_ in
NoclippedBaseParts do NoclippedBaseParts[BasePart]=nil BasePart.CanCollide=true
end end)self.Toggles.EnableWalkSpeed:OnChanged(ChangeWalkSpeed)self.Options.
WalkSpeed:OnChanged(ChangeWalkSpeed)end self._Maid:GiveTask(function()self.
Toggles.EnableWalkSpeed:OnChanged(function()end)self.Options.WalkSpeed:
OnChanged(function()end)end)self._Maid:GiveTask(Client.CharacterAdded:Connect(
OnCharacterAdded))if Client.Character then task.spawn(OnCharacterAdded,Client.
Character)end end function UIManager._SetupSettingsTab(self)local MenuSettings=
self._Tabs.Settings:AddLeftGroupbox('Menu Settings')MenuSettings:AddButton({Text
='Unload/Destroy Script',Func=function()self:Destroy()end,Tooltip=
'Completely removes and destroys the script'})end function UIManager.
GetToggleValue(self,ToggleName)if self.Toggles and self.Toggles[ToggleName]then
return self.Toggles[ToggleName].Value end return false end function UIManager.
GetOptionValue(self,OptionName)return self.Options[OptionName].Value end
function UIManager.Notify(self,Text,Duration)if not self._Library then return
end self._Library:Notify(Text,Duration)end function UIManager.Destroy(self)if
self.IsDestroyed then return end self._Maid:Destroy()warn(
'UIManager destroyed successfully!')end return UIManager end function
__DARKLUA_BUNDLE_MODULES.h()local Players=game:GetService('Players')local
ReplicatedStorage=game:GetService('ReplicatedStorage')local Maid=
__DARKLUA_BUNDLE_MODULES.load('d')__DARKLUA_BUNDLE_MODULES.load('g')local
RedLightGreenLight={}RedLightGreenLight.__index=RedLightGreenLight function
RedLightGreenLight.new(UIManager)local self=setmetatable({},RedLightGreenLight)
self._UIManager=UIManager self._Maid=Maid.new()return self end function
RedLightGreenLight.Start(self)local Client=Players.LocalPlayer local PlayerGui=
Client:WaitForChild('PlayerGui')local TrafficLightImage=(PlayerGui:WaitForChild(
'ImpactFrames'):WaitForChild('TrafficLightEmpty'))self._IsGreenLight=
TrafficLightImage.Image==ReplicatedStorage.Effects.Images.TrafficLights.
GreenLight.Image local RootPart=Client.Character and Client.Character:
FindFirstChild('HumanoidRootPart')self._LastRootPartCFrame=RootPart and RootPart
.CFrame self._Maid:GiveTask(ReplicatedStorage.Remotes.Effects.OnClientEvent:
Connect(function(EffectsData)if EffectsData.EffectName~='TrafficLight'then
return end self._IsGreenLight=EffectsData.GreenLight==true local RootPart=Client
.Character and Client.Character:FindFirstChild('HumanoidRootPart')self.
_LastRootPartCFrame=RootPart and RootPart.CFrame end))local OriginalNamecall
OriginalNamecall=hookfunction(getrawmetatable(game).__namecall,newcclosure(
function(Instance,...)local Args={...}if getnamecallmethod()=='FireServer'and
Instance.ClassName=='RemoteEvent'and Instance.Name=='rootCFrame'then if self.
_UIManager:GetToggleValue('RedLightGodMode')and self._IsGreenLight==false and
self._LastRootPartCFrame then Args[1]=self._LastRootPartCFrame return
OriginalNamecall(Instance,unpack(Args))end end return OriginalNamecall(Instance,
...)end))self._Maid:GiveTask(function()hookfunction(getrawmetatable(game).
__namecall,OriginalNamecall)end)warn('RLGL feature started!')end function
RedLightGreenLight.Destroy(self)warn('RLGL feature destroyed!')self._Maid:
Destroy()end return RedLightGreenLight end function __DARKLUA_BUNDLE_MODULES.i()
local ReplicatedStorage=game:GetService('ReplicatedStorage')local Maid=
__DARKLUA_BUNDLE_MODULES.load('d')__DARKLUA_BUNDLE_MODULES.load('g')local
Dalgona={}Dalgona.__index=Dalgona function Dalgona.new(UIManager)local self=
setmetatable({},Dalgona)self._UIManager=UIManager self._Maid=Maid.new()return
self end function Dalgona.Start(self)local DalgonaClientModule=(
ReplicatedStorage.Modules.Games.DalgonaClient)local CompleteDalgona=function()if
not self._UIManager:GetToggleValue('DalgonaAuto')then return end for _,Value in
ipairs(getreg())do if typeof(Value)=='function'and islclosure(Value)then if
getfenv(Value).script==DalgonaClientModule then if getinfo(Value).nups==73 then
setupvalue(Value,31,9e9)break end end end end end local OriginalDalgonaFunction
OriginalDalgonaFunction=hookfunction((require)(DalgonaClientModule),function(...
)task.delay(3,CompleteDalgona)return OriginalDalgonaFunction(...)end)self._Maid:
GiveTask(function()hookfunction((require)(DalgonaClientModule),
OriginalDalgonaFunction)self._UIManager.Toggles.DalgonaAuto:OnChanged(function()
end)end)self._UIManager.Toggles.DalgonaAuto:OnChanged(CompleteDalgona)warn(
'Dalgona feature started!')end function Dalgona.Destroy(self)warn(
'Dalgona feature destroyed!')self._Maid:Destroy()end return Dalgona end function
__DARKLUA_BUNDLE_MODULES.j()local ReplicatedStorage=game:GetService(
'ReplicatedStorage')local Maid=__DARKLUA_BUNDLE_MODULES.load('d')
__DARKLUA_BUNDLE_MODULES.load('g')local TugOfWar={}TugOfWar.__index=TugOfWar
function TugOfWar.new(UIManager)local self=setmetatable({},TugOfWar)self.
_UIManager=UIManager self._Maid=Maid.new()return self end function TugOfWar.
Start(self)local TemporaryReachedBindableRemote=ReplicatedStorage.Remotes.
TemporaryReachedBindable local PULL_RATE=0.025 local VALID_PULL_DATA={[
'PerfectQTE']=true}self._Maid:GiveTask(task.spawn(function()while task.wait(
PULL_RATE)do if self._UIManager:GetToggleValue('TugOfWarAuto')then
TemporaryReachedBindableRemote:FireServer(VALID_PULL_DATA)end end end))warn(
'TugOfWar feature started!')end function TugOfWar.Destroy(self)warn(
'TugOfWar feature destroyed!')self._Maid:Destroy()end return TugOfWar end
function __DARKLUA_BUNDLE_MODULES.k()local Maid=__DARKLUA_BUNDLE_MODULES.load(
'd')__DARKLUA_BUNDLE_MODULES.load('g')local GlassBridge={}GlassBridge.__index=
GlassBridge function GlassBridge.new(UIManager)local self=setmetatable({},
GlassBridge)self._UIManager=UIManager self._Maid=Maid.new()return self end
function GlassBridge.Start(self)local GlassHolder=(workspace.GlassBridge.
GlassHolder)local SetupGlassPart=function(GlassPart)local
CanEnableGlassBridgeESP=self._UIManager:GetToggleValue('GlassBridgeESP')if not
CanEnableGlassBridgeESP then GlassPart.Color=Color3.fromRGB(106,106,106)
GlassPart.Transparency=0.45 GlassPart.Material=Enum.Material.SmoothPlastic else
local Color=GlassPart:GetAttribute('exploitingisevil')and Color3.fromRGB(248,87,
87)or Color3.fromRGB(28,235,87)GlassPart.Color=Color GlassPart.Transparency=0
GlassPart.Material=Enum.Material.Neon end end self._UIManager.Toggles.
GlassBridgeESP:OnChanged(function()for _,PanelPair in ipairs(GlassHolder:
GetChildren())do for _,Panel in ipairs(PanelPair:GetChildren())do local
GlassPart=(Panel:FindFirstChild('glasspart'))if GlassPart then task.defer(
SetupGlassPart,GlassPart)end end end end)self._Maid:GiveTask(GlassHolder.
DescendantAdded:Connect(function(Descendant)if Descendant.Name=='glasspart'and
Descendant:IsA('BasePart')then task.defer(SetupGlassPart,Descendant)end end))
self._Maid:GiveTask(function()self._UIManager.Toggles.GlassBridgeESP:OnChanged(
function()end)end)warn('GlassBridge feature started!')end function GlassBridge.
Destroy(self)warn('GlassBridge feature destroyed!')self._Maid:Destroy()end
return GlassBridge end function __DARKLUA_BUNDLE_MODULES.l()local Players=game:
GetService('Players')local Maid=__DARKLUA_BUNDLE_MODULES.load('d')
__DARKLUA_BUNDLE_MODULES.load('g')local Mingle={}Mingle.__index=Mingle function
Mingle.new(UIManager)local self=setmetatable({},Mingle)self._UIManager=UIManager
self._Maid=Maid.new()return self end function Mingle.Start(self)local Client=
Players.LocalPlayer local CharacterMaid=Maid.new()self._Maid:GiveTask(
CharacterMaid)local OnCharacterAdded=function(Character)CharacterMaid:
DoCleaning()local OnRemoteForQTEAdded=function(RemoteForQTE)CharacterMaid:
GiveTask(task.spawn(function()while task.wait(0.5)do if not RemoteForQTE then
break end if not RemoteForQTE.Parent then break end if self._UIManager:
GetToggleValue('MinglePowerHoldAuto')then RemoteForQTE:FireServer()end end end))
end local OnChildAdded=function(Object)if Object.ClassName=='RemoteEvent'and
Object.Name=='RemoteForQTE'then OnRemoteForQTEAdded(Object)end end CharacterMaid
:GiveTask(Character.ChildAdded:Connect(OnChildAdded))for _,Object in ipairs(
Character:GetChildren())do task.spawn(OnChildAdded,Object)end end self._Maid:
GiveTask(Client.CharacterAdded:Connect(OnCharacterAdded))if Client.Character
then task.spawn(OnCharacterAdded,Client.Character)end warn(
'Mingle feature started!')end function Mingle.Destroy(self)warn(
'Mingle feature destroyed!')self._Maid:Destroy()end return Mingle end function
__DARKLUA_BUNDLE_MODULES.m()local ESP={Enabled=false,Boxes=true,BoxShift=CFrame.
new(0,-1.5,0),BoxSize=Vector3.new(4,6,0),Color=Color3.fromRGB(255,170,0),
FaceCamera=false,Names=true,TeamColor=true,Thickness=2,AttachShift=1,TeamMates=
true,Players=true,Objects=setmetatable({},{__mode='kv'}),Overrides={}}local cam=
workspace.CurrentCamera local plrs=game:GetService('Players')local plr=plrs.
LocalPlayer plr:GetMouse()local _=Vector3.new local WorldToViewportPoint=cam.
WorldToViewportPoint local Draw=function(obj,props)local new=Drawing.new(obj)
props=props or{}for i,v in pairs(props)do new[i]=v end return new end function
ESP:GetTeam(p)local ov=self.Overrides.GetTeam if ov then return ov(p)end return
p and p.Team end function ESP:IsTeamMate(p)local ov=self.Overrides.IsTeamMate if
ov then return ov(p)end return self:GetTeam(p)==self:GetTeam(plr)end function
ESP:GetColor(obj)local ov=self.Overrides.GetColor if ov then return ov(obj)end
local p=self:GetPlrFromChar(obj)return p and self.TeamColor and p.Team and p.
Team.TeamColor.Color or self.Color end function ESP:GetPlrFromChar(char)local ov
=self.Overrides.GetPlrFromChar if ov then return ov(char)end return plrs:
GetPlayerFromCharacter(char)end function ESP:Toggle(bool)self.Enabled=bool if
not bool then for i,v in pairs(self.Objects)do if v.Type=='Box'then if v.
Temporary then v:Remove()else for i,v in pairs(v.Components)do v.Visible=false
end end end end end end function ESP:GetBox(obj)return self.Objects[obj]end
function ESP:AddObjectListener(parent,options)local NewListener=function(c)if
type(options.Type)=='string'and c:IsA(options.Type)or options.Type==nil then if
type(options.Name)=='string'and c.Name==options.Name or options.Name==nil then
if not options.Validator or options.Validator(c)then local box=ESP:Add(c,{
PrimaryPart=type(options.PrimaryPart)=='string'and c:WaitForChild(options.
PrimaryPart)or type(options.PrimaryPart)=='function'and options.PrimaryPart(c),
Color=type(options.Color)=='function'and options.Color(c)or options.Color,
ColorDynamic=options.ColorDynamic,Name=type(options.CustomName)=='function'and
options.CustomName(c)or options.CustomName,IsEnabled=options.IsEnabled,
RenderInNil=options.RenderInNil})if options.OnAdded then coroutine.wrap(options.
OnAdded)(box)end end end end end if options.Recursive then parent.
DescendantAdded:Connect(NewListener)for i,v in pairs(parent:GetDescendants())do
coroutine.wrap(NewListener)(v)end else parent.ChildAdded:Connect(NewListener)for
i,v in pairs(parent:GetChildren())do coroutine.wrap(NewListener)(v)end end end
local boxBase={}boxBase.__index=boxBase function boxBase:Remove()ESP.Objects[
self.Object]=nil for i,v in pairs(self.Components)do v.Visible=false v:Remove()
self.Components[i]=nil end end function boxBase:Update()if not self.PrimaryPart
then return self:Remove()end local color if ESP.Highlighted==self.Object then
color=ESP.HighlightColor else color=self.Color or self.ColorDynamic and self:
ColorDynamic()or ESP:GetColor(self.Object)or ESP.Color end local allow=true if
ESP.Overrides.UpdateAllow and not ESP.Overrides.UpdateAllow(self)then allow=
false end if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player)
then allow=false end if self.Player and not ESP.Players then allow=false end if
self.IsEnabled and(type(self.IsEnabled)=='string'and not ESP[self.IsEnabled]or
type(self.IsEnabled)=='function'and not self:IsEnabled())then allow=false end if
not workspace:IsAncestorOf(self.PrimaryPart)and not self.RenderInNil then allow=
false end if not allow then for i,v in pairs(self.Components)do v.Visible=false
end return end if ESP.Highlighted==self.Object then color=ESP.HighlightColor end
local cf=self.PrimaryPart.CFrame if ESP.FaceCamera then cf=CFrame.new(cf.p,cam.
CFrame.p)end local size=self.Size local locs={TopLeft=cf*ESP.BoxShift*CFrame.
new(size.X/2,size.Y/2,0),TopRight=cf*ESP.BoxShift*CFrame.new(-size.X/2,size.Y/2,
0),BottomLeft=cf*ESP.BoxShift*CFrame.new(size.X/2,-size.Y/2,0),BottomRight=cf*
ESP.BoxShift*CFrame.new(-size.X/2,-size.Y/2,0),TagPos=cf*ESP.BoxShift*CFrame.
new(0,size.Y/2,0),Torso=cf*ESP.BoxShift}if ESP.Boxes then local TopLeft,Vis1=
WorldToViewportPoint(cam,locs.TopLeft.p)local TopRight,Vis2=
WorldToViewportPoint(cam,locs.TopRight.p)local BottomLeft,Vis3=
WorldToViewportPoint(cam,locs.BottomLeft.p)local BottomRight,Vis4=
WorldToViewportPoint(cam,locs.BottomRight.p)if self.Components.Quad then if Vis1
or Vis2 or Vis3 or Vis4 then self.Components.Quad.Visible=true self.Components.
Quad.PointA=Vector2.new(TopRight.X,TopRight.Y)self.Components.Quad.PointB=
Vector2.new(TopLeft.X,TopLeft.Y)self.Components.Quad.PointC=Vector2.new(
BottomLeft.X,BottomLeft.Y)self.Components.Quad.PointD=Vector2.new(BottomRight.X,
BottomRight.Y)self.Components.Quad.Color=color else self.Components.Quad.Visible
=false end end else self.Components.Quad.Visible=false end if ESP.Names then
local TagPos,Vis5=WorldToViewportPoint(cam,locs.TagPos.p)if Vis5 then self.
Components.Name.Visible=true self.Components.Name.Position=Vector2.new(TagPos.X,
TagPos.Y)self.Components.Name.Text=self.Name self.Components.Name.Color=color
self.Components.Distance.Visible=true self.Components.Distance.Position=Vector2.
new(TagPos.X,TagPos.Y+14)self.Components.Distance.Text=math.floor((cam.CFrame.p-
cf.p).magnitude)..'m away'self.Components.Distance.Color=color else self.
Components.Name.Visible=false self.Components.Distance.Visible=false end else
self.Components.Name.Visible=false self.Components.Distance.Visible=false end if
ESP.Tracers then local TorsoPos,Vis6=WorldToViewportPoint(cam,locs.Torso.p)if
Vis6 then self.Components.Tracer.Visible=true self.Components.Tracer.From=
Vector2.new(TorsoPos.X,TorsoPos.Y)self.Components.Tracer.To=Vector2.new(cam.
ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)self.Components.Tracer.Color
=color else self.Components.Tracer.Visible=false end else self.Components.Tracer
.Visible=false end end function ESP:Add(obj,options)if not obj.Parent and not
options.RenderInNil then return warn(obj,'has no parent')end local box=
setmetatable({Name=options.Name or obj.Name,Type='Box',Color=options.Color,Size=
options.Size or self.BoxSize,Object=obj,Player=options.Player or plrs:
GetPlayerFromCharacter(obj),PrimaryPart=options.PrimaryPart or obj.ClassName==
'Model'and(obj.PrimaryPart or obj:FindFirstChild('HumanoidRootPart')or obj:
FindFirstChildWhichIsA('BasePart'))or obj:IsA('BasePart')and obj,Components={},
IsEnabled=options.IsEnabled,Temporary=options.Temporary,ColorDynamic=options.
ColorDynamic,RenderInNil=options.RenderInNil},boxBase)if self:GetBox(obj)then
self:GetBox(obj):Remove()end box.Components['Quad']=Draw('Quad',{Thickness=self.
Thickness,Color=color,Transparency=1,Filled=false,Visible=self.Enabled and self.
Boxes})box.Components['Name']=Draw('Text',{Text=box.Name,Color=box.Color,Center=
true,Outline=true,Size=19,Visible=self.Enabled and self.Names})box.Components[
'Distance']=Draw('Text',{Color=box.Color,Center=true,Outline=true,Size=19,
Visible=self.Enabled and self.Names})box.Components['Tracer']=Draw('Line',{
Thickness=ESP.Thickness,Color=box.Color,Transparency=1,Visible=self.Enabled and
self.Tracers})self.Objects[obj]=box obj.AncestryChanged:Connect(function(_,
parent)if parent==nil and ESP.AutoRemove~=false then box:Remove()end end)obj:
GetPropertyChangedSignal('Parent'):Connect(function()if obj.Parent==nil and ESP.
AutoRemove~=false then box:Remove()end end)local hum=obj:FindFirstChildOfClass(
'Humanoid')if hum then hum.Died:Connect(function()if ESP.AutoRemove~=false then
box:Remove()end end)end return box end local CharAdded=function(char)local p=
plrs:GetPlayerFromCharacter(char)if not char:FindFirstChild('HumanoidRootPart')
then local ev ev=char.ChildAdded:Connect(function(c)if c.Name==
'HumanoidRootPart'then ev:Disconnect()ESP:Add(char,{Name=p.Name,Player=p,
PrimaryPart=c})end end)else ESP:Add(char,{Name=p.Name,Player=p,PrimaryPart=char.
HumanoidRootPart})end end local PlayerAdded=function(p)p.CharacterAdded:Connect(
CharAdded)if p.Character then coroutine.wrap(CharAdded)(p.Character)end end plrs
.PlayerAdded:Connect(PlayerAdded)for i,v in pairs(plrs:GetPlayers())do if v~=plr
then PlayerAdded(v)end end game:GetService('RunService').RenderStepped:Connect(
function()cam=workspace.CurrentCamera for i,v in(ESP.Enabled and pairs or ipairs
)(ESP.Objects)do if v.Update then local s,e=pcall(v.Update,v)if not s then warn(
'[EU]',e,v.Object:GetFullName())end end end end)return ESP end function
__DARKLUA_BUNDLE_MODULES.n()local Players=game:GetService('Players')local Maid=
__DARKLUA_BUNDLE_MODULES.load('d')__DARKLUA_BUNDLE_MODULES.load('g')local
HideAndSeek={}HideAndSeek.__index=HideAndSeek function HideAndSeek.new(UIManager
)local self=setmetatable({},HideAndSeek)self._UIManager=UIManager self._Maid=
Maid.new()self._ESP=__DARKLUA_BUNDLE_MODULES.load('m')return self end function
HideAndSeek.Start(self)local ROLES_DATA={IsHider={Name='Hider',Color=Color3.
fromRGB(0,255,230),Flag='Hiders'},IsHunter={Name='Hunter',Color=Color3.fromRGB(
251,0,0),Flag='Hunters'}}local Client=Players.LocalPlayer local BoxObjects={}
local OnPlayerAdded=function(Player)if Player==Client then return end local
PlayerMaid=Maid.new()self._Maid:GiveTask(PlayerMaid)local CharacterMaid=Maid.
new()PlayerMaid:GiveTask(CharacterMaid)local OnCharacterAdded=function(Character
)CharacterMaid:DoCleaning()local RootPart=Character:WaitForChild(
'HumanoidRootPart')local OnRoleAdded=function(Role)local RoleData=ROLES_DATA[
Role]table.insert(BoxObjects,self._ESP:Add(Character,{Name='Role: '..RoleData.
Name..' | '..'Player Name: '..Player.Name,Color=RoleData.Color,PrimaryPart=
RootPart,IsEnabled=RoleData.Flag}))end for _,Attribute in ipairs({'IsHider',
'IsHunter'})do CharacterMaid:GiveTask(Player:GetAttributeChangedSignal(Attribute
):Connect(function()if Player:GetAttribute(Attribute)~=true then return end
OnRoleAdded(Attribute)end))if Player:GetAttribute(Attribute)==true then task.
spawn(OnRoleAdded,Attribute)end end end PlayerMaid:GiveTask(Player.
AncestryChanged:Connect(function(_,NewParent)if NewParent then return end
PlayerMaid:Destroy()end))PlayerMaid:GiveTask(Player.CharacterAdded:Connect(
OnCharacterAdded))if Player.Character then task.spawn(OnCharacterAdded,Player.
Character)end end self._Maid:GiveTask(Players.PlayerAdded:Connect(OnPlayerAdded)
)for _,Player in ipairs(Players:GetPlayers())do task.spawn(OnPlayerAdded,Player)
end self._UIManager.Toggles.HiderESP:OnChanged(function()self._ESP.Hiders=self.
_UIManager:GetToggleValue('HiderESP')end)self._UIManager.Toggles.HunterESP:
OnChanged(function()self._ESP.Hunters=self._UIManager:GetToggleValue('HunterESP'
)end)self._Maid:GiveTask(function()for _,Box in ipairs(BoxObjects)do Box:Remove(
)end table.clear(BoxObjects)self._ESP:Toggle(false)self._UIManager.Toggles.
HiderESP:OnChanged(function()end)self._UIManager.Toggles.HunterESP:OnChanged(
function()end)end)self._ESP.Players=true self._ESP:Toggle(true)warn(
'HideAndSeek feature started!')end function HideAndSeek.Destroy(self)warn(
'HideAndSeek feature destroyed!')self._Maid:Destroy()end return HideAndSeek end
end assert(game.GameId==7008097940,'Invalid Game!')local Signal=
__DARKLUA_BUNDLE_MODULES.load('b')if not shared._InkGameScriptState then shared.
_InkGameScriptState={IsScriptExecuted=false,IsScriptReady=false,ScriptReady=
Signal.new(),Cleanup=function()end}end local GlobalScriptState=shared.
_InkGameScriptState if GlobalScriptState.IsScriptExecuted then if not
GlobalScriptState.IsScriptReady then GlobalScriptState.ScriptReady:Wait()if
GlobalScriptState.IsScriptReady then return end end GlobalScriptState.Cleanup()
end GlobalScriptState.IsScriptExecuted=true if not game:IsLoaded()then game.
Loaded:Wait()end local UI=__DARKLUA_BUNDLE_MODULES.load('g').new()local
GameState=(workspace:WaitForChild('Values'))local CurrentGame=(GameState:
WaitForChild('CurrentGame'))local Features={['RedLightGreenLight']=
__DARKLUA_BUNDLE_MODULES.load('h'),['Dalgona']=__DARKLUA_BUNDLE_MODULES.load('i'
),['TugOfWar']=__DARKLUA_BUNDLE_MODULES.load('j'),['GlassBridge']=
__DARKLUA_BUNDLE_MODULES.load('k'),['Mingle']=__DARKLUA_BUNDLE_MODULES.load('l')
,['HideAndSeek']=__DARKLUA_BUNDLE_MODULES.load('n')}local CurrentRunningFeature=
nil local GameChangedConnection=nil local CleanupCurrentFeature=function()if
CurrentRunningFeature then CurrentRunningFeature:Destroy()CurrentRunningFeature=
nil end end local CurrentGameChanged=function()warn('Current game: '..
CurrentGame.Value)CleanupCurrentFeature()local Feature=Features[CurrentGame.
Value]if not Feature then return end CurrentRunningFeature=Feature.new(UI)
CurrentRunningFeature:Start()end GameChangedConnection=CurrentGame:
GetPropertyChangedSignal('Value'):Connect(CurrentGameChanged)CurrentGameChanged(
)GlobalScriptState.Cleanup=function()CleanupCurrentFeature()if
GameChangedConnection then GameChangedConnection:Disconnect()
GameChangedConnection=nil end if not UI.IsDestroyed then UI:Destroy()end
GlobalScriptState.IsScriptReady=false GlobalScriptState.IsScriptExecuted=false
end GlobalScriptState.IsScriptReady=true GlobalScriptState.ScriptReady:Fire()UI:
Notify('Script executed successfully!',4)UI:Notify(
'Script authored by: Jorsan, enjoy!',4)