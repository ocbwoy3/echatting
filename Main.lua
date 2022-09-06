 
-- Import libraries
local GUI = require("GUI")
local system = require("System")
local event = require("Event")
local internet = require("Internet")

---------------------------------------------------------------------------------

-- Add a new window to MineOS workspace
local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 60*1.5, 20*1.5, 0xE1E1E1))
--menu = nil

--local menu = workspace:addChild(GUI.menu(1, 1, workspace.width, 0xEEEEEE, 0x666666, 0x3366CC, 0xFFFFFF))

-- Get localization table dependent of current system language
local localization = system.getCurrentScriptLocalization()

-- Add single cell layout to window
local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))

function addString(ok)
  return layout:addChild(GUI.text(1, 1, 0x4B4B4B, ok))
end

local genderMap = {
  localization.genders.male;
  localization.genders.female;
  localization.genders.nonbinary;
  localization.genders.private;
}

function addEntry(user_data)
  -- add text box to layout
  local textBox = layout:addChild(GUI.textBox(2, 2, 60, 3, 0xEEEEEE, 0x2D2D2D, {}, 1, 1, 0))
  -- parse user data
  local ign = user_data[1]
  local alias = user_data[2]
  local age = user_data[3]
  local gender = user_data[4]
  local purpose = user_data[5]
  local favourite_servers = user_data[6]

  -- prepare lines
  local line1 = ign .. " "
  if alias then
    line1 = line1 .. string.format("(%s)  ",alias)
  else
    line1 = line1 .. "  "
  end
  if age ~= -1 then
    line1 = line1 .. tostring(age)
    if gender ~= 4 then
      line1 = line1 .. ", "
    end
  end
  if gender ~= 4 then
    line1 = line1 .. genderMap[gender]
  end

  local line2 = tostring(purpose)
  local line3 = localization.favouriteServers:format(localization.none)
  local line3x = ""

  if favourite_servers then
    line3 = localization.favouriteServers
    line3x = line3x .. tostring(favourite_servers[1])
    if favourite_servers[2] then
      line3x = line3x .. ", " .. tostring(favourite_servers[2])
    end
  end

  -- add lines to text box
  textBox.lines = {line1, line2, line3:format(line3x)}

  return textBox
end

local userLoggedIn = false

-- How entries work: Each entry is a table with the following fields:
-- User's Minecraft IGN, Their alias, their age, their gender as an integer, purpose for using E-Chatting.app and their favourite minecraft servers
-- If age is -1, it is considered as "private" and won't be shown
-- If gender is 4 then it considered "private" and won't be shown (refer to genderMap)

local entries = {
  {"BranzyCraft","Branzy",-1,4,'E-Chatting - Test',{'Lifesteal SMP','EchoCraft','Hypixel, I guess?'}};  
  {"echatting-test","test account",-1,4,'test',{"Hypixel"}}
}

local entriesObj = {}

local function updateEntries()
  local allEntries = #entries
  -- Add a background container to workspace with background panel and layout
  local container = GUI.addBackgroundContainer(workspace, true, true, localization.updatingEntries)
  -- Add a switch and label to it's layout
  local pg = container.layout:addChild(GUI.progressBar(2, 2, 80, 0x3366CC, 0xEEEEEE, 0xEEEEEE, 80, true, true)) --, localization.entryUpdateProgressbar1, localization.entryUpdateProgressbar2:format(#entries)))

  for i,entry in pairs(entriesObj) do
    entry:remove()
  end

  local entriesObj = {}

  -- add each entry
  for i,entry in pairs(entries) do
    pg.value = math.floor(100/allEntries)*i
    entriesObj[i] = addEntry(entry)
    event.sleep(0.1)
    --computer.pullSignal(1)
  end

  container:remove()

end

function _G.ec_setEntries(entry)
  entries = entry
  GUI.alert(localization.developer.entryUpdate)
end

function _G.ec_reloadGui()
  updateEntries()
  GUI.alert(localization.developer.entryReload)
end

function _G.ec_getAll()
  GUI.alert(localization.developer.entryGetAll)
  return entries
end

menu:removeChildren()
local appMenu = menu:addContextMenuItem("E-Chatting",0x0)
appMenu:addItem(localization.updateEntries).onTouch = function()
  if userLoggedIn == true then
    updateEntries()
  else
    GUI.alert(localization.developer.entryUpdateFail)
  end
end
appMenu:addItem(localization.addEntry, true).onTouch = function()
  local container = GUI.addBackgroundContainer(workspace, true, true, localization.addEntry)
  local ign = container.layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D))
  local alias = container.layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D))
  local age = container.layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D))
  local gender = container.layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D))
  local bio = container.layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D))
  local server1 = container.layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D))
  local server2 = container.layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D))
  
  -- and a button to submit
  local submit = container.layout:addChild(GUI.roundedButton(2, 18, 30, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, localization.addEntry))
  -- when submit clicked, add entry
  submit.onTouch = function()

    -- parse entry data in input fields
    local entry = {
      tostring(ign.text),
      tostring(alias.text) or nil,
      tonumber(age.text) or -1,
      tonumber(gender.text) or 4,
      tostring(bio.text) or 'ok',
      {
        tostring(server1.text) or nil,
        tostring(server2.text) or nil
      }
    }

    if success then
      table.insert(entries, entry)
      GUI.alert(localization.entryEditor.success)
    else
        GUI.alert(localization.entryEditor.error)
    end
  end
end

-- E-Chatting WIP Test account settings

-- Login
local SETTINGS_PHONE_NUMBER = "+371 TESTING" -- Your phone number here
local SETTINGS_EMAIL = "ocboy3@echatting.lv" -- Your e-mail here
local SETTINGS_PASSWORD = "branzy" -- Your E-Chatting password here

-- Account status
local SETTINGS_BANNED = false; -- wip, defines if account is banned
local SETTINGS_BAN_INFO = {
  moderatorNote = "Las imágenes de citas y envíos no están permitidas en Roblox.";
  offensiveItems = {
    {"other","download my virus"};
    {"other","plz"};
    {"other","github ocboy3/OC"};
    {"other","download ochammer2 virus"};
  };
  banType = "warning";
  showNumbers = false;
  showNumberSerious = nil; 
}

-- E-Chatting menu settings
local QPANEL_ACCOUNT_NAME = "OCboy3"
local QPANEL_ACCOUNT_AGE_RANGE = localization.qpanel.account_13plus

-- compile the settings lol

-- make SETTINGS_PHONE_NUMBER no spaces
SETTINGS_PHONE_NUMBER = SETTINGS_PHONE_NUMBER:gsub(" ", "")

-- Menu

appMenu:addItem(string.format(localization.qpanel.account, QPANEL_ACCOUNT_NAME, QPANEL_ACCOUNT_AGE_RANGE),true)
appMenu:addItem(localization.settings,true)
appMenu:addSeparator()
appMenu:addItem(localization.close,false,"^W").onTouch = function()
  window:remove()
end
appMenu:addItem(localization.about).onTouch = function()
  local aboutWindow = GUI.addBackgroundContainer(workspace, true, true, localization.about)
  local function aboutAdd(text)
    aboutWindow.layout:addChild(GUI.text(1, 1, 0xFFFF00, text))
  end

  for i,v in pairs(localization.credits) do
    aboutAdd(v)
  end
end

-- add a input for username and password
local greeting = addString(localization.misc.loginTitleWelcome)
local subt1 = addString(localization.misc.loginSubtitle)
local subt2 = addString(localization.misc.loginSubtitle2)

local username = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, nil, localization.login.username))
local password = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, nil, localization.login.password, false, '•'))
-- add login button
local login = layout:addChild(GUI.roundedButton(1, 1, 30, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, localization.login.confirm))

login.onTouch = function()
  -- if username is equal to email or phone number and password is equal to password then
  if username.text:gsub(" ", "") == SETTINGS_PHONE_NUMBER or username.text == SETTINGS_EMAIL and password.text == SETTINGS_PASSWORD then
    userLoggedIn = true
    -- remove welcome message and that stuff
    greeting:remove()
    subt1:remove()
    subt2:remove()
    -- remove login inputs
    username:remove()
    password:remove()
    -- remove login button
    login:remove()
    -- refresh entries
    updateEntries()
  else
    GUI.alert(localization.login.failedLogin)
  end
end

-- Create callback function with resizing rules when window changes its' size
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight
end

---------------------------------------------------------------------------------

-- Draw changes on screen after customizing your window
workspace:draw()