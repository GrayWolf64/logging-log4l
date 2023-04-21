--- Client GUI (MMC).
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local ClientGUIDerma = include("log4g/mmc-gui/client/ClientGUIDerma.lua")
local CreateDFrame, CreateDPropertySheet = ClientGUIDerma.CreateDFrame, ClientGUIDerma.CreateDPropertySheet
local CreateDPropRow, GetRowControl = ClientGUIDerma.CreateDPropRow, ClientGUIDerma.GetRowControl
local Frame = nil
local next = next
local JSONToTable = util.JSONToTable
local pairs, isstring, tostring = pairs, isstring, tostring
local netReceive = net.Receive
local netStart = net.Start
local sendToServer = net.SendToServer

concommand.Add("log4g_mmc", function()
    if IsValid(Frame) then
        Frame:Remove()

        return
    end

    local function GetGameInfo()
        return "Server: " .. game.GetIPAddress() .. " " .. "SinglePlayer: " .. tostring(game.SinglePlayer())
    end

    Frame = CreateDFrame(700, 400, "Log4g Monitoring & Management Console" .. " - " .. GetGameInfo(), "icon16/application.png", nil)
    local MenuBar = vgui.Create("DMenuBar", Frame)
    local ViewMenu = MenuBar:AddMenu("View")
    local Icon = vgui.Create("DImageButton", MenuBar)
    Icon:Dock(RIGHT)
    Icon:DockMargin(4, 4, 4, 4)

    local function SendEmptyMsgToSV(msgn)
        netStart(msgn)
        sendToServer()
    end

    local function UpdateIcon()
        Icon:SetImage("icon16/disconnect.png")
        SendEmptyMsgToSV("Log4g_CLReq_ChkConnected")

        netReceive("Log4g_CLRcv_ChkConnected", function()
            if not net.ReadBool() then return end
            Icon:SetImage("icon16/connect.png")
        end)
    end

    Icon:SetKeepAspect(true)
    Icon:SetSize(16, 16)
    local BaseSheet = CreateDPropertySheet(Frame, FILL, 0, 1, 0, 0, 4)
    local BasePanel = vgui.Create("DPanel", BaseSheet)
    BasePanel.Paint = nil
    local SummaryPanel = vgui.Create("DPanel", BaseSheet)
    BaseSheet:AddSheet("Summary", SummaryPanel, "icon16/table.png")
    local SummarySheet = vgui.Create("DProperties", SummaryPanel)
    SummarySheet:Dock(FILL)

    local function CreateSpecialRow(category, name)
        local control = GetRowControl(CreateDPropRow(SummarySheet, category, name, "Generic"))
        control:SetEditable(false)

        return control
    end

    local RowA, RowB, RowC, RowD = CreateSpecialRow("Client", "OS Date"), CreateSpecialRow("Server", "Estimated Tickrate"), CreateSpecialRow("Server", "Floored Lua Dynamic RAM Usage (kB)"), CreateSpecialRow("Server", "Entity Count")
    local RowE, RowF, RowG, RowH = CreateSpecialRow("Server", "Networked Entity (EDICT) Count"), CreateSpecialRow("Server", "Net Receiver Count"), CreateSpecialRow("Server", "Lua Registry Table Element Count"), CreateSpecialRow("Server", "Constraint Count")
    local RowI, RowJ, RowK = CreateSpecialRow("Server", "Uptime (Seconds)"), CreateSpecialRow("Server", "_G Element Count"), CreateSpecialRow("Logging System", "LoggerContext Count")

    local function UpdateTime()
        RowA:SetValue(tostring(os.date()))
    end

    local function setValue(row, value)
        row:SetValue(tostring(value))
    end

    local function UpdateSummary()
        SendEmptyMsgToSV("Log4g_CLReq_SVSummaryData")

        netReceive("Log4g_CLRcv_SVSummaryData", function()
            setValue(RowB, 1 / engine.ServerFrameTime())
            setValue(RowC, net.ReadFloat())
            setValue(RowD, net.ReadUInt(14))
            setValue(RowE, net.ReadUInt(13))
            setValue(RowF, net.ReadUInt(12))
            setValue(RowG, net.ReadUInt(32))
            setValue(RowH, net.ReadUInt(16))
            setValue(RowI, net.ReadDouble())
            setValue(RowJ, net.ReadUInt(32))
            setValue(RowK, net.ReadUInt(16))
        end)
    end

    local ConfigurationPanel = vgui.Create("DPanel", BaseSheet)
    BaseSheet:AddSheet("Configuration", ConfigurationPanel, "icon16/wrench.png")
    local ButtonGrid = vgui.Create("DGrid", ConfigurationPanel)
    ButtonGrid:Dock(TOP)
    ButtonGrid:DockMargin(2, 2, 2, -2)
    ButtonGrid:SetCols(2)
    ButtonGrid:SetColWide(300)
    local ConfigFileOption = vgui.Create("DComboBox")
    ConfigFileOption:SetWide(300)
    ConfigFileOption:SetTall(25)
    ButtonGrid:AddItem(ConfigFileOption)
    local TextEditor = vgui.Create("DTextEntry", ConfigurationPanel)
    TextEditor:SetMultiline(true)
    TextEditor:Dock(FILL)
    TextEditor:DockMargin(2, -2, 2, 2)
    TextEditor:SetDrawLanguageID(false)
    TextEditor:SetFont("Log4gMMCConfigFileEditorDefault")
    TextEditor:SetVerticalScrollbarEnabled(true)

    local function ClearTextEditor()
        TextEditor:SetValue("")
        TextEditor:SetEditable(false)
    end

    local function UpdateConfigurationFilePaths()
        SendEmptyMsgToSV("Log4g_CLReq_SVConfigurationFiles")

        netReceive("Log4g_CLRcv_SVConfigurationFiles", function()
            local files = net.ReadData(net.ReadUInt(32))
            if not isstring(files) or #files == 0 then return end
            files = JSONToTable(util.Decompress(files))
            ConfigFileOption:Clear()
            if not next(files) then return end

            for k, v in pairs(files) do
                ConfigFileOption:AddChoice(k, v)
            end

            ConfigFileOption:ChooseOptionID(1)
        end)
    end

    function ConfigFileOption:OnSelect(_, _, data)
        TextEditor:SetText(data)
    end

    local function UpdateGUI()
        UpdateTime()
        UpdateIcon()
        UpdateSummary()
        UpdateConfigurationFilePaths()
        ClearTextEditor()
    end

    ViewMenu:AddOption("Refresh", function()
        UpdateGUI()
    end):SetIcon("icon16/arrow_refresh.png")

    UpdateGUI()
end)