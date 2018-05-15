local imgui = require 'lib.imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	style.WindowRounding = 2.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
	style.ChildWindowRounding = 2.0
	style.FrameRounding = 2.0
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.GrabMinSize = 8.0
	style.GrabRounding = 1.0
	-- style.Alpha =
	-- style.WindowPadding =
	-- style.WindowMinSize =
	-- style.FramePadding =
	-- style.ItemInnerSpacing =
	-- style.TouchExtraPadding =
	-- style.IndentSpacing =
	-- style.ColumnsMinSpacing = ?
	-- style.ButtonTextAlign =
	-- style.DisplayWindowPadding =
	-- style.DisplaySafeAreaPadding =
	-- style.AntiAliasedLines =
	-- style.AntiAliasedShapes =
	-- style.CurveTessellationTol =

	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()

local h = {}
h.font_changed = false
h.isWantedFinderActive = imgui.ImBool(true)

h.minStarsCount = imgui.ImInt(1)
h.main_window_state = imgui.ImBool(false) 
h.is_radar_working = imgui.ImBool(false)
h.show_cursor = imgui.ImBool(imgui.ShowCursor)

function h.bindParams(cParser)
  h.cParser = cParser
end

function h.changeMainWindowsState()
  h.main_window_state.v = not h.main_window_state.v 
  imgui.Process = h.main_window_state
end

local wSize = imgui.ImVec2(300, 140)

function imgui.OnDrawFrame()
  if h.main_window_state.v then 
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowSize(wSize, imgui.Cond.FirstUseEver) 
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('AutoRadar for Diamond-RP', h.main_window_state)
    if (imgui.Checkbox(u8'Включить курсор', h.show_cursor)) then
      imgui.ShowCursor = h.show_cursor.v
    end
    imgui.Text(u8'Если курсора не видно')
    imgui.Text(u8'откройте чат и вклюите курсор')
    if (imgui.Checkbox(u8'Активировать радар', h.is_radar_working)) then 
      if (h.is_radar_working.v) then 
        notification("Вы активировали радар")
        wSize = imgui.ImVec2(300, 220)
      else 
        imgui.ImVec2(300, 120)
        notification("Вы деактивировали радар") 
      end
      imgui.SetWindowSize('AutoRadar for Diamond-RP', wSize)
    end

    if (h.is_radar_working.v) then
      if (imgui.Button(u8'Обновить список подозреваемых')) then
        h.cParser.refreshWantedList()
      end
      imgui.Text(u8'Минимальное кол-во')
      imgui.SliderInt('', h.minStarsCount, 1, 6)
      imgui.Text(u8(string.format("Количество преступников:%d", h.cParser.cHelper.count)))
    end
    imgui.SetWindowFontScale(1.2)
    -- if imgui.CollapsingHeader('Options') then
    --   if imgui.Checkbox('Render in menu', h.test) then
    --   end
    -- end
    -- if h.test.v then
    --   if imgui.Button('Refresh wanted list') then
    --     h.cParser.refreshWantedList() 
    --   end
    -- end

    -- if imgui.Button("Write all criminals") then
    --     h.criminal.v = not h.criminal.v
    -- end
    imgui.End()
  end

  -- if h.criminal.v then 
  --   imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver) 
  --   imgui.Begin(u8'Заключенные', h.criminal)
  --   for i, k in pairs(h.cParser.cHelper.wanted) do
  --     imgui.Text(u8(string.format("Заключенный %s. Уровень розыска: %d", i, k)))
  --   end
  --   imgui.End()
  -- end

end

return h

