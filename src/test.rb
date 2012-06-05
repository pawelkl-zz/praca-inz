require 'wx'
include Wx
 MENU_FILE_OPEN,MENU_FILE_SAVE,MENU_FILE_QUIT,MENU_INFO_ABOUT = 1..class TextFrame < WxFrame
  def initialize(title,xpos,ypos,width,height)
  super(nil, -1, title, WxPoint.new(xpos, ypos), WxSize.new(width, ight))
 @m_pTextCtrl = WxTextCtrl.new(self, -1, "Type some text...",
            Wx::wxDefaultPosition, Wx::wxDefaultSize, ::WxTE_MULTILINE)
 @m_pMenuBar = WxMenuBar.new
 @m_pFileMenu = WxMenu.new
  @m_pFileMenu.Append(MENU_FILE_OPEN, "&Open", "Opens an existing le")
 @m_pFileMenu.Append(MENU_FILE_SAVE, "&Save", "Save the content")
 @m_pFileMenu.AppendSeparator();
  @m_pFileMenu.Append(MENU_FILE_QUIT, "&Quit", "Quit the plication")
 @m_pMenuBar.Append(@m_pFileMenu, "&File")
 @m_pInfoMenu = WxMenu.new
 @m_pInfoMenu.Append(MENU_INFO_ABOUT, "&About", "Shows
information about the
application")
 @m_pMenuBar.Append(@m_pInfoMenu, "&Info")
 SetMenuBar(@m_pMenuBar)
 CreateStatusBar(3)
 SetStatusText("Ready", 0)
  end
  def OnMenuFileOpen
    puts "OnMenuFileOpen"
  end
  def OnMenuFileSave
    puts "OnMenuFileSave"
  end
  def OnMenuFileQuit
    Close(0)
  end
  def OnMenuInfoAbout
    puts "OnMenuInfoAbout"
  end
end
class WxApp < WxRbApp
  def initialize
    super
    __wxStart(self)
  end
  def OnInit()
    @frame = TextFrame.new("Simple Text Editor", 200, 200, 500, 500 EVT_MENU(@frame, MENU_FILE_OPEN,  "OnMenuFileOpen")
 EVT_MENU(@frame, MENU_FILE_SAVE,  "OnMenuFileSave")
 EVT_MENU(@frame, MENU_FILE_QUIT,  "OnMenuFileQuit")
 EVT_MENU(@frame, MENU_INFO_ABOUT, "OnMenuInfoAbout")
 @frame.Show()
 SetTopWindow(@frame)
  end
end
a = WxApp.new
a.MainLoop()
exit!