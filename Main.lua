
-- Importēt bibliotēkas un to funkcijas
local GUI = require("GUI")
local system = require("System")
local event = require("Event")
local internet = require("Internet")

---------------------------------------------------------------------------------

local function createQr(data)
  -- Koda optimizācijas
  return require('qr').createPic(require('qr').encode(data))
end

-- Sākt E-Chatting initalizāciju
local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 60*1.5, 20*1.5, 0xE1E1E1))
local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))
-- Dabūt lietotnes lokalizāciju (Latviski vai angliski)
local locale = system.getCurrentScriptLocalization()

-- Definēt testa konta datus, noņemt vēlāk.

local ACCOUNT = {
  -- Lietotāja dati
  username = "OCboy3";
  nick = "OCboy3";
  age = -1;
  agegroup = "13+";
  status = "Online";
  ec_developer = true;
  ec_special = "owner";

  -- Lietotājvārdi, paroles utt.
  email = "testacc@echatting.lv";
  number = "+371 TESTING";
  password = "branzy";
  
  -- E-Chatting+ abonomenta statuss
  ecplus_tier = "E-Chatting+ Founder's edition"; -- skatoties pēc ecplus_prices
  ecplus_prices = { -- EUR/mēn
    ["E-Chatting+"] = "3€";
    ["E-Chatting+ (Student pricing)"] = "1€";
    ["E-Chatting+ Founder's edition"] = "exclusive";
  }

}

---------------------------------------------------------------------------------

local function qrcodePanel(link,txt,title)
  if not title then title = locale.qrmenu.title end
  local qrcontainer = GUI.addBackgroundContainer(workspace, true, true, title)
  local qrImage = qrcontainer.layout:addChild(GUI.image(1,1,createQr(link)))
  for i,v in pairs(txt) do
    qrcontainer.layout:addChild(GUI.text(1,1,0xFFFF00,v))
  end
  workspace:draw()
end

_G.ec_qrp = qrcodePanel

-- Initalizēt E-Chatting izvēlni
menu:removeChildren()
local ctxmenu = menu:addContextMenuItem(locale.qpanel.ec_menu,0x0)
local statusChangeButton = ctxmenu:addItem(locale.qpanel.change_status, true)
local userButton = ctxmenu:addItem(string.format(locale.qpanel.user,ACCOUNT.username,ACCOUNT.agegroup), true)
local settingsButton = ctxmenu:addItem(locale.qpanel.settings, true)
ctxmenu:addSeparator()
local closeButton = ctxmenu:addItem(locale.qpanel.close,false,locale.qpanel.closeKeys) closeButton.onTouch = function() window:remove() end
local creditsButton = ctxmenu:addItem(locale.qpanel.credits_title, false)

creditsButton.onTouch = function()
  local creditsContainer = GUI.addBackgroundContainer(workspace, true, true, locale.qpanel.credits_title)
  for i,v in pairs(locale.qpanel.credits) do local creditsTextBox = creditsContainer.layout:addChild(GUI.text(1,1,0xFFFF00,v)) end
  workspace:draw()
end

---------------------------------------------------------------------------------

-- Ielogošanās ekrāns.

local ecWelcome = layout:addChild(GUI.text(1, 1, 0x4B4B4B, locale.welcome.title1))
local ecUsername = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x000000, 0x999999, 0xFFFFFF, 0x2D2D2D, "", locale.welcome.userinput, false))
local ecPassword = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x000000, 0x999999, 0xFFFFFF, 0x2D2D2D, "", locale.welcome.passinput, true, "•"))
local ecLogin = layout:addChild(GUI.roundedButton(2, 18, 30, 3, 0xFFFFFF, 0x555555, 0xE1E1E1, 0xFFFFFF, locale.welcome.login))
local ecReset = layout:addChild(GUI.roundedButton(2, 18, 30, 1, 0xE1E1E1, 0x555555, 0xE1E1E1, 0xFFFFFF, locale.welcome.forgot))
local ecNew = layout:addChild(GUI.roundedButton(2, 18, 30, 1, 0xE1E1E1, 0x555555, 0xE1E1E1, 0xFFFFFF, locale.welcome.createaccount))

ecLogin.onTouch = function()
  if ecUsername.Text:gsub(' ','') ~= ACCOUNT.number:gsub(' ','') then
    GUI.alert('Nepareizs e-pasts, telefona numurs vai parole.')
    return
  elseif ecUsername.Text ~= ACCOUNT.email then
    GUI.alert('Nepareizs e-pasts, telefona numurs vai parole.')
  elseif ecPassword.Text ~= ACCOUNT.password then
    GUI.alert('Nepareizs e-pasts, telefona numurs vai parole.')
    return
  else
    qrcodePanel("NEUZTICATIES ERNESTAM VIŅŠ NAV ECHATTING ĪPAŠNIEKS!!!! ES ESMU (OCboy3) https://tiktok.com/@__ocboy3__",{'Noskenēniet QR kodu, izmantojot E-Chatting lietotni','vai app.echatting.lv/2sv'},'E-Chatting - Divpakāpju verifikācija')
  end
end

ecReset.onTouch = function()
  GUI.alert('CASE SENSITIVE. Nnumurs ir +371 TESTING\nEpasts ir ocboy3@echatting.lv\nParole ir branzy')
end

ecNew.onTouch = function()
  qrcodePanel("MAN 7.I VNK BESĪ ĀRĀ KAD ES VARĒŠU IET PROM NO VIŅIEM",{"Noskenējiet QR kodu lai reģistrētos."},'Izveidot E-Chatting kontu')
end


---------------------------------------------------------------------------------

-- Izveidot loga izmēra maiņas funkciju
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight
end

-- Zīmēt izmaiņas uz ekrāna
workspace:draw()
