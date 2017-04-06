local lgi = require 'lgi'
local Gtk = lgi.Gtk
local Gdk = lgi.Gdk
local cairo = lgi.cairo
local serpent = require 'serpent'

local utils = require 'gardener.utils'

local window, header, stack
local gsbox, gbox, agbox, gswbox
local agentry
local glst
local sbbutton

data = dofile(os.getenv('HOME')..'/.config/gardener/conf.lua')

stack = Gtk.Stack {}

sbbutton = Gtk.ToolButton {
  icon_name = 'go-previous',
  sensitive = false,
  on_clicked = function (btn)
    stack:set_visible_child_name('gsbox')
    btn.sensitive = false
    window.title = "Gardener"
  end
}

header = Gtk.HeaderBar {
  title = 'Gardener',
  show_close_button = true
}

header:pack_start(sbbutton)

agentry = Gtk.Entry {
  expand = true,
  max_length = 32,
  placeholder_text = 'Patch'
}

agbox = Gtk.Box {
  orientation = 'HORIZONTAL',
  agentry,
  margin_bottom = 5,
  expand = true,
  Gtk.Button {
    on_clicked = function (btn)
      if agentry.text ~= '' then
        table.insert(data,{
          name = agentry.text
        })
        utils.update_lsbx(glst,data)
        agentry.text = ''
        window:show_all()
      end
    end,
    Gtk.Image {
      icon_name = 'list-add'
    }
  }
}

local agbox_sc = agbox:get_style_context()
agbox_sc:add_class('linked')

glst = Gtk.ListBox {
  on_row_activated = function(lbx,row,udata)
    local index = row:get_index() + 1
    local name = row:get_children()[1]:get_children()[1].label
    print(name,index)
    stack:set_visible_child_name("gbox")
    sbbutton.sensitive = true
    window.title = name
  end,
}

utils.update_lsbx(glst,data)

gswbox = Gtk.Box {
  width_request = 300,
  orientation = 'VERTICAL',
  halign = 'CENTER',
  valign = 'CENTER',
  agbox,
  Gtk.ScrolledWindow {
    min_content_width=400,
    min_content_height=300,
    hscrollbar_policy = 'NEVER',
    Gtk.Frame {
      glst
    }
  }
}

gsbox = Gtk.Box {
  orientation = 'VERTICAL',
  gswbox,
}

gbox = Gtk.Box {
  orientation = 'VERTICAL'
}

stack:add_titled(gsbox, "gsbox", "Garden Selection")
stack:add_titled(gbox, "gbox", "Garden")

window = Gtk.Window {
  default_width = 800,
  default_height = 600,
  stack
}

window:set_titlebar(header)

function window:on_destroy()
  Gtk.main_quit()
end

window:show_all()
Gtk:main()
