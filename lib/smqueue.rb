class SMQueue
  VERSION = '1.0.0'

  attr_accessor :adapter

  def initialize uri = nil
    if uri
      adapter_class_name, options = *uri.split(/:\/\//, 2)
      adapter_class_name[0] = adapter_class_name[0..0].upcase
      adapter_class_name += 'Adapter'
      adapter_class = SMQueue::Adapter.const_get(adapter_class_name)
      @adapter = adapter_class.new(options)
    end
  end

  def channel *args
    raise "You must select an Adapter before connecting" if !@adapter
    @adapter.channel *args
  end
end
