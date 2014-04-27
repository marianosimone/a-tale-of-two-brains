require 'config_panel'
require 'game_constants'

class InitGameWindow < Gtk::Window
  def initialize
    super
    SoundsPlayer.instance.play_background(MainMenuMusic)
    set_title(ProgramName)
    set_icon(IconLocation)
    set_window_position(Gtk::Window::POS_CENTER)

    @boxPpal = Gtk::VBox.new
    
    box_image = Gtk::HBox.new

    @imagen = Gtk::Image.new(Gdk::Pixbuf.new(MainWindowBackgroundLocation,800,520))
    box_image.pack_start(@imagen, false, false, 0)
    @boxPpal.pack_start(box_image, false, false, 0)

    box_buttons = Gtk::HBox.new

    button_init = Gtk::Button.new("Iniciar Partida")
    #se pasa a la ventana principal del juego
    button_init.signal_connect("clicked") {
       remove(@boxPpal)
       toConfigWin
    }
    box_buttons.add(button_init)

    button_about = Gtk::Button.new("Acerca de")
    button_about.signal_connect("clicked"){ show_about_box }
    box_buttons.add(button_about)

    button_exit=Gtk::Button.new("Salir")
    button_exit.signal_connect("clicked"){ Gtk.main_quit }
    
    signal_connect("delete_event"){ Gtk.main_quit }
    signal_connect("destroy"){ 
      Gtk.main_quit
      false
    }
    box_buttons.add(button_exit)

    @boxPpal.pack_start(box_buttons, false, false, 0)
    add(@boxPpal)
    show_all
  end
  
  def exit_event
    dialog = Gtk::Dialog.new("Finalizar Juego", self,
                             Gtk::Dialog::MODAL ,
                             [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT],
                             [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT])
    dialog.has_separator = false
    label = Gtk::Label.new("¿Esta seguro que desea abandonar el juego?")
    image = Gtk::Image.new(Gtk::Stock::DIALOG_WARNING, Gtk::IconSize::DIALOG)

    hbox = Gtk::HBox.new(false, 5)
    hbox.border_width = 10
    hbox.pack_start_defaults(image)
    hbox.pack_start_defaults(label)
    dialog.vbox.add(hbox)
    dialog.show_all

    response_id = dialog.run

    if (response_id == Gtk::Dialog::RESPONSE_OK) 
      dialog.destroy
      Gtk.main_quit
    end
  end
  
  def remove_widget
    remove(@config_panel)
  end

  def toConfigWin
    @config_panel = ConfigPanel.new(self)
    add(@config_panel)
    show_all
  end

  def backToInitWin
    SoundsPlayer.instance.play_background(MainMenuMusic)
    remove_widget
    add(@boxPpal)
    show_all
  end

  def show_about_box
    ad = Gtk::AboutDialog.new      
    ad.set_modal(true)
    ad.skip_taskbar_hint = true
    ad.name = ProgramName
    ad.program_name = ad.name
    ad.version = "1.0"
    ad.authors = ["Virginia Barros <virginanbarros@gmail.com>", "Mariano Simone <marianosimone@gmail.com>"]
    ad.comments = "Todas las imágenes usadas están bajo licencias CreativeCommons"
    ad.copyright = "GNU GPL - 2009 - Barros/Simone"
    ad.set_response_sensitive(1,true)
    ad.website = "http://code.google.com/p/virmafight/"
    ad.logo = Gdk::Pixbuf.new(AboutBoxLogoLocation)
    ad.icon = Gdk::Pixbuf.new(IconLocation)
    
    ad.signal_connect('response') { ad.destroy }

    ad.show_all 
  end
end
