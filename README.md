bluez-ibeacon
=============

Complete example of using Bluez as an iBeacon

How to use
==========

To use this example you will need to install [Bluez](http://www.bluez.org/)
either compiled by hand or through a development packaged libbluetooth. BTLE
support requires a recent version of Bluez so make sure to install the latest
version available.

After installing Bluez you can make the ibeacon binary in the bluez-beacon
directory.

Fire up XCode and run the BeaconDemo app on a device that supports BTLE such
as the iPhone 5 or later. The information displayed on screen is needed to run
the Bluez beacon.

Take the UUID displayed in the app along with the major and minor version and
plug those into the ibeacon binary like this:

```
./ibeacon 200 <UUID> <Major Number> <Minor Number> -29
```

If everything goes correctly you will get an alert on the device that you
have entered the region of the beacon. It can take a few seconds to register
so you may want to give it time if it doesn't pick up instantly. You may also
want to double check that the UUID is entered correctly if it doesn't seem to
work.

The passbook example uses a UUID of e2c56db5-dffb-48d2-b060-d0f5a71096e0, a
marjor number of 1 and a minor number of 1. After installing it you can use
the ibeacon program to advertise for it with the following options:

```
./ibeacon 200 e2c56db5dffb48d2b060d0f5a71096e0 1 1 -29
```

License
=======

MIT - See the LICENSE file
