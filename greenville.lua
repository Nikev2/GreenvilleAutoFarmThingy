if not game:IsLoaded() then game.Loaded:Wait() end
local plr = game.Players.LocalPlayer
local Char = plr.Character
local workspace = game.workspace
local Twist = workspace.Workplaces.Twist

function calculateChange(input)
    
    local amount = tonumber(string.match(input, "%d+%.?%d*")) or 0

    
    local billDenominations = {20, 5, 1}
    local coinDenominations = {0.25, 0.05, 0.01}

    
    local bills = {
        [20] = 0,
        [5] = 0,
        [1] = 0
    }

    local coins = {
        [0.25] = 0,
        [0.05] = 0,
        [0.01] = 0
    }

    
    for _, bill in ipairs(billDenominations) do
        bills[bill] = math.floor(amount / bill)
        amount = amount % bill
    end

    
    amount = math.floor(amount * 100 + 0.5) / 100

   
    for _, coin in ipairs(coinDenominations) do
        coins[coin] = math.floor(amount / coin)
        amount = amount % coin
    end

    return bills, coins
end



function GetRegister()
    local R
    for _,ShoppingStation in pairs(Twist:GetChildren()) do
        if ShoppingStation.Name=="_ShoppingStation" then
            if ShoppingStation:FindFirstChild("NPC") then
                R = ShoppingStation.CashRegister
                break
            end
        end
    end
    return R
end
local function GetChildrenOfClass(parent, ClassName)
    local childrenOfClass = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA(ClassName) then
            table.insert(childrenOfClass, child)
        end
    end
    return childrenOfClass
end
local Register = GetRegister()
local Lists = Register.Pad.Display.Register
local Customer = Register.Parent.NPC

function GetOrderButtons(NPC)
    local Order=NPC.Head.ImageBubble.Frame
    local FoodList, DrinkList = Lists.FoodList, Lists.DrinkList
    local Food, Drink = Order.Food, Order.Drink --Speech bubble
    
    local F, D --Register
    for _,f in pairs(GetChildrenOfClass(FoodList,"ImageButton")) do
        if f.Image == Food.Image then
            F = f
            break
        end
    end
    for _,d in pairs(GetChildrenOfClass(DrinkList,"ImageButton")) do
        if d.Image == Drink.Image then
            D = d
            break
        end
    end
    return F, D
end

 local Remote=game:GetService("ReplicatedStorage").Remote.RestaurantJob
function TakeOrder()
    local FoodButton, DrinkButton = GetOrderButtons(Customer)
   
    Remote:InvokeServer("food",Register.Parent,FoodButton.Name)
    Remote:InvokeServer("drink",Register.Parent,DrinkButton.Name)
end
local function stringtonum(input)
    return tonumber(string.match(input, "%d+%.?%d*"))
end
function GiveChange()
    local ChangeAmount = Lists.Frame.Received.Text
    local bills, coins = calculateChange(ChangeAmount)
    
    for denomination, amount in pairs(bills) do 
       
        if amount > 0 then 
            for i=1,amount do
            Remote:InvokeServer("change",Register.Parent,denomination)
            end
        end
    end
   
    for denomination, amount in pairs(coins) do --spamming pennies works more stable for some fucking reason
        for i=1,amount do
            
            Remote:InvokeServer("change",Register.Parent,denomination)
        end
    end
  
end
function fcd(cd)
    fireclickdetector(cd)
    task.wait()
end

function PrepareOrder()
    local Tray = Twist.Tray.ClickDetector
    local PlaceTray = Twist.PlaceTray.ClickDetector
    local FoodModels = Twist.Food
    local DrinkModels = Twist.Drinks
    FoodName, DrinkName = GetOrderButtons(Customer)
    FoodName = FoodName.Name
    DrinkName = DrinkName.Name
    fcd(Tray)
    fcd(FoodModels[FoodName].ClickDetector)
    fcd(DrinkModels[DrinkName].ClickDetector)
    fcd(PlaceTray)
end






function Cycle()
    task.wait()
    TakeOrder()
    GiveChange()
    -----Oh wait nvm THIS should fix the fucking rounding bug
    while task.wait() do
        if Register.Parent:FindFirstChild("NPC") then
            Remote:InvokeServer("change",Register.Parent,0.01)
        else
            break
        end
    end
    PrepareOrder()
end
getgenv().AutoFarm = false





function Init()
   repeat task.wait() ---Waiting for customer logic
   -----Refresh vars
    if getgenv().AutoFarm==false then break end
    Lists = Register.Pad.Display.Register
    Customer = Register.Parent:FindFirstChild("NPC")
    if Customer then
      while task.wait() do
         if Customer:WaitForChild("Head").ImageBubble.Enabled==true then
            break
         end
      end
      Cycle()
    end
    
    until getgenv().AutoFarm == false
end

local UserInputService = game:GetService("UserInputService")

getgenv().AutoFarm = true
Init()
local function onKeyPress(input, gameProcessed)
   
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.P then
       getgenv().AutoFarm = not getgenv().AutoFarm
        spawn(function()
            Init()
        end)
    end
end

UserInputService.InputBegan:Connect(onKeyPress)




