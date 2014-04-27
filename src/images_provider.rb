class ImagesProvider

  def self.get(name, color = nil)
    image_key = color.nil? ? "#{name}" : "#{name}-#{color}" 
    Gtk::Image.new("#{SpritesLocation}/#{image_key}.png")
  end
end
