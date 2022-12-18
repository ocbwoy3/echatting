
-- Importēt bibliotēkas un to funkcijas
local GUI = require("GUI")
local system = require("System")
local event = require("Event")
local internet = require("Internet")

---------------------------------------------------------------------------------

local function createQr(data)
  -- Koda optimizācijas
  local a = require('qr').createPic(require('qr').encode(data))
  package.loaded['qr'] = nil
  return a
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

-- E-Chatting+

local isBroke = true

_G.ec_setBroke = function(a) isBroke = a end

local function loginComplete()
  layout:removeChildren()
  local gftc1 = layout:addChild(GUI.text(1, 1, 0x4B4B4B, locale.giftcards.title))
  local gftc2 = layout:addChild(GUI.text(1, 1, 0x4B4B4B, locale.giftcards.cost))
  
  local eccn = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x000000, 0x999999, 0xFFFFFF, 0x2D2D2D, "", locale.buy.cc, false))
  local eca1 = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x000000, 0x999999, 0xFFFFFF, 0x2D2D2D, "", locale.buy.address1, false))
  local eca2 = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x000000, 0x999999, 0xFFFFFF, 0x2D2D2D, "", locale.buy.address2, false))
  local ecpi = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x000000, 0x999999, 0xFFFFFF, 0x2D2D2D, "", locale.buy.index, false))
  local ecco = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x000000, 0x999999, 0xFFFFFF, 0x2D2D2D, "", locale.buy.country, false))
  local ecc2 = layout:addChild(GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x000000, 0x999999, 0xFFFFFF, 0x2D2D2D, "", locale.buy.special, true, "•"))

  local ecBuy = layout:addChild(GUI.roundedButton(2, 18, 30, 3, 0xFFFFFF, 0x555555, 0xE1E1E1, 0xFFFFFF, string.format(locale.buy.buyV,"1,5 EUR")))
  ecBuy.onTouch = function()
    if isBroke == false then
      GUI.alert(locale.giftcards.ecplus)
    else
      GUI.alert(locale.buy.cceror)
    end
  end
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
  local function passwd(reslt)
    if ecPassword.text == ACCOUNT.password then
      return reslt()
    else
      GUI.alert(locale.welcome.fail)
    end
  end
  local function xd()
    qrcodePanel("NEUZTICATIES ERNESTAM VIŅŠ NAV ECHATTING ĪPAŠNIEKS!!!! ES ESMU (OCboy3) https://tiktok.com/@__ocboy3__",locale.qrmenu.ins,locale.qrmenu['2sv'])
    loginComplete()
    return nil
  end
  
  if ecUsername.text:gsub(' ','') == ACCOUNT.number:gsub(' ','') then
    return passwd(xd)
  elseif ecUsername.text == ACCOUNT.email then
    return passwd(xd)
  else
    GUI.alert(locale.welcome.fail)
    return nil
  end
  GUI.alert('E-Chatting.LoginHandler kļūda: 0')
end

ecReset.onTouch = function()
  GUI.alert('CASE SENSITIVE. Tel: +371 TESTING\ntestacc@echatting.lv\nParole ir branzy')
end

ecNew.onTouch = function()
  qrcodePanel("MAN 7.I VNK BESĪ ĀRĀ KAD ES VARĒŠU IET PROM NO VIŅIEM",locale.qrmenu.ins,locale.qrmenu.newacc)
end


---------------------------------------------------------------------------------

-- Izveidot loga izmēra maiņas funkciju
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight
end

-- Zīmēt izmaiņas uz ekrāna
workspace:draw()
