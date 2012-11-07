# Imobiledevice

Provides a ruby interface for libimobiledevice (http://www.libimobiledevice.org/).  So far, only a small subset of libimobiledevice's features are implemented.

## Installation

Add this line to your application's Gemfile:

    gem 'imobiledevice'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install imobiledevice

## Usage

``` pry
[1] pry(main)> require 'imobiledevice'
=> true
[2] pry(main)> i = IMobileDevice::IDevice.new
=> #<IMobileDevice::IDevice:0x007fd294da9bc0
 @device=#<FFI::Pointer address=0x007fd296e19640>,
 @udid=REDACTED>
[3] pry(main)> #Access media files
[4] pry(main)> i.start_afc
=> #<FFI::Pointer address=0x007fd296e3bb80>
[5] pry(main)> i.ls('/')
=> [".",
 "..",
 "AirFair",
 "Airlock",
 "ApplicationArchives",
 "Books",
 "DCIM",
 "Downloads",
 "HighlandPark",
 "PhotoData",
 "Photos",
 "Podcasts",
 "Purchases",
 "Recordings",
 "Safari",
 "general_storage",
 "iPhoneDrive",
 "iTunes_Control"]
[6] pry(main)> #Access an app's files
[7] pry(main)> i.access_app "com.atebits.ios.Letterpress"
=> #<FFI::Pointer address=0x007fd296eb1430>
[8] pry(main)> i.ls("/")
=> [".",
 "..",
 "Documents",
 "Letterpress.app",
 "Library",
 "iTunesArtwork",
 "iTunesMetadata.plist",
 "tmp"]
[9] pry(main)> #Open a file
[10] pry(main)> f = i.open("/Letterpress.app/o/aa.txt", :r) 
=> #<IMobileDevice::IFile:0x007fd294b71dd0
 @afc_client=#<FFI::Pointer address=0x007fd296eb1430>,
 @handle=1>
[11] pry(main)> puts f.read
aa
aah
aahed
aahing
aahs
aal
aalii
aaliis
aals
aardvark
aardvarks
aardwolf
aardwolves
aargh
aarrgh
aarrghh
aarti
aartis
aas
aasvogel
aasvogels
=> nil
[12] pry(main)> #Open a file for writing (this will delete it)
[13] pry(main)> f = i.open("/Letterpress.app/o/aa.txt", :w)
[18] pry(main)> f.write("FOO")
=> 0
```

## Todo

1. Implement more of libimobiledevice 
2. Handle errors better (especially for house_arrest)
3. Ability to parse plists from memory when functions return them 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
