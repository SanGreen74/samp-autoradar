local imgui = require 'lib.imgui'
local encoding = require 'encoding'
local h = {}

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
	-- style.WindowPadding = imgui.ImVec2(5.0, 12.0)
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

function applySettings()
  h.settings = {}
  h.settings.isWantedFinderActive = imgui.ImBool(false)
  h.settings.minStarsCount = imgui.ImInt(2)
  h.settings.maxDistance = imgui.ImInt(100) 
end

apply_custom_style()
applySettings()

h.main_window_state = imgui.ImBool(false) 
h.show_cursor = imgui.ImBool(imgui.ShowCursor)
function h.bindParams(cParser)
  h.cParser = cParser
end

function h.changeMainWindowsState()
  h.main_window_state.v = not h.main_window_state.v 
  imgui.Process = h.main_window_state
end

local wSize = imgui.ImVec2(300, 200)
function imgui.OnDrawFrame()
  if h.main_window_state.v then 
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowSize(wSize, imgui.Cond.FirstUseEver) 
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('AutoRadar for Diamond-RP', h.main_window_state, imgui.WindowFlags.NoResize)
    if (imgui.Checkbox(u8'�������� ������', h.show_cursor)) then
      imgui.ShowCursor = h.show_cursor.v
    end
    imgui.Text(u8'���� ������� �� �����\n�������� ��� � ������� ������')
    if (imgui.Checkbox(u8'������������ �����', h.settings.isWantedFinderActive)) then 
      onRadarChangeStatus()
    end

    if (h.settings.isWantedFinderActive.v) then
      addRadarMenu()
    end
    imgui.Text(u8'������ ������\n/aradar - ���� ����������\n/tdist - ���������� �� ������\n/refresh - �������� ������������')
    imgui.SetWindowFontScale(1.2)
    imgui.End()
  end

  function addSliders()
    addMinStartCountSlider()
    addMinDistanceSlider()
  end

  function addMinStartCountSlider() 
    imgui.Text(u8'����������� ������� �������')
    imgui.HelpMarker("����������� ������� ������� ��� ������������ ������")
    imgui.SliderInt('##minStars', h.settings.minStarsCount, 1, 6)
  end

  function addMinDistanceSlider()
    imgui.Text(u8'������ ������������ �������')
    imgui.SliderInt('##maxDistance', h.settings.maxDistance, 1, 250)
    imgui.HelpMarker("������������ ��������� ������������ �� ������������")
  end

  function addRadarMenu()
    if (imgui.Button(u8'�������� ������ �������������')) then
      h.cParser.refreshWantedList()
    end
    addSliders()
    imgui.Text(u8(string.format("���������� ������������: %d", h.cParser.cHelper.count)))
  end

  function onRadarChangeStatus()
    if (h.settings.isWantedFinderActive.v) then 
      notification("�� ������������ �����")
      wSize = imgui.ImVec2(300, 330)
    else 
      wSize = imgui.ImVec2(300, 200)
      notification("�� �������������� �����") 
      h.cParser.cHelper.clearAllCollections()
    end
    imgui.SetWindowSize('AutoRadar for Diamond-RP', wSize)
  end

  function setImguiSettings(sw, sh)
    imgui.SetNextWindowSize(wSize, imgui.Cond.FirstUseEver) 
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('AutoRadar for Diamond-RP', h.main_window_state, imgui.WindowFlags.NoResize)
  end

  function imgui.HelpMarker(text) 
    imgui.SameLine() 
    imgui.TextDisabled('(?)') 
    if imgui.IsItemHovered() then 
      imgui.BeginTooltip() 
      imgui.PushTextWrapPos(imgui.GetFontSize() * 35) 
      imgui.TextUnformatted(u8(text)) 
      imgui.PopTextWrapPos() 
      imgui.EndTooltip() 
    end 
  end
  -- if h.criminal.v then 
  --   imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver) 
  --   imgui.Begin(u8'�����������', h.criminal)
  --   for i, k in pairs(h.cParser.cHelper.wanted) do
  --     imgui.Text(u8(string.format("����������� %s. ������� �������: %d", i, k)))
  --   end
  --   imgui.End()
  -- end

end

return h

