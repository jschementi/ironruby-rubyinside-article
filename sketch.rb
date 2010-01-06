class DrawingSurface < UserControl
  include System
  include System::Windows::Threading
  
  class << self
    attr_reader :current
  
    def create(sketch_class)
      @current = self.new
      Application.current.root_visual = @current
      @current.content = Canvas.build do
        self.background = :black
        self.loaded do |_,_|
          DrawingSurface.current.set_sketch(sketch_class)
          DrawingSurface.current.start
        end
      end
      @current
    end
  end
  
  def initialize
    @timer = DispatcherTimer.new
    @timer.tick do |s,e|
      @each_frame_method.call if @each_frame_method
    end
    @timer.interval = TimeSpan.new(0,0,0,0,1000/30);
  end
  
  def set_sketch(sketch)
    @sketch = sketch.new(content)
    @each_frame_method = @sketch.respond_to?(:draw) ? @sketch.method(:draw) : nil
    @sketch.setup if @sketch.respond_to?(:setup)
  end
  
  def start
    @timer.start
  end
end

class Sketch
  attr_reader :canvas

  def initialize(canvas)
    @canvas = canvas
  end
  
  def self.create_sketch
    DrawingSurface.create(self)
  end
  
  def dimensions
    [canvas.actual_width, canvas.actual_height]
  end
  
  def rectangle(fields = {})
    left, top = fields.delete(:left), fields.delete(:top)
    shape = Rectangle.new
    fields.each do |key, value|
      shape.send("#{key}=", value)
    end
    Canvas.set_left(shape, left) if left
    Canvas.set_top(shape, top) if top
    shape
  end
  
  def square(fields = {})
    size = fields.delete(:size)
    rectangle({:width => size, :height => size}.merge(fields))
  end
end