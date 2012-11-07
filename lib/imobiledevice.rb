require 'rubygems'
require 'ffi'
require_relative "./imobiledevice/version"
require_relative "./imobiledevice/c"
require_relative "./imobiledevice/idevice"
require_relative "./imobiledevice/ifile"

module IMobileDevice
  autoload :C, 'imobiledevice/c'
  autoload :IDevice, 'imobiledevice/idevice'
  autoload :IFile, 'imobiledevice/ifile'
  
  def self.device_list
    listptrptr = FFI::MemoryPointer.new(:pointer)
    countptr = FFI::MemoryPointer.new(:pointer)
    C.idevice_get_device_list(listptrptr, countptr)
    count = countptr.read_int
    listptr = listptrptr.read_pointer
    listptr.get_array_of_string(0, count).compact 
  end
end
