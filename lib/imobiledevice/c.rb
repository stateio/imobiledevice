require 'ffi'
require 'imobiledevice'

module FFI
  class Pointer
    def read_unbound_array_of_string
      #Reads an array of strings terminated by an empty string (i.e.
      #not length bound
      ary = []
      size = FFI.type_size(:string)
      tmp = self
      begin
        s = tmp.read_pointer.read_string
        ary << s
        tmp += size
      end while !tmp.read_pointer.null?
      ary
    end
  end
end

module IMobileDevice
  module C
    extend FFI::Library
    ffi_lib 'libimobiledevice'

    #Error codes
    LOCKDOWN_ERRORS = { 0 => "LOCKDOWN_E_SUCCESS",
      -1 => "LOCKDOWN_E_INVALID_ARG",
      -2 => "LOCKDOWN_E_INVALID_CONF",
      -3 => "LOCKDOWN_E_PLIST_ERROR",
      -4 => "LOCKDOWN_E_PAIRING_FAILED",
      -5 => "LOCKDOWN_E_SSL_ERROR",
      -6 => "LOCKDOWN_E_DICT_ERROR",
      -7 => "LOCKDOWN_E_START_SERVICE_FAILED",
      -8 => "LOCKDOWN_E_NOT_ENOUGH_DATA",
      -9 => "LOCKDOWN_E_SET_VALUE_PROHIBITED",
      -10 => "LOCKDOWN_E_GET_VALUE_PROHIBITED",
      -11 => "LOCKDOWN_E_REMOVE_VALUE_PROHIBITED",
      -12 => "LOCKDOWN_E_MUX_ERROR",
      -13 => "LOCKDOWN_E_ACTIVATION_FAILED",
      -14 => "LOCKDOWN_E_PASSWORD_PROTECTED",
      -15 => "LOCKDOWN_E_NO_RUNNING_SESSION",
      -16 => "LOCKDOWN_E_INVALID_HOST_ID",
      -17 => "LOCKDOWN_E_INVALID_SERVICE",
      -18 => "LOCKDOWN_E_INVALID_ACTIVATION_RECORD",
      -256 => "LOCKDOWN_E_UNKNOWN_ERROR"}
    

    IDEVICE_EVENT_TYPE = enum(:IDEVICE_DEVICE_ADD, 1,
                              :IDEVICE_DEVICE_REMOVE)

    CONNECTION_TYPE =  enum(:CONNECTION_USBMUXD, 1)

    AFC_FILE_MODE = enum(:r, 1,
                         :rw,
                         :w,
                         :wr,
                         :append,
                         :rdappend)

    AFC_LOCK_OP = enum(:shared, 1,
                       :exclusive,
                       :unlock)

    #Typedefs
    typedef :int16, :idevice_error_t
    typedef :int16, :lockdownd_error_t
    typedef :int16, :afc_error_t
    typedef :int16, :house_arrest_error_t
    typedef :int16, :instproxy_error_t
    
    #Structs
    class IDeviceEvent < FFI::Struct
      layout :event, IDEVICE_EVENT_TYPE,
      :udid, :string,
      :conn_type, :int
    end

    class IDevice < FFI::ManagedStruct
      layout :udid, :string,
      :conn_type, CONNECTION_TYPE,
      :conn_data, :pointer

      def self.release(ptr)
        C.idevice_free(ptr)
      end
    end

    #Functions
    #idevice.h
    attach_function :idevice_set_debug_level, [:int], :void
    attach_function :idevice_get_device_list, [:pointer, :pointer], :idevice_error_t
    attach_function :idevice_new, [:pointer, :pointer], :idevice_error_t
    attach_function :idevice_free, [:pointer], :idevice_error_t
    #attach_function :idevice_connect, [:pointer, :pointer], :idevice_error_t
    #attach_function :idevice_disconnect, [:pointer], :idevice_error_t
    #attach_function :idevice_get_handle, [:pointer, :pointer], :idevice_error_t
    #attach_function :idevice_get_udid, [:pointer, :pointer], :idevice_error_t

    #lockdown.h
    #attach_function :lockdownd_client_new, [:pointer, :pointer, :string], :lockdownd_error_t
    attach_function :lockdownd_client_new_with_handshake, [:pointer, :pointer, :string], :lockdownd_error_t
    attach_function :lockdownd_client_free, [:pointer], :lockdownd_error_t
    attach_function :lockdownd_start_service, [:pointer, :string, :pointer], :lockdownd_error_t
    #attach_function :lockdownd_query_type, [:pointer, :pointer],
    #:lockdownd_error_t

    #afc.h
    attach_function :afc_client_new, [:pointer, :uint16, :pointer], :afc_error_t
    attach_function :afc_client_free, [:pointer], :afc_error_t
    attach_function :afc_read_directory, [:pointer, :string, :pointer], :afc_error_t
    attach_function :afc_get_file_info, [:pointer, :string, :pointer], :afc_error_t
    attach_function :afc_file_open, [:pointer, :string, :int, :pointer], :afc_error_t
    attach_function :afc_file_close, [:pointer, :uint64], :afc_error_t
    attach_function :afc_file_lock, [:pointer, :uint64, :int], :afc_error_t
    attach_function :afc_file_read, [:pointer, :uint64, :pointer, :uint32, :pointer], :afc_error_t
    attach_function :afc_file_write, [:pointer, :uint64, :string, :uint32, :pointer], :afc_error_t

    #house_arrest.h
    attach_function :house_arrest_client_new, [:pointer, :uint16, :pointer], :house_arrest_error_t
    attach_function :house_arrest_client_free, [:pointer], :house_arrest_error_t
    attach_function :house_arrest_send_request, [:pointer, :pointer], :house_arrest_error_t
    attach_function :house_arrest_send_command, [:pointer, :string, :string], :house_arrest_error_t
    attach_function :house_arrest_get_result, [:pointer, :pointer], :house_arrest_error_t
    attach_function :afc_client_new_from_house_arrest_client, [:pointer, :pointer], :afc_error_t
    
    #installation_proxy.h
    attach_function :instproxy_client_new, [:pointer, :uint16, :pointer], :instproxy_error_t
    attach_function :instproxy_browse, [:pointer, :pointer, :pointer], :instproxy_error_t
  end
end
